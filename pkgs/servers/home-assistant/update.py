#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=channel:nixpkgs-unstable -i python3 -p "python3.withPackages (ps: with ps; [ aiohttp packaging ])" -p git nix-prefetch-git nodePackages.pyright isort ruff

import asyncio
import json
import os
import sys
from typing import Any, Dict, Final, List, Optional, Union
from subprocess import run, CalledProcessError

import aiohttp
from aiohttp import ClientSession
from packaging.version import LegacyVersion, Version
from packaging.version import parse as parse_version


def run_sync(cmd: List[str]) -> None:
    try:
        print(f"Running {cmd[0]}")
        run(cmd)
    except CalledProcessError:
        sys.exit(1)


async def check_async(cmd: List[str]) -> str:
    print(f"$ {' '.join(cmd)}")
    process = await asyncio.create_subprocess_exec(
        *cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    stdout, stderr = await process.communicate()

    if process.returncode != 0:
        error = stderr.decode()
        raise RuntimeError(f"{cmd[0]} failed: {error}")

    return stdout.decode().strip()


class Nurl:
    @classmethod
    async def prefetch(cls, url: str, version: LegacyVersion | Version) -> str:
        return await check_async(["nurl", "--hash", url, str(version)])


class Nixpkgs:
    @classmethod
    async def get_root(cls) -> str:
        return await check_async([
            "git",
            "rev-parse",
            "--show-toplevel",
        ])


class Nix:
    base_cmd: Final = [
        "nix",
        "--show-trace",
        "--extra-experimental-features", "nix-command"
    ]

    @classmethod
    async def _run(cls, args: List[str]) -> Optional[str]:
        return await check_async(cls.base_cmd + args)

    @classmethod
    async def eval(cls, expr: str) -> Union[List, Dict, int, float, str, bool]:
        response = await cls._run([
            "eval",
            "-f", f"{await Nixpkgs.get_root()}/default.nix",
            "--json",
            expr
        ])
        if response is None:
            raise RuntimeError("Nix eval expression returned no response")
        try:
            return json.loads(response)
        except (TypeError, ValueError):
            raise RuntimeError("Nix eval response could not be parsed from JSON")

    @classmethod
    async def hash_to_sri(cls, algorithm: str, value: str) -> Optional[str]:
        return await cls._run([
            "hash",
            "to-sri",
            "--type", algorithm,
            value
        ])


class HomeAssistant:
    def __init__(self, session: ClientSession):
        self._session = session
    
    async def get_latest_core_version(self, owner: str = "home-assistant", repo: str = "core") -> str:
        async with self._session.get(
            f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
        ) as response:
            document = await response.json()
        try:
            return str(document.get("name"))
        except KeyError:
            raise RuntimeError("No tag name in response document")


    async def get_latest_frontend_version(self, core_version: Version | LegacyVersion) -> str:
        async with self._session.get(
            f"https://raw.githubusercontent.com/home-assistant/core/{core_version}/homeassistant/components/frontend/manifest.json"
        ) as response:
            document = await response.json(content_type="text/plain")
    
        requirements = [
            requirement
            for requirement in document.get("requirements", [])
            if requirement.startswith("home-assistant-frontend==")
        ]
    
        if len(requirements) > 1:
            raise RuntimeError("Found more than one version specifier for the frontend package")
        elif len(requirements) == 1:
            requirement = requirements.pop()
            _, version = requirement.split("==", maxsplit=1)
            return str(version)
        else:
            raise RuntimeError("Found no version specifier for frontend package")


    async def update_core(self, version: Version | LegacyVersion) -> None:
        sdist_hash_current = await Nix.eval("home-assistant.src.outputHash")
        sdist_hash_latest = await Nurl.prefetch("https://pypi.org/project/homeassistant/", version)
        print(f"sdist: {sdist_hash_current} -> {sdist_hash_latest}")

        git_hash_current = await Nix.eval("home-assistant.gitSrc.outputHash")
        git_hash_latest = await Nurl.prefetch("https:github.com/home-assistant/core/", version)
        print(f"git: {git_hash_current} -> {git_hash_latest}")


    async def update_frontend(self, version: Version | LegacyVersion) -> None:
        hash_current = await Nix.eval("home-assistant.python.pkgs.home-assistant-frontend.src.outputHash")
        hash_latest = await Nurl.prefetch("https://github.com/home-assistant/frontend/", version)
        print(f"frontend: {hash_current} -> {hash_latest}")


async def main():
    headers = {}
    if token := os.environ.get("GITHUB_TOKEN", None):
        headers.update({"GITHUB_TOKEN": token})    
    
    async with aiohttp.ClientSession(headers=headers) as client:
        hass = HomeAssistant(client)

        core_current = parse_version(
            str(await Nix.eval("home-assistant.version"))
        )
        core_latest = parse_version(await hass.get_latest_core_version())

        if core_latest > core_current:
            print(f"Update core from {core_current} to {core_latest}")
            await hass.update_core(core_latest)

            frontend_current = parse_version(
                str(await Nix.eval("home-assistant.python.pkgs.home-assistant-frontend.version"))
            )
            frontend_latest = parse_version(await hass.get_latest_frontend_version(core_latest))

            if frontend_latest > frontend_current:
                print(f"Update frontend from {frontend_current} to {frontend_latest}")
                await hass.update_frontend(frontend_latest)

        else:
            print(f"Home Assistant {core_current} is still the latest version.")

        # wait for async client sessions to close
        # https://docs.aiohttp.org/en/stable/client_advanced.html#graceful-shutdown
        await asyncio.sleep(0)

if __name__ == "__main__":
    run_sync(["pyright", __file__])
    run_sync(["isort", __file__])
    asyncio.run(main())
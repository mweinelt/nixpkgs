{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "lego";
  version = "5.0.4";

  src = fetchFromGitHub {
    owner = "go-acme";
    repo = "lego";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nGJRWt+ZA1rGPalFj6sD299MDX215vBky70+nQJwgto=";
  };

  vendorHash = "sha256-//UVZHEYjMHZFkm8H49KIhpQATRTJatveOnQzI6L0uw=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Let's Encrypt client and ACME library written in Go";
    license = lib.licenses.mit;
    homepage = "https://go-acme.github.io/lego/";
    teams = [ lib.teams.acme ];
    mainProgram = "lego";
  };

  passthru.tests = {
    lego-http = nixosTests.acme.http01-builtin;
    lego-dns = nixosTests.acme.dns01;
  };
})

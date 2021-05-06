import ./make-test-python.nix ({ pkgs, lib, ... }:

let
  configDir = "/var/lib/foobar";
  userName = "admin";
  password = "secret";
in {
  name = "home-assistant";
  meta.maintainers = lib.teams.home-assistant.members;

  nodes.hass = { pkgs, ... }: {
    virtualisation.memorySize = 1024;

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensurePermissions = {
          "DATABASE hass" = "ALL PRIVILEGES";
        };
      }];
    };

    services.home-assistant = {
      enable = true;
      inherit configDir;

      # tests loading components by overriding the package
      package = (pkgs.home-assistant.override {
        extraPackages = ps: with ps; [
          colorama
        ];
        extraComponents = [ "zha" ];
      }).overrideAttrs (oldAttrs: {
        doInstallCheck = false;
      });

      # tests loading components from the module
      extraComponents = [
        "wake_on_lan"
      ];

      # test extra package passing from the module
      extraPackages = python3Packages: with python3Packages; [
        psycopg2
      ];

      config = {
        homeassistant = {
          name = "Home";
          time_zone = "UTC";
          latitude = "0.0";
          longitude = "0.0";
          elevation = 0;
        };

        # configure the recorder component to use the postgresql db
        recorder.db_url = "postgresql://@/hass";

        # we can't load default_config, because the updater requires
        # network access and would cause an error, so load frontend
        # here explicitly.
        # https://www.home-assistant.io/integrations/frontend/
        frontend = {};

        # set up a wake-on-lan switch to test capset capability required
        # for the ping suid wrapper
        # https://www.home-assistant.io/integrations/wake_on_lan/
        switch = [ {
          platform = "wake_on_lan";
          mac = "00:11:22:33:44:55";
          host = "127.0.0.1";
        } ];

        # test component-based capability assignment (CAP_NET_BIND_SERVICE)
        # https://www.home-assistant.io/integrations/emulated_hue/
        emulated_hue = {
          host_ip = "127.0.0.1";
          listen_port = 80;
        };

        # https://www.home-assistant.io/integrations/logger/
        logger = {
          default = "info";
          logs."homeassistant.components.http" = "debug";
        };
      };

      # configure the sample lovelace dashboard
      lovelaceConfig = {
        title = "My Awesome Home";
        views = [{
          title = "Example";
          cards = [{
            type = "markdown";
            title = "Lovelace";
            content = "Welcome to your **Lovelace UI**.";
          }];
        }];
      };
      lovelaceConfigWritable = true;
    };

    # Cause a configuration change inside `configuration.yml` and verify that the process is being reloaded.
    specialisation.differentName = {
      inheritParentConfig = true;
      configuration.services.home-assistant.config.homeassistant.name = lib.mkForce "Test Home";
    };

    # Cause a configuration change that requires a service restart as we added a new runtime dependency
    specialisation.newFeature = {
      inheritParentConfig = true;
      configuration.services.home-assistant.config.esphome = {};
    };

    environment.systemPackages = let
      testRunner = pkgs.writers.writePython3Bin "test-runner" {
        libraries = with pkgs.python3Packages; [ selenium structlog ];
      } ''
        from os import mkdir
        from selenium.webdriver import Chrome
        from selenium.webdriver.firefox.options import Options
        from selenium.webdriver.support.ui import WebDriverWait
        from selenium.webdriver.support import expected_conditions as EC
        from selenium.webdriver.common.by import By
        # from selenium.webdriver.common.keys import Keys

        mkdir("/tmp/screenshots")

        options = Options()
        options.add_argument("--headless")
        driver = Chrome(options=options)
        wait = WebDriverWait(driver, 10)

        # Wait for browser startup
        driver.implicitly_wait(10)

        driver.get("http://localhost:8123/onboarding.html")
        wait.until(EC.title_contains("Home Assistant"))

        # press space to trigger a redraw
        # driver.find_element_by_tag_name('body').send_keys(Keys.SPACE)

        driver.save_screenshot("/tmp/screenshots/step_onboarding_user.png")


        def select(*argv):
            script = "return document"
            for arg in argv:
                script += arg
            print(script)
            return driver.execute_script(script)


        def qs(selector, shadow_root=False):
            ret = f".querySelector('{selector}')"
            if shadow_root:
                ret += ".shadowRoot"
            return ret


        def set_attribute(key, value, element):
            driver.execute_script(
                f"arguments[0].setAttribute('{key}', '{value}')",
                element
            )


        onboarding = driver.find_element(
          By.TAG_NAME, "ha-onboarding").shadow_root
        onboarding_create_user = onboarding.find_element(
          By.TAG_NAME, "onboarding-create-user")[0].shadow_root
        ha_form = onboarding_create_user.find_element(
          By.TAG_NAME, "ha-form")[0].shadow_root
        ha_selectors = ha_form.find_elements(
          By.TAG_NAME, "ha-selector").shadow_root
        print(ha_selectors)


        input_name = select(
            qs('ha-onboarding', shadow_root=True),
            qs('onboarding-create-user', shadow_root=True),
            qs('form > paper-input:nth-child(1)', shadow_root=True),
            qs('#container > iron-input > input')
        )
        set_attribute("value", "${userName}", input_name)

        input_username = select(
            qs('ha-onboarding', shadow_root=True),
            qs('onboarding-create-user', shadow_root=True),
            qs('form > paper-input:nth-child(2)', shadow_root=True),
            qs('#container > iron-input > input')
        )
        set_attribute("value", "${userName}", input_username)

        input_password1 = select(
            qs('ha-onboarding', shadow_root=True),
            qs('onboarding-create-user', shadow_root=True),
            qs('form > paper-input:nth-child(3)', shadow_root=True),
            qs('#container > iron-input > input')
        )
        set_attribute("value", "${password}", input_password1)

        input_password2 = select(
            qs('ha-onboarding', shadow_root=True),
            qs('onboarding-create-user', shadow_root=True),
            qs('form > paper-input:nth-child(4)', shadow_root=True),
            qs('#container > iron-input')
        )
        set_attribute("value", "${password}", input_password2)

        driver.save_screenshot("/tmp/screenshots/step_onboarding_user2.png")

        button_create_account = select(
            qs('ha-onboarding', shadow_root=True),
            qs('onboarding-create-user', shadow_root=True),
            qs('mwc-button', shadow_root=True),
            qs('button')
        )
        button_create_account.click()

        driver.save_screenshot("/tmp/screenshots/step_onboarding_core_config.png")


        driver.close()
        print("close")
      '';
    in with pkgs; [
      chromium
      chromedriver
      testRunner
    ];
  };

  testScript = { nodes, ... }: let
    system = nodes.hass.config.system.build.toplevel;
  in
  ''
    import re
    import json

    start_all()

    # Parse the package path out of the systemd unit, as we cannot
    # access the final package, that is overriden inside the module,
    # by any other means.
    pattern = re.compile(r"path=(?P<path>[\/a-z0-9-.]+)\/bin\/hass")
    response = hass.execute("systemctl show -p ExecStart home-assistant.service")[1]
    match = pattern.search(response)
    assert match
    package = match.group('path')


    def get_journal_cursor(host) -> str:
        exit, out = host.execute("journalctl -u home-assistant.service -n1 -o json-pretty --output-fields=__CURSOR")
        assert exit == 0
        return json.loads(out)["__CURSOR"]


    def wait_for_homeassistant(host, cursor):
        host.wait_until_succeeds(f"journalctl --after-cursor='{cursor}' -u home-assistant.service | grep -q 'Home Assistant initialized in'")


    hass.wait_for_unit("home-assistant.service")
    cursor = get_journal_cursor(hass)

    with subtest("Check that YAML configuration file is in place"):
        hass.succeed("test -L ${configDir}/configuration.yaml")

    with subtest("Check the lovelace config is copied because lovelaceConfigWritable = true"):
        hass.succeed("test -f ${configDir}/ui-lovelace.yaml")

    with subtest("Check extraComponents and extraPackages are considered from the package"):
        hass.succeed(f"grep -q 'colorama' {package}/extra_packages")
        hass.succeed(f"grep -q 'zha' {package}/extra_components")

    with subtest("Check extraComponents and extraPackages are considered from the module"):
        hass.succeed(f"grep -q 'psycopg2' {package}/extra_packages")
        hass.succeed(f"grep -q 'wake_on_lan' {package}/extra_components")

    with subtest("Check that Home Assistant's web interface and API can be reached"):
        wait_for_homeassistant(hass, cursor)
        hass.wait_for_open_port(8123)
        hass.succeed("curl --fail http://localhost:8123/lovelace")

    with subtest("Check that capabilities are passed for emulated_hue to bind to port 80"):
        hass.wait_for_open_port(80)
        hass.succeed("curl --fail http://localhost:80/description.xml")

    with subtest("Check extra components are considered in systemd unit hardening"):
        hass.succeed("systemctl show -p DeviceAllow home-assistant.service | grep -q char-ttyUSB")

    with subtest("Check service reloads when configuration changes"):
      # store the old pid of the process
      pid = hass.succeed("systemctl show --property=MainPID home-assistant.service")
      cursor = get_journal_cursor(hass)
      hass.succeed("${system}/specialisation/differentName/bin/switch-to-configuration test")
      new_pid = hass.succeed("systemctl show --property=MainPID home-assistant.service")
      assert pid == new_pid, "The PID of the process should not change between process reloads"
      wait_for_homeassistant(hass, cursor)

    with subtest("check service restarts when package changes"):
      pid = new_pid
      cursor = get_journal_cursor(hass)
      hass.succeed("${system}/specialisation/newFeature/bin/switch-to-configuration test")
      new_pid = hass.succeed("systemctl show --property=MainPID home-assistant.service")
      assert pid != new_pid, "The PID of the process shoudl change when the HA binary changes"
      wait_for_homeassistant(hass, cursor)

    with subtest("Check that no errors were logged"):
        output_log = hass.succeed("cat ${configDir}/home-assistant.log")
        assert "ERROR" not in output_log

    with subtest("Check systemd unit hardening"):
        hass.log(hass.succeed("systemctl cat home-assistant.service"))
        hass.log(hass.succeed("systemd-analyze security home-assistant.service"))

    with subtest("Test onboarding"):
        hass.execute(
            "systemd-run --wait --unit hass-onboarding -E PATH=${pkgs.geckodriver}/bin:$PATH -E PYTHONUNBUFFERED=1 test-runner"
        )
        hass.copy_from_vm("/tmp/screenshots")
  '';
})

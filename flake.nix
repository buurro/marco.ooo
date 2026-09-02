{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    # Design tokens + component CSS the site's layouts are built on.
    # `nix flake update retro-ui` to pull a newer revision.
    retro-ui = {
      url = "github:buurro/ui";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    retro-ui,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        version = "0.1.8";

        port = "8000";

        pkgs = import nixpkgs {inherit system;};

        buildDependencies = with pkgs; [hugo];

        # Hugo reads the retro-ui CSS from assets/retro-ui (see layouts/partials/head.html).
        retroUiSrc = "${retro-ui}/src";

        marcoooo = pkgs.stdenv.mkDerivation {
          name = "marco-ooo";
          version = version;
          src = ./.;
          buildInputs = buildDependencies;

          # works on macos for some reason
          buildPhase = ''
            mkdir -p assets
            rm -rf assets/retro-ui
            cp -r ${retroUiSrc} assets/retro-ui
            ${pkgs.hugo}/bin/hugo
          '';
          installPhase = ''
            cp -r public $out
          '';
        };
      in rec {
        devShells.default = pkgs.mkShell {
          # Links the pinned retro-ui into assets/. Point the link at a local
          # checkout (../ui/src) instead to iterate on the tokens live.
          shellHook = ''
            mkdir -p assets
            [ -e assets/retro-ui ] || ln -s ${retroUiSrc} assets/retro-ui
          '';
          buildInputs = buildDependencies;
        };
        packages =
          {
            default = packages.sws;

            sws = pkgs.writeShellScriptBin "marco-ooo-server" ''
              ${pkgs.lib.getExe pkgs.static-web-server} -p ${port} -g info -d ${marcoooo}
            '';

            caddy = pkgs.writeShellScriptBin "marco-ooo-server" ''
              ${pkgs.caddy}/bin/caddy file-server --listen :${port} --root ${marcoooo}
            '';

            html = marcoooo;
          }
          // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            containerImage = pkgs.dockerTools.streamLayeredImage {
              name = "ghcr.io/buurro/marco.ooo";
              tag = version;
              created = "now";
              contents = [packages.sws];
              config = {
                Cmd = ["/bin/marco-ooo-server"];
                ExposedPorts = {
                  "${port}/tcp" = {};
                };
              };
            };
          };
      }
    );
}

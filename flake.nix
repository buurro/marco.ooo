{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      version = "0.1.7";

      port = "8000";

      pkgs = import nixpkgs { inherit system; };

      buildDependencies = with pkgs; [ hugo ];

      themeCongo = pkgs.fetchFromGitHub {
        owner = "jpanther";
        repo = "congo";
        rev = "v2.12.2";
        sha256 = "sha256-VzO4hQH+o2a65sH6CA1bQjTDuFRRyUQOP17f4J0kCKY=";
      };

      marcoooo = pkgs.stdenv.mkDerivation {
        name = "marco-ooo";
        version = version;
        src = ./.;
        buildInputs = buildDependencies;

        # works on macos for some reason
        buildPhase = ''
          mkdir -p themes
          cp -r ${themeCongo} themes/congo
          ${pkgs.hugo}/bin/hugo
        '';
        installPhase = ''
          cp -r public $out
        '';
      };

    in
    rec {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          rm themes/congo
          mkdir -p themes
          ln -s ${themeCongo} themes/congo
        '';
        buildInputs = buildDependencies;
      };
      packages = {
        default = packages.sws;

        sws = pkgs.writeShellScriptBin "marco-ooo-server" ''
          ${pkgs.lib.getExe pkgs.static-web-server} -p ${port} -g info -d ${marcoooo}
        '';

        caddy = pkgs.writeShellScriptBin "marco-ooo-server" ''
          ${pkgs.caddy}/bin/caddy file-server --listen :${port} --root ${marcoooo}
        '';

        html = marcoooo;
      } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
        containerImage = pkgs.dockerTools.streamLayeredImage {
          name = "ghcr.io/buurro/marco.ooo";
          tag = version;
          created = "now";
          contents = [ packages.sws ];
          config = {
            Cmd = [ "/bin/marco-ooo-server" ];
            ExposedPorts = {
              "${port}/tcp" = { };
            };
          };
        };
      };
    }
  );
}

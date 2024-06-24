{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      version = "0.1.0";

      pkgs = import nixpkgs { inherit system; };

      buildDependencies = with pkgs; [ hugo ];

      themeCongo = pkgs.fetchFromGitHub {
        owner = "jpanther";
        repo = "congo";
        rev = "v2.6.1";
        sha256 = "0l36wvgn97cpkmjj095fz8hc6fa0vm8hrh63vcsqikhfpr79l3yq";
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
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          rm themes/congo
          mkdir -p themes
          ln -s ${themeCongo} themes/congo
        '';
        buildInputs = buildDependencies;
      };
      packages = rec {
        default = sws;

        sws = pkgs.writeShellScriptBin "marco-ooo-server" ''
          ${pkgs.lib.getExe pkgs.static-web-server} -p 8000 -g info -d ${marcoooo}
        '';

        busybox = pkgs.writeShellScriptBin "marco-ooo-server" ''
          ${pkgs.busybox}/bin/httpd file-server -f -p 8000 -v -h ${marcoooo}
        '';

        caddy = pkgs.writeShellScriptBin "marco-ooo-server" ''
          ${pkgs.caddy}/bin/caddy file-server --listen :8000 --root ${marcoooo}
        '';

        containerImage = pkgs.dockerTools.buildImage {
          name = "ghcr.io/buurro/marco.ooo";
          tag = "latest";
          created = "now";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ sws ];
            pathsToLink = [ "/bin" ];
          };
          config = {
            Cmd = [ "/bin/marco-ooo-server" ];
            Expose = [ 8000 ];
          };
        };
        html = marcoooo;
      };
    }
  );
}

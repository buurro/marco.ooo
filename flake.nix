{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

      buildDependencies = with pkgs; [ git go hugo ];

      themeCongo = pkgs.fetchFromGitHub {
        owner = "jpanther";
        repo = "congo";
        rev = "v2.6.1";
        sha256 = "0l36wvgn97cpkmjj095fz8hc6fa0vm8hrh63vcsqikhfpr79l3yq";
      };

      marcoooo = pkgs.stdenv.mkDerivation {
        name = "marco-ooo";
        version = "0.1.0";
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

      nginxPort = "80";
      nginxConf = pkgs.writeText "nginx.conf" ''
        user nobody nobody;
        daemon off;
        error_log /dev/stdout info;
        pid /dev/null;
        events {}
        http {
          include ${pkgs.nginx}/conf/mime.types;
          access_log /dev/stdout;
          server {
            listen ${nginxPort};
            index index.html;
            location / {
              root ${marcoooo};
            }
          }
        }
      '';

    in
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          mkdir themes; ln -s ${themeCongo} themes/congo
        '';
        buildInputs = buildDependencies;
      };
      packages = {
        default = marcoooo;
        server = pkgs.writeShellScriptBin "marco-ooo-server" ''
          ${pkgs.nginx}/sbin/nginx -c ${nginxConf}
        '';
      };
    }
  );
}

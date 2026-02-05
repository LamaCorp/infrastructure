{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-terraform.url = "github:NixOS/nixpkgs/nixos-23.11";
    futils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-terraform
    , futils
    ,
    } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (futils.lib) eachDefaultSystem defaultSystems;

      nixpkgsFor = lib.genAttrs defaultSystems (system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfreePredicate = pkg:
              builtins.elem (lib.getName pkg) [
                "vault"
              ];
          };
        });
    in
    (eachDefaultSystem (
      system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (import nixpkgs-terraform {
              inherit system;
              config = {
                allowUnfreePredicate = pkg:
                  builtins.elem (lib.getName pkg) [
                    "terraform"
                  ];
              };
            }).terraform
            cargo
            git
            jq
            openssl
            python314
            rustc
            shellcheck
            uv
            vault
          ];

          shellHook = ''
            source ./config.sh
          '';

          UV_NO_BINARY_PACKAGE = "ruff";

          # See https://github.com/NixOS/nix/issues/318#issuecomment-52986702
          LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
        };
      }
    ));
}

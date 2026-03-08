{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    futils,
  } @ inputs: let
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
  in (eachDefaultSystem (
    system: let
      pkgs = nixpkgsFor.${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          cargo
          git
          jq
          openssl
          opentofu
          python314
          rustc
          shellcheck
          uv
          vault
        ];

        UV_NO_BINARY_PACKAGE = "ruff";

        # See https://github.com/NixOS/nix/issues/318#issuecomment-52986702
        LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";

        VAULT_ADDR = "https://vault.as212024.net:443";
      };
    }
  ));
}

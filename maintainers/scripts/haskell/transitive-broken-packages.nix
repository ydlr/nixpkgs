let
  nixpkgs = import ../../..;
  inherit (nixpkgs {}) pkgs lib;
  getEvaluating = x:
    builtins.attrNames (
      lib.filterAttrs (
        _: v: (builtins.tryEval (v.outPath or null)).success && lib.isDerivation v && !v.meta.broken
      ) x
    );
  brokenDeps = lib.subtractLists
    (getEvaluating pkgs.haskellPackages)
    (getEvaluating (nixpkgs { config.allowBroken = true; }).haskellPackages);
in
''
  # This file is automatically generated by
  # maintainers/scripts/haskell/regenerate-transitive-broken-packages.sh
  # It is supposed to list all haskellPackages that cannot evaluate because they
  # depend on a dependency marked as broken.
  dont-distribute-packages:
  ${lib.concatMapStringsSep "\n" (x: "  - ${x}") brokenDeps}
''

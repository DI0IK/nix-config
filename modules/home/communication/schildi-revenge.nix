{ pkgs, ... }: {
  home.persistence."/persist".directories = [
    ".config/SchildiChatRevenge"
  ];

  home.packages = [
    # Workaround for nixpkgs aws-lc-sys build failure (issue #570938, PR #585576):
    # Nixpkgs exports AWS_LC_SYS_USE_SYSTEM=1 by default, but schildi-revenge drives
    # cargo through Gradle (:matrixRustBindings:buildDesktopSdk) without cargoBuildHook,
    # causing cargo to panic when no system AWS-LC is found.
    # Setting dontCargoUseSystemLibs = true and AWS_LC_SYS_USE_SYSTEM = "0" restores
    # building the vendored AWS-LC copy.
    # Can be removed once PR #585576 lands in nixpkgs or when prebuilt on Hydra.
    (pkgs.schildi-revenge.overrideAttrs (_old: {
      dontCargoUseSystemLibs = true;
      AWS_LC_SYS_USE_SYSTEM = "0";
    }))
  ];
}

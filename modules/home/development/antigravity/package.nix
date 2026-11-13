{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  cacert,
  writeShellScript,
  coreutils,
  gawk,
  getconf,
  gnugrep,
  gnused,
  which,
  copyDesktopItems,
  makeDesktopItem,
  imagemagick,
  asar,
  autoPatchelfHook,
  buildPackages,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libdbusmenu,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxshmfence,
  libxtst,
  nspr,
  nss,
  pango,
  pipewire,
  systemdLibs,
  wayland,
  commandLineArgs ? "",
}:

let
  inherit (stdenv) hostPlatform;
  information = lib.importJSON ./information.json;
  source =
    information.sources."${hostPlatform.system}"
      or (throw "antigravity: unsupported system ${hostPlatform.system}");

  pname = "antigravity";
  inherit (information) version;
  executableName = "antigravity";
  longName = "Antigravity";
  shortName = "Antigravity";
  libraryName = "antigravity";
  iconName = "antigravity";
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchurl { inherit (source) url sha256; };

  strictDeps = true;
  __structuredAttrs = true;

  dontBuild = true;
  dontConfigure = true;
  noDumpEnvVars = true;

  nativeBuildInputs = [
    imagemagick
    autoPatchelfHook
    asar
    copyDesktopItems
    (buildPackages.wrapGAppsHook3.override { makeWrapper = buildPackages.makeShellWrapper; })
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libsecret
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxkbfile
    libxrandr
    libxshmfence
    libxtst
    nspr
    nss
    pango
    pipewire
    systemdLibs
  ];

  runtimeDependencies = [
    systemdLibs
    fontconfig.lib
    libdbusmenu
    wayland
    libsecret
    libpulseaudio
  ];

  desktopItems = [
    (makeDesktopItem {
      name = executableName;
      desktopName = longName;
      comment = "Antigravity - Agentic Desktop Application";
      genericName = "Agentic Desktop Application";
      exec = "${executableName} %U";
      icon = iconName;
      startupNotify = true;
      startupWMClass = shortName;
      categories = [
        "Development"
        "IDE"
        "Utility"
      ];
      mimeTypes = [
        "inode/directory"
        "x-scheme-handler/${iconName}"
      ];
      keywords = [ "antigravity" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/${libraryName}" "$out/bin"
    cp -r ./* "$out/lib/${libraryName}"

    ln -s "$out/lib/${libraryName}/${executableName}" "$out/bin/${executableName}"

    mkdir -p "$out/share/pixmaps"
    asar extract-file "$out/lib/${libraryName}/resources/app.asar" icon.png
    cp icon.png "$out/share/pixmaps/${iconName}.png"

    size=$(identify -format "%wx%h" icon.png)
    mkdir -p "$out/share/icons/hicolor/$size/apps"
    cp icon.png "$out/share/icons/hicolor/$size/apps/${iconName}.png"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libdbusmenu ]}
      --prefix PATH : ${
        lib.makeBinPath [
          glib
          gawk
          gnugrep
          gnused
          coreutils
          which
          getconf
        ]
      }
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}"
      --append-flags ${lib.escapeShellArg commandLineArgs}
    )
  '';

  postFixup = ''
    patchelf \
      --add-needed ${libglvnd}/lib/libGLESv2.so.2 \
      --add-needed ${libglvnd}/lib/libGL.so.1 \
      --add-needed ${libglvnd}/lib/libEGL.so.1 \
      "$out/lib/${libraryName}/${executableName}"
  '';

  passthru =
    let
      fhs =
        {
          additionalPkgs ? pkgs: [ ],
        }:
        buildFHSEnv {
          pname = executableName;
          inherit version;

          targetPkgs =
            pkgs:
            (with pkgs; [
              glibc
              curl
              icu
              libunwind
              libuuid
              lttng-ust
              openssl
              zlib
              krb5
              glib
              gtk3
              nspr
              nss
              dbus
              at-spi2-atk
              at-spi2-core
              cups
              expat
              libdrm
              libxkbcommon
              libx11
              libxcomposite
              libxdamage
              libxcb
              libxext
              libxfixes
              libxrandr
              libxshmfence
              libxtst
              cairo
              pango
              alsa-lib
              libgbm
              udev
              libudev0-shim
            ])
            ++ additionalPkgs pkgs;

          extraBwrapArgs = [
            "--bind-try /etc/nixos/ /etc/nixos/"
            "--ro-bind-try /etc/xdg/ /etc/xdg/"
            "--tmpfs /opt/google/chrome"
            "--symlink ${cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/cert.pem"
          ];

          extraBuildCommands = ''
            mkdir -p "$out/opt/google/chrome"
          '';

          extraInstallCommands = ''
            ln -s "${finalAttrs.finalPackage}/share" "$out/"
          '';

          runScript = writeShellScript "antigravity-wrapper" ''
            for candidate in google-chrome-stable google-chrome chromium-browser chromium; do
              if target=$(command -v "$candidate"); then
                ${coreutils}/bin/ln -sf "$target" /opt/google/chrome/chrome
                break
              fi
            done
            exec "${finalAttrs.finalPackage}/bin/${executableName}" "$@"
          '';

          dieWithParent = false;

          passthru = {
            inherit executableName;
            inherit (finalAttrs.finalPackage) pname version;
          };

          meta = finalAttrs.meta // {
            description = "Wrapped variant of ${pname} which launches in a FHS compatible environment";
          };
        };
    in
    {
      inherit
        executableName
        iconName
        longName
        ;
      updateScript = ./update.js;
      fhs = (fhs { }).overrideAttrs {
        strictDeps = true;
        __structuredAttrs = true;
      };
      fhsWithPackages =
        f:
        (fhs { additionalPkgs = f; }).overrideAttrs {
          strictDeps = true;
          __structuredAttrs = true;
        };
    };

  meta = {
    mainProgram = "antigravity";
    description = "Antigravity - Agentic Desktop Application";
    homepage = "https://antigravity.google";
    downloadPage = "https://antigravity.google/download";
    changelog = "https://antigravity.google/docs/changelog?tab=hub";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})

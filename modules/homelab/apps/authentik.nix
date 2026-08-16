{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.authentik;
  inherit (lib) types;
  helpers = import ./authentik-helpers.nix { inherit lib; };

  blueprintDir = "/etc/authentik-blueprints";

  appOptionType = types.submodule {
    options = {
      type = lib.mkOption {
        type = types.nullOr (
          types.enum [
            "forward-auth"
            "oidc"
            "oidc-public"
          ]
        );
        default = null;
        description = "Provider type: forward-auth (proxy), oidc (confidential OAuth2), or oidc-public";
      };

      name = lib.mkOption {
        type = types.str;
        description = "Display name for the application";
      };

      slug = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "URL slug for the application (defaults to kebab-case of name)";
      };

      group = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Group name for access control (defaults to name)";
      };

      roleGroups = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Role group names (created as children of the parent group)";
      };

      extraGroups = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional standalone groups to create";
      };

      # Forward Auth specific
      externalHost = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "External URL for forward auth (e.g., https://app.example.com)";
      };

      accessTokenValidity = lib.mkOption {
        type = types.str;
        default = "hours=16";
        description = "Access token validity duration";
      };

      # OIDC specific
      clientId = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "OAuth2 client ID (null = auto-generate)";
      };

      clientSecret = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "OAuth2 client secret (null = auto-generate, or use sops.placeholder)";
      };

      redirectUris = lib.mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              url = lib.mkOption { type = types.str; };
              matching_mode = lib.mkOption {
                type = types.enum [
                  "strict"
                  "regex"
                ];
                default = "strict";
              };
            };
          }
        );
        default = [ ];
        description = "OAuth2 redirect URIs";
      };

      scopes = lib.mkOption {
        type = types.listOf types.str;
        default = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        description = "OAuth2 scopes (maps to Authentik scope mappings)";
      };

      # Escape hatch
      extraEntries = lib.mkOption {
        type = types.lines;
        default = "";
        description = "Extra YAML blueprint entries to append";
      };

      rawBlueprint = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Raw blueprint YAML content (bypasses helpers entirely)";
      };
    };
  };

  resolveApp = app: {
    inherit (app)
      name
      type
      roleGroups
      extraGroups
      externalHost
      accessTokenValidity
      clientId
      clientSecret
      redirectUris
      scopes
      extraEntries
      rawBlueprint
      ;
    slug =
      if app.slug != null then app.slug else lib.toLower (lib.replaceStrings [ " " ] [ "-" ] app.name);
    group = if app.group != null then app.group else app.name;
  };

  generateBlueprint =
    appName: rawApp:
    let
      app = resolveApp rawApp;
    in
    if app.rawBlueprint != null then
      app.rawBlueprint
    else if app.type == "forward-auth" then
      helpers.mkForwardAuthBlueprint {
        inherit (app)
          name
          slug
          group
          accessTokenValidity
          extraEntries
          ;
        externalHost = app.externalHost;
      }
    else
      helpers.mkOidcBlueprint {
        inherit (app)
          name
          slug
          clientId
          clientSecret
          redirectUris
          scopes
          group
          roleGroups
          accessTokenValidity
          extraEntries
          ;
      };

  activeApps = lib.filterAttrs (_: app: app.rawBlueprint != null || app.type != null) cfg.apps;
  allBlueprints = lib.mapAttrs generateBlueprint activeApps;

  blueprintFiles = lib.mapAttrs' (
    name: content:
    lib.nameValuePair "${name}.yaml" {
      text = content;
    }
  ) allBlueprints;
in
{
  options.homelab.apps.authentik.enable = lib.mkEnableOption "Authentik identity provider";

  options.homelab.authentik = {
    apps = lib.mkOption {
      type = types.attrsOf appOptionType;
      default = { };
      description = "Authentik applications to create via blueprints";
    };
  };

  config = lib.mkIf config.homelab.apps.authentik.enable {
    services.authentik = {
      enable = true;
      createDatabase = true;
      environmentFile = config.sops.secrets.authentik-env.path;
      nginx.enable = false;
      settings = {
        redis = {
          host = "127.0.0.1";
          port = 6379;
        };
        storage.media.file.path = "/persist/apps/authentik";
        blueprints_dir = blueprintDir;
      };
    };

    users.users.authentik = {
      isSystemUser = true;
      group = "authentik";
      home = "/persist/apps/authentik";
      createHome = false;
    };
    users.groups.authentik = { };

    systemd.tmpfiles.rules = [
      "d /var/lib/authentik 0700 authentik authentik -"
      "d /persist/apps/authentik 0700 authentik authentik -"
      "d ${blueprintDir} 0755 authentik authentik -"
    ];

    systemd.services = {
      authentik.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
      };
      authentik-worker.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
      };
      authentik-migrate.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
      };
    };

    homelab.traefik.apps.authentik = {
      host = "sso.dominikstahl.dev";
      port = 9000;
    };

    sops.secrets.authentik-env = {
      owner = "root";
      mode = "0400";
    };

    environment.etc = lib.mapAttrs' (
      filename: fileDef:
      lib.nameValuePair "authentik-blueprints/${filename}" {
        text = fileDef.text;
        group = "authentik";
        user = "authentik";
      }
    ) blueprintFiles;
  };
}

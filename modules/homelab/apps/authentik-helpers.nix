{ lib }:

let
  indent = n: lib.concatStringsSep "" (lib.genList (_: "  ") n);
  scopeToManaged = scope:
    if scope == "openid" then "goauthentik.io/providers/oauth2/scope-openid"
    else if scope == "email" then "goauthentik.io/providers/oauth2/scope-email"
    else if scope == "profile" then "goauthentik.io/providers/oauth2/scope-profile"
    else if scope == "groups" then "goauthentik.io/providers/oauth2/scope-groups"
    else if scope == "offline_access" then "goauthentik.io/providers/oauth2/scope-offline_access"
    else "goauthentik.io/providers/oauth2/scope-${scope}";
in
{
  mkForwardAuthBlueprint = {
    name,
    slug ? (lib.toLower (lib.replaceStrings [ " " ] [ "-" ] name)),
    group ? name,
    externalHost,
    accessTokenValidity ? "hours=16",
    extraEntries ? "",
  }: ''
    version: 1
    metadata:
      labels:
        blueprints.goauthentik.io/description: "Forward Auth for ${name}"
      name: "ForwardAuth - ${name}"
    entries:
      # Required flows
      - model: authentik_blueprints.metaapplyblueprint
        attrs:
          identifiers:
            name: Default - Authentication flow
        required: true
      - model: authentik_blueprints.metaapplyblueprint
        attrs:
          identifiers:
            name: Default - Provider authorization flow (explicit consent)
        required: true

      # Group
      - model: authentik_core.group
        id: group-${slug}
        identifiers:
          name: ${group}
        state: present

      # Provider
      - model: authentik_providers_proxy.proxyprovider
        id: provider-${slug}
        identifiers:
          name: ${slug}-forward-auth-provider
        attrs:
          authorization_flow: !Find [authentik_flows.flow, [slug, default-provider-authorization-explicit-consent]]
          authentication_flow: !Find [authentik_flows.flow, [slug, default-authentication-flow]]
          invalidation_flow: !Find [authentik_flows.flow, [slug, default-provider-invalidation-flow]]
          external_host: "${externalHost}"
          mode: forward_single
          access_token_validity: "${accessTokenValidity}"
        state: present

      # Application
      - model: authentik_core.application
        id: ${slug}-application
        identifiers:
          slug: ${slug}-forward-auth-application
        attrs:
          name: ${name}
          policy_engine_mode: any
          provider: !KeyOf provider-${slug}
        state: present

      # Policy binding
      - model: authentik_policies.policybinding
        identifiers:
          target: !Find [authentik_core.application, [slug, ${slug}-forward-auth-application]]
        attrs:
          group: !KeyOf group-${slug}
          target: !Find [authentik_core.application, [slug, ${slug}-forward-auth-application]]
          order: 0
        state: present
    ${extraEntries}
  '';

  mkOidcBlueprint = {
    name,
    slug ? (lib.toLower (lib.replaceStrings [ " " ] [ "-" ] name)),
    clientId ? null,
    clientSecret ? null,
    redirectUris ? [ ],
    scopes ? [ "openid" "profile" "email" "groups" ],
    group,
    roleGroups ? [ ],
    accessTokenValidity ? "hours=16",
    extraEntries ? "",
  }: ''
    version: 1
    metadata:
      labels:
        blueprints.goauthentik.io/description: "OpenID Connect for ${name}"
      name: "OpenID Connect - ${name}"
    entries:
      # Required flows
      - model: authentik_blueprints.metaapplyblueprint
        attrs:
          identifiers:
            name: Default - Authentication flow
        required: true
      - model: authentik_blueprints.metaapplyblueprint
        attrs:
          identifiers:
            name: Default - Provider authorization flow (explicit consent)
        required: true

      # Parent group
      - model: authentik_core.group
        id: group-${slug}
        identifiers:
          name: ${group}
        state: present
    ${lib.concatMapStringsSep "\n" (role: ''
      # Role group: ${role}
      - model: authentik_core.group
        identifiers:
          name: ${group} ${role}
        parent: !KeyOf group-${slug}
        state: present
    '') roleGroups}

      # Provider
      - model: authentik_providers_oauth2.oauth2provider
        id: provider-${slug}
        identifiers:
          name: ${slug}-openid-connect-provider
        attrs:
          authorization_flow: !Find [authentik_flows.flow, [slug, default-provider-authorization-explicit-consent]]
          authentication_flow: !Find [authentik_flows.flow, [slug, default-authentication-flow]]
          invalidation_flow: !Find [authentik_flows.flow, [slug, default-provider-invalidation-flow]]
          client_id: "${if clientId != null then clientId else ""}"
          client_secret: "${if clientSecret != null then clientSecret else ""}"
          redirect_uris:
    ${lib.concatMapStringsSep "\n" (uri: "            - url: \"${uri.url}\"\n              matching_mode: \"${uri.matching_mode}\"") redirectUris}
          property_mappings:
    ${lib.concatMapStringsSep "\n" (scope: "            - !Find [authentik_providers_oauth2.scopemapping, [managed, ${scopeToManaged scope}]]") scopes}
          signing_key: !Find [authentik_crypto.certificatekeypair, [name, authentik Self-signed Certificate]]
          access_token_validity: "${accessTokenValidity}"
          client_type: confidential
        state: present

      # Application
      - model: authentik_core.application
        id: ${slug}-application
        identifiers:
          slug: ${slug}
        attrs:
          name: ${name}
          policy_engine_mode: any
          provider: !KeyOf provider-${slug}
        state: present

      # Policy binding
      - model: authentik_policies.policybinding
        identifiers:
          target: !Find [authentik_core.application, [slug, ${slug}]]
        attrs:
          group: !KeyOf group-${slug}
          target: !Find [authentik_core.application, [slug, ${slug}]]
          order: 0
        state: present
    ${extraEntries}
  '';
}

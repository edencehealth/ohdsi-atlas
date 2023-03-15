#!/bin/sh
set -e

warn() {
  printf '%s %s\n' "$(date '+%FT%T')" "$*" >&2
}

die() {
  warn "FATAL:" "$@"
  exit 1
}

main() {
  # Set defaults for values we expect to come from the container environment
  # NOTE: exported variables are those expected to be used by envsubst

  # DOCUMENT_ROOT is the container path from which nginx will serve content
  DOCUMENT_ROOT="${DOCUMENT_ROOT:-/usr/share/nginx/html}"

  # ---------------------------------------------------------------------------

  # CACHE_SOURCES: bool
  export CACHE_SOURCES="${CACHE_SOURCES:-0}"

  # COHORT_COMPARISON_RESULTS_ENABLED: bool
  export COHORT_COMPARISON_RESULTS_ENABLED="${COHORT_COMPARISON_RESULTS_ENABLED:-0}"

  # DEFAULT_LOCALE: string
  export DEFAULT_LOCALE="${DEFAULT_LOCALE:-en}"

  # ENABLE_AUTH_AD: bool
  export ENABLE_AUTH_AD="${ENABLE_AUTH_AD:-0}"

  # ENABLE_AUTH_DB: bool
  export ENABLE_AUTH_DB="${ENABLE_AUTH_DB:-0}"

  # ENABLE_AUTH_GITHUB: bool
  export ENABLE_AUTH_GITHUB="${ENABLE_AUTH_GITHUB:-0}"

  # ENABLE_AUTH_GOOGLE: bool
  export ENABLE_AUTH_GOOGLE="${ENABLE_AUTH_GOOGLE:-0}"

  # ENABLE_AUTH_KERBEROS: bool
  export ENABLE_AUTH_KERBEROS="${ENABLE_AUTH_KERBEROS:-0}"

  # ENABLE_AUTH_LDAP: bool
  export ENABLE_AUTH_LDAP="${ENABLE_AUTH_LDAP:-0}"

  # ENABLE_AUTH_OPENID: bool
  export ENABLE_AUTH_OPENID="${ENABLE_AUTH_OPENID:-0}"

  # ENABLE_AUTH_SAML: bool
  export ENABLE_AUTH_SAML="${ENABLE_AUTH_SAML:-0}"

  # ENABLE_AUTH_WINDOWS: bool
  export ENABLE_AUTH_WINDOWS="${ENABLE_AUTH_WINDOWS:-0}"

  # ENABLE_COSTS: bool
  export ENABLE_COSTS="${ENABLE_COSTS:-0}"

  # ENABLE_TERMS_AND_CONDITIONS: bool
  export ENABLE_TERMS_AND_CONDITIONS="${ENABLE_TERMS_AND_CONDITIONS:-0}"

  # PLP_RESULTS_ENABLED: bool
  export PLP_RESULTS_ENABLED="${PLP_RESULTS_ENABLED:-0}"

  # POLL_INTERVAL: int
  export POLL_INTERVAL="${POLL_INTERVAL:-60000}"

  # SUPPORT_MAIL: string
  export SUPPORT_MAIL="${SUPPORT_MAIL:-atlasadmin@example.com}"

  # SUPPORT_URL: string
  export SUPPORT_URL="${SUPPORT_URL:-https://github.com/ohdsi/atlas/issues}"

  # USER_AUTHENTICATION_ENABLED: bool
  export USER_AUTHENTICATION_ENABLED="${USER_AUTHENTICATION_ENABLED:-0}"

  # USE_EXECUTION_ENGINE: bool
  export USE_EXECUTION_ENGINE="${USE_EXECUTION_ENGINE:-0}"

  # VIEW_PROFILE_DATES: bool
  export VIEW_PROFILE_DATES="${VIEW_PROFILE_DATES:-0}"

  # WEBAPI_NAME: string - maps to appConfig.api.name - upstream defaults to "Local"
  export WEBAPI_NAME="${WEBAPI_NAME:-OHDSI}"

  # WEBAPI_URL: string - URL where WebAPI can be queried by the client - should always end in a slash
  export WEBAPI_URL="${WEBAPI_URL:-http://localhost:8080/WebAPI/}"

  # the Dockerfile has to put *something* in the final target location because
  # we're doing "COPY --chown=nginx src dest". That something might as well be
  # the template that we want to fill. this obviates the need for a /templates
  # directory and keeps things maybe semi-functional when debugging

  # shellcheck disable=SC2066
  for target in \
    "${DOCUMENT_ROOT}/js/config-local.js" \
  ; do
    warn "templating ${target}..."
    [ -f "${target}" ] || die "Could not find the file ${target}"
    printf '%s\n' "$(envsubst <"$target")" >"$target"
    warn "templating results ${target}:"
    cat "$target" >&2
  done
}

main "$@"

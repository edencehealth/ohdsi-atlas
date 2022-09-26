define([], function () {
  // this file will have values templated in with envsubst, these values come
  // from the container's runtime environment at startup

  let parseBool = function (envString) {
    return ["1", "enable", "on", "true", "y", "yes"].includes(
      envString.toLowerCase()
    );
  };

  var configLocal = {
    api: {
      name: "$WEBAPI_NAME",
      url: "$WEBAPI_URL",
    },
    authProviders: [], // see below
    cacheSources: parseBool("$CACHE_SOURCES"),
    cohortComparisonResultsEnabled: parseBool(
      "$COHORT_COMPARISON_RESULTS_ENABLED"
    ),
    defaultLocale: "$DEFAULT_LOCALE",
    enableCosts: parseBool("$ENABLE_COSTS"),
    enableTermsAndConditions: parseBool("$ENABLE_TERMS_AND_CONDITIONS"),
    plpResultsEnabled: parseBool("$PLP_RESULTS_ENABLED"),
    pollInterval: parseInt("$POLL_INTERVAL"),
    supportMail: "$SUPPORT_MAIL",
    supportUrl: "$SUPPORT_URL",
    useExecutionEngine: parseBool("$USE_EXECUTION_ENGINE"),
    userAuthenticationEnabled: parseBool("$USER_AUTHENTICATION_ENABLED"),
    viewProfileDates: parseBool("$VIEW_PROFILE_DATES"),
  };

  let availableAuthProviders = [
    {
      name: "Windows",
      url: "user/login/windows",
      ajax: true,
      icon: "fa fa-windows",
      enabled: "$ENABLE_AUTH_WINDOWS",
    },
    {
      name: "Kerberos",
      url: "user/login/kerberos",
      ajax: true,
      icon: "fa fa-windows",
      enabled: "$ENABLE_AUTH_KERBEROS",
    },
    {
      name: "OpenID",
      url: "user/login/openid",
      ajax: false,
      icon: "fa fa-openid",
      enabled: "$ENABLE_AUTH_OPENID",
    },
    {
      name: "Google",
      url: "user/oauth/google",
      ajax: false,
      icon: "fa fa-google",
      enabled: "$ENABLE_AUTH_GOOGLE",
    },
    {
      name: "Github",
      url: "user/oauth/github",
      ajax: false,
      icon: "fa fa-github",
      enabled: "$ENABLE_AUTH_GITHUB",
    },
    {
      name: "DB",
      url: "user/login/db",
      ajax: true,
      icon: "fa fa-database",
      isUseCredentialsForm: true,
      enabled: "$ENABLE_AUTH_DB",
    },
    {
      name: "LDAP",
      url: "user/login/ldap",
      ajax: true,
      icon: "fa fa-cubes",
      isUseCredentialsForm: true,
      enabled: "$ENABLE_AUTH_LDAP",
    },
    {
      name: "SAML",
      url: "user/login/saml",
      ajax: false,
      icon: "fa fa-openid",
      enabled: "$ENABLE_AUTH_SAML",
    },
    {
      name: "Active Directory LDAP",
      url: "user/login/ad",
      ajax: true,
      icon: "fa fa-cubes",
      isUseCredentialsForm: true,
      enabled: "$ENABLE_AUTH_AD",
    },
  ];

  for (let provider of availableAuthProviders) {
    if (parseBool(provider.enabled)) {
      delete provider["enabled"];
      configLocal.authProviders.push(provider);
    }
  }

  return configLocal;
});

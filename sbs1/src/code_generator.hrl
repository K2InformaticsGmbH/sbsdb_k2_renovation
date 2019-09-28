%% -----------------------------------------------------------------------------
%%
%% code_generator.hrl: SBSDB - code script generator.
%%
%% -----------------------------------------------------------------------------

-define(CHAR_NEWLINE, case os:type() of
                          {unix, _} -> "\n";
                          _ -> "\r\n"
                      end).

-ifndef(CODE_GENERATOR_HRL).
-define(CODE_GENERATOR_HRL, true).

-ifdef(NODEBUG).
-define(D(Format), undefined).
-define(D(Format, Args), undefined).
-else.
-define(D(Format), ?D(Format, [])).
-define(D(Format, Args), io:format(user, "~p:~p:~p ===> "Format, [?MODULE, ?FUNCTION_NAME, ?LINE | Args])).
-endif.

-define(DEPLOY_DIRECTORY, "src/deploy/").
-define(DEPLOY_DIRECTORY_TEST, "test/src/deploy/").

-define(E(Format), ?E(Format, [])).
-define(E(Format, Args), io:format(user, "~p:~p:~p ===> "Format, [?MODULE, ?FUNCTION_NAME, ?LINE | Args])).

-define(FILE_NAME_SBSDB_API_GROUP_TRANS, "sbsdb_api_group_trans.fnc").
-define(FILE_NAME_SBSDB_API_SCOPE_HELP, "sbsdb_api_scope_help.fnc").
-define(FILE_NAME_SBSDB_API_SCOPE_TRANS, "sbsdb_api_scope_trans.fnc").

-define(FILE_SUFFIX_FUNCTIONS, ".fnc").
-define(FILE_SUFFIX_PACKAGES_BODY, ".pkb").
-define(FILE_SUFFIX_PACKAGES_SPEC, ".pks").
-define(FILE_SUFFIX_PROCEDURES, ".prc").
-define(FILE_XSD, "sbsdb.xsd").

% Options: developer / k2 / swisscom
-define(HELP_VARIANT, developer).

-define(I(Format), ?I(Format, [])).
-define(I(Format, Args), io:format(user, "~p ===> "Format, [?MODULE | Args])).

% Options: file / table
-define(IO_TYPE_LOG, table).
-define(IO_TYPE_PROPERTY, file).

-define(PATH_CONTEXT, "src/context/").
-define(PATH_FUNCTIONS, "src/functions/").
-define(PATH_FUNCTIONS_GENERATED, "src/functions/generated/").
-define(PATH_INSTALL_DEPLOY, "install/deploy/").
-define(PATH_INSTALL_DEPLOY_TEST, "test/install/deploy/").
-define(PATH_INSTALL_GENERATED, "install/generated/").
-define(PATH_INSTALL_GENERATED_TEST, "test/install/generated/").
-define(PATH_PACKAGES_GENERATED, "src/packages/generated/").
-define(PATH_PACKAGES, "src/packages/").
-define(PATH_PACKAGES_TEST, "test/src/packages/").
-define(PATH_PROCEDURES, "src/procedures/").
-define(PATH_TYPES, "src/types/").
-define(PATH_XSD, "priv/").

-define(WCARD_CONTEXT, "*.sql").
-define(WCARD_FUNCTIONS, "*.fnc").
-define(WCARD_PACKAGES_BODY, "*.pkb").
-define(WCARD_PACKAGES_SPEC, "*.pks").
-define(WCARD_PROCEDURES, "*.prc").
-define(WCARD_SYNONYMS, "*.sql").
-define(WCARD_TRIGGERS, "*.trg").
-define(WCARD_TYPES, "*.tps").
-define(WCARD_VIEWS, "*.vw").

-record(api_group_trans_entry, {
    apiGroup,
    apiScope,
    packageImplName,
    packageName,
    methodName
}).

-record(api_scope_help_entry, {
    apiHelpText,
    packageImplName,
    packageName,
    methodName = []
}).

-record(api_scope_trans_entry, {
    apiScope,
    packageImplName,
    packageName,
    methodName
}).

-record(function, {
    apiGroups = [],
    apiHidden = [],
    manPage = [],
    name,
    versions = []
}).

-record(package, {
    functions = [],
    manPage = [],
    implName,
    name,
    privileges = [],
    procedures = []
}).

-record(parameter, {
    dataType,
    defaultValue = {none, []},
    loggerToCharacter = true,
    mode = "IN",
    name = []
}).

-record(parser_state, {
    apiGroupTransEntries = [],
    apiScopeHelpEntries = [],
    apiScopeTransEntries = [],
    localNames = {},
    package,
    privileges = []
}).

-record(privilege, {
    object = [],
    type = []
}).

-record(procedure, {
    apiGroups = [],
    apiHidden = [],
    manPage = [],
    name,
    versions = []
}).

-record(version, {
    condition = {none, []},
    parameters = [],
    pipelined = [],
    returnDataType
}).

-endif.

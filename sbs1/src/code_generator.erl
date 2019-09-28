%% -----------------------------------------------------------------------------
%%
%% code_generator.erl: SBSDB - code generator.
%%
%% -----------------------------------------------------------------------------

-module(code_generator).

-export([generate/0]).

-define(NODEBUG, true).

-include("code_generator.hrl").

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract API Group Translation Entries.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

extract_api_group_trans(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    ApiGroupsTransF = extract_api_group_trans(function, ParserState#parser_state.package#package.name, ParserState#parser_state.package#package.implName,
        ParserState#parser_state.package#package.functions,
        ParserState#parser_state.apiGroupTransEntries),
    ApiGroupsTransP = extract_api_group_trans(procedure, ParserState#parser_state.package#package.name, ParserState#parser_state.package#package.implName,
        ParserState#parser_state.package#package.procedures,
        ApiGroupsTransF),

    ?D("End~n ApiGroupsTrans: ~p~n", [ApiGroupsTransP]),
    ApiGroupsTransP.

extract_api_group_trans(_Type, _PackageName, _PackageImplName, [] = _Method, ApiGroupsTrans) ->
    ?D("Start~n Type: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n ApiGroupsTrans: ~p~n",
        [_Type, _PackageName, _PackageImplName, _Method, ApiGroupsTrans]),
    ApiGroupsTrans;
extract_api_group_trans(function = Type, PackageName, PackageImplName, [Method | Tail], ApiGroupsTrans) ->
    ?D("Start~n Type: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n ApiGroupsTrans: ~p~n",
        [Type, PackageName, PackageImplName, Method, ApiGroupsTrans]),

    MethodName = Method#function.name,
    ApiGroupTransEntry = #api_group_trans_entry{apiScope = get_api_scope("SBSDB_AC_",
        lists:append([PackageName, ".", MethodName])), packageImplName = PackageImplName, packageName = PackageName, methodName = MethodName},

    ApiGroupsTransNew = extract_api_group_trans(ApiGroupTransEntry, case Method#function.apiGroups of
                                                                        [] -> case string:uppercase(PackageName) of
                                                                                  "SBSDB_STANDALONE_SPEC" -> ["not_assigned"];
                                                                                  _ -> [PackageName]
                                                                              end;
                                                                        _ ->
                                                                            Method#function.apiGroups
                                                                    end, ApiGroupsTrans),

    ?D("End~n ApiGroupsTrans: ~p~n", [ApiGroupsTransNew]),
    extract_api_group_trans(Type, PackageName, PackageImplName, Tail, ApiGroupsTransNew);
extract_api_group_trans(procedure = Type, PackageName, PackageImplName, [Method | Tail], ApiGroupsTrans) ->
    ?D("Start~n Type: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n ApiGroupsTrans: ~p~n",
        [Type, PackageName, PackageImplName, Method, ApiGroupsTrans]),

    MethodName = Method#procedure.name,
    ApiGroupTransEntry = #api_group_trans_entry{apiScope = get_api_scope("SBSDB_AC_",
        lists:append([PackageName, ".", MethodName])), packageImplName = PackageImplName, packageName = PackageName, methodName = MethodName},

    ApiGroupsTransNew = extract_api_group_trans(ApiGroupTransEntry, case Method#procedure.apiGroups of
                                                                        [] -> case string:uppercase(PackageName) of
                                                                                  "SBSDB_STANDALONE_SPEC" -> ["not_assigned"];
                                                                                  _ -> [PackageName]
                                                                              end;
                                                                        _ ->
                                                                            Method#procedure.apiGroups
                                                                    end, ApiGroupsTrans),

    ?D("End~n ApiGroupsTrans: ~p~n", [ApiGroupsTransNew]),
    extract_api_group_trans(Type, PackageName, PackageImplName, Tail, ApiGroupsTransNew).

extract_api_group_trans(_ApiGroupTransEntry, [] = _ApiGroup, ApiGroupsTrans) ->
    ?D("Start~n ApiGroupTransEntry: ~p~n ApiGroup: ~p~n ApiGroupsTrans: ~p~n", [_ApiGroupTransEntry, _ApiGroup, ApiGroupsTrans]),
    ApiGroupsTrans;
extract_api_group_trans(ApiGroupTransEntry, [ApiGroup | Tail], ApiGroupsTrans) ->
    ?D("Start~n ApiGroupTransEntry: ~p~n ApiGroup: ~p~n ApiGroupsTrans: ~p~n", [ApiGroupTransEntry, ApiGroup, ApiGroupsTrans]),

    ApiGroupsTransNew = ApiGroupsTrans ++ [ApiGroupTransEntry#api_group_trans_entry{apiGroup = ApiGroup}],

    ?D("End~n ApiGroupsTrans: ~p~n", [ApiGroupsTransNew]),
    extract_api_group_trans(ApiGroupTransEntry, Tail, ApiGroupsTransNew).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract API Scope Help Entries.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

extract_api_scope_help(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    Package = ParserState#parser_state.package,

    ApiScopesHelpF =
        extract_api_scope_help(function, Package, ParserState#parser_state.package#package.functions, ParserState#parser_state.apiScopeHelpEntries),
    ApiScopesHelpP = extract_api_scope_help(procedure, Package, ParserState#parser_state.package#package.procedures, ApiScopesHelpF),

    ManPage = Package#package.manPage,

    ApiScopesHelpS = case ManPage of
                         [] -> ApiScopesHelpP;
                         _ -> ApiScopesHelpP ++
                         [#api_scope_help_entry{apiHelpText = ManPage, packageName = Package#package.name, packageImplName = Package#package.implName}]
                     end,

    ?D("End~n ApiScopesHelp: ~p~n", [ApiScopesHelpS]),
    ApiScopesHelpS.
extract_api_scope_help(_Type, _Package, [] = _Method, ApiScopesHelp) ->
    ?D("Start~n Type: ~p~n Package: ~p~n Method: ~p~n ApiScopesHelp: ~p~n", [_Type, _Package, _Method, ApiScopesHelp]),
    ApiScopesHelp;
extract_api_scope_help(function = Type, Package, [Method | Tail], ApiScopesHelp)
    when Method#function.manPage == [] ->
    ?D("Start~n Type: ~p~n Package: ~p~n Method: ~p~n ApiScopesHelp: ~p~n", [Type, Package, Method, ApiScopesHelp]),
    extract_api_scope_help(Type, Package, Tail, ApiScopesHelp);
extract_api_scope_help(function = Type, Package, [Method | Tail], ApiScopesHelp) ->
    ?D("Start~n Type: ~p~n Package: ~p~n Method: ~p~n ApiScopesHelp: ~p~n", [Type, Package, Method, ApiScopesHelp]),
    ApiScopeHelpEntry =
        #api_scope_help_entry{apiHelpText = Method#function.manPage, packageName = Package#package.name, packageImplName = Package#package.implName, methodName = Method#function.name},
    ?D("ApiScopeHelpEntry: ~p~n", [ApiScopeHelpEntry]),
    ApiScopesHelpNew = ApiScopesHelp ++ [ApiScopeHelpEntry],
    ?D("End~n ApiScopesHelp: ~p~n", [ApiScopesHelpNew]),
    extract_api_scope_help(Type, Package, Tail, ApiScopesHelpNew);
extract_api_scope_help(procedure = Type, Package, [Method | Tail], ApiScopesHelp)
    when Method#procedure.manPage == [] ->
    ?D("Start~n Type: ~p~n Package: ~p~n Method: ~p~n ApiScopesHelp: ~p~n", [Type, Package, Method, ApiScopesHelp]),
    extract_api_scope_help(Type, Package, Tail, ApiScopesHelp);
extract_api_scope_help(procedure = Type, Package, [Method | Tail], ApiScopesHelp) ->
    ?D("Start~n Type: ~p~n Package: ~p~n Method: ~p~n ApiScopesHelp: ~p~n", [Type, Package, Method, ApiScopesHelp]),
    ApiScopeHelpEntry =
        #api_scope_help_entry{apiHelpText = Method#procedure.manPage, packageName = Package#package.name, packageImplName = Package#package.implName, methodName = Method#procedure.name},
    ?D("ApiScopeHelpEntry: ~p~n", [ApiScopeHelpEntry]),
    ApiScopesHelpNew = ApiScopesHelp ++ [ApiScopeHelpEntry],
    ?D("End~n ApiScopesHelp: ~p~n", [ApiScopesHelpNew]),
    extract_api_scope_help(Type, Package, Tail, ApiScopesHelpNew).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract API Scope Translation Entries.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

extract_api_scope_trans(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    ApiScopesTransF = extract_api_scope_trans(function, ParserState#parser_state.package#package.name, ParserState#parser_state.package#package.implName,
        ParserState#parser_state.package#package.functions, ParserState#parser_state.apiScopeTransEntries),
    ApiScopesTransP = extract_api_scope_trans(procedure, ParserState#parser_state.package#package.name, ParserState#parser_state.package#package.implName,
        ParserState#parser_state.package#package.procedures, ApiScopesTransF),

    ?D("End~n ApiScopesTrans: ~p~n", [ApiScopesTransP]),
    ApiScopesTransP.
extract_api_scope_trans(_Type, _PackageName, _PackageImplName, [] = _Method, ApiScopesTrans) ->
    ?D("Start~n Type: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n ApiScopesTrans: ~p~n",
        [_Type, _PackageName, _PackageImplName, _Method, ApiScopesTrans]),
    ApiScopesTrans;
extract_api_scope_trans(function = Type, PackageName, PackageImplName, [Method | Tail], ApiScopesTrans) ->
    ?D("Start~n Type: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n ApiScopesTrans: ~p~n",
        [Type, PackageName, PackageImplName, Method, ApiScopesTrans]),

    ApiScopesTransNew = case Method#function.apiHidden of
                            "TRUE" -> ApiScopesTrans;
                            _ ->
                                MethodName = Method#function.name,
                                ApiScopeTransEntry = #api_scope_trans_entry{apiScope = get_api_scope("SBSDB_AC_", lists:append(
                                    [PackageName, ".", MethodName])), packageName = PackageName, packageImplName = PackageImplName, methodName = MethodName},
                                ?D("ApiScopeTransEntry: ~p~n", [ApiScopeTransEntry]),
                                ApiScopesTrans ++ [ApiScopeTransEntry]
                        end,

    ?D("End~n ApiScopesTrans: ~p~n", [ApiScopesTransNew]),
    extract_api_scope_trans(Type, PackageName, PackageImplName, Tail, ApiScopesTransNew);
extract_api_scope_trans(procedure = Type, PackageName, PackageImplName, [Method | Tail], ApiScopesTrans) ->
    ?D("Start~n Type: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n ApiScopesTrans: ~p~n",
        [Type, PackageName, PackageImplName, Method, ApiScopesTrans]),

    ApiScopesTransNew = case Method#procedure.apiHidden of
                            "TRUE" -> ApiScopesTrans;
                            _ ->
                                MethodName = Method#procedure.name,
                                ApiScopeTransEntry = #api_scope_trans_entry{apiScope = get_api_scope("SBSDB_AC_", lists:append(
                                    [PackageName, ".", MethodName])), packageName = PackageName, packageImplName = PackageImplName, methodName = MethodName},
                                ?D("ApiScopeTransEntry: ~p~n", [ApiScopeTransEntry]),
                                ApiScopesTrans ++ [ApiScopeTransEntry]
                        end,

    ?D("End~n ApiScopesTrans: ~p~n", [ApiScopesTransNew]),
    extract_api_scope_trans(Type, PackageName, PackageImplName, Tail, ApiScopesTransNew).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filter in or out parameters.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filter_parameter(InOut, Parameters) ->
    ?D("Start~n InOut: ~p~n Parameters: ~p~n", [InOut, Parameters]),
    filter_parameter(InOut, Parameters, []).

filter_parameter(_InOut, [] = _Parameter, Parameters) ->
    ?D("Start~n InOut: ~p~n Parameter: ~p~n Parameters: ~p~n", [_InOut, _Parameter, Parameters]),
    Parameters;
filter_parameter(in = InOut, [Parameter | Tail], Parameters)
    when Parameter#parameter.mode /= "IN", Parameter#parameter.mode /= "IN OUT", Parameter#parameter.mode /= "IN OUT NOCOPY" ->
    ?D("Start~n InOut: ~p~n Parameter: ~p~n Parameters: ~p~n", [InOut, Parameter, Parameters]),
    filter_parameter(InOut, Tail, Parameters);
filter_parameter(out = InOut, [Parameter | Tail], Parameters)
    when Parameter#parameter.mode == "IN" ->
    ?D("Start~n InOut: ~p~n Parameter: ~p~n Parameters: ~p~n", [InOut, Parameter, Parameters]),
    filter_parameter(InOut, Tail, Parameters);
filter_parameter(InOut, [Parameter | Tail], Parameters) ->
    ?D("Start~n InOut: ~p~n Parameter: ~p~n Parameters: ~p~n", [InOut, Parameter, Parameters]),
    filter_parameter(InOut, Tail, Parameters ++ [Parameter]).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Finalize the generation process.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

finalize(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    ok = Result = finalize_install_software(ParserState),

    ?D("End~n Result: ~p~n", [Result]),
    Result.

finalize_install_software(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    ok = generate_api_group_trans(ParserState),
    ok = generate_api_scope_help(ParserState),
    ok = generate_api_scope_trans(ParserState),

    % Set the io types in the file SBSDB_IO_LIB.pkb -----------------------------
    ok = set_io_type(),

    % Create the deployment files ----------------------------------------------
    ok = generate_deploy(),

    % Create the SBSDB schema installation scripts ------------------------------
    ok = generate_install_sbsdb_schema_privileges(ParserState),
    ok = generate_install_sbsdb_schema_software(),

    % Create the SBSDB unit test installation and uninstallation scripts --------
    ok = generate_install_sbsdb_ut_package(),
    ok = generate_uninstall_sbsdb_ut_package(),

    % Create the SBSDB unit test object privileges scripts for the code coverage
    ok = generate_install_sbsdb_ut_execute_cover("sbsdb_ut_execute_grant_cover.sql", grant,
        "   Grant the SBSDB unit testing object privileges for the code coverage."),
    ok = generate_install_sbsdb_ut_execute_cover("sbsdb_ut_execute_revoke_cover.sql", revoke,
        "   Revoke the SBSDB unit testing object privileges for the code coverage."),

    % Create the SBSDB unit test object privileges scripts for the unit tests ---
    ok = generate_install_sbsdb_ut_execute_test("sbsdb_ut_execute_grant_test.sql", [], grant,
        "   Grant the SBSDB unit testing object privileges for the unit tests."),
    ok = Result = generate_install_sbsdb_ut_execute_test("sbsdb_ut_execute_revoke_test.sql", [], revoke,
        "   Revoke the SBSDB unit testing object privileges for the unit tests."),

    ?I("================================================================================~n", []),

    ?D("End~n Result: ~p~n", [Result]),
    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate SBSDB files.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate() ->
    ?D("Start~n", []),

    ParserState = init(),
    PKSFiles = get_filenames(),
    ?D("PKSFiles: ~p~n", [PKSFiles]),
    ok = Result = process_file(ParserState, PKSFiles),

    ?D("End~n Result: ~p~n", [Result]),
    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate accessor method files from package implementation specification.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_accessor_method(_FunctionProcedure, _PackageName, _PackageImplName, [] = _Method) ->
    ?D("Start~n FunctionProcedure: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n", [_FunctionProcedure, _PackageName, _PackageImplName, _Method]),
    ok;
generate_accessor_method(function = FunctionProcedure, PackageName, PackageImplName, [Method | Tail])
    when Method#function.apiHidden == "TRUE" ->
    ?D("Start~n FunctionProcedure: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n", [FunctionProcedure, PackageName, PackageImplName, Method]),
    generate_accessor_method(FunctionProcedure, PackageName, PackageImplName, Tail);
generate_accessor_method(procedure = FunctionProcedure, PackageName, PackageImplName, [Method | Tail])
    when Method#procedure.apiHidden == "TRUE" ->
    ?D("Start~n FunctionProcedure: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n", [FunctionProcedure, PackageName, PackageImplName, Method]),
    generate_accessor_method(FunctionProcedure, PackageName, PackageImplName, Tail);
generate_accessor_method(FunctionProcedure, PackageName, PackageImplName, [Method | Tail]) ->
    ?D("Start~n FunctionProcedure: ~p~n PackageName: ~p~n PackageImplName: ~p~n Method: ~p~n", [FunctionProcedure, PackageName, PackageImplName, Method]),

    MethodName = case FunctionProcedure of
                     function -> Method#function.name;
                     procedure -> Method#procedure.name
                 end,
    ?D("MethodName: ~p~n", [MethodName]),

    MethodNameMD5 = get_api_scope("SBSDB_AC_", lists:append([
        PackageName,
        ".",
        MethodName
    ])),
    ?D("MethodNameMD5: ~p~n", [MethodNameMD5]),

    ?D("PATH_FUNCTIONS_GENERATED: ~p~n", [?PATH_FUNCTIONS_GENERATED]),
    filelib:ensure_dir(?PATH_FUNCTIONS_GENERATED),
    AccessorMethodFileName = MethodNameMD5 ++ ?FILE_SUFFIX_FUNCTIONS,
    ?D("AccessorMethodFileName: ~p~n", [AccessorMethodFileName]),

    % Generate code - open file ------------------------------------------------

    {ok, File, _} = file:path_open([?PATH_FUNCTIONS_GENERATED], AccessorMethodFileName, [write]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", [lists:append([
        "-- GENERATED CODE (based on ",
        atom_to_list(FunctionProcedure),
        " ",
        MethodName,
        " in package specification ",
        PackageImplName,
        ")"
    ])]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["CREATE OR REPLACE FUNCTION " ++ MethodNameMD5]),
    io:format(File, "~s~n", ["    RETURN VARCHAR2"]),
    io:format(File, "~s~n", ["IS"]),
    io:format(File, "~s~n", ["    /*"]),
    io:format(File, "~s~n", [lists:append([
        "       Implementation Method: ",
        PackageName,
        ".",
        MethodName
    ])]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["       This is a accessor function placeholder. It can be ignored by all users of the database."]),
    io:format(File, "~s~n", ["       SBSDB internal workflows may grant 'execute' to this object to a SBSDB user with the"]),
    io:format(File, "~s~n", [lists:append([
        "       effect that the user gets access to the method <SBSDB Schema.>",
        PackageName,
        ".",
        MethodName,
        "."
    ])]),
    io:format(File, "~s~n", ["    */"]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", [lists:append([
        "RETURN sbsdb_api_impl.scope ('",
        PackageName,
        "', '",
        MethodName,
        "');"
    ])]),
    io:format(File, "~s~n", [lists:append([
        "END ",
        MethodNameMD5,
        ";"
    ])]),
    io:format(File, "~s~n", ["/"]),

    % Generate code - close file -----------------------------------------------

    ok = _Result = file:close(File),

    ?I("Generated file - Accessor function: ~s~n", [AccessorMethodFileName]),

    ?D("End~n Result: ~p~n", [_Result]),

    generate_accessor_method(FunctionProcedure, PackageName, PackageImplName, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the API group translation table function.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_api_group_trans(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    ?D("PATH_FUNCTIONS_GENERATED: ~p~n", [?PATH_FUNCTIONS_GENERATED]),
    filelib:ensure_dir(?PATH_FUNCTIONS_GENERATED),
    FileName = ?FILE_NAME_SBSDB_API_GROUP_TRANS,
    ?D("FileName: ~p~n", [FileName]),

    % Generate code - open file ------------------------------------------------

    {ok, File, _} = file:path_open([?PATH_FUNCTIONS_GENERATED], FileName, [write]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE (based on the API group annotations in the implementation specification packages)"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["CREATE OR REPLACE FUNCTION sbsdb_api_group_trans"]),
    io:format(File, "~s~n", ["    RETURN sbsdb_api_group_trans_nt"]),
    io:format(File, "~s~n", ["IS"]),
    io:format(File, "~s~n", ["    l_sbsdb_api_group_trans_ntv     sbsdb_api_group_trans_nt := sbsdb_api_group_trans_nt ();"]),
    io:format(File, "~s~n", ["BEGIN"]),

    Total = length(ParserState#parser_state.apiGroupTransEntries),

    case Total of
        0 -> nop;
        _ ->
            io:format(File, "~s~n", [lists:append([
                "    l_sbsdb_api_group_trans_ntv.EXTEND (",
                integer_to_list(Total),
                ");"
            ])]),
            io:format(File, "~s~n", [""]),
            ok = generate_api_group_trans_entry(File, ParserState#parser_state.apiGroupTransEntries, 1),
            io:format(File, "~s~n", [""])
    end,

    io:format(File, "~s~n", ["    RETURN l_sbsdb_api_group_trans_ntv;"]),
    io:format(File, "~s~n", ["END sbsdb_api_group_trans;"]),
    io:format(File, "~s~n", ["/"]),

    % Generate code - close file -----------------------------------------------

    ok = file:close(File),

    Result = ?I("Generated file - API group translation table function: ~s~n", [FileName]),

    ?D("End~n Result: ~p~n", [Result]),

    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the API group translation entries.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_api_group_trans_entry(_File, [] = _ApiGroupTransEntry, _Counter) ->
    ?D("Start~n File: ~p~n ApiGroupTransEntry: ~p~n Counter: ~p~n", [_File, _ApiGroupTransEntry, _Counter]),
    ok;
generate_api_group_trans_entry(File, [ApiGroupTransEntry | Tail], Counter) ->
    ?D("Start~n File: ~p~n ApiGroupTransEntry: ~p~n Counter: ~p~n", [File, ApiGroupTransEntry, Counter]),
    io:format(File, "~s~n", [lists:append([
        "    l_sbsdb_api_group_trans_ntv (",
        integer_to_list(Counter),
        ") := sbsdb_api_group_trans_ot (api_group => '",
        case ApiGroupTransEntry#api_group_trans_entry.apiGroup of
            "not_assigned" -> [];
            _ -> string:uppercase(ApiGroupTransEntry#api_group_trans_entry.apiGroup)
        end,
        "', api_scope => '",
        ApiGroupTransEntry#api_group_trans_entry.apiScope,
        "', package_impl_name => '",
        string:uppercase(ApiGroupTransEntry#api_group_trans_entry.packageImplName),
        "', package_name => '",
        string:uppercase(ApiGroupTransEntry#api_group_trans_entry.packageName),
        "', method_name => '",
        string:uppercase(ApiGroupTransEntry#api_group_trans_entry.methodName),
        "');"
    ])]),
    generate_api_group_trans_entry(File, Tail, Counter + 1).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the API scope help table function.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_api_scope_help(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    ?D("PATH_FUNCTIONS_GENERATED: ~p~n", [?PATH_FUNCTIONS_GENERATED]),
    filelib:ensure_dir(?PATH_FUNCTIONS_GENERATED),
    FileName = ?FILE_NAME_SBSDB_API_SCOPE_HELP,
    ?D("FileName: ~p~n", [FileName]),

    % Generate code - open file ------------------------------------------------

    {ok, File, _} = file:path_open([?PATH_FUNCTIONS_GENERATED], FileName, [write]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE (based on the man pages in the implementation specification packages)"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["SET DEFINE OFF;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["CREATE OR REPLACE FUNCTION sbsdb_api_scope_help"]),
    io:format(File, "~s~n", ["    RETURN sbsdb_api_scope_help_nt"]),
    io:format(File, "~s~n", ["IS"]),
    io:format(File, "~s~n", ["    l_sbsdb_api_scope_help_ntv     sbsdb_api_scope_help_nt := sbsdb_api_scope_help_nt ();"]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", [lists:append([
        "    l_sbsdb_api_scope_help_ntv.EXTEND (",
        integer_to_list(length(ParserState#parser_state.apiScopeHelpEntries)),
        ");"
    ])]),
    io:format(File, "~s~n", [""]),

    ok = generate_api_scope_help_entry(File, ParserState#parser_state.apiScopeHelpEntries, 1),

    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["    RETURN l_sbsdb_api_scope_help_ntv;"]),
    io:format(File, "~s~n", ["END sbsdb_api_scope_help;"]),
    io:format(File, "~s~n", ["/"]),

    % Generate code - close file -----------------------------------------------

    ok = file:close(File),

    Result = ?I("Generated file - API scope help table function: ~s~n", [FileName]),

    ?D("End~n Result: ~p~n", [Result]),

    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the API scope help entries.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_api_scope_help_entry(_File, [] = _ApiScopeHelpEntry, _Counter) ->
    ?D("Start~n File: ~p~n ApiScopeHelpEntry: ~p~n Counter: ~p~n", [_File, _ApiScopeHelpEntry, _Counter]),
    ok;
generate_api_scope_help_entry(File, [ApiScopeHelpEntry | Tail], Counter) ->
    ?D("Start~n File: ~p~n ApiScopeHelpEntry: ~p~n Counter: ~p~n", [File, ApiScopeHelpEntry, Counter]),
    HelpText = ApiScopeHelpEntry#api_scope_help_entry.apiHelpText,
    HelpTextStrippedLeading = string:replace(HelpText, "/*<>", "", leading),
    HelpTextStrippedTrailing = string:replace(HelpTextStrippedLeading, "*/", "", trailing),
    HelpTextSingleQuote = string:replace(HelpTextStrippedTrailing, "'", "''", all),
    {Package, Method} =
        {string:uppercase(ApiScopeHelpEntry#api_scope_help_entry.packageName), string:uppercase(ApiScopeHelpEntry#api_scope_help_entry.methodName)},
    io:format(File, "~s~n", [lists:append([
        "    l_sbsdb_api_scope_help_ntv (",
        integer_to_list(Counter),
        ") := sbsdb_api_scope_help_ot (api_scope => '",
        case {Package, Method} of
            {_, []} -> Package;
            {[], _} -> "." ++ Method;
            {"SBSDB_STANDALONE_SPEC", _} -> "." ++ Method;
            _ -> lists:append([
                Package,
                ".",
                Method
            ])
        end,
        "', api_help_text => '",
        string:slice(HelpTextSingleQuote, 0, 4000),
        "');"
    ])]),
    generate_api_scope_help_entry(File, Tail, Counter + 1).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the API scope translation table function.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_api_scope_trans(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    ?D("PATH_FUNCTIONS_GENERATED: ~p~n", [?PATH_FUNCTIONS_GENERATED]),
    filelib:ensure_dir(?PATH_FUNCTIONS_GENERATED),
    FileName = ?FILE_NAME_SBSDB_API_SCOPE_TRANS,
    ?D("FileName: ~p~n", [FileName]),

    % Generate code - open file ------------------------------------------------

    {ok, File, _} = file:path_open([?PATH_FUNCTIONS_GENERATED], FileName, [write]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE (based on the functions and procedures in the implementation specification packages)"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["CREATE OR REPLACE FUNCTION sbsdb_api_scope_trans"]),
    io:format(File, "~s~n", ["    RETURN sbsdb_api_scope_trans_nt"]),
    io:format(File, "~s~n", ["IS"]),
    io:format(File, "~s~n", ["    l_sbsdb_api_scope_trans_ntv     sbsdb_api_scope_trans_nt := sbsdb_api_scope_trans_nt ();"]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", [lists:append([
        "    l_sbsdb_api_scope_trans_ntv.EXTEND (",
        integer_to_list(length(ParserState#parser_state.apiScopeTransEntries)),
        ");"
    ])]),
    io:format(File, "~s~n", [""]),

    ok = generate_api_scope_trans_entry(File, ParserState#parser_state.apiScopeTransEntries, 1),

    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["    RETURN l_sbsdb_api_scope_trans_ntv;"]),
    io:format(File, "~s~n", ["END sbsdb_api_scope_trans;"]),
    io:format(File, "~s~n", ["/"]),

    % Generate code - close file -----------------------------------------------

    ok = file:close(File),

    Result = ?I("Generated file - API scope translation table function: ~s~n", [FileName]),

    ?D("End~n Result: ~p~n", [Result]),

    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the API scope translation entries.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_api_scope_trans_entry(_File, [] = _ApiScopeTransEntry, _Counter) ->
    ?D("Start~n File: ~p~n ApiScopeTransEntry: ~p~n Counter: ~p~n", [_File, _ApiScopeTransEntry, _Counter]),
    ok;
generate_api_scope_trans_entry(File, [ApiScopeTransEntry | Tail], Counter) ->
    ?D("Start~n File: ~p~n ApiScopeTransEntry: ~p~n Counter: ~p~n", [File, ApiScopeTransEntry, Counter]),
    io:format(File, "~s~n", [lists:append([
        "    l_sbsdb_api_scope_trans_ntv (",
        integer_to_list(Counter),
        ") := sbsdb_api_scope_trans_ot (api_scope => '",
        ApiScopeTransEntry#api_scope_trans_entry.apiScope,
        "', package_impl_name => '",
        string:uppercase(ApiScopeTransEntry#api_scope_trans_entry.packageImplName),
        "', package_name => '",
        string:uppercase(ApiScopeTransEntry#api_scope_trans_entry.packageName),
        "', method_name => '",
        string:uppercase(ApiScopeTransEntry#api_scope_trans_entry.methodName),
        "');"
    ])]),
    generate_api_scope_trans_entry(File, Tail, Counter + 1).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the deployment directory.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_deploy() ->
    ?D("Start~n", []),

    {ok, Cwd} = file:get_cwd(),
    ?D("Cwd: ~p~n", [Cwd]),
    RootPath = lists:reverse(filename:split(Cwd)),
    ?D("RootPath: ~p~n", [RootPath]),

    ok = case file:list_dir(?DEPLOY_DIRECTORY) of
             {error, enoent} -> file:make_dir(?DEPLOY_DIRECTORY);
             {ok, Files} -> lists:foreach(fun(File) -> file:delete(?DEPLOY_DIRECTORY ++ File)
                                          end, Files)
         end,

    %% -------------------------------------------------------------------------
    %% Install.
    %% -------------------------------------------------------------------------

    InstallResult = filelib:wildcard("*", filename:join(lists:reverse(["deploy", "install"] ++ RootPath))),
    ok = generate_deploy_original(?PATH_INSTALL_DEPLOY, ?DEPLOY_DIRECTORY, InstallResult),

    InstallTestResult = filelib:wildcard("*", filename:join(lists:reverse(["deploy", "install", "test"] ++ RootPath))),
    ok = generate_deploy_original(?PATH_INSTALL_DEPLOY_TEST, ?DEPLOY_DIRECTORY_TEST, InstallTestResult),

    %% -------------------------------------------------------------------------
    %% Contexts.
    %% -------------------------------------------------------------------------

    ContextsResult = filelib:wildcard(?WCARD_CONTEXT, filename:join(lists:reverse(["context", "src"] ++ RootPath))),
    Result = generate_deploy_original(?PATH_CONTEXT, ?DEPLOY_DIRECTORY, ContextsResult),

    ?D("End~n Result: ~p~n", [Result]),
    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copy files to the deployment directory.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_deploy_original(_SourceDirectory, _TargetDirectory, [] = _File) ->
    ?D("Start~n SourceDirectory: ~p~n TargetDirectory: ~p~n File: ~p~n", [_SourceDirectory, _TargetDirectory, _File]),
    ok;
generate_deploy_original(SourceDirectory, TargetDirectory, [File | Tail]) ->
    ?D("Start~n SourceDirectory: ~p~n TargetDirectory: ~p~n File: ~p~n", [SourceDirectory, TargetDirectory, File]),
    FileNameSource = SourceDirectory ++ File,
    ?D("FileNameSource: ~p~n", [FileNameSource]),
    FileNameTarget = TargetDirectory ++ File,
    ?D("FileNameTarget: ~p~n", [FileNameTarget]),
    {ok, _BytesCopied} = file:copy(FileNameSource, FileNameTarget),
    ?D("BytesCopied: ~p~n", [_BytesCopied]),
    generate_deploy_original(SourceDirectory, TargetDirectory, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate files package based.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_file_package_based(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    Package = ParserState#parser_state.package,

    PackageName = Package#package.name,
    ?D("PackageName: ~p~n", [PackageName]),

    PackageNameImpl = Package#package.implName,
    ?D("PackageNameImpl: ~p~n", [PackageNameImpl]),

    IsPackageTypeImpl = case string:slice(PackageNameImpl, length(PackageNameImpl) - 5) of
                            "_impl" ->
                                ok = generate_accessor_method(function, Package#package.name, Package#package.implName,
                                    lists:sort(Package#package.functions)),
                                ok =
                                    generate_accessor_method(procedure, Package#package.name, Package#package.implName,
                                        lists:sort(Package#package.procedures)),
                                ok = generate_package_spec(Package),
                                ok = generate_package_body(Package),
                                true;
                            _ -> false
                        end,

    IsPackageTypeConLib = case string:slice(PackageName, length(PackageName) - 4) of
                              "_con" -> true;
                              "_lib" -> true;
                              _ -> false
                          end,

    ParserStateNew = if
                         (?HELP_VARIANT == developer) orelse
                             (?HELP_VARIANT == k2 andalso IsPackageTypeImpl == true) orelse
                             (?HELP_VARIANT == swisscom andalso IsPackageTypeConLib == false) ->
                             ParserState#parser_state{
                                 apiGroupTransEntries = extract_api_group_trans(ParserState),
                                 apiScopeHelpEntries = extract_api_scope_help(ParserState),
                                 apiScopeTransEntries = extract_api_scope_trans(ParserState)
                             };
                         true -> ParserState
                     end,

    ?D("End~n ParserStateNew: ~p~n", [ParserStateNew]),
    ParserStateNew.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate return value definition in function specification
%% [conditional compilation].
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_function_return_definition_version(_File, _Processed, [] = _Version) ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [_File, _Processed, _Version]),
    ok;
generate_function_return_definition_version(File, Processed, [Version | Tail]) ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [File, Processed, Version]),

    {ConditionType, ConditionValue} = _Condition = Version#version.condition,
    ?D("Condition: ~p~n", [_Condition]),

    ReturnDataType = Version#version.returnDataType,
    ?D("ReturnDataType: ~p~n", [ReturnDataType]),

    case ConditionType of
        ifend ->
            case Processed of
                0 -> io:format(File, "~s~n", ["    $IF " ++ ConditionValue]);
                _ -> io:format(File, "~s~n", ["    $ELSIF " ++ ConditionValue])
            end,
            io:format(File, "~s~n", ["    $THEN"]);
        _ -> nop
    end,

    io:format(File, "~s~n", [lists:append([
        "        RETURN ",
        ReturnDataType,
        case Version#version.pipelined of
            [] -> [];
            _ -> " PIPELINED"
        end
    ])]),

    case ConditionType == ifend andalso Tail == [] of
        true -> io:format(File, "~s~n", ["    $END"]);
        _ -> nop
    end,

    generate_function_return_definition_version(File, Processed + 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate local return value definition in function
%% [conditional compilation].
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_function_return_local_version(_File, _Processed, [] = _Version) ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [_File, _Processed, _Version]),
    ok;
generate_function_return_local_version(File, Processed, [Version | Tail]) ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [File, Processed, Version]),

    {ConditionType, ConditionValue} = _Condition = Version#version.condition,
    ?D("Condition: ~p~n", [_Condition]),

    ReturnDataType = Version#version.returnDataType,
    ?D("ReturnDataType: ~p~n", [ReturnDataType]),

    case ConditionType of
        ifend ->
            case Processed of
                0 -> io:format(File, "~s~n", ["    $IF " ++ ConditionValue]);
                _ -> io:format(File, "~s~n", ["    $ELSIF " ++ ConditionValue])
            end,
            io:format(File, "~s~n", ["    $THEN"]);
        _ -> nop
    end,

    case Version#version.pipelined of
        [] ->
            io:format(File, "~s~n", [lists:append([
                "        l_return_value ",
                ReturnDataType,
                ";"
            ])]);
        _ ->
            io:format(File, "~s~n", [lists:append([
                "        l_coll sbsdb_type_lib.",
                string:replace(ReturnDataType, "_nt", "_ct", trailing),
                ";"
            ])])
    end,

    case ConditionType == ifend andalso Tail == [] of
        true -> io:format(File, "~s~n", ["    $END"]);
        _ -> nop
    end,

    generate_function_return_local_version(File, Processed + 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB schema installation script - compile the software.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_schema_compile(_File, _FunctionPackageProcedure, _Prefix, [] = _Object) ->
    ?D("Start~n File: ~p~n _FunctionPackageProcedure: ~p~n Prefix: ~p~n Object: ~p~n", [_File, _FunctionPackageProcedure, _Prefix, _Object]),
    ok;
generate_install_sbsdb_schema_compile(File, FunctionPackageProcedure, Prefix, [Object | Tail])
    when Object == "sbsdb_api_lib.pks";Object == "sbsdb_type_lib.pks" ->
    ?D("Start~n File: ~p~n _FunctionPackageProcedure: ~p~n Prefix: ~p~n Object: ~p~n", [File, FunctionPackageProcedure, Prefix, Object]),
    generate_install_sbsdb_schema_compile(File, FunctionPackageProcedure, Prefix, Tail);
generate_install_sbsdb_schema_compile(File, FunctionPackageProcedure, Prefix, [Object | Tail]) ->
    ?D("Start~n File: ~p~n _FunctionPackageProcedure: ~p~n Prefix: ~p~n Object: ~p~n", [File, FunctionPackageProcedure, Prefix, Object]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('Compilation of ",
        atom_to_list(FunctionPackageProcedure),
        " file ",
        Prefix,
        Object,
        "');"])]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [lists:append([
        "@",
        Prefix,
        Object
    ])]),
    io:format(File, "~s~n", [""]),
    generate_install_sbsdb_schema_compile(File, FunctionPackageProcedure, Prefix, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB schema installation script - grants for SBSDB.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_schema_grant(_File, _Grantee, [] = _Privilege) ->
    ?D("Start~n File: ~p~n Grantee: ~p~n Privilege: ~p~n", [_File, _Grantee, _Privilege]),
    ok;
generate_install_sbsdb_schema_grant(File, Grantee, [{privilege, [], Type} = _Privilege | Tail]) ->
    ?D("Start~n File: ~p~n Grantee: ~p~n Privilege: ~p~n", [File, Grantee, _Privilege]),
    io:format(File, "~s~n", [lists:append([
        "    l_sql_stmnt := 'GRANT ",
        Type,
        " TO ' || :user_username;"
    ])]),
    io:format(File, "~s~n", ["    EXECUTE IMMEDIATE l_sql_stmnt;"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);"]),
    generate_install_sbsdb_schema_grant(File, Grantee, Tail);
generate_install_sbsdb_schema_grant(File, Grantee, [{privilege, Object, Type} = _Privilege | Tail]) ->
    ?D("Start~n File: ~p~n Grantee: ~p~n Privilege: ~p~n", [File, Grantee, _Privilege]),
    io:format(File, "~s~n", [lists:append([
        "    l_sql_stmnt := 'GRANT ",
        Type,
        " ON ",
        Object,
        " TO ' || :user_username;"
    ])]),
    io:format(File, "~s~n", ["    EXECUTE IMMEDIATE l_sql_stmnt;"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);"]),
    generate_install_sbsdb_schema_grant(File, Grantee, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate method params in package method.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_method_params(_File, _Reminder, [] = _Parameter) ->
    ?D("Start~n File: ~p~n Reminder: ~p~n Parameter: ~p~n", [_File, _Reminder, _Parameter]),
    ok;
generate_method_params(File, Reminder, [Parameter | Tail]) ->
    ?D("Start~n File: ~p~n Reminder: ~p~n Parameter: ~p~n", [File, Reminder, Parameter]),

    DataType = Parameter#parameter.dataType,
    ?D("DataType: ~p~n", [DataType]),

    {DefaultType, DefaultValue} = _Default = Parameter#parameter.defaultValue,
    ?D("Default: ~p~n", [_Default]),

    Mode = Parameter#parameter.mode,
    ?D("Mode: ~p~n", [Mode]),

    Name = Parameter#parameter.name,
    ?D("Name: ~p~n", [Name]),

    io:format(File, "~s", [lists:append([
        "    ",
        Name,
        " ",
        case Mode of
            "InOut" -> "IN OUT";
            _ -> string:uppercase(Mode)
        end,
        " ",
        DataType,
        case DefaultType of
            none -> [];
            string -> lists:append([
                " := '",
                DefaultValue,
                "'"
            ]);
            _ -> " := " ++ DefaultValue
        end
    ])]),

    case Reminder of
        1 -> io:format(File, "~n", []);
        _ -> io:format(File, "~s~n", [","])
    end,

    generate_method_params(File, Reminder - 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate call method params in package method.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_method_params_call(_File, _Reminder, [] = _Parameter) ->
    ?D("Start~n File: ~p~n Reminder: ~p~n Parameter: ~p~n", [_File, _Reminder, _Parameter]),
    ok;
generate_method_params_call(File, Reminder, [Parameter | Tail]) ->
    ?D("Start~n File: ~p~n Reminder: ~p~n Parameter: ~p~n", [File, Reminder, Parameter]),

    Name = Parameter#parameter.name,
    ?D("Name: ~p~n", [Name]),

    io:format(File, "~s", ["    " ++ Name]),

    case Reminder of
        1 -> io:format(File, "~n", []);
        _ -> io:format(File, "~s~n", [","])
    end,

    generate_method_params_call(File, Reminder - 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate logger entries for method params in package method.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_method_params_logger(_File, _InOut, _FunctionProcedure, [] = _Parameter) ->
    ?D("Start~n File: ~p~n InOut: ~p~n FunctionProcedure: ~p~n Parameter: ~p~n", [_File, _InOut, _FunctionProcedure, _Parameter]),
    ok;
generate_method_params_logger(File, InOut, FunctionProcedure, [Parameter | Tail]) ->
    ?D("Start~n File: ~p~n InOut: ~p~n FunctionProcedure: ~p~n Parameter: ~p~n", [File, InOut, FunctionProcedure, Parameter]),

    Name = Parameter#parameter.name,
    ?D("Name: ~p~n", [Name]),

    io:format(File, "~s~n", [lists:append([
        "            sbsdb_logger_lib.log_param ('",
        Name,
        "', ",
        Name,
        ")",
        case (InOut == in orelse InOut == out andalso FunctionProcedure == procedure) andalso Tail == [] of
            true -> [];
            _ -> ","
        end
    ])]),

    generate_method_params_logger(File, InOut, FunctionProcedure, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate logger start for method params in package method
%% [conditional compilation].
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_method_params_logger_versions(File, Type, FunctionProcedure, MethodName, Processed, [] = _Version) ->
    ?D("Start~n File: ~p~n Type: ~p~n FunctionProcedure: ~p~n MethodName: ~p~n Processed: ~p~n Version: ~p~n",
        [File, Type, FunctionProcedure, MethodName, Processed, _Version]),
    case Processed of
        0 ->
            case Type of
                'end' -> io:format(File, "~s~n", [lists:append([
                    "        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, '",
                    MethodName,
                    "')",
                    case FunctionProcedure of
                        function -> ",";
                        _ -> []
                    end
                ])]);
                error -> io:format(File, "~s", [lists:append([
                    "                sbsdb_error_lib.LOG (SQLCODE, SQLERRM, sbsdb_logger_lib.scope ($$plsql_unit, '",
                    MethodName,
                    "')"
                ])]);
                start -> io:format(File, "~s", [lists:append([
                    "        sbsdb_logger_lib.log_info ('Start', sbsdb_logger_lib.scope ($$plsql_unit, '",
                    MethodName,
                    "')"
                ])])
            end,

            case Type of
                'end' -> case FunctionProcedure of
                             function ->
                                 io:format(File, "~s~n", ["            sbsdb_logger_lib.log_param ('"]),
                                 io:format(File, "~s~n", ["                                   'return_value', l_return_value"]),
                                 io:format(File, "~s~n", ["                                  ));"]);
                             _ -> io:format(File, "~s~n", [");"])
                         end;
                _ -> io:format(File, "~s~n", [");"])
            end;
        _ -> nop
    end,
    ok;
generate_method_params_logger_versions(File, Type, FunctionProcedure, MethodName, Processed, [Version | Tail]) ->
    ?D("Start~n File: ~p~n Type: ~p~n FunctionProcedure: ~p~n MethodName: ~p~n Processed: ~p~n Version: ~p~n",
        [File, Type, FunctionProcedure, MethodName, Processed, Version]),

    {ConditionType, ConditionValue} = _Condition = Version#version.condition,
    ?D("Condition: ~p~n", [_Condition]),

    Parameters = Version#version.parameters,
    ?D("Parameters: ~p~n", [Parameters]),

    case ConditionType of
        ifend ->
            case Processed of
                0 -> io:format(File, "~s~n", ["    $IF " ++ ConditionValue]);
                _ -> io:format(File, "~s~n", ["    $ELSIF " ++ ConditionValue])
            end,
            io:format(File, "~s~n", ["    $THEN"]);
        _ -> nop
    end,

    Params = filter_parameter(case Type of
                                  'end' -> out;
                                  _ -> in
                              end, Parameters),
    ?D("Params: ~p~n", [Params]),

    case Type of
        'end' -> io:format(File, "~s~n", [lists:append([
            "        sbsdb_logger_lib.log_info ('End', sbsdb_logger_lib.scope ($$plsql_unit, '",
            MethodName,
            "')",
            case FunctionProcedure == procedure andalso Params == [] of
                true -> [];
                _ -> ","
            end
        ])]);
        error -> io:format(File, "~s", [lists:append([
            "                sbsdb_error_lib.LOG (SQLCODE, SQLERRM, sbsdb_logger_lib.scope ($$plsql_unit, '",
            MethodName,
            "')",
            case Params of
                [] -> [];
                _ -> ","
            end
        ])]);
        start -> io:format(File, "~s", [lists:append([
            "        sbsdb_logger_lib.log_info ('Start', sbsdb_logger_lib.scope ($$plsql_unit, '",
            MethodName,
            "')",
            case Params of
                [] -> [];
                _ -> ","
            end
        ])])
    end,

    case Type of
        'end' -> case FunctionProcedure of
                     function ->
                         case Params of
                             [] -> nop;
                             _ ->
                                 ok = generate_method_params_logger(File, out, FunctionProcedure, Params)
                         end,
                         io:format(File, "~s~n", ["            sbsdb_logger_lib.log_param ('return_value', l_return_value)"]),
                         io:format(File, "~s~n", ["                                  );"]);
                     _ -> case Params of
                              [] ->
                                  io:format(File, "~s~n", [");"]);
                              _ ->
                                  ok = generate_method_params_logger(File, out, FunctionProcedure, Params),
                                  io:format(File, "~s~n", ["                                  );"])
                          end
                 end;
        _ -> case Params of
                 [] ->
                     io:format(File, "~s~n", [");"]);
                 _ ->
                     ok = generate_method_params_logger(File, in, FunctionProcedure, Params),
                     io:format(File, "~s~n", ["                                  );"])
             end
    end,

    case ConditionType == ifend andalso Tail == [] of
        true -> io:format(File, "~s~n", ["    $END"]);
        _ -> nop
    end,

    generate_method_params_logger_versions(File, Type, FunctionProcedure, MethodName, Processed + 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB schema installation script - privileges.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_schema_privileges(ParserState) ->
    ?D("Start~n ParserState: ~p~n", [ParserState]),

    FileName = "sbsdb_schema_update_privileges.sql",
    ?D("FileName: ~p~n", [FileName]),
    {ok, File, _} = file:path_open([?PATH_INSTALL_GENERATED], FileName, [write]),

    %% -------------------------------------------------------------------------
    %% Start script
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["/*"]),
    io:format(File, "~s~n", ["   Create or update the SBSDB schema - privileges."]),
    io:format(File, "~s~n", ["*/"]),
    io:format(File, "~s~n", [""]),

    io:format(File, "~s~n", ["SET ECHO         OFF"]),
    io:format(File, "~s~n", ["SET FEEDBACK     OFF"]),
    io:format(File, "~s~n", ["SET HEADING      OFF"]),
    io:format(File, "~s~n", ["SET LINESIZE     200"]),
    io:format(File, "~s~n", ["SET PAGESIZE     0"]),
    io:format(File, "~s~n", ["SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED"]),
    io:format(File, "~s~n", ["SET TAB          OFF"]),
    io:format(File, "~s~n", ["SET VERIFY       OFF"]),
    io:format(File, "~s~n", ["WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Current user is now: ' || USER);"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('Start ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["VARIABLE user_username        VARCHAR2 ( 128 )"]),
    io:format(File, "~s~n", ["EXECUTE :user_username        := UPPER('&1');"]),
    io:format(File, "~s~n", ["VARIABLE connect_identifier   VARCHAR2 ( 128 )"]),
    io:format(File, "~s~n", ["EXECUTE :connect_identifier   := UPPER('&3');"]),
    io:format(File, "~s~n", ["VARIABLE var_username         VARCHAR2 ( 128 )"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Create or update the SBSDB schema.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["DECLARE"]),
    io:format(File, "~s~n", ["    TYPE l_object_names_nt IS TABLE OF VARCHAR2 (128);"]),
    io:format(File, "~s~n", ["    TYPE l_privileges_nt IS TABLE OF VARCHAR2 (40);"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["    l_object_name                  VARCHAR2 (128);"]),
    io:format(File, "~s~n", ["    l_object_names_ntv             l_object_names_nt;"]),
    io:format(File, "~s~n", ["    l_privileges_ntv               l_privileges_nt;"]),
    io:format(File, "~s~n", ["    l_sql_stmnt                    VARCHAR2 (4000);"]),
    io:format(File, "~s~n", ["BEGIN"]),

    %% -------------------------------------------------------------------------
    %% GRANT the privileges to the SBSDB schema.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('GRANT privileges required by SBSDB ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", [""]),

    ok = generate_install_sbsdb_schema_grant(File, ":user_username", lists:append([
        ParserState#parser_state.privileges,
        [#privilege{type = "CONNECT"}],
        [#privilege{type = "CREATE PROCEDURE"}],
        [#privilege{type = "CREATE SEQUENCE"}],
        [#privilege{type = "CREATE SESSION"}],
        [#privilege{type = "CREATE TABLE"}],
        [#privilege{type = "CREATE TYPE"}],
        [#privilege{type = "CREATE USER"}],
        [#privilege{type = "UNLIMITED TABLESPACE"}],
        [#privilege{type = "SELECT", object = "sys.dba_objects"}],
        [#privilege{type = "SELECT", object = "sys.v_$parameter"}]
    ])),
    io:format(File, "~s~n", [""]),

    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% End   script.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('End   ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),

    ?I("Generated file - Installation script: ~s~n", [FileName]),

    ok.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB schema installation script - software.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_schema_software() ->
    ?D("Start~n ParserState: ~p~n", []),

    FileName = "sbsdb_schema_update_software.sql",
    ?D("FileName: ~p~n", [FileName]),
    {ok, File, _} = file:path_open([?PATH_INSTALL_GENERATED], FileName, [write]),

    {ok, Cwd} = file:get_cwd(),
    ?D("Cwd: ~p~n", [Cwd]),
    RootPath = lists:reverse(filename:split(Cwd)),
    ?D("RootPath: ~p~n", [RootPath]),

    %% -------------------------------------------------------------------------
    %% Start script
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["/*"]),
    io:format(File, "~s~n", ["   Create or update the SBSDB schema."]),
    io:format(File, "~s~n", ["*/"]),
    io:format(File, "~s~n", [""]),

    io:format(File, "~s~n", ["SET ECHO         OFF"]),
    io:format(File, "~s~n", ["SET FEEDBACK     OFF"]),
    io:format(File, "~s~n", ["SET HEADING      OFF"]),
    io:format(File, "~s~n", ["SET LINESIZE     200"]),
    io:format(File, "~s~n", ["SET PAGESIZE     0"]),
    io:format(File, "~s~n", ["SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED"]),
    io:format(File, "~s~n", ["SET TAB          OFF"]),
    io:format(File, "~s~n", ["SET VERIFY       OFF"]),
    io:format(File, "~s~n", ["WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Current user is now: ' || USER);"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('Start ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["VARIABLE user_username        VARCHAR2 ( 128 )"]),
    io:format(File, "~s~n", ["EXECUTE :user_username        := UPPER('&1');"]),
    io:format(File, "~s~n", ["VARIABLE connect_identifier   VARCHAR2 ( 128 )"]),
    io:format(File, "~s~n", ["EXECUTE :connect_identifier   := UPPER('&3');"]),
    io:format(File, "~s~n", ["VARIABLE var_username         VARCHAR2 ( 128 )"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Install the software : Switching database user.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Switching database user ...');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["CONNECT &1/&2@&3;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["SET ECHO         OFF"]),
    io:format(File, "~s~n", ["SET FEEDBACK     OFF"]),
    io:format(File, "~s~n", ["SET HEADING      OFF"]),
    io:format(File, "~s~n", ["SET LINESIZE     200"]),
    io:format(File, "~s~n", ["SET PAGESIZE     0"]),
    io:format(File, "~s~n", ["SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED"]),
    io:format(File, "~s~n", ["SET TAB          OFF"]),
    io:format(File, "~s~n", ["SET VERIFY       OFF"]),
    io:format(File, "~s~n", ["WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Current user is now: ' || USER);"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Install the software : logger sequence.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["DECLARE"]),
    io:format(File, "~s~n", ["    l_object_name                  VARCHAR2 (128);"]),
    io:format(File, "~s~n", ["    l_sql_stmnt                    VARCHAR2 (4000);"]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Installing Logger Sequence ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["    SELECT OBJECT_NAME"]),
    io:format(File, "~s~n", ["      INTO l_object_name"]),
    io:format(File, "~s~n", ["      FROM SYS.ALL_OBJECTS"]),
    io:format(File, "~s~n", ["     WHERE OBJECT_TYPE = 'SEQUENCE'"]),
    io:format(File, "~s~n", ["       AND OBJECT_NAME = 'SBSDB_LOG_SEQ'"]),
    io:format(File, "~s~n", ["       AND OWNER = UPPER(:user_username);"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Database sequence SBSDB_LOG_SEQ is already existing !!!');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["EXCEPTION"]),
    io:format(File, "~s~n", ["    WHEN NO_DATA_FOUND"]),
    io:format(File, "~s~n", ["    THEN"]),
    io:format(File, "~s~n", [lists:append([
        "        l_sql_stmnt := 'CREATE SEQUENCE sbsdb_log_seq ",
        "MINVALUE 1 ",
        "MAXVALUE 999999999999999999999999999 ",
        "START WITH 1 ",
        "INCREMENT BY 1 "
        "CACHE 20';"
    ])]),
    io:format(File, "~s~n", ["        EXECUTE IMMEDIATE l_sql_stmnt;"]),
    io:format(File, "~s~n", ["        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);"]),
    io:format(File, "~s~n", ["        DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Install the software : Create the SBSDB log table.
    %% -------------------------------------------------------------------------

    case ?IO_TYPE_LOG of
        table ->
            io:format(File, "~s~n", ["DECLARE"]),
            io:format(File, "~s~n", ["    l_object_name                  VARCHAR2 (128);"]),
            io:format(File, "~s~n", ["    l_sql_stmnt                    VARCHAR2 (4000);"]),
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Installing SBSDB Log Table ...');"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["    SELECT OBJECT_NAME"]),
            io:format(File, "~s~n", ["      INTO l_object_name"]),
            io:format(File, "~s~n", ["      FROM SYS.ALL_OBJECTS"]),
            io:format(File, "~s~n", ["     WHERE OBJECT_TYPE = 'TABLE'"]),
            io:format(File, "~s~n", ["       AND OBJECT_NAME = 'SBSDB_LOG'"]),
            io:format(File, "~s~n", ["       AND OWNER = UPPER(:user_username);"]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Database table SBSDB_LOG is already existing !!!');"]),
            io:format(File, "~s~n", ["EXCEPTION"]),
            io:format(File, "~s~n", ["    WHEN NO_DATA_FOUND"]),
            io:format(File, "~s~n", ["    THEN"]),
            io:format(File, "~s~n", [lists:append([
                "        l_sql_stmnt := '\nCREATE TABLE sbsdb_log (\n",
                "    ckey              NUMBER          NOT NULL,\n"
                "    cvalue            CLOB            NOT NULL,\n"
                "    chash             VARCHAR2 (20),\n"
                "    logger_level      NUMBER,\n"
                "    scope             VARCHAR2 (1000),\n"
                "    time_stamp        TIMESTAMP (6),\n"
                "    CONSTRAINT sbsdb_log_pk PRIMARY KEY (ckey) ENABLE"
                ")';"
            ])]),
            io:format(File, "~s~n", ["        EXECUTE IMMEDIATE l_sql_stmnt;"]),
            io:format(File, "~s~n", ["        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);"]),
            io:format(File, "~s~n", [lists:append(["        l_sql_stmnt := 'CREATE BITMAP INDEX idx_sdbsdb_log_01 ON sbsdb_log (logger_level)';"])]),
            io:format(File, "~s~n", ["        EXECUTE IMMEDIATE l_sql_stmnt;"]),
            io:format(File, "~s~n", ["        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);"]),
            io:format(File, "~s~n", [lists:append(["        l_sql_stmnt := 'CREATE INDEX idx_sdbsdb_log_02 ON sbsdb_log (scope)';"])]),
            io:format(File, "~s~n", ["        EXECUTE IMMEDIATE l_sql_stmnt;"]),
            io:format(File, "~s~n", ["        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);"]),
            io:format(File, "~s~n", [lists:append(["        l_sql_stmnt := 'CREATE INDEX idx_sdbsdb_log_03 ON sbsdb_log (time_stamp)';"])]),
            io:format(File, "~s~n", ["        EXECUTE IMMEDIATE l_sql_stmnt;"]),
            io:format(File, "~s~n", ["        DBMS_OUTPUT.put_line ('Executed: ' || l_sql_stmnt);"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]),
            io:format(File, "~s~n", [""])
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : Prerequisites.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile prerequisites ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compilation of types file src/types/sbsdb.tps');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", ["@src/types/sbsdb.tps"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_type_lib.pks');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", ["@src/packages/sbsdb_type_lib.pks"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compilation of package file src/packages/sbsdb_api_lib.pks');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", ["@src/packages/sbsdb_api_lib.pks"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Install the software : views - handy versions.
    %% -------------------------------------------------------------------------

    ViewsHandyDir = filename:join(lists:reverse(["views", "src"] ++ RootPath)),
    ViewsHandyResult = lists:sort(filelib:wildcard(?WCARD_VIEWS, ViewsHandyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile views - handy versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(ViewsHandyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no views in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, view, "src/views/", ViewsHandyResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : synonyms - handy versions.
    %% -------------------------------------------------------------------------

    SynonymsHandyDir = filename:join(lists:reverse(["synonyms", "src"] ++ RootPath)),
    SynonymsHandyResult = lists:sort(filelib:wildcard(?WCARD_SYNONYMS, SynonymsHandyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile synonyms - handy versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(SynonymsHandyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no synonyms in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, synonym, "src/synonyms/", SynonymsHandyResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : functions - generated versions.
    %% -------------------------------------------------------------------------

    FunctionsGeneratedDir = filename:join(lists:reverse(["generated", "functions", "src"] ++ RootPath)),
    FunctionsGeneratedResult = lists:sort(filelib:wildcard(?WCARD_FUNCTIONS, FunctionsGeneratedDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile functions - generated versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(FunctionsGeneratedResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no functions in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, function, "src/functions/generated/", FunctionsGeneratedResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : package specifications - handy versions.
    %% -------------------------------------------------------------------------

    PackagesSpecHandyDir = filename:join(lists:reverse(["packages", "src"] ++ RootPath)),
    PackagesSpecHandyResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_SPEC, PackagesSpecHandyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile package specifications - handy versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesSpecHandyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package specifications in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, package, "src/packages/", PackagesSpecHandyResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : package specifications - generated versions.
    %% -------------------------------------------------------------------------

    PackagesSpecGeneratedDir = filename:join(lists:reverse(["generated", "packages", "src"] ++ RootPath)),
    PackagesSpecGeneratedResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_SPEC, PackagesSpecGeneratedDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile package specifications - generated versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesSpecGeneratedResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package specifications in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, package, "src/packages/generated/", PackagesSpecGeneratedResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : package bodies - handy versions.
    %% -------------------------------------------------------------------------

    PackagesBodyHandyDir = filename:join(lists:reverse(["packages", "src"] ++ RootPath)),
    PackagesBodyHandyResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_BODY, PackagesBodyHandyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile package bodies - handy versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesBodyHandyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package bodies in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, package, "src/packages/", PackagesBodyHandyResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : package bodies - generated versions.
    %% -------------------------------------------------------------------------

    PackagesBodyGeneratedDir = filename:join(lists:reverse(["generated", "packages", "src"] ++ RootPath)),
    PackagesBodyGeneratedResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_BODY, PackagesBodyGeneratedDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile package bodies - generated versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesBodyGeneratedResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package bodies in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, package, "src/packages/generated/", PackagesBodyGeneratedResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : functions - handy versions.
    %% -------------------------------------------------------------------------

    FunctionsHandyDir = filename:join(lists:reverse(["functions", "src"] ++ RootPath)),
    FunctionsHandyResult = lists:sort(filelib:wildcard(?WCARD_FUNCTIONS, FunctionsHandyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile functions - handy versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(FunctionsHandyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no functions in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, function, "src/functions/", FunctionsHandyResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : procedures - handy versions.
    %% -------------------------------------------------------------------------

    ProceduresHandyDir = filename:join(lists:reverse(["procedures", "src"] ++ RootPath)),
    ProceduresHandyResult = lists:sort(filelib:wildcard(?WCARD_PROCEDURES, ProceduresHandyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile procedures - handy versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(ProceduresHandyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no procedures in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, procedure, "src/procedures/", ProceduresHandyResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : triggers - handy versions.
    %% -------------------------------------------------------------------------

    TriggersHandyDir = filename:join(lists:reverse(["triggers", "src"] ++ RootPath)),
    TriggersHandyResult = lists:sort(filelib:wildcard(?WCARD_TRIGGERS, TriggersHandyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Compile triggers - handy versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(TriggersHandyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no triggers in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, trigger, "src/triggers/", TriggersHandyResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : Initialize the logger table.
    %% -------------------------------------------------------------------------

    case ?IO_TYPE_LOG of
        table ->
            io:format(File, "~s~n", ["DECLARE"]),
            io:format(File, "~s~n", ["    l_rownum                       PLS_INTEGER;"]),
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Initialization of the SBSDB log table ...');"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["    BEGIN"]),
            io:format(File, "~s~n", ["        SELECT ROWNUM"]),
            io:format(File, "~s~n", ["          INTO l_rownum"]),
            io:format(File, "~s~n", ["          FROM sbsdb_log"]),
            io:format(File, "~s~n", ["         WHERE ROWNUM = 1;"]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["         DBMS_OUTPUT.put_line ('Table SBSDB_LOG is already initialized !!!');"]),
            io:format(File, "~s~n", ["    EXCEPTION"]),
            io:format(File, "~s~n", ["        WHEN NO_DATA_FOUND"]),
            io:format(File, "~s~n", ["        THEN"]),
            io:format(File, "~s~n", ["            sbsdb_logger_lib.log_permanent ('SBSDB Logger installed.');"]),
            io:format(File, "~s~n", ["            DBMS_OUTPUT.put_line ('Table SBSDB_LOG is now initialized.');"]),
            io:format(File, "~s~n", ["    END;"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]),
            io:format(File, "~s~n", [""])
    end,

    %% -------------------------------------------------------------------------
    %% End   script.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('End   ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),

    ?I("Generated file - Installation script: ~s~n", [FileName]),

    ok.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB unit test installation script for execute privileges
%% for the code coverage.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_ut_execute_cover(FileName, Operation, ScriptTitle) ->
    ?D("Start~n FileName: ~p~n Operation: ~p~n ScriptTitle: ~p~n", [FileName, Operation, ScriptTitle]),

    {ok, File, _} = file:path_open([?PATH_INSTALL_GENERATED_TEST], FileName, [write]),

    {ok, Cwd} = file:get_cwd(),
    ?D("Cwd: ~p~n", [Cwd]),
    RootPath = lists:reverse(filename:split(Cwd)),
    ?D("RootPath: ~p~n", [RootPath]),

    %% -------------------------------------------------------------------------
    %% Start script
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["/*"]),
    io:format(File, "~s~n", ["   " ++ ScriptTitle]),
    io:format(File, "~s~n", ["*/"]),
    io:format(File, "~s~n", [""]),

    io:format(File, "~s~n", ["SET ECHO         OFF"]),
    io:format(File, "~s~n", ["SET FEEDBACK     OFF"]),
    io:format(File, "~s~n", ["SET HEADING      OFF"]),
    io:format(File, "~s~n", ["SET LINESIZE     200"]),
    io:format(File, "~s~n", ["SET PAGESIZE     0"]),
    io:format(File, "~s~n", ["SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED"]),
    io:format(File, "~s~n", ["SET TAB          OFF"]),
    io:format(File, "~s~n", ["SET VERIFY       OFF"]),
    io:format(File, "~s~n", ["WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('Start ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["VARIABLE user_username VARCHAR2 ( 128 )"]),
    io:format(File, "~s~n", ["EXECUTE :user_username := UPPER('&1');"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Install the software : package bodies - handy versions.
    %% -------------------------------------------------------------------------

    PackagesBodyHandyDir = filename:join(lists:reverse(["packages", "src"] ++ RootPath)),
    PackagesBodyHandyResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_BODY, PackagesBodyHandyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Process package bodies - handy versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesBodyHandyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package bodies in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_ut_execute_cover(File, package, Operation, PackagesBodyHandyResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : package bodies - generated versions.
    %% -------------------------------------------------------------------------

    PackagesBodyGeneratedDir = filename:join(lists:reverse(["generated", "packages", "src"] ++ RootPath)),
    PackagesBodyGeneratedResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_BODY, PackagesBodyGeneratedDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Process package bodies - generated versions ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesBodyGeneratedResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package bodies in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_ut_execute_cover(File, package, Operation, PackagesBodyGeneratedResult)
    end,

    %% -------------------------------------------------------------------------
    %% End   script.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('End   ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),

    ?I("Generated file - Installation script: ~s~n", [FileName]),

    ok.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB unit test installation script for execute privileges
%% for thecode coverage - grant or revoke.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_ut_execute_cover(_File, _FunctionPackageProcedure, _Operation, [] = _Object) ->
    ?D("Start~n File: ~p~n _FunctionPackageProcedure: ~p~n Operation: ~p~n Object: ~p~n", [_File, _FunctionPackageProcedure, _Operation, _Object]),
    ok;
generate_install_sbsdb_ut_execute_cover(File, FunctionPackageProcedure, Operation, [Object | Tail]) ->
    ?D("Start~n File: ~p~n _FunctionPackageProcedure: ~p~n Operation: ~p~n Object: ~p~n", [File, FunctionPackageProcedure, Operation, Object]),
    ObjectName = case FunctionPackageProcedure of
%%                     function ->
%%                         string:replace(Object, ".fnc", "", trailing);
                     package ->
                         string:replace(Object, ".pkb", "", trailing)
%%                     procedure ->
%%                         string:replace(Object, ".prc", "", trailing)
                 end,
    Statement = case Operation of
                    grant -> lists:append([
                        "GRANT EXECUTE ON ",
                        ObjectName,
                        " TO &1;"
                    ]);
                    revoke -> lists:append([
                        "REVOKE EXECUTE ON ",
                        ObjectName,
                        " FROM &1;"
                    ])
                end,
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('",
        Statement,
        "');"])]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [Statement]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    generate_install_sbsdb_ut_execute_cover(File, FunctionPackageProcedure, Operation, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB unit test installation script for execute privileges
%% for the unit tests.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_ut_execute_test(FileName, DBSchema, Operation, ScriptTitle) ->
    ?D("Start~n FileName: ~p~n DBSchema: ~p~n Operation: ~p~n ScriptTitle: ~p~n", [FileName, DBSchema, Operation, ScriptTitle]),

    {ok, File, _} = file:path_open([?PATH_INSTALL_GENERATED_TEST], FileName, [write]),

    {ok, Cwd} = file:get_cwd(),
    ?D("Cwd: ~p~n", [Cwd]),
    RootPath = lists:reverse(filename:split(Cwd)),
    ?D("RootPath: ~p~n", [RootPath]),

    %% -------------------------------------------------------------------------
    %% Start script
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["/*"]),
    io:format(File, "~s~n", ["   " ++ ScriptTitle]),
    io:format(File, "~s~n", ["*/"]),
    io:format(File, "~s~n", [""]),

    io:format(File, "~s~n", ["SET ECHO         OFF"]),
    io:format(File, "~s~n", ["SET FEEDBACK     OFF"]),
    io:format(File, "~s~n", ["SET HEADING      OFF"]),
    io:format(File, "~s~n", ["SET LINESIZE     200"]),
    io:format(File, "~s~n", ["SET PAGESIZE     0"]),
    io:format(File, "~s~n", ["SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED"]),
    io:format(File, "~s~n", ["SET TAB          OFF"]),
    io:format(File, "~s~n", ["SET VERIFY       OFF"]),
    io:format(File, "~s~n", ["WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('Start ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["VARIABLE user_username VARCHAR2 ( 128 )"]),
    io:format(File, "~s~n", ["EXECUTE :user_username := UPPER('&1');"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Install the software : package specifications.
    %% -------------------------------------------------------------------------

    PackagesDir = filename:join(lists:reverse(["packages", "src", "test"] ++ RootPath)),
    PackagesResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_BODY, PackagesDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Process package specifications ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package specifications in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_ut_execute_test(File, DBSchema, package, Operation, PackagesResult)
    end,

    %% -------------------------------------------------------------------------
    %% End   script.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('End   ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),

    ?I("Generated file - Installation script: ~s~n", [FileName]),

    ok.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB unit test installation script for execute privileges
%% for the unit tests - grant or revoke.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_ut_execute_test(_File, _DBSchema, _FunctionPackageProcedure, _Operation, [] = _Object) ->
    ?D("Start~n File: ~p~n DBSchema: ~p~n _FunctionPackageProcedure: ~p~n Operation: ~p~n Object: ~p~n",
        [_File, _DBSchema, _FunctionPackageProcedure, _Operation, _Object]),
    ok;
generate_install_sbsdb_ut_execute_test(File, DBSchema, FunctionPackageProcedure, Operation, [Object | Tail]) ->
    ?D("Start~n File: ~p~n DBSchema: ~p~n _FunctionPackageProcedure: ~p~n Operation: ~p~n Object: ~p~n",
        [File, DBSchema, FunctionPackageProcedure, Operation, Object]),
    ObjectName = case FunctionPackageProcedure of
%%                     function ->
%%                         string:replace(Object, ".fnc", "", trailing);
                     package ->
                         string:replace(Object, ".pkb", "", trailing)
%%                     procedure ->
%%                         string:replace(Object, ".prc", "", trailing)
                 end,
    Statement = case Operation of
                    grant -> lists:append([
                        "GRANT EXECUTE ON ",
                        case DBSchema == [] of
                            true -> [];
                            _ -> DBSchema ++ "."
                        end,
                        ObjectName,
                        " TO &1;"
                    ]);
                    revoke -> lists:append([
                        "REVOKE EXECUTE ON ",
                        case DBSchema == [] of
                            true -> [];
                            _ -> DBSchema ++ "."
                        end,
                        ObjectName,
                        " FROM &1;"
                    ])
                end,
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('",
        Statement,
        "');"])]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [Statement]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    generate_install_sbsdb_ut_execute_test(File, DBSchema, FunctionPackageProcedure, Operation, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB unit test installation script for packages.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_install_sbsdb_ut_package() ->
    ?D("Start~n", []),

    FileName = "sbsdb_ut_package_create.sql",
    ?D("FileName: ~p~n", [FileName]),
    {ok, File, _} = file:path_open([?PATH_INSTALL_GENERATED_TEST], FileName, [write]),

    {ok, Cwd} = file:get_cwd(),
    ?D("Cwd: ~p~n", [Cwd]),
    RootPath = lists:reverse(filename:split(Cwd)),
    ?D("RootPath: ~p~n", [RootPath]),

    %% -------------------------------------------------------------------------
    %% Start script
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["/*"]),
    io:format(File, "~s~n", ["   Create or update the SBSDB unit testing."]),
    io:format(File, "~s~n", ["*/"]),
    io:format(File, "~s~n", [""]),

    io:format(File, "~s~n", ["SET ECHO         OFF"]),
    io:format(File, "~s~n", ["SET FEEDBACK     OFF"]),
    io:format(File, "~s~n", ["SET HEADING      OFF"]),
    io:format(File, "~s~n", ["SET LINESIZE     200"]),
    io:format(File, "~s~n", ["SET PAGESIZE     0"]),
    io:format(File, "~s~n", ["SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED"]),
    io:format(File, "~s~n", ["SET TAB          OFF"]),
    io:format(File, "~s~n", ["SET VERIFY       OFF"]),
    io:format(File, "~s~n", ["WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('Start ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Install the software : package specifications.
    %% -------------------------------------------------------------------------

    PackagesSpecDir = filename:join(lists:reverse(["packages", "src", "test"] ++ RootPath)),
    PackagesSpecResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_SPEC, PackagesSpecDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Process package specifications ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesSpecResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package specifications in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, package, "src/packages/", PackagesSpecResult)
    end,

    %% -------------------------------------------------------------------------
    %% Install the software : package bodies.
    %% -------------------------------------------------------------------------

    PackagesBodyDir = filename:join(lists:reverse(["packages", "src", "test"] ++ RootPath)),
    PackagesBodyResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_BODY, PackagesBodyDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Process package bodies ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesBodyResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package bodies in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_install_sbsdb_schema_compile(File, package, "src/packages/", PackagesBodyResult)
    end,

    %% -------------------------------------------------------------------------
    %% End   script.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('End   ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),

    ?I("Generated file - Installation script: ~s~n", [FileName]),

    ok.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate method params in package method
%% [conditional compilation].
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_method_param_version(_File, _Processed, [] = _Version) ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [_File, _Processed, _Version]),
    ok;
generate_method_param_version(File, Processed, [Version | Tail])
    when length(Version#version.parameters) == 0 ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [File, Processed, Version]),
    generate_method_param_version(File, Processed, Tail);
generate_method_param_version(File, Processed, [Version | Tail]) ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [File, Processed, Version]),

    {ConditionType, ConditionValue} = _Condition = Version#version.condition,
    ?D("Condition: ~p~n", [_Condition]),

    Parameters = Version#version.parameters,
    ?D("Parameters: ~p~n", [Parameters]),

    case ConditionType of
        ifend ->
            case Processed of
                0 -> io:format(File, "~s~n", ["    $IF " ++ ConditionValue]);
                _ -> io:format(File, "~s~n", ["    $ELSIF " ++ ConditionValue])
            end,
            io:format(File, "~s~n", ["    $THEN"]);
        _ -> nop
    end,

    io:format(File, "~s~n", ["    ("]),

    ok = generate_method_params(File, length(Parameters), Parameters),

    io:format(File, "~s~n", ["    )"]),

    case ConditionType == ifend andalso Tail == [] of
        true -> io:format(File, "~s~n", ["    $END"]);
        _ -> nop
    end,

    generate_method_param_version(File, Processed + 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate processing in functions
%% [conditional compilation].
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_method_process_function_version(_File, _PackageImplName, _MethodName, _Processed, [] = _Version) ->
    ?D("Start~n File: ~p~n PackageImplName: ~p~n MethodName: ~p~n Processed: ~p~n Version: ~p~n", [_File, _PackageImplName, _MethodName, _Processed, _Version]),
    ok;
generate_method_process_function_version(File, PackageImplName, MethodName, Processed, [Version | Tail]) ->
    ?D("Start~n File: ~p~n PackageImplName: ~p~n MethodName: ~p~n Processed: ~p~n Version: ~p~n", [File, PackageImplName, MethodName, Processed, Version]),

    {ConditionType, ConditionValue} = _Condition = Version#version.condition,
    ?D("Condition: ~p~n", [_Condition]),

    Parameters = Version#version.parameters,
    ?D("Parameters: ~p~n", [Parameters]),

    case ConditionType of
        ifend ->
            case Processed of
                0 -> io:format(File, "~s~n", ["    $IF " ++ ConditionValue]);
                _ -> io:format(File, "~s~n", ["    $ELSIF " ++ ConditionValue])
            end,
            io:format(File, "~s~n", ["    $THEN"]);
        _ -> nop
    end,

    case Version#version.pipelined of
        [] ->
            io:format(File, "~s~n", [lists:append([
                "        l_return_value := ",
                PackageImplName,
                ".",
                MethodName,
                " ("
            ])]),

            ok = generate_method_params_call(File, length(Parameters), Parameters),

            io:format(File, "~s~n", ["        );"]),

            ok = generate_method_params_logger_versions(File, 'end', function, MethodName, 0, [Version]),

            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["        return l_return_value;"]),
            io:format(File, "~s~n", ["    EXCEPTION"]);
        _ ->
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["        SELECT *"]),
            io:format(File, "~s~n", ["          BULK COLLECT INTO l_coll"]),
            io:format(File, "~s~n", [lists:append([
                "          FROM TABLE (",
                PackageImplName,
                ".",
                MethodName
            ])]),
            io:format(File, "~s~n", ["                     ("]),

            ok = generate_method_params_call(File, length(Parameters), Parameters),

            io:format(File, "~s~n", ["                     ));"]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["        <<process_rows>>"]),
            io:format(File, "~s~n", ["        FOR indx IN 1 .. l_coll.COUNT"]),
            io:format(File, "~s~n", ["        LOOP"]),
            io:format(File, "~s~n", [lists:append([
                "            PIPE ROW (",
                PackageImplName,
                ".pipe_row (l_coll (indx)));"
            ])]),
            io:format(File, "~s~n", ["        END LOOP process_rows;"]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", [lists:append([
                "        sbsdb_logger_lib.log_info ('Rows returned ' || l_coll.COUNT(), sbsdb_logger_lib.scope ($$plsql_unit, '",
                MethodName,
                "'));"
            ])]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["        RETURN;"]),
            io:format(File, "~s~n", ["    EXCEPTION"]),
            io:format(File, "~s~n", ["        WHEN no_data_needed"]),
            io:format(File, "~s~n", ["        THEN"]),
            io:format(File, "~s~n", ["            RAISE;"])
    end,

    case ConditionType == ifend andalso Tail == [] of
        true -> io:format(File, "~s~n", ["    $END"]);
        _ -> nop
    end,

    generate_method_process_function_version(File, PackageImplName, MethodName, Processed + 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate processing in procedures
%% [conditional compilation].
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_method_process_procedure_version(_File, _Processed, [] = _Version) ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [_File, _Processed, _Version]),
    ok;
generate_method_process_procedure_version(File, Processed, [Version | Tail]) ->
    ?D("Start~n File: ~p~n Processed: ~p~n Version: ~p~n", [File, Processed, Version]),

    {ConditionType, ConditionValue} = _Condition = Version#version.condition,
    ?D("Condition: ~p~n", [_Condition]),

    Parameters = Version#version.parameters,
    ?D("Parameters: ~p~n", [Parameters]),

    case ConditionType of
        ifend ->
            case Processed of
                0 -> io:format(File, "~s~n", ["    $IF " ++ ConditionValue]);
                _ -> io:format(File, "~s~n", ["    $ELSIF " ++ ConditionValue])
            end,
            io:format(File, "~s~n", ["    $THEN"]);
        _ -> nop
    end,

    ok = generate_method_params_call(File, length(Parameters), Parameters),

    case ConditionType == ifend andalso Tail == [] of
        true -> io:format(File, "~s~n", ["    $END"]);
        _ -> nop
    end,

    generate_method_process_procedure_version(File, Processed + 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate a package body.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_package_body(Package) ->
    ?D("Start~n Package: ~p~n", [Package]),

    PackageImplName = Package#package.implName,
    ?D("PackageImplName: ~p~n", [PackageImplName]),
    PackageName = Package#package.name,
    ?D("PackageName: ~p~n", [PackageName]),

    ?D("PATH_PACKAGES_GENERATED: ~p~n", [?PATH_PACKAGES_GENERATED]),
    filelib:ensure_dir(?PATH_PACKAGES_GENERATED),
    PackageBodyFileName = PackageName ++ ?FILE_SUFFIX_PACKAGES_BODY,
    ?D("PackageBodyFileName: ~p~n", [PackageBodyFileName]),

    % Generate code - open file ------------------------------------------------

    {ok, File, _} = file:path_open([?PATH_PACKAGES_GENERATED], PackageBodyFileName, [write]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", [lists:append([
        "-- GENERATED CODE (based on the functions and procedures in the package specification ",
        Package#package.implName,
        ")"
    ])]),
    io:format(File, "~n", []),
    io:format(File, "~s~n", ["CREATE OR REPLACE PACKAGE BODY " ++ PackageName]),
    io:format(File, "~s~n", ["IS"]),
    io:format(File, "~n", []),
    io:format(File, "~s~n", ["    /* ========================================================================="]),
    io:format(File, "~s~n", ["       Public Function Implementation."]),
    io:format(File, "~s~n", ["       ---------------------------------------------------------------------- */"]),
    io:format(File, "~n", []),

    ok = generate_package_body_function(File, PackageName, PackageImplName, lists:sort(Package#package.functions)),

    io:format(File, "~s~n", ["    /* ========================================================================="]),
    io:format(File, "~s~n", ["       Public Procedure Implementation."]),
    io:format(File, "~s~n", ["       ---------------------------------------------------------------------- */"]),
    io:format(File, "~n", []),

    ok = generate_package_body_procedure(File, PackageName, PackageImplName, lists:sort(Package#package.procedures)),

    io:format(File, "~s~n", ["/* ============================================================================="]),
    io:format(File, "~s~n", ["   Initializing Package."]),
    io:format(File, "~s~n", ["   -------------------------------------------------------------------------- */"]),
    io:format(File, "~n", []),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.enable (buffer_size => NULL);"]),
    io:format(File, "~s~n", [lists:append([
        "END ",
        PackageName,
        ";"
    ])]),
    io:format(File, "~s~n", ["/"]),

    % Generate code - close file -----------------------------------------------

    ok = Result = file:close(File),

    ?I("Generated file - Package body: ~s~n", [PackageBodyFileName]),

    ?D("End~n Result: ~p~n", [Result]),

    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate function bodies in package body.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_package_body_function(_File, _PackageName, _PackageNameImpl, [] = _Function) ->
    ?D("Start~n File: ~p~n PackageName: ~p~n PackageImplName: ~p~n Function: ~p~n", [_File, _PackageName, _PackageNameImpl, _Function]),
    ok;
generate_package_body_function(File, PackageName, PackageImplName, [Function | Tail])
    when Function#function.apiHidden == "TRUE" ->
    ?D("Start~n File: ~p~n PackageName: ~p~n PackageImplName: ~p~n Function: ~p~n", [File, PackageName, PackageImplName, Function]),
    generate_package_body_function(File, PackageName, PackageImplName, Tail);
generate_package_body_function(File, PackageName, PackageImplName, [Function | Tail]) ->
    ?D("Start~n File: ~p~n PackageName: ~p~n PackageImplName: ~p~n Function: ~p~n", [File, PackageName, PackageImplName, Function]),

    MethodName = Function#function.name,
    ?D("MethodName: ~p~n", [MethodName]),

    MethodNameMD5 = get_api_scope("SBSDB_AC_", lists:append([
        PackageName,
        ".",
        Function#function.name
    ])),
    ?D("MethodNameMD5: ~p~n", [MethodNameMD5]),

    Versions = Function#function.versions,
    ?D("Versions: ~p~n", [Versions]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", ["    FUNCTION " ++ MethodName]),

    ok = generate_method_param_version(File, 0, Versions),

    ok = generate_function_return_definition_version(File, 0, Versions),

    io:format(File, "~s~n", ["    IS"]),

    ok = generate_function_return_local_version(File, 0, Versions),

    io:format(File, "~s~n", ["    BEGIN"]),

    ok = generate_method_params_logger_versions(File, start, function, MethodName, 0, Versions),

    io:format(File, "~s~n", [lists:append([
        "        sbsdb_api_impl.raise_access_denied ('",
        MethodNameMD5,
        "');"
    ])]),

    ok = generate_method_process_function_version(File, PackageImplName, MethodName, 0, Versions),

    io:format(File, "~s~n", ["        WHEN OTHERS"]),
    io:format(File, "~s~n", ["        THEN"]),
    io:format(File, "~s~n", ["            IF SQLCODE = sbsdb_error_lib.en_access_denied"]),
    io:format(File, "~s~n", ["            THEN"]),

    ok = generate_method_params_logger_versions(File, error, function, MethodName, 0, Versions),

    io:format(File, "~s~n", ["            END IF;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["            RAISE;"]),

    io:format(File, "~s~n", [lists:append([
        "    END ",
        MethodName,
        ";"
    ])]),
    io:format(File, "~s~n", [""]),

    ok = generate_package_body_function_procedure(File, PackageName, PackageImplName, MethodName, 0, Versions),

    generate_package_body_function(File, PackageName, PackageImplName, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate procedure bodies in package body based on pipelined functions.
%% [conditional compilation].
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_package_body_function_procedure(_File, _PackageName, _PackageImplName, _MethodName, _Processed, [] = _Version) ->
    ?D("Start~n File: ~p~n PackageName: ~p~n PackageImplName: ~p~n MethodName: ~p~n Processed: ~p~n Version: ~p~n",
        [_File, _PackageName, _PackageImplName, _MethodName, _Processed, _Version]),
    ok;
generate_package_body_function_procedure(File, PackageName, PackageImplName, MethodName, Processed, [Version | Tail]) ->
    ?D("Start~n File: ~p~n PackageName: ~p~n PackageImplName: ~p~n MethodName: ~p~n Processed: ~p~n Version: ~p~n",
        [File, PackageName, PackageImplName, MethodName, Processed, Version]),

    MethodNameMD5 = get_api_scope("SBSDB_AC_", lists:append([
        PackageName,
        ".",
        MethodName
    ])),
    ?D("MethodNameMD5: ~p~n", [MethodNameMD5]),

    {ConditionType, ConditionValue} = _Condition = Version#version.condition,
    ?D("Condition: ~p~n", [_Condition]),

    Parameters = Version#version.parameters,
    ?D("Parameters: ~p~n", [Parameters]),

    % Generate code ------------------------------------------------------------

    case Version#version.pipelined of
        [] -> nop;
        _ ->
            case ConditionType of
                ifend ->
                    case Processed of
                        0 ->
                            io:format(File, "~s~n", ["    $IF " ++ ConditionValue]);
                        _ ->
                            io:format(File, "~s~n", ["    $ELSIF " ++ ConditionValue])
                    end,
                    io:format(File, "~s~n", ["    $THEN"]);
                _ -> nop
            end,

            io:format(File, "~s~n", ["    PROCEDURE " ++ MethodName]),

            ok = generate_method_param_version(File, 0, [Version]),

            io:format(File, "~s~n", ["    IS"]),
            io:format(File, "~s~n", ["        l_rows PLS_INTEGER;"]),
            io:format(File, "~s~n", ["    BEGIN"]),

            ok = generate_method_params_logger_versions(File, start, procedure, MethodName, 0, [Version]),

            io:format(File, "~s~n", [lists:append([
                "        sbsdb_api_impl.raise_access_denied ('",
                MethodNameMD5,
                "');"
            ])]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["        SELECT COUNT(*)"]),
            io:format(File, "~s~n", ["          INTO l_rows"]),
            io:format(File, "~s~n", [lists:append([
                "          FROM TABLE (",
                PackageImplName,
                ".",
                MethodName
            ])]),
            io:format(File, "~s~n", ["                     ("]),

            ok = generate_method_params_call(File, length(Parameters), Parameters),

            io:format(File, "~s~n", ["                     ));"]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", [lists:append([
                "        sbsdb_logger_lib.log_info ('Rows returned ' || l_rows, sbsdb_logger_lib.scope ($$plsql_unit, '",
                MethodName,
                "'));"
            ])]),
            io:format(File, "~s~n", ["    EXCEPTION"]),
            io:format(File, "~s~n", ["        WHEN no_data_needed"]),
            io:format(File, "~s~n", ["        THEN"]),
            io:format(File, "~s~n", ["            RAISE;"]),
            io:format(File, "~s~n", ["        WHEN OTHERS"]),
            io:format(File, "~s~n", ["        THEN"]),
            io:format(File, "~s~n", ["            IF SQLCODE = sbsdb_error_lib.en_access_denied"]),
            io:format(File, "~s~n", ["            THEN"]),

            ok = generate_method_params_logger_versions(File, error, procedure, MethodName, 0, [Version]),

            io:format(File, "~s~n", ["            END IF;"]),
            io:format(File, "~s~n", [""]),
            io:format(File, "~s~n", ["            RAISE;"]),
            io:format(File, "~s~n", [lists:append([
                "    END ",
                MethodName,
                ";"
            ])]),

            case ConditionType == ifend andalso Tail == [] of
                true -> io:format(File, "~s~n", ["    $END"]);
                _ -> nop
            end,

            io:format(File, "~s~n", [""])
    end,

    generate_package_body_function_procedure(File, PackageName, PackageImplName, MethodName, Processed + 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate procedure bodies in package body.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_package_body_procedure(_File, _PackageName, _PackageNameImpl, [] = _Procedure) ->
    ?D("Start~n File: ~p~n PackageName: ~p~n PackageImplName: ~p~n Procedure: ~p~n", [_File, _PackageName, _PackageNameImpl, _Procedure]),
    ok;
generate_package_body_procedure(File, PackageName, PackageImplName, [Procedure | Tail])
    when Procedure#procedure.apiHidden == "TRUE" ->
    ?D("Start~n File: ~p~n PackageName: ~p~n PackageImplName: ~p~n Procedure: ~p~n", [File, PackageName, PackageImplName, Procedure]),
    generate_package_body_procedure(File, PackageName, PackageImplName, Tail);
generate_package_body_procedure(File, PackageName, PackageImplName, [Procedure | Tail]) ->
    ?D("Start~n File: ~p~n PackageName ~p~n PackageImplName: ~p~n Procedure: ~p~n", [File, PackageName, PackageImplName, Procedure]),

    MethodName = Procedure#procedure.name,
    ?D("MethodName: ~p~n", [MethodName]),

    MethodNameMD5 = get_api_scope("SBSDB_AC_", lists:append([
        PackageName,
        ".",
        Procedure#procedure.name
    ])),
    ?D("MethodNameMD5: ~p~n", [MethodNameMD5]),

    Versions = Procedure#procedure.versions,
    ?D("Versions: ~p~n", [Versions]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", ["    PROCEDURE " ++ MethodName]),

    ok = generate_method_param_version(File, 0, Versions),

    io:format(File, "~s~n", ["    IS"]),
    io:format(File, "~s~n", ["    BEGIN"]),

    ok = generate_method_params_logger_versions(File, start, procedure, MethodName, 0, Versions),

    io:format(File, "~s~n", [lists:append([
        "        sbsdb_api_impl.raise_access_denied ('",
        MethodNameMD5,
        "');"
    ])]),

    io:format(File, "~s~n", [lists:append([
        "        ",
        PackageImplName,
        ".",
        MethodName,
        " ("
    ])]),

    ok = generate_method_process_procedure_version(File, 0, Versions),

    io:format(File, "~s~n", ["        );"]),

    ok = generate_method_params_logger_versions(File, 'end', procedure, MethodName, 0, Versions),

    io:format(File, "~s~n", ["    EXCEPTION"]),
    io:format(File, "~s~n", ["        WHEN OTHERS"]),
    io:format(File, "~s~n", ["        THEN"]),
    io:format(File, "~s~n", ["            IF SQLCODE = sbsdb_error_lib.en_access_denied"]),
    io:format(File, "~s~n", ["            THEN"]),

    ok = generate_method_params_logger_versions(File, error, procedure, MethodName, 0, Versions),

    io:format(File, "~s~n", ["            END IF;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["            RAISE;"]),

    io:format(File, "~s~n", [lists:append([
        "    END ",
        MethodName,
        ";"
    ])]),
    io:format(File, "~s~n", [""]),

    generate_package_body_procedure(File, PackageName, PackageImplName, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate a package specification.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_package_spec(Package) ->
    ?D("Start~n Package: ~p~n", [Package]),

    PackageName = Package#package.name,
    ?D("PackageName: ~p~n", [PackageName]),

    ?D("PATH_PACKAGES_GENERATED: ~p~n", [?PATH_PACKAGES_GENERATED]),
    filelib:ensure_dir(?PATH_PACKAGES_GENERATED),
    PackageSpecFileName = PackageName ++ ?FILE_SUFFIX_PACKAGES_SPEC,
    ?D("PackageSpecFileName: ~p~n", [PackageSpecFileName]),

    % Generate code - open file ------------------------------------------------

    {ok, File, _} = file:path_open([?PATH_PACKAGES_GENERATED], PackageSpecFileName, [write]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", [lists:append([
        "-- GENERATED CODE (based on the functions and procedures in the package specification ",
        Package#package.implName,
        ")"
    ])]),
    io:format(File, "~n", []),
    io:format(File, "~s~n", ["CREATE OR REPLACE PACKAGE " ++ PackageName]),
    io:format(File, "~s~n", ["IS"]),
    io:format(File, "~n", []),
    io:format(File, "~s~n", ["    /* ========================================================================="]),
    io:format(File, "~s~n", ["       Public Function Declaration."]),
    io:format(File, "~s~n", ["       ---------------------------------------------------------------------- */"]),
    io:format(File, "~n", []),

    ok = generate_package_spec_function(File, lists:sort(Package#package.functions)),

    io:format(File, "~s~n", ["    /* ========================================================================="]),
    io:format(File, "~s~n", ["       Public Procedure Declaration."]),
    io:format(File, "~s~n", ["       ---------------------------------------------------------------------- */"]),
    io:format(File, "~n", []),

    ok = generate_package_spec_procedure(File, lists:sort(Package#package.procedures)),

    io:format(File, "~s~n", [lists:append([
        "END ",
        PackageName,
        ";"
    ])]),
    io:format(File, "~s~n", ["/"]),

    % Generate code - close file -----------------------------------------------

    ok = Result = file:close(File),

    ?I("Generated file - Package specification: ~s~n", [PackageSpecFileName]),

    ?D("End~n Result: ~p~n", [Result]),

    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate function specifications in package specification.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_package_spec_function(_File, [] = _Function) ->
    ?D("Start~n File: ~p~n Function: ~p~n", [_File, _Function]),
    ok;
generate_package_spec_function(File, [Function | Tail])
    when Function#function.apiHidden == "TRUE" ->
    ?D("Start~n File: ~p~n Function: ~p~n", [File, Function]),
    generate_package_spec_function(File, Tail);
generate_package_spec_function(File, [Function | Tail]) ->
    ?D("Start~n File: ~p~n Function: ~p~n", [File, Function]),

    MethodName = Function#function.name,
    ?D("MethodName: ~p~n", [MethodName]),

    Versions = Function#function.versions,
    ?D("Versions: ~p~n", [Versions]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", ["    FUNCTION " ++ MethodName]),

    ok = generate_method_param_version(File, 0, Versions),

    ok = generate_function_return_definition_version(File, 0, Versions),

    io:format(File, "~s~n", ["    ;"]),
    io:format(File, "~s~n", [""]),

    ok = generate_package_spec_function_procedure(File, MethodName, 0, Versions),

    generate_package_spec_function(File, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate procedure specifications in package specification based on
%% pipelined functions.
%% [conditional compilation].
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_package_spec_function_procedure(_File, _MethodName, _Processed, [] = _Version) ->
    ?D("Start~n File: ~p~n MethodName: ~p~n Processed: ~p~n Version: ~p~n", [_File, _MethodName, _Processed, _Version]),
    ok;
generate_package_spec_function_procedure(File, MethodName, Processed, [Version | Tail]) ->
    ?D("Start~n File: ~p~n MethodName: ~p~n Processed: ~p~n Version: ~p~n", [File, MethodName, Processed, Version]),

    {ConditionType, ConditionValue} = _Condition = Version#version.condition,
    ?D("Condition: ~p~n", [_Condition]),

    % Generate code ------------------------------------------------------------

    case Version#version.pipelined of
        [] -> nop;
        _ ->
            case ConditionType of
                ifend ->
                    case Processed of
                        0 ->
                            io:format(File, "~s~n", ["    $IF " ++ ConditionValue]);
                        _ ->
                            io:format(File, "~s~n", ["    $ELSIF " ++ ConditionValue])
                    end,
                    io:format(File, "~s~n", ["    $THEN"]);
                _ -> nop
            end,

            io:format(File, "~s~n", ["    PROCEDURE " ++ MethodName]),

            ok = generate_method_param_version(File, 0, [Version]),

            io:format(File, "~s~n", ["    ;"]),
            io:format(File, "~s~n", [""]),

            case ConditionType == ifend andalso Tail == [] of
                true -> io:format(File, "~s~n", ["    $END"]);
                _ -> nop
            end,

            io:format(File, "~s~n", [""])
    end,

    generate_package_spec_function_procedure(File, MethodName, Processed + 1, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate procedure specifications in package specification.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_package_spec_procedure(_File, [] = _Procedure) ->
    ?D("Start~n File: ~p~n Procedure: ~p~n", [_File, _Procedure]),
    ok;
generate_package_spec_procedure(File, [Procedure | Tail])
    when Procedure#procedure.apiHidden == "TRUE" ->
    ?D("Start~n File: ~p~n Procedure: ~p~n", [File, Procedure]),
    generate_package_spec_procedure(File, Tail);
generate_package_spec_procedure(File, [Procedure | Tail]) ->
    ?D("Start~n File: ~p~n Procedure: ~p~n", [File, Procedure]),

    MethodName = Procedure#procedure.name,
    ?D("MethodName: ~p~n", [MethodName]),

    Versions = Procedure#procedure.versions,
    ?D("Versions: ~p~n", [Versions]),

    % Generate code ------------------------------------------------------------

    io:format(File, "~s~n", ["    PROCEDURE " ++ MethodName]),

    ok = generate_method_param_version(File, 0, Versions),

    io:format(File, "~s~n", ["    ;"]),
    io:format(File, "~s~n", [""]),

    generate_package_spec_procedure(File, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB unit test uninstallation script for packages.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_uninstall_sbsdb_ut_package() ->
    ?D("Start~n", []),

    FileName = "sbsdb_ut_package_drop.sql",
    ?D("FileName: ~p~n", [FileName]),
    {ok, File, _} = file:path_open([?PATH_INSTALL_GENERATED_TEST], FileName, [write]),

    {ok, Cwd} = file:get_cwd(),
    ?D("Cwd: ~p~n", [Cwd]),
    RootPath = lists:reverse(filename:split(Cwd)),
    ?D("RootPath: ~p~n", [RootPath]),

    %% -------------------------------------------------------------------------
    %% Start script
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["-- GENERATED CODE"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["/*"]),
    io:format(File, "~s~n", ["   Drop the SBSDB unit testing."]),
    io:format(File, "~s~n", ["*/"]),
    io:format(File, "~s~n", [""]),

    io:format(File, "~s~n", ["SET ECHO         OFF"]),
    io:format(File, "~s~n", ["SET FEEDBACK     OFF"]),
    io:format(File, "~s~n", ["SET HEADING      OFF"]),
    io:format(File, "~s~n", ["SET LINESIZE     200"]),
    io:format(File, "~s~n", ["SET PAGESIZE     0"]),
    io:format(File, "~s~n", ["SET SERVEROUTPUT ON FORMAT WRAPPED SIZE UNLIMITED"]),
    io:format(File, "~s~n", ["SET TAB          OFF"]),
    io:format(File, "~s~n", ["SET VERIFY       OFF"]),
    io:format(File, "~s~n", ["WHENEVER SQLERROR EXIT sql.sqlcode ROLLBACK;"]),
    io:format(File, "~s~n", [""]),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('Start ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    %% -------------------------------------------------------------------------
    %% Uninstall the software : packages.
    %% -------------------------------------------------------------------------

    PackagesSpecDir = filename:join(lists:reverse(["packages", "src", "test"] ++ RootPath)),
    PackagesSpecResult = lists:sort(filelib:wildcard(?WCARD_PACKAGES_SPEC, PackagesSpecDir)),

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('Uninstall packages ...');"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('<------------------------------------------------------------------------------>');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),

    case length(PackagesSpecResult) of
        0 ->
            io:format(File, "~s~n", ["BEGIN"]),
            io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('There are no package specifications in the given directory !!!');"]),
            io:format(File, "~s~n", ["END;"]),
            io:format(File, "~s~n", ["/"]);
        _ ->
            ok = generate_uninstall_sbsdb_ut_package(File, PackagesSpecResult)
    end,

    %% -------------------------------------------------------------------------
    %% End   script.
    %% -------------------------------------------------------------------------

    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('--------------------------------------------------------------------------------');"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('End   ",
        FileName,
        "');"
    ])]),
    io:format(File, "~s~n", ["    DBMS_OUTPUT.put_line ('================================================================================');"]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),

    ?I("Generated file - Uninstallation script: ~s~n", [FileName]),

    ok.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the SBSDB unit test uninstallation script for the packages.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_uninstall_sbsdb_ut_package(_File, [] = _Object) ->
    ?D("Start~n File: ~p~n Object: ~p~n", [_File, _Object]),
    ok;
generate_uninstall_sbsdb_ut_package(File, [Object | Tail]) ->
    ?D("Start~n File: ~p~n Object: ~p~n", [File, Object]),
    ObjectName = string:replace(Object, ".pks", "", trailing),
    io:format(File, "~s~n", ["BEGIN"]),
    io:format(File, "~s~n", [lists:append([
        "    DBMS_OUTPUT.put_line ('DROP PACKAGE ",
        ObjectName,
        "');"])]),
    io:format(File, "~s~n", ["END;"]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [lists:append([
        "DROP PACKAGE ",
        ObjectName
    ])]),
    io:format(File, "~s~n", ["/"]),
    io:format(File, "~s~n", [""]),
    generate_uninstall_sbsdb_ut_package(File, Tail).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Computing the API scope (method signature (incl. MD5 hash)).
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_api_scope(Type, Data)
    when Type == "SBSDB_AC_", is_list(Data) ->
    ?D("Start~n Type: ~p~n Data: ~p~n", [Type, Data]),

    Hash = Type ++ string:uppercase(string:slice([hd(erlang:integer_to_list(Nibble, 16)) || <<Nibble:5>> <= crypto:hash(md5, string:lowercase(Data))], 0, 21)),

    ?D("End~n Hash: ~p~n", [Hash]),
    Hash.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determine the XML-Files to be processed.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_filenames() ->
    ?D("Start~n", []),

    {ok, Cwd} = file:get_cwd(),
    ?D("Cwd: ~p~n", [Cwd]),
    RootPath = lists:reverse(filename:split(Cwd)),
    ?D("RootPath: ~p~n", [RootPath]),
    PackagesDir = filename:join(lists:reverse(["packages", "src"] ++ RootPath)),
    ?D("PackagesDir: ~p~n", [PackagesDir]),
    Result = lists:sort(filelib:wildcard(?WCARD_PACKAGES_SPEC, PackagesDir)),

    ?D("End~n Result: ~p~n", [Result]),
    Result.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the generation process.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init() ->
    ?D("Start~n", []),

    ParserState = init_install_software(),

    ?D("End~n ParserState: ~p~n", [ParserState]),
    ParserState.

init_install_software() ->
    ?D("Start~n", []),

    ?D("PATH_INSTALL_GENERATED: ~p~n", [?PATH_INSTALL_GENERATED]),
    filelib:ensure_dir(?PATH_INSTALL_GENERATED),

    ?D("PATH_INSTALL_GENERATED_TEST: ~p~n", [?PATH_INSTALL_GENERATED_TEST]),
    filelib:ensure_dir(?PATH_INSTALL_GENERATED_TEST),

    % save file informations ---------------------------------------------------
    ParserState = #parser_state{package = #package{}},

    ?D("End~n ParserState: ~p~n", [ParserState]),
    ParserState.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAX Parser Events: ignored.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parser_event(Event, _Location, _ParserState)
    when Event == endDocument;        Event == startDocument ->
    _ParserState;
parser_event({Type, _} = _Event, _Location, _ParserState)
    when Type == comment;Type == endPrefixMapping; Type == ignorableWhitespace ->
    _ParserState;
parser_event({Type, _, _} = _Event, _Location, _ParserState)
    when Type == startPrefixMapping ->
    _ParserState;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAX Parser Events: characters: package & function.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "ApiGroupPrivilege", "ApiGroup"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    FunctionNew = Function#function{apiGroups = Function#function.apiGroups ++ [String]},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "ApiGroupPrivilege", "Privilege", "Object"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    PackagePrivileges = Package#package.privileges,
    Privilege = lists:last(PackagePrivileges),
    PrivilegeNew = Privilege#privilege{object = String},
    ?I("Object privilege of type: ~p to object: ~p~n", [PrivilegeNew#privilege.type, PrivilegeNew#privilege.object]),
    PackagePrivilegesNew = lists:droplast(Package#package.privileges) ++ [PrivilegeNew],
    PackageNew = Package#package{privileges = PackagePrivilegesNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "ApiGroupPrivilege", "Privilege", "Type"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    PackagePrivileges = Package#package.privileges,
    PackagePrivilegesNew = case PackagePrivileges of
                               [] ->
                                   [#privilege{type = String}];
                               _ ->
                                   PackagePrivileges ++ [#privilege{type = String}]
                           end,
    case String of
        "ALTER" -> nop;
        "DEBUG" -> nop;
        "DELETE" -> nop;
        "EXECUTE" -> nop;
        "FLASHBACK ARCHIVE" -> nop;
        "INDEX" -> nop;
        "INHERIT PRIVILEGES" -> nop;
        "INHERIT REMOTE PRIVILEGES" -> nop;
        "INSERT" -> nop;
        "KEEP SEQUENCE" -> nop;
        "MERGE VIEW" -> nop;
        "ON COMMIT REFRESH" -> nop;
        "QUERY REWRITE" -> nop;
        "READ" -> nop;
        "REFERENCES" -> nop;
        "SELECT" -> nop;
        "TRANSLATE SQL" -> nop;
        "UNDER" -> nop;
        "UPDATE" -> nop;
        "USE" -> nop;
        "WRITE" -> nop;
        _ -> ?I("System privilege of type: ~p~n", [String])
    end,
    PackageNew = Package#package{privileges = PackagePrivilegesNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "ApiHidden"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    FunctionNew = Function#function{apiGroups = Function#function.apiGroups ++ ["hidden"], apiHidden = String},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Condition", "IfEnd"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    Versions = Function#function.versions,
    Type = list_to_atom(string:casefold(lists:last(tuple_to_list(ParserState#parser_state.localNames)))),
    VersionsNew = Versions ++ [#version{condition = {Type, String}}],
    FunctionNew = Function#function{versions = VersionsNew},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "ManPage"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    FunctionNew = Function#function{manPage = String},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Name"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    FunctionsNew = case Functions of
                       [] ->
                           [#function{name = String}];
                       _ ->
                           Function = lists:last(Functions),
                           case String == Function#function.name of
                               true -> Functions;
                               _ ->
                                   FunctionNew = #function{name = String},
                                   Functions ++ [FunctionNew]
                           end
                   end,
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Parameter", "DataType"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    Versions = Function#function.versions,
    Version = lists:last(Versions),
    Parameters = Version#version.parameters,
    Parameter = lists:last(Parameters),
    ParameterNew = Parameter#parameter{dataType = String},
    ParametersNew = lists:droplast(Parameters) ++ [ParameterNew],
    VersionNew = Version#version{parameters = ParametersNew},
    VersionsNew = lists:droplast(Versions) ++ [VersionNew],
    FunctionNew = Function#function{versions = VersionsNew},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Parameter", "DefaultValue", "Expression"};
         ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Parameter", "DefaultValue", "String"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    Versions = Function#function.versions,
    Version = lists:last(Versions),
    Parameters = Version#version.parameters,
    Parameter = lists:last(Parameters),
    Type = list_to_atom(string:casefold(lists:last(tuple_to_list(ParserState#parser_state.localNames)))),
    ParameterNew = Parameter#parameter{defaultValue = {Type, String}},
    ParametersNew = lists:droplast(Parameters) ++ [ParameterNew],
    VersionNew = Version#version{parameters = ParametersNew},
    VersionsNew = lists:droplast(Versions) ++ [VersionNew],
    FunctionNew = Function#function{versions = VersionsNew},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Parameter", "Mode"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    Versions = Function#function.versions,
    Version = lists:last(Versions),
    Parameters = Version#version.parameters,
    Parameter = lists:last(Parameters),
    ParameterNew = Parameter#parameter{mode = String},
    ParametersNew = lists:droplast(Parameters) ++ [ParameterNew],
    VersionNew = Version#version{parameters = ParametersNew},
    VersionsNew = lists:droplast(Versions) ++ [VersionNew],
    FunctionNew = Function#function{versions = VersionsNew},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Parameter", "Name"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    Versions = Function#function.versions,
    VersionsNew = case Versions of
                      [] ->
                          ParameterNew = #parameter{name = String},
                          ParametersNew = [ParameterNew],
                          VersionNew = #version{parameters = ParametersNew},
                          [VersionNew];
                      _ ->
                          Version = lists:last(Versions),
                          Parameters = Version#version.parameters,
                          ParametersNew = case Parameters of
                                              [] ->
                                                  ParameterNew = #parameter{name = String},
                                                  Parameters ++ [ParameterNew];
                                              _ ->
                                                  Parameter = lists:last(Parameters),
                                                  case Parameter#parameter.name of
                                                      [] ->
                                                          ParameterNew = Parameter#parameter{name = String},
                                                          lists:droplast(Parameters) ++ [ParameterNew];
                                                      _ ->
                                                          ParameterNew = #parameter{name = String},
                                                          Parameters ++ [ParameterNew]
                                                  end
                                          end,
                          VersionNew = Version#version{parameters = ParametersNew},
                          lists:droplast(Versions) ++ [VersionNew]
                  end,
    FunctionNew = Function#function{versions = VersionsNew},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Pipelined"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    Versions = Function#function.versions,
    Version = lists:last(Versions),
    VersionNew = Version#version{pipelined = String},
    VersionsNew = lists:droplast(Versions) ++ [VersionNew],
    FunctionNew = Function#function{versions = VersionsNew},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Function", "Return", "DataType"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Functions = Package#package.functions,
    Function = lists:last(Functions),
    Versions = Function#function.versions,
    VersionsNew = case Versions of
                      [] ->
                          [#version{returnDataType = String}];
                      _ ->
                          Version = lists:last(Versions),
                          VersionNew = Version#version{returnDataType = String},
                          lists:droplast(Versions) ++ [VersionNew]
                  end,
    FunctionNew = Function#function{versions = VersionsNew},
    FunctionsNew = lists:droplast(Functions) ++ [FunctionNew],
    PackageNew = Package#package{functions = FunctionsNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAX Parser Events: characters: package 1/2.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "ManPage"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n",
        [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    PackageNew = Package#package{manPage = String},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "Name"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n",
        [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    ImplName = string:lowercase(String),
    Name = lists:flatten(string:split(ImplName, "_impl", trailing)),
    PackageNew = Package#package{name = Name, implName = ImplName},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAX Parser Events: characters: package & procedure.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "ApiGroupPrivilege", "ApiGroup"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    Procedure = lists:last(Procedures),
    ProcedureNew = Procedure#procedure{apiGroups = Procedure#procedure.apiGroups ++ [String]},
    ProceduresNew = lists:droplast(Procedures) ++ [ProcedureNew],
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "ApiGroupPrivilege", "Privilege", "Object"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    PackagePrivileges = Package#package.privileges,
    Privilege = lists:last(PackagePrivileges),
    PrivilegeNew = Privilege#privilege{object = String},
    ?I("Object privilege of type: ~p to object: ~p~n", [PrivilegeNew#privilege.type, PrivilegeNew#privilege.object]),
    PackagePrivilegesNew = lists:droplast(Package#package.privileges) ++ [PrivilegeNew],
    PackageNew = Package#package{privileges = PackagePrivilegesNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "ApiGroupPrivilege", "Privilege", "Type"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    PackagePrivileges = Package#package.privileges,
    PackagePrivilegesNew = case PackagePrivileges of
                               [] ->
                                   [#privilege{type = String}];
                               _ ->
                                   PackagePrivileges ++ [#privilege{type = String}]
                           end,
    case String of
        "ALTER" -> nop;
        "DEBUG" -> nop;
        "DELETE" -> nop;
        "EXECUTE" -> nop;
        "FLASHBACK ARCHIVE" -> nop;
        "INDEX" -> nop;
        "INHERIT PRIVILEGES" -> nop;
        "INHERIT REMOTE PRIVILEGES" -> nop;
        "INSERT" -> nop;
        "KEEP SEQUENCE" -> nop;
        "MERGE VIEW" -> nop;
        "ON COMMIT REFRESH" -> nop;
        "QUERY REWRITE" -> nop;
        "READ" -> nop;
        "REFERENCES" -> nop;
        "SELECT" -> nop;
        "TRANSLATE SQL" -> nop;
        "UNDER" -> nop;
        "UPDATE" -> nop;
        "USE" -> nop;
        "WRITE" -> nop;
        _ -> ?I("System privilege of type: ~p~n", [String])
    end,
    PackageNew = Package#package{privileges = PackagePrivilegesNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "ApiHidden"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    Procedure = lists:last(Procedures),
    ProcedureNew = Procedure#procedure{apiGroups = Procedure#procedure.apiGroups ++ ["hidden"], apiHidden = String},
    ProceduresNew = lists:droplast(Procedures) ++ [ProcedureNew],
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "Condition", "IfEnd"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    Procedure = lists:last(Procedures),
    Versions = Procedure#procedure.versions,
    Type = list_to_atom(string:casefold(lists:last(tuple_to_list(ParserState#parser_state.localNames)))),
    VersionsNew = Versions ++ [#version{condition = {Type, String}}],
    ProcedureNew = Procedure#procedure{versions = VersionsNew},
    ProceduresNew = lists:droplast(Procedures) ++ [ProcedureNew],
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "ManPage"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    Procedure = lists:last(Procedures),
    ProcedureNew = Procedure#procedure{manPage = String},
    ProceduresNew = lists:droplast(Procedures) ++ [ProcedureNew],
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "Name"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    ProceduresNew = case Procedures of
                        [] ->
                            [#procedure{name = String}];
                        _ ->
                            Procedure = lists:last(Procedures),
                            case String == Procedure#procedure.name of
                                true -> Procedures;
                                _ ->
                                    ProcedureNew = #procedure{name = String},
                                    Procedures ++ [ProcedureNew]
                            end
                    end,
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "Parameter", "DataType"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    Procedure = lists:last(Procedures),
    Versions = Procedure#procedure.versions,
    Version = lists:last(Versions),
    Parameters = Version#version.parameters,
    Parameter = lists:last(Parameters),
    ParameterNew = Parameter#parameter{dataType = String},
    ParametersNew = lists:droplast(Parameters) ++ [ParameterNew],
    VersionNew = Version#version{parameters = ParametersNew},
    VersionsNew = lists:droplast(Versions) ++ [VersionNew],
    ProcedureNew = Procedure#procedure{versions = VersionsNew},
    ProceduresNew = lists:droplast(Procedures) ++ [ProcedureNew],
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "Parameter", "DefaultValue", "Expression"};
         ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "Parameter", "DefaultValue", "String"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    Procedure = lists:last(Procedures),
    Versions = Procedure#procedure.versions,
    Version = lists:last(Versions),
    Parameters = Version#version.parameters,
    Parameter = lists:last(Parameters),
    Type = list_to_atom(string:casefold(lists:last(tuple_to_list(ParserState#parser_state.localNames)))),
    ParameterNew = Parameter#parameter{defaultValue = {Type, String}},
    ParametersNew = lists:droplast(Parameters) ++ [ParameterNew],
    VersionNew = Version#version{parameters = ParametersNew},
    VersionsNew = lists:droplast(Versions) ++ [VersionNew],
    ProcedureNew = Procedure#procedure{versions = VersionsNew},
    ProceduresNew = lists:droplast(Procedures) ++ [ProcedureNew],
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "Parameter", "Mode"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    Procedure = lists:last(Procedures),
    Versions = Procedure#procedure.versions,
    Version = lists:last(Versions),
    Parameters = Version#version.parameters,
    Parameter = lists:last(Parameters),
    ParameterNew = Parameter#parameter{mode = String},
    ParametersNew = lists:droplast(Parameters) ++ [ParameterNew],
    VersionNew = Version#version{parameters = ParametersNew},
    VersionsNew = lists:droplast(Versions) ++ [VersionNew],
    ProcedureNew = Procedure#procedure{versions = VersionsNew},
    ProceduresNew = lists:droplast(Procedures) ++ [ProcedureNew],
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({characters, String} = _Event, _Location, ParserState)
    when ParserState#parser_state.localNames == {"Package", "FunctionProcedure", "Procedure", "Parameter", "Name"} ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Package = ParserState#parser_state.package,
    Procedures = Package#package.procedures,
    Procedure = lists:last(Procedures),
    Versions = Procedure#procedure.versions,
    VersionsNew = case Versions of
                      [] ->
                          ParameterNew = #parameter{name = String},
                          ParametersNew = [ParameterNew],
                          VersionNew = #version{parameters = ParametersNew},
                          [VersionNew];
                      _ ->
                          Version = lists:last(Versions),
                          Parameters = Version#version.parameters,
                          ParametersNew = case Parameters of
                                              [] ->
                                                  ParameterNew = #parameter{name = String},
                                                  Parameters ++ [ParameterNew];
                                              _ ->
                                                  Parameter = lists:last(Parameters),
                                                  case Parameter#parameter.name of
                                                      [] ->
                                                          ParameterNew = Parameter#parameter{name = String},
                                                          lists:droplast(Parameters) ++ [ParameterNew];
                                                      _ ->
                                                          ParameterNew = #parameter{name = String},
                                                          Parameters ++ [ParameterNew]
                                                  end
                                          end,
                          VersionNew = Version#version{parameters = ParametersNew},
                          lists:droplast(Versions) ++ [VersionNew]
                  end,
    ProcedureNew = Procedure#procedure{versions = VersionsNew},
    ProceduresNew = lists:droplast(Procedures) ++ [ProcedureNew],
    PackageNew = Package#package{procedures = ProceduresNew},
    Result = ParserState#parser_state{package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAX Parser Events: endCDATA & endElement.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parser_event(endCDATA = _Event, _Location, ParserState) ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    ParserState;
parser_event({endElement, _Uri, _LocalName, _QualifiedName} = _Event, _Location, ParserState) ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Result = ParserState#parser_state{localNames = erlang:delete_element(size(ParserState#parser_state.localNames), ParserState#parser_state.localNames)},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAX Parser Events: startCDATA & startElement.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parser_event(startCDATA = _Event, _Location, ParserState) ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    ParserState;
parser_event({startElement, _Uri, "Package" = LocalName, _QualifiedName, _Attributes} = _Event, _Location, ParserState) ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    PackageNew = #package{},
    Result = ParserState#parser_state{localNames = erlang:append_element(ParserState#parser_state.localNames, LocalName), package = PackageNew},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;
parser_event({startElement, _Uri, LocalName, _QualifiedName, _Attributes} = _Event, _Location, ParserState) ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [_Event, _Location, ParserState]),
    Result = ParserState#parser_state{localNames = erlang:append_element(ParserState#parser_state.localNames, LocalName)},
    ?D("End~n ParserState: ~p~n", [Result]),
    Result;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAX Parser Events: unknown.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parser_event(Event, _Location, _ParserState) ->
    ?D("Start~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [Event, _Location, _ParserState]),
    ErrorMsg = "parser_event not supported",
    ?E("================================================================================~n", []),
    ?E("Error: ~p~n~n Event: ~p~n Location: ~p~n ParserState: ~p~n", [ErrorMsg, Event, _Location, _ParserState]),
    ?E("================================================================================~n", []),
    error(ErrorMsg).

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process the XML-Files.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

process_file(ParserState, [] = _PKSFile) ->
    ?D("Start~n ParserState: ~p~n PKSFiles: ~p~n", [ParserState, _PKSFile]),
    ok = Result = finalize(ParserState),
    ?D("End~n Result: ~p~n", [Result]),
    Result;
process_file(ParserState, [PKSFile | Tail]) ->
    ?D("Start~n ParserState: ~p~n PKSFile: ~p~n", [ParserState, PKSFile]),

    [_Base, Extension] = string:split(PKSFile, "."),

    case Extension == "pks" of
        true when Extension == "pks" ->
            ?I("================================================================================~n", []),
            ?I("Start processing file: ~s~n", [PKSFile]),
            ?I("--------------------------------------------------------------------------------~n", []),
            {ok, XMLDocument} = validate(PKSFile),
            ?D("XMLDocument: ~p~n", [XMLDocument]),

            {ok, ParserStateNew_1} = case xmerl_sax_parser:stream(XMLDocument,
                [
                    {event_fun, fun parser_event/3},
                    {event_state, ParserState#parser_state{}}
                ]) of
                                         {ok, Result, _Rest} ->
                                             {ok, Result};
                                         {Tag, _Location, Reason, _EndTags, RespMap} ->
                                             ErrorMsg = "sax parser problem",
                                             ?E("================================================================================~n", []),
                                             ?E("Error: ~p~n~n Tag: ~p~n Reason: ~p~n RespMap: ~p~n", [ErrorMsg, Tag, Reason, RespMap]),
                                             ?E("================================================================================~n", []),
                                             error(ErrorMsg);
                                         {_ = ErrorMsg, _ = Reason} ->
                                             ?E("================================================================================~n", []),
                                             ?E("Error: ~p~n~n Reason: ~p~n XMLDocument: ~p~n", [ErrorMsg, Reason, XMLDocument]),
                                             ?E("================================================================================~n", []),
                                             error(ErrorMsg)
                                     end,
            ?D("ParserStateNew_1: ~p~n", [ParserStateNew_1]),

            ?D("================================================================================~n", []),
            ?D("Package: ~p~n", [ParserStateNew_1#parser_state.package]),
            ?D("--------------------------------------------------------------------------------~n", []),

            ParserStateNew_2 = generate_file_package_based(ParserStateNew_1),
            ?D("ParserStateNew_2: ~p~n", [ParserStateNew_2]),

            ?I("--------------------------------------------------------------------------------~n", []),
            ?I("End   processing file: ~s~n", [PKSFile]),
            ?I("================================================================================~n", []),

            ParserStateNew_3 = ParserStateNew_2#parser_state{
                privileges = lists:sort(
                    sets:to_list(sets:from_list(ParserStateNew_2#parser_state.privileges ++ ParserStateNew_2#parser_state.package#package.privileges)))
            },

            process_file(ParserStateNew_3, Tail);
        _ -> process_file(ParserState, Tail)
    end.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the io types in the package body of SBSDB_LOGGER_LIB.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set_io_type() ->
    ?D("Start~n", []),
    FileNameSource = ?PATH_PACKAGES ++ "sbsdb_io_lib.pkb",
    ?D("FileNameSource: ~p~n", [FileNameSource]),
    FileNameTarget = ?PATH_PACKAGES ++ "sbsdb_io_lib.pkb_copy",
    ?D("FileNameTarget: ~p~n", [FileNameTarget]),
    {ok, _BytesCopied} = file:copy(FileNameSource, FileNameTarget),
    ?D("BytesCopied: ~p~n", [_BytesCopied]),
    {ok, IoDeviceSource} = file:open(FileNameSource, [write]),
    {ok, IoDeviceTarget} = file:open(FileNameTarget, [read]),
    {ok, MPLog} = re:compile("^[\040]*(g_io_type_log)[\040]+(sbsdb_type_lib\.oracle_name_t)[\040]+(:=)[\040]+"),
    {ok, MPProperty} = re:compile("^[\040]*(g_io_type_property)[\040]+(sbsdb_type_lib\.oracle_name_t)[\040]+(:=)[\040]+"),
    set_io_type_lines(IoDeviceSource, IoDeviceTarget, MPLog, MPProperty),
    ok = file:close(IoDeviceSource),
    ok = file:close(IoDeviceTarget),
    ok = Result = file:delete(FileNameTarget),
    ?D("End~n Result: ~p~n", [Result]),
    Result.

set_io_type_lines(IoDeviceSource, IoDeviceTarget, MPLog, MPProperty) ->
    ?D("Start~n IoDeviceSource: ~p~n IoDeviceTarget: ~p~n MPLog: ~p~n MPProperty: ~p~n", [IoDeviceSource, IoDeviceTarget, MPLog, MPProperty]),
    case io:get_line(IoDeviceTarget, "") of
        eof -> [];
        Line -> case re:run(Line, MPLog) of
                    nomatch ->
                        case re:run(Line, MPProperty) of
                            nomatch ->
                                io:format(IoDeviceSource, "~s", [Line]);
                            _ ->
                                io:format(IoDeviceSource, "~s~n", [lists:append([
                                    "    g_io_type_property             sbsdb_type_lib.oracle_name_t := '",
                                    atom_to_list(?IO_TYPE_PROPERTY),
                                    "';"
                                ])])
                        end;
                    _ ->
                        io:format(IoDeviceSource, "~s~n", [lists:append([
                            "    g_io_type_log                  sbsdb_type_lib.oracle_name_t := '",
                            atom_to_list(?IO_TYPE_LOG),
                            "';"
                        ])])
                end,
            set_io_type_lines(IoDeviceSource, IoDeviceTarget, MPLog, MPProperty)
    end.

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Validate an XML-File.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

validate(PKSFile) ->
    ?D("Start~n PKSFile: ~p~n", [PKSFile]),

    ?D("PATH_PACKAGES: ~p~n", [?PATH_PACKAGES]),
    {ok, BinSource} = file:read_file(?PATH_PACKAGES ++ PKSFile),
    ?D("BinSource: ~p~n", [BinSource]),

    case plsql_parser:parsetree(binary_to_list(BinSource)) of
        {ok, ParseTree} ->
            ?D("ParseTree: ~p~n", [ParseTree]),

            BinXMLDocument = case plsql_parser_fold:top_down(
                plsql_parser_format_dbss, ParseTree, []) of
                                 {error, Reason_1} ->
                                     ErrorMsg_1 = "Error ParseTree ==> Source_FORMAT",
                                     ?E("================================================================================~n", []),
                                     ?E("Error: ~p~n~n Reason: ~p~n Source: ~s~n ParseTree: ~p~n", [ErrorMsg_1, Reason_1, BinSource, ParseTree]),
                                     ?E("================================================================================~n", []),
                                     error(ErrorMsg_1);
                                 NS_FORMAT -> NS_FORMAT
                             end,

            XMLDocument = lists:flatten(binary_to_list(BinXMLDocument)),
            ?D("XMLDocument: ~p~n", [XMLDocument]),

            {XMLElem1, _} = xmerl_scan:string(XMLDocument),
            ?D("PATH_XSD: ~p~n FILE_XSD: ~p~n", [?PATH_XSD, ?FILE_XSD]),

            {ok, GlobalState} = xmerl_xsd:process_schema(?PATH_XSD ++ ?FILE_XSD),
            {ok = Result, _} = case xmerl_xsd:validate(XMLElem1, GlobalState) of
                                   {XMLElem2, _} when XMLElem2 /= error ->
                                       {ok, XMLElem2};
                                   {error, Reason} ->
                                       ErrorMsg = "schema validation problem",
                                       ?E("================================================================================~n", []),
                                       ?E("Error: ~p~n~n Reason: ~p~n", [ErrorMsg, Reason]),
                                       ?E("================================================================================~n", []),
                                       error(ErrorMsg)
                               end,

            ?D("End~n Result: ~p~n Result: ~p~n", [Result, XMLDocument]),
            {Result, XMLDocument};
        {lex_error, Reason} ->
            ErrorMsg = "Failed lex_error",
            ?E("================================================================================~n", []),
            ?E("Error: ~p~n~n Reason: ~p~n Source: ~s~n", [ErrorMsg, Reason, BinSource]),
            ?E("================================================================================~n", []),
            error(ErrorMsg);
        {parse_error, {Reason, Tokens}} ->
            ErrorMsg = "Failed parse_error",
            ?E("================================================================================~n", []),
            ?E("Error: ~p~n~n Reason: ~p~n Source: ~s~n Tokens: ~p~n", [ErrorMsg, Reason, BinSource, Tokens]),
            ?E("================================================================================~n", []),
            error(ErrorMsg)
    end.


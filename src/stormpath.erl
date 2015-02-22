-module(stormpath).

-export([login/2, create_user/1]).

login(Email, Password) ->
    Uri = get_stormpath_uri(<<"/loginAttempts">>),
    ReqBody = #{type => <<"basic">>, value => base64:encode(<<Email/binary, ":", Password/binary>>)},
    ReqJson = jiffy:encode(ReqBody),
    {ok, StatusCode, _, ClientRef} = stormpath_request(post, Uri, ReqJson),
    {ok, RespBody} = hackney:body(ClientRef),
    RespJson = jiffy:decode(RespBody, [return_maps]),
    case StatusCode of
        200 ->
            get_user_info(RespJson);
        400 ->
            get_error_message(RespJson);
        _ ->
            generic_error()
    end.

get_user_info(Json) ->
    Account = maps:get(<<"account">>, Json),
    Href = maps:get(<<"href">>, Account),
    {ok, StatusCode, _, ClientRef} = stormpath_request(get, Href, <<>>),
    {ok, RespBody} = hackney:body(ClientRef),
    RespJson = jiffy:decode(RespBody, [return_maps]),
    case StatusCode of
        200 ->
            {ok, RespJson};
        400 ->
            get_error_message(RespJson);
        _ ->
            generic_error()
    end.

create_user(UserInfo) ->
    Uri = get_stormpath_uri(<<"/accounts">>),
    ReqJson = jiffy:encode(UserInfo),
    {ok, StatusCode, _, ClientRef} = stormpath_request(post, Uri, ReqJson),
    {ok, RespBody} = hackney:body(ClientRef),
    RespJson = jiffy:decode(RespBody, [return_maps]),
    case StatusCode of
        201 ->
            {ok, RespJson};
        400 ->
            get_error_message(RespJson);
        409 ->
            get_error_message(RespJson);
        _ ->
            generic_error()
    end.

get_credentials() ->
    {ok, ApiKey} = get_env_var("STORMPATH_API_KEY"),
    {ok, ApiSecret} = get_env_var("STORMPATH_API_SECRET"),
    {ok, ApiKey, ApiSecret}.

get_application_id() ->
    get_env_var("STORMPATH_APP_ID").

get_stormpath_uri(Resource) ->
    {ok, ApplicationId} = get_application_id(),
    <<"https://api.stormpath.com/v1/applications/", ApplicationId/binary, Resource/binary>>.

get_env_var(Name) ->
    case os:getenv(Name) of
        false -> false;
        Var -> {ok, list_to_binary(Var)}
    end.

stormpath_request(Method, Uri, Body) ->
    {ok, ApiKey, ApiSecret} = get_credentials(),
    Headers = [{<<"Accept">>, <<"application/json">>}, {<<"Content-Type">>, <<"application/json">>}],
    Options = [{pool, default}, {basic_auth, {ApiKey, ApiSecret}}],
    hackney:request(Method, Uri, Headers, Body, Options).

get_error_message(Json) ->
    Message = maps:get(<<"message">>, Json),
    {error, Message}.

generic_error() ->
    {error, <<"This is a generic error message">>}.

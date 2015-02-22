-module(stormpath).

-export([login/2, create_user/1]).

login(Email, Password) ->
    ApiKey = list_to_binary(os:getenv("STORMPATH_API_KEY")),
    ApiSecret = list_to_binary(os:getenv("STORMPATH_API_SECRET")),
    ApplicationId = list_to_binary(os:getenv("STORMPATH_APP_ID")),
    Uri = <<"https://api.stormpath.com/v1/applications/", ApplicationId/binary, "/loginAttempts">>,
    Headers = [{<<"Accept">>, <<"application/json">>}, {<<"Content-Type">>, <<"application/json">>}],
    ReqBody = #{type => <<"basic">>, value => base64:encode(<<Email/binary, ":", Password/binary>>)},
    ReqJson = jiffy:encode(ReqBody),
    Options = [{pool, default}, {basic_auth, {ApiKey, ApiSecret}}],
    {ok, StatusCode, _, ClientRef} = hackney:post(Uri, Headers, ReqJson, Options),
    {ok, RespBody} = hackney:body(ClientRef),
    RespJson = jiffy:decode(RespBody, [return_maps]),
    case StatusCode of
        200 ->
            Account = maps:get(<<"account">>, RespJson),
            Href = maps:get(<<"href">>, Account),
            {ok, StatusCode2, _, ClientRef2} = hackney:get(Href, [], <<>>, Options),
            {ok, RespBody2} = hackney:body(ClientRef2),
            RespJson2 = jiffy:decode(RespBody2, [return_maps]),
            case StatusCode2 of
                200 ->
                    {ok, RespJson2};
                _ ->
                    Message = maps:get(<<"message">>, RespJson2),
                    {error, StatusCode2, Message}
            end;
        _ ->
            Message = maps:get(<<"message">>, RespJson),
            {error, StatusCode, Message}
    end.

create_user(UserInfo) ->
    ApiKey = list_to_binary(os:getenv("STORMPATH_API_KEY")),
    ApiSecret = list_to_binary(os:getenv("STORMPATH_API_SECRET")),
    ApplicationId = list_to_binary(os:getenv("STORMPATH_APP_ID")),
    Uri = <<"https://api.stormpath.com/v1/applications/", ApplicationId/binary, "/accounts">>,
    Headers = [{<<"Accept">>, <<"application/json">>}, {<<"Content-Type">>, <<"application/json">>}],
    ReqJson = jiffy:encode(UserInfo),
    Options = [{pool, default}, {basic_auth, {ApiKey, ApiSecret}}],
    {ok, StatusCode, _, ClientRef} = hackney:post(Uri, Headers, ReqJson, Options),
    {ok, RespBody} = hackney:body(ClientRef),
    RespJson = jiffy:decode(RespBody, [return_maps]),
    case StatusCode of
        201 ->
            {ok, RespJson};
        _ ->
            Message = maps:get(<<"message">>, RespJson),
            {error, StatusCode, Message}
    end.

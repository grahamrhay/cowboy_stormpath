-module(login_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {}).

init(_, Req, _Opts) ->
    {ok, Req, #state{}}.

handle(Req, State=#state{}) ->
    {Method, _} = cowboy_req:method(Req),
    case Method of
        <<"GET">> ->
            {ok, Body} = login_dtl:render(),
            {ok, Reply} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req),
            {ok, Reply, State};
        <<"POST">> ->
            {ok, Body, Req2} = cowboy_req:body_qs(Req),
            Email = proplists:get_value(<<"email">>, Body),
            Password = proplists:get_value(<<"password">>, Body),
            case stormpath:login(Email, Password) of
                {ok, UserInfo} ->
                    {ok, Req3} = cowboy_session:set(<<"user">>, UserInfo, Req2),
                    {ok, Reply} = cowboy_req:reply(302, [{<<"Location">>, <<"/user/info">>}], Req3),
                    {ok, Reply, State};
                {error, _, Error} ->
                    {ok, Body2} = login_dtl:render([{error, Error}, {email, Email}]),
                    {ok, Reply} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body2, Req),
                    {ok, Reply, State}
            end
    end.

terminate(_Reason, _Req, _State) ->
    ok.

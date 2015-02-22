-module(user_info_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {}).

init(_, Req, _Opts) ->
    {ok, Req, #state{}}.

handle(Req, State=#state{}) ->
    {Method, _} = cowboy_req:method(Req),
    {ok, Reply} = handle_req(Method, Req),
    {ok, Reply, State}.

handle_req(<<"GET">>, Req) ->
    {User, Req2} = cowboy_session:get(<<"user">>, Req),
    case User of
        undefined ->
            cowboy_req:reply(302, [{<<"Location">>, <<"/login">>}], Req2);
        _ ->
            {ok, Body} = user_info_dtl:render(User),
            cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2)
    end;

handle_req(_, Req) ->
    cowboy_req:reply(405, [], Req).

terminate(_Reason, _Req, _State) ->
    ok.

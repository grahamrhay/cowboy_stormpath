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
    case Method of
        <<"GET">> ->
            {User, Req2} = cowboy_session:get(<<"user">>, Req),
            case User of
                undefined ->
                    {ok, Reply} = cowboy_req:reply(302, [{<<"Location">>, <<"/login">>}], Req2),
                    {ok, Reply, State};
                _ ->
                    {ok, Body} = user_info_dtl:render(maps:to_list(User)),
                    {ok, Reply} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body, Req2),
                    {ok, Reply, State}
            end;
        _ ->
            {ok, Reply} = cowboy_req:reply(405, [], Req),
            {ok, Reply, State}
    end.

terminate(_Reason, _Req, _State) ->
    ok.

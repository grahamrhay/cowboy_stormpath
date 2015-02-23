-module(logout_handler).
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

handle_req(<<"POST">>, Req) ->
    {ok, Req2} = cowboy_session:expire(Req),
    redirect_to(<<"/">>, Req2);

handle_req(_, Req) ->
    cowboy_req:reply(405, [], Req).

redirect_to(Location, Req) ->
    cowboy_req:reply(302, [{<<"Location">>, Location}], Req).

terminate(_Reason, _Req, _State) ->
    ok.

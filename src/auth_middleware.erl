-module(auth_middleware).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->
    {Path, _} = cowboy_req:path(Req),
    check_path(Path, Req, Env).

check_path(<<"/user/", _/binary>>, Req, Env) ->
    case logged_in(Req) of
        false ->
            redirect_to(<<"/login">>, Req);
        _ ->
            {ok, Req, Env}
    end;

check_path(_, Req, Env) ->
    {ok, Req, Env}.

logged_in(Req) ->
    {User, _} = cowboy_session:get(<<"user">>, Req),
    case User of
        undefined -> false;
        _ -> true
    end.

redirect_to(Location, Req) ->
    {ok, Req2} = cowboy_req:reply(302, [{<<"Location">>, Location}], Req),
    {halt, Req2}.

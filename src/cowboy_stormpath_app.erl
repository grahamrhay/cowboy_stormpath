-module(cowboy_stormpath_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", cowboy_static, {priv_file, cowboy_stormpath, "static/index.html"}},
            {"/[...]", cowboy_static, {priv_dir, cowboy_stormpath, "static/"}}
        ]}
    ]),
    {ok, _} = cowboy:start_http(my_http_listener, 100, [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
    ),
    cowboy_stormpath_sup:start_link().

stop(_State) ->
    ok.

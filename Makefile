PROJECT = cowboy_stormpath
EUNIT_DIR=test
DEPS = cowboy erlydtl hackney jiffy cowboy_session
dep_hackney = git https://github.com/benoitc/hackney.git 1.0.6
dep_cowboy_session = git https://github.com/chvanikoff/cowboy_session.git master
include erlang.mk

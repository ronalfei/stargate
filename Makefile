PROJECT = stargate 
DEPS = ranch lager poolboy
dep_ranch = git https://github.com/ninenines/ranch.git 1.2.1
dep_lager = git https://github.com/basho/lager.git 2.2.3
dep_poolboy = git https://github.com/devinus/poolboy.git 1.5.1
include erlang.mk

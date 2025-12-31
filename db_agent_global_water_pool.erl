%%%--------------------------------------
%%% @Module  : db_agent_global_water_pool
%%% @Author  :
%%% @Created :
%%% @Description: 
%%%--------------------------------------
-module(db_agent_global_water_pool).

-include("common.hrl").
-include("record.hrl").

-define(TABLE_NAME, water_pool).

-compile(export_all).


%% 获取所有水池值
load_all_golbal_water_pool() ->
    ?DB_MODULE:select_all(?TABLE_NAME, "pool_name, value", []).

%% 保存所有水池值
save_all_global_water_pool(PoolList) ->
    [
    	begin
    		PoolNameStr = util:term_to_string(PoolName),
    		?DB_MODULE:replace(?TABLE_NAME, [{pool_name, PoolNameStr}, {value, Value}])
    	end || {PoolName, Value} <- PoolList
    ].
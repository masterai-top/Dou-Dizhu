%%%--------------------------------------
%%% @Module  : db_agent_id_global
%%% @Author  :
%%% @Created :
%%% @Description: 
%%%--------------------------------------
-module(db_agent_id_global).

-include("common.hrl").
-include("record.hrl").

-define(TABLE_NAME, id_global).

-compile(export_all).

%% 获取所有globalId
load_id_global() ->
    ?DB_MODULE:select_all(?TABLE_NAME, "id_kind, id_value", [{id_value, ">", 1}, {sid, ?SERVER_ID}]).

%% 全球 ID 数据存档
save_id_global(Kind, Id) ->
    StrKind = util:term_to_string(Kind),
    ?DB_MODULE:replace(?TABLE_NAME, [{id_kind, StrKind}, {sid, ?SERVER_ID}, {id_value, Id}]).


%% 获取最大的玩家id
get_max_player_id(ServerID) ->
	case ?DB_MODULE:select_row(player, "max(id)", [{server_id, ServerID}], [], [1]) of
		[MaxID] when is_integer(MaxID) -> MaxID;
		_ -> 0
	end.

%% 获取最大的物品id
get_max_table_id(Table) ->
	case ?DB_MODULE:select_row(Table, "max(id)", [], [], [1]) of
		[MaxID] when is_integer(MaxID) -> MaxID;
		_ -> 0
	end.







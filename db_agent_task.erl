%%%--------------------------------------
%%% @Module  : db_agent_task
%%% @Author  : xws
%%% @Created : 2016.10.10
%%% @Description:
%%%--------------------------------------
-module(db_agent_task).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("task.hrl").

-define(TABLE_NAME, player_task).
-define(RECORD_NAME, player_task).

-compile(export_all).

%% 获取玩家任务数据
get_player_task_data(PlayerId) ->
	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			lib_task:init_task_data(PlayerId);
		ValueList ->
			PlayerShop = list_to_tuple([?TABLE_NAME|ValueList]),
			decode_data(PlayerShop)
	end.

%% 更新玩家任务数据
update_player_task(PlayerTask) ->
    PlayerTask1 = encode_data(PlayerTask),
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerTask1)),
    ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

encode_data(Data) ->
	String1 = util:term_to_string(Data#player_task.daily_task_list),
	String2 = util:term_to_string(Data#player_task.challenge_task),
	String3 = util:term_to_string(Data#player_task.now_dayN_task),
	String4 = util:term_to_string(Data#player_task.picked_liveness_id_list),
	String5 = util:term_to_string(Data#player_task.challenge_task_list),
	String6 = util:term_to_string(Data#player_task.newbie_task_list),
	String7 = util:term_to_string(Data#player_task.cyclic_task_list),
	String8 = util:term_to_string(Data#player_task.week_task_list),
	String9 = util:term_to_string(Data#player_task.poke_draw_award_task_list),
	String10 = util:term_to_string(Data#player_task.poke_draw_award_list),
	String11 = util:term_to_string(Data#player_task.poke_cyclic_task_list),
	String12 = util:term_to_string(Data#player_task.task_list),
	Data#player_task{
		daily_task_list = String1, 
		challenge_task = String2,
		now_dayN_task = String3,
		picked_liveness_id_list = String4,
		challenge_task_list = String5,
		newbie_task_list = String6,
		cyclic_task_list = String7,
		week_task_list = String8,
		poke_draw_award_task_list = String9,
		poke_draw_award_list = String10,
		poke_cyclic_task_list = String11,
		task_list = String12
	}.

decode_data(Data) ->
	Term1 = util:bitstring_to_term(Data#player_task.daily_task_list),
	Term2 = util:bitstring_to_term(Data#player_task.challenge_task),
	Term3 = util:bitstring_to_term(Data#player_task.now_dayN_task),
	Term4 = util:bitstring_to_term(Data#player_task.picked_liveness_id_list),
	Term5 = util:bitstring_to_term(Data#player_task.challenge_task_list),
	Term6 = util:bitstring_to_term(Data#player_task.newbie_task_list),
	Term7 = util:bitstring_to_term(Data#player_task.cyclic_task_list),
	Term8 = util:bitstring_to_term(Data#player_task.week_task_list),
	String9 = util:bitstring_to_term(Data#player_task.poke_draw_award_task_list),
	String10 = util:bitstring_to_term(Data#player_task.poke_draw_award_list),
	String11 = util:bitstring_to_term(Data#player_task.poke_cyclic_task_list),
	String12 = util:bitstring_to_term(Data#player_task.task_list),
	Data#player_task{
		daily_task_list = Term1, 
		challenge_task = Term2,
		now_dayN_task = Term3,
		picked_liveness_id_list = Term4,
		challenge_task_list = Term5,
		newbie_task_list = Term6,
		cyclic_task_list = Term7,
		week_task_list = Term8,
		poke_draw_award_task_list = String9,
		poke_draw_award_list = String10,
		poke_cyclic_task_list = String11,
		task_list = String12
	}.
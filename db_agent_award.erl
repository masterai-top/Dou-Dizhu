%%%--------------------------------------
%%% @Module  : db_agent_award
%%% @Author  : xws
%%% @Created : 2016.09.14
%%% @Description:
%%%--------------------------------------
-module(db_agent_award).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("award.hrl").
-include("operaty.hrl").

-define(TABLE_NAME, player_award).
-define(RECORD_NAME, player_award).

-compile(export_all).

%% 获取玩家奖励数据
get_player_award_data(PlayerId) ->
	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			init_data(PlayerId);
		ValueList ->
			Data = list_to_tuple([?TABLE_NAME|ValueList]),
			decode_data(Data)
	end.

%% 更新玩家奖励数据
update_player_award(PlayerAward) ->
    PlayerAward1 = encode_data(PlayerAward),
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerAward1)),
    ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

init_data(PlayerId) ->
	Data = #player_award{player_id = PlayerId, next_refresh_day = util:now_days() + 1},
	update_player_award(Data),
	Data.

encode_data(Data) ->
	Data.

decode_data(Data) ->
	Data.



%% =========================运营活动===================================

%% 获取运营活动数据
get_operaty_award_data(UID, Nick) ->
	case ?DB_MODULE:select_row(operaty_award, "*", [{uid, UID}], [], [1]) of
		[] ->
			init_operaty_data(UID, Nick);
		ValueList ->
			Data = list_to_tuple([operaty_award|ValueList]),
			OperatyAward = decode_operaty_data(Data),
			if
				length(OperatyAward#operaty_award.nick) =< 0 ->		
				%%length(OperatyAward#operaty_award.nick) =< 0 orelse size(OperatyAward#operaty_award.nick) =< 0 ->		
					OperatyAward1 = OperatyAward#operaty_award{nick = Nick},
					%%update_operaty_data(OperatyAward1),
					OperatyAward1;
				true ->					
					OperatyAward
			end
	end.

%% 获取所以运营互动数据
get_all_operaty_data(ConditionList) ->
	AllData = ?DB_MODULE:select_all(operaty_award, "*", ConditionList),
	F = fun(L) ->
			Data = list_to_tuple([operaty_award|L]),
			decode_operaty_data(Data)
		end,
	[F(Data) || Data <- AllData].

%% 更新运营活动数据
update_operaty_data(OperatyAward) ->
    OperatyAward1 = encode_operaty_data(OperatyAward),
    ValueList = erlang:tl(erlang:tuple_to_list(OperatyAward1)),
    ?DB_MODULE:replace(operaty_award, record_info(fields, operaty_award), ValueList).

%% 初始化运营活动数据
init_operaty_data(UID, Nick) ->
	Data = #operaty_award{uid = UID, nick = Nick},
	update_operaty_data(Data),
	Data.
	
encode_operaty_data(Data) ->
	Data#operaty_award{nick = tool:to_binary(Data#operaty_award.nick),
					   online_reward = util:term_to_bitstring(Data#operaty_award.online_reward),
					   lucky_fund = util:term_to_bitstring(Data#operaty_award.lucky_fund),
					   compose_reward = util:term_to_bitstring(Data#operaty_award.compose_reward),
					   game_share_reward = util:term_to_bitstring(Data#operaty_award.game_share_reward),
					   open_fire = util:term_to_bitstring(Data#operaty_award.open_fire),
					   box_treasure_rank = util:term_to_bitstring(Data#operaty_award.box_treasure_rank),
					   newbie_rebate_reward = util:term_to_bitstring(Data#operaty_award.newbie_rebate_reward),
					   herocraft_twice = util:term_to_bitstring(Data#operaty_award.herocraft_twice)
					  }.

decode_operaty_data(Data) ->
	Data#operaty_award{nick = erlang:binary_to_list(Data#operaty_award.nick),
					   online_reward = util:bitstring_to_term(Data#operaty_award.online_reward),
					   lucky_fund = util:bitstring_to_term(Data#operaty_award.lucky_fund),
					   compose_reward = util:bitstring_to_term(Data#operaty_award.compose_reward),
					   game_share_reward = util:bitstring_to_term(Data#operaty_award.game_share_reward),
					   open_fire = util:bitstring_to_term(Data#operaty_award.open_fire),
					   box_treasure_rank = util:bitstring_to_term(Data#operaty_award.box_treasure_rank),
					   newbie_rebate_reward = util:bitstring_to_term(Data#operaty_award.newbie_rebate_reward),
					   herocraft_twice = util:bitstring_to_term(Data#operaty_award.herocraft_twice)
					  }.


%% 获取所有运营活动数据  运营统计用
get_all_operaty_data() ->
	AllData = ?DB_MODULE:select_all(operaty_award, "*", [{lucky_fund, "!=", "[]"}]),
	F = fun(L) ->
			Data = list_to_tuple([operaty_award|L]),
			decode_operaty_data(Data)
		end,
	DataList = [F(Data) || Data <- AllData],
	count_num(DataList, 0, 0, 0, 0, 0, 0).

count_num([], NewAcc1, NewAcc2, NewAcc3, NewAcc4, NewAcc5, NewAcc6) ->
	[NewAcc1, NewAcc2, NewAcc3, NewAcc4, NewAcc5, NewAcc6];
count_num([Operaty | Record], Acc1, Acc2, Acc3, Acc4, Acc5, Acc6) ->
	LuckyFund = Operaty#operaty_award.lucky_fund,
	case length(LuckyFund) of
		6 ->
			NewAcc1 = Acc1 + 1,
			NewAcc2 = Acc2 + 1,
			NewAcc3 = Acc3 + 1,
			NewAcc4 = Acc4 + 1,
			NewAcc5 = Acc5 + 1,
			NewAcc6 = Acc6 + 1;
		5 ->
			NewAcc1 = Acc1 + 1,
			NewAcc2 = Acc2 + 1,
			NewAcc3 = Acc3 + 1,
			NewAcc4 = Acc4 + 1,
			NewAcc5 = Acc5 + 1,
			NewAcc6 = Acc6;
		4 ->
			NewAcc1 = Acc1 + 1,
			NewAcc2 = Acc2 + 1,
			NewAcc3 = Acc3 + 1,
			NewAcc4 = Acc4 + 1,
			NewAcc5 = Acc5,
			NewAcc6 = Acc6;
		3 ->
			NewAcc1 = Acc1 + 1,
			NewAcc2 = Acc2 + 1,
			NewAcc3 = Acc3 + 1,
			NewAcc4 = Acc4,
			NewAcc5 = Acc5,
			NewAcc6 = Acc6;
		2 ->
			NewAcc1 = Acc1 + 1,
			NewAcc2 = Acc2 + 1,
			NewAcc3 = Acc3,
			NewAcc4 = Acc4,
			NewAcc5 = Acc5,
			NewAcc6 = Acc6;
		1 ->
			NewAcc1 = Acc1 + 1,
			NewAcc2 = Acc2,
			NewAcc3 = Acc3,
			NewAcc4 = Acc4,
			NewAcc5 = Acc5,
			NewAcc6 = Acc6;
		_ ->
			NewAcc1 = Acc1,
			NewAcc2 = Acc2,
			NewAcc3 = Acc3,
			NewAcc4 = Acc4,
			NewAcc5 = Acc5,
			NewAcc6 = Acc6
	end,
	count_num(Record, NewAcc1, NewAcc2, NewAcc3, NewAcc4, NewAcc5, NewAcc6).






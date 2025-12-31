%%%--------------------------------------
%%% @Module  : db_agent_rank
%%% @Author  : smyx
%%% @Created : 2013.08.15 
%%% @Description:  排行榜系统数据库操作
%%%--------------------------------------
-module(db_agent_rank).
-include("common.hrl").
-include("record.hrl").
-include("rank.hrl").
-compile(export_all).

% %%等级排行sql
% -define(SQL_LOG_LV_RANK_LIMIT,      "select id,nick,level,vip,`force` from player order by level desc , exp desc , id asc limit ~p;").

% %%战斗力排行sql
% -define(SQL_LOG_BATTLE_RANK_LIMIT,  "select id,nick,level,vip,`force` from player order by `force` desc, id asc limit ~p;").

% %%竞技场名次排行sql
% -define(SQL_LOG_ARENA_RANK_LIMIT,   "select a.uid,a.nick,p.`level`,p.vip,a.rank FROM arena a LEFT JOIN  player p ON  a.uid = p.id  WHERE  a.rank < 1001  order by a.rank asc limit ~p;").

% %%爬塔层次排名
% -define(SQL_LOG_TOWER_RANK_LIMIT, "select p.id,p.nick,p.level,p.vip,t.floors from player  p right JOIN  tower  t on   p.id  =  t.uid where t.floors>0 order by t.floors desc, p.id asc limit ~p;").

%% 兑换排行榜
-define(SQL_EXCHANGE_RANK, "select a.id, a.exchange_value, a.nick, a.vip, a.facelook, a.coin, a.gold, a.win_num, a.lose_num, b.buy_history_list from player as a inner join player_shop as b on a.id = b.player_id order by a.exchange_value desc limit ~p").

%% 红黑今日盈利排行榜
-define(SQL_RB_DAY_WIN_RANK, "select a.id, b.total_coin, a.nick, a.facelook, a.vip from player as a inner join player_redblack_day_win as b on a.id = b.player_id order by b.total_coin desc limit ~p").

%% 红黑今日押注排行榜
-define(SQL_RB_DAY_YAZHU_RANK, "select a.id, b.total_coin, a.nick, a.facelook, a.vip from player as a inner join player_redblack_day_stake as b on a.id = b.player_id order by b.total_coin desc limit ~p").

%% 红黑今周盈利排行榜
-define(SQL_RB_WEEK_WIN_RANK, "select a.id, b.total_coin, a.nick, a.facelook, a.vip from player as a inner join player_redblack_week_win as b on a.id = b.player_id order by b.total_coin desc limit ~p").

%% 金币排行榜
-define(SQL_COIN_RANK, "select id, coin, nick, vip, facelook,signature from player ORDER BY coin desc limit ~p").

%% 胜率排行榜
-define(SQL_WIN_RATE_RANK, "select id, win_num/(win_num + lose_num) as rate, nick, vip, facelook from player where win_num > 0 and lose_num > 0 and win_num + lose_num >= 200 ORDER BY rate desc limit ~p").

%% 充值排行榜
-define(SQL_RECHARGE_RANK, "select a.id, b.total_money, a.nick, a.facelook, a.vip, b.last_reset_time from player as a inner join player_recharge as b on a.id = b.player_id 
						where b.total_money > 0 and FROM_UNIXTIME(b.last_reset_time,'%Y%m%d') = ~p order by b.total_money desc limit ~p").

% %%获取排行榜等级列表
% select_level_rank()->
% 	Sql = io_lib:format(?SQL_SELECT_LV_RANK_LIMIT, [?TOTAL_SIZE]),
% 	?DB_MODULE:select_all(player, Sql).

% %%获取排行榜战斗力列表
% select_battle_rank()->
% 	Sql = io_lib:format(?SQL_SELECT_BATTLE_RANK_LIMIT, [?TOTAL_SIZE]),
% 	?DB_MODULE:select_all(player, Sql).
 




% %%插入排行榜各类型数据
% insert_rank(VauleList) ->
% 	FieldList = record_info(fields, rank),
% 	?DB_MODULE:insert(rank,FieldList,VauleList).

% %%获取排行榜爬塔层次列表
% select_tower_rank() ->
% 	Sql = io_lib:format(?SQL_SELECT_TOWER_RANK_LIMIT, [?TOTAL_SIZE]),
% 	?DB_MODULE:select_all(tower,Sql).

%% 获取玩家排行榜数据
get_player_rank_data(PlayerId) ->
	case ?DB_MODULE:select_row(player_rank, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			#player_rank{player_id = PlayerId};
		ValueList ->
			PlayerRank = list_to_tuple([player_rank|ValueList]),
			decode_data(PlayerRank)
	end.

%% 更新玩家排行榜数据
update_player_rank_data(PlayerRank) ->
	PlayerRank1 = encode_data(PlayerRank),
	ValueList = erlang:tl(erlang:tuple_to_list(PlayerRank1)),
    ?DB_MODULE:replace(player_rank, record_info(fields, player_rank), ValueList).


encode_data(Data) ->
	String = util:term_to_string(Data#player_rank.picked_list),
	Data#player_rank{picked_list = String}.

decode_data(Data) ->
	Term = util:bitstring_to_term(Data#player_rank.picked_list),
	Data#player_rank{picked_list = Term}.

%% 加载中心服所有排行榜数据
load_center_all_rank() ->
	case ?DB_MODULE:select_all(rank_center, "*", []) of
		[] ->
			[];
		ValueList ->
			[
				begin
					{RankType, Ranklist} = list_to_tuple(ValueItem),
					Ranklist1 = util:bitstring_to_term(Ranklist),
					{RankType, Ranklist1}
				end || ValueItem <- ValueList
			]
	end.

%% 更新排行榜数据
update_center_rank(RankType, Ranklist) ->
	Ranklist1 = util:term_to_string(Ranklist),
    ?DB_MODULE:replace(rank_center, [rank_type, rank_list], [RankType, Ranklist1]).


%% 获取兑换排行榜排行榜
select_exchange_rank(Size) ->
	Sql = io_lib:format(?SQL_EXCHANGE_RANK, [Size]),
	List = ?DB_MODULE:select_all(player, Sql),
	[
		begin
			{Id, TotalCoin, Nick, Vip, Facelook, Coin, Gold, WinNum, LoseNum, util:bitstring_to_term(BuyHis)}
		end || [Id, TotalCoin, Nick, Vip, Facelook, Coin, Gold, WinNum, LoseNum, BuyHis] <- List
	].

%% 获取红黑今日盈利榜
select_redblack_day_win_rank(Size) ->
	Sql = io_lib:format(?SQL_RB_DAY_WIN_RANK, [Size]),
	List = ?DB_MODULE:select_all(player, Sql),
	[
		begin
			{Id, TotalCoin, Nick, Facelook, Vip}
		end || [Id, TotalCoin, Nick, Facelook, Vip] <- List
	].

%% 获取红黑今日押注榜
select_redblack_day_yazhu_rank(Size) ->
	Sql = io_lib:format(?SQL_RB_DAY_YAZHU_RANK, [Size]),
	List = ?DB_MODULE:select_all(player, Sql),
	[
		begin
			{Id, TotalCoin, Nick, Facelook, Vip}
		end || [Id, TotalCoin, Nick, Facelook, Vip] <- List
	].

%% 获取红黑今周盈利榜
select_redblack_week_win_rank(Size) ->
	Sql = io_lib:format(?SQL_RB_WEEK_WIN_RANK, [Size]),
	List = ?DB_MODULE:select_all(player, Sql),
	[
		begin
			{Id, TotalCoin, Nick, Facelook, Vip}
		end || [Id, TotalCoin, Nick, Facelook, Vip] <- List
	].

%% 获取金币排行榜
select_coin_rank(Size) ->
	Sql = io_lib:format(?SQL_COIN_RANK, [Size]),
	List = ?DB_MODULE:select_all(player, Sql),
	[
		begin
			{Id, Coin, Nick, Vip, Facelook,Sign}
		end || [Id, Coin, Nick, Vip, Facelook,Sign] <- List
	].

%% 获取胜率排行榜
select_win_rate_rank(Size) ->
	Sql = io_lib:format(?SQL_WIN_RATE_RANK, [Size]),
	List = ?DB_MODULE:select_all(player, Sql),
	[
		begin
			{Id, WinRate, Nick, Vip, Facelook}
		end || [Id, WinRate, Nick, Vip, Facelook] <- List
	].

%% 获取充值排行榜
select_recharge_rank(Size) ->
	{{Y, M, D},_} = erlang:localtime(),
	M1 = ?IF(M > 9, M, lists:concat([0, M])),
	D1 = ?IF(D > 9, D, lists:concat([0, D])),
	NowTime = list_to_integer(lists:concat([Y, M1, D1])),
	Sql = io_lib:format(?SQL_RECHARGE_RANK, [NowTime, Size]),
	List = ?DB_MODULE:select_all(player, Sql),
	%%Fun = fun(Time1, Time2) ->
	%%			  util:is_same_date(Time1, Time2)
	%%	  end,
	[
		begin
			{Id, TotalMoney, Nick, Vip, Facelook}
		end || [Id, TotalMoney, Nick, Vip, Facelook, _LastResetTime] <- List
			   %%Fun(NowTime, LastResetTime) =:= true
	].

select_redpack_rank(Size) ->
	Sql = "select rank_list from rank_center where rank_type = 9",
	[[List]] = ?DB_MODULE:select_all(rank_center, Sql),
%	O = tool:to_list(List),
%	io:format("~p~n",[O]),
	util:string_to_term(tool:to_list(List)).
	
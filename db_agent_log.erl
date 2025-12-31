%% Author: Administrator
%% Created: 2013-3-6
%% Description: TODO: Add description to db_agent_log
-module(db_agent_log).

-include("common.hrl").
-include("record.hrl").
-include("record/data_monitor_server_record.hrl").
-include("data_goods_record.hrl").

%% 金币排行榜
-define(SQL_HEROCRAFT_TWICE_LOG, "select uid, nick, card_type, gtid, num from log_herocraft_twice ORDER BY create_time desc limit ~p").

-compile(export_all).

date_to_second(Date) ->
	[Time] = calendar:local_time_to_universal_time_dst(Date),
	calendar:datetime_to_gregorian_seconds(Time) - ?DIFF_SECONDS_0000_1900.
	  
test(N) ->
	Now = util:unixtime(),
	Time = Now - N * 600,
	test_log(N, Time).

test_log(0, _Time) ->
	skip;
test_log(N, Time) when is_integer(N)->
	Rand = util:rand(1, 600),
	Now = Time + Rand,
	Id = util:rand(1000001, 1001000),
	Num = util:rand(1, 1000),
	?DB_LOG_MODULE:insert(log_add_gold, [uid, num, type, create_time], [Id, Num, 1, Now]),
	test_log(N - 1, Now).

%% 获取玩家ID
get_player_id(Condition) ->
	?DB_LOG_MODULE:select_all(log_player, "uid", Condition).


%%获取服务器列表日志
insert_get_servers_log(Acid,Acnm,AcType,Key, Tstamp, CreateTime,Ip, Pid) ->
	?DB_LOG_MODULE:insert(log_get_servers,[acid,acnm,actype,key,time_stamp,create_time,ip, pid],[Acid,Acnm,AcType,Key, Tstamp,CreateTime,Ip, Pid]).	

%%mysql玩家日志记录
insert_log_player(Uid,Acid,Acnm,AccType, Channel, Nick,Sex,Crr, Did) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_player,[uid,acid,acnm,actype, channel, nick,sex,career,did,create_time], [Uid,Acid,Acnm,AccType,Channel,Nick,Sex,Crr,Did,Now]).

%% 玩家登陆日志记录
insert_log_login(Uid, Lv, Acnm, Actype, RegTime, Ip, Did, ChannelID) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_login,[uid, acnm, actype, level, reg_time, login_time, ip, did, channel_id], [Uid, Acnm, Actype, Lv, RegTime, Now, Ip, Did, ChannelID]).

%% 玩家退出日志记录
insert_log_quit(Uid, Nick, Acnm, RegTime, LoginTime, ReasonId, Did) ->
	LogoutTime = util:unixtime(),
	Time = LogoutTime - LoginTime,	
	?DB_LOG_MODULE:insert(log_quit,[uid, nick, acnm, time_duration, reason_id, reg_time, login_time, logout_time, did], 
						  [Uid, Nick, Acnm, Time, ReasonId, RegTime, LoginTime, LogoutTime, Did]).

%% 机器人金币输钱/赢钱/抽数日志
insert_coin_system_log(CostCoin, AddCoin, PumpCoin, Source, SystemType, Now) ->
	?DB_LOG_MODULE:insert(log_coin_system, [cost_coin, add_coin, pump_coin, source, system_type, create_time], [CostCoin, AddCoin, PumpCoin, Source, SystemType, Now]).

%% 机器人物品输钱/赢钱/抽数日志
insert_goods_system_log(CostGoods, AddGoods, PumpGoods, Source, SystemType, CostNum, AddNum, PumpNum, Now) ->
	?DB_LOG_MODULE:insert(log_goods_system, [cost_goods, add_goods, pump_goods, source, system_type, cost_num, add_num, pump_num, create_time], 
						  [CostGoods, AddGoods, PumpGoods, Source, SystemType, CostNum, AddNum, PumpNum, Now]).


%% 在线人数日志
insert_log_online(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_online,[log_time, num], [Now, OnlineNum]).

%% 斗地主在线人数日志
insert_poke_online_log(Type, OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_all_poke_online,[type, log_time, num], [Type, Now, OnlineNum]).

%% 飞禽走兽在线人数日志
insert_fowlsbeasts_online_log(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_all_fowlsbeasts_online,[log_time, num], [Now, OnlineNum]).

%% 聚宝盆在线人数日志
insert_lottery_online_log(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_all_lottery_online,[log_time, num], [Now, OnlineNum]).

%% 总在线人数日志
insert_all_online_log(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_all_online,[log_time, num], [Now, OnlineNum]).

%% 百人牛牛在线人数日志
insert_hundred_douniu_online_log(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_all_hundred_online,[log_time, num], [Now, OnlineNum]).

%% 2人牛牛在线人数日志
insert_2niu_online_log(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_2niu_online,[log_time, num], [Now, OnlineNum]).

%% 火拼牛牛在线人数日志
insert_huopin_niu_online_log(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_huopin_niu_online,[log_time, num], [Now, OnlineNum]).

%% 红黑大战在线人数日志
insert_redblack_online_log(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_all_redblack_online,[log_time, num], [Now, OnlineNum]).

%% 梭哈在线人数日志
insert_suoha_online_log(OnlineNum) ->
    Now = util:unixtime(),
    ?DB_LOG_MODULE:insert(log_all_suoha_online,[log_time, num], [Now, OnlineNum]).

%% 龙虎斗在线人数日志
insert_longhudou_online_log(OnlineNum) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_all_longhudou_online, [log_time, num], [Now, OnlineNum]).

%% 等级日志
insert_log_level(Num, Lv) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_level,[log_time, num, level], [Now, Num, Lv]).

insert_log_shop(PlayerId, AccName, Lv, Career, GuildId, MoneyType, Amount, GoodsType, GoodsSubType, GoodsTid, GoodsNum) ->
	?DB_LOG_MODULE:insert(log_shop,[uid, acnm, level, career, guild_id, money_type, amount, type, sub_type, gtid, number], 
						  [PlayerId, AccName, Lv, Career, GuildId, MoneyType, Amount, GoodsType, GoodsSubType, GoodsTid, GoodsNum]).

%% 玩家充值日志记录
insert_log_pay(OrderId, AccountId, Gold) ->
	?DB_LOG_MODULE:insert(log_pay, [order_id, account_id, gold], [OrderId, AccountId, Gold]).

%% %% 获取玩家的最后充值时间
%% get_last_pay_time(PlayerId) ->
%% 	?DB_LOG_MODULE:select_one(log_pay,"insert_time",[{player_id,PlayerId},{pay_status,1}],[{insert_time,desc}],[1]).

%% 玩家踢出日志
insert_kick_off_log(Uid, NickName, K_type, Now_time, Scene, X, Y, Other) ->
	?DB_LOG_MODULE:insert(log_kick_off, [uid, nick, k_type, time, scene, x, y, other], [Uid, NickName, K_type, Now_time, Scene, X, Y, Other]).

%% 铜钱消耗日志
insert_cost_coin(PlayerId, CostCoin, Coin, Source, SystemType, Now, PokeID) ->
	?DB_LOG_MODULE:insert(log_coin, [uid, num, coin, type, source, system_type, create_time, poke_id,game_id,room_id], 
						  [PlayerId, CostCoin, Coin, 2, Source, SystemType, Now, PokeID,0,0]).

insert_cost_coin(PlayerId, CostCoin, Coin, Source, SystemType, Now, PokeID,GameID,RoomID) ->
    ?DB_LOG_MODULE:insert(log_coin, [uid, num, coin, type, source, system_type, create_time, poke_id,game_id,room_id], 
                          [PlayerId, CostCoin, Coin, 2, Source, SystemType, Now, PokeID,GameID,RoomID]).

%% 发放铜钱
insert_add_coin(PlayerId, Money, Coin, Source, SystemType, Now, PokeID) ->
	?DB_LOG_MODULE:insert(log_coin, [uid, num, coin, type, source, system_type, create_time, poke_id,game_id,room_id], 
						  [PlayerId, Money, Coin, 1, Source, SystemType, Now, PokeID,0,0]).

insert_add_coin(PlayerId, Money, Coin, Source, SystemType, Now, PokeID,GameID,RoomID) ->
    ?DB_LOG_MODULE:insert(log_coin, [uid, num, coin, type, source, system_type, create_time, poke_id,game_id,room_id], 
                          [PlayerId, Money, Coin, 1, Source, SystemType, Now, PokeID,GameID,RoomID]).

%% 钻石消耗日志
insert_cost_gold(PlayerId, ChangeGold, Gold, Source, SystemType, Now) ->
	?DB_LOG_MODULE:insert(log_gold, [uid, num, gold, type, source, system_type, create_time], [PlayerId, ChangeGold, Gold, 2, Source, SystemType, Now]).

%% 钻石增加日志
insert_add_gold(PlayerId, ChangeGold, Gold, Source, SystemType, Now) ->
	?DB_LOG_MODULE:insert(log_gold, [uid, num, gold, type, source, system_type, create_time], [PlayerId, ChangeGold, Gold, 1, Source, SystemType, Now]).

%% ====================================
%% 红豆消耗日志
insert_cost_redbean(PlayerId, CostCoin, Coin, Source, SystemType, Now, PokeID) ->
	?DB_LOG_MODULE:insert(log_red_bean, [uid, num, red_bean, type, source, system_type, create_time, poke_id,game_id,room_id], 
						  [PlayerId, CostCoin, Coin, 2, Source, SystemType, Now, PokeID,0,0]).

insert_cost_redbean(PlayerId, CostCoin, Coin, Source, SystemType, Now, PokeID,GameID,RoomID) ->
    ?DB_LOG_MODULE:insert(log_red_bean, [uid, num, red_bean, type, source, system_type, create_time, poke_id,game_id,room_id], 
                          [PlayerId, CostCoin, Coin, 2, Source, SystemType, Now, PokeID,GameID,RoomID]).

%% 发放铜钱
insert_add_redbean(PlayerId, Money, Coin, Source, SystemType, Now, PokeID) ->
	?DB_LOG_MODULE:insert(log_red_bean, [uid, num, red_bean, type, source, system_type, create_time, poke_id,game_id,room_id], 
						  [PlayerId, Money, Coin, 1, Source, SystemType, Now, PokeID,0,0]).

insert_add_redbean(PlayerId, Money, Coin, Source, SystemType, Now, PokeID,GameID,RoomID) ->
    ?DB_LOG_MODULE:insert(log_red_bean, [uid, num, red_bean, type, source, system_type, create_time, poke_id,game_id,room_id], 
                          [PlayerId, Money, Coin, 1, Source, SystemType, Now, PokeID,GameID,RoomID]).

%% =======================================
%% 物品消耗
insert_cost_goods(PlayerId, GoodsId, Gtid, GoodsType, SubType, Quality, GoodsNum, Source, SystemType, Now) ->
	case data_goods:get(Gtid) of
		#goods_config{real_name = GoodsName1} ->
			GoodsName = util:ascii_to_utf8(GoodsName1);
		_ ->
			GoodsName = ""
	end,
	?DB_LOG_MODULE:insert(log_goods, [uid, gid, gtid, goods_name, goodtype, subtype, quality, num, type, source, system_type, create_time], 
						  [PlayerId, GoodsId, Gtid, GoodsName, GoodsType, SubType, Quality, GoodsNum, 2, Source, SystemType, Now]).

%% 发放物品
insert_add_goods(GoodsId, PlayerId, Gtid, GoodsType, SubType, Quality, GoodsNum, Source, SystemType, Now) ->
	case data_goods:get(Gtid) of
		#goods_config{real_name = GoodsName1} ->
			GoodsName = util:ascii_to_utf8(GoodsName1);
		_ ->
			GoodsName = ""
	end,
	?DB_LOG_MODULE:insert(log_goods, [uid, gid, gtid, goods_name, goodtype, subtype, quality, num, type, source, system_type, create_time], 
						  [PlayerId, GoodsId, Gtid, GoodsName, GoodsType, SubType, Quality, GoodsNum, 1, Source, SystemType, Now]).

%% 强化日志
add_stren_log(Id, PlayerId, Gtid, OldStrenLv, NewStrenLv, Coin, Gold, CostGoodsTid) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_stren, [gid, uid, gtid, old_stren, new_stren, coin, gold, cost_goods, create_time], 
						  [Id, PlayerId, Gtid, OldStrenLv, NewStrenLv, Coin, Gold, CostGoodsTid, Now]).

%% 装备转换日志
equip_convert_log(PlayerId, Id, Gtid, New_Gtid, Gold) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_upgrade, [uid, gid, gtid, new_gtid, type, gold, create_time],
							   [PlayerId, Id, Gtid, New_Gtid, 2,  Gold, Now]).
  

%% 装备升级日志
equip_upg_log(PlayerId, Id, Gtid, New_Gtid, Coin) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_upgrade, [uid, gid, gtid, new_gtid, type, coin, create_time],
							   [PlayerId, Id, Gtid, New_Gtid,1, Coin, Now]).

%% 宝石升级日志
compose_log(PlayerId, Id, Gtid, Num, Coin) ->
	Now = util:unixtime(),
	?DB_LOG_MODULE:insert(log_gem_compose, [uid, gid, gtid, num, coin, create_time],
							   [PlayerId, Id, Gtid, Num, Coin, Now]).




%% 玩家升级日志
insert_player_uplevel(Data) ->
	Time = util:unixtime(),
	?DB_LOG_MODULE:insert(log_uplevel,
						  [time,acid,uid,nick,lv,exp,eng,scene],
						  [Time | Data]
						 ).

%%奖励日志
insert_reward_log(Uid,Type,Repu,Coin,Gold,Eng,Award) ->
	NewAward =  util:term_to_string(Award),
	?DB_LOG_MODULE:insert(log_reward,[uid,type,repu,coin,gold,eng,award,time],[Uid,Type,Repu,Coin,Gold,Eng,NewAward,util:unixtime()]).

%%活动统计日志
insert_attends_log([Type, Number, Times, CreateTime]) ->
	?DB_LOG_MODULE:insert(log_attends,[type,number,times,create_time],[Type, Number, Times, CreateTime]).

%%通过动态sql语句查询人物信息
get_player_info(Sql) ->   
	?DB_LOG_MODULE:select_row(log_player, Sql).

%%所有玩家魔晶和金币存量
insert_player_money_stock(Gold, Coin, CreateTime) ->
    ?DB_LOG_MODULE:insert(log_money_stock,[gold, coin, create_time],[Gold, Coin, CreateTime]).


%%玩家提意见日志
insert_suggestion_log(UID, Nick, AcId, AcNm, Content, CreateTime) ->
    ?DB_LOG_MODULE:insert(log_suggestion, [uid, nick, acid, acnm, content, create_time], [UID, Nick, AcId, AcNm, Content, CreateTime]).


%% 玩家兑换商品日志
insert_player_exchange_shop_log(OrderId, UID, GoodsType, GoodsId, GoodsName, ExchangeNum, LeftNum, CreateTime, Name, 
								PhoneNum, QqNum, Mail, Address, IsExecuted, ExchangeMoney) ->
	?DB_LOG_MODULE:insert(log_shop, [order_id, uid, goods_type, goods_id, goods_name, exchange_num, left_num, 
									 create_time, name, phone_num, qq_num, mail, address, visible, exchange_money], 
						  [OrderId, UID, GoodsType, GoodsId, GoodsName, ExchangeNum, LeftNum, 
						   CreateTime, Name, PhoneNum, QqNum, Mail, Address, IsExecuted, ExchangeMoney]).

%% 更新玩家兑换订单的可见状态
update_player_exchange_shop_log(OrderID, UID) ->
	?DB_LOG_MODULE:update(log_shop, [{visible, 1}], [{order_id, OrderID}, {uid, UID}]).

%% 玩家盈利比日志
insert_log_profit_percent(Uid, ProfitPercent) ->
	LogTime = util:unixtime(),	
	?DB_LOG_MODULE:insert(log_profit_percent,[uid, profit_percent, insert_time], 
						  [Uid, ProfitPercent, LogTime]).

%% 斗地主牌局日志
insert_poke_result(Type, RoomId, PokeTime, IsTrade, IsLandWin, MemInfos, Doubles, MemCards, 
				   TableCards, LaiziCards, SkillInfo, AccUsers, CreateTime, PokeID)->
	MemInfos1 =  util:term_to_string(MemInfos),
	Doubles1 =  util:term_to_string(Doubles),
	MemCards1 =  util:term_to_string(MemCards),
	TableCards1 =  util:term_to_string(TableCards),
	LaiziCards1 =  util:term_to_string(LaiziCards),
	SkillInfo1 = util:term_to_string(SkillInfo),
	AccUsers1 = util:term_to_string(AccUsers),
	
	?DB_LOG_MODULE:insert(log_poke_result,[type,room_id,poke_time,is_trade,is_land_win,mem_infos,doubles,mem_cards,table_cards,laizi_cards,skill_info,result,create_time,poke_id],
						  [Type,RoomId,PokeTime,IsTrade,IsLandWin, MemInfos1,
						   Doubles1, MemCards1, TableCards1, LaiziCards1, SkillInfo1, AccUsers1, CreateTime, PokeID]).

%% 插入热点记录
inset_hotpoint_log(UID, ChannelId, Hotpoint)->
	#monitor_server_config{event=Name} = data_monitor_server:get(Hotpoint),
	?DB_LOG_MODULE:insert(log_hotpoint, [uid, channel_id, hotpoint, name, timestamp],
						  [UID, ChannelId, Hotpoint, unicode:characters_to_binary(Name), util:unixtime()]).


%% 飞禽走兽开奖日志
insert_fowlsbeasts_log(UID, Nick, AnimalList, IsRobot, RoomID) ->
	?DB_LOG_MODULE:insert(log_fowlsbeasts, [uid, nick, animal_list, is_robot, room_id, create_time],
						  [UID, tool:to_binary(Nick), util:term_to_bitstring(AnimalList), IsRobot, RoomID, util:unixtime()]).


%% 聚宝阁开奖日志
insert_lottery_log(RoomID, UID, Nick, IsRobot, PlayerNum, RobotNum, BetPlayerNum, BetRobotNum, PlayerBetNum, RobotBetNum,
				   PlayerBetVal, RobotBetVal, PumpNum, PumpValue, GoodsList, PumpList) ->
	?DB_LOG_MODULE:insert(log_lottery, [room_id, uid, nick, is_robot_win, player_num, robot_num, bet_player_num, bet_robot_num, player_bet_num, 
										robot_bet_num, player_bet_value, robot_bet_value, pump_num, pump_value, goods_list, pump_list, create_time],
						  [RoomID, UID, tool:to_binary(Nick), IsRobot, PlayerNum, RobotNum, BetPlayerNum, BetRobotNum, PlayerBetNum, RobotBetNum,
						   PlayerBetVal, RobotBetVal, PumpNum, PumpValue, util:term_to_bitstring(GoodsList), util:term_to_bitstring(PumpList), 
						   util:unixtime()]).


%% 商行物品日志
insert_trade_log(PlayerId, Type, GoodsType, GoodsId, GoodsQty, GoodsNum, TotalPrice, UnitPrice, Now) ->
	?DB_LOG_MODULE:insert(log_trade, [uid, type, goods_type, goods_id, goods_quality, goods_num, total_price, unit_price, create_time],
						  [PlayerId, Type, GoodsType, GoodsId, GoodsQty, GoodsNum, TotalPrice, UnitPrice, Now]).

%% 牌局匹配时间日志
insert_waiting_time_log(Uid, RoomId, WaitingTime, CreateTime) ->
	?DB_LOG_MODULE:insert(log_waiting_time,[uid, room_id, waiting_time, create_time], [Uid, RoomId, WaitingTime, CreateTime]).



%% 插入打中鱼日志
insert_shoot_fish_log(PlayerId, Name, AccountName, NowInput, NowOuput, TotalInput, 
                      TotalOutput, CannonLv, FishIdList) ->
	Time = util:unixtime(),
	FishIdList1 = util:term_to_string(FishIdList),
	?DB_LOG_MODULE:insert(log_by_shoot_fish,
	[player_id, time, name, account_name,now_input,now_output,total_input,total_output,cannon_lv,fish_id_list], 
	[PlayerId, 
	 Time,
	 Name, 
	 AccountName, 
	 NowInput, 
	 NowOuput, 
	 TotalInput, 
	 TotalOutput, 
	 CannonLv, 
	 FishIdList1
	]).


%% 捕鱼掉落物品日志
insert_by_drop(PlayerId,CannonLv,FishId,ResId,Num) ->
    NowTime = time_util:now(),
    ?DB_LOG_MODULE:insert(log_by_drop,
    [time,player_id,cannon_lv,fish_id,res_id,num],
    [NowTime,
     PlayerId,
     CannonLv,
     FishId,
     ResId,
     Num
    ]).
	 

%% 红包日志
insert_redpacket_log(RedId,SendId,SendName,SendAcct,Money,OpType)->
    Now = util:unixtime(),
    ?DB_LOG_MODULE:insert(log_redpackets,
                          [red_id,role_id,role_name,role_acct,red_num,op_type,op_time], 
                          [RedId,SendId,SendName,SendAcct,Money,OpType,Now]).


%% 私人房日志
insert_priv_suoha_log(RoleId,RoleName,RoleAcct,XzCoin,WinCoin,PumpCoin,LoseId,LoseName)->
    Now = util:unixtime(),
    ?DB_LOG_MODULE:insert(log_suoha_private_room,
                          [role_id,role_nick,role_acct,xz_coin,win_coin,pump_coin,lose_id,lose_nick,op_time], 
                          [RoleId,RoleName,RoleAcct,XzCoin,WinCoin,PumpCoin,LoseId,LoseName,Now]).

%% 超级翻翻乐活动日志
insert_herocraft_twice_log(UID, Nick, Cards, CardType, GTID, Num, CreateTime) ->
    ?DB_LOG_MODULE:insert(log_herocraft_twice,[uid,nick,cards,card_type,gtid,num,create_time], 
                          [UID, Nick, Cards, CardType, GTID, Num, CreateTime]).

%% 获取超级翻翻乐最新的3条日志
get_herocraft_twice_log() ->
	Sql = io_lib:format(?SQL_HEROCRAFT_TWICE_LOG, [3]),
	case ?DB_LOG_MODULE:select_all(log_herocraft_twice, Sql) of
		List when is_list(List) -> List;
		_ -> []
	end.

%% ----------------------------------------------------
%% 平台日志
%% ----------------------------------------------------
insert_account_reg(#pt_account_reg{}=Reg)->
      ?DB_LOG_MODULE:insert(log_pt_account_reg,
      [uuid,sdk_uuid,trigger_time,platform,zone_id,channel,client_version], 
      [ Reg#pt_account_reg.uuid,
        Reg#pt_account_reg.sdk_uuid,
        Reg#pt_account_reg.trigger_time,
        Reg#pt_account_reg.platform,
        Reg#pt_account_reg.zone_id,
        Reg#pt_account_reg.channel,
        Reg#pt_account_reg.client_version
       ]).


insert_role_reg(#pt_role_reg{}=Reg)->
      ?DB_LOG_MODULE:insert(log_pt_role_reg,
      [uuid,trigger_time,platform,zone_id,sdk_uuid,nick_name,channel,role_id,career_id,client_version], 
      [ Reg#pt_role_reg.uuid,
        Reg#pt_role_reg.trigger_time,
        Reg#pt_role_reg.platform,
        Reg#pt_role_reg.zone_id,
        Reg#pt_role_reg.sdk_uuid,
        Reg#pt_role_reg.nick_name,
        Reg#pt_role_reg.channel,
        Reg#pt_role_reg.role_id,
        Reg#pt_role_reg.career_id,
        Reg#pt_role_reg.client_version
       ]).


insert_recharge_log(#pt_recharge{}=Reg)->
      ?DB_LOG_MODULE:insert(log_pt_recharge,
      [uuid,channel,role_id,level,order_id,trigger_time,platform,zone_id,recharge_type,
       recharge_count,recharge_money,before_vip_level,later_vip_level,client_version], 
      [ Reg#pt_recharge.uuid,
        Reg#pt_recharge.channel,
        Reg#pt_recharge.role_id,
        Reg#pt_recharge.level,
        Reg#pt_recharge.order_id,
        Reg#pt_recharge.trigger_time,
        Reg#pt_recharge.platform,
        Reg#pt_recharge.zone_id,
        Reg#pt_recharge.recharge_type,
        Reg#pt_recharge.recharge_count,
        Reg#pt_recharge.recharge_money,
        Reg#pt_recharge.before_vip_level,
        Reg#pt_recharge.later_vip_level,
        Reg#pt_recharge.client_version
       ]).


insert_account_act(#pt_account_act{}=Act)->
      ?DB_LOG_MODULE:insert(log_pt_account_act,
      [uuid,trigger_time,platform,zone_id,channel,operation_code,
       operation_data,result,client_version], 
      [ Act#pt_account_act.uuid,
        Act#pt_account_act.trigger_time,
        Act#pt_account_act.platform,
        Act#pt_account_act.zone_id,
        Act#pt_account_act.channel,
        Act#pt_account_act.operation_code,
        Act#pt_account_act.operation_data,
        Act#pt_account_act.result,
        Act#pt_account_act.client_version
       ]).


insert_online_data(#pt_online_data{}=Act)->
      ?DB_LOG_MODULE:insert(log_pt_online_data,
      [trigger_time,platform,zone_id,count,extra], 
      [ Act#pt_online_data.trigger_time,
        Act#pt_online_data.platform,
        Act#pt_online_data.zone_id,
        Act#pt_online_data.count,
        Act#pt_online_data.extra
       ]).


insert_match_record(#pt_match_record{}=Act)->
      ?DB_LOG_MODULE:insert(log_pt_match_record,
      [uuid,trigger_time,platform,zone_id,is_robot,channel,role_id,vip_level,level,
       room_id,match_id,first_change_type,second_change_type,match_type,extra,match_status,
       match_multiple,client_version], 
      [ Act#pt_match_record.uuid,
        Act#pt_match_record.trigger_time,
        Act#pt_match_record.platform,
        Act#pt_match_record.zone_id,
        Act#pt_match_record.is_robot,
        Act#pt_match_record.channel,
        Act#pt_match_record.role_id,
        Act#pt_match_record.vip_level,
        Act#pt_match_record.level,
        Act#pt_match_record.room_id,
        Act#pt_match_record.match_id,
        Act#pt_match_record.first_change_type,
        Act#pt_match_record.second_change_type,
        Act#pt_match_record.match_type,
        Act#pt_match_record.extra,
        Act#pt_match_record.match_status,
        Act#pt_match_record.match_multiple,
        Act#pt_match_record.client_version
       ]).


insert_operaty(PlayerId,ActType,OpType,Param1,Param2,Param3)->
    ?DB_LOG_MODULE:insert(log_operaty,
    [uid,act_type,op_type,param1,param2,param3,time], 
    [PlayerId,ActType,OpType,Param1,Param2,Param3,util:unixtime()]).

%% 记录抽水
insert_pump(PlayerId,Num,Source,SystemType)->
    ?DB_LOG_MODULE:insert(log_pump,
    [uid,num,source,system_type,create_time], 
    [PlayerId,Num,Source,SystemType,util:unixtime()]).


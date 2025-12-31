%%%--------------------------------------
%%% @Module  : db_agent_player
%%% @Author  : water
%%% @Created : 2013.01.15
%%% @Description: 玩家数据处理模块
%%%--------------------------------------
-module(db_agent_player).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").

-compile(export_all).

%% 创建初始化玩家
create_player([Version, Agent, AccounId, Accname, _Password, Nick,Channel, Device, Did, Ip,
			   ServerId, Sex, Time, Facelook, PoolValue, VipGiftBuyNum, Coin, GuideId]) ->
	PlayerID = mod_id_global:get_id(player),
	Player   = #player{
				 id = PlayerID,
				 account_id = AccounId,                            %% 平台账号ID
				 account_name = Accname,                           %% 平台账号
                 account_type =  Agent,
				 server_id = ServerId,
				 gender = Sex,
				 nick = Nick,                                      %% 玩家名
				 type = 1,                                         %% 玩家身份 1普通玩家 2指导员3gm
				 reg_time = Time,                                  %% 注册时间
				 last_login_time = Time,                      	   %% 最后登陆时间
				 last_login_ip = Ip,                               %% 最后登陆IP
				 platform = Agent,
				 channel_id = Channel,
				 device = Device,
				 did = Did,
				 skin = 0,
				 coin = Coin,                                      %% 皮肤
				 facelook = Facelook,                              %% 头像ID
				 pool_value = PoolValue,                           %% 个人水池价值
				 vip_gift_num = VipGiftBuyNum,
				 other = 0,                                        %% 其他信息
				 newbie_guide_status = GuideId,                    %% 新手引导状态默认第一步
                 client_version = Version
				},
    ValueList = lists:nthtail(1, tuple_to_list(Player)),
    FieldList = record_info(fields, player),
    ?DB_MODULE:insert(player, FieldList, ValueList),
	PlayerID.


%%通过人物单个信息查询人物信息
get_player_info_by_key(List) ->
	?DB_MODULE:select_all(player, "*", List).

%% 通过角色ID取得帐号ID
get_accountid_by_id(PlayerId) ->
    ?DB_MODULE:select_one(player, "account_id", [{id, PlayerId}], [], [1]).

%% 通过帐号ID取得角色ID
get_playerid_by_accountid(AccId, Agent) ->
    ?DB_MODULE:select_one(player, "id", [{account_id, AccId},{account_type, Agent}], [], [1]).

%% 通过角色ID取得帐号信息
get_info_by_id(PlayerId) ->
	ValueList = ?DB_MODULE:select_row(player, "*", [{id, PlayerId}], [], [1]),
	case ValueList of
		[] ->
		    [];
		_ ->
		    list_to_tuple([player|ValueList])
	end.


%% 通过角色名取得id
get_id_by_nickname(Name) ->
    ?DB_MODULE:select_one(player, "id", [{nick, Name}], [], [1]).

%% 通过角色名取得id,平台账号
get_id_accname_by_nickname(Name) ->
    ?DB_MODULE:select_row(player, "id,account_name", [{nick, Name}], [], [1]).

%% 通过角色id获取平台账号, id, 昵称
get_id_accname_by_uid(ID) ->
    ?DB_MODULE:select_row(player, "id, nick, account_name", [{id, ID}], [], [1]).

%% 通过平台id取得id,nick,平台账号
get_playerinfo_by_accountid(AccId) ->
	?DB_MODULE:select_row(player, "id,nick,account_name,level", [{account_id, AccId}], [], [1]).

%% 通过角色名取得角色信息
get_info_by_name(Name) ->
    ?DB_MODULE:select_row(player, "*", [{nick, Name}], [], [1]).

%% 通过角色ID取得帐号相关于私聊的信息
get_chat_info_by_id(PlayerId) ->
    ?DB_MODULE:select_row(player, "nick,gender,career,guild_name,level,`force`,nobi, speed", [{id, PlayerId}], [], [1]).

%% 通过角色ID取得帐号相关于排行榜的信息
get_rank_info_by_id(PlayerId) ->
    ?DB_MODULE:select_row(player, "nick, gender, career, guild_name, vip", [{id, PlayerId}], [], [1]).
%%通过好友角色Id获取好友信息
get_friend_info_by_name(Name) ->
	 ?DB_MODULE:select_row(player, "id,nick,icon,gender,vip,level,guild_name,camp,career", [{nick, Name}], [], [1]).
check_player_exit(PlayerId)->
	 ?DB_MODULE:select_one(player, "count(*)", [{id, PlayerId}], [], [1]).

%% 获取角色money信息
get_player_money(PlayerId) ->
    ?DB_MODULE:select_row(player,"gold, coin",[{id,PlayerId}],[],[1]).

%% 获取角色充值monney信息
get_player_vip_money(PlayerId) ->
    ?DB_MODULE:select_row(player,"gold, vip_gold",[{id,PlayerId}],[],[1]).

%% 根据台用户ID，平台用户账号
%% 返回角色ID，状态，等级，职业，性别，名字
%% 取得指定帐号名称的角色列表 
get_role_list(Accid) ->
    ?DB_MODULE:select_all(player, "id, status, level, career, gender, nick", [{account_id, Accid}], [],[]).

get_server_role_list(ServerId, Accid, AccType) ->
	?DB_MODULE:select_all(player, "id, status, level, career, gender, nick", [{account_id, Accid},{server_id, ServerId},{account_type, AccType}], [],[]).

%% 根据台用户ID，平台用户账号
%% 返回角色ID，状态，等级，职业，性别，名字
%% 取得指定帐号名称的角色列表 
get_role_list_by_accid(Accid) ->
    Ret = ?DB_MODULE:select_row(player, "id, status, level, career, gender, nick", [{account_id, Accid}], [],[1]),
    case Ret of
        [] -> [];
        _  -> [Ret]
    end.

%% 根据台平台用户账号
%% 返回角色ID，状态，等级，职业，性别，名字
%% 取得指定帐号名称的角色列表 
get_role_list_by_accname(Accname) ->
    Ret = ?DB_MODULE:select_row(player, "id, status, level, career, gender, nick", [{account_name, Accname}], [],[1]),
    case Ret of
        [] -> [];
        _  -> [Ret]
    end.

reset_player_info() ->
%% 	?DB_MODULE:update(player,[{online_flag, 0},{table_attr, util:term_to_string([])}],[]),
%% 	?DB_MODULE:update(player,[{online_flag, 0}],[{online_flag, 1}]),
%%  	?DB_MODULE:update(player,[{table_attr, util:term_to_string([])}],[]),
	?DB_MODULE:update(player_room_game,[{room_info, util:term_to_string([])}],[]).

%% 更新账号最近登录时间和IP
update_last_login(Time, LastLoginIP, PlayerId) ->
    ?DB_MODULE:update(player,[{last_login_time, Time}, {online_flag, 1}, {last_login_ip,LastLoginIP}],[{id, PlayerId}]).

%% 更新玩家的昵称
update_player_nick(Nick, PlayerId) ->
    ?DB_MODULE:update(player,[{nick, Nick}],[{id, PlayerId}]).

%% 更新玩家的性别
update_player_sex(Sex, PlayerId) ->
    ?DB_MODULE:update(player,[{gender, Sex}],[{id, PlayerId}]).

%% 更新玩家信息
update_player_info(Field, Data, Key, Value) ->
	?DB_MODULE:update(player, Field, Data, Key, Value).

%%更新角色在线状态
update_online_flag(PlayerId, Online_flag) ->
    ?DB_MODULE:update(player,[{online_flag, Online_flag}],[{id, PlayerId}]).


%%更新新手引导状态
update_newbie_guide_status(PlayerId, [NewStatus, FinishTime]) ->
    ?DB_MODULE:update(player,[{newbie_guide_status, NewStatus}, {newbie_guide_finish_time, FinishTime}],[{id, PlayerId}]).

%%更新角色TableAttr
update_player_table_attr(PlayerId,TableAttr) ->
    ?DB_MODULE:update(player,[{table_attr, TableAttr}],[{id, PlayerId}]).

%% 设置角色状态(0-正常，1-禁止)
set_player_status(Id, Status) ->
    ?DB_MODULE:update(player, [{status, Status}], [{id, Id}]).

%%获取玩家最近登录的时间
get_player_last_login_time(PlayerId) ->
    ?DB_MODULE:select_one(player, "last_login_time", [{id, PlayerId}], [], [1]).

%% 根据角色名称查找ID
get_role_id_by_name(Name) ->
    ?DB_MODULE:select_one(player, "id", [{nick, Name}], [], [1]).

%%根据玩家ID获取角色名
get_role_name_by_id(Id)->
    ?DB_MODULE:select_one(player, "nick", [{id, Id}], [], [1]).

%%获取模块开启状态
get_switch_by_id(Id)->
    ?DB_MODULE:select_one(player, "switch", [{id, Id}], [], [1]).

%% 检测指定名称的角色是否已存在
is_accname_exists(AccName) ->
    ?DB_MODULE:select_one(player, "id", [{account_name, AccName}], [], [1]).

%% 更改玩家经验、血、魔等数值
update_player_exp_data(ValueList, WhereList) ->
    ?DB_MODULE:update(player, ValueList, WhereList).

%% 是否创建角色
is_create(Accname)->
    ?DB_MODULE:select_all(player, "id", [{account_name, Accname}], [], [1]).

%%保存玩家基本信息
save_player_table(PlayerId, FieldList, ValueList)->
    ?DB_MODULE:update(player, FieldList, ValueList, "id", PlayerId).

%% 删除角色
delete_role(PlayerId, Accid) ->
    ?DB_MODULE:delete(player, [{id, PlayerId}, {account_id, Accid}]).

%% 取得IP封禁信息
get_ban_ip_info(Ip) ->
    ?DB_MODULE:select_one(ban_ip_list, "end_time", [{ip, Ip}], [], [1]).

%% 取得Id封禁信息
get_ban_id_info(Id) ->
    ?DB_MODULE:select_one(ban_account_list, "end_time", [{uid, Id}], [], [1]).

add_ban_ip_info(BanIpInfo) ->
	ValueList = lists:nthtail(1, tuple_to_list(BanIpInfo)),
    FieldList = record_info(fields, ban_ip_list),
	?DB_MODULE:insert(ban_ip_list, FieldList, ValueList).

add_ban_account_info(BanAccountInfo) ->
	ValueList = lists:nthtail(1, tuple_to_list(BanAccountInfo)),
    FieldList = record_info(fields, ban_account_list),
	?DB_MODULE:insert(ban_account_list, FieldList, ValueList).

del_ban_account_by_id(Uid) ->
	?DB_MODULE:delete(ban_account_list, [{uid, Uid}]).

add_ban_imei_info(BanIMeiInfo) ->
	ValueList = lists:nthtail(1, tuple_to_list(BanIMeiInfo)),
	FieldList = record_info(fields, ban_imei_list),
	?DB_MODULE:insert(ban_imei_list, FieldList, ValueList).

del_ban_imei_by_id(IMei) ->
	?DB_MODULE:delete(ban_imei_list, [{imei, IMei}]).

get_ban_mei_info(IMei) ->
    ?DB_MODULE:select_one(ban_imei_list, "end_time", [{imei, IMei}], [], [1]).

get_ban_chat_info(Id) ->
    ?DB_MODULE:select_one(ban_chat_list, "end_time", [{uid, Id}], [], [1]).

add_ban_chat_info(BanAccountInfo) ->
	ValueList = lists:nthtail(1, tuple_to_list(BanAccountInfo)),
    FieldList = record_info(fields, ban_chat_list),
	?DB_MODULE:insert(ban_chat_list, FieldList, ValueList).

del_ban_chat_by_id(Uid) ->
	?DB_MODULE:delete(ban_chat_list, [{uid, Uid}]).

del_ban_ip_by_id(Ip) ->
	?DB_MODULE:delete(ban_ip_list, [{ip, Ip}]).

get_roleid_by_level(MinLv, MaxLv) ->
    ?DB_MODULE:select_all(player, "id", [{level, ">", MinLv-1},{level, "<", MaxLv+1}], [],[]).

get_all_roleid() ->
    ?DB_MODULE:select_all(player, "id",[],[],[]).

get_player_level_inof() ->
	?DB_MODULE:select_all(player, "select `level`, count(1) from `player` group by `level`").

del_gm_by_id(Uid) ->
	?DB_MODULE:delete(gm_list, [{uid, Uid}]).

add_gm_info(GmInfo) ->
	ValueList = lists:nthtail(1, tuple_to_list(GmInfo)),
    FieldList = record_info(fields, gm_list),
	?DB_MODULE:insert(gm_list, FieldList, ValueList).

%% get_charge_order(AccountId, HandleStatus) ->
%% 	[].
%% %%     ?DB_MODULE:select_all(charge, "order_id, gold",[{account_id, AccountId}, {handle_status, HandleStatus}],[],[]).
%% 
%% update_charge_order(OrderId, HandleStatus) ->
%%     ?DB_MODULE:update(charge,["handle_status"],[HandleStatus], "order_id", OrderId).

%% 根据玩家ID处理玩家充值
get_player_pay(PlayerId, State) ->
	?DB_MODULE:select_all(player_pay, "id, is_first, pay_gold", [{player_id, PlayerId}, {state, State}, {pay_status, 1}]).

%% 根据平台ID处理玩家充值
get_player_pay_account_id(AccountId, State) ->
	?DB_MODULE:select_all(player_pay, "id,order_id,is_first,pay_gold,pay_way,pay_time,callback_info,recharge_id,amount", [{account_id, AccountId}, {state, State}, {pay_status, 1}]).

%% 根据平台用户名处理玩家充值 
get_player_pay_account_name(AccountId, State) ->
	?DB_MODULE:select_all(player_pay, "id, is_first, pay_gold", [{account_id, AccountId}, {state, State}, {pay_status, 1}]).

%% 根据玩家参加的活动类型查询玩家充值
get_player_pay_callbackinfo(PlayerId, State, StartTime, EndTime) ->
    ?DB_MODULE:select_all(player_pay, "callback_info", [{player_id, PlayerId}, {state, State}, {pay_time, ">=", StartTime}, {pay_time, "<=", EndTime}]).

%% 检查订单是否重复
check_order_repeat(Order) ->
	?DB_MODULE:select_row(player_pay, "*", [{order_id, Order}, {pay_status, 1}], [], [1]).

%% 通过uid 获取订单
get_order_by_uid(Uid) ->
	?DB_MODULE:select_row(player_pay, "*", [{player_id, Uid}, {pay_status, 1}],[], [1]).

%% 通过uid 获取订单数量
get_order_num_by_uid(Uid) ->
	?DB_MODULE:select_row(player_pay, "count(order_id)", [{player_id, Uid}, {pay_status, 1}],[], [1]).

%% 通过uid 获取历史订单
get_order_num_by_uid(Uid, StartTime, EndTime) ->
	?DB_MODULE:select_row(player_pay, "count(order_id), sum(amount)", [{player_id, Uid}, {pay_status, 1},
																	   {pay_time, ">=", StartTime}, {pay_time, "<=", EndTime}],[], [1]).

%% 获取最近一次充值的时间
get_last_pay_time(Uid) ->
	case ?DB_MODULE:select_row(player_pay, "pay_time", [{player_id, Uid}, {pay_status, 1}], [{pay_time, desc}], [1]) of
		[PayTime | _] -> PayTime;
		_ -> 0
	end.

%% 创建新订单
insert_order(Order, Uid, Nick, Acid, Acn, Amount, RechargeID, ChannelID, AccountType, PayTime, Level, Callback_Info, Order_Status, Is_First, Way, Failed_Desc, DID, State) ->
	%%Now = util:unixtime(),
	?DB_MODULE:insert(player_pay,
					  [{order_id, Order},
					   {player_id, Uid},
					   {nick_name, Nick},
					   {account_id, Acid},
					   {account_name, Acn},
					   {recharge_id, RechargeID},
					   {channel_id, ChannelID},
					   {account_type, AccountType},
					   {pay_time, PayTime},
					   {amount, Amount},
					   {pay_status, Order_Status},
					   {player_level, Level},
					   {is_first, Is_First},
					   {pay_way, Way},
					   {failed_desc, Failed_Desc},
					   {did, DID},
					   {state, State},
					   {pay_gold, 0},
					   {usd_amount, 0},
					   {twd_amount, 0},
					   {callback_info, util:term_to_bitstring(Callback_Info)}]).

%% 处理充值后更新订单状态
update_pay_order(PayId, State, ErrorMsg) ->
	?DB_MODULE:update(player_pay,
					  [{state, State}, {error_msg, ErrorMsg}],
					  [{id, PayId}]).

update_pay_order(PayId, ErrorMsg) ->
    ?DB_MODULE:update(player_pay,
                      [{error_msg, ErrorMsg}],
                      [{id, PayId}]).

get_player_pay_time(PlayerId, Time) ->
 	?DB_MODULE:select_all(player_pay, "pay_gold", [{player_id, PlayerId}, {pay_status, 1}, {pay_time, ">", Time}]).

get_player_pay_time(PlayerId, StartTime, EndTime) ->
 	?DB_MODULE:select_all(player_pay, "pay_gold", [{player_id, PlayerId}, {pay_status, 1}, {pay_time, ">", StartTime}, {pay_time, "<=", EndTime}]).

set_vip_level(PlayerId,VipLv) ->
	?DB_MODULE:update(player,
					  [{vip,VipLv}],
					  [{id,PlayerId}]).

%% 获取玩家在线数据
get_max_min_online_num(Time) ->
	{Today, NextDay} = util:get_midnight_seconds(Time),
	Sql = lists:concat(["select max(`num`), min(`num`) from `log_online` where `log_time` >=", Today, " and `log_time`<", NextDay]),
	?DB_LOG_MODULE:select_all(log_online, Sql).

%% 获取注册角色信息
get_register_data(StartTime, EndTime) ->
	?DB_LOG_MODULE:select_all(log_player, "acid, nick, create_time", [{create_time, ">=", StartTime}, {create_time, "<", EndTime}]).

%% 获取角色升级信息
get_upgrade_log(StartTime, EndTime) ->
	?DB_LOG_MODULE:select_all(log_uplevel, "acid, nick, lv, time", [{time, ">=", StartTime}, {time, "<", EndTime}]).

get_vip_gold(PlayerId) ->
	?DB_MODULE:select_one(player,"vip_gold",[{id,PlayerId}],[],[1]).


add_vip_gold(PlayerId,Add) ->
	?DB_MODULE:update(player,[{vip_gold, Add, add}],[{id,PlayerId}]).

add_poke_result(PlayerId, Coin, RoomId, IsWin, RbPoint) ->
	case ?DB_MODULE:select_one(player, "coin", [{id, PlayerId}], [], [1]) of
		PlayerCoin when is_integer(PlayerCoin) ->
			if
				IsWin =:= 1 andalso Coin >= 0 ->
					?DB_MODULE:update(player,[{coin, Coin, add},{win_num, 1, add},{winning, 1, add},{losing, 0},{after_pay_num, 1, add}],[{id,PlayerId}]),
					log:log_add_coin(PlayerId, Coin, PlayerCoin + Coin, 16004, 16*1000+RoomId);
				true ->
					NewCoin = max(0, PlayerCoin + Coin),
					?DB_MODULE:update(player,[{coin, NewCoin},{lose_num, 1, add},{winning, 0},{losing, 1, add},{after_pay_num, 1, add}],[{id,PlayerId}]),
					log:log_cost_coin(PlayerId, min(PlayerCoin, -Coin), NewCoin, 16004, 16*1000+RoomId)
			end;
		_ ->
			ok
	end.

add_hundred_douniu_yazhu(UID, Coin) ->
	update_offline_player_coin(UID, -Coin, 22001, 22).
%% 	case ?DB_MODULE:select_one(player, "coin", [{id, UID}], [], [1]) of
%% 		PlayerCoin when is_integer(PlayerCoin) ->
%% 			NewCoin = max(0, PlayerCoin - Coin),					
%% 			?DB_MODULE:update(player,[{coin, NewCoin}],[{id,UID}]),
%% 			log:log_cost_coin(UID, Coin, NewCoin, 22001, 22),
%% 			ok;
%% 		_ ->
%% 			ok
%% 	end.

%% 玩家下线, 金币变化(Coin:变化的金币量, 负数为减少, 正数为增加)
update_offline_player_coin(UID, Coin, Source, System) ->
	case ?DB_MODULE:select_one(player, "coin", [{id, UID}], [], [1]) of
		PlayerCoin when is_integer(PlayerCoin) ->
			NewCoin = max(0, PlayerCoin + Coin),
			?DB_MODULE:update(player,[{coin, NewCoin}],[{id,UID}]),
			log:log_cost_coin(UID, Coin, NewCoin, Source, System),
			ok;
		_ ->
			ok
	end.


insert_vip_reward(Id) ->
	?DB_MODULE:insert(vip_reward, [uid], [Id]).

insert_vip_reward(Id, OnlineReward) ->
	?DB_MODULE:insert(vip_reward, [{uid, Id}, {online_reward, util:term_to_bitstring(OnlineReward)}]).

%% 仅GM命令使用
clear_vip_gold(PlayerId) ->
	?DB_MODULE:update(player,[{vip_gold, 0}],[{id,PlayerId}]).

%% 获取所有玩家的魔晶和金币
get_player_money() ->
    ?DB_MODULE:select_all(player,"sum(gold), sum(coin)",[]).


%% 获取财神活动最小的ID
get_min_mammon_id() ->
    case ?DB_MODULE:select_all(temp_mammon, "min(id)", []) of
        [[ID]] ->
            ID;
        _ ->
            error
    end.

%% 获取财神活动最大的ID
get_max_mammon_id() ->
    case ?DB_MODULE:select_all(temp_mammon, "max(id)", []) of
        [[ID]] ->
            ID;
        _ ->
            error
    end.


%% =========================================================================

%% 插入玩家的游戏信息
insert_player_game(UID, Nick, RegTime, Did, ChannelID) ->
	PlayerGame = #player_game{
							  uid = UID,
							  nick = Nick,
							  reg_time = RegTime,
							  did = Did,
							  channel_id = ChannelID
							 },
	insert_player_game(PlayerGame).

insert_player_game(#player_game{} = PlayerGame) ->
	%%NewPlayerGame = PlayerGame#player_game{nick = tool:to_binary(PlayerGame#player_game.nick)},
	ValueList = lists:nthtail(1, tuple_to_list(PlayerGame)),
    FieldList = record_info(fields, player_game),
    ?DB_MODULE:insert(player_game, FieldList, ValueList).

%% 更新玩家的游戏信息
update_player_game(PlayerGame) ->
	?DB_MODULE:update(player_game,[{first_lottery_time, PlayerGame#player_game.first_lottery_time},
							       {first_niuniu_time, PlayerGame#player_game.first_niuniu_time},
							       {first_fowlsbeasts_time, PlayerGame#player_game.first_fowlsbeasts_time},
                                   {first_suoha_time,PlayerGame#player_game.first_suoha_time}],
					  [{uid, PlayerGame#player_game.uid}]).

%% 获取玩家的游戏信息
get_player_game(UID) ->
	ValueList = ?DB_MODULE:select_row(player_game, "*", [{uid, UID}], [], [1]),
	case ValueList of
		[] ->
		    [];
		_ ->
		    list_to_tuple([player_game | ValueList])
	end.


%% 获取老玩家信息
get_old_player(AccountID) ->
	case ?DB_MODULE:select_row(temp_old_player, "state, reward_list", [{account_id, AccountID}, {state, 0}], [], [1]) of
		[State, RewardList] ->
			[State, util:bitstring_to_term(RewardList)];
		_ ->
			[]
	end.

%% 更新老玩家信息
update_old_player(AccountID) ->
	?DB_MODULE:update(temp_old_player,[{state, 1}, {create_time, util:unixtime()}],[{account_id,AccountID}]).


%% ====================压制牌局=============================
%% 插入玩家的压制牌局信息
insert_player_poke_store(UID, Nick, ChannelID) ->
	PlayerPokeStore = #player_poke_store{
							  uid = UID,
							  nick = Nick,
							  channel_id = ChannelID
							 },
	insert_player_poke_store(PlayerPokeStore).

insert_player_poke_store(#player_poke_store{} = PlayerPokeStore) ->
	NewPlayerPokeStore = PlayerPokeStore#player_poke_store{poke_store_list = util:term_to_bitstring(PlayerPokeStore#player_poke_store.poke_store_list)},
	ValueList = lists:nthtail(1, tuple_to_list(NewPlayerPokeStore)),
    FieldList = record_info(fields, player_poke_store),
    ?DB_MODULE:insert(player_poke_store, FieldList, ValueList).

%% 更新玩家的压制牌局信息
update_player_poke_store(PlayerPokeStore) ->
	?DB_MODULE:update(player_poke_store,[{poke_store_list, util:term_to_bitstring(PlayerPokeStore#player_poke_store.poke_store_list)}],
					  [{uid, PlayerPokeStore#player_poke_store.uid}]).

%% 获取玩家的压制牌局信息
get_player_poke_store(UID) ->
	ValueList = ?DB_MODULE:select_row(player_poke_store, "*", [{uid, UID}], [], [1]),
	case ValueList of
		[] ->
		    [];
		_ ->
		    PP = list_to_tuple([player_poke_store | ValueList]),
			PP#player_poke_store{poke_store_list = util:bitstring_to_term(PP#player_poke_store.poke_store_list)}
	end.




%% ====================玩家标签=============================
insert_player_label(#player_label{}=Lable)->
    ValueList = lists:nthtail(1, tuple_to_list(Lable)),
    FieldList = record_info(fields, player_label),
    ?DB_MODULE:insert(player_label, FieldList, ValueList).


update_player_label(#player_label{}=Lable)->
    ?DB_MODULE:update(player_label,
                      [{lable_id, Lable#player_label.lable_id},
                       {reward_num, Lable#player_label.reward_num},
                       {reward_limit,Lable#player_label.reward_limit},
                       {oper_time, Lable#player_label.oper_time}],
                      [{player_id, Lable#player_label.player_id}]).

get_player_label(PlayerId)->
    ?DB_MODULE:select_row(player_label,"lable_id,reward_num,reward_limit,oper_time",[{player_id,PlayerId}],[],[1]).


%% ====================玩家开心值=============================
insert_player_delight(#player_delight{}=Delight)->
    ValueList = lists:nthtail(1, tuple_to_list(Delight)),
    FieldList = record_info(fields, player_delight),
    ?DB_MODULE:insert(player_delight, FieldList, ValueList).


update_player_delight(#player_delight{}=Delight)->
    ?DB_MODULE:update(player_delight,
                      [{room_id,Delight#player_delight.room_id},
                       {delight_value,Delight#player_delight.delight_value},
                       {oper_time,Delight#player_delight.oper_time}],
                      [{player_id,Delight#player_delight.player_id}]).

get_player_delight(PlayerId)->
    ?DB_MODULE:select_row(player_delight,"room_id,delight_value,oper_time",[{player_id,PlayerId}],[],[1]).






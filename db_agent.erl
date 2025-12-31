%%%--------------------------------------
%%% @Module  : db_agent
%%% @Author  : smyx
%%% @Created : 2013.06.30
%%% @Description: 数据库处理模块(杂）
%%%--------------------------------------
-module(db_agent).
-include("common.hrl").
-include("record.hrl").
-compile(export_all).


%% 是否创建角色
is_create(Accname)->
    ?DB_MODULE:select_all(player, "id", [{account_name, Accname}], [], [1]).

%%获取账号信息
update_account_id(AccName) ->
    case ?DB_MODULE:select_row(user,"*",[{account_name, AccName}],[],[1]) of
        [] ->
            AccId = ?DB_MODULE:insert(user, [account_id, account_name, state, id_card_status], [0, AccName, 0, 0]),
            ?DB_MODULE:update(user, [{account_id, AccId}], [{id, AccId}]);
        Data ->
            [AccId, _Acnm, _State, _IdCardState] = Data
    end,
    AccId.

%% 更新角色在线状态
update_online_flag(PlayerId, OnlieFlag) ->
	?DB_MODULE:update(player,[{online_flag, OnlieFlag}],[{id, PlayerId}]).

%%退出服务器集群
del_server(Sid) ->
    ?DB_MODULE:delete(server, [{id, Sid}]).

%%加入服务器集群
add_server(Server) ->
    ?DB_MODULE:replace(server, [{id, Server#server.id}, 
								{domain, Server#server.domain}, 
								{ip, Server#server.ip}, 
								{port, Server#server.port}, 
								{node, Server#server.node}, 
								{online_num,Server#server.online_num}, 
								{total_num,Server#server.total_num},
								{start_time,Server#server.start_time}, 
								{state,Server#server.state},
								{is_control,Server#server.is_control}]).

%% 获取所有服务器集群
select_all_server() ->
    case ?DB_MODULE:select_all(server, "*", []) of
		DataList when is_list(DataList) andalso length(DataList) >  0 ->
			Fun = fun(DataItem) ->
						  ServerRcd = list_to_tuple([server|DataItem]) ,
						  ServerRcd#server{node = list_to_atom(binary_to_list(ServerRcd#server.node)) ,
										   ip = binary_to_list(ServerRcd#server.ip)} 
				  end ,
			lists:map(Fun,DataList) ;
		_ ->
			[]
	end .

%%加入游戏服务器名
add_server_config(ServerId, ServerName) ->
    ?DB_MODULE:replace(server_config, [{id, ServerId}, {name, ServerName}]).

%% 获取游戏服务器名
select_server_name(ServerId) ->
    ?DB_MODULE:select_one(server_config, "name", [{id, ServerId}], [], [1]).
	
%% 获取服务器的配置信息，可以手工加载
select_server_config() ->
    case ?DB_MODULE:select_all(server_config, "*", []) of
		DataList when is_list(DataList) andalso length(DataList) >  0 ->
			Fun = fun(DataItem) ->
						  list_to_tuple([server_config|DataItem]) 
				  end ,
			lists:map(Fun,DataList) ;
		_ ->
			[]
	end .

select_server_player() ->
	case ?DB_MODULE:select_all(server_player, "*", [{last_login,">",1489600800}]) of
		DataList when is_list(DataList) andalso length(DataList) >  0 ->
			Fun = fun(DataItem) ->
						  ServerPlayer = list_to_tuple([server_player|DataItem]),
						  ServerPlayer#server_player{acc_name = binary_to_list(ServerPlayer#server_player.acc_name),
													 acc_type = binary_to_list(ServerPlayer#server_player.acc_type)}
				  end ,
			lists:map(Fun,DataList) ;
		_ ->
			[]
	end .

%% 网关删除指定服务器的玩家
delete_server_player(ServerID, Domain) ->
	?DB_MODULE:delete(server_player,[{serv_id,ServerID}, {domain, Domain}]).

%% 网关删除指定服务器的玩家
delete_server_player_uid(UserId) ->
	?DB_MODULE:delete(server_player,[{uid,UserId}]).

%%添加在线玩家
add_server_player(ServPlayer) ->
    ServerKey = data_config:get_server_player_key(ServPlayer#server_player.serv_id),
 	ValueList = lists:nthtail(1, tuple_to_list(ServPlayer)) ,
    FieldList = record_info(fields, server_player) ,
	?DB_MODULE:replace(ServerKey, FieldList, ValueList).
%%     ServerKey = data_config:get_server_player_key(ServPlayer#server_player.serv_id),
%% 	ValueList = lists:nthtail(1, tuple_to_list(ServPlayer)) ,
%%     FieldList = record_info(fields, server_player) ,
%% 	?DB_MODULE:insert_get_id(ServerKey, FieldList, ValueList) .

update_server_player(ServPlayer) ->
	ServerKey = data_config:get_server_player_key(ServPlayer#server_player.serv_id),
	?DB_MODULE:update(ServerKey, 
					  [{domain, ServPlayer#server_player.domain} , 
					   {acc_type, ServPlayer#server_player.acc_type} , 
					   {acc_name, ServPlayer#server_player.acc_name} , 
					   {nick, ServPlayer#server_player.nick},
					   {did, ServPlayer#server_player.did} , 
					   {sex, ServPlayer#server_player.sex} , 
					   {career, ServPlayer#server_player.career},
					   {lv, ServPlayer#server_player.lv},
					   {icon, ServPlayer#server_player.icon} , 
					   {last_ip, ServPlayer#server_player.last_ip} ,
					   {last_login, ServPlayer#server_player.last_login}],
					  [{uid,ServPlayer#server_player.uid}]).

%%World Level
insert_world_level(Num, State, Level, Now) ->
    ?DB_MODULE:insert(world_level, [sid, state, world_level, timestamp], [Num, State, Level, Now]).

update_world_level(Num, State, Level, Now) ->
    ?DB_MODULE:update(world_level, [{state, State},{world_level, Level}, {timestamp, Now}], [{sid, Num}]).

get_world_level(Num) ->
    ?DB_MODULE:select_row(world_level, "state, world_level", [{sid, Num}], [], [1]).

is_world_level_exist(Num) ->
    case ?DB_MODULE:select_row(world_level, "sid", [{sid, Num}], [], [1]) of
        []  -> false;
        [Num] -> true
    end.

%% 获取全部有效的公告
get_all_announce(NowTime) ->
	?DB_MODULE:select_all(sys_announce,"*",[{begin_time,"<=",NowTime},{times,">=",0},{interval,">",0}],[{begin_time,asc}],[]) .

get_announce(AnnId) ->
	?DB_MODULE:select_row(sys_announce,"*",[{id,AnnId}],[],[1]) .

get_announce_by_type(Type) ->
    ?DB_MODULE:select_row(sys_announce,"*",[{type,Type}],[],[1]) .

%% 修改公告
update_announce(AnnId,Interval,PreAnnTime,Times) ->
	?DB_MODULE:update(sys_announce,[{interval, Interval}, {next_time, PreAnnTime + Interval*60},{times, Times}],[{id, AnnId}]).

update_announce_by_type(Type, Content) ->
    ?DB_MODULE:update(sys_announce,[{content, Content}],[{type, Type}]).
 
%% 写入公告
insert_announce(List) ->
%%     io:format("Interval === ~p~n", [List]),
    Field = ["id", "type", "begin_time", "end_time", "interval", "next_time", "times", "content"],
    ?DB_MODULE:insert(sys_announce, Field, List).

%%获取所有数据
get_all_server_data() ->
	?DB_MODULE:select_all(temp_server_data,"*",[],[],[]) .
%%模块数据回写
insert_server_data(Key,Data) ->
	TermData = util:term_to_string(Data),
    ?DB_MODULE:insert(temp_server_data,[key,data],[Key,TermData]).

%%模块数据回写
insert_server_data(Key,Data, Desc) ->
	TermData = util:term_to_string(Data),
	TermDesc = Desc,
    ?DB_MODULE:insert_get_id(temp_server_data,[key,data,desc],[Key,TermData,TermDesc]).


%%根据key获取数据
get_server_data(Key) ->
	case   ?DB_MODULE:select_row(temp_server_data,"data",[{key,Key}],[],[1])  of
		[] -> [];
		[Data] -> util:bitstring_to_term(Data)
	end.

%%根据Key更新数据
update_server_data(Key,Data, Desc) ->
	TermData = util:term_to_string(Data),
	TermDesc = Desc,
	?DB_MODULE:update(temp_server_data,[{data,TermData},{desc, TermDesc}],[{key,Key}]).

%%根据Key更新数据
update_server_data(Key,Data) ->
	TermData = util:term_to_string(Data),
	?DB_MODULE:update(temp_server_data,[{data,TermData}],[{key,Key}]).

%%根据Key删除
delete_server_data(Key) ->
	?DB_MODULE:delete(temp_server_data,[{key,Key}]).

%%语音存放
insert_chat_sound(SoundData) ->
	NewSoundData = util:term_to_bitstring(SoundData),
	Now = util:unixtime(),
   	Ret = ?DB_MODULE:insert_get_id(chat_sound, [create_time, sound_data], [Now, NewSoundData]),
    Ret.
get_chat_sound(SoundId) ->
	?DB_MODULE:select_row(chat_sound,"sound_data",[{id,SoundId}],[],[1]) .

%%战报存放
insert_battle_record(BattleReport) ->
	NewBattleReport = util:term_to_bitstring(BattleReport),
%% 	NewBattleReport = mysql:encode(BattleReport, false),%%<<34:8, BattleReport/binary, 34:8>>,
   	Ret = ?DB_MODULE:insert_get_id(battle_record, [battle_report], [NewBattleReport]),
    Ret.
get_battle_record(BattleId) ->
	?DB_MODULE:select_row(battle_record,"battle_report",[{id,BattleId}],[],[1]) .

get_all_battle() ->
	?DB_MODULE:select_all(battle_record, "*", []).

update_battle_record(Id, Data) ->
	?DB_MODULE:update(battle_record,[{battle_report,Data}],[{id,Id}]).

%%用卡号查卡记录
get_card_info(CardNO) ->
	?DB_MODULE:select_row(cards,"*",[{card_no,CardNO}]).

%%激活卡，保存玩家信息
active_card(CardNO,Uid, NickName,AccID, Time) ->
	?DB_MODULE:update(cards,[{uid, Uid}, {nick, NickName}, {account_id, AccID}, {activate_time, Time}],[{card_no,CardNO}]).

%%检查玩家是否已经使用过同类卡型
check_card_used(Key,Player_id) ->
	case ?DB_MODULE:select_row(cards,"*",[{uid,Player_id}, {key, Key}]) of
		[] -> false;
		_ -> true
	end.

get_all_accid() ->
	?DB_MODULE:select_all(player, "account_id, account_type", []).


get_all_player_name() ->
	?DB_MODULE:select_all(player, "id, nick", []).
	
	
%% 机器人测试随机发牌 
insert_poke_deal(ID, BombList, TableCards) ->
	?DB_MODULE:insert(test_deal_bomb,[id, tablecards, bomb_list, insert_time],
					  [ID, util:term_to_bitstring(TableCards), util:term_to_bitstring(BombList), util:unixtime()]).
	
    
%% ====================================================================
%% @author x-men
%% @doc @todo Add description to db_agent_robot.
%% ====================================================================
-module(db_agent_robot).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-compile([export_all]).

%% ====================================================================
%% Internal functions
%% ====================================================================

%% 创建初始化玩家
create_robot([RobotId,Nick,Sex,Facelook,Coin,Vip,RType,Win,Lose,Sign])->
    Robot = #robot_player{   
            id = RobotId,
            gender = Sex,                    
            nick = unicode:characters_to_binary(Nick,utf8),                                      %% 玩家名    
            type = RType,                                     %% 玩家身份原型
            signature=unicode:characters_to_binary(Sign,utf8),                                   %% 签名   
            skin = 0,
            coin = Coin,                                      %% 皮肤
            facelook = Facelook,                              %% 头像ID
            vip = Vip,
            win_num = Win,
            lose_num = Lose,
            table_attr=util:term_to_bitstring([]) 
            },
    ValueList = lists:nthtail(1, tuple_to_list(Robot)),
    FieldList = record_info(fields, robot_player),
    %%?Print({FieldList,ValueList}),
    ?DB_MODULE:insert(robot_player, FieldList, ValueList),
    RobotId.

count_robot()->
    case ?DB_MODULE:select_count(robot_player, []) of
        [Num]->Num;
        _->0
    end.

get_robot_ids()->
    ?DB_MODULE:select_all(robot_player, "id", []).


%% 通过角色ID取得帐号信息
get_info_by_id(PlayerId) ->
    ValueList = ?DB_MODULE:select_row(robot_player, "*", [{id, PlayerId}], [], [1]),
    case ValueList of
        [] ->
            [];
        _ ->
            RobotPlayer0 = list_to_tuple([robot_player|ValueList]),
            RobotPlayer1 = RobotPlayer0#robot_player{
                            table_attr = util:bitstring_to_term(RobotPlayer0#robot_player.table_attr)                       
                            },
            RobotPlayer1
    end.


%%保存玩家基本信息
save_robot_table(RobotId, FieldList, ValueList)->
    ?DB_MODULE:update(robot_player,FieldList,ValueList, "id", RobotId).
    

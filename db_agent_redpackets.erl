%% ====================================================================
%% @author yangping
%% @doc @todo Add description to db_agent_redpackets.
%%       红包广场
%% ====================================================================
-module(db_agent_redpackets).
-include("common.hrl").
-include("record.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).

%% ====================================================================
%% Internal functions
%% ====================================================================
sel_redpackets()->
    case ?DB_MODULE:select_all(red_packets_plaza, "*", []) of
        DataList when is_list(DataList) andalso length(DataList) >  0 ->
            DataList1 = [list_to_tuple([red_packets_plaza|DataItem]) || DataItem <- DataList],
            DataList2 = [Item#red_packets_plaza{recv_list=util:bitstring_to_term(Recv)}
                        ||#red_packets_plaza{recv_list=Recv}=Item<-DataList1],
            DataList2;
        _ ->
            []
    end.

%% 加入红包
insert_redpackets(#red_packets_plaza{}=RedPackets)->
    ?DB_MODULE:insert_get_id(red_packets_plaza,
                             [red_coin,red_min,red_max,sender_id,sender_face,
                              sender_name,send_acct,recv_list,send_time,guess_time,state,
                              red_sign,db_op],
                             [RedPackets#red_packets_plaza.red_coin,
                              RedPackets#red_packets_plaza.red_min,
                              RedPackets#red_packets_plaza.red_max,
                              RedPackets#red_packets_plaza.sender_id,
                              RedPackets#red_packets_plaza.sender_face,
                              RedPackets#red_packets_plaza.sender_name,
                              RedPackets#red_packets_plaza.send_acct,
                              util:term_to_bitstring(RedPackets#red_packets_plaza.recv_list),
                              RedPackets#red_packets_plaza.send_time,
                              RedPackets#red_packets_plaza.guess_time,
                              RedPackets#red_packets_plaza.state,
                              RedPackets#red_packets_plaza.red_sign,
                              RedPackets#red_packets_plaza.db_op
                             ]).
        

%% 删除
del_redpackets(#red_packets_plaza{red_id=RedId}=_RedPackets)->
    ?DB_MODULE:delete(red_packets_plaza, [{red_id, RedId}]).



%% player redpackets
%% --------------------------------------------
insert_player_redpackets(#player_redpackets{player_id=Uid,red_record=Record}=_Packets)->
    ?DB_MODULE:insert(player_redpackets,
                      [player_id,red_record], 
                      [Uid,util:term_to_bitstring(Record)]).


update_player_redpackets(#player_redpackets{}=Packets)->
    ?DB_MODULE:update(player_redpackets,
                      [{player_id, Packets#player_redpackets.player_id},
                       {red_record,util:term_to_bitstring(Packets#player_redpackets.red_record)}],
                      [{player_id, Packets#player_redpackets.player_id}]).

get_player_redpackets(PlayerId)->
    ?DB_MODULE:select_row(player_redpackets,"player_id,red_record",[{player_id,PlayerId}],[],[1]).
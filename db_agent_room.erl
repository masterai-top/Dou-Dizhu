%% @author kexiaopeng
%% @doc @todo Add description to db_agent_room.


-module(db_agent_room).

%% ====================================================================
%% API functions
%% ====================================================================
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("room.hrl").

-compile(export_all).




%% ====================================================================
%% Internal functions
%% ====================================================================
get_room_game_info(RoomId) ->
	ValueList = ?DB_MODULE:select_row(room_game_info, "*", [{room_id, RoomId}], [], [1]),
	case ValueList of
		[] ->
		    [];
		_ ->
		    Data = list_to_tuple([room_game_info|ValueList]),
			Data#room_game_info{limit_time = util:bitstring_to_term(Data#room_game_info.limit_time)}			 
	end.

updata_room_game_info(RoomInfo) ->
	?DB_MODULE:replace(room_game_info, [{room_id, RoomInfo#room_game_info.room_id}, 
										{type, RoomInfo#room_game_info.type}, 
										{is_open, RoomInfo#room_game_info.is_open}, 
										{enroll_num, RoomInfo#room_game_info.enroll_num},
										{limit_time, util:term_to_bitstring(RoomInfo#room_game_info.limit_time)}]).

get_player_room_game(PlayerId) ->
	ValueList = ?DB_MODULE:select_row(player_room_game, "*", [{uid, PlayerId}], [], [1]),
	case ValueList of
		[] ->
			[];
		_ ->
			Data = list_to_tuple([player_room_game|ValueList]),
			Data#player_room_game{room_info = util:bitstring_to_term(Data#player_room_game.room_info), 
								  match_info = util:bitstring_to_term(Data#player_room_game.match_info),
								  room_list = util:bitstring_to_term(Data#player_room_game.room_list)}
	end.

updata_player_room_game(PlayerData) ->
	?DB_MODULE:replace(player_room_game, [{uid, PlayerData#player_room_game.uid}, 
										  {table_point, PlayerData#player_room_game.table_point}, 
										  {match_info, util:term_to_bitstring(PlayerData#player_room_game.match_info)}, 
										  {room_info, util:term_to_bitstring(PlayerData#player_room_game.room_info)},
										  {room_list, util:term_to_bitstring(PlayerData#player_room_game.room_list)}]).




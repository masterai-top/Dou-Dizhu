%% Author: Administrator
%% Created: 2013-7-3
%% Description: TODO: Add description to db_agent_offline
-module(db_agent_offline).

%%
%% Include files
%%
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").

-compile(export_all).
%%
%% Exported Functions
%%
%% -export([]).

%%
%% API Functions
%%
get_offline_all() ->
	?DB_MODULE:select_all(offline_info, "*", []).

%% 获取玩家离线信息
get_offline_info(PlayerId) ->
	?DB_MODULE:select_row(offline_info,  "*", [{uid, PlayerId}]).

%% 增加离线信息
insert_offline_info(Info) ->
    InfoForDB = Info#offline_info{
                        uinfo = util:term_to_string(Info#offline_info.uinfo),
						uattr = util:term_to_string(Info#offline_info.uattr),
						battle = util:term_to_string(Info#offline_info.battle),
						par = util:term_to_string(Info#offline_info.par),
						other = ""
                       },
    ValueList = lists:nthtail(1, tuple_to_list(InfoForDB)),
    FieldList = record_info(fields, offline_info),
    ?DB_MODULE:insert(offline_info, FieldList, ValueList).

%% 更新离线信息
update_offline_info(Info) ->
	?DB_MODULE:update(offline_info,
					  [{uinfo, util:term_to_string(Info#offline_info.uinfo)},
					   {uattr, util:term_to_string(Info#offline_info.uattr)},
					   {battle, util:term_to_string(Info#offline_info.battle)},
					   {par, util:term_to_string(Info#offline_info.par)}],
					  [{uid, Info#offline_info.uid}]).

%%
%% Local Functions
%%


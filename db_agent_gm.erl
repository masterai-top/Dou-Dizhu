%%%-------------------------------------------------------------------
%%% @author henry
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Aug 2018 9:34 AM
%%%-------------------------------------------------------------------
-module(db_agent_gm).
-author("henry").

-include("common.hrl").
-include("record.hrl").

%% API
-compile(export_all).

%% ==============================邮件发送===================================
insert_gm_mail(UserID, NickName, SendType, Channel, SendTime, SendTimeStamp, EmailTitle,
    Context1, Context2, OperatorName, CheckName, Status, System, IsDel) ->
    ?DB_LOG_MODULE:insert(log_gm_mail,
        [user_id, nick_name, send_type, channel, system, send_time, send_timestamp, email_title,
            email_context1, email_context2, operator_name, check_operator_name, status, is_del],
        [UserID, NickName, SendType, Channel, System, SendTime, SendTimeStamp, EmailTitle,
            Context1, Context2, OperatorName, CheckName, Status, IsDel]).

update_gm_mail(EmailID, UserID, NickName, SendType, Channel, SendTime, SendTimeStamp, EmailTitle,
    Context1, Context2, OperatorName, CheckName, Status, System, IsDel) ->
    ?DB_LOG_MODULE:update(log_gm_mail,
        [user_id, nick_name, send_type, channel, system, send_time, send_timestamp, email_title,
            email_context1, email_context2, operator_name, check_operator_name, status, is_del],
        [UserID, NickName, SendType, Channel, System, SendTime, SendTimeStamp, EmailTitle,
            Context1, Context2, OperatorName, CheckName, Status, IsDel],
        "email_id", EmailID).

update_gm_mail_status(EmailID, CheckName, Status) ->
    ?DB_LOG_MODULE:update(log_gm_mail, [check_operator_name, status], [CheckName, Status], "email_id", EmailID).

select_gm_mail(Where, Limit) ->
    DataList = ?DB_LOG_MODULE:select_all(log_gm_mail, "*", Where, [{send_timestamp, desc}], Limit),
    [Data -- [lists:nth(8, Data)] || Data <- DataList].

select_single_gm_mail(Field, Where) ->
    ?DB_LOG_MODULE:select_row(log_gm_mail, Field, Where).

select_single_gm_mail(EmailID) ->
    [UserID] = ?DB_LOG_MODULE:select_row(log_gm_mail, "user_id", [{email_id, EmailID}]),
    UserID.

select_gm_mail_count(Where) ->
    [TotalCount] = ?DB_LOG_MODULE:select_count(log_gm_mail, Where),
    ?IF(TotalCount rem 20 =:= 0, TotalCount div 20, TotalCount div 20 + 1).


%% ==============================封号===================================
insert_gm_ban_player(UserID, Nick, LoginIp, IMei, StopStatus, StopMsg, OperatorName, StopTime) ->
    ?DB_LOG_MODULE:insert(log_gm_ban,
        [user_id, nick_name, login_ip, imei, stop_status, stop_msg, operator_name, stop_time],
        [UserID, Nick, LoginIp, IMei, StopStatus, StopMsg, OperatorName, StopTime]).

update_gm_ban_player(StopID, UserID, Nick, LoginIp, IMei, StopStatus, StopMsg, OperatorName, StopTime) ->
    ?DB_LOG_MODULE:update(log_gm_ban,
        [user_id, nick_name, login_ip, imei, stop_status, stop_msg, operator_name, stop_time],
        [UserID, Nick, LoginIp, IMei, StopStatus, StopMsg, OperatorName, StopTime],
        "stop_id", StopID).

select_gm_ban(Where, Limit) ->
    ?DB_LOG_MODULE:select_all(log_gm_ban, "*", Where, [], Limit).

select_gm_ban_count(Where) ->
    [TotalCount] = ?DB_LOG_MODULE:select_count(log_gm_ban, Where),
    ?IF(TotalCount rem 20 =:= 0, TotalCount div 20, TotalCount div 20 + 1).


%% ==============================公告===================================
insert_gm_system_title(TitleName, TitleContext, Channel, SendTime, EndTime, Status, OperatorName, GameType) ->
    ?DB_LOG_MODULE:insert(log_gm_title,
        [title_name, title_context, channel, send_time, end_time, status, operator_name, game_type],
        [TitleName, TitleContext, Channel, SendTime, EndTime, Status, OperatorName, GameType]).


update_gm_system_title(TitleID, Status) ->
    ?DB_LOG_MODULE:update(log_gm_title, [status], [Status], "title_id", TitleID).

update_gm_system_title(TitleID, TitleName, TitleContext, Channel, SendTime, EndTime, Status, OperatorName, GameType) ->
    ?DB_LOG_MODULE:update(log_gm_title,
        [title_name, title_context, channel, send_time, end_time, status, operator_name, game_type],
        [TitleName, TitleContext, Channel, SendTime, EndTime, Status, OperatorName, GameType],
        "title_id", TitleID).

select_gm_title_context(TitleID) ->
    ?DB_LOG_MODULE:select_row(log_gm_title, "title_context", [{title_id, TitleID}]).

select_gm_system_title(Where, Limit) ->
    ?DB_LOG_MODULE:select_all(log_gm_title, "*", Where, [{title_id, desc}], Limit).

select_gm_system_title_count(Where) ->
    [TotalCount] = ?DB_LOG_MODULE:select_count(log_gm_title, Where),
    ?IF(TotalCount rem 20 =:= 0, TotalCount div 20, TotalCount div 20 + 1).


%% ===============================跑马灯====================================
insert_gm_light(LightTitle, LightType, System, Channel, LightContext, SendTime, EndTime, RunSpeed, OperatorName, Status, GameType) ->
    ?DB_LOG_MODULE:insert(log_gm_light,
        [light_title, light_type, system, channel, light_context, send_time, end_time, run_speed, operator_name, status, game_type],
        [LightTitle, LightType, System, Channel, LightContext, SendTime, EndTime, RunSpeed, OperatorName, Status, GameType]).

update_gm_light(LightID, LightTitle, LightType, System, Channel, LightContext, SendTime, EndTime, RunSpeed, OperatorName, Status, GameType) ->
    ?DB_LOG_MODULE:update(log_gm_light,
        [light_title, light_type, system, channel, light_context, send_time, end_time, run_speed, operator_name, status, game_type],
        [LightTitle, LightType, System, Channel, LightContext, SendTime, EndTime, RunSpeed, OperatorName, Status, GameType],
        "light_id", LightID).

update_gm_light(LightID, Status) ->
    ?DB_LOG_MODULE:update(log_gm_light, [status], [Status], "light_id", LightID).

select_gm_light(Where, Limit) ->
    ?DB_LOG_MODULE:select_all(log_gm_light, "*", Where, [{light_id, desc}], Limit).

select_gm_light_context(LightID) ->
    ?DB_LOG_MODULE:select_row(log_gm_light, "light_context", [{light_id, LightID}]).

select_gm_light_count(Where) ->
    [TotalCount] = ?DB_LOG_MODULE:select_count(log_gm_light, Where),
    ?IF(TotalCount rem 20 =:= 0, TotalCount div 20, TotalCount div 20 + 1).
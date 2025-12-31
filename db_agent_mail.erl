%%--------------------------------------
%% @Module  : db_agent_mail
%% @Author  : water
%% @Created : 2013.02.06
%% @Description: 邮件系统
%%--------------------------------------
-module(db_agent_mail).

-include("common.hrl").
-include("record.hrl").

-compile(export_all).

%%邮件物品格式: 
%%[{GoodTypeId, Num, State},...]
%%GoodTypeId为物品类型ID, Num为物品的数量, State为附件物品状态, 1:有效(未提取), 0:已提取
%%玩家私人邮件不允许发送物品

%%邮件回馈到GM
insert_feedback(Type, PlayerId, Name, Content, Timestamp, IP, Server) ->
    FieldList = [type, subtype, state, uid, name, content, timestamp, ip, server],
    ValueList = [Type, 1, 0, PlayerId, Name, Content, Timestamp, IP, Server],
    ?DB_MODULE:insert(feedback, FieldList, ValueList).

%%查询反馈回复
get_feedback(PlayerId) ->
   ?DB_MODULE:select_all(feedback,"id, type, state, name, content, timestamp, gm, reply, reply_time", [{uid, PlayerId}]).

%%删除反馈
delete_feedback(FbId) ->
   ?DB_MODULE:delete(feedback, [{id, FbId}]).

%% 插入邮件到表mail
insert_mail(Uid, Type, SubType, Title, Timestamp, ExpiredTime, Content, State, IsAttach, GoodsList, OtherData) ->
	MailId = mod_id_global:get_id(mail),
	%%NewContent = list_to_binary(BinContent),
	%%BinTitle = unicode:characters_to_binary(Title),
	NewTitle = tool:to_binary(Title),
	NewContent = tool:to_binary(Content),
	%%io:format("~n=====NewContent:~p=====~n", [NewContent]),
    GoodsListStr = util:term_to_bitstring(GoodsList),
	OtherDataStr = util:term_to_bitstring(OtherData),
    ?DB_MODULE:insert(mail, [id, uid, type, subtype, title, timestamp, vt, content, state, is_attach, goods_list, other], 
                            [MailId, Uid, Type, SubType, NewTitle, Timestamp, ExpiredTime, NewContent, State, IsAttach, 
							 GoodsListStr, OtherDataStr]),
	MailId.

%%删除信件
delete_mail(MailId) ->
    ?DB_MODULE:delete(mail, [{id, MailId}]).

%%删除信件
delete_mail(MailId, PlayerId) ->
    ?DB_MODULE:delete(mail, [{id, MailId},{uid, PlayerId}]).

%%删除信件
delete_all_mail(PlayerId) ->
    ?DB_MODULE:delete(mail, [{uid, PlayerId}, {is_attach, "=", 0}]).

%%获取玩家所有信件,按时间戳来排序
get_all_mail_info() ->
    ?DB_MODULE:select_all(mail, "id, type, timestamp", [{subtype , "!=", 0}], [], []).

get_all_mail_info(PlayerId) ->
    ?DB_MODULE:select_all(mail, "id, type, timestamp", [{uid, PlayerId}, {subtype , "!=", 0}], [], []).

%%获取玩家所有信件,按时间戳来排序, 不拿透明邮件
get_mail_all(Uid) ->
    %%MailList = ?DB_MODULE:select_all(mail, "*", [{uid, Uid},{type,"!=",2},{subtype, 1}],[{timestamp,asc}],[]),
	MailList = ?DB_MODULE:select_all(mail, "*", [{uid, Uid},{subtype, 1}],[{timestamp,asc}],[]),
    %%转换一下GoodsList
    F = fun(Mail, MList) ->
        case Mail of 
            [MailId, Uid, Type, SubType, Title, TimeStamp, ExpiredTime, Content, State, IsAttach, GList | _] ->
                [[MailId, Uid, Type, SubType, Title, TimeStamp, ExpiredTime, Content, 
				  State, IsAttach, util:bitstring_to_term(GList)]|MList];
            _ -> 
                MList
        end
    end,
    lists:foldr(F, [], MailList).

%% 获取未领取附件的公开邮件(所有邮件)
get_attachment_mail(Uid) ->
    %%MailList = ?DB_MODULE:select_all(mail, "*", [{uid, Uid},{type,"!=",2},{subtype, 1}],[{timestamp,asc}],[]),
	MailList = ?DB_MODULE:select_all(mail, "*", [{uid, Uid},{subtype, 1},{is_attach, 1}],[{timestamp,asc}],[]),
    %%转换一下GoodsList
    F = fun(Mail, MList) ->
        case Mail of 
            [MailId, _Uid, Type, _SubType, _Title, _TimeStamp, _ExpiredTime, _Content, _State, _IsAttach, GList | _] ->
                [[MailId, Type, util:bitstring_to_term(GList)]|MList];
            _ -> 
                MList
        end
    end,
    lists:foldr(F, [], MailList).

%% 获取未领取附件的公开邮件(单个邮件)
get_attachment_mail(Uid, MailID) ->
    %%MailList = ?DB_MODULE:select_all(mail, "*", [{uid, Uid},{type,"!=",2},{subtype, 1}],[{timestamp,asc}],[]),
	MailList = ?DB_MODULE:select_all(mail, "*", [{id, MailID}, {uid, Uid},{subtype, 1},{is_attach, 1}],[],[1]),
    %%转换一下GoodsList
    F = fun(Mail, MList) ->
        case Mail of 
            [MailId, _Uid, Type, _SubType, _Title, _TimeStamp, _ExpiredTime, _Content, _State, _IsAttach, GList | _] ->
                [[MailId, Type, util:bitstring_to_term(GList)]|MList];
            _ -> 
                MList
        end
    end,
    lists:foldr(F, [], MailList).

%% 获取玩家的透明邮件
get_transparent_mail(Uid) ->
	MailList = ?DB_MODULE:select_all(mail, "*", [{uid, Uid}, {subtype, 0}],[],[]),
    %%转换一下GoodsList
    F = fun(Mail, MList) ->
        case Mail of
            [MailId, Uid, Type, SubType, Title, TimeStamp, ExpiredTime, Content, _State, _IsAttach, GList, Other] ->
				GoodsList = util:bitstring_to_term(GList),
				OtherData = util:bitstring_to_term(Other),
                [[MailId, Uid, Type, SubType, Title, TimeStamp, ExpiredTime, Content, GoodsList, OtherData]|MList];
            _ ->
                MList
        end
    end,
    lists:foldr(F, [], MailList).

%% 获取邮件附件内容
get_mail_attachment(MailId, PlayerId) ->
	case ?DB_MODULE:select_all(mail, "vt, goods_list", [{id, MailId}, {uid, PlayerId}], [], [1]) of
		[] -> [];
		[[Vt, GList] | _T] ->
			[util:bitstring_to_term(GList), Vt]
	end.

%% 更新邮件的状态
update_attachment_mail_state(MailId, IsAttach) ->
	?DB_MODULE:update(mail, [{is_attach, IsAttach}, {state, 0}], [{id, MailId}]).

%% 更新邮件状态
update_mail(Data, Field, Key, Value) ->
	?DB_MODULE:update(mail, Field, Data, Key, Value).

update_mail_state(MailId, UID, State) ->
	?DB_MODULE:update(mail, [{state, State}], [{id, MailId}, {uid, UID}]).
	

%% 更新信件的物品附件
update_attachment(MailId, GoodsList) ->
    GoodsListStr = util:term_to_string(GoodsList),
    ?DB_MODULE:update(mail, [{goods_list, GoodsListStr}], [{id, MailId}]).                         

%%获取玩家最新的信件类型
get_latest_mail_type(Uid) ->
    ?DB_MODULE:select_one(mail, "type", [{uid, Uid}],[{timestamp,desc}],[1]).

%%插入私人邮件日志
insert_mail_log(Time, SName, Uid, GoodsList, Act) ->
    GoodsListStr = util:term_to_string(GoodsList),
    ?DB_LOG_MODULE:insert(log_mail,  [time, sname, uid, goods_list, act], 
                                     [Time, SName, Uid, GoodsListStr, Act]).

%% 获取战报邮件
get_mail_battle(PlayerId,Type) ->
	?DB_MODULE:select_all(mail,"id,content",[{uid,PlayerId},{type,Type}],[{timestamp,asc}],[]).

%% 更新战报邮件
update_mail_battle(Id,Content) ->
    ?DB_MODULE:update(mail, [{content, Content},{timestamp,util:unixtime()}], [{id, Id}]).   


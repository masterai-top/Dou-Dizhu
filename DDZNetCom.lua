-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   yaoyurong
-- @Last Modified time: 2017-09-06 18:11:00


local M = class("DDZNetCom")

function M:ctor()
    self:init()
end

function M:init()
end

--proto_16_table.hrl
--请求进入房间
function M:req16000(roomId, is_upgrade, is_lower)
    local upgrade = 0
    if is_upgrade then
        upgrade = 1

    elseif is_lower then
        upgrade = 2
    end
    netCom.send({roomId, upgrade}, 16000, function(pack)
        local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_join_room")
        self:on16000(info, roomId)
    end)
end

function M:on16000(info, roomId)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, info)

    local retCode = info.ret_code
    if retCode ~= 0 then
        Game.DDZPlayCom:errorHandle(retCode)
        return
    end
    local layer = Game.uiManager:getLayer("DDZResultUI")
    if layer then layer:destroy() end
    -- 等待服务端拉
    if roomId == 0 then
        return
    end
    Game.DDZPlayCom:onEnterGameRoom(info)
end

--玩家进入牌局
function M:on16001(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_join_table")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "=========on 16001 Player enter room==========")

    Game.DDZPlayCom:onWaitStartGame(info)
end

--倒计时到游戏开始
function M:build16004From16002(info16002)
    local tableInfo = info16002.table_info
    local ret16004 = {}
    ret16004.state = tableInfo.state
    ret16004.state_pos = tableInfo.state_pos
    ret16004.state_time = tableInfo.state_time
    ret16004.round_state = 0
    local playerPoke = tableInfo.play_cards
    local myPos = Game.DDZPlayDB:getMyPos()
    for k,v in pairs(playerPoke) do
        local pos = v.pos
        local cards = v.cards
        if #cards > 0 and pos ~= myPos then
            ret16004.round_state = 1
        end
        Game.DDZPlayCom:onPlayCards(v, true) --忽略记牌器
    end
    return ret16004
end

--倒计时
function M:on16002(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_table_start")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "======16002 on game begin============")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, info)
    
    Game.DDZPlayCom:onStartGame(info)
end

--系统发牌
function M:on16003(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_table_dealing")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "======on 16003 system send card============")

    Game.DDZPlayCom:onSystemSendCards(info)
end

--牌局状态信息
function M:on16004(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_table_state")

    dump(info)

    Game.DDZPlayCom:onTableStateChange(info)
end

--玩家牌局操作
function M:req16005(state, playPos, value)
    local sendData = {state, playPos, value}
    Log(LOG.TAG.DDZ, LOG.LV.INFO, sendData)
    netCom.send(sendData, 16005)
end

function M:on16005(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_player_choose_state")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===on 16005 player choose state===")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, info)

    Game.DDZPlayCom:onPlayerChooseState(info)
end

--玩家出牌
function M:req16006(toSvrPokes, laiZiChange)
    local sendInfo = {#toSvrPokes, toSvrPokes, #laiZiChange, laiZiChange}
    netCom.send(sendInfo, 16006)
end

--通知出牌
function M:on16006(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_player_play_cards")
    Game.DDZPlayCom:onPlayCards(info)
end

--牌局中的倍数信息
function M:on16007(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_table_double")
    Game.DDZPlayDB:setDoublesInfo(info.doubles)
end

--牌局结果
function M:on16008(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_table_result")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "=======on 16008 game end=========")
    Game.DDZPlayCom:onPlayGameEnd(info)
end

--玩家重新开始
function M:req16009(uid, mingpai)
    netCom.send({uid, mingpai}, 16009, function(pack)
        Game.DDZNetCom:on16009(pack)
    end)
end

function M:on16009(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_player_restart")
    Game.DDZPlayCom:onReStartGame(info)
end

--玩家推出斗地主
function M:req16010(uid, callback)
    netCom.send({uid}, 16010, function(pack)
        Game.DDZNetCom:on16010(pack,callback)
    end)
end

function M:on16010(pack,callback)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_player_leave")
    local retCode = info.ret_code
    if retCode == 0 then
        Game.DDZPlayDB:setInPlaying(false)
        if callback ~= nil then
            callback()
        end
    end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("======on 16010 player leave game retCode %d========", retCode))
end

--确定玩家身份和底牌
function M:on16011(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_table_cards")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("======on 16011 show game dipai and player========"))
    Log(LOG.TAG.DDZ, LOG.LV.INFO, info)

    Game.DDZPlayCom:onGetTableDiPai(info)
end

--玩家托管
function M:req16012(nowState)
    local sendData = {nowState}
    netCom.send(sendData, 16012)
end

function M:on16012(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_player_trust")
    local retCode = info.ret_code
    if retCode == 0 then
        Game.DDZPlayDB:setTuoguan(info.pos, info.state)
    else
        Game.DDZPlayCom:errorHandle(retCode)
    end
end

function M:sendemoticon(face_id, to_pos)
    netCom.send({face_id, to_pos}, 16013)
end

--玩家发表情
function M:on16013(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_player_emoticon")
    local retCode = info.ret_code

    if retCode == 0 then
        local playUi = Game.DDZPlayCom:getPlayUi()
        if playUi then playUi:on16013(info) end
    else
        Game.DDZPlayCom:errorHandle(retCode)
    end
end

--比赛场信息
function M:req16014(roomId)
    netCom.send({roomId}, 16014)
end

function M:on16014(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_get_match_info")
    -- dump(info)
    local retCode = info.ret_code
    if retCode == 0 then
        Game.DDZPlayCom:onEvent(DDZEvent.DDZ_ON_16014, info)
    else
        Game.DDZPlayCom:errorHandle(retCode)
    end
end

--报名参加比赛场
function M:req16015(roomId, callback)
    netCom.send({roomId}, 16015, function(pack)
        local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_enroll_match")
        self:on16015(info, callback)
    end)
end

function M:on16015(info, callback)
    local retCode = info.ret_code
    if retCode == 0 then
        local roomId = info.roomid
        Game.DDZPlayDB:setRoomId(roomId)
        
        if callback then
            callback(info)
        end
    else
        Game.DDZPlayCom:errorHandle(retCode)
    end
end

--报名人数
function M:on16016(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_enroll_number")
    Game.DDZPlayDB:setCurRoomNumOfPeople(info.number)

    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_ON_16016, info)
end

--取消报名比赛场
function M:req16017(roomId, callback)
    netCom.send({roomId}, 16017, function(pack)
        local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_cancel_match")
        if info.ret_code == 0 then
            if callback then
                callback(info)
            end
        else
            Game.DDZPlayCom:errorHandle(info.ret_code)
        end
    end)
end

--比赛等待匹配中
function M:on16018(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_wait_match")
    -- dump(info)
    Game.DDZPlayDB:setRoomId(info.room_id)
    local tableNum = info.table_number

    if Game:getScenceIdx() ~= SCENCE_ID.DDZ then
        Game:openGameWithIdx(SCENCE_ID.DDZ)
    end

    if tableNum > 0 then
        Game:setWaitUITxt(stringCfgCom.content("ddz_wait_bisai_mingdan"), WAIT_TYPE.RUN_ANI)
    else
        Game:setWaitUITxt(stringCfgCom.content("ddz_wait_start"), WAIT_TYPE.RUN_ANI)
    end
end

--获取比赛局数信息
function M:req16019(roomId)
    netCom.send({roomId}, 16019)
end

function M:on16019(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_get_match_turn_info")
    -- dump(info)
    local retCode = info.ret_code
    if retCode == 0 then
        Game.DDZPlayDB:setMatchLevel(info.type)
        Game.DDZPlayCom:onGetMatchInfo(info)
    else
        Game.DDZPlayCom:errorHandle(retCode)
    end
end

--比赛结果
function M:on16020(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_match_result")
    -- dump(info)
    Game:destroyDDZWaitUI()
    Game.DDZPlayCom:showDDZMatchRewardUI(info)
end

--晋级转换分数
function M:on16021(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_match_change_point")
    -- dump(info)
    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_ON_16021, info)
end

--牌局任务
function M:on16022(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_poke_task")
    Game.DDZPlayCom:showGameTask(info, true)
end

--完成牌局任务
function M:on16023(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_finish_poke_task")
    Game.DDZPlayCom:finishGameTask(info)
end

--使用记牌器
function M:req16024()
    netCom.send({Game.playerDB:getPlayerUid()}, 16024, function(pack)
        local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_poke_use_note")
        self:on16024(info)
    end)
end

function M:on16024(info)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, info.use_cards)
    if info.ret_code ~= 0 then
        Game.DDZPlayCom:errorHandle(info.ret_code)
        return
    end
    Game.DDZPlayCom:onUseQpqHandle(info)
end

--牌局总宝箱数量
function M:on16026(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_player_box_num")
    Game.DDZPlayCom:onGameBoxNum(info)
end

--房间人数
function M:req16027()
    netCom.send({Game.playerDB:getPlayerUid()}, 16027, function(pack)
        local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_poke_room_num")
        self:on16027(info)
    end)
end

function M:on16027(info)
    Game.DDZPlayCom:onEvent(16027, info)
    
    Game.DDZPlayDB:setRoomNumList(info.num_list)
    Game:dispatchCustomEvent(GlobalEvent.GET_ROOM_NUM_EVENT)
end

--触发英雄技能buff
function M:req16028(skill_id, buff_type, data)
    data = data or {}
    netCom.send({skill_id, buff_type, #data, data}, 16028)
end

function M:on16028(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_trigger_skill")
    Game.DDZPlayCom:onHandleTriggerSkill(info)
end

-- 通知玩家准备开始实物大奖赛
function M:on16029(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_notice_ready_match")

    if Game:getScenceIdx() ~= SCENCE_ID.DDZ then
        Game.DDZPlayCom:showBackToMatchWaitConfirm(info.room_id)
    end
end

--玩家准备开始实物大奖赛
function M:req16030(roomId , callback)
    netCom.send({roomId}, 16030, function(pack)
        local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_ready_match")
        self:on16030(info, callback)
    end)
end

function M:on16030(info, callback)
    if callback then
        callback(info)
    end
end

--机器人魔法表情金币消耗通知
function M:on16032(pack)
    local info,cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_poke_player_state")
    Game.DDZPlayCom:onPokePlayerStateChange(info.players)
end

--请求退出匹配
function M:req16033()
    local uid = Game.playerDB:getPlayerUid()
    netCom.send({uid}, 16033)
end

function M:on16033(pack)
    local info,cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_poke_table_notify")
    Game.DDZPlayCom:onMatchTable(info)
end

--测试使用
function M:on16035(pack)
    local info,cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_poke_round_notify")
    Game.DDZPlayCom:onPokeRoundNotify(info)
end

function M:on16040(pack)
    local info, cursor = netCom.parsePackByProtocol(pack, cursor, "s2c_logout_room")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "======16040 logout game============")
    Game.DDZPlayCom:onLogoutRoom(info)
end

return M:new()

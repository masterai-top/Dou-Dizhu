-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-12-23 10:10:30


local M = class("DDZSkillMgr")

-- 技能效果：
-- 1:(小乔OK)提升叫地主概率---[[{1,[30]},30%的概率优先叫地主]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).使用结果：这时若成功获得优先叫地主的机会，则播技能动作和特效；
-- 3).如果使用这个技能的人是自己，且成功地优先叫地主，“叫地主”按钮上出现高亮（法术）特效。
-- (全部玩家可见)

-- 2:(孙尚香OK)提升获得牌的概率(2或者王)---[[{2,[15,20]},20%获得2]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).如果成功获得2或者王，则播放技能动作和特效，从发牌开始这张牌就挂着一个特效光泽，持续10秒左右自然消失，这期间buff图标是发亮的状态。
-- (该技能发动效果仅自己可见)

-- 3:(周瑜OK)不显示手牌(队友可见)---[[{3,[5]},剩余5张时不显示手牌]]
-- 1).玩家入场时该人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).当剩余牌数到达规定数字时，播放技能动作和特效，buff图标处发亮，桌面中间出现特效字：“对手已无法看到您的手牌数量”；
-- 3).对方看到的手牌数字变为“？”
-- （该技能发动效果仅自己可见）

-- 4:(诸葛亮OK)透视底牌---[[{4,[{6000,1},{10000,2}]},60%透视1张底牌，40%透视2张底牌]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).发牌后，地主牌开牌之前，如果触发技能则播技能动作和特效，底牌出现x张半透明牌并闪烁
-- (全部玩家可见，其他玩家看到的3张底牌不是数字而是一个眼睛图标)

-- 5:(貂蝉OK)条件替换底牌---[[{5,[5,10]},用自己5~10的手牌中的一张和底牌中的一张随机替换]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).发完牌之后，地主牌出现之前如果可发动技能，则播技能动作和特效，这时手牌中可选的牌高亮特效，
--   手牌上方出现一行字和两个按钮，字是“可选一张高亮牌与地主牌对换”，两个按钮是亮的“不换”和置灰的“换牌”，
--   选择一张牌伸出，“换牌”按钮就可点击，点击“换牌”，选中的牌消失，手牌中出现一张新的牌并插入手牌中。（同翻底牌动画）
-- 3).如果是他人的技能，地主牌开牌之前，会看到该人物buff图标处发光特效同时头上出现技能名字

-- 6:(鲁智深OK)透视癞子牌---[[{6,[{6000,1}]},60%透视1张癞子牌]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).触发技能时则播技能动作和特效，上方癞子牌呈现半透明装且闪烁并显示（透视）癞子牌
-- 3).若条件满足可以换癞子牌，在手牌上出现一行询问是否换牌的提示文字及发光的“不换”和“换牌”按钮。
-- 4).点击“换牌”按钮，癞子牌变化，牌上面一道划光特效并发个光，同时牌左边出现“癞子牌已被更改”的特效字样
-- 5).如果多人玩家都有这个技能，则按发动顺序显示。
-- (全部玩家可见，其他玩家看到的癞子牌不是数字而是一个眼睛图标，牌被替换时弹出提示“癞子牌已被替换”)

-- 7:条件替换癞子牌--[[{7,[3,5]},当癞子牌是3~5时可以在翻癞子牌前对此区间内进行随机替换]]

-- 8:(关羽OK)赢得牌局后，对方每张手牌为你增加金币---[[{8,[0.2]},赢得牌局时，对方每张手牌为你增加0.2%金币]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).打完牌时，如果触发技能则播技能动作和特效，且自己的buff图标处发亮。播完技能特效再播胜利动作
-- 3).结算面板上的金币显示为【金币+（buff图标）技能增加的金币】

-- 9:(武松OK)输得牌局后，根据自己手牌数量减免亏损金币(每打出1张手牌减免0.2%)--[[{9,[0.2]},输掉牌局时，自己每打出一张手牌为你减免0.2%金币]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).牌局对家打完牌时（也就是输了），则播技能动作和特效；先播技能再哭
-- 3).结算面板上的金币显示为【金币-（buff图标）技能减免的金币】；

-- 10:修改出牌时间(可正可负)--[[{10,[5,-4,0]},轮到出牌时[我方出牌+5时间,对方出牌-4时间,友方出牌+0时间]]]

-- 11:(李逵)特殊牌型增加金币,每次打出飞机、连对、顺子、火箭、炸弹时，赢钱增加25%--[[{11,[5,10,9,8,1,2]},5%，每次打出1飞机 2连对 3顺子 4火箭 5炸弹赢钱增加5%]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).每次打出对应牌型时，则播技能动作和特效，buff图标处冒金币和“+”号，人物头上出现技能名字；
-- 3).结算面板上的金币显示为【金币+（buff图标）技能增加的金币】

-- 12:(花荣)加倍倍数增加,加倍和超级加倍时倍数+1---[[{12,[1]},加倍和超级加倍时倍数+1]]
-- 1).玩家入场时在人物旁标记一个buff图标，表示激活了技能；
-- 2).使用“加倍”和“超级加倍”时，则播技能动作和特效，头上出现技能文字，倍数图标处迸出一些加号（该效果全玩家可见）。如果多名玩家都发动技能，则按照施法顺序轮流播放
-- 3).触发该技能后，加倍详情页内对应的“农民加倍”、“地主加倍”旁盖一个“百步穿杨UP”的章

-- 13:(潘金莲)明牌后输赢金钱数变化,明牌后赢钱增加20%，输钱减少10%--[[{13,[20,10]}],明牌后赢钱增加20%，输钱减少10%]]
-- 1).玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2).点击“明牌”后，则播技能动作和特效；
-- 3).结算面板上的金币显示为【金币±（buff图标）技能增加的金币】

-- 14:(孙二娘)每次自己出牌后无人跟牌，赢钱增加3%---[[{14,[5]},每次自己出牌后无人跟牌，赢钱增加5%]]
-- 1.玩家入场时在人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2.每次该人物出牌后，若下两家都“过”，则播技能动作和特效；buff图标处做一个跳金币和冒“+”号的特效表现。
-- 3.结算面板上的金币显示为【金币+（buff图标）技能增加的金币】

local DEBUG = false

function M:ctor()
    self.m_play_ui = nil
end

function M:isTriggerSkill(pos)
    if not self.m_trigger_list then
        return false
    end
    if not self.m_trigger_list[pos] then
        return false
    end
    return (self.m_trigger_list[pos] >= 1)
end

function M:setTriggerSkill(pos, net)
    if not self.m_trigger_list then
        return false
    end
    if not self.m_trigger_list[pos] then
        self.m_trigger_list[pos] = 0
    end
    self.m_trigger_list[pos] = self.m_trigger_list[pos]+1

    if self:getPlayUI() and not net then
        self:getPlayUI():onPlayerInfoRefresh()
    end
    return self.m_trigger_list[pos]
end

function M:setFreezeCards(pos, cards)
    if not self.m_freeze_cards then
        return false
    end
    if not self.m_freeze_cards[pos] then
        self.m_freeze_cards[pos] = {}
    end
    local len = table.nums(cards)/2
    for i=1,len do
        local ci = 2*i-1
        local ri = 2*i
        local card = cards[ci] or 0
        local round = cards[ri] or 0
        table.insert(self.m_freeze_cards[pos], {card = card, round = round})
    end
    return self.m_freeze_cards[pos]
end

function M:reduceFreezeRound(pos)
    local clear_list = {}
    for i,v in ipairs(self.m_freeze_cards[pos] or {}) do
        if v.round > 0 then
            self.m_freeze_cards[pos][i].round = v.round-1
        end
        if self.m_freeze_cards[pos][i].round <= 0 then
            clear_list[v.card] = true
        end
    end
    self:HandleClearFreezeEffect(pos, clear_list)
end

function M:isFreezeCard(pos, num)
    local list = self.m_freeze_cards[pos] or {}
    for i,v in ipairs(list) do
        if v.card == num and v.round > 0 then
            return true
        end
    end
    return false
end

function M:getFreezeCards(pos)
    local freeze_list = {}
    local list = self.m_freeze_cards[pos] or {}
    for i,v in ipairs(list) do
        if v.round > 0 then
           freeze_list[v.card] = v.round
        end
    end
    return freeze_list  
end

-- skill_info: [skill_id, 0, 0, 0]
-- 1,金币变化技能(“额外获得%s金币” or “输钱减少%s金币”) ok
-- [skill_id, skill_type, 增加金币, 减少金币]

-- 2,叫地主技能(“优先叫地主”)
-- [skill_id, skill_type, (1优先叫地主, 0否), 0]

-- 3,癞子替换(“透视癞子牌” or “透视癞子牌；癞子牌由%s替换为%s”) ok
-- [skill_id, skill_type, 原底牌, 换的牌]

-- 4,倍数增加(“加倍倍数增加%s” or “超级加倍倍数增加%s”) ok
-- [skill_id, skill_type, 增加倍数, 0]

-- 5,底牌替换(“底牌由%s替换为%s”)
-- [skill_id, skill_type, 原底牌, 换的牌]

-- 6,得到2数、得到王数(“得到%s张2、%s张王”)
-- [skill_id, skill_type, 得到2数, 得到王数]

-- 7,牌数显示(“冻结对手%s张手牌”, “透视对手%s张手牌”)
-- [skill_id, skill_type, 冻结手牌数/透视手牌数, 0, 0]

-- 8,透视底牌(“透视%s张底牌”)
-- [skill_id, skill_type, 0, 0]

-- 9,(“隐藏手牌张数”)
-- 10,(“尚未触发技能”)

function M:getTriggerSkillDesc(pos, skin, data, win)
    if not data then return "尚未触发技能", false end
    local viewPos = Game.DDZPlayDB:getViewPosWithSvrPos(pos)

    local cards = data.cards or {}
    local skill_info = data.skill_info or {}
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "=====getTriggerSkillDesc viewPos is: " .. tostring(viewPos))
    Log(LOG.TAG.DDZ, LOG.LV.INFO, skill_info)

    local skill_ids = GoodsConfig.skill_list(skin) or {}
    local skill_id = skill_ids[1]
    if not skill_id then
        return "尚未触发技能", false
    end
    local desc = SkillConfig.skill_desc(skill_id) or "尚未触发技能"
    local s_type = SkillConfig.skill_type(skill_id)

    if DDZSkillType.T_POKE_NUM == s_type then
        local param = self:getSkillEffectParam(skin, DDZSkillEffType.ET_POKE_NUM)
        local poke_num = param[1] or 18
        local cards_num = table.nums(cards)
        local trigger = (poke_num >= cards_num)
        return desc, trigger
    end
    if table.nums(skill_info) <= 0 then
        return "尚未触发技能", false
    end
    local id = skill_info[1]
    local tp = skill_info[2]
    local d1 = skill_info[3]
    local d2 = skill_info[4]
    if tp == DDZSkillEffType.ET_JIAO_DIZU then
        if d1==1 then return "优先叫地主", true end

    elseif tp == DDZSkillEffType.ET_HUODE_POKE then
        if d1 > 0 and d2 > 0 then
            return string.format("得到%s张2、%s张王", tostring(d1), tostring(d2)), true
        elseif d1 > 0 then
            return string.format("得到%s张2", tostring(d1)), true
        elseif d2 > 0 then
            return string.format("得到%s张王", tostring(d2)), true
        end

    elseif tp == DDZSkillEffType.ET_KAN_DIPAI then
        if d1>1 then return string.format("透视%s张底牌", tostring(d1)), true end

    elseif tp == DDZSkillEffType.ET_HUANG_DIPAI then
        local oriNum = math.floor(d1/10)
        local chgNum = math.floor(d2/10)
        if d1>0 then return string.format("底牌由%s替换为%s", self:getShowPokeWord(oriNum), self:getShowPokeWord(chgNum)), true end

    elseif tp == DDZSkillEffType.ET_HUANG_LAIZI then
        local oriNum = math.floor(d1/10)
        local chgNum = math.floor(d2/10)
        if d1>0 then return string.format("透视癞子牌,癞子牌由%s替换为%s", self:getShowPokeWord(oriNum), self:getShowPokeWord(chgNum)), true end

    elseif tp == DDZSkillEffType.ET_WIN_ZENGJIA_JINBI 
        or tp == DDZSkillEffType.ET_PX_ADD_JINBI
        or tp == DDZSkillEffType.ET_FINISH_PAI then
        if d1>0 then
            local base = data.coin/(1+(d1/100))
            local extra = string.format("%.2f", math.max(0, (data.coin-base)))
            return string.format("额外获得%s金币", tostring(extra)), true 
        end

    elseif tp == DDZSkillEffType.ET_MINGPAI_JINBI then
        if d1>0 and win then
            local base = data.coin/(1+(d1/100))
            local extra = string.format("%.2f", math.max(0, (data.coin-base)))
            return string.format("额外获得%s金币", tostring(extra)), true 
        end
        if d2>0 and not win then
            local base = data.coin/(1-(d2/100))
            local extra = string.format("%.2f", math.max(0, (base-data.coin)))
            return string.format("输钱减少%s金币", tostring(extra)), true 
        end

    elseif tp == DDZSkillEffType.ET_LOST_JIAN_JINBI then
        if d2>0 then
            local base = data.coin/(1-(d2/100))
            local extra = string.format("%.2f", math.max(0, (base-data.coin)))
            return string.format("输钱减少%s金币", tostring(extra)), true 
        end

    elseif tp == DDZSkillEffType.ET_DOUBLE_ADD then
        if d2>0 then return string.format("超级加倍倍数增加%s", tostring((d1+d2))), true end
        if d1>0 then return string.format("加倍倍数增加%s", tostring(d1)), true end

    elseif tp == DDZSkillEffType.ET_KAN_SHOU_PAI then
        if d1>0 then return string.format("透视对手%s张手牌", tostring(d1)), true end

    elseif tp == DDZSkillEffType.ET_BREZZ_SHOU_PAI then
        if d1>0 then return string.format("冻结对手%s张手牌", tostring(d1)), true end
    end
    return "尚未触发技能", false
end

function M:init(play_ui)
    self.m_play_ui = play_ui
    self:clearSkillBuff()
end

function M:getPlayUI()
    return self.m_play_ui
end

function M:getBuffList()
    return self.m_buff_list
end

function M:clearSkillBuff()
    self.m_dipai = {}
    self.m_laizi = {}
    self.m_buff_list = {}
    self.m_trigger_list = {}
    self.m_freeze_cards = {}

    if not self:getPlayUI() then return end
    local widget = self:getPlayUI():getWidgets()
    if not widget then return end

    local panSkill = widget.panSkill
    panSkill:setVisible(false)
end

function M:isHaveBuff(pos, buff_type)
    local buffs = self.m_buff_list[pos] or {}
    for i,buff in ipairs(buffs) do
        if buff == buff_type then
            return true
        end
    end
    return false
end

function M:addBuff(pos, buff_type)
    if self:isHaveBuff(pos, buff_type) then
        return
    end
    self.m_buff_list[pos] = self.m_buff_list[pos] or {}
    table.insert(self.m_buff_list[pos], buff_type)
end

function M:removeBuff(pos, buff_type)
    if not self:isHaveBuff(pos, buff_type) then
        return
    end
    local buffs = self.m_buff_list[pos] or {}
    for i,buff in ipairs(buffs) do
        if buff == buff_type then
            table.remove(buffs, i)
            break
        end
    end
end

function M:onTriggerSkill(skill_type, data)  
end

function M:onTriggerSkillEffType(pos, skill_type, eff_type, data)
    if not Game.DDZPlayDB:getIsHeroRoom() then return end
    data = data or {}

    local playerData = Game.DDZPlayDB:getDDZPlayer(pos)
    local skin = playerData.skin
    if skin == 0 or not GoodsConfig[skin] then return end

    for k,id in ipairs(GoodsConfig.skill_list(skin)) do
        local s_type = SkillConfig.skill_type(id)
        if s_type == skill_type then
            local effects = SkillConfig.effect(id)
            for i,v in ipairs(effects or {}) do
                local e_type = v[1]
                if e_type == eff_type then
                    self:onSkillEffect(id, e_type, v, playerData, data)
                end
            end
        end
    end
end

function M:playSkill(player_data, skill_type, data)
    if not Game.DDZPlayDB:getIsHeroRoom() then return end

    local skin = player_data.skin
    if skin == 0 or not GoodsConfig[skin] then
        return
    end
    for i,v in ipairs(GoodsConfig.skill_list(skin)) do
        local s_type = SkillConfig.skill_type(v)
        if s_type == skill_type then
            self:onSkill(v, player_data, data)
        end
    end
end

function M:onSkill(id, player_data, data)
    if not SkillConfig[id] then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===ddz play skill is null id is: " .. tostring(id))
        return
    end
    data = data or {}
    local effects = SkillConfig.effect(id)
    for i,v in ipairs(effects or {}) do
        local eff_type = v[1]
        self:onSkillEffect(id, eff_type, v, player_data, data)
    end
end

function M:onSkillEffect(id, eff_type, eff_data, player_data, data)
    switch(eff_type)
    {
        [DDZSkillEffType.ET_JIAO_DIZU]            = function() self:HandleSkillJiaoDiZu(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_HUODE_POKE]           = function() self:HandleSkillHuoDePoke(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_POKE_NUM]             = function() self:HandleSkillBuXianShiShouPai(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_KAN_DIPAI]            = function() self:HandleSkillKanDiPai(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_HUANG_DIPAI]          = function() self:HandleSkillHuangDiPai(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_KAN_LAIZI]            = function() self:HandleSkillKanLaiZi(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_HUANG_LAIZI]          = function() self:HandleSkillHuangLaiZi(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_WIN_ZENGJIA_JINBI]    = function() self:HandleSkillWinJiaJinbi(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_LOST_JIAN_JINBI]      = function() self:HandleSkillLostJianJinbi(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_XIUGAI_SHIJIAN]       = function() self:HandleSkillXiuGaiShiJian(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_PX_ADD_JINBI]         = function() self:HandleSkillPXAddJinbi(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_DOUBLE_ADD]           = function() self:HandleSkillAddDouble(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_MINGPAI_JINBI]        = function() self:HandleSkillMingPaiJinbi(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_FINISH_PAI]           = function() self:HandleSkillFinishPai(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_KAN_SHOU_PAI]         = function() self:HandleSkillKanShouPai(id, eff_data, player_data, data) end,
        [DDZSkillEffType.ET_BREZZ_SHOU_PAI]       = function() self:HandleSkillBrezzShouPai(id, eff_data, player_data, data) end,
        [Default]   = function() self:HandleDefault() end,
        [Nil]       = function() self:HandleNil() end,
    }  
end

function M:onSkillBeEffect(id, eff_type, eff_data, player_data, data)
    switch(eff_type)
    {
        [Default]   = function() self:HandleDefault() end,
        [Nil]       = function() self:HandleNil() end,
    }     
end

-- {1, {10}}
-- 一旦玩家首发叫地主，则在人物上方闪现技能文字，然后文字消失（该效果全玩家可见）；同时【叫地主】按钮增加高光特效
function M:HandleSkillJiaoDiZu(id, skill_data, player_data, data)
    local pos = data.pos
    local player_pos = player_data.pos
    if not pos or player_pos ~= pos then
        return
    end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillJiaoDiZu pos is: " .. tostring(pos))
    
    self:setTriggerSkill(pos)
    self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_JIAO_DIZU, player_data.skin)

    if Game.DDZPlayDB:isMyPos(pos) then
        local button = self:getPlayUI():getAutoBtn()
        self:onSkillPokeEffect(DDZSkillEffType.ET_JIAO_DIZU, button)
    end
end

-- {2, {15,10}}
-- 手牌中出现对应的牌时，该牌显示高光特效；人物头顶闪现技能文字，然后文字消失（该效果仅自己可见）
function M:HandleSkillHuoDePoke(id, skill_data, player_data, data)
    local pos = data.pos
    local num = data.num
    local poke = data.poke
    if not pos or not num or not poke then return end
    if not Game.DDZPlayDB:isMyPos(pos) then return end

    local is_effect = false
    local effects = SkillConfig.effect(id)
    for i,v in ipairs(effects or {}) do
        local eff_type = v[1]
        if DDZSkillEffType.ET_HUODE_POKE == eff_type then
            local param = v[2] or {}
            local card_num = param[1] or 0
            if card_num == num then
                is_effect = true
                self:onSkillPokeEffect(DDZSkillEffType.ET_HUODE_POKE, poke)
                self:onSkillPokeEffect(DDZSkillEffType.ET_HUODE_POKE, poke, {action="paimianliuguang"}, false)
            end            
        end
    end
    if not is_effect then return end
    if self:isTriggerSkill(pos) then return end

    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillHuoDePoke pos is: " .. tostring(pos))
    self:setTriggerSkill(pos)
    self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_HUODE_POKE, player_data.skin)
end

-- 3:{3,[5]},剩余5张时不显示手牌
-- 手牌达到对应张数时，人物头顶闪现技能文字，然后文字消失（该效果仅自己可见）；其他玩家看到的手牌数字变为“？”
function M:HandleSkillBuXianShiShouPai(id, skill_data, player_data, data)
    if not self:getPlayUI() then return end

    local pos = data.pos
    local player_pos = player_data.pos

    local param = skill_data[2] or {}
    local poke_num = param[1] or 18
    local cards_num = player_data.cards_num
    if poke_num < cards_num then return end
    if self:isHaveBuff(pos, DDZSkillEffType.ET_POKE_NUM) then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillBuXianShiShouPai pos is: " .. tostring(pos))

    self:setTriggerSkill(pos)
    self:addBuff(pos, DDZSkillEffType.ET_POKE_NUM)

    -- 技能效果
    if Game.DDZPlayDB:isMyPos(pos) then
        self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_POKE_NUM, player_data.skin)

        local size = cc.Director:getInstance():getWinSize()
        local showPos = {x = size.width/2, y = size.height/2}
        self:onSkillDesktopEffect(DDZSkillEffType.ET_POKE_NUM, self:getPlayUI(), showPos)
    end
end

-- {4, {1}}
-- 发牌时，左上方底牌处，显示可看见的底牌
function M:HandleSkillKanDiPai(id, skill_data, player_data, data)
    -- data {state: 1,看底牌(不是我触发则显示闪动特效); 2,换底牌操作; 3,成功更换底牌}
    if not self:getPlayUI() or not data then return end
    if (data.state ~= 1 and data.state ~= 3) then return end

    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillKanDiPai===")

    -- Game.DDZNetCom:req16028(id, DDZSkillEffType.ET_KAN_DIPAI)
    local change_idx = 0
    local diPais = {}
    local pos = data.pos or 0
    -- 看底牌
    if data.state == 1 then
        self.m_dipai = {}
        if Game.DDZPlayDB:isMyPos(pos) then
            for i,v in ipairs(data.data or {}) do
                if v ~= 0 then
                    table.insert(diPais, v)
                end
            end
        else
            self:getPlayUI():showBlinkDiPai(3)
            return
        end
    -- 换底牌
    elseif data.state == 3 then
        local widget = self:getPlayUI():getWidgets()
        if Game.DDZPlayDB:isMyPos(pos) then
            local panSkill = widget.panSkill
            panSkill:setVisible(false)
        end

        diPais = self.m_dipai
        local old_card = data.data[1] or 0
        local new_card = data.data[2] or 0
        for i,v in ipairs(diPais or {}) do
            if v == old_card then
                change_idx = i
            end
        end
        if diPais[change_idx] then
            diPais[change_idx] = new_card
        end
    end
    if #diPais <= 0 then return end

    self.m_dipai = diPais
    local pokes = Game.DDZPlayCom:converSvrPokeToClient(diPais)
    local len = #pokes
    local pokeWidth = self:getPlayUI():getPokeWidth(4)

    local panDi = self:getPlayUI():getDiPaiNode()
    panDi:removeAllChildren()
    local diSize = panDi:getContentSize()

    local start_x = (diSize.width/2)-(pokeWidth/2)*(len-1)
    for i,v in ipairs(pokes or {}) do
        local targetPos = cc.p((start_x+pokeWidth*(i-1)), 0)

        local pokeNode = self:getPlayUI():getPokeNode(v, 4)
        pokeNode:setPosition(targetPos)
        pokeNode:setOpacity(128)
        panDi:addChild(pokeNode)
        if change_idx == i then
            local old_card = data.data[1] or 0
            local new_card = data.data[2] or 0
            self:onSkillPokeEffect(DDZSkillEffType.ET_HUANG_DIPAI, pokeNode, {x=6, y=6})

            Game.DDZPlayDB:changePokeData(new_card, old_card)
            Game.DDZPlayCom:getDDZEffc():playGetDPEffect({old_card})

            if Game.DDZPlayDB:isMyPos(pos) then
                Game:tipMsg("成功更换底牌！")
            end
        end
        common_util.showBlinkEffect(pokeNode, 255*0.2, 255*0.8, 1.5)
    end
    -- 技能效果
    self:setTriggerSkill(pos)
    if Game.DDZPlayDB:isMyPos(pos) then
        self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_KAN_DIPAI, player_data.skin)
        self:onSkillDiPaiKuangEffect(DDZSkillEffType.ET_KAN_DIPAI, pos)
    end
end

-- {5, {8,17}}
-- 抢地主和加倍之间
function M:HandleSkillHuangDiPai(id, skill_data, player_data, data)
    if not self:getPlayUI() or not data then return end
    if (data.state ~= 2 and data.state ~= 3) then return end

    local pos = data.pos or 0
    if data.state == 3 then
        self:HandleSkillHuangDiPaiSucc(id, skill_data, player_data, data)
        return
    end
    if self:isTriggerSkill(pos) then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillHuangDiPai===")

    
    local param = skill_data[2]
    local min = param[1] or 0
    local max = param[2] or 0
    local widget = self:getPlayUI():getWidgets()
    local panSkill = widget.panSkill
    local txtDesc = panSkill:getChildByName("txtDesc")
    txtDesc:setString(string.format("是否使用自己手牌中%s~%s跟底牌随机替换？", self:getShowPokeWord(min), self:getShowPokeWord(max)))

    local btn_ok = panSkill:getChildByName("btn_ok")
    btn_ok:setEnabled(false)
    btn_ok:getChildByName("txt_btnAdd"):setGray(true)

    bindClickFunc(btn_ok, function()
        local nowSelPoke = Game.DDZPlayDB:getSelectedPoke()
        local nowSelPokeData = Game.DDZPlayDB:getSelectedPokesData()
        if #nowSelPokeData <= 0 then
            return
        end
        local pokeData = nowSelPokeData[1]
        Game.DDZNetCom:req16028(id, DDZSkillEffType.ET_HUANG_DIPAI, {pokeData.svrNum})
        panSkill:setVisible(false)
    end)    
    local btn_cancel = panSkill:getChildByName("btn_cancel")
    bindClickFunc(btn_cancel, function()
        self:onTriggerHideSkillPan(0)
    end) 
    panSkill:setVisible(true)
    panSkill:setTouchEnabled(false) 

    local pokeData = Game.DDZPlayDB:getPokesData()
    for k,v in pairs(pokeData or {}) do
        if v.num < min or v.num > max then
            self:onSkillPokeDarkEffect(DDZSkillEffType.ET_HUODE_POKE, v.pokeView)
            -- self:onSkillPokeEffect(DDZSkillEffType.ET_HUODE_POKE, v.pokeView, nil, true)
        end
    end
    self:setTriggerSkill(pos)
    if Game.DDZPlayDB:isMyPos(pos) then
        self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_HUANG_DIPAI, player_data.skin)
    end
end

function M:HandleSkillHuangDiPaiSucc(id, skill_data, player_data, data)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillHuangDiPaiSucc===")

    local pos = data.pos or 0
    local old_card = data.data[1] or 0
    local new_card = data.data[2] or 0

    Game.DDZPlayDB:changePokeData(new_card, old_card)
    Game.DDZPlayCom:getDDZEffc():playGetDPEffect({old_card})

    self:setTriggerSkill(pos)
    if Game.DDZPlayDB:isMyPos(pos) then
        Game:tipMsg("成功更换底牌！")
    end     
end

-- {6, {1}}
-- 发牌时，左上方癞子牌处，直接显示当局癞子牌
function M:HandleSkillKanLaiZi(id, skill_data, player_data, data)
    if not self:getPlayUI() or not data then return end
    if (data.state ~= 1 and data.state ~= 3) then return end

    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillKanLaiZi===")
    -- Game.DDZNetCom:req16028(id, DDZSkillEffType.ET_KAN_LAIZI)
    
    local change_idx = 0
    local diPais = {}
    local pos = data.pos or 0

    if data.state == 1 then
        self.m_laizi = {}
        if Game.DDZPlayDB:isMyPos(pos) then
            for i,v in ipairs(data.data or {}) do
                if v ~= 0 then
                    table.insert(diPais, v)
                end
            end
        else
            self:getPlayUI():showBlinkDiPai(1)
            return
        end
    else
        diPais = self.m_laizi
        local old_card = data.data[1] or 0
        local new_card = data.data[2] or 0
        diPais[1] = new_card
        change_idx = 1
    end
    if #diPais <= 0 then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===DDZSkillMgr HandleSkillKanLaiZi diPais is null===")
        return
    end
    self.m_laizi = diPais
    local pokes = Game.DDZPlayCom:converSvrPokeToClient(diPais)
    local poke = pokes[1]
    poke.lie = true

    local panDi = self:getPlayUI():getDiPaiNode()
    panDi:removeAllChildren()
    local diSize = panDi:getContentSize()

    local pokeNode = self:getPlayUI():getPokeNode(poke, 4)
    pokeNode:setPosition(cc.p(diSize.width/2, 0))
    panDi:addChild(pokeNode)
    common_util.showBlinkEffect(pokeNode, 255*0.2, 255*0.8, 1.5)

    if change_idx == 1 then
        local size = cc.Director:getInstance():getWinSize()
        local showPos = {x = size.width/2, y = size.height/2}

        self:onSkillDesktopEffect(DDZSkillEffType.ET_HUANG_DIPAI, self:getPlayUI(), showPos)
        self:onSkillPokeEffect(DDZSkillEffType.ET_HUANG_DIPAI, pokeNode, {x=6, y=6})

        -- local old_card = data.data[1] or 0
        -- local new_card = data.data[2] or 0
        -- Game.DDZPlayDB:changePokeData(new_card, old_card)

        if Game.DDZPlayDB:isMyPos(pos) then
            -- Game:tipMsg("成功更换癞子牌！")
        end
    end   
    -- 技能效果
    self:setTriggerSkill(pos)
    if Game.DDZPlayDB:isMyPos(pos) then
        self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_HUANG_LAIZI, player_data.skin)
    end
end

-- {7, {8,17}}
-- 翻牌前癞子牌
function M:HandleSkillHuangLaiZi(id, skill_data, player_data, data)
    if not data or data.state ~= 2 then return end

    local pos = data.pos or 0
    if self.m_trigger_list[pos] and self.m_trigger_list[pos] > 1 then return end

    local laizi = self.m_laizi[1]
    if not laizi then return end
    local laiziNum = math.floor(laizi/10)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillHuangLaiZi laizi is: " .. tostring(laizi))

    local param = skill_data[2]
    local min = param[1] or 0
    local max = param[2] or 0
    if laiziNum < min or laiziNum > max then return end

    local has_change = false
    local pokeData = Game.DDZPlayDB:getPokesData()
    for i,v in ipairs(pokeData or {}) do
        if min <= v.num and v.num <= max then
            has_change = true
            break
        end
    end
    if not has_change then return end

    local widget = self:getPlayUI():getWidgets()
    local panSkill = widget.panSkill
    local txtDesc = panSkill:getChildByName("txtDesc")
    txtDesc:setString(string.format("是否使用自己手牌中%s~%s跟癞子牌随机替换？", self:getShowPokeWord(min), self:getShowPokeWord(max)))

    local btn_ok = panSkill:getChildByName("btn_ok")
    bindClickFunc(btn_ok, function()
        Game.DDZNetCom:req16028(id, DDZSkillEffType.ET_HUANG_LAIZI)
        panSkill:setVisible(false)
    end)    
    local btn_cancel = panSkill:getChildByName("btn_cancel")
    bindClickFunc(btn_cancel, function()
        panSkill:setVisible(false)
    end) 
    panSkill:setVisible(true)
    panSkill:setTouchEnabled(true)

    self:setTriggerSkill(pos)
    self:onSkillPokeEffect(DDZSkillEffType.ET_HUANG_LAIZI, btn_ok, nil, true)
end

function M:HandleSkillWinJiaJinbi(id, skill_data, player_data, data)
    if not data then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillWinJiaJinbi===")

    local pos = data.pos or 0
    if Game.DDZPlayDB:isMyPos(pos) then
    end
    self:setTriggerSkill(pos)
    self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_WIN_ZENGJIA_JINBI, player_data.skin)
end

function M:HandleSkillLostJianJinbi(id, skill_data, player_data, data)
    if not data then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillLostJianJinbi===")
    
    local pos = data.pos or 0
    if Game.DDZPlayDB:isMyPos(pos) then
    end
    self:setTriggerSkill(pos)
    self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_LOST_JIAN_JINBI, player_data.skin)
end

function M:HandleSkillXiuGaiShiJian(id, skill_data, player_data, data)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillXiuGaiShiJian===")
end

-- 每次打出对应牌型时，则播技能动作和特效，buff图标处冒金币和“+”号，人物头上出现技能名字；
-- 结算面板上的金币显示为【金币+(buff图标技能)增加的金币】
function M:HandleSkillPXAddJinbi(id, skill_data, player_data, data)
    if not data then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillPXAddJinbi===")

    local pos = data.pos or 0
    if Game.DDZPlayDB:isMyPos(pos) then
    end
    self:setTriggerSkill(pos)
    self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_PX_ADD_JINBI, player_data.skin)
    self:onSkillBuffIconEffect(DDZSkillEffType.ET_PX_ADD_JINBI, pos)
end

-- 使用“加倍”和“超级加倍”时，则播技能动作和特效，头上出现技能文字，倍数图标处迸出一些加号（该效果全玩家可见）
-- 如果多名玩家都发动技能，则按照施法顺序轮流播放
-- 触发该技能后，加倍详情页内对应的“农民加倍”、“地主加倍”旁盖一个“百步穿杨UP”的章
function M:HandleSkillAddDouble(id, skill_data, player_data, data)
    if not data then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillAddDouble===")

    local pos = data.pos or 0
    if Game.DDZPlayDB:isMyPos(pos) then
    end
    self:setTriggerSkill(pos)
    self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_DOUBLE_ADD, player_data.skin)
    self:onSkillBeiShuIconEffect(DDZSkillEffType.ET_DOUBLE_ADD, pos)
end

-- 使用“明牌”时，人物头顶闪现技能文字，然后文字消失（该效果全玩家可见）；结算面板上的金币显示为【金币+技能增加的金币】
function M:HandleSkillMingPaiJinbi(id, skill_data, player_data, data)
    if not data then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillMingPaiJinbi===")

    local pos = data.pos or 0
    if Game.DDZPlayDB:isMyPos(pos) then
    end
    self:setTriggerSkill(pos)
    self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_MINGPAI_JINBI, player_data.skin)
end

-- 每次该人物出牌后，若下两家都“过”，则播技能动作和特效；buff图标处做一个跳金币和冒“+”号的特效表现。
-- 结算面板上的金币显示为【金币+（buff图标）技能增加的金币】
function M:HandleSkillFinishPai(id, skill_data, player_data, data)
    if not data then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillFinishPai===")

    local pos = data.pos or 0
    if Game.DDZPlayDB:isMyPos(pos) then
    end
    self:setTriggerSkill(pos)
    self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_FINISH_PAI, player_data.skin)
    self:onSkillBuffIconEffect(DDZSkillEffType.ET_FINISH_PAI, pos)    
end

-- 1.玩家入场时该人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2.当对方玩家出牌回合时，播放技能动作和特效，buff图标处发亮，
--   依据技能显示特定张数的牌，展示在对方明牌区，3秒后渐淡消失（若对方已名牌则不发动技能）
function M:HandleSkillKanShouPai(id, skill_data, player_data, data)
    if not data then return end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillKanShouPai===")

    local pos = data.pos or 0
    local data = data.data or {}

    if Game.DDZPlayDB:isMyPos(pos) then return end
    if Game.DDZPlayDB:getMingPai(pos) then return end
    local my_pos = Game.DDZPlayDB:getMyPos()
    self:setTriggerSkill(my_pos)

    local cardMap = {}
    local dataLen = table.nums((data or {}))/2
    for i=1,dataLen do
        local pre = (2*i)-1
        local nex = (2*i)
        local idx = data[pre]
        local card = data[nex]

        table.insert(cardMap, card)
    end
    self:getPlayUI():createSkillMPView(pos, cardMap)
    self:onPlayerFlyWord(my_pos, id, DDZSkillEffType.ET_KAN_SHOU_PAI, player_data.skin)
end

-- 1.玩家入场时该人物旁标记一个可查看的buff图标，表示激活了技能；
-- 2.自己出牌回合时，操作按钮处多出一个【冻结】按钮；点击按钮后除对方玩家（若为地主则对方两名）处，
--   界面全部压暗，点击对方玩家则发动技能，播放技能动作和特效，buff图标处发亮
-- 3.被冻结的手牌出现“冰块”特效，不可被点选
function M:HandleSkillBrezzShouPai(id, skill_data, player_data, data)
    if not data then return end

    local pos = data.pos or 0
    if self:isTriggerSkill(pos) then return end
    if not Game.DDZPlayDB:isMyPos(pos) then return end
    
    local param = skill_data[2]
    local cfgData = param[1] or {}
    local maxCards = cfgData[1] or 0
    local betCards = cfgData[2] or 0
    local maxRound = cfgData[3] or 0

    local svrPos1 = Game.DDZPlayDB:getSvrPosWithViewPos(2)
    local svrPos2 = Game.DDZPlayDB:getSvrPosWithViewPos(3)

    local pokesNum1 = Game.DDZPlayDB:getOtherPlayerCardNum(svrPos1)
    local pokesNum2 = Game.DDZPlayDB:getOtherPlayerCardNum(svrPos2)
    if (Game.DDZPlayDB:isFriendPos(svrPos1) or pokesNum1 < maxCards) 
        and (Game.DDZPlayDB:isFriendPos(svrPos2) or pokesNum2 < maxCards) then
        Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillBrezzShouPai pokesNum is: " .. tostring(pokesNum))
        return
    end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZSkillMgr HandleSkillBrezzShouPai maxCards is: " .. tostring(maxCards))

    local min = math.floor((betCards[1] or 0)/10)
    local max = math.floor((betCards[2] or 0)/10)
    local widget = self:getPlayUI():getWidgets()
    local panSkill = widget.panSkill
    local txtDesc = panSkill:getChildByName("txtDesc")
    txtDesc:setString(string.format("是否随机冻结对方手牌中%s~%s的%s张牌？", self:getShowPokeWord(min), self:getShowPokeWord(max), maxRound))

    local btn_ok = panSkill:getChildByName("btn_ok")
    btn_ok:setEnabled(true)
    btn_ok:getChildByName("txt_btnAdd"):setString("冻结")

    bindClickFunc(btn_ok, function()
        self:HandleChooseOtherPlayer(id, maxCards)
    end)

    local btn_cancel = panSkill:getChildByName("btn_cancel")
    bindClickFunc(btn_cancel, function()
        self:onTriggerHideSkillPan(0)
    end) 
    panSkill:setVisible(true)
    panSkill:setTouchEnabled(true) 

    -- if Game.DDZPlayDB:isMyPos(pos) then
    --     self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_BREZZ_SHOU_PAI, player_data.skin)
    -- end
end

function M:HandleChooseOtherPlayer(id, maxCards)
    local svrPos1 = Game.DDZPlayDB:getSvrPosWithViewPos(2)
    local svrPos2 = Game.DDZPlayDB:getSvrPosWithViewPos(3)

    local p_data1 = Game.DDZPlayDB:getDDZPlayer(svrPos1)
    local p_data2 = Game.DDZPlayDB:getDDZPlayer(svrPos2)

    local pokesNum1 = p_data1.cards_num or 0
    local pokesNum2 = p_data2.cards_num or 0

    if not Game.DDZPlayDB:isLandLord() then
        local station1 = p_data1.station
        local station2 = p_data2.station
        if station1 == 2 then
            Log(LOG.TAG.DDZ, LOG.LV.INFO, "===LandLord p_data1 uid is: " .. tostring(p_data1.uid))
            Game.DDZNetCom:req16028(id, DDZSkillEffType.ET_BREZZ_SHOU_PAI, {p_data1.uid})            

        elseif station2 == 2 then
            Log(LOG.TAG.DDZ, LOG.LV.INFO, "===LandLord p_data2 uid is: " .. tostring(p_data2.uid))
            Game.DDZNetCom:req16028(id, DDZSkillEffType.ET_BREZZ_SHOU_PAI, {p_data2.uid})   
        end
        return
    end

    local path1 = GoodsConfig.hero(p_data1.skin)
    local path2 = GoodsConfig.hero(p_data2.skin)
    local scale1 = GoodsConfig.skin_scale_fight(p_data1.skin) or 1.0
    local scale2 = GoodsConfig.skin_scale_fight(p_data2.skin) or 1.0

    local widget = self:getPlayUI():getWidgets()
    local uiRefresh = self:getPlayUI():getDDZUIRefresh()
    local panSkillArea = widget.panSkillArea

    local playerPan1 = panSkillArea:getChildByName("panHero1")
    local playerPan2 = panSkillArea:getChildByName("panHero2")

    local panSize1 = playerPan1:getContentSize()
    local panSize2 = playerPan2:getContentSize()
    playerPan1:setFlippedX(true)
    playerPan1:setVisible((pokesNum1 >= maxCards) and not Game.DDZPlayDB:isFriendPos(svrPos1))
    playerPan2:setVisible((pokesNum2 >= maxCards) and not Game.DDZPlayDB:isFriendPos(svrPos2))

    -- local spineNode1 = uiRefresh:createSpine(path1, "daiji", scale1)
    -- spineNode1:setVisible(true)
    -- spineNode1:setName(path1)
    -- spineNode1:setAnimation(0, "daiji", true)
    -- spineNode1:setPositionX(panSize1.width/2)
    -- playerPan1:addChild(spineNode1)

    local view1 = ccui.ImageView:create(path1)
    view1:setAnchorPoint(cc.p(0.5, 0.0))
    view1:setPosition(cc.p(panSize1.width/2, -140))
    playerPan1:addChild(view1)

    -- local spineNode2 = uiRefresh:createSpine(path2, "daiji", scale2)
    -- spineNode2:setVisible(true)
    -- spineNode2:setName(path2)
    -- spineNode2:setAnimation(0, "daiji", true)
    -- spineNode2:setPositionX(panSize2.width/2)
    -- playerPan2:addChild(spineNode2)

    local view2 = ccui.ImageView:create(path2)
    view2:setAnchorPoint(cc.p(0.5, 0.0))
    view2:setPosition(cc.p(panSize2.width/2, -140))
    playerPan2:addChild(view2)

    bindClickFunc(playerPan1, function()
        Log(LOG.TAG.DDZ, LOG.LV.INFO, "=========p_data1 uid is: " .. tostring(p_data1.uid))
        Game.DDZNetCom:req16028(id, DDZSkillEffType.ET_BREZZ_SHOU_PAI, {p_data1.uid})
    end)

    bindClickFunc(playerPan2, function()
        Log(LOG.TAG.DDZ, LOG.LV.INFO, "=========p_data2 uid is: " .. tostring(p_data2.uid))
        Game.DDZNetCom:req16028(id, DDZSkillEffType.ET_BREZZ_SHOU_PAI, {p_data2.uid})
    end)

    local uiPlayerPan2 = self:getPlayUI():getPlayerHeroImgPan(2)
    local uiPlayerPan3 = self:getPlayUI():getPlayerHeroImgPan(3)
    uiPlayerPan2:setVisible((pokesNum1 < maxCards) or Game.DDZPlayDB:isFriendPos(svrPos1))
    uiPlayerPan3:setVisible((pokesNum2 < maxCards) or Game.DDZPlayDB:isFriendPos(svrPos2))
    panSkillArea:setVisible(true)
end

function M:HandleFreezeEffect(pos, epos, id)
    local freeze_map = self:getFreezeCards(epos)
    local freeze_num = table.nums(freeze_map)

    if freeze_num <= 0 then return end

    if Game.DDZPlayDB:isMyPos(epos) then
        local pokeData = Game.DDZPlayDB:getPokesData()
        for k,v in ipairs(pokeData) do
            local onpPoke = v.pokeView
            if not onpPoke or tolua.isnull(onpPoke) then
                break
            end
            if freeze_map[v.svrNum] then
                Log(LOG.TAG.DDZ, LOG.LV.INFO, "=====HandleFreezeEffect svrNum is: " .. tostring(v.svrNum))
                
                if v.selected == true then
                    Game.DDZPlayCom:onPokeUnSelected(k)
                end
                self:onSkillPokeEffect(DDZSkillEffType.ET_BREZZ_SHOU_PAI, onpPoke, nil, true)
            end
        end
    elseif epos ~= 0 and Game.DDZPlayDB:getMingPai(epos) then
        local vPlayer = Game.DDZPlayDB:getDDZPlayer(epos) or {}
        for k,v in pairs(vPlayer.pokeData or {}) do
            local onpPoke = v.node
            if not onpPoke or tolua.isnull(onpPoke) then
                break
            end
            if freeze_map[v.svrNum] then
                self:onSkillPokeEffect(DDZSkillEffType.ET_BREZZ_SHOU_PAI, onpPoke, {x = 0, y = 0, scale = 0.4}, true)
            end
        end
    end
    if pos > 0 and id > 0 and Game.DDZPlayDB:isMyPos(pos) then
        local playerData = Game.DDZPlayDB:getDDZPlayer(pos)
        local skin = playerData.skin
        self:onPlayerFlyWord(pos, id, DDZSkillEffType.ET_BREZZ_SHOU_PAI, skin)
    end
end

function M:HandleClearFreezeEffect(pos, freeze_map)
    local pokeData = Game.DDZPlayDB:getPokesData()
    for k,v in ipairs(pokeData) do
        local onpPoke = v.pokeView
        if not onpPoke or tolua.isnull(onpPoke) then
            break
        end
        if freeze_map[v.svrNum] then
            onpPoke:removeChildByTag(DDZ.POKE_EFF_TAG)
        end
    end   
end

function M:HandleDefault()
    Log(LOG.TAG.DDZ, LOG.LV.WARN, "===DDZSkillMgr HandleDefault===")
end

function M:HandleNil()
    Log(LOG.TAG.DDZ, LOG.LV.WARN, "===DDZSkillMgr HandleNil===")
end

function M:isSkill(skin, skill_type)
    local skill_ids = GoodsConfig.skill_list(skin)
    if not skill_ids then
        return false
    end
    local skill_id = skill_ids[1]
    if not skill_id then
        return false
    end
    local s_type = SkillConfig.skill_type(skill_id) or 0
    return (s_type == skill_type)
end

function M:checkCanChangePoke(skin, num)
    local skill_ids = GoodsConfig.skill_list(skin)
    if not skill_ids then
        return false
    end
    local skill_id = skill_ids[1]
    if not skill_id then
        return false
    end
    local effects = SkillConfig.effect(skill_id) or {}
    for i,v in ipairs(effects or {}) do
        local e_type = v[1]
        local param = v[2]
        if DDZSkillEffType.ET_HUANG_DIPAI == e_type then
            local min = param[1]
            local max = param[2]
            if num >= min and num <= max then
                return true
            end           
        end
    end
    return false    
end

function M:getSkillEffectParam(skin, eff_type)
    local skill_ids = GoodsConfig.skill_list(skin)
    local skill_id = skill_ids[1]
    if not skill_id then
        return {}
    end
    local effects = SkillConfig.effect(skill_id) or {}
    for i,v in ipairs(effects or {}) do
        local e_type = v[1]
        if eff_type == e_type then
            return v[2] or {}
        end
    end
    return {}
end

function M:getDoubleSkillEffect()
    local ret1, ret2 = 0, 0
    local allPlayer = Game.DDZPlayDB:getAllPlayer()
    for k,v in pairs(allPlayer or {}) do
        local pos = v.pos
        local skin = v.skin
        local station = v.station
        if v.double > 1 and self:isSkill(skin, DDZSkillType.T_DOUBLE_ADD) then
            local param = self:getSkillEffectParam(skin, DDZSkillEffType.ET_DOUBLE_ADD)
            local double = param[1] or 0
            if station == 1 then
                ret1 = ret1+double

            elseif station == 2 then
                ret2 = ret2+double
            end
        end
    end
    return ret1, ret2
end

function M:getShowPokeWord(num)
    local show = num
    if num == 11 then
        show = "J"
    elseif num == 12 then
        show = "Q"
    elseif num == 13 then
        show = "K"
    elseif num == 14 then
        show = "A"
    elseif num == 16 then
        show = "小王"
    elseif num == 17 then
        show = "大王"
    end
    return tostring(show)
end

function M:onTriggerSkillPokeTouch()
    local widget = self:getPlayUI():getWidgets()
    local panSkill = widget.panSkill
    local btn_ok = panSkill:getChildByName("btn_ok")

    local nowSelPoke = Game.DDZPlayDB:getSelectedPoke()
    if #nowSelPoke > 0 then
        btn_ok:setEnabled(true)
        btn_ok:getChildByName("txt_btnAdd"):setGray(false)
    else
        btn_ok:setEnabled(false)
        btn_ok:getChildByName("txt_btnAdd"):setGray(true)
    end
end

function M:onTriggerHideSkillPan(pos)
    if not self:getPlayUI() then return end
    if not Game.DDZPlayDB:getIsHeroRoom() then return end

    local widget = self:getPlayUI():getWidgets()
    local panSkill = widget.panSkill
    local panSkillArea = widget.panSkillArea
    panSkill:setVisible(false)
    panSkillArea:setVisible(false)

    local btn_ok = panSkill:getChildByName("btn_ok")
    btn_ok:removeChildByTag(DDZ.POKE_EFF_TAG)

    local playerPan2 = self:getPlayUI():getPlayerHeroImgPan(2)
    local playerPan3 = self:getPlayUI():getPlayerHeroImgPan(3)
    playerPan2:setVisible(true)
    playerPan3:setVisible(true)

    local pokeData = Game.DDZPlayDB:getPokesData()
    for k,v in pairs(pokeData or {}) do
        local pokeView = v.pokeView
        if pokeView then
            pokeView:setColor(cc.c3b(255, 255, 255))
            -- pokeView:removeChildByTag(DDZ.POKE_EFF_TAG)
        end
    end
    if Game.DDZPlayDB:isMyPos(pos) then
        Game.DDZPlayCom:doUnSelectSelectPokes()
    end
end

function M:onPlayerFlyWord(pos, id, skill_type, skin)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("===DDZSkillMgr onPlayerFlyWord pos is:%s, skill_type is:%s", tostring(pos), tostring(skill_type)))

    local action = nil
    local spineRes = nil
    -- 天赐恩宠(小乔)
    if skill_type == DDZSkillEffType.ET_JIAO_DIZU then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/xiaoqiao/jineng1/jineng/jn_xq1"

    -- 神之祝福(孙尚香)
    elseif skill_type == DDZSkillEffType.ET_HUODE_POKE then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/sunshangxiang/jineng1/jineng/jn_ssx1"

    -- 瞒天过海(周瑜)
    elseif skill_type == DDZSkillEffType.ET_POKE_NUM then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/zhouyu/jineng1/jineng/jn_zy1"

    -- 神机妙算(诸葛亮)
    elseif skill_type == DDZSkillEffType.ET_KAN_DIPAI then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/zhugeliang/jineng1/jineng/jn_zgl1"

    -- 偷梁换柱, 千里冰封(貂蝉)
    elseif skill_type == DDZSkillEffType.ET_HUANG_DIPAI 
        or skill_type == DDZSkillEffType.ET_BREZZ_SHOU_PAI then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/diaochan/jineng1/jineng/jn_dc1"

    -- 偷天换日(鲁智深)
    elseif skill_type == DDZSkillEffType.ET_HUANG_LAIZI then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/luzhishen/jineng1/jineng/jn_lzs1"

    -- 乘胜追击(关羽)
    elseif skill_type == DDZSkillEffType.ET_WIN_ZENGJIA_JINBI then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/guangyu/jineng1/jineng/jn_gy1"

    -- 三碗不过岗, 火眼晶晶(武松)
    elseif skill_type == DDZSkillEffType.ET_LOST_JIAN_JINBI 
        or skill_type == DDZSkillEffType.ET_KAN_SHOU_PAI then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/wusong/jineng1/jineng/jn_ws1"

    -- 巧夺天工(李逵)
    elseif skill_type == DDZSkillEffType.ET_PX_ADD_JINBI then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/likui/jineng1/jineng/jn_lk1"

    -- 百步穿杨(花荣)
    elseif skill_type == DDZSkillEffType.ET_DOUBLE_ADD then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/huarong/jineng1/jineng/jn_hr1" 

    -- 意乱情迷(潘金莲)
    elseif skill_type == DDZSkillEffType.ET_MINGPAI_JINBI then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/panjinlian/jineng1/jineng/jn_pjl1" 

    -- 黑暗料理(孙二娘)
    elseif skill_type == DDZSkillEffType.ET_FINISH_PAI then
        action = "1"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/sunerniang/jineng1/jineng/jn_sen1"
    end

    local viewPos = Game.DDZPlayDB:getViewPosWithSvrPos(pos)
    local playerPan = self:getPlayUI():getPlayerSkillEffPan(viewPos)

    if not spineRes then return end
    local panSize = playerPan:getContentSize()

    local skeletonNode = sp.SkeletonAnimation:create(spineRes..".json", spineRes..".atlas", 1.0)
    skeletonNode:setAnchorPoint(cc.p(0.5, 0.5))
    skeletonNode:setAnimation(0, action, false)
    playerPan:addChild(skeletonNode, 666)
    if viewPos == 2 then
        skeletonNode:setPosition(panSize.width/2, panSize.height/2+10)

    elseif viewPos == 3 then
        skeletonNode:setPosition(panSize.width/2, panSize.height/2+10)
    else
        skeletonNode:setPosition(panSize.width/2, panSize.height/2+10)
    end
    skeletonNode:registerSpineEventHandler(function(event)
        -- skeletonNode:setVisible(false)
        local bgDelay = cc.DelayTime:create(0.6)
        local bgCallback = cc.CallFunc:create(function()
            skeletonNode:removeFromParent(true)
        end)
        local seq = cc.Sequence:create(bgDelay, bgCallback)
        skeletonNode:runAction(seq)

    end, sp.EventType.ANIMATION_COMPLETE)

    self:onSkillBuffIconCommonEffect(skill_type, pos)
    if Game.DDZPlayDB:isMyPos(pos) then
        Game.DDZPlayCom:getDDZEffc():playHeroSound(skin, 4, viewPos)
    end
end

function M:onSkillPokeEffect(skill_type, node, pos, loop)
    pos = pos or {}
    pos.x = pos.x or 0
    pos.y = pos.y or 0

    local action = nil
    local spineRes = nil
    local delayTime = 0.6
    -- 天赐恩宠(小乔)
    if skill_type == DDZSkillEffType.ET_JIAO_DIZU then
        -- action = "paimianliuguang"
        -- spineRes = "res/subgame/ddz/effect/yingxiongjineng/tongyong/qiangdizhu_anniu/doudizhu_yingxiongjineng_paimianliuguang"
        delayTime = 3.0
        action = "jiaodizhu"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/xiaoqiao/jineng1/jiaodizhu/jn_xq1_jiaodizhu"

    -- 神之祝福(孙尚香)
    elseif skill_type == DDZSkillEffType.ET_HUODE_POKE then
        delayTime = 1.0
        action = pos.action or "1"
        if action == "1" then
            pos.scale = 0.95
            spineRes = "res/subgame/ddz/effect/yingxiongjineng/sunshangxiang/jineng1/shaguang/jn_ssx1_shaguang"

        elseif action == "paimianliuguang" then
            delayTime = 3.0
            spineRes = "res/subgame/ddz/effect/yingxiongjineng/tongyong/paimianliuguang2/doudizhu_yingxiongjineng_paimianliuguang"
        end

    -- 神机妙算
    elseif skill_type == DDZSkillEffType.ET_HUANG_DIPAI then
        action = "paimianliuguang"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/tongyong/paimianliuguang1/doudizhu_yingxiongjineng_paimianliuguang"

    -- 千里冰封
    elseif skill_type == DDZSkillEffType.ET_BREZZ_SHOU_PAI then
        action = "bing"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/diaochan/jineng1/bingdong/jn_dc1_bing"

    -- 偷天换日
    elseif skill_type == DDZSkillEffType.ET_HUANG_LAIZI then
        action = "jiaodizhu"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/xiaoqiao/jineng1/jiaodizhu/jn_xq1_jiaodizhu"        
    end
    if not spineRes then return end
    local panSize = node:getContentSize()

    local skeletonNode = sp.SkeletonAnimation:create(spineRes..".json", spineRes..".atlas", 1.0)
    skeletonNode:setPosition(cc.p(panSize.width/2+pos.x, panSize.height/2+pos.y))
    skeletonNode:setAnchorPoint(cc.p(0.5, 0.5))
    skeletonNode:setTag(DDZ.POKE_EFF_TAG)
    if pos.scale then
        skeletonNode:setScale(pos.scale)
    end
    if loop then
        skeletonNode:setAnimation(0, action, true)
        node:addChild(skeletonNode, 666)
        return

    elseif action == "jiaodizhu" then
        skeletonNode:setAnimation(0, action, true)
        node:addChild(skeletonNode, 666)

    elseif (pos.action and pos.action == "paimianliuguang") then
        skeletonNode:setVisible(false)
        skeletonNode:setAnimation(0, action, true)
        node:addChild(skeletonNode, 666)

        local delay = cc.DelayTime:create(0.9)
        local delayCallback = cc.CallFunc:create(function()
            skeletonNode:setVisible(true)
        end)
        local seq = cc.Sequence:create(delay, delayCallback)
        skeletonNode:runAction(seq)

    elseif action == "1" then
        skeletonNode:setAnimation(0, action, true)
        node:addChild(skeletonNode, -1)     
    else
        skeletonNode:setAnimation(0, action, false)
        node:addChild(skeletonNode, 666)
    end
    skeletonNode:registerSpineEventHandler(function(event)
        local bgDelay = cc.DelayTime:create(delayTime)
        local bgCallback = cc.CallFunc:create(function()
            skeletonNode:removeFromParent(true)
        end)
        local seq = cc.Sequence:create(bgDelay, bgCallback)
        skeletonNode:runAction(seq)

    end, sp.EventType.ANIMATION_COMPLETE)
end

function M:onSkillPokeDarkEffect(skill_type, node, pos)
    node:setColor(cc.c3b(159, 168, 176))
end

function M:onSkillClearPokeDarkEffect(skill_type, node, pos)
    node:setColor(cc.c3b(255, 255, 255))
end

function M:onSkillDesktopEffect(skill_type, node, pos)
    pos = pos or {x = 0, y = 0}
    if skill_type == DDZSkillEffType.ET_POKE_NUM then
        local widget = ccui.Text:create()
        widget:setFontSize(44)
        widget:setColor(cc.c3b(255, 255, 255))
        widget:setString(tostring("对手已无法看到您的手牌数量"))
        widget:setAnchorPoint(cc.p(0.5, 0.5))
        widget:setPosition(cc.p(pos.x, pos.y))
        node:addChild(widget, 666)

        local callFunc = cc.CallFunc:create(function()
            widget:removeFromParent()
        end)
        local moveBy = cc.MoveBy:create(3.0, cc.p(0, 0))
        widget:runAction(cc.Sequence:create(moveBy, callFunc))

    elseif skill_type == DDZSkillEffType.ET_HUANG_DIPAI then
        local widget = ccui.Text:create()
        widget:setFontSize(44)
        widget:setColor(cc.c3b(255, 255, 255))
        widget:setString(tostring("癞子牌已被更改"))
        widget:setAnchorPoint(cc.p(0.5, 0.5))
        widget:setPosition(cc.p(pos.x, pos.y))
        node:addChild(widget, 666)

        local callFunc = cc.CallFunc:create(function()
            widget:removeFromParent()
        end)
        local moveBy = cc.MoveBy:create(3.0, cc.p(0, 0))
        widget:runAction(cc.Sequence:create(moveBy, callFunc))        
    end
end

function M:onSkillBuffIconEffect(skill_type, pos)
    local viewPos = Game.DDZPlayDB:getViewPosWithSvrPos(pos)
    local playerEffPan = self:getPlayUI():getPlayerEffPan(viewPos)

    local action = nil
    local spineRes = nil
    if skill_type == DDZSkillEffType.ET_PX_ADD_JINBI then
        action = "tiaojingbi"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/sunerniang/jineng1/tiaojingbi/jn_sen1_tiaojingbi"

    elseif skill_type == DDZSkillEffType.ET_FINISH_PAI then
        action = "tiaojingbi"
        spineRes = "res/subgame/ddz/effect/yingxiongjineng/sunerniang/jineng1/tiaojingbi/jn_sen1_tiaojingbi"
    end

    if not spineRes then return end

    local effSize = playerEffPan:getContentSize()
    local skeletonNode = sp.SkeletonAnimation:create(spineRes..".json", spineRes..".atlas", 1.0)
    skeletonNode:setPosition(cc.p(effSize.width/2, effSize.height/2))
    skeletonNode:setAnchorPoint(cc.p(0.5, 0.5))
    skeletonNode:setAnimation(0, action, false)
    playerEffPan:addChild(skeletonNode, 666)

    skeletonNode:registerSpineEventHandler(function(event)
        local bgDelay = cc.DelayTime:create(0.6)
        local bgCallback = cc.CallFunc:create(function()
            skeletonNode:removeFromParent(true)
        end)
        local seq = cc.Sequence:create(bgDelay, bgCallback)
        skeletonNode:runAction(seq)

    end, sp.EventType.ANIMATION_COMPLETE)

    -- local widget = ccui.Text:create()
    -- widget:setFontSize(30)
    -- widget:setColor(cc.c3b(255, 255, 255))
    -- widget:setString(tostring("+"))
    -- widget:setAnchorPoint(cc.p(0.5, 0.5))
    -- widget:setPosition(cc.p(effSize.width/2, effSize.height/2))
    -- playerEffPan:addChild(widget) 

    -- local callFunc = cc.CallFunc:create(function()
    --     widget:removeFromParent()
    -- end)
    -- local moveBy = cc.MoveBy:create(1.5, cc.p(0, 20))
    -- widget:runAction(cc.Sequence:create(moveBy, callFunc))
end

function M:onSkillBuffIconCommonEffect(skill_type, pos)
    local viewPos = Game.DDZPlayDB:getViewPosWithSvrPos(pos)
    local playerEffPan = self:getPlayUI():getPlayerEffPan(viewPos)

    local action = "tubiao2"
    local spineRes = "res/subgame/ddz/effect/yingxiongjineng/tongyong/tubiao/jn_ty_tubiao"

    local effSize = playerEffPan:getContentSize()
    local skeletonNode = sp.SkeletonAnimation:create(spineRes..".json", spineRes..".atlas", 1.0)
    skeletonNode:setPosition(cc.p(effSize.width/2, effSize.height/2))
    skeletonNode:setAnchorPoint(cc.p(0.5, 0.5))
    skeletonNode:setAnimation(0, action, false)
    playerEffPan:addChild(skeletonNode, 668)

    skeletonNode:registerSpineEventHandler(function(event)
        local bgDelay = cc.DelayTime:create(0.6)
        local bgCallback = cc.CallFunc:create(function()
            skeletonNode:removeFromParent(true)
        end)
        local seq = cc.Sequence:create(bgDelay, bgCallback)
        skeletonNode:runAction(seq)
        
    end, sp.EventType.ANIMATION_COMPLETE)

    if skill_type == DDZSkillEffType.ET_PX_ADD_JINBI then
        return
    end
    local actList = {}
    table.insert(actList, {id = DDZ.ACT_CHUPAI, pos = pos})
    self:getPlayUI():onDoPlayerActor(actList)
end

function M:onSkillBeiShuIconEffect(skill_type, pos)
    local widget = self:getPlayUI():getWidgets()
    local imgDoubles = widget.imgdoubles

    if skill_type == DDZSkillEffType.ET_DOUBLE_ADD then
        local effSize = imgDoubles:getContentSize()

        local spineRes = "res/subgame/ddz/effect/yingxiongjineng/huarong/jineng1/jiabei/jn_hr1_jiabei"
        local skeletonNode = sp.SkeletonAnimation:create(spineRes..".json", spineRes..".atlas", 1.0)
        skeletonNode:setPosition(cc.p(effSize.width/2, effSize.height/2))
        skeletonNode:setAnchorPoint(cc.p(0.5, 0.5))
        skeletonNode:setAnimation(0, "jiabei", false)
        imgDoubles:addChild(skeletonNode, 666)

        skeletonNode:registerSpineEventHandler(function(event)
            local bgDelay = cc.DelayTime:create(0.6)
            local bgCallback = cc.CallFunc:create(function()
                skeletonNode:removeFromParent(true)
            end)
            local seq = cc.Sequence:create(bgDelay, bgCallback)
            skeletonNode:runAction(seq)

        end, sp.EventType.ANIMATION_COMPLETE)

        -- local widget = ccui.Text:create()
        -- widget:setFontSize(30)
        -- widget:setColor(cc.c3b(255, 255, 255))
        -- widget:setString(tostring("+"))
        -- widget:setAnchorPoint(cc.p(0.5, 0.5))
        -- widget:setPosition(cc.p(effSize.width/2, effSize.height/2))
        -- imgDoubles:addChild(widget) 

        -- local callFunc = cc.CallFunc:create(function()
        --     widget:removeFromParent()
        -- end)
        -- local moveBy = cc.MoveBy:create(1.5, cc.p(0, 20))
        -- widget:runAction(cc.Sequence:create(moveBy, callFunc))
    end    
end

function M:onSkillDiPaiKuangEffect(skill_type, pos)
    local panDi = self:getPlayUI():getDiPaiNode()
    local effSize = panDi:getContentSize()

    -- TODO 底框特效暂时只有癞子场
    if skill_type == DDZSkillEffType.ET_KAN_DIPAI then
        -- local spineRes = "res/subgame/ddz/effect/yingxiongjineng/zhugeliang/jineng1/dizhupai/jn_zgl1_dizhupai"
        -- local skeletonNode = sp.SkeletonAnimation:create(spineRes..".json", spineRes..".atlas", 1.0)
        -- skeletonNode:setPosition(cc.p(effSize.width/2, 0))
        -- skeletonNode:setAnchorPoint(cc.p(0.5, 0.5))
        -- skeletonNode:setAnimation(0, "dizhupai", true)
        -- panDi:addChild(skeletonNode, 666)

        -- skeletonNode:registerSpineEventHandler(function(event)
        -- end, sp.EventType.ANIMATION_COMPLETE)
    end
end

return M
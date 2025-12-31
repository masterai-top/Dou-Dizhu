-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36

local M = class("DDZUtil")

function M:ctor()
end

function M:selectLaiZiPokes(pokes)
    local retPokes = {}
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    for k,v in pairs(pokes) do
        if v.num == laiZiNum then
            table.insert(retPokes, k)
        end
    end
    return retPokes
end

function M:buildLaiZiData(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local laiziPokes = self:selectLaiZiPokes(dataClone)
    local data = {}
    for k,v in pairs(laiziPokes) do
        table.insert(data, dataClone[v])
    end
    return data
end

-- @返回当前下标
function M:findSameCountPoke(sameCnt, inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local allNums = self:buildAllNums(dataClone, true)
    for i,v in ipairs(allNums) do
        local sames = self:findSamePoke(v, dataClone)
        if #sames == sameCnt then
            return sames
        end
    end
    return nil
end

-- @返回总体下标
function M:findSameCountPokeLZ(sameCnt, inData, inLZData)
    local pokeData = inData
    local lzData = inLZData
    local dataClone = table.newclone(pokeData)
    local allNums = self:buildAllNums(dataClone, true)
    for i,v in ipairs(allNums) do
        local sames = self:findSamePokeRetIndex(v, dataClone)
        if #sames == sameCnt then
            return sames
        elseif (#sames < sameCnt) and (#sames + #lzData) >= 3 then
            while #sames ~= 3 do
                table.insert(sames, lzData[1].index)
                table.remove(lzData, 1)
            end
            return sames
        end
    end
    return nil
end

function M:makeCollectInfo(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = {}
    for i=1,4 do
        collect[i] = {}
    end
    local allNums = self:buildAllNums(dataClone, true)
    for i,v in ipairs(allNums) do
        local sames = self:findSamePoke(v, dataClone)
        if #sames == 1 then
            table.insert(collect[1], v)
        elseif #sames == 2 then
            table.insert(collect[2], v)
        elseif #sames == 3 then
            table.insert(collect[3], v)
        elseif #sames == 4 then
            table.insert(collect[4], v)
        end
    end
    return collect
end

function M:makeLaiZiCollectInfo(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = {}
    for i=1,5 do
        collect[i] = {}
    end
    local allNums = self:buildAllNums(dataClone, true)
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    for i,v in ipairs(allNums) do
        local sames = self:findSamePoke(v, dataClone)

        if v == laiZiNum then
            table.insert(collect[3], v)
        elseif #sames == 1 then
            table.insert(collect[4], v)
        elseif #sames == 2 then
            table.insert(collect[1], v)
        elseif #sames == 3 then
            table.insert(collect[2], v)
        elseif #sames == 4 then
            table.insert(collect[5], v)
        end
    end
    return collect
end

function M:makeNumMap(allNums)
    local numMap = {}
    for k,v in pairs(allNums) do
        numMap[v] = true
    end
    return numMap
end

function M:buildLZMap(laizis)
    local mapLaiZi = {}
    for k,v in pairs(laizis) do
        mapLaiZi[v.card] = v.change
    end
    return mapLaiZi
end

function M:makeLaiZiChange(oriSvrNum, changeToNum)
    return {oriSvrNum, changeToNum*10 + 1}
end

function M:findSamePoke(pokeClientNum, inData)
    local retPokes = {}
    for k,v in pairs(inData) do
        if v.num == pokeClientNum then
            table.insert(retPokes, k)
        end
    end
    return retPokes
end

function M:findSamePokeRetIndex(pokeClientNum, inData)
    local retPokes = {}
    for k,v in pairs(inData) do
        if v.num == pokeClientNum then
            table.insert(retPokes, v.index)
        end
    end
    return retPokes
end

function M:checkFourPoke(pokeNum)
    local pokeData = Game.DDZPlayDB:getPokesData()
    local sames = self:findSamePoke(pokeNum, pokeData)
    if #sames >= 4 then
        return true
    end
    return false
end

function M:checkShunZiPoke(pokeNum)
    local retValue = false
    retValue = self:checkShunZiPoke_NotLZ(pokeNum)
    return retValue
end

function M:checkShunZiPoke_NotLZ(pokeNum)
    local pokeData = Game.DDZPlayDB:getPokesData()

    local allNums = self:buildAllNums(pokeData, true)

    local numCnt = #allNums
    if numCnt < 5 then
        return false
    end

    for i,v in ipairs(allNums) do
        local seqList = {}
        local hasPoke = false
        local needValue = v
        for j=i,numCnt do
            if needValue >= TWO then
                break
            end
            if allNums[j] == needValue then
                if needValue == pokeNum then
                    hasPoke = true
                end
                table.insert(seqList, needValue)
                if #seqList >= 5 and hasPoke == true then
                    return true
                end
                needValue = needValue + 1
            else
                break
            end
        end
    end

    return false
end

function M:checkThreePoke(pokeNum)
    local pokeData = Game.DDZPlayDB:getPokesData()
    local sames = self:findSamePoke(pokeNum, pokeData)
    if #sames == 3 then
        return true
    end
    return false
end

function M:checkDoublePoke(pokeNum)
    local pokeData = Game.DDZPlayDB:getPokesData()
    local sames = self:findSamePoke(pokeNum, pokeData)
    if #sames == 2 then
        return true
    end
    return false
end

function M:checkSinglePoke(pokeNum)
    local pokeData = Game.DDZPlayDB:getPokesData()
    local sames = self:findSamePoke(pokeNum, pokeData)
    if #sames ~= 1 then
        return false
    end
    return true
end

function M:checkDaXiaoWang(inData, idx)
    local poke = inData[idx]
    if not poke then
        return false
    end
    if poke.num == SMALL_JOKER or poke.num == BIG_JOKER then
        return true
    end
    return false
end

function M:checkHaveDaXiaoWang()
    local pokeData = Game.DDZPlayDB:getPokesData()
    local sames1 = self:findSamePoke(SMALL_JOKER, pokeData)
    if #sames1 ~= 1 then
        return false
    end
    local sames2 = self:findSamePoke(BIG_JOKER, pokeData)
    if #sames2 ~= 1 then
        return false
    end
    return true    
end

function M:buildAllNums(pokes, isBiger)
    local retInfo = {}
    local nowNum = 0
    for k,v in pairs(pokes) do
        if nowNum ~= v.num then
            nowNum = v.num
            table.insert(retInfo, v.num)
        end
    end
    if isBiger == true then
        table.sort(retInfo, function(a, b)
            return a < b
        end)
    else
        table.sort(retInfo, function(a, b)
            return a > b
        end)
    end

    return retInfo
end

function M:buildIndexAllNums(pokesIndex, inData, isBiger)
    local dataClone = table.newclone(inData)
    local retInfo = {}
    local numKey = {}
    for k,v in pairs(pokesIndex) do
        local num = dataClone[v].num
        numKey[num] = true
    end

    for k,v in pairs(numKey) do
        table.insert(retInfo, k)
    end
    if isBiger == true then
        table.sort(retInfo, function(a, b)
            return a < b
        end)
    else
        table.sort(retInfo, function(a, b)
            return a > b
        end)
    end

    return retInfo
end

function M:clearTableByNum(num, tab, cnt)
    local delNum = 4
    if cnt ~= nil then
        delNum = cnt
    end
    local values = {}
    for k,v in pairs(tab) do
        if v.num == num then
            table.insert(values, v)
            delNum = delNum - 1
            if delNum <= 0 then
                break
            end
        end
    end

    for k,v in pairs(values) do
        table.removebyvalue(tab, v)
    end
end

function M:clearTableBySeq(seqS, tab)
    local values = {}
    for k,v in pairs(seqS) do
        table.insert(values, tab[v])
    end

    for k,v in pairs(values) do
        table.removebyvalue(tab, v)
    end
end

function M:clearTableByIndex(idxS, tab)
    local map = self:makeNumMap(idxS)
    local values = {}
    for k,v in pairs(tab) do
        if map[v.index] ~= nil then
            table.insert(values, v)
        end
    end

    for k,v in pairs(values) do
        table.removebyvalue(tab, v)
    end
end
return M

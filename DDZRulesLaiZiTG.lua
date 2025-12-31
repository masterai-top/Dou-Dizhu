-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36


local M = class("DDZRulesTG")

function M:ctor()

end

function M:findMoreOneNotMainLZ(inData, moreNum, inLZData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local lzData = {}
    if inLZData ~= nil then
        lzData = inLZData
    end

    local lzChanges = {}
    local collect = Game.DDZUtil:makeCollectInfo(dataClone)

    for iCo,vCo in ipairs(collect) do
        for iVa,vVa in ipairs(vCo) do
            local sames = Game.DDZUtil:findSamePoke(vVa, dataClone)
            for i,v in ipairs(sames) do
                table.insert(retPokes, dataClone[v].index)
                if #retPokes == moreNum then
                    return retPokes
                end
            end
        end
    end

    for k,v in pairs(lzData) do
        table.insert(retPokes, v.index)
        if #retPokes == moreNum then
            return retPokes
        end
    end
    return nil
end

function M:findMoreTwoNotMainLZ(inData, moreNum, inLZData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local lzData = {}
    if inLZData ~= nil then
        lzData = inLZData
    end

    local collect = Game.DDZUtil:makeCollectInfo(dataClone)

    for iCo,vCo in ipairs(collect) do
        for iVa,vVa in ipairs(vCo) do
            local sames = Game.DDZUtil:findSamePokeRetIndex(vVa, dataClone)

            if iCo == 1 then
                if lzData[1] ~= nil then
                    table.insert(retPokes, sames[1])
                    table.insert(retPokes, lzData[1].index)
                    table.remove(lzData, 1)
                end
            elseif iCo == 3 then
                table.insert(retPokes, sames[1])
                table.insert(retPokes, sames[2])
                if #retPokes == moreNum then
                    return retPokes
                end
                if lzData[1] ~= nil then
                    table.insert(retPokes, sames[3])
                    table.insert(retPokes, lzData[1].index)
                    table.remove(lzData, 1)
                end
            elseif iCo == 2 then
                table.insert(retPokes, sames[1])
                table.insert(retPokes, sames[2])
            elseif iCo == 4 then
                table.insert(retPokes, sames[1])
                table.insert(retPokes, sames[2])
                if #retPokes == moreNum then
                    return retPokes
                end
                table.insert(retPokes, sames[3])
                table.insert(retPokes, sames[4])
            end
            if #retPokes == moreNum then
                return retPokes
            end
        end
    end
    return nil
end

function M:findSamePokeWithNum(sameNum, inData)
    return Game.DDZUtil:findSameCountPoke(sameNum, inData)
end

function M:checkGoShunZi(inData, shuns)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local lzData = Game.DDZUtil:buildLaiZiData(dataClone)
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)

    local shunNumCnt = 0
    local shunNumsIndex = {}
    local mustNum = allNums[1]
    local samesMust = Game.DDZUtil:findSamePokeRetIndex(mustNum, dataClone)
    if #samesMust > shuns then
        return nil
    end
    local needValue = mustNum
    while needValue < TWO do
        local sames = Game.DDZUtil:findSamePokeRetIndex(needValue, dataClone)
        local sameCnt = #sames
        if sameCnt < shuns and (sameCnt + #lzData) >= shuns then
            for i=1,shuns-sameCnt do
                table.insert(sames, lzData[1].index)
                table.remove(lzData, 1)
            end
        end
        sameCnt = #sames
        if sameCnt < shuns then
            break
        else
            for i=1,shuns do
                table.insert(shunNumsIndex, sames[i])
            end
            shunNumCnt = shunNumCnt + 1
        end
        needValue = needValue + 1
    end
    if (shuns == 1 and shunNumCnt >= 5)
    or (shuns == 2 and shunNumCnt >= 3)
    or (shuns == 3 and shunNumCnt >= 2) then
        return shunNumsIndex,{}
    end
    return nil
end

function M:turnGoShunZi(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local retPokes = self:checkGoShunZi(dataClone, 1)
    return retPokes
end

function M:turnGoShunZiDouble(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local retPokes = self:checkGoShunZi(dataClone, 2)
    return retPokes
end

function M:turnGoFeiJi(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local retPokes = self:checkGoShunZi(dataClone, 3)
    return retPokes
end

--@仅适用3带1， 3带2
function M:checkSmallThree(inData, mustGoNum, tailNum)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    if #dataClone < 3 then
        return nil
    end

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local lzData = Game.DDZUtil:buildLaiZiData(dataClone)
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    if mustGoNum > TWO then
        return nil
    end
    local sames = Game.DDZUtil:findSamePokeRetIndex(mustGoNum, dataClone)
    local samesCnt = #sames
    if samesCnt == 4 or samesCnt == 0 then
        return nil
    end
    local allMust = table.newclone(sames)
    if #allMust + #lzData >= 3 then
        while #allMust ~= 3 do
            table.insert(allMust, lzData[1].index)
            table.remove(lzData, 1)
        end
        Game.DDZUtil:clearTableByIndex(allMust, dataClone)
        local retOne = nil
        if tailNum == 2 then
            retOne = self:findMoreTwoNotMainLZ(dataClone, 2, lzData)
        elseif tailNum == 1 then
            retOne = self:findMoreOneNotMainLZ(dataClone, 1, lzData)
        end
        if retOne ~= nil then
            retPokes = {}
            for k,v in pairs(allMust) do
                table.insert(retPokes, v)
            end
            for k,v in pairs(retOne) do
                table.insert(retPokes, v)
            end
            return retPokes,{}
        end
    else
        if #allMust > tailNum then
            return nil
        end
        if tailNum == 2 then
            if #allMust + #lzData == 2 then
                while #allMust ~= 2 do
                    table.insert(allMust, lzData[1].index)
                    table.remove(lzData, 1)
                end
            end
        end

        Game.DDZUtil:clearTableByIndex(allMust, dataClone)
        local rets = Game.DDZUtil:findSameCountPokeLZ(3, dataClone, lzData)
        if rets then
            retPokes = {}
            for k,v in pairs(rets) do
                table.insert(retPokes, v)
            end
            for k,v in pairs(allMust) do
                table.insert(retPokes, v)
            end
            return retPokes,{}
        end
    end
    return nil
end

-- @仅适用于飞机带单和飞机带双
function M:checkSmallFeiJi(inData, tailNum)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local lzData = Game.DDZUtil:buildLaiZiData(dataClone)

    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local shunNums = {}
    local isInShun = false

    local mustGoNum = allNums[1]
    if mustGoNum >= TWO then
        return nil
    end
    local sameMust = Game.DDZUtil:findSamePokeRetIndex(mustGoNum, dataClone)
    local samesMustCnt = #sameMust

    local allMust = table.newclone(sameMust)
    if samesMustCnt == 4 or samesMustCnt == 0 then
        return nil
    end

    local shunAllIndex = {}

    if #allMust + #lzData >= 3 then
        while #allMust ~= 3 do
            table.insert(allMust, lzData[1].index)
            table.remove(lzData, 1)
        end
        isInShun = true
        local needValue = mustGoNum
        shunAllIndex = table.newclone(allMust)
        table.insert(shunNums, needValue)
        needValue = needValue + 1
        while needValue < TWO do
            local sames = Game.DDZUtil:findSamePokeRetIndex(needValue, dataClone)
            local nowSamesCnt = #sames
            if (nowSamesCnt + #lzData) >= 3 then
                table.insert(shunNums, needValue)
                if nowSamesCnt < 3 then
                    for i=1,nowSamesCnt do
                        table.insert(shunAllIndex, sames[i])
                    end
                    for i=1,3-nowSamesCnt do
                        table.insert(shunAllIndex, lzData[1].index)
                        table.remove(lzData, 1)
                    end
                else
                    for i=1,3 do
                        table.insert(shunAllIndex, sames[i])
                    end
                end
            else
                break
            end
            needValue = needValue + 1
        end
    end

    local endShunNum = #shunNums
    if endShunNum >= 2 then
        local testShunNum = endShunNum
        local feiJis = shunAllIndex
        while testShunNum >= 2 do
            local dataCloneTmp = table.newclone(dataClone)

            Game.DDZUtil:clearTableByIndex(feiJis, dataCloneTmp)
            local retOne = nil
            if isInShun == true then
                if tailNum == 1 then
                    retOne = self:findMoreOneNotMainLZ(dataCloneTmp, testShunNum, lzData)
                elseif tailNum == 2 then
                    retOne = self:findMoreTwoNotMainLZ(dataCloneTmp, testShunNum*2, lzData)
                end
            end

            if retOne ~= nil then
                retPokes = {}
                for k,v in pairs(feiJis) do
                    table.insert(retPokes, v)
                end

                for k,v in pairs(retOne) do
                    table.insert(retPokes, v)
                end
                return retPokes,{}
            else
                testShunNum = testShunNum - 1
                table.clearTail(shunNums, 1)
                table.clearTail(feiJis, 3)
            end
        end
    end
    return nil
end

function M:turnGoFeiJiWithSingle(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local totalNum = #dataClone
    if totalNum < 8 then
        return nil
    end

    local retPokes = self:checkSmallFeiJi(dataClone, 1)
    return retPokes
end

function M:turnGoFeiJiWithDouble(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local totalNum = #dataClone
    if totalNum < 10 then
        return nil
    end

    local retPokes = self:checkSmallFeiJi(dataClone, 2)
    return retPokes
end

function M:turnGoThreeWithOne(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if #dataClone < 4 then
        return nil
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local retPokes = self:checkSmallThree(dataClone, mustGoNum, 1)
    return retPokes
end

function M:turnGoThreeWithTwo(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    if #dataClone < 5 then
        return nil
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local retPokes = self:checkSmallThree(dataClone, mustGoNum, 2)
    return retPokes
end

--@仅适用4带2， 4带2对
function M:checkSmallFour(inData, tailNum)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    if #dataClone < 6 then
        return nil
    end

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local lzData = Game.DDZUtil:buildLaiZiData(dataClone)
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local sames = Game.DDZUtil:findSamePokeRetIndex(mustGoNum, dataClone)
    local samesCnt = #sames

    if samesCnt == 0 or mustGoNum > TWO then
        return nil
    end
    local allMust = table.newclone(sames)
    if #allMust + #lzData >= 4 then
        while #allMust ~= 4 do
            table.insert(allMust, lzData[1].index)
            table.remove(lzData, 1)
        end
        Game.DDZUtil:clearTableByIndex(allMust, dataClone)
        local retOne = nil
        if tailNum == 4 then
            retOne = self:findMoreTwoNotMainLZ(dataClone, 2*2, lzData)
        elseif tailNum == 2 then
            retOne = self:findMoreOneNotMainLZ(dataClone, 2, lzData)
        end
        if retOne ~= nil then
            retPokes = {}
            for k,v in pairs(allMust) do
                table.insert(retPokes, v)
            end
            for k,v in pairs(retOne) do
                table.insert(retPokes, v)
            end
            return retPokes,{}
        end
    end
    return nil
end

function M:turnGoFourWithTwoSingle(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if #dataClone < 6 then
        return nil
    end
    local retPokes = self:checkSmallFour(inData, 2)
    return retPokes
end

function M:turnGoFourWithTwoDouble(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if #dataClone < 8 then
        return nil
    end
    local retPokes = self:checkSmallFour(inData, 4)
    return retPokes
end

function M:turnGoSameNum(count, inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local lzData = Game.DDZUtil:buildLaiZiData(dataClone)
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local sames = Game.DDZUtil:findSamePokeRetIndex(mustGoNum, dataClone)
    local samesCnt = #sames
    if samesCnt > count then
        return nil
    end
    if (samesCnt + #lzData) >= count then
        retPokes = {}
        for k,v in pairs(lzData) do
            table.insert(sames, v.index)
        end
        for i=1,count do
            table.insert(retPokes, sames[i])
        end
        return retPokes
    end
    return retPokes,{}
end

function M:turnGoOne(inData)
    return self:turnGoSameNum(1, inData)
end

function M:turnGoTwo(inData)
    return self:turnGoSameNum(2, inData)
end

function M:turnGoThree(inData)
    return self:turnGoSameNum(3, inData)
end

function M:turnGoFour(inData)
    return self:turnGoSameNum(4, inData)
end

function M:turnGoHuoJian(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    if allNums[1] == SMALL_JOKER and allNums[2] == BIG_JOKER then
        retPokes = {}
        table.insert(retPokes, dataClone[1].index)
        table.insert(retPokes, dataClone[2].index)
        return retPokes, {}
    end
    return retPokes
end

function M:turnGoAllLZ(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    if #laiziPokes == #dataClone then
        return laiziPokes,{}
    end
    return nil
end

function M:turnGoOnlyHuoJian(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if #dataClone ~= 2 then
        return nil
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    if (allNums[1] == SMALL_JOKER and allNums[2] == BIG_JOKER) 
        or (allNums[1] == BIG_JOKER and allNums[2] == SMALL_JOKER) then
        retPokes = {}
        table.insert(retPokes, dataClone[1].index)
        table.insert(retPokes, dataClone[2].index)
        return retPokes
    end
    return retPokes
end

function M:turnGoMinLessFourPokes(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    -- dump(dataClone)
    
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local sames = {}
    local samesCnt = 0
    while true do
        sames = {}
        samesCnt = 0
        local mustGoNum = allNums[1]
        if not mustGoNum then
            break
        end
        sames = Game.DDZUtil:findSamePokeRetIndex(mustGoNum, dataClone)
        samesCnt = #sames
        if samesCnt <= 3 and BIG_JOKER ~= mustGoNum and SMALL_JOKER ~= mustGoNum then
            retPokes = {}
            break
        end
        table.remove(allNums, 1)
    end
    for i=1,samesCnt do
        table.insert(retPokes, sames[i])
    end
    return retPokes, {}
end

function M:turnGoMinFourPokes(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local sames = {}
    local samesCnt = 0
    while true do
        sames = {}
        samesCnt = 0
        local mustGoNum = allNums[1]
        if not mustGoNum then
            break
        end
        sames = Game.DDZUtil:findSamePokeRetIndex(mustGoNum, dataClone)
        samesCnt = #sames
        if samesCnt == 4 then
            retPokes = {}
            break
        end
        table.remove(allNums, 1)
    end
    for i=1,samesCnt do
        table.insert(retPokes, sames[i])
    end
    return retPokes, {}
end

local myTurnGoPokeFunc = {
    M.turnGoOnlyHuoJian,
    M.turnGoMinLessFourPokes,
    M.turnGoMinFourPokes,
    M.turnGoAllLZ,
    M.turnGoShunZi,
    M.turnGoThreeWithTwo,
    M.turnGoFeiJiWithSingle,
    M.turnGoFourWithTwoDouble,
    M.turnGoOne,
    M.turnGoShunZiDouble,
    M.turnGoThreeWithOne,
    M.turnGoFourWithTwoSingle,
    M.turnGoFeiJiWithDouble,
    M.turnGoTwo,
    M.turnGoFeiJi,
    M.turnGoThree,
    M.turnGoFour,
    M.turnGoHuoJian,
}

function M:myTurnGoPoke(inData)
    local retPokes = {}
    local laiZiChanges = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    for i,v in ipairs(myTurnGoPokeFunc) do
        retPokes, laiZiChanges = v(self, dataClone)
        if retPokes ~= nil then
            return retPokes, laiZiChanges
        end
    end
    return retPokes
end

return M

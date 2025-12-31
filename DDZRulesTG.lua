-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36


local M = class("DDZRulesTG")

function M:ctor()
end

function M:findMoreOneNotMain(inData, moreNum)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
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
    return nil
end

function M:findMoreTwoNotMain(inData, moreNum)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = Game.DDZUtil:makeCollectInfo(dataClone)

    collect[1] = {}

    for iCo,vCo in ipairs(collect) do
        for iVa,vVa in ipairs(vCo) do
            local sames = Game.DDZUtil:findSamePoke(vVa, dataClone)
            if iCo == 3 or iCo == 2 then
                table.insert(retPokes, dataClone[sames[1]].index)
                table.insert(retPokes, dataClone[sames[2]].index)
                if #retPokes == moreNum then
                    return retPokes
                end
            elseif iCo == 4 then
                table.insert(retPokes, dataClone[sames[1]].index)
                table.insert(retPokes, dataClone[sames[2]].index)
                if #retPokes == moreNum then
                    return retPokes
                end
                table.insert(retPokes, dataClone[sames[3]].index)
                table.insert(retPokes, dataClone[sames[4]].index)
                if #retPokes == moreNum then
                    return retPokes
                end
            end

        end
    end
    return nil
end

function M:findSamePokeWithNum(sameNum, inData)
    return Game.DDZUtil:findSameCountPoke(sameNum, inData)
end

function M:turnGoShunZi(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local shunNums = {}
    local needValue = allNums[1]
    for i,v in ipairs(allNums) do
        if needValue >= TWO then
            break
        end
        if needValue == v then
            table.insert(shunNums, needValue)
        else
            break
        end
        needValue = needValue + 1
    end
    if #shunNums >= 5 then
        retPokes = {}
        for i,v in ipairs(shunNums) do
            local sames = Game.DDZUtil:findSamePoke(v, dataClone)
            table.insert(retPokes, sames[1])
        end
    end
    return retPokes
end

function M:turnGoShunZiDouble(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local shunNums = {}
    local mustGoNum = allNums[1]
    local samesMust = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    if #samesMust ~= 2 then
        return nil
    end
    local needValue = mustGoNum
    local tmpRets = {}
    for i,v in ipairs(allNums) do
        if needValue >= TWO then
            break
        end
        if needValue == v then
            local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
            if #sames >= 2 then
                table.insert(shunNums, needValue)
                table.insert(tmpRets, sames[1])
                table.insert(tmpRets, sames[2])
            else
                break
            end
        else
            break
        end
        needValue = needValue + 1
    end
    if #shunNums >= 3 then
        retPokes = tmpRets
    end
    return retPokes
end

function M:turnGoFeiJi(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local totalNum = #dataClone
    if totalNum < 6 then
        return nil
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local shunNums = {}
    local mustGoNum = allNums[1]
    local sameMust = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    if #sameMust == 3 then
        local needValue = mustGoNum
        while needValue < TWO do
            local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
            if #sames >= 3 then
                table.insert(shunNums, needValue)
            else
                break
            end
            needValue = needValue + 1
        end
    end
    local endShunNum = #shunNums
    if endShunNum >= 2 then
        local feiJis = {}
        for i,v in ipairs(shunNums) do
            local sames = Game.DDZUtil:findSamePoke(v, dataClone)
            for i=1,3 do
                table.insert(feiJis, sames[i])
            end
        end
        retPokes = {}
        for k,v in pairs(feiJis) do
            table.insert(retPokes, v)
        end
    end
    return retPokes
end

function M:turnGoFeiJiWithSingle(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local totalNum = #dataClone
    if totalNum < 8 then
        return nil
    end
    local collect = Game.DDZUtil:makeCollectInfo(dataClone)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local shunNums = {}
    local mustGoNum = allNums[1]
    local sameMust = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    if #sameMust == 3 then
        local needValue = mustGoNum
        while needValue < TWO do
            local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
            if #sames >= 3 then
                table.insert(shunNums, needValue)
            else
                break
            end
            needValue = needValue + 1
        end
    elseif #sameMust == 1 then
        Game.DDZUtil:clearTableBySeq(sameMust, dataClone)
        local allNumsTmp = Game.DDZUtil:buildAllNums(dataClone, true)
        for i,v in ipairs(allNumsTmp) do
            local needValue = v
            shunNums = {}
            while needValue < TWO do
                local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
                if #sames >= 3 then
                    table.insert(shunNums, needValue)
                else
                    break
                end
                needValue = needValue + 1
            end
            if #shunNums >= 2 then
                break
            end
        end
    end
    local endShunNum = #shunNums
    if endShunNum >= 2 then
        local testShunNum = endShunNum
        while testShunNum >= 2 do
            local dataCloneTmp = table.newclone(dataClone)
            local feiJis = {}
            for i,v in ipairs(shunNums) do
                local sames = Game.DDZUtil:findSamePoke(v, dataCloneTmp)
                for i=1,3 do
                    table.insert(feiJis, sames[i])
                end
            end
            Game.DDZUtil:clearTableBySeq(feiJis, dataCloneTmp)
            local retOne = nil
            if #sameMust == 3 then
                retOne = self:findMoreOneNotMain(dataCloneTmp, testShunNum)
            elseif #sameMust == 1 then
                retOne = self:findMoreOneNotMain(dataCloneTmp, testShunNum - 1)
            end

            if retOne ~= nil then
                retPokes = {}
                for k,v in pairs(feiJis) do
                    table.insert(retPokes, v)
                end

                for k,v in pairs(retOne) do
                    table.insert(retPokes, v)
                end
                if #sameMust == 1 then
                    table.insert(retPokes, sameMust[1])
                end
                return retPokes
            else
                testShunNum = testShunNum - 1
                table.remove(shunNums, #shunNums)
            end
        end
    end
    return retPokes
end

function M:turnGoFeiJiWithDouble(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local totalNum = #dataClone
    if totalNum < 10 then
        return nil
    end
    local collect = Game.DDZUtil:makeCollectInfo(dataClone)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local shunNums = {}
    local mustGoNum = allNums[1]
    local sameMust = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    if #sameMust == 3 then
        local needValue = mustGoNum
        while needValue < TWO do
            local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
            if #sames >= 3 then
                table.insert(shunNums, needValue)
            else
                break
            end
            needValue = needValue + 1
        end
    elseif #sameMust == 2 then
        Game.DDZUtil:clearTableBySeq(sameMust, dataClone)
        local allNumsTmp = Game.DDZUtil:buildAllNums(dataClone, true)
        for i,v in ipairs(allNumsTmp) do
            local needValue = v
            shunNums = {}
            while needValue < TWO do
                local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
                if #sames >= 3 then
                    table.insert(shunNums, needValue)
                else
                    break
                end
                needValue = needValue + 1
            end
            if #shunNums >= 2 then
                break
            end
        end
    end
    local endShunNum = #shunNums
    if endShunNum >= 2 then
        local testShunNum = endShunNum
        while testShunNum >= 2 do
            local dataCloneTmp = table.newclone(dataClone)
            local feiJis = {}
            for i,v in ipairs(shunNums) do
                local sames = Game.DDZUtil:findSamePoke(v, dataCloneTmp)
                for i=1,3 do
                    table.insert(feiJis, sames[i])
                end
            end
            Game.DDZUtil:clearTableBySeq(feiJis, dataCloneTmp)
            local retOne = nil
            if #sameMust == 3 then
                retOne = self:findMoreTwoNotMain(dataCloneTmp, testShunNum*2)
            elseif #sameMust == 2 then
                retOne = self:findMoreTwoNotMain(dataCloneTmp, (testShunNum - 1)*2)
            end

            if retOne ~= nil then
                retPokes = {}
                for k,v in pairs(feiJis) do
                    table.insert(retPokes, v)
                end

                for k,v in pairs(retOne) do
                    table.insert(retPokes, v)
                end
                if #sameMust == 2 then
                    table.insert(retPokes, sameMust[1])
                    table.insert(retPokes, sameMust[2])
                end
                return retPokes
            else
                testShunNum = testShunNum - 1
                table.remove(shunNums, #shunNums)
            end
        end
    end
    return retPokes
end

function M:turnGoThreeWithOne(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if #dataClone < 4 then
        return nil
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local sames = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    local samesCnt = #sames
    if samesCnt == 3 then
        Game.DDZUtil:clearTableBySeq(sames, dataClone)
        local retOne = self:findMoreOneNotMain(dataClone, 1)
        if retOne ~= nil then
            retPokes = {}
            for k,v in pairs(sames) do
                table.insert(retPokes, v)
            end

            table.insert(retPokes, retOne[1])
        end
    elseif samesCnt == 1 then
        local rets = Game.DDZUtil:findSameCountPoke(3, dataClone)
        if rets then
            retPokes = {}
            for k,v in pairs(rets) do
                table.insert(retPokes, v)
            end
            table.insert(retPokes, sames[1])
        end
    end
    return retPokes
end

function M:turnGoThreeWithTwo(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if #dataClone < 5 then
        return nil
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local sames = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    local samesCnt = #sames
    if samesCnt == 3 then
        Game.DDZUtil:clearTableBySeq(sames, dataClone)
        local retOne = self:findMoreTwoNotMain(dataClone, 2)
        if retOne ~= nil then
            retPokes = {}
            for k,v in pairs(sames) do
                table.insert(retPokes, v)
            end
            for k,v in pairs(retOne) do
                table.insert(retPokes, v)
            end
        end
    elseif samesCnt == 2 then
        local rets = Game.DDZUtil:findSameCountPoke(3, dataClone)
        if rets then
            retPokes = {}
            for k,v in pairs(rets) do
                table.insert(retPokes, v)
            end
            table.insert(retPokes, sames[1])
            table.insert(retPokes, sames[2])
        end
    end
    return retPokes
end

function M:turnGoFourWithTwoSingle(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if #dataClone < 6 then
        return nil
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local sames = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    local samesCnt = #sames
    if samesCnt == 4 then
        Game.DDZUtil:clearTableBySeq(sames, dataClone)
        local retOne = self:findMoreOneNotMain(dataClone, 2)
        if retOne ~= nil then
            retPokes = {}
            for k,v in pairs(sames) do
                table.insert(retPokes, v)
            end

            for k,v in pairs(retOne) do
                table.insert(retPokes, v)
            end
        end
    elseif samesCnt == 1 then
        local rets = Game.DDZUtil:findSameCountPoke(4, dataClone)
        if rets then
            retPokes = {}
            for k,v in pairs(rets) do
                table.insert(retPokes, v)
            end
            table.insert(retPokes, sames[1])
            Game.DDZUtil:clearTableBySeq(retPokes, dataClone)
            local retOne = self:findMoreOneNotMain(dataClone, 1)
            if retOne ~= nil then
                table.insert(retPokes, retOne[1])
                return retPokes
            else
                return nil
            end
        end
    end
    return retPokes
end

function M:turnGoFourWithTwoDouble(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if #dataClone < 8 then
        return nil
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local sames = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    local samesCnt = #sames
    if samesCnt == 4 then
        Game.DDZUtil:clearTableBySeq(sames, dataClone)
        local retOne = self:findMoreTwoNotMain(dataClone, 4)
        if retOne ~= nil then
            retPokes = {}
            for k,v in pairs(sames) do
                table.insert(retPokes, v)
            end

            for k,v in pairs(retOne) do
                table.insert(retPokes, v)
            end
        end
    elseif samesCnt == 2 then
        local rets = Game.DDZUtil:findSameCountPoke(4, dataClone)
        if rets then
            retPokes = {}
            for k,v in pairs(rets) do
                table.insert(retPokes, v)
            end
            table.insert(retPokes, sames[1])
            table.insert(retPokes, sames[2])
            Game.DDZUtil:clearTableBySeq(retPokes, dataClone)
            local retOne = self:findMoreTwoNotMain(dataClone, 2)
            if retOne ~= nil then
                for k,v in pairs(retOne) do
                    table.insert(retPokes, v)
                end
                return retPokes
            else
                return nil
            end
        end
    end
    return retPokes
end

function M:turnGoSameNum(count, inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local mustGoNum = allNums[1]
    local sames = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
    local samesCnt = #sames
    if samesCnt > count then
        return nil
    end
    if #sames == count then
        retPokes = {}
        for i=1,count do
            table.insert(retPokes, sames[i])
        end
        return retPokes
    end
    return retPokes
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
    if (allNums[1] == SMALL_JOKER and allNums[2] == BIG_JOKER) 
        or (allNums[2] == SMALL_JOKER and allNums[1] == BIG_JOKER) then
        retPokes = {}
        table.insert(retPokes, dataClone[1].index)
        table.insert(retPokes, dataClone[2].index)
        return retPokes
    end
    return retPokes
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
        or (allNums[2] == SMALL_JOKER and allNums[1] == BIG_JOKER) then
        retPokes = {}
        table.insert(retPokes, dataClone[1].index)
        table.insert(retPokes, dataClone[2].index)
        return retPokes
    end
    return retPokes
end

-- 出最小的非炸
function M:turnGoMinLessFourPokes(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

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
        sames = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
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
    return retPokes
end

-- 出最小的炸
function M:turnGoMinFourPokes(inData)
    local retPokes = nil
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    dump(allNums)
    local sames = {}
    local samesCnt = 0
    while true do
        sames = {}
        samesCnt = 0
        local mustGoNum = allNums[1]
        if not mustGoNum then
            break
        end
        sames = Game.DDZUtil:findSamePoke(mustGoNum, dataClone)
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
    return retPokes   
end

local myTurnGoPokeFunc = {
    M.turnGoOnlyHuoJian,
    M.turnGoMinLessFourPokes,
    M.turnGoMinFourPokes,
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
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    for i,v in ipairs(myTurnGoPokeFunc) do
        local retPokes = v(self, dataClone)
        if retPokes ~= nil then
            return retPokes
        end
    end
    return {}
end

return M

-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36

local base = require_ex("games.ddz.models.DDZRulesGoLinkBase")
local M = class("DDZRulesGoLinkLaiZi", base)

function M:ctor()
    base.ctor(self)
end

local myTurnGoLinkPokeFunc = 
{
    M.turnGoLianDuiPokes,
    M.turnGoShunZiPokes,
}

function M:myGoLinkPoke(inData, selectData)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "==========DDZRulesGoLinkLaiZi myGoLinkPoke=======")

    if inData then
        return nil
    end
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local selectClone = table.newclone(selectData)

    local data_map = {}
    for i,v in ipairs(dataClone) do
        if not data_map[v.num] then
            data_map[v.num] = {}
        end
        table.insert(data_map[v.num], i)
    end

    local select_map = {}
    local select_list = {}
    for i,v in ipairs(selectClone) do
        if not select_map[v.num] then
            select_map[v.num] = 0
            table.insert(select_list, v.num)
        end
        select_map[v.num] = select_map[v.num] + 1
    end
    table.sort(select_list, function(a, b)
        return a < b
    end)

    if self:checkSelectData(select_map, select_list) then
        return
    end

    for i,v in ipairs(myTurnGoLinkPokeFunc) do
        local retPokes = v(self, data_map, select_list)
        if retPokes ~= nil then
            Log(LOG.TAG.DDZ, LOG.LV.INFO, retPokes)
            return retPokes
        end
    end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "==========DDZRulesGoLinkLaiZi no go========")
    return nil
end


return M
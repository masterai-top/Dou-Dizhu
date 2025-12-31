-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36


local M = class("DDZRulesGoLinkBase")

function M:ctor()
end

function M:isSelectConnect(select_list)
    local len = #select_list
    local cur_min = select_list[1]
    local cur_max = select_list[len]

    local numMap = {}
    for i,v in ipairs(select_list) do
        numMap[v] = true
    end
    local is_connect = true
    for i = cur_min, cur_max do
        if not numMap[i] then
            is_connect = false
        end
    end
    return is_connect
end

function M:getMinAndMax(num, data_map, select_list)
    local len = #select_list
    local cur_min = select_list[1]
    local cur_max = select_list[len]
    local min = cur_min
    local max = cur_max

    local numMap = {}
    local numCount = 0
    for i,v in ipairs(select_list) do
        if not numMap[v] then
            numMap[v] = 0
            numCount = numCount + 1
        end
    end
    if len == numCount then
        Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZRulesGoLinkBase getMinAndMax min is: " .. min)
        Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZRulesGoLinkBase getMinAndMax max is: " .. max)
        return min, max
    end

    for i=min,3,-1 do
        if not data_map[i] or #data_map[i] < num then
            break
        end
        min = i
    end
    for i=max,14 do
        if not data_map[i] or #data_map[i] < num then
            break
        end
        max = i
    end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZRulesGoLinkBase getMinAndMax min is: " .. min)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZRulesGoLinkBase getMinAndMax max is: " .. max)
    return min, max
end

function M:getSelectMinAndMax(select_list)
    local len = #select_list
    local cur_min = select_list[1]
    local cur_max = select_list[len]
    return cur_min, cur_max
end

function M:checkSelectBoom(data_map, select_list)
    local cur_min, cur_max = self:getSelectMinAndMax(select_list)

    local is_boom = false
    for i = cur_min, cur_max do
        if data_map[i] and #data_map[i] >= 4 then
            is_boom = true
        end
    end
    return is_boom    
end

function M:checkSelectDifferent(select_list)
    local len = #select_list
    local cur_min = select_list[1]
    local cur_max = select_list[len]

    local numMap = {}
    local numCount = 0
    for i,v in ipairs(select_list) do
        if not numMap[v] then
            numMap[v] = 0
            numCount = numCount + 1
        end
        numMap[v] = numMap[v] + 1
    end
    if len == 3 or len == 4 then
        return (numCount >= 3)
    end

    local count1 = 0
    local count2 = 0
    for k,v in pairs(numMap) do
        if v >= 2 then
            count1 = count1 + 1
        end
        if v >= 3 then
            count2 = count2 + 1
        end
    end
    if count1 >= 3 then return false end
    if count2 >= 2 then return false end
    return true     
end

function M:getReturnPokes(num, connect_list, data_map)
    if #connect_list <= 0 then
        return nil
    end
    table.sort(connect_list, function(a, b)
        return #a > #b
    end)

    local retPokes = {}
    for i,key in ipairs(connect_list[1]) do
        if data_map[key] then
            -- table.sort(data_map[key], function(a, b)
            --     return b > a
            -- end)

            for k,v in ipairs(data_map[key]) do
                table.insert(retPokes, v)
                if k >= num then break end
            end
        end
    end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, connect_list[1])  
    return retPokes  
end

-- 判断选中的牌是否已经是顺子或连对
function M:checkSelectData(select_map, select_list)
    local is_shunzi = true
    local is_liandui = true
    
    local len = #select_list
    local min = select_list[1]
    local max = select_list[len]

    for i=min,max do
        if not select_map[i] or select_map[i] ~= 1 then
            is_shunzi = false
        end
        if not select_map[i] or select_map[i] ~= 2 then
            is_liandui = false
        end
    end
    if len < 5 then
        is_shunzi = false
    end
    if len < 3 then
        is_liandui = false
    end
    return (is_shunzi or is_liandui)
end

-- 自动补齐连对
function M:turnGoLianDuiPokes(data_map, select_list)
    local single_len = 1
    local double_len = 1
    for i,v in ipairs(select_list or {}) do
        if data_map[v] and #data_map[v] >= 2 then
            double_len = double_len + 1
        else
            single_len = single_len + 1
        end
    end
    if double_len <= single_len then
        return
    end
    local min, max = self:getMinAndMax(2, data_map, select_list)

    local check_list = {}
    for num=2,4 do
        local connect_len = 0
        local connect_list = {}
        local cur_list = {}
        for i=min,max do
            if not data_map[i] or #data_map[i] < 2 or #data_map[i] > num then
                if connect_len >= 3 then
                    table.insert(connect_list, cur_list)
                end
                connect_len = 0
                cur_list = {}
            else
                connect_len = connect_len + 1
                table.insert(cur_list, i)

                if connect_len >= 3 then
                    table.insert(connect_list, cur_list)
                    connect_len = 0
                    break
                end
            end
        end
        if connect_len >= 3 then
            table.insert(connect_list, cur_list)
        end
        if #connect_list > 0 then
            check_list = connect_list
            break
        end     
    end
    return self:getReturnPokes(2, check_list, data_map)
end

-- 自动补齐顺子
function M:turnGoShunZiPokes(data_map, select_list)
    if not self:isSelectConnect(select_list) then
        return nil
    end
    if self:checkSelectBoom(data_map, select_list) then
        return nil
    end
    if not self:checkSelectDifferent(select_list) then
        return nil
    end
    local min, max = self:getMinAndMax(1, data_map, select_list)

    local check_list = {}
    for num=1,4 do
        local connect_len = 0
        local connect_list = {}
        local cur_list = {}

        for i=min,max do
            if not data_map[i] or #data_map[i] < 1 or #data_map[i] > num then
                if connect_len >= 5 then
                    table.insert(connect_list, cur_list)
                end
                connect_len = 0
                cur_list = {}
            else
                connect_len = connect_len + 1
                table.insert(cur_list, i)

                -- if connect_len >= 5 then
                --     table.insert(connect_list, cur_list)
                --     connect_len = 0
                --     break
                -- end
            end
        end
        if connect_len >= 5 then
            table.insert(connect_list, cur_list)
        end
        if #connect_list > 0 then
            check_list = connect_list
            break
        end
    end
    return self:getReturnPokes(1, check_list, data_map)
end

return M
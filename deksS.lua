local mysql = exports.mysql
bocekler = {}

addEventHandler('onResourceStart', resourceRoot, function()
    local count = 0

    dbQuery(function(qh)
        local res, rows = dbPoll(qh, 0) 
        if rows > 0 then
            for _, row in ipairs(res) do
                
                local bocek = {
                    id = tonumber(row.ID), 
                    posx = tonumber(row.posx), 
                    posy = tonumber(row.posy),
                    posz = tonumber(row.posz),
                    dimension = tonumber(row.dimension),
                    interior = tonumber(row.interior),
                    obje = createObject(1337, row.posx, row.posy, row.posz, 0.0, 0.0, 0.0, false) 
                }
                
                bocekler[bocek.id] = bocek
                count = count + 1
            end
        end
    end, mysql:getConnection(), "SELECT * FROM `bocekler`") 
end)

function onuOlustur(plr)
    local x, y, z = getElementPosition(plr)
    local interior = getElementInterior(plr)
    local dimension = getElementDimension(plr)
    local idQ = SmallestID()
    local id = dbExec(mysql:getConnection(), "INSERT INTO bocekler (ID, posx, posy, posz, interior, dimension) VALUES ("..(idQ)..", " .. (x) .. ", " .. (y) .. ", " .. (z) .. ", " .. (interior) .. "," .. (dimension)..")" )

    local bocek = {
        id = idQ,
        posx = x,
        posy = y,
        posz = z,
        interior = interior,
        dimension = dimension,
        obje = createObject(1337, x, y, z, 0.0, 0.0, 0.0, false)
    }
    bocekler[id] = bocek
    outputChatBox("(( Başarıyla xx oluşturuldu! ID: "..idQ.." ))", plr, 155, 155, 155, true)
end
addCommandHandler("onuolustur", onuOlustur)

function onuSil(plr, cmd, id)
    if not id or tonumber(id) then
        bocekid = tonumber(id)

        if not bocekler[bocekid] then
            outputChatBox("(( Belirtilen ID'de bir böcek bulunamadı. ))", plr, 155, 155, 155, true)
            return
        end

        local bocek = bocekler[bocekid]

        destroyElement(bocek.obje)
        bocekler[id] = nil
        dbExec(mysql:getConnection(), "DELETE FROM bocekler WHERE ID = ?", id)
    else 
        outputChatBox("(( /" .. cmd .. " [ID] ))", plr, 155, 155, 155, true)
        return
    end
end
addCommandHandler("onusil", onuSil)

function SmallestID()
    local query = dbQuery(mysql:getConnection(), "SELECT MIN(e1.ID+1) AS nextID FROM bocekler AS e1 LEFT JOIN bocekler AS e2 ON e1.ID +1 = e2.ID WHERE e2.ID IS NULL")
    local result = dbPoll(query, -1)
    if result then
        local id = tonumber(result[1]["nextID"]) or 1
        return id
    end
    return false
end

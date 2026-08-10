local function ownedWagon(sourceId, wagonId, expectedModel)
    local _, charId = ServerUtils.getCharacter(sourceId, 'wagon feature ownership validation')
    wagonId = tonumber(wagonId)
    if not charId or not wagonId then return nil end

    local row = MySQL.single.await(
        'SELECT `id`, `model` FROM `bcc_player_wagons` WHERE `id` = ? AND `charid` = ? LIMIT 1',
        { wagonId, charId }
    )
    if not row or (expectedModel and row.model ~= expectedModel) then return nil end
    return { id = tonumber(row.id), model = row.model, charId = charId }
end

exports('GetOwnedWagon', ownedWagon)

exports('ValidateOwnedWagon', function(sourceId, wagonId, wagonNetId, expectedModel)
    local row = ownedWagon(sourceId, wagonId, expectedModel)
    wagonNetId = tonumber(wagonNetId)
    if not row or not wagonNetId then return false end

    local entity = NetworkGetEntityFromNetworkId(wagonNetId)
    if not entity or entity == 0 then return false end
    local state = Entity(entity).state
    return tonumber(state.myWagonId) == row.id
end)

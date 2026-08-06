local NATIVE_GET_CLOSEST_VEHICLE = 0x52F45D033645181B
local NATIVE_IS_DRAFT_VEHICLE = 0xEA44E97849E9F3DD
local NATIVE_GET_PLAYER_OWNER_OF_VEHICLE = 0x7C803BDC8343228D
local NATIVE_PROMPT_HAS_STANDARD_MODE_COMPLETED = 0xC92AC953F0A982AE

local function runLootInventoryLoop()
    local lootLabel = CreateVarString(10, 'LITERAL_STRING', _U('lootInventory'))

    while true do
        local playerPed = PlayerPedId()
        local sleep = 1000

        if not IsEntityDead(playerPed) and IsPedOnFoot(playerPed) then
            local coords = (GetEntityCoords(playerPed))
            local vehicle = Citizen.InvokeNative(NATIVE_GET_CLOSEST_VEHICLE, coords.x, coords.y, coords.z, 3.0, 0, 70, Citizen.ResultAsInteger())
            if vehicle ~= 0 and vehicle ~= MyWagon then
                if Citizen.InvokeNative(NATIVE_IS_DRAFT_VEHICLE, vehicle) then
                    if Citizen.InvokeNative(NATIVE_GET_PLAYER_OWNER_OF_VEHICLE, vehicle) ~= 255 then
                        sleep = 0
                        PromptSetActiveGroupThisFrame(LootGroup, lootLabel, 1, 0, 0, 0)
                        if Citizen.InvokeNative(NATIVE_PROMPT_HAS_STANDARD_MODE_COMPLETED, LootPrompt) then
                            local wagonId = Entity(vehicle).state.myWagonId
                            TriggerServerEvent('bcc-wagons:OpenInventory', wagonId)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end

if Config.inventory.shared then
    CreateThread(runLootInventoryLoop)
end

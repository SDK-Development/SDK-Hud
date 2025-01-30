local isHudVisible = true
local isInVehicle = false
local currentVoiceRange = 1
local hunger = 100
local thirst = 100
local isSeatbeltOn = false
local seatbeltTimeout = false
local isHudVisible = true

exports('showHud', function()
    isHudVisible = true
    SendNUIMessage({
        type = "toggleHud",
        show = true
    })
end)

exports('hideHud', function()
    isHudVisible = false
    SendNUIMessage({
        type = "toggleHud",
        show = false
    })
end)

CreateThread(function()
    while true do
        if isHudVisible then
            local ped = PlayerPedId()
            local player = PlayerId()
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            local armor = GetPedArmour(ped)
            local stamina = 100 - GetPlayerSprintStaminaRemaining(player)
            local isTalking = NetworkIsPlayerTalking(player)
            
            isInVehicle = IsPedInAnyVehicle(ped, false)
            DisplayRadar(isInVehicle or Config.AlwaysShowRadar)

            TriggerEvent('esx_status:getStatus', 'hunger', function(status)
                hunger = math.floor(status.getPercent())
            end)
            
            TriggerEvent('esx_status:getStatus', 'thirst', function(status)
                thirst = math.floor(status.getPercent())
            end)
                
            SendNUIMessage({
                type = "updateStatus",
                health = health > 100 and ((health - 100) / (maxHealth - 100) * 100) or 0,
                armor = armor,
                hunger = hunger,
                thirst = thirst,
                stamina = stamina,
                voiceRange = currentVoiceRange,
                isTalking = isTalking,
                isInVehicle = isInVehicle,
                showRadar = isInVehicle or Config.AlwaysShowRadar,
                playerId = GetPlayerServerId(PlayerId())
            })

            if isInVehicle then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local speed = GetEntitySpeed(vehicle) * (Config.UseKMH and 3.6 or 2.236936)
                local fuel = Config.EnableFuel and exports["LegacyFuel"]:GetFuel(vehicle) or 100

                SendNUIMessage({
                    type = "updateVehicle",
                    speed = speed,
                    maxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel") * (Config.UseKMH and 3.6 or 2.236936),
                    gear = GetVehicleCurrentGear(vehicle),
                    fuel = fuel,
                    useKMH = Config.UseKMH,
                    seatbelt = isSeatbeltOn,
                    seatbeltEnabled = Config.EnableSeatbelt
                })
            else
                SendNUIMessage({
                    type = "hideVehicleHUD"
                })
            end

            if isSeatbeltOn and not IsPedInAnyVehicle(ped, true) then
                isSeatbeltOn = false
                SendNUIMessage({
                    type = "updateSeatbeltNoSound",
                    seatbelt = false
                })
            end
        end
        
        HideHudComponentThisFrame(1)
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(20)
        Wait(Config.UpdateTime)
    end
end)

RegisterNetEvent('pma-voice:setTalkingMode')
AddEventHandler('pma-voice:setTalkingMode', function(mode)
    currentVoiceRange = mode
end)

RegisterCommand('givemearmor', function()
    SetPedArmour(PlayerPedId(), 100)
end)

function canUseSeatbelt(vehicle)
    local vc = GetVehicleClass(vehicle)
    return vc ~= 8 and -- Not motorcycle
           vc ~= 13 and -- Not bicycle
           vc ~= 14 -- Not boat
end

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', Config.SeatbeltKey)

RegisterCommand('toggleseatbelt', function()
    if not Config.EnableSeatbelt then return end
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 or not canUseSeatbelt(vehicle) then return end
    
    isSeatbeltOn = not isSeatbeltOn
    
    print("Seatbelt: " .. (isSeatbeltOn and "On" or "Off"))
    
    SendNUIMessage({
        type = "updateSeatbelt",
        seatbelt = isSeatbeltOn
    })
end)

function preventVehicleExit()
    if isSeatbeltOn then
        return true
    end
    return false 
end
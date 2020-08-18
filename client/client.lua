--===============================================================================
--=== Stworzone przez Alcapone aka suprisex. Zakaz rozpowszechniania skryptu! ===
--===================== na potrzeby LS-Story.pl =================================
--===============================================================================


-- ESX

ESX = nil
local PlayerData = {}
local radioMenu = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
            PlayerData = ESX.GetPlayerData() or {}
        end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

function PrintChatMessage(text)
    TriggerEvent('chatMessage', "system", { 255, 0, 0 }, text)
end

function enableRadio(enable)
    SetNuiFocus(true, true)
    radioMenu = enable

    SendNUIMessage({
        type = "enableui",
        enable = enable
    })
end

--- sprawdza czy komenda /radio jest włączony

RegisterCommand('radio', function(source, args)
    if Config.enableCmd then
        enableRadio(true)
    end
end, false)


-- radio test

RegisterCommand('radiotest', function(source, args)
    local playerName = GetPlayerName(PlayerId())
    local data = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

    if data == "nil" then
        exports['mythic_notify']:DoHudText('inform', Config.messages['not_on_radio'])
    else
        exports['mythic_notify']:DoHudText('inform', Config.messages['on_radio'] .. data .. '.00 MHz </b>')
    end
end, false)

-- dołączanie do radia

function canAccessRestrictedChannel(channel)
    if PlayerData == nil or PlayerData.job == nil or PlayerData.job.name == nil then
        return false
    end

    local channels = Config.RestrictedChannelPermissions[PlayerData.job.name]

    if channels == nil then
        return false
    end

    for _, channel_id in ipairs(channels) do
        if channel == channel_id then
            return true
        end
    end

    return false
end

RegisterNUICallback('joinRadio', function(data, cb)
    local radio_channel = tonumber(data.channel)
    local playerName = GetPlayerName(PlayerId())
    local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

    if radio_channel == tonumber(getPlayerRadioChannel) then
        exports['mythic_notify']:DoHudText('error', Config.messages['you_on_radio'] .. data.channel .. '.00 MHz </b>')

        return
    end

    if radio_channel <= Config.RestrictedChannels and not canAccessRestrictedChannel(radio_channel) then
        exports['mythic_notify']:DoHudText('error', Config.messages['restricted_channel_error'])

        return
    end

    exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
    exports.tokovoip_script:setPlayerData(playerName, "radio:channel", radio_channel, true);
    exports.tokovoip_script:addPlayerToRadio(radio_channel)
    exports['mythic_notify']:DoHudText('inform', Config.messages['joined_to_radio'] .. radio_channel .. '.00 MHz </b>')

    cb('ok')
end)

-- opuszczanie radia

RegisterNUICallback('leaveRadio', function(data, cb)
    local playerName = GetPlayerName(PlayerId())
    local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

    if getPlayerRadioChannel == "nil" then
        exports['mythic_notify']:DoHudText('inform', Config.messages['not_on_radio'])
    else
        exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
        exports.tokovoip_script:setPlayerData(playerName, "radio:channel", "nil", true)
        exports['mythic_notify']:DoHudText('inform', Config.messages['you_leave'] .. getPlayerRadioChannel .. '.00 MHz </b>')
    end

    cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
    enableRadio(false)
    SetNuiFocus(false, false)

    cb('ok')
end)

-- net eventy

RegisterNetEvent('ls-radio:use')
AddEventHandler('ls-radio:use', function()
    enableRadio(true)
end)

RegisterNetEvent('ls-radio:onRadioDrop')
AddEventHandler('ls-radio:onRadioDrop', function(source)
    local playerName = GetPlayerName(source)
    local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

    if getPlayerRadioChannel ~= "nil" then
        exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
        exports.tokovoip_script:setPlayerData(playerName, "radio:channel", "nil", true)
        exports['mythic_notify']:DoHudText('inform', Config.messages['you_leave'] .. getPlayerRadioChannel .. '.00 MHz </b>')
    end
end)

Citizen.CreateThread(function()
    while true do
        if radioMenu then
            DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
            DisableControlAction(0, 2, guiEnabled) -- LookUpDown

            DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate

            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride

            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage({
                    type = "click"
                })
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterCommand("launch", function(source, args, rawCommand)
    local target = tonumber(args[1])
    if target and GetPlayerPing(target) then
        TriggerClientEvent('TC:Client:launchPlayerIntoAir', target)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Invalid Player ID!")
    end
end, true)

RegisterCommand("runover", function(source, args, rawCommand)
    local targetPlayer = tonumber(args[1])
    if not targetPlayer then return end
    TriggerClientEvent('TC:Client:runPlayerOver', targetPlayer)

end, false)

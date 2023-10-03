local GetHashKey = GetHashKey
local RequestModel = RequestModel
local PlayerPedId = PlayerPedId
local vector3 = vector3
local HasModelLoaded = HasModelLoaded
local CreateVehicle = CreateVehicle
local GetHeadingFromVector_2d = GetHeadingFromVector_2d
local SetEntityHeading = SetEntityHeading
local SetVehicleForwardSpeed = SetVehicleForwardSpeed
local GetEntityCoords = GetEntityCoords
local IsPedShooting = IsPedShooting
local GetGameplayCamRot = GetGameplayCamRot
local ApplyForceToEntity = ApplyForceToEntity
local isWeaponFired = false
local vehicleGun = false


RegisterNetEvent('TC:Client:launchPlayerIntoAir')
AddEventHandler('TC:Client:launchPlayerIntoAir', function()
    local ped = GetPlayerPed(-1)
    ApplyForceToEntity(ped, 3, 0.0, 0.0, 200.0, 0.0, 0.0, 0.0, 0, false, false, true, false, true)
end)

RegisterNetEvent('TC:Client:runPlayerOver')
AddEventHandler('TC:Client:runPlayerOver', function()
    local targetPed = GetPlayerPed(-1)

    local x, y, z = table.unpack(GetEntityCoords(targetPed, false))

    local spawnPos = vector3(x + 10, y, z)

    local vehicleHash = GetHashKey("phantom")
    RequestModel(vehicleHash)

    while not HasModelLoaded(vehicleHash) do
        Wait(500)
    end

    local vehicle = CreateVehicle(vehicleHash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)

    local heading = GetHeadingFromVector_2d(x - spawnPos.x, y - spawnPos.y)
    SetEntityHeading(vehicle, heading)

    local speed = 50.0
    SetVehicleForwardSpeed(vehicle, speed)
    Wait(3000)
    DeleteEntity(vehicle)
end)


RegisterCommand("vehiclegun", function(source, args, rawCommand)
    vehicleGun = not vehicleGun
end, false)


Citizen.CreateThread(function()
    local playerPed = PlayerPedId()

    while true do
        Citizen.Wait(0)
        if IsPedShooting(playerPed) and vehicleGun then
            isWeaponFired = true
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isWeaponFired then
            isWeaponFired = false

            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)

            local rot = GetGameplayCamRot(2)
            local heading = math.rad(rot.z)
            local pitch = math.rad(rot.x)

            local forwardVector = vector3(-math.sin(heading) * math.cos(pitch), math.cos(heading) * math.cos(pitch), math.sin(pitch))

            local spawnPos = vector3(pos.x + forwardVector.x * 10, pos.y + forwardVector.y * 10, pos.z + forwardVector.z * 10)

            local vehicleHash = GetHashKey("phantom")

            RequestModel(vehicleHash)

            while not HasModelLoaded(vehicleHash) do
                Wait(500)
            end

            local vehicle = CreateVehicle(vehicleHash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)

            local forceMultiplier = 50000.0
            ApplyForceToEntity(vehicle, 1, forwardVector.x * forceMultiplier, forwardVector.y * forceMultiplier, forwardVector.z * forceMultiplier, 0.0, 0.0, 0.0, false, false, true, true, false, true)
        end
    end
end)


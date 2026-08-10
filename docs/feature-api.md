# Wagon feature API

`bcc-wagons` owns wagon purchase, ownership, selection, spawning, streaming,
returning, and sale. Model-specific resources consume this API.

## Client exports

```lua
local wagon = exports['bcc-wagons']:GetActiveWagon()
local active = exports['bcc-wagons']:IsActiveWagon(wagonId)
exports['bcc-wagons']:RegisterWagonFeature('model_name', {
    resource = GetCurrentResourceName(),
    persistentWhenDistant = true,
})
```

The active wagon object contains `entity`, `netId`, `id`, `model`, `type`,
`name`, and `active`.

## Client lifecycle events

```lua
AddEventHandler('bcc-wagons:client:wagonSpawned', function(wagon) end)
AddEventHandler('bcc-wagons:client:wagonStreamedIn', function(wagon) end)
AddEventHandler('bcc-wagons:client:wagonReturning', function(wagon) end)
```

## Server exports

```lua
local wagon = exports['bcc-wagons']:GetOwnedWagon(source, wagonId, expectedModel)
local valid = exports['bcc-wagons']:ValidateOwnedWagon(source, wagonId, netId, expectedModel)
```

## Server lifecycle events

```lua
AddEventHandler('bcc-wagons:server:wagonSold', function(source, wagonId, model) end)
```

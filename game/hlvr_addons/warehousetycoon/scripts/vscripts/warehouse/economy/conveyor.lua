require("warehouse.products.products")
Conveyor = _G.Conveyor or {
    Speed = 5;
    Level = 0;
    ItemRandomPusher = "randomPusherTrigger";
    ItemRandomPusherEntity = nil;
    TimeUntilNextSpawn = 2;

    ProgressBar = "progressbar";
    ProgressBarEntity = nil;
    CurrentMaxResources = 10;
    
}
ResourceEntityKeys = {
    ["BasicResource"] = {
        ResourceName = "BasicResource";
        origin = nil;
        targetname = "resource";
        vscripts = "warehouse/products/EntityProduct.lua";
        model = ProductModelDictionary.BaseResource;
    },
    ["AdvancedResource"] = {
        ResourceName = "AdvancedResource";
        origin = nil,
        targetname = "resource",
        vscripts = "warehouse/products/EntityProduct.lua",
        model = ProductModelDictionary.BaseResource
    },
    ["ImpossibleResource"] = {
        ResourceName = "ImpossibleResource";
        origin = nil,
        targetname = "resource",
        vscripts = "warehouse/products/EntityProduct.lua",
        model = ProductModelDictionary.BaseResource
    }
}

local conveyorTable ={
    countdowntime=Conveyor.currentTime;
    reachedmax = false;
}

local ware = nil

function Precache(context)
    for key, value in pairs(ProductModelDictionary) do
        PrecacheModel(value,context)
    end
end

function Activate(activatetype)
    Conveyor.currentTime = Conveyor.TimeUntilNextSpawn
    thisEntity:SetThink(function() return Conveyor:FindSpawnPoint() end,"findingConveyor",1.0)
end


function Conveyor:FindSpawnPoint()
    if ware == nil then
        Conveyor.ItemRandomPusherEntity = Entities:FindByName(nil,Conveyor.ItemRandomPusher)
        Conveyor.ProgressBarEntity = Entities:FindByName(nil,Conveyor.ProgressBar)
        ware = _G.WarehouseMain or nil
        return 0.2
    end
    table.insert(_G.WarehouseMain.OnUpdate,Conveyor.onUpdate)
    table.insert(_G.WarehouseMain.OnStart,Conveyor.onLoaded)
   --print("FoundConveyor and WarehouseMain")
    return nil
end

function Conveyor:onUpdate()
    if Conveyor.currentTime < 0 then
        Conveyor.currentTime = Conveyor.TimeUntilNextSpawn
       --print(_G.WarehouseMain.ResourcesDictionaryAmount["BasicResource"])
        if _G.WarehouseMain.ResourcesDictionaryAmount["BasicResource"] == nil or _G.WarehouseMain.ResourcesDictionaryAmount["BasicResource"] < 10 then
            local res = ResourceEntityKeys.BasicResource
            res.origin = thisEntity:GetAbsOrigin()
            SpawnEntityFromTableAsynchronous("prop_physics",res,nil,nil)
            EntFireByHandle(thisEntity,Conveyor.ItemRandomPusherEntity,"SetPushSpeed",tostring(RandomFloat(100,1000)))
            _G.WarehouseMain:AddResourceCount("BasicResource")
           --print("ResourceSpawned")
        else
            Conveyor.currentTime = Conveyor.TimeUntilNextSpawn
           --print("Max Resources Reached")
        end
        
    else
        
    if _G.WarehouseMain.ResourcesDictionaryAmount["BasicResource"] == nil or _G.WarehouseMain.ResourcesDictionaryAmount["BasicResource"] < 10 then
        Conveyor.currentTime = Conveyor.currentTime - ware.UpdateTime
        conveyorTable.countdowntime=Conveyor.currentTime;
        conveyorTable.reachedmax = false;
        if _G.WarehouseMain.ResourcesDictionaryAmount["BasicResource"] == 9 and Conveyor.currentTime <= 0.1  then
            conveyorTable.reachedmax = true;
        end
        _G.WarehouseMain:AddToTable("conveyor", conveyorTable)
        
    end
    
    --Conveyor.ProgressBarEntity:SetGraphParameterFloat("blendamount",Conveyor.currentTime/Conveyor.TimeUntilNextSpawn)
    
    --print(Conveyor.currentTime)
    end
    
end

function Conveyor:onLoaded()
   --print("loaded")
end

_G.Conveyor= Conveyor
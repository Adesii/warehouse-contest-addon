local moneymaker = require("warehouse.economy.money")
require("warehouse.jobs.Jobs")
require("warehouse.machines.templates.MachinesTemplates")
require("warehouse.products.products")
require("utils.json")
local json = require "utils.json"

function Precache(context)
    for key, value in pairs(ModelResourceDictionary) do
        PrecacheModel(value,context)
    end
    for key, value in pairs(ParticleResourceDictionary) do
        PrecacheResource("particle",value,context)
    end
    for key, value in pairs(ProductModelDictionary) do
        PrecacheModel(value,context)
    end
end
WarehouseMain = _G.WarehouseMain or
{
    Money = moneymaker(100);
    UpdateTime = 0.1;
    MachineManager = require("warehouse.machines.machinesManager");
    JobManager = require("warehouse.jobs.JobManager");
    npc_manager = require("warehouse.ai.npc_manager");

    OnStart = {};
    OnUpdate = {};
    OnSave = {};
    OnLoad = {};

    Resources = {};
    ResourcesDictionaryAmount ={}
}

function Activate(activateType)
   print("Activating Warehouse")
    if activateType == 0 then
       print("First Start")
        WarehouseMain:Init()

    elseif activateType == 2 then
       print("Restoring Game")
        WarehouseMain:Reload()
        --DeepPrintTable(_G)
    end

    thisEntity:SetThink(function() return WarehouseMain:OnUpdated() end,"MainUpdateLoop",1.0)
    thisEntity:SetThink(function() WarehouseMain.Money:AddMoney(0) return nil end,"moneySend",2.0)
end
function WarehouseMain:Init()
   --print("Initiating WarehouseLevel")
    --todo
    WarehouseMain.ownEntity = thisEntity
    WarehouseMain.npc_manager:init()
    table.insert( WarehouseMain.OnUpdate,WarehouseMain.MachineManager.UpdateMachines)
end

function WarehouseMain:Reload()
    --WarehouseMain = thisEntity:GetContext("warehouseContext")
end


function WarehouseMain:Reload()
   --print("loading Warehouse")
end


function WarehouseMain:OnUpdated()
    for index, value in pairs(WarehouseMain.OnUpdate) do
        local ran, errorMsg = pcall(value)
        if not ran then
            error("Function errored on run " .. tostring(index) .. "\n" .. errorMsg)
        end
    end
    return WarehouseMain.UpdateTime
end

function CreateTemplateFactory()
   --print("Trying to spawn SOmething")
    WarehouseMain.MachineManager:AddNewMachine(Assembler)
    WarehouseMain.MachineManager:AddNewMachine(Shredder)
    --WarehouseMain.MachineManager:AddNewMachine(Shredder)
    --WarehouseMain.MachineManager:AddNewMachine(Shredder)
end
local warehouseDataTable = {}

function WarehouseMain:AddResourceCount(Resource)
    if WarehouseMain.ResourcesDictionaryAmount[Resource] == nil then
        WarehouseMain.ResourcesDictionaryAmount[Resource] = 0
    end
    WarehouseMain.ResourcesDictionaryAmount[Resource] = WarehouseMain.ResourcesDictionaryAmount[Resource] +1
    WarehouseMain:AddToTable("ResourceAmount", WarehouseMain.ResourcesDictionaryAmount)

    table.sort( WarehouseMain.Resources, function (a,b)
        return a.Resource.Tier>b.Resource.Tier
    end )
end

function WarehouseMain:RemoveResource(Resource)

    WarehouseMain.ResourcesDictionaryAmount[Resource] = WarehouseMain.ResourcesDictionaryAmount[Resource]-1
    vlua.delete(WarehouseMain.Resources, Resource)
    if WarehouseMain.ResourcesDictionaryAmount[Resource] == 0 then
        WarehouseMain.ResourcesDictionaryAmount[Resource] = nil
    end
    WarehouseMain:AddToTable("ResourceAmount", WarehouseMain.ResourcesDictionaryAmount)
end

function WarehouseMain:AddToTable(key,table)
    warehouseDataTable = {}
    warehouseDataTable[key] = table
    if warehouseDataTable == nil or warehouseDataTable[key] == nil or table == nil then
        return
    end
    WarehouseMain:SendCommandToPanorama(json.encode(warehouseDataTable))
end

function WarehouseMain:SendCommandToPanorama(command)
    SendToConsole("@panorama_dispatch_event AddStyleToEachChild(\'"..command.."\')")
end

function SendTestCommand()
    WarehouseMain:SendCommandToPanorama(json.encode({TestingPanel={CountDown=Time();}}))
end

function SendTestMoney()
    WarehouseMain.Money:AddMoney(100)
end
function BuyMachine(panel,machine)
    
   --print(thisEntity:GetEntityIndex(),panel,machine)
    for index, value in pairs(MachinesIndex) do
        if value.Name == machine then
           --print(value,panel,"sgfdsg")
            local m =WarehouseMain.MachineManager:AddNewMachine(value,panel)
            UpdateMachineInfo(m:GetEntID())
        end
    end
    
end
function UpgradeMachine(panel)
    for key, value in pairs(_G.WarehouseMain.MachineManager.AvailableList) do
        if value:GetEntID() == tonumber(panel) then
            value.ownMachine.kind:Upgrade()
            UpdateMachineInfo(panel)
        end
    end
end
function UpdateMachineInfo(currentMachineID)
    local sendMachinePrices = true;
    local b = {
        Machine = nil;
        CurrentMachines = nil
    }
    b["CurrentMachines"] = {}
    for key, value in pairs(_G.WarehouseMain.MachineManager.AvailableList) do
        print(value:GetEntID(),currentMachineID)
        if value:GetEntID() == tonumber(currentMachineID) then
            print("sending info of: ",value:GetEntID())
            print("sending info of: ",value.ownMachine.kind)
            --DeepPrintTable(value)
            if value.ownMachine.kind ~= nil then
                b["CurrentMachines"]["own"] = {
                    MachineID = value:GetEntID();
                    Name = value.ownMachine.kind.Name;
                    Tier = value.ownMachine.kind.Tier;
                    UpgradePrice = value.ownMachine.kind.UpgradeCost;
                }
                sendMachinePrices = false
            end
        end
    end
    if sendMachinePrices then
        b["Machine"] = {}
        for key, value in pairs(MachinesIndex) do
           --print(key,value.Name,value," Machine")
            b["Machine"][key] = {
                Name = value.Name;
                Price = value.Price;
            }
        end
    end
    
    
    --DeepPrintTable(b)
    --DeepPrintTable(WarehouseMain.MachineManager.AvailableList)
    WarehouseMain:AddToTable("MachineUpdate",b)
end



_G.WarehouseMain = WarehouseMain
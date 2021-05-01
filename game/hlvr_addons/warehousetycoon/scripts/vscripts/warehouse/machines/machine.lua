require("warehouse.machines.templates.MachinesTemplates")

local Machine = class(
    {
        kind = nil;
        JobTemplate = nil;

        constructor = function (self,kind,job,Table)
            self.kind = kind(Table) or Assembler(Table)
            self.JobTemplate = job or BaseJob(nil,Table,nil,JobStatus.NONE)
        end;

        MachineUpdate = function (self,TimePast)
            if self.kind ~= nil then
                self.kind:MachineUpdate(TimePast)
            end
        end
    }
)

local MachineTable = {}

function AddToAvailable(t)
   --print("Adding to Available")
    if _G.WarehouseMain== nil or _G.WarehouseMain.MachineManager == nil then
        return 0.25
    end
    _G.WarehouseMain.MachineManager:AddToAvailable(t)
end


function Spawn(spawnkeys)
    local t = loadstring("return "..spawnkeys:GetValue("Group15"):gsub("(.+_)",""))()
    t.id = spawnkeys:GetValue("targetname")
    t.build = false
    t.ownMachine = Machine
    t.entity = thisEntity
    t.UIPanel = EntityGroup[2]
    t.UIEntID = t.UIPanel:entindex()
    t.UIIdName = "Machine_"..tostring(t.UIEntID)
    t.GetEntID = function()
        return EntityGroup[2]:entindex()
    end
    t[MachineTargetsIndex.BASE] = spawnkeys:GetValue(MachineTargetsIndex.BASE)

    MachineTable = t
    thisEntity:SetThink(function () return AddToAvailable(MachineTable) end,"idk",0.5)
end

Transiting = false;
TransitionQueue = {}



function DoUIPanel(action,Repeat)
    if Transiting == true and Repeat == false then
        return
    end
    Transiting = true;
   --print(action)
    if action == "Open" then
        EntFireByHandle(thisEntity,MachineTable.UIPanel,"RemoveCSSClass","playerFar")
        EntFireByHandle(thisEntity,MachineTable.UIPanel,"Enable",nil,1)
        EntFireByHandle(thisEntity,MachineTable.UIPanel,"AddCSSClass","playerNear",1.1)
        
        Transiting = false;
    elseif action == "Close" then
        EntFireByHandle(thisEntity,MachineTable.UIPanel,"RemoveCSSClass","playerNear")
        EntFireByHandle(thisEntity,MachineTable.UIPanel,"AddCSSClass","playerFar")
        thisEntity:SetThink(function ()
           --print(thisEntity,MachineTable.UIPanel)
            EntFireByHandle(thisEntity,MachineTable.UIPanel,"Disable")
            
        end,"closing",1)
        Transiting = false;
    end
    
    
end
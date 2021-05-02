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
            --print("updating seller")
            if self.kind ~= nil then
                self.kind:MachineUpdate(TimePast)
            end
        end
    }
)

local MachineTable = {}

function Spawn(spawnkeys)
    local t = {}
    t.id = spawnkeys:GetValue("targetname")
    t.build = false
    t.entity = thisEntity
    t.IsUnlocked = false
    MachineTable = t
    thisEntity:SetThink(function () return AddToFinalMachines(MachineTable) end,"idk",0.4)
end

function AddToFinalMachines(t)
    t.ownMachine = Machine(FinalClass,ProductionJob,t)
    _G.WarehouseMain.Final = t
    WarehouseMain.MachineManager.Machines[t.id] = t
end
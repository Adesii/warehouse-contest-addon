local MachineManager ={
    Machines = {};
    CurrentMachineAmount = 0;
    MachineUpdateTime = 0.5;
    AvailableList = {};
    CurrentAvailableLevel = 2;
}



function MachineManager:UpdateMachines()
    if MachineManager.Machines == nil then
        return
    end
    for key, value in pairs(MachineManager.Machines) do
        value.ownMachine:MachineUpdate(WarehouseMain.UpdateTime)
    end

end

function MachineManager:AddNewMachine(TypeOfMachine,entid)
    if entid ~= nil then
        for index, value in pairs(MachineManager.AvailableList) do
            --print(value,entid,value.UIEntID,value:GetEntID(),value.build)
            if tonumber(entid) == value:GetEntID() and value.build == false then
                value.build = true
               --print("TYPE OF MACHINE___")
               --print(TypeOfMachine)
                
                value.ownMachine = value.ownMachine(TypeOfMachine,nil,value)
                MachineManager.Machines[value:GetEntID()] = value
                value.UIPanel:AddCSSClasses("HasBuilding")
               --print("Build New Machine")
                WarehouseMain.Money:RemoveMoney(TypeOfMachine.Price)
                TypeOfMachine.Price = TypeOfMachine.Price *2
                return value
            end
        end
    end
end

function MachineManager:FindMachineOfType(resP)
    
    for machineName, product in pairs(resP.Resource.ProductionTable) do
       --print(machineName,product.Tier)
        for key, machine in pairs(MachineManager.AvailableList) do
            if machine.ownMachine.kind ~= nil then
               --print(machine,machineName,machine.ownMachine.kind.Tier,machine.ownMachine.kind.Occupied)
                if machine.ownMachine.kind.Name == machineName and machine.ownMachine.kind.Tier>=product.Tier  then
                    if machine.ownMachine.kind.Occupied == false then
                        machine.ownMachine.kind.Occupied = true
                        return machine.ownMachine.kind
                    end
                    if not machine.ownMachine.kind.working == true and machine.ownMachine.kind.CurrentProduct == nil and not machine.ownMachine.kind.worker.job == nil and machine.ownMachine.kind.worker.job.Product.Resource.Tier<=resP.Resource.Tier then
                        machine.ownMachine.kind.worker.job.ownMachine = nil
                        machine.ownMachine.kind.worker.job.state = JobStatus.WAITING
                        machine.ownMachine.kind.worker:WalktoPos(machine.ownMachine.kind.worker.entity:GetAbsOrigin())
                        machine.ownMachine.kind.worker = nil
                        machine.ownMachine.kind.Occupied = true
                        return machine.ownMachine.kind
                    end
                end
            end
        end
    end
    return WarehouseMain.Seller.ownMachine.kind
end



function MachineManager:AddToAvailable(t)
    table.insert(MachineManager.AvailableList,t)
    table.sort( MachineManager.AvailableList, function (a,b)
         return tonumber(a.id)<tonumber(b.id)
    end)
end
return MachineManager

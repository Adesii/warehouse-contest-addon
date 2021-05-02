CurrentStates={
    ["IDLE"] = 1,
    ["WAITING"] = 2,
    ["WORKING"] = 3,
    ["WAITINGFORWORK"] = 4,

}


local npc = {
    id = 0;
    currentState = CurrentStates.IDLE;
    walkenum = 0;
    toleranceDistance = 10;
    manager = nil;
    job = nil;
    entity = nil;
    HandConstraint = nil;
}


function Activate(activateType)
    if activateType == 0 then
        npc.entity = thisEntity;
        npc.walkenum = RandomInt(0,4)
        npc.manager =_G.WarehouseMain.npc_manager
        npc.manager:AddWorker(npc)
        local entKeys = {
            targetname = npc.entity:GetName().."_handanchor";
            origin = Vector(0,0,0);
        }
        npc.HandConstraint = SpawnEntityFromTableSynchronous("info_constraint_anchor",entKeys);
        npc.HandConstraint:SetParent(thisEntity,"right_hand")
        npc.HandConstraint:SetLocalOrigin(Vector(0,0,0))
    end
    if activateType == 1 then
        npc = _G.NPCList[thisEntity]
    end
end
function reload()
    
end
function npc:WalktoPos(position,tolerance)
    if thisEntity:NpcNavGoalActive() == true then
       --print("entity is walking")
        return
    end
    thisEntity:SetGraphParameterEnum("WalkForward",npc.walkenum)
    thisEntity:NpcForceGoPosition(position,true,30)
end
function npc:update()
    if npc.job then
        npc.job:JobUpdate()
    end
end
function npc:jobCompleted(job)
   --print("Completed Job: ",job.name)
end
function npc:addedWorker()
    npc.manager:GetNewJob(npc)
end
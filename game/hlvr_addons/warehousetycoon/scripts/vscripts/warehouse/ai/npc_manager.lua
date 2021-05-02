local npc_manager = {

    npcUpdateTimer = 1;
    waitingAreaName = "npc_waitingArea";
    waitingAreaEntity = nil;

    waitingSpotName = "npc_waitingSpot";
    waitingSpots = {};
    waitingSpotAmount = 0;

    waitingSpotAvoidance = "npc_waitingSpot_middle";
    waitingSpotAvoidanceEntity = nil;

    waitingArea_x = 100;
    waitingArea_y = 50;

    workerAmount = 0;
    workers = {};

    availableJobs = {};

    CostToBuy = 100;
}

function npc_manager:init()
    _G.WarehouseMain.ownEntity:SetThink(function() return lookForWaiting() end,"lookingForWaiting",1)
   --print("initiated waiting")
    _G.WarehouseMain.ownEntity:SetThink(function() return npc_manager:updateLoop() end,"updatingNPC",1)
   --print("initiated updateLoop")
end

function lookForWaiting()
    
    if npc_manager.waitingAreaEntity == nil then
        npc_manager.waitingAreaEntity = Entities:FindByName(nil,npc_manager.waitingAreaName)
        if npc_manager.waitingAreaEntity == nil then
            return 0.2
        end
        local k = 0
       --print("searching Spots:")
        for key, value in pairs(Entities:FindAllByName(npc_manager.waitingSpotName)) do
            npc_manager.waitingSpots[key] =WaitingJob(key,value)
            k = key
        end
        npc_manager.waitingSpotAmount = k
        return 0.2
    end

    npc_manager.waitingSpotAvoidanceEntity = Entities:FindByName(nil,npc_manager.waitingSpotAvoidance)
   --print("foundWaitingArea")
    --DebugDrawBox(npc_manager.waitingAreaEntity:GetAbsOrigin(),Vector(-npc_manager.waitingArea_x,-npc_manager.waitingArea_y,-5),Vector(npc_manager.waitingArea_x,npc_manager.waitingArea_y,5),255,0,0,20,5)
    local b = {}
    b["Cost"] = npc_manager.CostToBuy
    WarehouseMain:AddToTable("citizen",b)

    return nil
end

function npc_manager:AddWorker(worker)
    worker.id = npc_manager.workerAmount
    worker.entity:SetEntityName("worker_"..tostring(worker.id))
    npc_manager.workers[worker.entity] = worker
    worker:addedWorker()
    npc_manager.workerAmount = npc_manager.workerAmount+1

    _G.NPCList = npc_manager.workers
    npc_manager.CostToBuy = npc_manager.CostToBuy * 1.5
    local b = {}
    b["Cost"] = WarehouseMain.npc_manager.CostToBuy
    WarehouseMain:AddToTable("citizen",b)
    npc_manager:GetNewJob(worker)
end

function npc_manager:updateLoop()
    for i,v in pairs(npc_manager.workers) do
        if v.job == nil then
            npc_manager:GetNewJob(v)
        end
        v:update()
    end
    return npc_manager.npcUpdateTimer
end
function npc_manager:getWaitingSpot(ent)
    for key,value in pairs(npc_manager.waitingSpots) do
        if value.Occupied == false then
            value.Occupied = true
            ent.job = value
            value.worker = ent
           --print(ent.entity:GetAbsOrigin(),value.entity:GetAbsOrigin())
            ent.job:JobStart()
            return
        end
    end
    if ent.job ~= nil then
        ent.job:JobCanceled()
    end
    ent.job = WaitingJob(#npc_manager.waitingSpots,npc_manager.waitingAreaEntity,nil,JobStatus.NONE,true)
    ent.job.Occupied = true
    ent.job.worker = ent
    ent.job:JobStart()
    return
end

function npc_manager:GetNewJob(worker,p)
    if p ~= nil then
        for key, value in pairs(WarehouseMain.JobManager.Jobs) do
            if value.Product.entity == p then
                value.Occupied = true
                worker.job = value
                value.worker = worker
                worker.job:JobStart()
                return value
            end
        end
    end
    for key, value in pairs(WarehouseMain.JobManager.Jobs) do
        if value ~= nil and value.Occupied == false then
            value.Occupied = true
            if worker.job ~= nil then
                worker.job:JobCompleted()
            end
            worker.job = value
            value.worker = worker
            worker.job:JobStart()
            return value
        end
    end
    if worker.job == nil then
        npc_manager:getWaitingSpot(worker)
    elseif worker.job.name ~= "WaitingJob" then
        npc_manager:getWaitingSpot(worker)
    end
end






return npc_manager
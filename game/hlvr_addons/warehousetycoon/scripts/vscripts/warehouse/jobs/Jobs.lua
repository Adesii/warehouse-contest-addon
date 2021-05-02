local npc_manager = require "warehouse.ai.npc_manager"
JobStatus = {
    ["NONE"] = 1,
    ["WAITING"] = 2,
    ["WALKING"] = 3,
    ["INPROGRESS"] = 4,
    ["COMPLETED"] = 5,
 }

BaseJob = class(
    {
        id = 0;
        name = "N/A";
        entity = nil;
        worker = nil;
        status = JobStatus.NONE;

        GoalVector = Vector(0,0,0);


        Occupied = false;

        CompletionProgress = 0;


        constructor = function(self,Id,Entity,Worker,Status)
            self.id = Id or self.id
            self.name = self.name
            self.entity = Entity or self.entity
            self.worker = Worker or self.worker
            self.status = Status or self.status
            if self.worker then
                self:JobStart()
            end
        end;

        JobStart = function (self)
            self.status = JobStatus.INPROGRESS
        end;
        JobCompleted = function(self)
            if self.worker then
                self.worker:jobCompleted(self.name)
            end
        end;
        JobUpdate = function (self)
            
        end;
        JobCanceled = function (self)
            self.status = JobStatus.NONE
            self.worker = nil
            self.Occupied = false
        end;

        NextStatus = function (self)
            if self.status == JobStatus.INPROGRESS then
                self.status = JobStatus.COMPLETED
                self:JobCompleted()
                self.worker.manager:GetNewJob(self.worker)
            end
        end;

    }
)

WaitingJob = class({
    name = "WaitingJob";
    tries = 0;
    isArea = false;
    RandomVector = Vector(0,0,0);
    TimeWaitingInArea = 0;
    MaxTimeWaitingBeforeWaling = RandomInt(5,15);

    isSitting = false;

    constructor = function(self,Id,Entity,Worker,Status,area)
        self.id = Id or self.id
        self.name = self.name
        self.entity = Entity or self.entity
        self.worker = Worker or self.worker
        self.status = Status or self.status
        if self.worker then
            self:JobStart()
        end
        self.isArea = area or false
    end;
    JobStart = function (self)
       --print("Starting Waiting Job")
        self.status = JobStatus.INPROGRESS
       --print("to:",self.entity:GetAbsOrigin())
        self.RandomVector = Vector(RandomFloat(-self.worker.manager.waitingArea_x,self.worker.manager.waitingArea_x),RandomFloat(-self.worker.manager.waitingArea_y,self.worker.manager.waitingArea_y),0)
        
        if self.isArea == true then
            self.GoalVector = self.entity:GetAbsOrigin() + self.RandomVector
        else
            self.GoalVector = self.entity:GetAbsOrigin()
        end
        self.worker:WalktoPos(self.GoalVector,0)
    end;
    JobUpdate = function (self)
        if self.GoalVector == nil then
            self.GoalVector = self.entity:GetAbsOrigin()
        end
        if self.isArea == true and self.status ==JobStatus.WAITING then
            self.TimeWaitingInArea = self.TimeWaitingInArea + self.worker.manager.npcUpdateTimer
            
            if self.TimeWaitingInArea > self.MaxTimeWaitingBeforeWaling  then
                self.RandomVector = Vector(RandomFloat(-self.worker.manager.waitingArea_x,self.worker.manager.waitingArea_x),RandomFloat(-self.worker.manager.waitingArea_y,self.worker.manager.waitingArea_y),0)
                self.status = JobStatus.INPROGRESS
                self.GoalVector = self.entity:GetAbsOrigin() + self.RandomVector
                self.MaxTimeWaitingBeforeWaling = RandomInt(5,20)
                self.TimeWaitingInArea = 0
            end
        end
        if self.status == JobStatus.INPROGRESS and VectorDistance(self.worker.entity:GetAbsOrigin(),self.GoalVector)<40 then
            --print("Distance is lower than tolerance")
            --self.worker.manager:GetNewJob(self.worker)
            self.status = JobStatus.WAITING
        elseif self.status == JobStatus.INPROGRESS and self.worker.entity:NpcNavGoalActive() == false then
            --print("trying again")
            self.worker:WalktoPos(self.GoalVector,0)
            self.tries = self.tries+1
            if self.tries > 10 then
                self.worker:WalktoPos(npc_manager.waitingSpotAvoidanceEntity:GetAbsOrigin()+self.RandomVector,0)
                self.tries = 0
            end
        elseif self.status == JobStatus.WAITING then
            if self.isArea == false then
                --self.worker:SetGraphParameterVector("SitDirection",self.entity:GetForwardVector())
                --self.worker.entity:NpcForceGoPosition(self.entity:GetAbsOrigin()+self.entity:GetForwardVector(),true,100)
                if self.isSitting == false and self.worker.entity:NpcNavGoalActive() == false then
                    self.worker.entity:NpcForceGoPosition(self.worker.entity:GetAbsOrigin()+(self.entity:GetForwardVector()*5),true,0)
                end
                self.worker.entity:SetGraphParameterBool("Sitting",true)
                if VectorDistance(self.worker.entity:GetAbsOrigin(),self.entity:GetAbsOrigin())>2 then
                    self.worker.entity:SetOrigin(LerpVectors(self.worker.entity:GetAbsOrigin(),self.entity:GetAbsOrigin(),10*(npc_manager.npcUpdateTimer*FrameTime())))
                    self.worker.entity:NpcNavClearGoal()
                    self.isSitting = true
                end
                --self.worker.entity:SetOrigin(self.entity:GetAbsOrigin())
            end
            --print("waiting for new Job")
            self.worker.manager:GetNewJob(self.worker)
        end
    end;
    JobCompleted = function(self)
        self.isSitting = false
        self.Occupied = false
        self.worker.entity:SetGraphParameterBool("Sitting",false)
        self.worker:jobCompleted(self.name)
    end;
},{},BaseJob
)

ProductionJob = class({
    name = "ProductionJob";

    HasProduct = false;

    State = JobStatus.NONE;

    Constraint = nil;
    PickingUp = false;
    ownMachine = nil;

    constructor = function (self,Product)
        self.ProductionTable = Product.Resource.ProductionTable
        self.Product = Product
        Product.Job = self
        WarehouseMain.JobManager:AddJob(self)
       --print("Added to AvailableJobList: "..self.name.." For Product: "..self.Product.Resource.Name)
       return self
    end;
    JobStart = function (self)
       --print("Starting Production Job for item: "..self.Product.Resource.Name)
        self.State = JobStatus.INPROGRESS
        self:CalculateGoal()
        self.worker:WalktoPos(self.Goal,0)
       --print("Trying to Walk to: "..tostring(self.Goal))
    end;
    JobUpdate = function (self)
        if self.Product == nil or self.Product.entity:IsNull() then
            return
        end
        --DebugDrawCircle(self.Goal,Vector(0,255,0),255,40,true,0.125)
        if self.State == JobStatus.INPROGRESS  then
            self:CalculateGoal()
            self.worker:WalktoPos(self.Goal,0)
            local firstV =self.worker.entity:GetAbsOrigin()
            local secV =self.Product.entity:GetAbsOrigin()
            if VectorDistance(self.worker.entity:NpcNavGetGoalPosition(),self.worker.entity:GetAbsOrigin())<40 then
                self:CalculateGoal()
                self.worker.entity:NpcForceGoPosition(self.Goal,true,50)
            end
            if VectorDistance(Vector(firstV.x,firstV.y,0),Vector(secV.x,secV.y,0))<100 then
               --print("Reached Goal")
                self.State = JobStatus.WAITING
            end
        end
        if self.State == JobStatus.WAITING and self.ownMachine == nil then
            --print(self.Product.Resource.ProductionTable)
             self.ownMachine = WarehouseMain.MachineManager:FindMachineOfType(self.Product)
             if self.ownMachine.Name == "Seller" or self.ownMachine.Name == "FinalClass" then
                 table.insert(self.ownMachine.workers, self.worker)
             else
                 self.ownMachine.worker = self.worker
             end
             
         end
        if self.State == JobStatus.WAITING and self.HasProduct == false then
            self:PickUp()
           --print("looking For Machine, ",self.ownMachine)
            
           --print("looking For Machine, ",self.ownMachine)
            --DeepPrintTable(self.ownMachine)
        end
        if self.ownMachine ~= nil then
            --print(self.ownMachine.Attachments[MachineAttachemntNames.WALKTO])
            self.worker:WalktoPos(self.ownMachine.entity:GetAttachmentOrigin(self.ownMachine.Attachments[MachineAttachemntNames.WALKTO]),0)
            if VectorDistance(self.ownMachine.entity:GetAttachmentOrigin(self.ownMachine.Attachments[MachineAttachemntNames.WALKTO]),self.worker.entity:GetAbsOrigin())<40 then
                if self.Product ~= nil and not self.Product.entity:IsNull() then
                    self.Product.entity:SetParent(nil,"")
                    self.Product.entity:SetOrigin(self.ownMachine.entity:GetAttachmentOrigin(self.ownMachine.Attachments[MachineAttachemntNames.IO]))
                end
            end
        end
    end;
    PickUp = function (self)
        self.Product.entity:SetEntityName(self.worker.entity:GetName().."_product")
        self.Product.entity:SetOrigin(self.worker.HandConstraint:GetAbsOrigin())
        self.Product.entity:SetParent(self.worker.HandConstraint,"")
        self.HasProduct = true
    end;

    JobCompleted = function (self)
        self.State = JobStatus.COMPLETED
        if self.worker ~= nil then
            self.worker.job = nil
        end
        WarehouseMain.JobManager:RemoveJob(self)
    end;

    CalculateGoal = function (self)
        if not self.worker.entity:IsNull() and not self.Product.entity:IsNull() then
            self.Goal = ((-(self.worker.entity:GetAbsOrigin()-self.Product.entity:GetAbsOrigin())):Normalized()*(VectorDistance(self.worker.entity:GetAbsOrigin(),self.Product.entity:GetAbsOrigin())/2))+self.worker.entity:GetAbsOrigin()
        else
            self.Goal = self.worker.entity:GetAbsOrigin()
        end
    end
},{},BaseJob)

SellJob = class({
    name = "selljob";
    JobUpdate = function (self)
        --DebugDrawCircle(self.Goal,Vector(0,255,0),255,40,true,0.125)
        if self.State == JobStatus.INPROGRESS then
            self:CalculateGoal()
            self.worker:WalktoPos(self.Goal,0)
            local firstV =self.worker.entity:GetAbsOrigin()
            local secV =self.Product.entity:GetAbsOrigin()
            if VectorDistance(Vector(firstV.x,firstV.y,0),Vector(secV.x,secV.y,0))<40 then
               --print("Reached Goal")
                self.State = JobStatus.WAITING
            end
        end
        
        if self.State == JobStatus.WAITING and self.HasProduct == false then
            self:PickUp()
           --print("looking For Machine, ",self.ownMachine)
           if self.ownMachine == nil then
            --print(self.Product.Resource.ProductionTable)
             self.ownMachine = WarehouseMain.MachineManager:FindMachineOfType(self.Product)
             table.insert(self.ownMachine.workers, self.worker)
         end
           --print("looking For Machine, ",self.ownMachine)
            --DeepPrintTable(self.ownMachine)
        end
        if self.ownMachine ~= nil then
            --print(self.ownMachine.Attachments[MachineAttachemntNames.WALKTO])
            self.worker:WalktoPos(self.ownMachine.entity:GetAttachmentOrigin(self.ownMachine.Attachments[MachineAttachemntNames.WALKTO]),0)
            if VectorDistance(self.ownMachine.entity:GetAttachmentOrigin(self.ownMachine.Attachments[MachineAttachemntNames.WALKTO]),self.worker.entity:GetAbsOrigin())<40 then
                if self.Product ~= nil and not self.Product.entity:IsNull() then
                    self.Product.entity:SetOrigin(self.ownMachine.entity:GetAttachmentOrigin(self.ownMachine.Attachments[MachineAttachemntNames.IO]))
                end
            end
        end
    end;
},{},ProductionJob)
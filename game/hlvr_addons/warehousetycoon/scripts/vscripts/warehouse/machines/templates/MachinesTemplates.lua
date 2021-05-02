require("warehouse.products.products")
require("warehouse.economy.conveyor")
MachineTargetsIndex = {
    ["BASE"] = "Group00",
    ["ZAWARUDO"] = "Group15",
 }

MachineAttachemntNames = {
    ["EXTENSION_1"] = "EXT",
    ["IO"] = "IO",
    ["WALKTO"] = "WALK",
    ["SMOKE"] = "SMOKE"
}

 ModelResourceDictionary = {
     ["basicinteractable"] = "models/basicinteractable.vmdl",
     ["basicshredder"]="models/shredder.vmdl",
     ["basicrefiner"]="models/refiner.vmdl"
 }
ParticleResourceDictionary = {
    ["smokeParticle"] = "particles/smokeparticle.vpcf"
}

MaterialGroupIndex = {
    [1] = "default",
    [2] = "tier2",
    [3] = "tier3"
}


Assembler = class({
    BaseTarget = nil;

    Tier = Tiers.Basic;
    entity = nil;
    Working = false;
    BaseModel = {
            furniture_physics = "1",
            model = ModelResourceDictionary.basicinteractable,
    },

    MHealth = 100;
    Chance = 0.25;
    AmountToLose = 10;

    baseTable = nil;
    CurrentProduct = nil;
    NextProduct = nil;
    CurrentProductProgess = 0;

    Occupied = false;
    

    HasItem = false;
    CurrentHealth = 100;

    IORadius = 10;

    UpgradeCostPrice = 150;
    


    constructor = function (self,ownEntity)
        self.baseTable = ownEntity
        self.entity = ownEntity.entity
        
        self[MachineTargetsIndex.BASE] = Entities:FindByName(nil,ownEntity[MachineTargetsIndex.BASE])
        self.BaseModel.origin = self[MachineTargetsIndex.BASE]:GetAbsOrigin()
        self.BaseModel.angles = self.entity:GetAngles()
        self.BaseModel.targetname = self.Name.."__"..self.entity:entindex()
        self.entity = SpawnEntityFromTableSynchronous("npc_furniture",self.BaseModel)
        --self.entity:RegisterAnimTagListener(self.TagListener)
        self.Attachments = {}
        for key, value in pairs(MachineAttachemntNames) do
            
            self.Attachments[value] = self.entity:ScriptLookupAttachment(value)
        end
        self.Particles = {}
        self.UpgradeCost = self.UpgradeCostPrice
    end;
    MachineUpdate = function (self,TimePast)
        if self.Particles[MachineAttachemntNames.SMOKE] == nil and self.Working == true then
            self.entity:SetGraphParameterBool("work",true)
            self.Particles[MachineAttachemntNames.SMOKE] = ParticleManager:CreateParticle(ParticleResourceDictionary.smokeParticle,4,self.entity)
            ParticleManager:SetParticleControlEnt(self.Particles[MachineAttachemntNames.SMOKE],0,self.entity,4,MachineAttachemntNames.SMOKE,Vector(0,0,0),false)
        elseif self.Particles[MachineAttachemntNames.SMOKE] ~= nil and self.Working == false then
            self.entity:SetGraphParameterBool("work",false)
            ParticleManager:DestroyParticle(self.Particles[MachineAttachemntNames.SMOKE],false)
            self.Particles[MachineAttachemntNames.SMOKE] = nil
        end
        if self.CurrentProduct == nil then
            self:CheckIO()
        else
            self:update(TimePast)
        end
    end;
    update = function (self,TimePast)
        if self.CurrentProductProgess >= 1.0 then
           --print("Product Finished ",self.CurrentProduct.Resource.Name)
            self:MachineProductFinished()
        else
        --print(self.CurrentProductProgess)
        self.CurrentProductProgess = self.CurrentProductProgess+((TimePast/self.NextProduct.Time)*self.Tier)
        end
    end;
    CheckIO = function (self)
        --DebugDrawBox(self.entity:GetAttachmentOrigin(self.Attachments[MachineAttachemntNames.IO]),Vector(-self.IORadius,-self.IORadius,-self.IORadius),Vector(self.IORadius,self.IORadius,self.IORadius),0,255,0,50,0.1)
        local res =Entities:FindByClassnameNearest("prop_physics",self.entity:GetAttachmentOrigin(self.Attachments[MachineAttachemntNames.IO]),self.IORadius)
        if res ~= nil then
            --print("GETTING PRODUCT")
            if vlua.contains(_G.WarehouseMain.Resources,res) then
                --print("HAS Product")
                if _G.WarehouseMain.Resources[res].Resource.ProductionTable ~=nil and vlua.contains(_G.WarehouseMain.Resources[res].Resource.ProductionTable,self.Name) then
                    --print("Is in Valid")
                    self.CurrentProduct = _G.WarehouseMain.Resources[res]
                    self.NextProduct = self.CurrentProduct.Resource:NextProduct(self.Name)()
                    --DeepPrintTable(getmetatable(self.NextProduct))
                    --print(self.NextProduct.Tier,self.Tier)
                    if self.NextProduct ~= nil and self.NextProduct.Tier <= self.Tier then
                        vlua.delete(_G.WarehouseMain.Resources, self.CurrentProduct.Name)
                        self.Working = true
                    else
                        self.CurrentProduct = nil
                        self.NextProduct = nil
                        self.Working = false
                    end
                end
            end
        end
    end;
    MachineProductFinished = function (self)
        --if RandomFloat(0,1)<= self.ChanceToLooseHealth then
        --    self.CurrentHealth = self.CurrentHealth - self.AmountOfHealthToLoose
        --end
        self:MachineProductDispensed()
    end;

    MachineProductDispensed = function (self)
       --print("Dispensing new Entity")
       --print("deleting: "..self.CurrentProduct.Resource.Name)
        _G.WarehouseMain:RemoveResource(self.CurrentProduct.Resource.Name)
        local nextProd = self.CurrentProduct.Resource:NextProduct(self.Name)()
       --print("Next Production = ",nextProd)
       local entKeys = nil
       if vlua.contains(ResourceEntityKeys, nextProd.Name) then
        entKeys= ResourceEntityKeys[nextProd.Name]
       else
        entKeys = ResourceEntityKeys["BasicResource"]
       end
       --print("GotEntKeys: ",entKeys)
        entKeys.ResourceType = nextProd.Name
       --print("New Key = ",entKeys.ResourceType)
        entKeys.model = nextProd.Model
       --print(self.Attachments[MachineAttachemntNames.IO])
        entKeys.origin = self.entity:GetAttachmentOrigin(self.Attachments[MachineAttachemntNames.IO])
        --entKeys.angles = self.CurrentProduct.entity:GetAngles()
        entKeys.angles = self.entity:GetAngles()
       --print("About to destroy")
        if self.CurrentProduct.Job ~=nil then
            self.CurrentProduct.Job:JobCompleted()
        end
        if not self.CurrentProduct.entity:IsNull() then
            self.CurrentProduct.entity:Destroy()
        end
        local newP =SpawnEntityFromTableSynchronous("prop_physics",entKeys)
        if newP ~= nil and vlua.contains(nextProd.ProductionTable, self.Name) and nextProd.ProductionTable[self.Name].Tier <= self.Tier  then
            if self.worker ~= nil then
                local j = WarehouseMain.npc_manager:GetNewJob(self.worker,newP)
                self.CurrentProductProgess = 0.0;
                self.CurrentProduct = j.Product
                j.ownMachine = self
                j.State = JobStatus.WAITING
            end
        else
            if self.worker ~= nil then
               --print("Getting New Job")
                self.Occupied = false
                WarehouseMain.npc_manager:GetNewJob(self.worker,newP)
            end
            self.Working = false
            self.CurrentProduct = nil
            self.NextProduct = nil
            self.CurrentProductProgess = 0.0;
        end
        
    end;
    Upgrade = function (self)
        self.Tier = self.Tier + 1
        if MaterialGroupIndex[self.Tier] ~= nil then
            self.entity:SetMaterialGroup(MaterialGroupIndex[self.Tier])
        end
        _G.WarehouseMain.Money:RemoveMoney(self.UpgradeCost)
        self.UpgradeCost = self.UpgradeCost *2
    end
},{Name = ProductStringDictionary.Assembler;Price = 25;})


Shredder = class({
    UpgradeCostPrice = 150;
    BaseModel = {
        furniture_physics = "1",
        model = ModelResourceDictionary.basicshredder,
    },
},{Name = ProductStringDictionary.Shredder;Price = 100;},Assembler)
Refiner = class({
    UpgradeCostPrice = 250;
    BaseModel = {
        furniture_physics = "1",
        model = ModelResourceDictionary.basicrefiner,
    },
    constructor = function (self,ownEntity)
        self.baseTable = ownEntity
        self.entity = ownEntity.entity
        
        self[MachineTargetsIndex.BASE] = Entities:FindByName(nil,ownEntity[MachineTargetsIndex.BASE])
        self.BaseModel.origin = self[MachineTargetsIndex.BASE]:GetAbsOrigin()
        self.BaseModel.angles = self.entity:GetAngles()
        self.BaseModel.targetname = self.Name.."__"..self.entity:entindex()
        self.entity = SpawnEntityFromTableSynchronous("npc_furniture",self.BaseModel)
        --self.entity:RegisterAnimTagListener(self.TagListener)
        self.Attachments = {}
        for key, value in pairs(MachineAttachemntNames) do
            self.Attachments[value] = self.entity:ScriptLookupAttachment(value)
        end
        self.Particles = {}
        self.UpgradeCost = self.UpgradeCostPrice
        self.Tier = self.Tier + 1
    end;
    Upgrade = function (self)
        self.Tier = self.Tier + 1
        if MaterialGroupIndex[self.Tier-1] ~= nil then
            self.entity:SetMaterialGroup(MaterialGroupIndex[self.Tier-1])
        end
        if self.Tier-1 == Tiers.Impossible then
            _G.WarehouseMain:UnlockHomeWorld()
        end
        _G.WarehouseMain.Money:RemoveMoney(self.UpgradeCost)
        self.UpgradeCost = self.UpgradeCost *2
    end
},{Name = ProductStringDictionary.Refiner;Price = 250;},Assembler)

Seller = class({
    Name = "Seller";
    IORadius = 20;
    workers = {};
    constructor = function (self,ownEntity)
        self.baseTable = ownEntity
        self.entity = ownEntity.entity

        self.Attachments = {}
        for key, value in pairs(MachineAttachemntNames) do
            self.Attachments[value] = self.entity:ScriptLookupAttachment(value)
        end
        self.CurrentProduct = nil
    end;
    MachineUpdate = function (self)
        if self.CurrentProduct == nil then
            self:CheckIO()
        end
    end;
    CheckIO = function (self)
        --DebugDrawBox(self.entity:GetAttachmentOrigin(self.Attachments[MachineAttachemntNames.IO]),Vector(-self.IORadius,-self.IORadius,-self.IORadius),Vector(self.IORadius,self.IORadius,self.IORadius),0,255,0,50,0.1)
        local res =Entities:FindByClassnameNearest("prop_physics",self.entity:GetAttachmentOrigin(self.Attachments[MachineAttachemntNames.IO]),self.IORadius)
        if res ~= nil then
           --print("GETTING PRODUCT")
            if vlua.contains(_G.WarehouseMain.Resources,res) then
               --print("HAS Product")
                
                self.CurrentProduct = _G.WarehouseMain.Resources[res]
                --DeepPrintTable(getmetatable(self.NextProduct))
               --print("deleting: "..tostring(self.CurrentProduct.Name))
                _G.WarehouseMain:RemoveResource(self.CurrentProduct.Resource.Name)
                
                _G.WarehouseMain.Money:AddMoney(self.CurrentProduct.Resource.Worth)

                for key, value in pairs(self.workers) do
                    if value.job ~= nil and value.job.Product ~= nil and value.job.Product.entity == self.CurrentProduct.entity then
                        value.job:JobCompleted()
                       --print("Getting New Job")
                        WarehouseMain.npc_manager:GetNewJob(value)
                    end
                end
                self.CurrentProduct.entity:Destroy()
                self.CurrentProduct = nil
            end
        end
    end;
})

FinalClass = class({
    Name = "FinalClass";
    IORadius = 30;
    workers = {};

    GoalNumber = 10;
    ResourceTable={

    };

    constructor = function (self,ownEntity)
        self.baseTable = ownEntity
        self.entity = ownEntity.entity

        self.Attachments = {}
        for key, value in pairs(MachineAttachemntNames) do
            self.Attachments[value] = self.entity:ScriptLookupAttachment(value)
        end
    end;
    MachineUpdate = function (self)
        if self.CurrentProduct == nil then
            self:CheckIO()
        end
        local ending = 0
        for key, value in pairs(self.ResourceTable) do
            if value>=self.GoalNumber then
                ending = ending + 1
            end
        end
        if ending >= 3 then
            self:releaseFromHell()
        end
    end;

    releaseFromHell = function (self)
        SendToConsole("map startup")
    end;

    CheckIO = function (self)
        --DebugDrawBox(self.entity:GetAttachmentOrigin(self.Attachments[MachineAttachemntNames.IO]),Vector(-self.IORadius,-self.IORadius,-self.IORadius),Vector(self.IORadius,self.IORadius,self.IORadius),0,255,0,50,0.1)
        local res =Entities:FindByClassnameNearest("prop_physics",self.entity:GetAttachmentOrigin(self.Attachments[MachineAttachemntNames.IO]),self.IORadius)
        if res ~= nil then
           --print("GETTING PRODUCT")
            if vlua.contains(_G.WarehouseMain.Resources,res) then
               --print("HAS Product")
                
                self.CurrentProduct = _G.WarehouseMain.Resources[res]
                --DeepPrintTable(getmetatable(self.NextProduct))
               --print("deleting: "..tostring(self.CurrentProduct.Name))
                _G.WarehouseMain:RemoveResource(self.CurrentProduct.Resource.Name)

                if self.ResourceTable[self.CurrentProduct.Resource.Name] == nil then
                    self.ResourceTable[self.CurrentProduct.Resource.Name] = 0
                end
                self.ResourceTable[self.CurrentProduct.Resource.Name] = self.ResourceTable[self.CurrentProduct.Resource.Name]+1
                print(self.ResourceTable[self.CurrentProduct.Resource.Name])
                for key, value in pairs(self.workers) do
                    if  value.job.Product ~= nil and value.job.Product.entity == self.CurrentProduct.entity then
                        if value.job ~= nil then
                            value.job:JobCompleted()
                        end
                        
                       --print("Getting New Job")
                        WarehouseMain.npc_manager:GetNewJob(value)
                    end
                end
                self.CurrentProduct.entity:Destroy()
                self.CurrentProduct = nil
            end
        end
    end;
})


MachinesIndex = {
    [1] = Assembler;
    [2] = Shredder;
    [3] = Refiner;
}
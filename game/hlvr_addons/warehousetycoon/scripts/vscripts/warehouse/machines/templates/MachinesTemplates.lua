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
     ["basicshredder"]="models/shredder.vmdl"
 }
ParticleResourceDictionary = {
    ["smokeParticle"] = "particles/smokeparticle.vpcf"
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

    UpgradeCostPrice = 50;
    


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
                if vlua.contains(_G.WarehouseMain.Resources[res].Resource.ProductionTable,self.Name) then
                    --print("Is in Valid")
                    self.CurrentProduct = _G.WarehouseMain.Resources[res]
                    self.NextProduct = self.CurrentProduct.Resource:NextProduct(self.Name)()
                    --DeepPrintTable(getmetatable(self.NextProduct))
                    vlua.delete(_G.WarehouseMain.Resources, self.CurrentProduct.Name)
                    self.Working = true
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
        local entKeys = ResourceEntityKeys["BasicResource"]
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
        self.CurrentProduct.entity:Destroy()
        local newP =SpawnEntityFromTableSynchronous("prop_physics",entKeys)
        if self.worker ~= nil then
           --print("Getting New Job")
            self.Occupied = false
            WarehouseMain.npc_manager:GetNewJob(self.worker,newP)
        end
        
        self.Working = false
        self.CurrentProduct = nil
        self.CurrentProductProgess = 0.0;
        
    end;
    Upgrade = function (self)
        self.Tier = self.Tier + 1
        self.UpgradeCost = self.UpgradeCost *2
    end
},{Name = ProductStringDictionary.Assembler;Price = 25;})


Shredder = class({
    
    BaseModel = {
        furniture_physics = "1",
        model = ModelResourceDictionary.basicshredder,
    },
},{Name = ProductStringDictionary.Shredder;Price = 100;},Assembler)
Refiner = class({
    
    BaseModel = {
        furniture_physics = "1",
        model = ModelResourceDictionary.shredder,
    },
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

MachinesIndex = {
    [1] = Assembler;
    [2] = Shredder;
    [3] = Refiner;
}
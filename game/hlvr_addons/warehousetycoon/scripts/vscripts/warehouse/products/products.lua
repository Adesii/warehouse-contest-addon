ProductModelDictionary = {
    ["BaseResource"] = "models/resource.vmdl";
    ["ArmorPlate"] = "models/products/armorplate.vmdl";
    ["ResourceShards"] = "models/products/productionshards.vmdl";
}

Tiers ={
    ["Basic"] = 1,
    ["Advanced"] = 2,
    ["Impossible"] = 3
}

ProductStringDictionary = {
    ["Assembler"] = "Assembler",
    ["Shredder"] = "Shredder",
    ["Refiner"] = "Refiner",
}

--Resources
BasicResource = class({
    
    Name = "BasicResource";
    Time = 0;
    Tier = 0;
    Worth = 5;
    Model = ProductModelDictionary.BaseResource;
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Refiner] = AdvancedResource,
            [ProductStringDictionary.Assembler] = ArmorPlate,
            [ProductStringDictionary.Shredder] = ResourceShards,
        }
    end;
    NextProduct = function (self,class)
        return self.ProductionTable[class]
    end
},{}
)

AdvancedResource =class({
    Tier = Tiers.Advanced;
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Refiner] = ImpossibleResource,
        }
    end;
},{Tier = Tiers.Advanced;},BasicResource)

ImpossibleResource = class({
    Tier = Tiers.Impossible;
    constructor = function (self)
        self.ProductionTable = {
        }
    end;
},{Tier = Tiers.Impossible;},AdvancedResource)

--AssemblerProducts
ArmorPlate = class({
    Name = "ArmorPlate";
    Time = 5;
    Worth = 10;
    Model = ProductModelDictionary.ArmorPlate;
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Shredder] = EnergyPellets
        }
    end;
    
},{Tier = Tiers.Basic;},BasicResource)

ShieldedArmor = class({
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Shredder] = DarkMatter
        }
    end;
},{},AdvancedResource)

FusionCore = class({
    constructor = function (self)
        self.ProductionTable = {
        }
    end;
},{},ImpossibleResource)

--ShredderProducts
ResourceShards = class({
    Name = "ResourceShards";
    Time = 1;
    Worth = 15;
    Model = ProductModelDictionary.ResourceShards;
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Assembler] = ShieldedArmor
        }
    end;
},{Tier = Tiers.Basic;},BasicResource)

EnergyPellets = class({
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Assembler] = FusionCore
        }
    end;
},{},AdvancedResource)

DarkMatter = class({
    constructor = function (self)
        self.ProductionTable = {
        }
    end;
},{},ImpossibleResource)


ProductsClassDictionary ={
    --REFINER
    ["BasicResource"] = BasicResource;
    ["AdvancedResource"] = AdvancedResource;
    ["ImpossibleResource"] = ImpossibleResource;
    --ASSEMBLER
    ["ArmorPlate"] = ArmorPlate;
    ["ShieldedArmor"] = ShieldedArmor;
    ["FusionCore"] = FusionCore;
    --SHREDDERPRODUCTS
    ["ResourceShards"] = ResourceShards;
    ["EnergyPellets"] = EnergyPellets;
    ["DarkMatter"] = DarkMatter;


}
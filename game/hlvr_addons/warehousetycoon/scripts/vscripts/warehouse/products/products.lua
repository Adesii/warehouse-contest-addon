ProductModelDictionary = {
    ["BaseResource"] = "models/resource.vmdl";
    ["AdvancedResource"] = "models/advancedresource.vmdl";
    ["ImpossibleResource"] = "models/impossibleresource.vmdl";

    ["ArmorPlate"] = "models/products/armorplate.vmdl";
    ["Shieldedarmorplate"] = "models/products/shieldedarmorplate.vmdl";
    ["FusionCore"] = "models/products/fusioncore.vmdl";


    ["ResourceShards"] = "models/products/productionshards.vmdl";
    ["EnergyShards"] = "models/products/energyproductionshards.vmdl";
    ["DarkMatter"] = "models/products/darkmatter.vmdl";
}

Tiers ={
    ["Basic"] = 1,
    ["Advanced"] = 2,
    ["Impossible"] = 3,
    ["Infinity"] = math.maxinteger,
}

ProductStringDictionary = {
    ["Assembler"] = "Assembler",
    ["Shredder"] = "Shredder",
    ["Refiner"] = "Refiner",
}

--Resources
BasicResource = class({
    Time = 10;
    Worth = 5;
    Model = ProductModelDictionary.BaseResource;
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Refiner] = AdvancedResource,
            [ProductStringDictionary.Shredder] = ResourceShards,
            [ProductStringDictionary.Assembler] = ArmorPlate,
            
        }
    end;
    NextProduct = function (self,class)
        return self.ProductionTable[class]
    end
},{Name = "BasicResource";Tier = Tiers.Basic;}
)

AdvancedResource =class({
    Time = 22;
    Worth = 100;
    Model = ProductModelDictionary.AdvancedResource;
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Refiner] = ImpossibleResource,
            [ProductStringDictionary.Shredder] = EnergyPellets,
            [ProductStringDictionary.Assembler] = ShieldedArmor,
        }
    end;
},{Name = "AdvancedResource";Tier = Tiers.Advanced;},BasicResource)

ImpossibleResource = class({
    Time = 45;
    Worth = 250;
    Model = ProductModelDictionary.ImpossibleResource;
    constructor = function (self)
        self.ProductionTable = {
            [ProductStringDictionary.Shredder] = DarkMatter,
            [ProductStringDictionary.Assembler] = FusionCore,
        }
    end;
},{Name = "ImpossibleResource";Tier = Tiers.Impossible;},AdvancedResource)

--AssemblerProducts
ArmorPlate = class({
    Time = 4;
    Worth = 10;
    Model = ProductModelDictionary.ArmorPlate;
    constructor = function (self)
        self.ProductionTable = {
            
        }
    end;
    
},{Name = "ArmorPlate";},BasicResource)

ShieldedArmor = class({
    Time = 10;
    Worth = 125;
    Model = ProductModelDictionary.Shieldedarmorplate;
    constructor = function (self)
        self.ProductionTable = {
            
        }
    end;
},{Name = "ShieldedArmor";},AdvancedResource)

FusionCore = class({
    Time = 24;
    Worth = 275;
    Model = ProductModelDictionary.FusionCore;

    constructor = function (self)
        self.ProductionTable = {
            
        }
    end;
},{Name = "FusionCore";Tiers.Infinity;},ImpossibleResource)

--ShredderProducts
ResourceShards = class({
    Time = 5;
    Worth = 15;
    Model = ProductModelDictionary.ResourceShards;
    constructor = function (self)
        self.ProductionTable = {
            
        }
    end;
},{Name = "ResourceShards";},BasicResource)

EnergyPellets = class({
    Time = 12;
    Worth = 140;
    Model = ProductModelDictionary.EnergyShards;

    constructor = function (self)
        self.ProductionTable = {
            
        }
    end;
},{Name = "EnergyPellets";},AdvancedResource)

DarkMatter = class({
    Time = 25;
    Worth = 300;
    Model = ProductModelDictionary.DarkMatter;

    constructor = function (self)
        self.ProductionTable = {
            
        }
    end;
},{Name = "DarkMatter";Tiers.Infinity;},ImpossibleResource)


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
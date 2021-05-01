local Product = class({
    entity = nil;
    Resource = nil;
    constructor = function (self,ent,resource)
        self.entity = ent
        self.Resource = resource
    end
})
local prod = nil
function Spawn(spawnkeys)
    if spawnkeys:GetValue("ResourceType") == nil then
        prod = Product(thisEntity,BasicResource())
        _G.WarehouseMain.Resources[thisEntity] = prod
    else
        prod = Product(thisEntity,ProductsClassDictionary[spawnkeys:GetValue("ResourceType")]())
        _G.WarehouseMain.Resources[thisEntity] = prod
        _G.WarehouseMain:AddResourceCount(spawnkeys:GetValue("ResourceType"))
    end
    
end

function Activate(ass)
    Product.entity = thisEntity
    Product.job = ProductionJob(prod)
end

function AddToThisMachine(id)
   --print("Inside IO of machine of ID = ",id)
end
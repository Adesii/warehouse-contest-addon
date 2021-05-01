local Money = class(
    {
        Balance = 0;
        constructor = function(self,amount)
            self.Balance = amount
        end
    },
    {
    },
    nil
)

function Money:AddMoney(amount)
   --print("Added to Balance"..tostring(amount))
    self.Balance = self.Balance + amount
    _G.WarehouseMain:AddToTable("money", _G.WarehouseMain.Money)
end
function Money:RemoveMoney(amount)
    if self.Balance-amount >= 0 then
       --print("Removed from Balance"..tostring(amount))
        self.Balance = self.Balance - amount
        _G.WarehouseMain:AddToTable("money", _G.WarehouseMain.Money)
        return true
    end
    return false
end

return Money
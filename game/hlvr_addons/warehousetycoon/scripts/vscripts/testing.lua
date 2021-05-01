local json = require("utils.json")
local t = {
    testing = "tst";
    int = 20;
    soemthing = "else";
}

function Activate()
    thisEntity:SetThink(function() return setAtt() end,"idk",0)
end


function setAtt()

    thisEntity:SetIntAttr("plswork",10)
    --EntFire(thisEntity,"jackpot","AddCSSClass","MOTHERFUCKER")
    --EntFire(thisEntity,"jackpot","RemoveCSSClass","MOTHERFUCKER",0.3)
    SendToConsole("@panorama_dispatch_event AddStyleToEachChild(\'"..json.encode(t)..Time().." \')");
    return 0.05
end
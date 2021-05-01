"use strict";

let MachineInfoRefresh = false;
let CurrentMoney = 0;

let menu = null;

let UpgradeMenu = null;

function DecodeCommand(command) 
{  
    if(command.includes("money")){
        var decoded = JSON.parse(command);
        //$.Msg(decoded);
        var moneyCounter =  $("#currmoneycount");
        moneyCounter.text = decoded["money"].Balance;
        CurrentMoney = decoded["money"].Balance;
        menu = $("#ExpandableBuildCollection");
        UpgradeMenu = $("#ExpandableUpgradeCollection");
        if (menu) {
            menu.Children().forEach(child => {
                if (CurrentMoney <Number.parseInt(child.FindChildrenWithClassTraverse("CategoryPrice").text)) {
                    child.AddClass('CantAfford');
                }else{
                    child.RemoveClass('CantAfford');
                }
            });
        }
        if (UpgradeMenu){
            var c = UpgradeMenu.FindChildrenWithClassTraverse("Category");
            if (c.RemoveClass) {
                if (CurrentMoney <Number.parseInt(UpgradeMenu.FindChildrenWithClassTraverse("CategoryCurrentPrice").text)) {

                    c.AddClass('CantAfford');
                }else{
                    c.RemoveClass('CantAfford');
                }
            }
        }
    }
    //$.Msg(command);
    if(command.includes("MachineUpdate") && MachineInfoRefresh){
        var decoded = JSON.parse(command)["MachineUpdate"];
        menu = $("#ExpandableBuildCollection");
        UpgradeMenu = $("#ExpandableUpgradeCollection");
        menu.RemoveAndDeleteChildren();
        UpgradeMenu.RemoveAndDeleteChildren();
        $.Msg(decoded)
        for (const key in decoded["Machine"]) {
            if (Object.hasOwnProperty.call(decoded["Machine"], key)) {
                $.Msg("CreatingObject:"+key)
                var child = $.CreatePanel("Button",menu,decoded["Machine"][key]["Name"])
                child.BLoadLayoutSnippet("CategoryHeader", false, false);
                child.FindChildrenWithClassTraverse("CategoryHeading")[0].text = decoded["Machine"][key]["Name"];
                child.FindChildrenWithClassTraverse("CategoryCurrentPrice")[0].text = decoded["Machine"][key]["Price"];
                if (CurrentMoney < decoded["Machine"][key]["Price"]) {
                    child.AddClass('CantAfford');
                }else{
                    child.RemoveClass('CantAfford');
                }
            }
        }
        if (decoded["CurrentMachines"]["own"]) {
            var ownItem = decoded["CurrentMachines"]["own"];
            var upgradeChild = $.CreatePanel("Button",UpgradeMenu,ownItem["Name"]+"_u")
                
                upgradeChild.BLoadLayoutSnippet("UpgradeCategoryHeader", false, false);
                upgradeChild.FindChildrenWithClassTraverse("CategoryHeading")[0].text = ownItem["Name"];
                upgradeChild.FindChildrenWithClassTraverse("CategoryCurrentPrice")[0].text = ownItem["UpgradePrice"];
                upgradeChild.FindChildrenWithClassTraverse("CurrentTier")[0].text = ownItem["Tier"];
                if (CurrentMoney < ownItem["UpgradePrice"]) {
                    upgradeChild.AddClass('CantAfford');
                }else{
                    upgradeChild.RemoveClass('CantAfford');
                }
        }
        

        MachineInfoRefresh = false;
    }
    //$.Msg($("#testingSomething").text)
}

function SendEvent(panel,root) {  
    
    if (panel.id.includes("_u")) {
        var idd = panel.id.substring(0, panel.id - 2);
        $.DispatchEvent("ClientUI_FireOutputStr",1,"UpgradeMachine('"+root.GetOwnerEntityID()+"')");
        GetOut("upgrademenu")
    }else{
        $.DispatchEvent("ClientUI_FireOutputStr",1,"BuyMachine('"+root.GetOwnerEntityID()+"','"+panel.id+"')");
        GetOut("buildmenu")

    }
    
}


function GoDeeper(name){
    var expandable = $("#ConsoleInterior").FindChild(name);
    $("#menuCollection").AddClass("close");
    $.Msg(expandable);
    $.Msg(expandable.AddClass("open"));
    $.DispatchEvent("ClientUI_FireOutputStr", 0,"UpdateMachineInfo('"+$.GetContextPanel().GetOwnerEntityID()+"')");
    MachineInfoRefresh = true;
}

function GetOut(name){
    var expandable = $("#ConsoleInterior").FindChild(name);
    $("#menuCollection").RemoveClass("close");
    $.Msg(expandable);
    $.Msg(expandable.RemoveClass("open"));
}
function GetRootPanelOfPanel(p) {
    for (let index = 0; index < 10; index++) {
        p = p.GetParent();
        //$.Msg(p.id);
        if(p.id == "client_ui_panel" || p == undefined){
            break;
        } 
    }
    return p
}

(function()
{
    //$('#test').GetParent().GetParent().AddClass("testingClass");
    $.RegisterForUnhandledEvent("Activated", function(panel,idf)
    {
        let p = panel;
        if (!panel.BHasClass("CantAfford")) {
            p = GetRootPanelOfPanel(p);
            if ($.GetContextPanel().GetOwnerEntityID()==p.GetOwnerEntityID()) {
                SendEvent(panel,p);
            }
        }
        
      
    });
    $.RegisterForUnhandledEvent('AddStyleToEachChild',function (param,ioud) {DecodeCommand(ioud);});
    //testing();
})();
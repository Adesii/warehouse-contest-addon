function DecodeCommand(command) 
{  
    if(command.includes("ResourceAmount")){
        var decoded = JSON.parse(command);
        var resourceDisplay = $("#ResourceDisplay");
        //$.Msg(decoded)
        resourceDisplay.RemoveAndDeleteChildren();
        for (const key in decoded["ResourceAmount"]) {
            if (Object.hasOwnProperty.call(decoded["ResourceAmount"], key)) {
                const element = decoded["ResourceAmount"][key];
                var child = $.CreatePanel("Panel",resourceDisplay,key.toLowerCase())
                child.BLoadLayoutSnippet("ResourceItems");
                child.GetChild(0).text = key;
                child.GetChild(1).text = element;
                

            }
        }
        //$("#testingSomething").text = decoded["conveyorTime"].countdowntime;
    }
    //$.Msg($("#testingSomething").text)
}

(function()
{

    //$('#test').GetParent().GetParent().AddClass("testingClass");
    $.RegisterForUnhandledEvent('AddStyleToEachChild',function (param,ioud) {DecodeCommand(ioud);});
    //testing();
})();
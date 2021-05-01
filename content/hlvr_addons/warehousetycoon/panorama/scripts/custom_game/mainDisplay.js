
function DecodeCommand(command) 
{  
    if(command.includes("conveyor")){
        var decoded = JSON.parse(command);
        var progress =  $("#progress");
        //$.Msg(decoded);
        //$("#testingSomething").text = decoded["conveyorTime"].countdowntime;
        progress.min = 0;
        progress.max = 2;
        progress.value = parseFloat(decoded["conveyor"].countdowntime);
        if(decoded["conveyor"].reachedmax == true){
            $("#idReachedMax").RemoveClass("hide");
        }else if(!$("#idReachedMax").BHasClass("hide")){
            $("#idReachedMax").AddClass("hide");
        }
    }else{
        if(command.includes("money")){
            var decoded = JSON.parse(command);
            //$.Msg(decoded);
            var moneyCounter =  $("#currmoneycount");
            moneyCounter.text = decoded["money"].Balance;
        }
    }
    //$.Msg($("#testingSomething").text)
}

(function()
{
    //$('#test').GetParent().GetParent().AddClass("testingClass");
    $.RegisterForUnhandledEvent('AddStyleToEachChild',function (param,ioud) {DecodeCommand(ioud);});
    //testing();
})();
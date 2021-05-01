

function testing(Test){
    var ing = 6;
    if(Test)
    //$.Msg(Test);
    //$.Msg(ing);
    //$.Msg(Test);
    $("#test").text= Test;
    //$.Msg($("#test").GetParent());
    //$.Schedule(1,testing);
}

(function()
{
    //$('#test').GetParent().GetParent().AddClass("testingClass");
    $.RegisterForUnhandledEvent('AddStyleToEachChild',function (param,ioud) {testing(ioud)});
	$.Msg("started");
    testing();
})();
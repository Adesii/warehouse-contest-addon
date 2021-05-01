function DecodeCommand(command) 
{  
    if(command.includes("money")){
        var decoded = JSON.parse(command);
        //$.Msg(decoded);
        var moneyCounter =  $("#currmoneycount");
        moneyCounter.text = decoded["money"].Balance;
        CurrentMoney = decoded["money"].Balance;
    }
}

function fastForward1(){
    SendEvent(1.0);
}
function fastForward2(){
    SendEvent(2.0);
}
function fastForward5(){
    SendEvent(5.0);
}
function SendEvent(FastForward) {  
        $.DispatchEvent("ClientUI_FireOutputStr",0,"CMD(\'host_timescale "+FastForward+"\')");
}

function OnLoadGameMenuUI()
{
	$.RegisterForUnhandledEvent( 'VRTouchApproach', function( panel, flApproachPercentage )
	{
		if ( panel.paneltype != "Button" )
		{
			return;
		}

		//$.Msg( "VRTouchApproach( " + panel.id + ", " + flApproachPercentage + ")" );
		
		if ( !panel.BHasClass( "VRTouchApproach" ) )
		{
			panel.SetHasClass( "VRTouchApproach", true );
		}
		
		panel.style['pre-transform-scale2d'] = 0.8 + ( flApproachPercentage * 0.2 );
	} );

	$.RegisterForUnhandledEvent( 'StyleFlagsChanged', function( panel )
	 {
		if ( panel.paneltype != "Button" )
		{
			return;
		}
		
		// $.Msg( "StyleFlagsChanged( " + panel.BHasHoverStyle() + ", " + panel.BHasClass( "VRTouchApproach" ) + ")" );

		if ( !panel.BHasHoverStyle() && panel.BHasClass( "VRTouchApproach" ) )
		{
			panel.ClearPropertyFromCode( "pre-transform-scale2d" );
			panel.RemoveClass( "VRTouchApproach" );
		}
	} );
}

function OnLoadGameMenuUIUsingClasses()
{
    $.RegisterForUnhandledEvent( 'VRTouchApproach', function( panel, flApproachPercentage )
    {
		// $.Msg( "VRTouchApproach( " + JSON.stringify( panel.id ) + ": " + flApproachPercentage + " )" );

		var strActiveClass = "";
		if ( flApproachPercentage < 0.25 )
		{
			strActiveClass = "VRTouchApproach25";
		}
		else if ( flApproachPercentage < 0.5 )
		{
			strActiveClass = "VRTouchApproach50";
		}
		else if ( flApproachPercentage < 0.75 )
		{
			strActiveClass = "VRTouchApproach75";
		}
		else if ( flApproachPercentage < 0.9 )
		{
			strActiveClass = "VRTouchApproach90";
		}
		else
		{
			strActiveClass = "VRTouchApproach100";
		}

		// $.Msg( "Active class = " + strActiveClass );
        if(panel.SwitchClass)
		    panel.SwitchClass( "VRTouchApproachClass", strActiveClass );
    } );
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
    OnLoadGameMenuUI();
    OnLoadGameMenuUIUsingClasses();
})();
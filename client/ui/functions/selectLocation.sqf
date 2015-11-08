//
//      Name: selectLocation
//      Desc: Choose the current location as the deploy location and go!
//      Return: None
//

if (!isNil "GW_SPAWN_LOCATION") then {

	closeDialog 0;
	[GW_SPAWN_VEHICLE, player, GW_SPAWN_LOCATION] spawn deployBattle;	
	GW_SPAWN_ACTIVE = false;
	
};
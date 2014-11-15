if (isNil "GW_BOT_SIDE") then {
	GW_BOT_SIDE = createCenter resistance;
	GW_BOT_GROUP = createGroup resistance;
};
_bot = _this select 0;
_vehicle = _this select 1;

_posNearVehicle = [_vehicle, 5, 5] call BIS_fnc_relPos;

GW_BOT_UNIT = nil;

"I_pilot_F" createUnit [ _posNearVehicle, GW_BOT_GROUP, "GW_BOT_UNIT = this;", 1, "corporal"];

GW_BOT_UNIT assignAsDriver _vehicle; 
GW_BOT_UNIT moveInDriver _vehicle;

while {alive _vehicle} do {

	if (_bot == "SHELLBY") then {
		systemChat 'running!';
	};

	Sleep 10;
};




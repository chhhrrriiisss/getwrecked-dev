closedialog 0;


// [_pos select 0, _pos select 1, 8] spawn {

// 	_pos = [_this select 0, _this select 1,_this select 2];

// 	(vehicle player) setpos [_pos select 0, _pos select 1, 0];				
// 	openMap [false, false];
// 	TitleText [format[''], 'PLAIN DOWN'];
// 	onMapSingleClick '';

// }; true


if (isNil "GW_RACE_GENERATOR_ACTIVE") then { GW_RACE_GENERATOR_ACTIVE = false; };	
if (GW_RACE_GENERATOR_ACTIVE) exitWith {};
GW_RACE_GENERATOR_ACTIVE = true;

disableSerialization;
if(!(createDialog "GW_Race")) exitWith { GW_RACE_GENERATOR_ACTIVE = false; }; //Couldn't create the menu

_mapControl = ((findDisplay 300000) displayCtrl 300001);

GW_RACE_ARRAY = [];
GW_MARKER_ARRAY = [];

GW_MAP_X = -1;
GW_MAP_Y = -1;
GW_MAP_NUMBER = 0;

createRacePath = {
	
	//systemchat format['checking %1 / %2', time, GW_RACE_ARRAY];

	if (GW_MAP_X == -1 && GW_MAP_Y == -1) exitWith {};
	_currentPos = ((findDisplay 300000) displayCtrl 300001) ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];	
	_lastPos = if (count GW_RACE_ARRAY > 0) then { (GW_RACE_ARRAY select ((count GW_RACE_ARRAY) -1)) } else { [0,0,0] };
	GW_RACE_ARRAY set [GW_MAP_NUMBER, _currentPos];		
};



_mouseUp = _mapControl ctrlAddEventHandler ["MouseButtonUp", { 

	if (_this select 1 == 1) exitWith {};

	_mapControl = ((findDisplay 300000) displayCtrl 300001);	
	_currentPos =_mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];

	_tooClose = -1;
	for "_i" from 0 to (count GW_RACE_ARRAY) - 2 step 1 do {
		if ((GW_RACE_ARRAY select _i) distance _currentPos < 100) exitWith { _tooClose = _i; };
	};
	
	if (_tooClose >= 0 && count GW_RACE_ARRAY > 1 && GW_MAP_NUMBER != _tooClose) exitWith {
		player say3D "beep_light";
	};	

	_currentPos = _currentPos findEmptyPosition [15,75,"O_truck_03_ammo_f"];

	if (count _currentPos == 0) exitWith {
		player say3D "beep_light";
	};

	_markerstr = createMarkerLocal [format['marker_%1', random 9999],_currentPos];	
	_markerstr setMarkerShapeLocal "ICON";	
	_size = [1, 1];
	_color = switch (count GW_RACE_ARRAY) do {

		case 1: { _size = [2, 2]; "colorGreen" };
		default {
			"colorRed"
		};
	};

	// _markerstr setMarkerTextLocal format["CP_%1", count GW_MARKER_ARRAY];
	_markerstr setMarkerSizeLocal _size;	
	_markerstr setMarkerColorLocal _color;
	_markerstr setMarkerTypeLocal "hd_dot";

	GW_MARKER_ARRAY pushBack _markerstr;
	GW_RACE_ARRAY set [GW_MAP_NUMBER, _currentPos];

	GW_MAP_NUMBER = GW_MAP_NUMBER + 1; 

}];

_mouseDown = _mapControl ctrlAddEventHandler ["MouseButtonDown", { 


	if (_this select 1 == 1) exitWith {};

	// Check we're not in range of an existing marker to drag
	{

		if (_x distance [GW_MAP_X, GW_MAP_Y, 0] < 100) then {
			GW_MAP_NUMBER = _forEachIndex;
		};

	} foreach GW_RACE_ARRAY;

	_this call createRacePath; 

}];


_mouseMove = _mapControl ctrlAddEventHandler ["MouseMoving", {  GW_MAP_X = _this select 1; GW_MAP_Y = _this select 2; _this call createRacePath; }];
_mapDraw = _mapControl ctrlAddEventHandler ["Draw", {  
	
	if (count GW_RACE_ARRAY == 0) exitWith {};

	_lastPos = [0,0,0];

	{
		if (_foreachIndex == 0) then {} else {

			_lastPos = GW_RACE_ARRAY select (_foreachIndex - 1);			
			_currentPos = _x;

			_lastPosMap = (_this select 0) ctrlMapWorldToScreen _lastPos;
			_currentPosMap = (_this select 0) ctrlMapWorldToScreen _currentPos;

			_lastPos set [2, 0];
			_currentPos set [2, 0];

			_dist = (_lastPos distance _currentPos) / 2;
			_dirTo = ([_lastPos, _currentPos] call dirTo);
			_midPos = [_lastPos, _dist, _dirTo] call relPos;

			(_this select 0) drawRectangle [
				_midPos,
				10,
				_dist,
				_dirTo,
				[1,1,1,0.5],
				"#(rgb,8,8,3)color(1,0,0,1)"
			];

			// Trigger icons
			

			if ( ([GW_MAP_X, GW_MAP_Y, 0] distance _currentPosMap) < 0.1 && _forEachIndex != (count GW_RACE_ARRAY) - 1) then {
				//systemchat format['close to a marker! %1 / %2', _x, time];
			};
		};

	} foreach GW_RACE_ARRAY;

}];


Sleep 0.1;
// TitleText [format["Left click to ."], "PLAIN DOWN"];
// openMap [true, false];
//onMapSingleClick "";

// Menu has been closed, kill everything!
waitUntil { isNull (findDisplay 300000) };

{
	deleteMarkerLocal _x;
} foreach GW_MARKER_ARRAY;
// _mapControl ctrlRemoveEventHandler ["MouseButtonUp", _mouseUp];

_mapControl ctrlRemoveEventHandler ["MouseButtonDown", _mouseDown];
_mapControl ctrlRemoveEventHandler ["MouseMoving", _mouseMove];
_mapControl ctrlRemoveEventHandler ["Draw", _mapDraw];

GW_RACE_GENERATOR_ACTIVE = false;


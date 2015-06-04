closedialog 0;


// [_pos select 0, _pos select 1, 8] spawn {

// 	_pos = [_this select 0, _this select 1,_this select 2];

// 	(vehicle player) setpos [_pos select 0, _pos select 1, 0];				
// 	openMap [false, false];
// 	TitleText [format[''], 'PLAIN DOWN'];
// 	onMapSingleClick '';

// }; true


if (isNil "GW_GENERATOR_ACTIVE") then { GW_GENERATOR_ACTIVE = false; };	
if (GW_GENERATOR_ACTIVE) exitWith {};
GW_GENERATOR_ACTIVE = true;

disableSerialization;
if(!(createDialog "GW_Race")) exitWith { GW_GENERATOR_ACTIVE = false; }; //Couldn't create the menu

_mapControl = ((findDisplay 300000) displayCtrl 300001);

GW_RACE_ARRAY = [];
GW_MARKER_ARRAY = [];
GW_RACE_EDITING = false;

GW_MAP_X = -1;
GW_MAP_Y = -1;
GW_MAP_NUMBER = 0;

createRacePath = {
	
	//systemchat format['checking %1 / %2', time, GW_RACE_ARRAY];

	if ( (GW_MAP_X == -1 && GW_MAP_Y == -1) || !GW_RACE_EDITING) exitWith {};
	_currentPos = ((findDisplay 300000) displayCtrl 300001) ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];	
	_lastPos = if (count GW_RACE_ARRAY > 0) then { (GW_RACE_ARRAY select ((count GW_RACE_ARRAY) -1)) } else { [0,0,0] };
	GW_RACE_ARRAY set [GW_MAP_NUMBER, _currentPos];		
};

_mouseDblClick = _mapControl ctrlAddEventHandler ["MouseButtonDblClick", { 

	_mapControl = ((findDisplay 300000) displayCtrl 300001);
	_currentPos = _mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];	

	if (count GW_RACE_ARRAY > 2 && !GW_RACE_EDITING) exitWith {
	
		// If we're close to an existing marker, remove it
		_currentPosMap = _mapControl ctrlMapWorldToScreen _currentPos;

		{				
			_markerPos = _mapControl ctrlMapWorldToScreen (getMarkerPos _x);
			if ([GW_MAP_X, GW_MAP_Y, 0] distance _markerPos < 0.025) exitwith {
				systemchat format['close to a marker! %1 / %2', _x, time];
				deleteMarkerLocal _X;
				GW_MARKER_ARRAY deleteAt _foreachIndex;
				GW_RACE_ARRAY deleteAt _foreachIndex;
			};
		} foreach GW_MARKER_ARRAY;

	};

	if (count GW_RACE_ARRAY == 0) then {
		GW_RACE_EDITING = true;
	};

	if (count GW_RACE_ARRAY > 2 && GW_RACE_EDITING) then {		
		GW_RACE_EDITING = false;
	};

	GW_RACE_ARRAY pushback _currentPos;

}];


_mouseUp = _mapControl ctrlAddEventHandler ["MouseButtonUp", { 

	if (_this select 1 == 1 || !GW_RACE_EDITING) exitWith {};

	_mapControl = ((findDisplay 300000) displayCtrl 300001);	
	_currentPos =_mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];

	_tooClose = -1;
	for "_i" from 0 to (count GW_RACE_ARRAY) - 2 step 1 do {
		if ((GW_RACE_ARRAY select _i) distance _currentPos < 100) exitWith { _tooClose = _i; };
	};
	
	if (_tooClose >= 0 && count GW_RACE_ARRAY > 1 && GW_MAP_NUMBER != _tooClose) exitWith {
		player say3D "beep_light";
	};	

	_currentPos = _currentPos findEmptyPosition [10,75,"O_truck_03_ammo_f"];

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
	_this call createRacePath; 
}];

_mouseHold = _mapControl ctrlAddEventHandler ["MouseHolding", {  

	_tooltip = (findDisplay 300000) displayCtrl 300020;
	_tooltip ctrlSetFade 0;
	_tooltip ctrlCommit 0.2;

}];


_mouseMove = _mapControl ctrlAddEventHandler ["MouseMoving", {  

	GW_MAP_X = _this select 1; 
	GW_MAP_Y = _this select 2; 

	// _tooltip = (findDisplay 300000) displayCtrl 300020;
	// _tooltip ctrlSetPosition [ (GW_MAP_X + 0.03), GW_MAP_Y];

	// _count = count GW_RACE_ARRAY;
	// _tooltipText = if (_count == 0) then {
	// 	'Double click to add a start location' 
	// } else {
	// 	if (_count > 2) exitWith { 'Double click to add a finish line' };
	// 	'Left click to add a checkpoint' 
	// };

	// _tooltip ctrlSetStructuredText parseText( format["<t size='0.55' color='#ffffff' align='center'>%1</t>", toUpper _tooltipText] );
	// _tooltip ctrlSetFade 1;
	// _tooltip ctrlCommit 0.05;

	_this call createRacePath;
}];

drawSegment = {

	private ['_p1','_p2', '_map', '_dist', '_dirTo', '_midPos'];

	_p1 = _this select 0;
	_p2 = _this select 1;
	_color = [_this, 2, '(0,1,0,1)', ['']] call filterParam;

	disableSerialization;
	_mapControl = ((findDisplay 300000) displayCtrl 300001);

	_dist = (_p1 distance _p2) / 2;
	_dirTo = ([_p1, _p2] call dirTo);
	_midPos = [_p1, _dist, _dirTo] call relPos;

	_mapControl drawRectangle [
		_midPos,
		10,
		_dist,
		_dirTo,
		[1,1,1,0.5],
		format["#(rgb,8,8,3)color%1", _color]
	];
};

_mapDraw = _mapControl ctrlAddEventHandler ["Draw", {  
	
	if (count GW_RACE_ARRAY == 0) exitWith {};

	_lastPos = [0,0,0];

	{
		if (_foreachIndex == 0) then {} else {

			_lastPos = GW_RACE_ARRAY select (_foreachIndex - 1);			
			_currentPos = _x;


			_lastPos set [2, 0];
			_currentPos set [2, 0];

			_dirTo = ([_lastPos, _currentPos] call dirTo);		
			_dist = (_lastPos distance _currentPos) / 2;

			_segmentSize = 300;

			_prevPos = _lastPos;

			for "_i" from 0 to _dist step 100 do {	

				if (surfaceIsWater _currentPos) exitWith {};

				_dirTo = ([_prevPos, _currentPos] call dirTo);
				_nextPos = [_prevPos, _segmentSize, _dirTo] call relPos;

				_dirBack = [_nextPos, _currentPos] call dirTo;
				_dirDif = abs ([_dirBack - _dirTo] call flattenAngle);

				if (_dirDif > 90) then { _nextPos = _currentPos; };
				
				_surfaceIsWater = surfaceIsWater _nextPos;
				_found = false;
				_nextPos = if (_surfaceIsWater) then {

					_scopeStart = [_dirTo - 90] call normalizeAngle;
					_scopeEnd = [_dirTo + 90] call normalizeAngle;

					// Do a sweep across all angles from prevPoint to find one that isn't in water
					_startDir = _dirTo;
					_toggle = 1;
					for "_i" from 0 to 86 step 3 do {
						_toggle = _toggle * -1;
						_newDir = _StartDir - (_i * _toggle);
						_tempPos = [_prevPos, _segmentSize, _newDir] call relPos;
						
						if (!surfaceisWater _tempPos) exitWith { _found = true; _nextPos = _tempPos; };
					};
						
					_nextPos
				} else {
					_nextPos
				};

				_c = if (_surfaceIsWater && !_found) then { '(1,0,0,1)' } else { '(0,1,0,1)' };

				[_prevPos, _nextPos,_c] call drawSegment;

				if (_dirDif > 90) exitWith {};

				_prevPos = _nextPos;

			};


			//[_lastPos, _currentPos] call drawSegment;


			// Check for water intersects at intervals		
			

			// Trigger icons on mousenear
			_lastPosMap = (_this select 0) ctrlMapWorldToScreen _lastPos;
			_currentPosMap = (_this select 0) ctrlMapWorldToScreen _currentPos;
			
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
_mapControl ctrlRemoveEventHandler ["MouseHolding", _mouseHold];
_mapControl ctrlRemoveEventHandler ["MouseMoving", _mouseMove];
_mapControl ctrlRemoveEventHandler ["Draw", _mapDraw];
_mapControl ctrlRemoveEventHandler ["MouseButtonDblClick", _mouseDblClick]; 
GW_GENERATOR_ACTIVE = false;


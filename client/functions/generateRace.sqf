closedialog 0;

if (isNil "GW_GENERATOR_ACTIVE") then { GW_GENERATOR_ACTIVE = false; };	
if (GW_GENERATOR_ACTIVE) exitWith {};
GW_GENERATOR_ACTIVE = true;

disableSerialization;
if(!(createDialog "GW_Race")) exitWith { GW_GENERATOR_ACTIVE = false; }; //Couldn't create the menu

_mapControl = ((findDisplay 90000) displayCtrl 90001);
_mapTitle = ((findDisplay 90000) displayCtrl 90012);
_filterList = ((findDisplay 90000) displayCtrl 90011);

_mapControl ctrlEnable false;
_mapControl ctrlCommit 0;

GW_RACE_ARRAY = [];
GW_RACE_NAME = "CUSTOM RACE";

GW_MARKER_ARRAY = [];
GW_RACE_EDITING = false;
GW_MAP_DRAG = false;

GW_MAP_X = -1;
GW_MAP_Y = -1;
GW_MAP_NUMBER = 0;
GW_MAP_CLOSEST = -1;
GW_MAP_BETWEEN = -1;

clearCurrentRace = {
	
	_result = ['CLEAR POINTS?', '', 'CONFIRM'] call createMessage;
	if (typename _result != "BOOL") exitWith {};
	if (!_result) exitWith {};

	GW_RACE_ARRAY = []; 
	[] call saveCurrentRace;
};


toggleRaceEditing = {
	
	disableSerialization;
	_mapControl = ((findDisplay 90000) displayCtrl 90001);
	_mapTitle = ((findDisplay 90000) displayCtrl 90012);
	_clearButton = ((findDisplay 90000) displayCtrl 90018);
	_mapEnabled = ctrlEnabled _mapControl;
	_editButton = _this select 0;

	_mapControl ctrlEnable !_mapEnabled;
	_mapControl ctrlCommit 0;

	if (_mapEnabled) then {

		_mapTitle ctrlSetFade 0;
		_mapTitle ctrlCommit 1;

		_editButton ctrlSetText 'EDIT';
		_editButton ctrlEnable true;
		_editButton ctrlCommit 0;

		_clearButton ctrlSetFade 0;
		_clearButton ctrlCommit 0;

	} else {

		_mapTitle ctrlSetFade 1;
		_mapTitle ctrlCommit 0.25;

		_editButton ctrlSetText 'DONE';
		_editButton ctrlCommit 0;

		_clearButton ctrlSetFade 1;
		_clearButton ctrlCommit 0;

	};

};

saveCurrentRace = {
	
	_existingRaces = profileNamespace getVariable ['GW_RACES', nil];
	if (isNil "_existingRaces") exitWith { systemchat 'Error saving... corrupted race library.'; };

	_index = count _existingRaces;

	{
		_meta = _x select 0;
		_name = _meta select 0;
		if (_name == GW_RACE_NAME) exitWith { _index = _foreachIndex; };
	} foreach _existingRaces;

	_existingRaces set [_index, 
		[
			[GW_RACE_NAME, name player, worldName],
			GW_RACE_ARRAY
		]
	];

	profileNamespace setVariable ['GW_RACES', _existingRaces]; 
	saveProfileNamespace;
};


createRacePath = {
	
	//systemchat format['checking %1 / %2', time, GW_RACE_ARRAY];

	if ( (GW_MAP_X == -1 && GW_MAP_Y == -1) || !GW_RACE_EDITING) exitWith {};
	_currentPos = ((findDisplay 90000) displayCtrl 90001) ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];	
	_lastPos = if (count GW_RACE_ARRAY > 0) then { (GW_RACE_ARRAY select ((count GW_RACE_ARRAY) -1)) } else { [0,0,0] };
	GW_RACE_ARRAY set [GW_MAP_NUMBER, _currentPos];		
};

closestMarkerToMouse = {
	
	private ['_tolerance', '_closest', '_currentPos', '_pointPos', '_currentPosMap', '_pointPosMap'];

	_tolerance = [_this,0,0.1, [0]] call filterParam;
	_useMap = [_this,1,true, [false]] call filterParam;

	// If we're close to an existing marker, move it
	disableSerialization;
	_mapControl = ((findDisplay 90000) displayCtrl 90001);	

	_currentPos = _mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];	
	_currentPosMap = _mapControl ctrlMapWorldToScreen _currentPos;
	_currentPos = if (_useMap) then { _currentPosMap } else { (_currentPos) };

	_closest = -1;

	{				
		_pointPosMap = _mapControl ctrlMapWorldToScreen _x;
		_pointPos = if (_useMap) then { _pointPosMap } else { _x };

		if (_currentPos distance _pointPos < _tolerance) exitwith {
			_closest = _foreachIndex;
		};
	} foreach GW_RACE_ARRAY;

	_closest

};

_mouseDblClick = _mapControl ctrlAddEventHandler ["MouseButtonDblClick", { 

	_mapControl = ((findDisplay 90000) displayCtrl 90001);
	_currentPos = _mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];	
	_raceLength = count GW_RACE_ARRAY;

	if (_raceLength == 0) exitWith {
		GW_RACE_EDITING = true;
	};

	if (_raceLength > 2 && GW_RACE_EDITING) then {		
		GW_RACE_EDITING = false;
	};

	if ((GW_RACE_ARRAY select (_raceLength -1)) distance _currentPos < 30) then {
		GW_RACE_ARRAY deleteAt (_raceLength -1);
	};
	GW_RACE_ARRAY pushback _currentPos;

}];


_mouseUp = _mapControl ctrlAddEventHandler ["MouseButtonUp", { 
	

	disableSerialization;
	_mapControl = ((findDisplay 90000) displayCtrl 90001);	
	_currentPos =_mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];
	_raceLength = count GW_RACE_ARRAY;

	[] call saveCurrentRace;

	if ((_this select 1) == 0 && GW_MAP_BETWEEN > 0) exitWith {
		if (surfaceIsWater _currentPos) exitWith {};
		GW_RACE_ARRAY = [GW_RACE_ARRAY, GW_MAP_BETWEEN, _currentPos] call insertAt;
		GW_MAP_NUMBER = GW_MAP_NUMBER + 1; 
	};

	if ((_this select 1) == 1 || !GW_RACE_EDITING) exitWith {};

	_tooClose = -1;

	_nearbyMarker = [100, false] call closestMarkerToMouse;
	if (_nearbyMarker >= 0 && _raceLength > 1 && GW_MAP_NUMBER != _nearbyMarker) exitWith {
		player say3D "beep_light";
	};	

	_currentPos = _currentPos findEmptyPosition [10,75,"O_truck_03_ammo_f"];
	if (count _currentPos == 0) exitWith {
		player say3D "beep_light";
	};

	GW_RACE_ARRAY set [GW_MAP_NUMBER, _currentPos];
	GW_MAP_NUMBER = GW_MAP_NUMBER + 1; 

}];

_mouseDown = _mapControl ctrlAddEventHandler ["MouseButtonDown", { 

	if (!GW_RACE_EDITING && !GW_MAP_DRAG) exitWith {

		disableSerialization;
		_mapControl = ((findDisplay 90000) displayCtrl 90001);	

		if (GW_MAP_CLOSEST >= 0) exitWith {

			GW_MAP_CLOSEST spawn {

				disableSerialization;
				_mapControl = ((findDisplay 90000) displayCtrl 90001);	
				_prevPos = GW_RACE_ARRAY select _this;
				_pos = _prevPos;

				waitUntil {
					Sleep 0.05;
					_pos = _mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];					
					if (!surfaceIsWater _pos) then { GW_RACE_ARRAY set [_this, _pos]; };
					(!GW_LMBDOWN)
				};

				_pos = _pos findEmptyPosition [10,75,"O_truck_03_ammo_f"];
				_pos = if (count _pos == 0) then { player say3D "beep_light"; _prevPos } else { _pos };
				GW_RACE_ARRAY set [_this, _pos];

				GW_MAP_DRAG = false;
			};
		};
	};

}];

_mouseHold = _mapControl ctrlAddEventHandler ["MouseHolding", {  

	_tooltip = (findDisplay 90000) displayCtrl 90020;
	_tooltip ctrlSetFade 0;
	_tooltip ctrlCommit 0.2;
}];



_mouseMove = _mapControl ctrlAddEventHandler ["MouseMoving", {  
	
	

	GW_MAP_X = _this select 1; 
	GW_MAP_Y = _this select 2; 

	if (GW_MAP_DRAG) exitWith {};

	if (count GW_RACE_ARRAY == 0) exitWith {};
	
	_this call createRacePath;

}];

drawSegment = {

	private ['_p1','_p2', '_map', '_dist', '_dirTo', '_midPos'];

	_p1 = _this select 0;
	_p2 = _this select 1;
	_color = [_this, 2, '(0.99,0.85,0.23,1)', ['']] call filterParam;

	disableSerialization;
	_mapControl = ((findDisplay 90000) displayCtrl 90001);

	_dist = (_p1 distance _p2) / 2;
	_dirTo = ([_p1, _p2] call dirTo);
	_midPos = [_p1, _dist, _dirTo] call relPos;

	_mapControl drawRectangle [
		_midPos,
		([ (50 * ctrlMapScale _mapControl), 5, 30] call limitToRange),
		_dist,
		_dirTo,
		[1,1,1,0.5],
		format["#(rgb,8,8,3)color%1", _color]
	];
};

_mapKeyDown = _mapControl ctrlAddEventHandler ["KeyDown", {  
	
	if (!GW_RACE_EDITING && (_this select 1) == 211 && GW_MAP_CLOSEST >= 0) exitWith {
		GW_RACE_ARRAY deleteAt GW_MAP_CLOSEST;
	};

}];

_mapDraw = _mapControl ctrlAddEventHandler ["Draw", {  
	
	_raceLength = count GW_RACE_ARRAY;
	if (count GW_RACE_ARRAY == 0) exitWith {};

	_lastPos = [0,0,0];
	GW_MAP_CLOSEST = [0.05] call closestMarkerToMouse;

	disableSerialization;
	_mapControl = ((findDisplay 90000) displayCtrl 90001);
	_mousePos = _mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];	
	 GW_MAP_BETWEEN = -1;

	{
		if (_foreachIndex == 0) then {} else {

			_lastPos = GW_RACE_ARRAY select (_foreachIndex - 1);			
			_currentPos = _x;
			
			// Mouse between these two points?		
			_maxDist = _lastPos distance _currentPos;
			if (_mousePos distance _currentPos > _maxDist || _mousePos distance _lastPos > _maxDist) then {} else {

				// Mouse angle is close enough to angle between points	
				_dirMouseToMarker = [_mousePos, _currentPos] call dirTo;
				_dirMarkerToNext = [_lastPos, _currentPos] call dirTo;
				_difDir = abs ([_dirMouseToMarker - _dirMarkerToNext] call flattenAngle);

				if (_difDir < 0.5 && (_mousePos distance _currentPos > 100) && (_mousePos distance _lastPos > 100) && !GW_RACE_EDITING) then {
					GW_MAP_BETWEEN = _forEachIndex;
				};

			};

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
					for "_i" from 0 to 90 step 10 do {
						_toggle = _toggle * -1;
						_newDir = _StartDir - (_i * _toggle);
						_tempPos = [_prevPos, _segmentSize, _newDir] call relPos;
						
						if (!surfaceisWater _tempPos) exitWith { _found = true; _nextPos = _tempPos; };
					};
						
					_nextPos
				} else {
					_nextPos
				};

				_c = if (_surfaceIsWater && !_found) then { '(1,0,0,1)' } else { '(0.99,0.85,0.23,1)' };

				[_prevPos, _nextPos,_c] call drawSegment;

				if (_dirDif > 90) exitWith {};

				_prevPos = _nextPos;

			};
		
		};

		_color = [1,1,1,1];
		_scale = [ (100 * ctrlMapScale (_this select 0)), 35, 100] call limitToRange;

		_iconToUse = switch (true) do {
			case (_foreachIndex == 0): { _scale = _scale * 1.5; startMarkerIcon };
			case (
				(_raceLength > 1 &&  _foreachIndex == (_raceLength -1) && !GW_RACE_EDITING)		
			) : { _scale = _scale * 1.5; finishMarkerIcon };
			default { checkpointMarkerIcon };
		};

		_dirTo = if (_raceLength > 1 && _forEachIndex < (_raceLength - 1) && _foreachIndex > 0) then {
			([([_x, GW_RACE_ARRAY select (_foreachIndex + 1)] call dirTo) - 90] call normalizeAngle)
		} else { 0 };

		if (GW_LMBDOWN && _foreachIndex == GW_MAP_CLOSEST) then {
			_color set [3, 0.5];
		};

		if (_foreachIndex == GW_MAP_CLOSEST && !GW_LMBDOWN) then {

			_scale = _scale * 1.25;
			
			// Draw icons for each point
			(_this select 0) drawIcon [
				markerBoxIcon,
				_color,
				_x,
				_scale,
				_scale,
				_dirTo,
				'',
				0,
				0.1,
				'puristaMedium',
				'center'
			];	

		};

		// Draw icons for each point
		(_this select 0) drawIcon [
			_iconToUse,
			_color,
			_x,
			_scale,
			_scale,
			_dirTo,
			'',
			0,
			0.1,
			'puristaMedium',
			'center'
		];

		if (GW_MAP_BETWEEN > 0 && GW_MAP_BETWEEN == _foreachIndex && !GW_LMBDOWN) then {

			_dirPrev = if (_foreachIndex > 0) then { ([([GW_RACE_ARRAY select (_foreachIndex - 1), _x] call dirTo) - 90] call normalizeAngle) } else { 0 };

			// Additionally draw a tempIcon if mouse is currently between points
			(_this select 0) drawIcon [
				checkpointMarkerAddIcon,
				[1,1,1,0.5],
				_mousePos,
				30,
				30,
				_dirPrev,
				'',
				0,
				0.1,
				'puristaMedium',
				'center'
			];

		};

	} foreach GW_RACE_ARRAY;

}];


Sleep 0.1;
// TitleText [format["Left click to ."], "PLAIN DOWN"];
// openMap [true, false];
//onMapSingleClick "";

// Menu has been closed, kill everything!
waitUntil { isNull (findDisplay 90000) };

_mapControl ctrlRemoveEventHandler ["KeyDown", _mapKeyDown];
_mapControl ctrlRemoveEventHandler ["MouseButtonUp", _mouseUp];
_mapControl ctrlRemoveEventHandler ["MouseButtonDown", _mouseDown];
_mapControl ctrlRemoveEventHandler ["MouseHolding", _mouseHold];
_mapControl ctrlRemoveEventHandler ["MouseMoving", _mouseMove];
_mapControl ctrlRemoveEventHandler ["MouseButtonDblClick", _mouseDblClick]; 
_mapControl ctrlRemoveEventHandler ["Draw", _mapDraw];

GW_GENERATOR_ACTIVE = false;


//
//      Name: race
//      Desc: 
//      Return: 
//

closedialog 0;

if (isNil "GW_RACE_GENERATOR_ACTIVE") then { GW_RACE_GENERATOR_ACTIVE = false; };	
if (GW_RACE_GENERATOR_ACTIVE) exitWith {};
GW_RACE_GENERATOR_ACTIVE = true;

GW_RACE_ACTIVE = false;

params ['_pad', '_unit'];

_isVehicleReady = [_pad, _unit] call vehicleReadyCheck;
if (!_isVehicleReady) exitWith { GW_RACE_GENERATOR_ACTIVE = false; };
	
disableSerialization;
if(!(createDialog "GW_Race")) exitWith { GW_RACE_GENERATOR_ACTIVE = false; }; //Couldn't create the menu

showChat false;

calculateDistance = {
	params ['_array'];
	private ['_array'];

	_d = 0;
	{
		if (_foreachIndex == ((count _array) - 1)) exitWith {};
		_d = _d + (_x distance (_array select (_foreachIndex + 1)));
	} foreach _array;	

	_d = if (_d > 1000) then { format['%1km', [_d / 1000, 1] call roundTo ] } else { format['%1m', [_d, 1] call roundTo ]};

	_d

};

getAllRaces = {
	_rcs = profileNamespace getVariable ['GW_RACES', []];
	_rcs = if (count _rcs == 0) then {
		[] call createDefaultRaces; 
		(profileNamespace getVariable ['GW_RACES', []])
	} else { _rcs };

	_libraryRaces = +_rcs;

	// Get a quick reference array including active race names
	_activeRaces = [];
	{ _activeRaces pushback ((_x select 0) select 0);	} foreach GW_ACTIVE_RACES;

	// Hide races in library that are the same as active races
	{
		_name = (_x select 0) select 0;
		if (_name in _activeRaces) then { _libraryRaces deleteAt _foreachIndex; };
	} foreach _libraryRaces;

	// Merge the two arrays and return
	_totalRaces = +GW_ACTIVE_RACES;
	_totalRaces append _libraryRaces;
	_totalRaces
};

startRace = {	

	if (GW_RACE_ACTIVE) exitWith { systemchat 'You cant host more than one race at a time.'; };
	GW_RACE_ACTIVE = true;

	_existingRaces = (call getAllRaces);
	_id = [_this, 0, [0]] call filterParam;;
	_id = [abs _id, 0, (count _existingRaces)-1] call limitToRange;

	_selectedRace = (call getAllRaces) select _id;
	_points = _selectedRace select 1;
	_meta = (_selectedRace select 0);
	_name = _meta select 0;

	_minPlayers = if (GW_DEBUG) then { 1 } else { 2 };
	_meta set [3, _minPlayers];

	_maxWaitPeriod = if (GW_DEBUG) then { 15 } else { 60 };
	_meta set [4, _maxWaitPeriod];

	_host = (name player);
	_raceStatus = [_name] call checkRaceStatus;

	// Check a race with that name is not currently running
	_exists = false;
	{
		if (((_x select 0) select 0) == _name) exitWith { _exists = true; };
		if (((_x select 1) select 0) distance (_points select 0) < 100) exitWith { _exists = true; };
	} foreach GW_ACTIVE_RACES;

	// Calculate total distance for this race
	_distance = [_points] call calculateDistance;

	// If we're targetting a race that's already running, go straight to deploy
	if (_exists) exitWith {

		// Race is a new one
		if (_raceStatus == -1) exitWith {
			systemchat 'A race in that area is already active.';
		};

		if (_raceStatus >= 2) exitWith {
			systemchat 'Race active and not currently joinable.';

			//closeDialog 0;
			//[] execVM 'testspectatorcamera.sqf';

		};

		closeDialog 0;

		// Send player to zone and begin waiting period for races that are already active
		_success = [GW_SPAWN_VEHICLE, player, _selectedRace] call deployRace;
		_success = true;
		GW_SPAWN_ACTIVE = false;

		if (!_success) exitWith {
			systemchat 'Deployment cancelled.';
			GW_RACE_ACTIVE = false;
			GW_HUD_ACTIVE = true;
			GW_HUD_LOCK = false;
		};
	};

	// Confirmation in case of mis-click
	_result = ['START RACE?', format['%1 [%2]', _name, _distance], 'CONFIRM'] call createMessage;
	if (!_result) exitWith { GW_RACE_ACTIVE = false; };	
	
	//_selectedRace pushback _host;
	_selectedRace pushback _host;
	// GW_ACTIVE_RACES pushback _selectedRace;

	// // Get index of race for reference
	// _raceID = -1;
	// { 
	// 	if (_name == ((_x select 0) select 0)) exitWith { _raceID = _foreachIndex; };
	// } foreach GW_ACTIVE_RACES;

	// Sync race to all clients
	systemchat 'Sending race data to server...';

	// Initialize race thread on server
	[
		[format['%1', _selectedRace]],
		'createRace',
		false,
		false
	] call bis_fnc_mp;	

	closeDialog 0;

	// Wait for server to update race to 'waiting'
	_timeout = time + 5;
	waitUntil {
		Sleep 1;
		['WAITING FOR SERVER...', 0.5, warningIcon, nil, "slideUp"] spawn createAlert; 
		( (([_name] call checkRaceStatus) == 0) || (time > _timeout) )
	};

	
	if (time > _timeout) exitWith {

		GW_RACE_ACTIVE = false;

		// Find and delete added race entry 9if exists)
		{ 
			if (_name == ((_x select 0) select 0)) exitWith { 
				GW_ACTIVE_RACES deleteAt _foreachIndex;
				publicVariable "GW_ACTIVE_RACES";
			};
		} foreach GW_ACTIVE_RACES;

		GW_HUD_ACTIVE = true;
		GW_HUD_LOCK = false;

		Sleep 1;
		['FAILED TO START!',1, warningIcon, colorRed, "slideUp"] spawn createAlert; 
	};	

	GW_HUD_ACTIVE = false;
	GW_HUD_LOCK = true;

	// Send player to zone and begin waiting period
	_success = [GW_SPAWN_VEHICLE, player, _selectedRace] call deployRace;
	GW_SPAWN_ACTIVE = false;

	if (!_success) exitWith {
		GW_RACE_ACTIVE = false;
		GW_HUD_ACTIVE = true;
		GW_HUD_LOCK = false;
	};

};


selectRace = {
	
	private ['_existingRaces', '_selection', '_raceData', '_raceStatus', '_raceMeta', '_isDefault'];

	_existingRaces = call getAllRaces;

	_selection = [_this, 0, (count _existingRaces) - 1, true] call limitToRange;

	_raceData = _existingRaces select _selection;
	
	GW_RACE_ARRAY = (_raceData select 1);
	GW_RACE_NAME = (_raceData select 0) select 0;	
	GW_RACE_HOST = [_raceData, 2, "NONE", [""]] call filterParam;
	GW_RACE_ID = _selection;


	_startButton = ((findDisplay 90000) displayCtrl 90015);
	_raceStatus = [GW_RACE_NAME] call checkRaceStatus;

	_startText = _raceStatus call {
		if (_this == -1) exitWith { 'START' };
		if (_this == 0) exitWith { 'JOIN' };
		If (_this == 2) exitWith { 'NOT JOINABLE' };
		'START'
	};

	_startButton ctrlSetText _startText;
	_startButton ctrlCommit 0;	

	_buttonFade = if (GW_RACE_HOST == "NONE") then { 0 } else { 1 };
	_editButton = ((findDisplay 90000) displayCtrl 90020);
	_renameButton = ((findDisplay 90000) displayCtrl 90021);
	_deleteButton = ((findDisplay 90000) displayCtrl 90018);

	{
		_x ctrlEnable true;
		// _x ctrlShow true;		
		_x ctrlSetFade _buttonFade;
		_x ctrlCommit 0;
	} foreach [_editButton, _renameButton, _deleteButton];

	_mapTitle = ((findDisplay 90000) displayCtrl 90012);
	_mapTitle ctrlSetText GW_RACE_NAME;
	_mapTitle ctrlCommit 0;

	// If default map, hide delete button
	_raceMeta = _raceData select 0;
	_isDefault = [_raceMeta, 3, false, [false]] call filterParam;

	if (_isDefault || _raceStatus >= 0) then {		


		_deleteButton ctrlEnable false;	
		_deleteButton ctrlSetFade 1;
		_deleteButton ctrlCommit 0;
	};

	[] call focusCurrentRace;



};

generateRaceList = {
	
	_selected = [_this, 0, 0, [0]] call filterParam;

	disableSerialization;
	_filterList = ((findDisplay 90000) displayCtrl 90011);
	lbClear _filterList;

	_existingRaces = call getAllRaces;

	{
		_meta = _x select 0;
		_name = _meta select 0;
		_host =  [_x, 2, "", [""]] call filterParam;

		if ((count toArray _host) > 0) then { 
			_host = format[' [ACTIVE, %1]', _host];
		};

		lbAdd [90011,  format[' %1%2', _name,_host] ];
		lbSetData [90011, _forEachIndex, _name];	


	} foreach _existingRaces;

	lbSetCurSel [90011, _selected];

};

focusCurrentRace = {
	_mapControl = ((findDisplay 90000) displayCtrl 90001);
	_startPos = GW_RACE_ARRAY select 0;
	_endPos = GW_RACE_ARRAY select ((count GW_RACE_ARRAY) -1);
	_dir = [_startPos, _endPos] call dirTo;
	_midPos = [_startPos, ((_startPos distance _endPos) / 2), _dir] call relPos;
	_startPosMap = (_mapControl ctrlMapWorldToScreen _startPos);
	_endPosMap = (_mapControl ctrlMapWorldToScreen _endPos);
	_screenYDist = [_startPosMap select 0, _startPosMap select 1, 0] distance [_startPosMap select 0, _endPosMap select 1, 0];
	_screenXDist = [_startPosMap select 0, _startPosMap select 1, 0] distance [_endPosMap select 0, _startPosMap select 1, 0];
	_multiplier = if (_screenXDist > _screenYDist) then { (_screenXDist / 0.5) } else { (_screenYDist / 0.3) };
	_mapControl ctrlMapAnimAdd [0.25, (1 * _multiplier), _midPos];
	ctrlMapAnimCommit _mapControl;
};

createNewRace = {
	
	_existingRaces = call getAllRaces;
	_raceName = toUpper([true] call generateName);
	_existingRaces pushBack [[_raceName,(name player),worldName], [[22845.5,18443,0],[23190.5,17340.5,0],[24414.8,18932.3,0]]];
	profileNamespace setVariable ['GW_RACES', _existingRaces];
	saveProfileNamespace;

	[((count _existingRaces) -1)] call generateRaceList;
	// [(_existingRaces select ((count _existingRaces) -1))] call selectRace;

};


_mapControl = ((findDisplay 90000) displayCtrl 90001);
_mapTitle = ((findDisplay 90000) displayCtrl 90012);
_mapControl ctrlEnable false;
_mapControl ctrlCommit 0;

_existingRaces = call getAllRaces;

GW_RACE_NAME = '';
GW_RACE_DATA = [];
GW_RACE_ID = 0;

_selection = (floor (random (count _existingRaces)));
_selection call generateRaceList;

GW_MARKER_ARRAY = [];
GW_RACE_EDITING = false;
GW_MAP_DRAG = false;

GW_MAP_X = -1;
GW_MAP_Y = -1;
GW_MAP_NUMBER = 0;
GW_MAP_CLOSEST = -1;
GW_MAP_BETWEEN = -1;


deleteRace = {
	
	private ['_raceToDelete', '_existingRaces', '_meta', '_name'];

	_raceToDelete = [_this, 0, GW_RACE_NAME, [""]] call filterParam;

	_result = if (isNil {_this select 0}) then { ([format['DELETE %1?', _raceToDelete], '', 'CONFIRM'] call createMessage) } else { true };
	if (!_result) exitWith {};	

	_existingRaces = call getAllRaces;

	systemchat format['%1 / %2', _raceToDelete, GW_RACE_NAME];

	{
		_meta = _x select 0;
		_name = _meta select 0;
		if (_name == _raceToDelete) exitWith { _existingRaces deleteAt _forEachIndex; };
	} foreach _existingRaces;

	profileNamespace setVariable ['GW_RACES', _existingRaces];
	saveProfileNamespace;

	[((count _existingRaces) -1)] call generateRaceList;
		
};

renameCurrentRace = {

	private ['_result'];
	
	_originalName = GW_RACE_NAME;
	_result = ['RENAME RACE', toUpper(GW_RACE_NAME), 'INPUT'] call createMessage;	

	if !(_result isEqualType "") exitWith {};
	if (_result == GW_RACE_NAME) exitWith {};
	if (count toArray _result == 0) exitWith {}; 		

	GW_RACE_NAME = [toUpper (_result), 10] call cropString;
	[] call saveCurrentRace;

	// Delete previous race entry
	[_originalName] call deleteRace;

	disableSerialization;
	_mapTitle = ((findDisplay 90000) displayCtrl 90012);
	_mapTitle ctrlSetText GW_RACE_NAME;
	_mapTitle ctrlCommit 0;

};

clearCurrentRace = {
	
	private['_result'];
	
	_result = ['CLEAR POINTS?', '', 'CONFIRM'] call createMessage;
	if !(_result isEqualType true) exitWith {};
	if (!_result) exitWith {};

	GW_RACE_ARRAY = []; 
	[] call saveCurrentRace;
};


toggleRaceEditing = {
	
	disableSerialization;
	_display = (findDisplay 90000);
	_mapControl = (_display displayCtrl 90001);
	_mapTitle = (_display displayCtrl 90012);

	_nonEditorControls = [
		(_display displayCtrl 90011),
		(_display displayCtrl 90018),
		(_display displayCtrl 90017),
		(_display displayCtrl 90016),
		(_display displayCtrl 90015),
		(_display displayCtrl 90014),
		(_display displayCtrl 90022)
	];

	_mapEnabled = ctrlEnabled _mapControl;
	params ['_editButton'];

	_mapControl ctrlEnable !_mapEnabled;
	_mapControl ctrlCommit 0;

	if (_mapEnabled) then {

		_mapTitle ctrlSetFade 0;
		_mapTitle ctrlCommit 1;

		_editButton ctrlSetText 'EDIT';
		_editButton ctrlEnable true;
		_editButton ctrlCommit 0;

		{
			_x ctrlSetFade 0;
			_x ctrlCommit 0;
		} foreach _nonEditorControls;

		[] call focusCurrentRace;
		[] call saveCurrentRace;

	} else {

		_mapTitle ctrlSetFade 1;
		_mapTitle ctrlCommit 0.25;

		_editButton ctrlSetText 'SAVE';
		_editButton ctrlCommit 0;

		{
			_x ctrlSetFade 1;
			_x ctrlCommit 0;
		} foreach _nonEditorControls;

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

	// Find the closest point to current mouse position
	{				
		_pointPosMap = _mapControl ctrlMapWorldToScreen _x;
		_pointPos = if (_useMap) then { _pointPosMap } else { _x };
		if (_currentPos distance _pointPos < _tolerance) exitwith {	_closest = _foreachIndex; };
	} foreach GW_RACE_ARRAY;

	_closest

};

_mouseDblClick = _mapControl ctrlAddEventHandler ["MouseButtonDblClick", { 

	_mapControl = ((findDisplay 90000) displayCtrl 90001);
	_currentPos = _mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];	
	_raceLength = count GW_RACE_ARRAY;

	// Delete nearby markers on double click
	if ((GW_RACE_ARRAY select (_raceLength -1)) distance _currentPos < 30 && (count GW_RACE_ARRAY) > 2) then {
		GW_RACE_ARRAY deleteAt (_raceLength -1);
	};

	// Add a marker at current location
	GW_RACE_ARRAY pushback _currentPos;

}];


_mouseUp = _mapControl ctrlAddEventHandler ["MouseButtonUp", { 
	

	disableSerialization;
	_mapControl = ((findDisplay 90000) displayCtrl 90001);	
	_currentPos =_mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];
	_raceLength = count GW_RACE_ARRAY;

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

		if (GW_MAP_CLOSEST >= 0 && (_this select 1) == 0) exitWith {

			GW_MAP_CLOSEST spawn {

				disableSerialization;
				_mapControl = ((findDisplay 90000) displayCtrl 90001);	
				_prevPos = GW_RACE_ARRAY select _this;
				_pos = _prevPos;

				waitUntil {
					_pos = _mapControl ctrlMapScreenToWorld [GW_MAP_X, GW_MAP_Y];					
					if (!surfaceIsWater _pos) then { GW_RACE_ARRAY set [_this, _pos]; };
					(!GW_LMBDOWN)
				};

				_pos = _pos findEmptyPosition [5,25,"O_truck_03_ammo_f"];
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
}];

drawSegment = {

	private ['_p1','_p2', '_map', '_dist', '_dirTo', '_midPos'];
	params ['_p1', '_p2'];
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
	
	if (!GW_RACE_EDITING && (_this select 1) == 211 && GW_MAP_CLOSEST >= 0 && (count GW_RACE_ARRAY) > 2) exitWith {
		GW_RACE_ARRAY deleteAt GW_MAP_CLOSEST;
	};

}];

_mapDraw = _mapControl ctrlAddEventHandler ["Draw", {  
	
	_raceLength = count GW_RACE_ARRAY;
	if (count GW_RACE_ARRAY == 0) exitWith {};

	_lastPos = [0,0,0];
	GW_MAP_CLOSEST = [0.05] call closestMarkerToMouse;

	disableSerialization;
	_mapControl = (_this select 0);
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

			_segments = [];

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

				_segments pushBack [_prevPos, _nextPos,_c];			
			
				if (_dirDif > 90) exitWith {};

				_prevPos = _nextPos;

			};

			if (count _segments == 0) exitWith { [_lastPos, _currentPos] call drawSegment; };
			{ [(_x select 0), (_x select 1), (_x select 2)] call drawSegment; false } count _segments;
		
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

// Menu has been closed, kill everything!
waitUntil { isNull (findDisplay 90000) };

_mapControl ctrlRemoveEventHandler ["KeyDown", _mapKeyDown];
_mapControl ctrlRemoveEventHandler ["MouseButtonUp", _mouseUp];
_mapControl ctrlRemoveEventHandler ["MouseButtonDown", _mouseDown];
_mapControl ctrlRemoveEventHandler ["MouseHolding", _mouseHold];
_mapControl ctrlRemoveEventHandler ["MouseMoving", _mouseMove];
_mapControl ctrlRemoveEventHandler ["MouseButtonDblClick", _mouseDblClick]; 
_mapControl ctrlRemoveEventHandler ["Draw", _mapDraw];

GW_RACE_GENERATOR_ACTIVE = false;

showChat true;


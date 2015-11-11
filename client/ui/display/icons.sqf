// Current Checkpoints
{	
	if (count GW_CHECKPOINTS == 0 && count GW_CHECKPOINTS_COMPLETED == 0) exitWith { false };
	_completedArray = (_x select 1);
	_totalCheckpoints = (count GW_CHECKPOINTS) + (count GW_CHECKPOINTS_COMPLETED);
	_currentCheckpoint = [(_totalCheckpoints - (count GW_CHECKPOINTS)) + 1, 0, _totalCheckpoints] call limitToRange;

	// systemchat format['%1 / %2', _totalCheckpoints, _currentCheckpoint];

	_arr = (_x select 0);
	{		

		_pos =  if (typename _x == "OBJECT") then { _x modelToWorldVisual [0, 0, 8]; } else { (_x select 0) };

		_dist = (GW_CURRENTVEHICLE distance _pos);
		_alpha = [1 - (_dist / 1000), 0.05, 1] call limitToRange;

		_alpha = if (_completedArray) then { 
			_prevAlpha = (_x select 2);
			_prevAlpha = [_prevAlpha - 0.005, 0, 1] call limitToRange;
			_x set [2, _prevAlpha];
			_prevAlpha
		} else { _alpha };
		_alpha = if (_forEachIndex == 0 && !_completedArray) then { 1 } else { _alpha };

		if (_alpha <= 0) then {} else {

			// _alpha = if (_completedArray) then { _alpha } else {			
			// 	if (_forEachIndex > 0) exitWith { (_alpha/2) };
			// 	_alpha
			// };

			_size = [2.5 - (_dist / 100), 1.2, 2.5] call limitToRange;
			_fontSize = if (_completedArray) then { ([(0.06 - (_dist / 10000)), (0.03), (0.06)] call limitToRange)  } else { (0.032) };
			_pos set [2, ([(_dist / 15), 0, 4] call limitToRange)];

			// Only render current checkpoint for in-progress array
			if (_forEachIndex > 2 && !_completedArray) exitWith {};

			// Change icon for completed checkpoints
			_icon = if (_completedArray) then { okIcon } else { 				
				if (_forEachIndex == 0 && (count GW_CHECKPOINTS_COMPLETED) == 0) exitWith {	startMarkerIcon	};
				if (_forEachIndex == ((count GW_CHECKPOINTS)-1) ) exitWith { finishMarkerIcon };
				checkpointMarkerIcon 	
			};

			
			// Offscreen marker render
			// _dT = [(positionCameraToWorld [0,0,0]), _pos] call dirTo;
			// _dif = [GW_TARGET_DIRECTION - _dT] call flattenAngle;
			// _offScreen = if ((abs _dif) > 45 && !_completedArray && _forEachIndex == 0) exitWith { 
			

			// 	_rot = 0;
			// 	_xPos = if (_dif < 0) then { _rot = 270; 0.9352 } else { _rot = 90; -0.352 };
			// 	_yPos = [1 - ( ((positionCameraToWorld [0,0,0]) select 2) / (_pos select 2) ), safeZoneY, (safeZoneY + safeZoneH)] call limitToRange;
				
			// 	hint format['POS: %1', _xPos];

			// 	_pos = screenToWorld [_xPos * safezoneW + safezoneX, _yPos * safezoneH + safezoneY];
			// 	_icon = format['%1%2', MISSION_ROOT, 'client\images\checkpoint_halo2.paa'];
			// 	_index = "";
			// 	_size = 5;

			// 	drawIcon3D [_icon,[255,255,255,_alpha],_pos,_size,_size,_rot, _index,0, _fontSize, "PuristaMedium"];		

			// };
			
			// Display distance and checkpoint index information
			_index = if (_completedArray) then { (_x select 1) } else { 

				if (_forEachIndex > 0) exitWith { '' };
				_dist = if (_dist > 5000) then { format['%1km', [_dist / 1000, 0] call roundTo ] } else { format['%1m', [_dist, 0] call roundTo ]};
				(format['%1/%2 [%3]',_currentCheckpoint, _totalCheckpoints, _dist]) 
			};

			drawIcon3D [_icon,[255,255,255,_alpha],_pos,_size * 1.03,_size * 1.03,0, _index,0, _fontSize, "PuristaMedium"];			
			drawIcon3D [markerBoxIcon,[255,255,255,_alpha],_pos,_size,_size,0, '',0, 0.03, "PuristaMedium"];		

		};

	} foreach _arr;	  

	false

} count [
	[GW_CHECKPOINTS, false],
	[GW_CHECKPOINTS_COMPLETED, true]
];


// Locked target icons
if (count GW_LOCKEDTARGETS > 0) then {
	{
		if (!alive _x || isNull _x) then {
			GW_LOCKEDTARGETS = GW_LOCKEDTARGETS - [_x];
		} else {
			if (typename _x == "OBJECT" && {alive _x}) then {	        	
        		_pos =  (ASLtoATL visiblePositionASL _x);
        		drawIcon3D [lockedIcon,colorRed,_pos,2.25,2.25,2, 'LOCKED', 0, 0.03, "PuristaMedium"];		      
        	};

    	};
		false
	} count GW_LOCKEDTARGETS > 0;
};	   

// Target icons 
if (count GW_TARGETICON_ARRAY > 0) then {
	{
		if (!alive _x || isNull _x) then {
			GW_TARGETICON_ARRAY = GW_TARGETICON_ARRAY - [_x];
		} else {
			if (typename _x == "OBJECT" && {alive _x}) then {
				drawIcon3D [lockingIcon,[0.99,0.14,0.09,1], (_x modelToWorldVisual [0,0,0]), 2.5,2.5,0, '', 0, 0.04, "PuristaMedium"];
			};
		};

		false
	} count GW_TARGETICON_ARRAY > 0;
};	        

// Laser Effect
if (count GW_LINEFFECT_ARRAY > 0) then {
	{
		_p1 = _x select 0;
		_p2 = _x select 1;
		if (typename _p1 == "OBJECT") then { _p1 = (ASLtoATL visiblePositionASL _p1); };				
		if (typename _p2 == "OBJECT") then { _p2 = (ASLtoATL visiblePositionASL _p2); };	

		if ((_x select 2) == "LSR") then { _p1 set [2, (_p1 select 2) + 0.48]; };

		drawLine3D [_p1, _p2, GW_LINEEFFECT_COLOR];				
		false
	} count GW_LINEFFECT_ARRAY > 0;
};	

// Warning Icons on Added Objects
if (count GW_WARNINGICON_ARRAY > 0) then {
	{
		if (!alive _x || isNull _x) then {
			GW_WARNINGICON_ARRAY = GW_WARNINGICON_ARRAY - [_x];

		} else {	

			if (typename _x == "OBJECT" && { alive _x } && { _x distance GW_CURRENTVEHICLE < 300 }) then {

				// Some objects need the warning icon in a slightly different place
				_offset = switch (typeof _x) do { case "Land_New_WiredFence_5m_F": { [0,0,2.2] }; case "Land_FoodContainer_01_F": { [0,0,0.5] }; case "Land_Sacks_heap_F": { [0,0,2] }; default { [0,0,0] }; };
				_p = (_x modelToWorldVisual _offset);
				_distance = _p distance (ASLtoATL visiblePositionASL GW_CURRENTVEHICLE);
				_size = (1 - ((_distance / 300) * 0.6)) * 1.4;
				_alpha = (300 - _distance) / (300 - 50);

				if (_alpha <= 0) exitWith {};
				
				drawIcon3D [warningIcon,[0.99,0.14,0.09,_alpha], _p, _size,_size,0, '', 0, 0.04, "PuristaMedium"];
			};

		};
		false
	} count GW_WARNINGICON_ARRAY > 0;
};	

// Vehicle pad & workshop hud icons
if (!isNil "GW_CURRENTZONE") then {

	if (GW_CURRENTZONE == "workshopZone" && !GW_TIMER_ACTIVE) then {
	
		// Draw a 3D icon for the save areas and buy terminals
		{		
			_areas = _x select 1;
			if (count _areas < 0) exitWith {};

			for "_i" from 0 to (count _areas) step 1 do {
				_d = ((_areas select _i) distance player);
				if (_d <= 50) then {
					[((_areas select _i) modelToWorldVisual [0,0,(_x select 0)]), (_x select 2), [], 50] call drawServiceIcon;		
				};
			};

		} count [	
			[2.2, vehicleTerminals, saveAreaIcon],
			[1.7, buySigns, buyAreaIcon]
		] > 0;

		// Additionally draw icons for vehicles that are hidden
		{
			_isHidden = _x getVariable ['GW_HIDDEN', false];
			_distance = _x distance player;
			_opacity = [1 - (_distance/30), 0, 1] call limitToRange;

			if (_isHidden) then {
				drawIcon3D [hiddenIcon,[1,1,1,_opacity], (_x modelToWorldVisual [0,0,1]), 1.7,1.7,0, '', 0, 0.04, "PuristaMedium"];
			};
			false
		} count ((getMarkerPos "workshopZone_camera") nearEntities [["Car", "Tank"], 200]);

	};

	if (GW_CURRENTZONE != "workshopZone") then {

		// Draw a 3D icon for each service point
		{		
			_areas = _x select 1;
			if (count _areas < 0) exitWith {};

			for "_i" from 0 to (count _areas) step 1 do {				
				if (((_areas select _i) distance (vehicle player)) < 500) then {
					[((_areas select _i) modelToWorldVisual [0,0,(_x select 0)]), (_x select 2), (_x select 3), 500, (_x select 4)] call drawServiceIcon;		
				};
			};

		} count [	
			[1, reloadAreas, rearmIcon, [activeIconA, activeIconB, activeIconC], "REARM" ],
			[1, repairAreas, repairIcon, [activeIconA, activeIconB, activeIconC], "REPAIR" ],
			[1, refuelAreas, refuelIcon, [activeIconA, activeIconB, activeIconC], "REFUEL" ]
		] > 0;

		// Check we're not in range of a nitro/flame pad
		if (GW_INVEHICLE && GW_ISDRIVER) then {
			{
				if (_x distance GW_CURRENTVEHICLE < 6) exitWith {
					[_x, GW_CURRENTVEHICLE] call nitroPad;
					false
				};
				false
			} count nitroPads;

			{
				if (_x distance GW_CURRENTVEHICLE < 8) exitWith {

					[_x, GW_CURRENTVEHICLE] call flamePad;

					false
				};
				false
			} count flamePads;
		};

	};

};

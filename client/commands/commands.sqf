GW_COMMANDS_LIST = [

	[
		"help",
		{
			_commands = "";
			{
				_name = _x select 0;
				if (_name == "tp" || _name == "warp" || _name == "kill" || _name == "disable" || _name == "spawn" || _name == "fling" || _name == "grab") then {} else {
					_commands = _commands + (pvpfw_chatIntercept_commandMarker + (_name)) + ", ";
				};
			} forEach pvpfw_chatIntercept_allCommands;
			systemChat format["Available Commands: %1",_commands];
		}
	],

	[
		
		"list",
		{

			_argument = _this select 0;

			if (isNil "_argument" || _argument == '' || _argument == ' ') exitWith {				
				//[] execVM 'client\persistance\list.sqf';	
				[] spawn listVehicles;					
			};

			if (_argument == 'clear') exitWith {

				//['clear'] execVM 'client\persistance\library.sqf';			
				['clear'] spawn listFunctions;		
			};		

			_delete = ['delete', _argument] call inString;

			if (_delete) exitWith {

				//['delete',_argument] execVM 'client\persistance\library.sqf';	
				['delete', _argument] spawn listFunctions;	
				
			};

			_share = ['share', _argument] call inString;

			if (_share) exitWith {

				//['share',_argument] execVM 'client\persistance\library.sqf';	
				['share', _argument] spawn listFunctions;	
				
			};

			_add = ['add', _argument] call inString;

			if (_add) exitWith {

				//['add',_argument] execVM 'client\persistance\library.sqf';	
				['add', _argument] spawn listFunctions;	
				
			};

					
		}
	],

	[
		
		"save",
		{
			_argument = _this select 0;	

			[_argument] spawn saveVehicle;
			//[_argument] execVM 'client\persistance\save.sqf';			
		}
	],

	[
		"clear",
		{

			_pos = (ASLtoATL (getPosASL player));
			_closest = [saveAreas, _pos] call findClosest; 

			_distance = (_closest distance player);

			if (_distance > 15) exitWith {
				systemChat 'You need to be closer to use that.';
			};		

			//hint str (typeOf _argument);
			[_closest] spawn clearPad;
	
		}

	],


	[
		
		"load",
		{
			_argument = _this select 0;

			if (isNil "_argument") then {
				_argument == '';
			};			

			if ( (_argument == '' || _argument == 'last') && lastLoad == '') exitWith {
				systemChat 'You have no previous vehicles to load';
			};

			if ( (_argument == '' || _argument == 'last') && lastLoad != '') then {
				_argument = lastLoad;
			};
			//hint format['load got: %1', _argument];

			_pos = (ASLtoATL getPosASL player);
			_closest = [saveAreas, _pos] call findClosest; 

			_distance = (_closest distance player);

			if (_distance > 15) exitWith {
				systemChat 'You need to be closer to use that.';
			};		

			//hint str (typeOf _argument);
			[_closest, _argument] spawn requestVehicle;

	
		}
	],
	
	[
		
		"spawn",
		{

			_argument = _this select 0;

			if (GW_CURRENTZONE != 'workshopZone' && !(serverCommandAvailable "#kick")) exitWith {
				systemChat 'You cant use that here.';
			};

			_len = count toArray(_argument);
			if (_len == 0) then {
				_argument = lastSpawn;
			};

			_data = [_argument, lootArray] call getObjectData;

			if (!isNil "_data") then {

				_type = _data select 0;

				_dir = direction player;
				_relPos = [(ASLtoATL getPosASL player), 2, _dir] call BIS_fnc_relPos;
				pubVar_spawnObject = [_type, _relPos];
				publicVariableServer "pubVar_spawnObject"; 	

				lastSpawn = _type;

			} else {

				systemChat format['Couldnt find %1.', _argument];
			};		
		}
	],


	[
		
		"warp",
		{

			if (serverCommandAvailable "#kick") then {			

				[] spawn
				{
					closedialog 0;
					sleep 0.5;
					TitleText [format["Click on the map to teleport."], "PLAIN DOWN"];
					openMap [true, false];
					onMapSingleClick "[_pos select 0, _pos select 1, 8] spawn {

						_pos = [_this select 0, _this select 1,_this select 2];

						(vehicle player) setpos [_pos select 0, _pos select 1, 0];				
						openMap [false, false];
						TitleText [format[''], 'PLAIN DOWN'];
						onMapSingleClick '';

					}; true";
				};
			
			};		
		}
	],


	[
		
		"grab",
		{
			_argument = _this select 0;

			if (serverCommandAvailable "#kick") then {			

				_target = [_argument] call findUnit;
				_curPos = (ASLtoATL getPosASL player);
				_curPos set [2, 1];

				if (!isNil "_target") then {
					(vehicle _target) setPosATL _curPos;	
				} else {
					systemChat 'Player not found';					
				};
			
			};		
		}
	],

	[
		
		"tp",
		{
			_argument = _this select 0;

			if (serverCommandAvailable "#kick") then {			

				_target = [_argument] call findUnit;

				if (!isNil "_target") then {
					_pos =  (ASLtoATL getPosASL (vehicle _target));
					_pos set[2,1];
					player setPos _pos;
				} else {
					systemChat 'Player not found';					
				};
			
			};		
		}
	],

	[
		
		"kill",
		{
			_argument = _this select 0;

			if (serverCommandAvailable "#kick") then {			

				_target = [_argument] call findUnit;

				if (!isNil "_target") then {
					_pos = ASLtoATL getPosASL (vehicle _target);
					_bomb = createVehicle ["Bo_GBU12_LGB", _pos, [], 0, "CAN_COLLIDE"];						
					_target setDammage 1;

				} else {
					systemChat 'Player not found';
				};
			};		
		}
	],

	[
		
		"setname",
		{
			_argument = _this select 0;

			if ( !(player == (vehicle player)) ) then { 

				(vehicle player) setVariable["name", _argument, true];
				systemChat format["Vehicle renamed to: %1",_argument];

			} else {

				systemChat "No vehicle to rename!";
			};
		}
	],
	[
		
		"setcamo",
		{
			_argument = _this select 0;

			if ( player == (vehicle player) ) exitWith { 

				systemChat "You need to be in a vehicle to use this.";
			};

			_isOwner = [(vehicle player), player, false] call checkOwner;

			if (!_isOwner) exitWith { 

				systemChat "You need to be the owner of the vehicle to use this.";
			};

			if (_argument == "") exitWith {

				_camoString = '';

				{
					_str = format['%1 ', _x select 0];
					_camoString = _camoString + _str;


				} ForEach camoList;

				systemChat format['Available camos: %1', _camoString];

			}; 

			{

				_name = _x select 0;

				if (_argument == _name) exitWith {

					_name = _x select 0;
					_path = _x select 1;
					_veh = (vehicle player);

					// pubVar_setObjectTexture = [_veh, _path];
				 //    publicVariable "pubVar_setObjectTexture"; 

					[		
						[
							_veh,
							_path
						],
						"setObjectTextureMP",
						false,
						false 
					] call BIS_fnc_MP;

				    _veh setVariable ["camo", _path]; 

				    // _path = format["%1%2", MISSION_ROOT, _path];
				    // _veh setObjectTexture [0, _path];

					systemChat format['Set vehicle camo to: %1 ', _name];

				};

			} ForEach camoList;
			
		}
	],

	[
		
		"stuck",
		{

			_vehicle = (vehicle player);

			if ( player == _vehicle ) exitWith { 
				systemChat "You need to be in a vehicle to use this.";
			};

			[_vehicle] spawn flipVehicle;
			
		}
	]
];        
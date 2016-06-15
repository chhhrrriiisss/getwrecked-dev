// Includes
#include "\A3\ui_f\hpp\defineResincl.inc"

// Macros
#define CHECK(CONDITION) \
	if (CONDITION) exitWith {};

// Defines
#define SELF					{ _this call (missionNamespace getVariable ["dynamicGroups", {}]); }
#define DISPLAY					{ _this call (uiNamespace getVariable ["RscDisplayDynamicGroups_script", {}]); }

#define UI_OPEN_KEY				"TeamSwitch"

#define DEFAULT_INSIGNIA			"BI"

#define HOLD_DOWN_TIME_FOR_INVITE_ACCEPT	0.7

#define INTERFACE_UPDATE_DELAY			0.4

#define INVITE_LIFETIME				60

#define IS_PUBLIC				true
#define IS_LOCAL				false

#define LOG_ENABLED				true

#define VAR_INITIALIZED				"BIS_dg_ini"
#define VAR_GROUP_REGISTERED			"BIS_dg_reg"
#define VAR_GROUP_CREATOR			"BIS_dg_cre"
#define VAR_GROUP_INSIGNIA			"BIS_dg_ins"
#define VAR_GROUP_PRIVATE			"BIS_dg_pri"

#define VAR_KICKED_BY				"BIS_dg_kic"
#define VAR_INVITES				"BIS_dg_inv"

#define VAR_ON_CLIENT_MESSAGE			"dynamicGroups_clientMessage"
#define VAR_PLAYER_DRAW3D			"dynamicGroups_draw3D"
#define VAR_LAST_UPDATE_TIME			"dynamicGroups_lastUpdateTime"
#define VAR_PLAYER_RESPAWN_KEYDOWN		"dynamicGroups_respawnKeyDown"

#define VAR_UI_DISPLAY				"dynamicGroups_display"

private ["_mode", "_params"];
_mode   = [_this, 0, "", [""]] call BIS_fnc_param;
_params = [_this, 1, [], [[]]] call BIS_fnc_param;

switch (_mode) do
{
	/**
	 * Initializes the dynamic groups system
	 * Runs only on the server
	 *
	 * @param Whether or not to register all groups led by a player at mission start
	 */
	case "Initialize" :
	{
		CHECK(!isServer)

		private ["_registerInitialPlayerGroups"];
		_registerInitialPlayerGroups = [_params, 0, false, [true]] call BIS_fnc_param;

		// Center of each side
		{ createCenter _x } forEach [WEST, EAST, RESISTANCE, CIVILIAN];

		// Block multiple execution
		if (["IsInitialized"] call SELF) exitWith
		{
			"Dynamic groups was already initialized, terminate in order to be able to re-initialize" call BIS_fnc_error;
		};

		// Handle requests from clients
		VAR_ON_CLIENT_MESSAGE addPublicVariableEventHandler [missionnamespace,
		{
			["OnClientMessage", _this] call SELF;
		}];

		// Initialized flag
		missionNamespace setVariable [VAR_INITIALIZED, true, IS_PUBLIC];

		// Initialize initial player groups
		if (_registerInitialPlayerGroups) then
		{
			["RegisterInitialPlayerGroups", []] call SELF;
		};

		// Log
		if (LOG_ENABLED) then
		{
			"Initialized" call BIS_fnc_log;
		};
	};

	/**
	 * Terminates the dynamic groups system, and deletes all current data
	 * Runs only on the server
	 */
	case "Terminate" :
	{
		CHECK(!isServer)

		// Clear client message event handler
		VAR_ON_CLIENT_MESSAGE addPublicVariableEventHandler [missionnamespace, {}];

		// Public variables
		missionNamespace setVariable [VAR_INITIALIZED, nil, IS_PUBLIC];

		// Log
		if (LOG_ENABLED) then
		{
			"Terminated" call BIS_fnc_log;
		};
	};

	/**
	 * Returns whether the dynamic groups system is initialized
	 */
	case "IsInitialized" :
	{
		missionNamespace getVariable [VAR_INITIALIZED, false];
	};

	/**
	 * Receives and handles client requests on the server
	 */
	case "OnClientMessage" :
	{
		CHECK(!isServer)

		private ["_variable", "_message"];
		_variable 	= [_params, 0, "", [""]] call BIS_fnc_param;
		_message	= [_params, 1, [], [[]]] call BIS_fnc_param;

		private ["_inMode", "_inParams", "_player"];
		_inMode 	= [_message, 0, "", [""]] call BIS_fnc_param;
		_inParams 	= [_message, 1, [], [[]]] call BIS_fnc_param;
		_player		= [_message, 2, objNull, [objNull]] call BIS_fnc_param;

		// Call requested function
		[_inMode, _inParams] call SELF;

		// Log
		if (LOG_ENABLED) then
		{
			["OnClientMessage: Message (%1) received from client (%2 / %3) with data (%4) at time (%5)", _variable, _player, name _player, _message, time] call BIS_fnc_logFormat;
		};
	};

	case "RegisterInitialPlayerGroups" :
	{
		{
			if (count units _x > 0 && isPlayer leader _x) then
			{
				["RegisterGroup", [_x, leader _x]] call SELF;
			};
		}
		forEach (allGroups - (["GetAllGroups"] call SELF));
	};

	case "RegisterGroup" :
	{
		CHECK(!isServer)

		private ["_group", "_leader"];
		_group	= [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_leader	= [_params, 1, objNull, [objNull]] call BIS_fnc_param;
		_data	= [_params, 2, [], [[]]] call BIS_fnc_param;

		if (!isNull _group && !isNull _leader && _leader == leader _group) then
		{
			private ["_insignia", "_name", "_private"];
			_insignia	= [_data, 0, ["LoadRandomInsignia"] call SELF, [""]] call BIS_fnc_param;
			_name		= [_data, 1, groupId _group, [""]] call BIS_fnc_param;
			_private	= [_data, 2, false, [true]] call BIS_fnc_param;

			// Flag as registered
			_group setVariable [VAR_GROUP_REGISTERED, true, IS_PUBLIC];

			// Set the creator of this group
			_group setVariable [VAR_GROUP_CREATOR, _leader, IS_PUBLIC];

			// Set random insignia
			_group setVariable [VAR_GROUP_INSIGNIA, _insignia, IS_PUBLIC];

			// Set lock status, unlocked by default
			_group setVariable [VAR_GROUP_PRIVATE, _private, IS_PUBLIC];

			// Set the default name of the group
			_group setGroupIdGlobal [_name];

			// Set insignia for all members of the group
			{
				["OnPlayerGroupChanged", [_x, _group]] call SELF;
			} forEach units _group;

			if (LOG_ENABLED) then
			{
				["RegisterGroup: Group (%1) registered with leader (%2)", _group, _leader] call BIS_fnc_logFormat;
			};
		};
	};

	case "UnregisterGroup" :
	{
		private ["_group", "_keep"];
		_group 	= [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_keep	= [_params, 1, false, [false]] call BIS_fnc_param;

		if (!isNull _group && { ["IsGroupRegistered", [_group]] call SELF }) then
		{
			if (_keep || count units _group > 0) then
			{
				_group setVariable [VAR_GROUP_REGISTERED, nil, IS_PUBLIC];
				_group setVariable [VAR_GROUP_CREATOR, nil, IS_PUBLIC];
				_group setVariable [VAR_GROUP_INSIGNIA, nil, IS_PUBLIC];
				_group setVariable [VAR_GROUP_PRIVATE, nil, IS_PUBLIC];
			}
			else
			{
				["DeleteGroup", [_group]] call SELF;
			};

			if (LOG_ENABLED) then
			{
				["UnregisterGroup: Group (%1) unregistered and deleted (%2)", _group, _keep] call BIS_fnc_logFormat;
			};
		};
	};

	case "IsGroupRegistered" :
	{
		private ["_group"];
		_group = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;

		_group getVariable [VAR_GROUP_REGISTERED, false];
	};

	case "DeleteGroup" :
	{
		private ["_group"];
		_group = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;

		if (local _group) then
		{
			["DeleteGroupLocal", [_group]] call SELF;
		}
		else
		{
			//["DeleteGroupLocal", [_group]] remoteExecCall ["dynamicGroups", groupOwner _group];
			[["DeleteGroupLocal", [_group]], "dynamicGroups", groupOwner _group] call BIS_fnc_mp;
		};
	};

	case "DeleteGroupLocal" :
	{
		private ["_group"];
		_group = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;

		if (!isNull _group && { local _group }) then
		{
			deleteGroup _group;
		};
	};

	case "SetName" :
	{
		CHECK(!isServer)

		private ["_group", "_name"];
		_group  = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_name 	= [_params, 1, "", [""]] call BIS_fnc_param;

		if (!isNull _group && _name != "") then
		{
			_group setGroupIdGlobal [_name];
		};
	};

	case "SetPrivateState" :
	{
		CHECK(!isServer)

		private ["_group", "_state"];
		_group  = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_state 	= [_params, 1, true, [true]] call BIS_fnc_param;

		if (!isNull _group) then
		{
			_group setVariable [VAR_GROUP_PRIVATE, _state, IS_PUBLIC];
		};
	};

	case "CreateGroupAndRegister" :
	{
		CHECK(!isServer)

		private ["_player"];
		_player = [_params, 0, objNull, [objNull]] call BIS_fnc_param;

		if (!isNull _player) then
		{
			// Create the new group in which we will put player
			private "_newGroup";
			_newGroup = createGroup (side group _player);

			// Join player to new group
			[_player] joinSilent _newGroup;

			// Register
			["RegisterGroup", [_newGroup, _player]] call SELF;

			// Log
			if (LOG_ENABLED) then
			{
				["CreateNewGroupFor: %1 / %2 / %3 / %4 / %5", _newGroup, _player, units _newGroup, leader _newGroup, _group] call BIS_fnc_logFormat;
			};
		};
	};

	case "SwitchLeader" :
	{
		CHECK(!isServer)

		private ["_group", "_player"];
		_group  = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_player = [_params, 1, objNull, [objNull]] call BIS_fnc_param;

		if (!isNull _group && !isNull _player && _group == group _player) then
		{
			private ["_oldInsignia", "_oldName", "_oldPrivateState"];
			_oldInsignia 		= _group getVariable [VAR_GROUP_INSIGNIA, ["LoadRandomInsignia"] call SELF];
			_oldName 		= groupId _newGroup;
			_oldPrivateState 	= _group getVariable [VAR_GROUP_PRIVATE, false];

			private ["_newGroup", "_units"];
			_newGroup 	= createGroup side _group;
			_units 		= units _group - [_player];
			_units 		= [_player] + _units;

			_units joinSilent _newGroup;
			_newGroup selectLeader _player;

			// Register new group
			["RegisterGroup", [_newGroup, _player, [_oldInsignia, _oldName, _oldPrivateState]]] call SELF;

			// Delete old group
			["DeleteGroup", [_group]] call SELF;

			// Log
			if (LOG_ENABLED) then
			{
				["SwitchLeader: %1 / %2 / %3 / %4 / %5", _newGroup, _player, units _newGroup, leader _newGroup, _group] call BIS_fnc_logFormat;
			};
		};
	};

	case "AddGroupMember" :
	{
		CHECK(!isServer)

		private ["_group", "_player"];
		_group  = [_params, 0, grpNull, [grpNull]] call bis_fnc_param;
		_player = [_params, 1, objNull, [objNull]] call bis_fnc_param;

		if (!isNull _player && !isNull _group && group _player != _group) then
		{
			private ["_oldGroup", "_units"];
			_oldGroup 	= group _player;
			_units		= units _oldGroup - [_player];

			// Join player to new group
			[_player] joinSilent _group;

			// Trigger event
			["OnPlayerGroupChanged", [_player, _group]] call SELF;

			// Delete old group
			if (count _units < 1) then
			{
				["DeleteGroup", [_oldGroup]] call SELF;
			};
		};
	};

	case "RemoveGroupMember" :
	{
		CHECK(!isServer)

		private ["_group", "_player"];
		_group  = [_params, 0, grpNull, [grpNull]] call bis_fnc_param;
		_player = [_params, 1, objNull, [objNull]] call bis_fnc_param;

		if (!isNull _player && !isNull _group && group _player == _group) then
		{
			private ["_units"];
			_units = units _group - [_player];

			// Join player to his own group
			[_player] joinSilent grpNull;

			// Trigger event
			["OnPlayerGroupChanged", [_player, group _player]] call SELF;

			// Delete registered group
			if (count _units < 1) then
			{
				["DeleteGroup", [_group]] call SELF;
			};
		};
	};

	/**
	 * Switches a player from a group to another
	 */
	case "SwitchGroup" :
	{
		CHECK(!isServer)

		private ["_group", "_player"];
		_group  = [_params, 0, grpNull, [grpNull]] call bis_fnc_param;
		_player = [_params, 1, objNull, [objNull]] call bis_fnc_param;

		if (!isNull _player && !isNull _group && group _player != _group) then
		{
			private ["_oldGroup", "_units"];
			_oldGroup 	= group _player;
			_units		= units _oldGroup - [_player];

			// Join player to new group
			[_player] joinSilent _group;

			// Trigger event
			["OnPlayerGroupChanged", [_player, _group]] call SELF;

			if (count _units < 1) then
			{
				["DeleteGroup", [_oldGroup]] call SELF;
			};
		};
	};

	/**
	 * Kicks a player out of a group
	 */
	case "KickPlayer" :
	{
		CHECK(!isServer)

		private ["_group", "_leader", "_player"];
		_group    = [_params, 0, grpNull, [grpNull]] call bis_fnc_param;
		_leader   = [_params, 1, objNull, [objNull]] call bis_fnc_param;
		_player   = [_params, 2, objNull, [objNull]] call bis_fnc_param;

		if (!isNull _group && !isNull _leader && !isNull _player && leader group _leader == _leader && group _player == _group) then
		{
			// Make player leave group
			["RemoveGroupMember", [_group, _player]] call SELF;

			// The current list of group kicks this player has
			private "_kicks";
			_kicks = _player getVariable [VAR_KICKED_BY, []];

			// Add new id
			_kicks pushBack _group;

			// Store this event, we want to be able to see if player was kicked out of a group
			_player setVariable [VAR_KICKED_BY, _kicks, IS_PUBLIC];
		};
	};

	/**
	 * Un-kicks a player from a group
	 */
	case "UnKickPlayer" :
	{
		CHECK(!isServer)

		private ["_groupId", "_player"];
		_group  = [_params, 0, grpNull, [grpNull]] call bis_fnc_param;
		_player = [_params, 1, objNull, [objNull]] call bis_fnc_param;

		if (!isNull _group && !isNull _player && ["WasPlayerKickedFrom", [_group, _player]] call SELF) then
		{
			// The current list of group kicks this player has
			private "_kicksOld";
			_kicksOld = _player getVariable [VAR_KICKED_BY, []];

			// Remove given id from list if it exists
			private "_kicks";
			_kicks = _kicksOld - [_group];

			// Store this event, we want to be able to see if player was kicked out of a group
			if !(_kicksOld isEqualTo _kicks) then
			{
				_player setVariable [VAR_KICKED_BY, _kicks, IS_PUBLIC];
			};
		};
	};

	case "WasPlayerKickedFrom" :
	{
		private ["_group", "_player"];
		_group  = [_params, 0, grpNull, [grpNull]] call bis_fnc_param;
		_player = [_params, 1, objNull, [objNull]] call bis_fnc_param;

		_group in (_player getVariable [VAR_KICKED_BY, []]);
	};

	/**
	 * Returns all abstract groups
	 */
	case "GetAllGroups" :
	{
		private "_groups";
		_groups = [];

		{
			if (["IsGroupRegistered", [_x]] call SELF && count units _x > 0 && isPlayer leader _x) then
			{
				_groups pushBack _x;
			};
		} forEach allGroups;

		_groups;
	};

	/**
	 * Returns all abstract groups belonging to a side
	 */
	case "GetAllGroupsOfSide" :
	{
		private ["_side"];
		_side = [_params, 0, sideUnknown, [sideUnknown]] call bis_fnc_param;

		private "_groups";
		_groups = [];

		{
			if (side _x == _side) then
			{
				_groups pushBack _x;
			};
		} forEach (["GetAllGroups"] call SELF);

		_groups;
	};

	/**
	 * Returns group with given name
	 */
	case "GetGroupByName" :
	{
		private ["_name", "_side"];
		_name = [_params, 0, "", [""]] call bis_fnc_param;
		_side = [_params, 1, sideUnknown, [sideUnknown]] call bis_fnc_param;

		private ["_groups", "_group"];
		_groups = ["GetAllGroups"] call SELF;
		_group  = grpNull;

		{
			if (_name == groupId _x && side _x == _side) then
			{
				_group = _x;
			};
		} forEach allGroups;

		_group;
	};

	/**
	 * Gets the list of all friendly players
	 */
	case "GetFriendlyPlayers" :
	{
		private ["_side"];
		_side = [_params, 0, SIDEUNKNOWN, [SIDEUNKNOWN]] call BIS_fnc_param;

		// Validate params
		if !(_side in [WEST, EAST, RESISTANCE, CIVILIAN]) exitWith
		{
			["GetFriendlyPlayers: Invalid side (%1), please use on of the supported (WEST, EAST, RESISTANCE, CIVILIAN)"] call BIS_fnc_error;
			[];
		};

		private "_friendlies";
		_friendlies = [];

		{
			if (side group _x == _side && isPlayer _x) then
			{
				_friendlies pushBack _x;
			};
		} forEach allUnits + allDead;

		_friendlies;
	};

	/**
	 * Return whether a player has group
	 */
	case "PlayerHasGroup" :
	{
		private ["_player"];
		_player = [_params, 0, objNull, [objNull]] call BIS_fnc_param;

		["IsGroupRegistered", [group _player]] call SELF;
	};

	/**
	 * Return whether a player is leader of group
	 */
	case "PlayerIsLeader" :
	{
		private ["_player"];
		_player = [_params, 0, objNull, [objNull]] call BIS_fnc_param;

		_player == leader group _player && ["PlayerHasGroup", [_player]] call SELF;
	};

	/**
	 * Initializes a player
	 * Can only be run on machines which have a player
	 */
	case "InitializePlayer" :
	{
		CHECK(!hasInterface)

		private ["_player", "_registerInitialGroup"];
		_player 		= [_params, 0, player, [objNull]] call BIS_fnc_param;
		_registerInitialGroup 	= [_params, 1, false, [true]] call BIS_fnc_param;

		if (!local _player) exitWith
		{
			["InitializePlayer: Player (%1) is not local", _player] call BIS_fnc_error;
		};

		if (!isNil { _player getVariable VAR_INITIALIZED }) exitWith
		{
			["InitializePlayer: Player (%1) already initialized, terminate to be able to re-initialize", _player] call BIS_fnc_error;
		};

		// Flag as initialized
		_player setVariable [VAR_INITIALIZED, true, IS_PUBLIC];

		// Add key events for opening the Dynamic Groups interface and for invitation handling
		["AddKeyEvents"] call SELF;

		// When in the respawn screen, detect when we want to open dynamic groups
		missionNamespace setVariable [VAR_PLAYER_RESPAWN_KEYDOWN,
		[
			missionnamespace,
			"RscDisplayRespawnKeyDown",
			{
				private "_key";
				_key = [_this, 1, -1, [0]] call BIS_fnc_param;

				if (_key in actionKeys UI_OPEN_KEY) then
				{
					(_this select 0) createDisplay "RscDisplayDynamicGroups";
				};
			}
		] call bis_fnc_addscriptedeventhandler, IS_LOCAL];

		// The updating function
		missionNamespace setVariable [VAR_PLAYER_DRAW3D, addMissionEventHandler ["Draw3D",
		{
			private ["_timeLastUpdate", "_timeNow", "_timeSinceLastUpdate"];
			_timeLastUpdate         = missionNamespace getVariable [VAR_LAST_UPDATE_TIME, 0];
			_timeNow                = time;
			_timeSinceLastUpdate    = _timeNow - _timeLastUpdate;

			if (_timeSinceLastUpdate >= INTERFACE_UPDATE_DELAY) then
			{
				// Update
				["UpdateInterface"] call SELF;

				// Store current time
				missionNamespace setVariable [VAR_LAST_UPDATE_TIME, _timeNow, IS_LOCAL];
			};
		}], IS_LOCAL];

		// Register player group if requested, not already registered and player is leader
		if (!(["IsGroupRegistered", [group _player]] call SELF) && leader group _player == _player && _registerInitialGroup) then
		{
			["SendClientMessage", ["RegisterGroup", [group _player, _player]]] call SELF;
		};
	};

	/**
	 * Un-initializes player
	 * Can only be run on machines which have a player
	 */
	case "TerminatePlayer" :
	{
		CHECK(!hasInterface)

		private ["_player"];
		_player = [_params, 0, player, [objNull]] call BIS_fnc_param;

		if (!local _player) exitWith
		{
			["TerminatePlayer: Player (%1) is not local", _player] call BIS_fnc_error;
		};

		if (isNil { _player getVariable VAR_INITIALIZED }) exitWith
		{
			["TerminatePlayer: Player (%1) is not initialized yet", _player] call BIS_fnc_error;
		};

		// Remove key events for opening the Dynamic Groups interface and for invitation handling
		["RemoveKeyEvents"] call SELF;

		// Remove respawn screen key down event handling
		(missionNamespace getVariable [VAR_PLAYER_RESPAWN_KEYDOWN, []]) call bis_fnc_removescriptedeventhandler;

		// Stop the updating function
		removeMissionEventHandler ["Draw3D", missionnamespace getVariable [VAR_PLAYER_DRAW3D, -1]];
	};

	/**
	 * Sends a message to server from a client machine
	 */
	case "SendClientMessage" :
	{
		CHECK(!hasInterface)

		private ["_inMode", "_inParams"];
		_inMode         = [_params, 0, "", [""]] call BIS_fnc_param;
		_inParams       = [_params, 1, [], [[]]] call BIS_fnc_param;

		// If we are on the server, we execute directly otherwise we send to the server to be executed
		if (isServer) then
		{
			[_inMode, _inParams] call SELF;
		}
		else
		{
			missionNamespace setVariable [VAR_ON_CLIENT_MESSAGE, [_inMode, _inParams, player], IS_PUBLIC];
		};
	};

	/**
	 * Is called every time a change is done from the server
	 */
	case "UpdateInterface" :
	{
		disableSerialization;
		CHECK(!hasInterface)

		with uiNamespace do
		{
			private "_display";
			_display = uiNamespace getVariable [VAR_UI_DISPLAY, displayNull];

			if (!isNull _display) then
			{
				["Update", [false]] call DISPLAY;
			};
		};
	};

	/**
	 * Adds key down/up events for opening interface or invitation interaction
	 */
	case "AddKeyEvents" :
	{
		disableSerialization;
		CHECK(!hasInterface)

		private ["_display"];
		_display = [_params, 0, displayNull, [displayNull]] call BIS_fnc_param;

		[_display] spawn
		{
			scriptName "DynamicGroups: AddKeyEvents";
			disableSerialization;

			with UiNamespace do
			{
				private ["_display", "_varName"];
				_display = _this select 0;
				_varName = "BIS_dynamicGroups_keyMain";

				// Wait for display to become available
				if (isNull _display) then
				{
					waitUntil{ !isNull (findDisplay 46) };

					_display = (findDisplay 46);
					_varName = "BIS_dynamicGroups_key";
				};

				// Exit in case event is already registered
				if (!isNil { uiNamespace getVariable _varName }) then
				{
					private ["_index", "_down", "_up"];
					_index = uiNamespace getVariable _varName;
					_down = _index select 0;
					_up = _index select 1;

					// Reset event handlers
					_display displayRemoveEventHandler ["KeyDown", _down];
					_display displayRemoveEventHandler ["KeyUp", _up];
					uiNamespace setVariable [_varName, nil];
				};

				// Add event handlers to display
				private ["_down", "_up"];
				_down   = _display displayAddEventHandler ["KeyDown", "with uiNamespace do { ['OnKeyDown', _this] call dynamicGroups; };"];
				_up     = _display displayAddEventHandler ["KeyUp", "with uiNamespace do { ['OnKeyUp', _this] call dynamicGroups; };"];

				// Store in ui namespace
				uiNamespace setVariable [_varName, [_down, _up]];

				// Log
				if (LOG_ENABLED) then
				{
					["AddKeyEvents: Key down event added for (%1)", _varName] call BIS_fnc_logFormat;
				};
			};
		};
	};

	/**
	 * Removes input event handling
	 */
	case "RemoveKeyEvents" :
	{
		disableSerialization;
		CHECK(!hasInterface)

		private ["_display"];
		_display = [_params, 0, displayNull, [displayNull]] call BIS_fnc_param;

		[_display] spawn
		{
			scriptName "DynamicGroups: RemoveKeyEvents";
			disableSerialization;

			with UiNamespace do
			{
				private ["_display", "_varName"];
				_display = _this select 0;
				_varName = "BIS_dynamicGroups_keyMain";

				// Wait for display to become available
				if (isNull _display) then
				{
					waitUntil{ !isNull (findDisplay 46) };

					_display = (findDisplay 46);
					_varName = "BIS_dynamicGroups_key";
				};

				// Exit in case event is already registered
				if (!isNil { uiNamespace getVariable _varName }) then
				{
					private ["_index", "_down", "_up"];
					_index = uiNamespace getVariable _varName;
					_down = _index select 0;
					_up = _index select 1;

					// Reset event handlers
					_display displayRemoveEventHandler ["KeyDown", _down];
					_display displayRemoveEventHandler ["KeyUp", _up];
					uiNamespace setVariable [_varName, nil];
				};

				// Log
				if (LOG_ENABLED) then
				{
					["RemoveKeyEvents: Key down event removed for (%1)", _varName] call BIS_fnc_logFormat;
				};
			};
		};
	};

	/**
	 * Handles a key down event
	 */
	case "OnKeyDown" :
	{
		disableSerialization;
		CHECK(!hasInterface)

		private ["_key", "_ctrl"];
		_key  = [_params, 1, -1, [0]] call BIS_fnc_param;
		_ctrl = [_params, 3, false, [false]] call BIS_fnc_param;

		if (_key in actionKeys UI_OPEN_KEY && !_ctrl) then
		{
			if (isNil { uiNamespace getVariable "BIS_dynamicGroups_keyDownTime" }) then
			{
				uiNamespace setVariable ["BIS_dynamicGroups_keyDownTime", time];
				uiNamespace setVariable ["BIS_dynamicGroups_ignoreInterfaceOpening", nil];
			};

			["UpdateKeyDown"] call SELF;
			true;
		}
		else
		{
			false;
		};
	};

	/**
	 * Handles a key up event
	 */
	case "OnKeyUp" :
	{
		disableSerialization;
		CHECK(!hasInterface)

		private ["_key", "_ctrl"];
		_key  = [_params, 1, -1, [0]] call BIS_fnc_param;
		_ctrl = [_params, 3, false, [false]] call BIS_fnc_param;

		uiNamespace setVariable ["BIS_dynamicGroups_keyDownTime", nil];

		if (_key in actionKeys UI_OPEN_KEY && !_ctrl && isNil { uiNamespace getVariable "BIS_dynamicGroups_ignoreInterfaceOpening" }) then
		{
			if (isNull (findDisplay 60490)) then
			{
				([] call BIS_fnc_displayMission) createDisplay "RscDisplayDynamicGroups";
			}
			else
			{
				if (isNil { uiNamespace getVariable "BIS_dynamicGroups_hasFocus" }) then
				{
					(["GetDisplay"] call DISPLAY) closeDisplay IDC_CANCEL;
				};
			};

			true;
		}
		else
		{
			false;
		};
	};

	/**
	 *
	 */
	case "UpdateKeyDown" :
	{
		CHECK(!hasInterface)

		if (!isNil { uiNamespace getVariable "BIS_dynamicGroups_keyDownTime" } && count (["GetPlayerInvites", [player]] call SELF) > 0) then
		{
			private ["_timestamp", "_timeHolding"];
			_timestamp      = uiNamespace getVariable "BIS_dynamicGroups_keyDownTime";
			_timeHolding    = time - _timestamp;

			if (_timeHolding >= HOLD_DOWN_TIME_FOR_INVITE_ACCEPT) then
			{
				with missionNamespace do
				{
					private "_invites";
					_invites = ["GetPlayerInvites", [player]] call SELF;

					if (count _invites > 0) then
					{
						private "_invite";
						_invite = _invites select (count _invites - 1);

						if !(["PlayerHasGroup", [player]] call SELF) then
						{
							["SendClientMessage", ["AddGroupMember", [_invite select 0, player]]] call SELF;
						}
						else
						{
							["SendClientMessage", ["SwitchGroup", [_invite select 0, player]]] call SELF;
						};

						// Remove invite
						["RemoveInvite", [_invite select 0, player]] call SELF;

						// Do not allow opening interface
						uiNamespace setVariable ["BIS_dynamicGroups_ignoreInterfaceOpening", true];

						// Notification
						["LocalShowNotification", ["DynamicGroups_Joined", [groupId (_invite select 0)]]] call SELF;

						// Log
						if (LOG_ENABLED) then
						{
							["UpdateKeyDown: Invite accepted from %1", _invite select 0] call BIS_fnc_logFormat;
						};
					};
				};
			};

			//hintSilent format ["Holding key down for %1 seconds", _timeHolding];
		};
	};

	/**
	 * Adds a invitation/request to a player
	 * Invitations are stored within unique player
	 */
	case "AddInvite" :
	{
		private ["_group", "_from", "_to"];
		_group	= [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_from	= [_params, 1, objNull, [objNull]] call BIS_fnc_param;
		_to	= [_params, 2, objNull, [objNull]] call BIS_fnc_param;

		// Validate params
		if (isNull _group) exitWith { "AddInvite: Group is null" call BIS_fnc_error; };
		if (isNull _from) exitWith { "AddInvite: Invite sender is null" call BIS_fnc_error; };
		if (isNull _to) exitWith { "AddInvite: Invite receiver is null" call BIS_fnc_error; };

		// Get current invites and requests
		private "_invitations";
		_invitations = _to getVariable [VAR_INVITES, []];

		// The index if group already in list
		private "_index";
		_index = -1;

		{
			if (_x select 0 == _group) exitWith
			{
				_index = _forEachIndex;
			};
		} forEach _invitations;

		// Store new info
		if (_index != -1) then
		{
			_invitations set [_index, [_group, _from, _to, time]];
		}
		else
		{
			_invitations pushBack [_group, _from, _to, time];
		};

		// Broadcast changes
		_to setVariable [VAR_INVITES, _invitations, IS_PUBLIC];

		// Fire event on target computer
		//["OnInvitationReceived", [_group, _to, _from]] remoteExecCall ["dynamicGroups", _to];
		[["OnInvitationReceived", [_group, _to, _from]], "dynamicGroups", _to] call BIS_fnc_mp;

		// If player was kicked from group we unkick since he was invited
		//["UnKickPlayer", [_group, _to]] remoteExecCall ["dynamicGroups", 2];
		[["UnKickPlayer", [_group, _to]], "dynamicGroups", false] call BIS_fnc_mp;

		// Log
		if (LOG_ENABLED) then
		{
			["AddInvite: %1 / %2 / %3", _group, _from, _to] call BIS_fnc_logFormat;
		};
	};

	/**
	 * Remove an invite from a player
	 */
	case "RemoveInvite" : {
		private ["_group", "_player"];
		_group	= [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_player	= [_params, 1, objNull, [objNull]] call BIS_fnc_param;

		if (isNull _group) exitWith { "RemoveInvite: Group is null" call BIS_fnc_error; };
		if (isNull _player) exitWith { "RemoveInvite: Invite holder is null" call BIS_fnc_error; };

		// Get current invites and requests
		private ["_invitations", "_container"];
		_invitations    = _player getVariable [VAR_INVITES, []];
		_container      = [] + _invitations;

		// Go through the container, find matching group id, get index within container and delete it
		private "_index";
		_index = -1;

		{
			if (_group == _x select 0 && _player == _x select 2) exitWith
			{
				_index = _forEachIndex;
			};
		} forEach _container;

		if (_index < 0) exitWith
		{
			["RemoveInvite: Not found for group (%1)", _group] call BIS_fnc_error;
		};

		_container deleteAt _index;
		_player setVariable [VAR_INVITES, _container, IS_PUBLIC];

		// Log
		if (LOG_ENABLED) then
		{
			["RemoveInvite: %1", _this] call BIS_fnc_logFormat;
		};
	};

	/**
	 * Whether player has an invite from a private group
	 */
	case "HasInvite" :
	{
		private ["_group", "_player"];
		_group	= [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_player	= [_params, 1, objNull, [objNull]] call BIS_fnc_param;

		private ["_invitations", "_hasInvitation"];
		_invitations = _player getVariable [VAR_INVITES, []];
		_hasInvitation = false;

		{
			private ["_inviteGroup", "_inviteFrom", "_inviteTo", "_inviteTime"];
			_inviteGroup 	= _x select 0;
			_inviteFrom 	= _x select 1;
			_inviteTo 	= _x select 2;
			_inviteTime 	= _x select 3;

			if (_group == _inviteGroup && _player == _inviteTo && time <= _inviteTime + INVITE_LIFETIME) exitWith
			{
				_hasInvitation = true;
			};
		} forEach _invitations;

		_hasInvitation;
	};

	/**
	 * Returns all invites player has received
	 **/
	case "GetPlayerInvites" :
	{
		private ["_player", "_maxLifeTime"];
		_player         = [_params, 0, objNull, [objNull]] call BIS_fnc_param;
		_maxLifeTime    = [_params, 1, 99999999, [0]] call BIS_fnc_param;

		private ["_invites", "_validInvites"];
		_invites        = _player getVariable [VAR_INVITES, []];
		_validInvites   = [];

		{
			if (!isNull (_x select 0) && time - (_x select 3) < _maxLifeTime) then
			{
				_validInvites pushBack _x;
			};
		} forEach _invites;

		_validInvites;
	};

	/**
	 * Event for player joining a group
	 */
	case "OnGroupJoin" :
	{
		private ["_group", "_leader", "_who"];
		_group  = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_leader = [_params, 1, objNull, [objNull]] call BIS_fnc_param;
		_who    = [_params, 2, objNull, [objNull]] call BIS_fnc_param;

		if (!isNull _leader && !isNull _who && { _leader != _who }) then
		{
			// Show notification
			//["LocalShowNotification", ["DynamicGroups_PlayerJoined", [name _who], _leader]] remoteExecCall ["dynamicGroups", _leader];
			[["LocalShowNotification", ["DynamicGroups_PlayerJoined", [name _who], _leader]], "dynamicGroups", _leader] call BIS_fnc_mp;
		};
	};

	/**
	 * Event for player leaving a group
	 */
	case "OnGroupLeave" :
	{
		private ["_group", "_leader", "_who"];
		_group  = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_leader = [_params, 1, objNull, [objNull]] call BIS_fnc_param;
		_who    = [_params, 2, objNull, [objNull]] call BIS_fnc_param;

		if (!isNull _leader && !isNull _who && { _leader != _who }) then
		{
			//["LocalShowNotification", ["DynamicGroups_PlayerLeft", [name _who], _leader]] remoteExecCall ["dynamicGroups", _leader];
			[["LocalShowNotification", ["DynamicGroups_PlayerLeft", [name _who], _leader]], "dynamicGroups", _leader] call BIS_fnc_mp;
		};
	};

	/**
	 * Event for invitation received
	 */
	case "OnInvitationReceived" :
	{
		CHECK(!hasInterface)

		private ["_group", "_to", "_from"];
		_group  = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_to     = [_params, 1, objNull, [objNull]] call BIS_fnc_param;
		_from   = [_params, 2, objNull, [objNull]] call BIS_fnc_param;

		CHECK(player != _to)

		if (!isNull _to && !isNull _from && { _to != _from }) then
		{
			["LocalShowNotification", ["DynamicGroups_InviteReceived", [name _from], _to]] call SELF;
		};

		// Log
		if (LOG_ENABLED) then
		{
			["OnInvitationReceived: %1 / %2 / %3", _group, _to, _from] call bis_fnc_logFormat;
		};
	};

	/**
	 * Event for player being promoted to leader
	 */
	case "OnPromotedToLeader" :
	{
		private ["_group", "_newLeader", "_oldLeader"];
		_group          = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_newLeader      = [_params, 1, objNull, [objNull]] call BIS_fnc_param;
		_oldLeader      = [_params, 2, objNull, [objNull]] call BIS_fnc_param;

		if (!isNull _oldLeader && !isNull _newLeader && { _oldLeader != _newLeader }) then
		{
			//["LocalShowNotification", ["DynamicGroups_PromotedToLeader", [name _oldLeader], _newLeader]] remoteExecCall ["dynamicGroups", _newLeader];
			[["LocalShowNotification", ["DynamicGroups_PromotedToLeader", [name _oldLeader], _newLeader]], "dynamicGroups", _newLeader] call BIS_fnc_mp;
		};

		// Log
		if (LOG_ENABLED) then
		{
			["OnPromotedToLeader: %1 / %2 / %3", _group, _newLeader, _oldLeader] call BIS_fnc_logFormat;
		};
	};

	/**
	 * Event for player group being disbanded
	 */
	case "OnGroupDisbanded" :
	{
		private ["_group", "_who", "_oldLeader"];
		_group          = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_who            = [_params, 1, objNull, [objNull]] call BIS_fnc_param;
		_oldLeader      = [_params, 2, objNull, [objNull]] call BIS_fnc_param;

		if (!isNull _oldLeader && !isNull _who && { _oldLeader != _who }) then
		{
			//["LocalShowNotification", ["DynamicGroups_GroupDisbanded", [name _oldLeader], _who]] remoteExecCall ["dynamicGroups", _who];
			[["LocalShowNotification", ["DynamicGroups_GroupDisbanded", [name _oldLeader], _who]], "dynamicGroups", _who] call BIS_fnc_mp;
		};

		// Log
		if (LOG_ENABLED) then
		{
			["OnGroupDisbanded: %1 / %2 / %3", _group, _who, _oldLeader] call bis_fnc_logFormat;
		};
	};

	/**
	 * Event for player being kicked from his group
	 */
	case "OnKicked" :
	{
		private ["_group", "_who", "_oldLeader"];
		_group  = [_params, 0, grpNull, [grpNull]] call BIS_fnc_param;
		_who    = [_params, 1, objNull, [objNull]] call BIS_fnc_param;
		_leader = [_params, 2, objNull, [objNull]] call BIS_fnc_param;

		if (!isNull _leader && !isNull _who && { _who != _leader }) then
		{
			//["LocalShowNotification", ["DynamicGroups_Kicked", [name _leader], _who]] remoteExecCall ["dynamicGroups", _who];
			[["LocalShowNotification", ["DynamicGroups_Kicked", [name _leader], _who]], "dynamicGroups", _who] call BIS_fnc_mp;
		};

		// Log
		if (LOG_ENABLED) then
		{
			["OnKicked: %1 / %2 / %3", _group, _who, _leader] call bis_fnc_logFormat;
		};
	};

	case "LoadInsignias" :
	{
		(configfile >> "CfgUnitInsignia") call BIS_fnc_getCfgSubClasses;
	};

	case "LoadInsignia" :
	{
		private ["_class"];
		_class = [_params, 0, "", [""]] call BIS_fnc_param;

		private ["_cfg", "_displayName", "_texture", "_author"];
		_cfg            = configfile >> "CfgUnitInsignia" >> _class;
		_displayName    = getText (_cfg >> "displayName");
		_texture        = getText (_cfg >> "texture");
		_author         = getText (_cfg >> "author");

		[_displayName, _texture, _author];
	};

	case "LoadRandomInsignia" :
	{
		private "_insignias";
		_insignias = ["LoadInsignias"] call SELF;
		_insignias = _insignias - [DEFAULT_INSIGNIA];
		_insignias call bis_fnc_selectRandom;
	};

	case "GetInsigniaDisplayName" :
	{
		private ["_class"];
		_class = [_params, 0, "", [""]] call BIS_fnc_param;

		private "_insignia";
		_insignia = ["LoadInsignia", [_class]] call SELF;

		_insignia select 0;
	};

	case "GetInsigniaTexture" :
	{
		private ["_class"];
		_class = [_params, 0, "", [""]] call BIS_fnc_param;

		private "_insignia";
		_insignia = ["LoadInsignia", [_class]] call SELF;

		_insignia select 1;
	};

	case "GetInsigniaAuthor" :
	{
		private ["_class"];
		_class = [_params, 0, "", [""]] call BIS_fnc_param;

		private "_insignia";
		_insignia = ["LoadInsignia", [_class]] call SELF;

		_insignia select 2;
	};

	case "LocalShowNotification" :
	{
		private ["_class", "_notificationParams", "_target"];
		_class                  = [_params, 0, "", [""]] call bis_fnc_param;
		_notificationParams     = [_params, 1, [], [[]]] call bis_fnc_param;
		_target                 = [_params, 2, objNull, [objNull]] call bis_fnc_param;

		private ["_actionKeysNames", "_keyText", "_string"];
		_actionKeysNames        = actionkeysnamesarray ["TeamSwitch", 1];
		_keyText                = if (count _actionKeysNames > 0) then { _actionKeysNames select 0 } else { "N/A" };
		_string                 = format ["<t color = '%2'>[%1]</t>", _keyText, (["GUI", "BCG_RGB"] call BIS_fnc_displayColorGet) call BIS_fnc_colorRGBtoHTML];

		_notificationParams pushBack _string;

		if (player == _target || isNull _target) then
		{
			[_class, _notificationParams] call BIS_fnc_showNotification;
		};
	};

	case "OnPlayerGroupChanged" :
	{
		private ["_player", "_newGroup", "_oldGroup"];
		_player 	= [_params, 0, objNull, [objNull]] call BIS_fnc_param;
		_newGroup 	= [_params, 1, grpNull, [grpNull]] call BIS_fnc_param;
		_oldGroup 	= [_params, 2, grpNull, [grpNull]] call BIS_fnc_param;

		if (["IsGroupRegistered", [_newGroup]] call SELF) then
		{
			[_player, _newGroup getVariable [VAR_GROUP_INSIGNIA, ""]] call BIS_fnc_setUnitInsignia;
		}
		else
		{
			[_player, ""] call BIS_fnc_setUnitInsignia;
		};
	};

	/**
	 * Log error in case of unknown given mode
	 */
	case default
	{
		["Unknown mode: %1", _mode] call BIS_fnc_error;
	};
};
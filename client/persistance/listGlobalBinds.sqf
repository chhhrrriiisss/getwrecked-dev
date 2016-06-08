//
//      Name: listGlobalBinds
//      Desc: Retrieve saved global binds, or default if they don't exist
//      Return: None
//

_globalBinds = profileNamespace getVariable ['GW_BINDS', []];
_globalBindsVersion = profileNamespace getVariable ['GW_BINDS_VERSION', 0];

_defaultBinds = [
	["SETTINGS", "220"],
	["GROUPS", "210"],
	["GRAB", "-1"],
	["ATTACH", "-1"],
	["ROTATECW", "-1"],
	["ROTATECCW", "-1"],
	["HOLD","-1"],
	["INFO", "23"]
];

IF ((count _globalBinds == count _defaultBinds) && _globalBindsVersion == GW_VERSION) exitWith { _globalBinds };

systemchat 'Global binds updated to new version.';

// Try and use previously set binds (if exists)
{	
	_bind = (_x select 0);
	_defaultKey = (_x select 0);

	{	
		if ((_x select 0) == _bind) exitWith {
			if ((_x select 1) == "-1") exitWith {};
			_defaultKey = (_x select 1);		
		};
	} foreach _globalBinds;

	_x set [1, _defaultKey];
} foreach _defaultBinds;

profileNamespace setVariable ['GW_BINDS_VERSION', GW_VERSION];
profileNamespace setVariable ['GW_BINDS', _defaultBinds]; 

_defaultBinds


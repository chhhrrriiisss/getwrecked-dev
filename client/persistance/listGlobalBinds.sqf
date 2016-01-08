//
//      Name: listGlobalBinds
//      Desc: Retrieve saved global binds, or default if they don't exist
//      Return: None
//

_globalBinds = profileNamespace getVariable ['GW_BINDS', []];
if (count _globalBinds > 0) exitWith { _globalBinds };

_defaultBinds = [
	["SETTINGS", "-1"],
	["GRAB", "-1"],
	["ATTACH", "-1"],
	["ROTATECW", "-1"],
	["ROTATECCW", "-1"],
	["HOLD","-1"]
];

profileNamespace setVariable ['GW_BINDS', _defaultBinds]; 
saveProfileNamespace;  

_defaultBinds

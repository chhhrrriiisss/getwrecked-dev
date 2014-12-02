//
//      Name: toggleLockOn
//      Desc: Toggle auto-lock on and off, optionally set to the desired state
//      Return: None
//

private ['_vehicle', '_dir', '_pos', '_alt', '_vel'];

_vehicle = [_this,0, objNull, [objNull]] call BIS_fnc_param;
_state = [_this,1, objNull, [false, objNull]] call BIS_fnc_param;

if (isNull _vehicle) exitWith {};

_currentState = _vehicle getVariable ["lockOns", true];
_state = if (typename _state == "BOOL") then { _state } else { !_currentState };

GW_LOCKEDTARGETS = [];
_vehicle setVariable ["lockOns", _state];	

_icon = lockingIcon;
_color = nil;
_stateString = if (_state) then { "ENABLED! " } else { _color = colorRed; _icon = clearIcon; "DISABLED! "};
[_stateString, 1.5, _icon, _color, "slideDown"] spawn createAlert;   



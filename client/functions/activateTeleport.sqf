//
//      Name: activateTeleport
//      Desc: Activates current teleport pad
//      Return: None
//

private ['_vehicle', '_dir', '_pos', '_alt', '_vel'];

_vehicle = [_this,0, objNull, [objNull]] call filterParam;

if (isNull _vehicle) exitWith {};


_targets = _vehicle getVariable ["GW_teleportTargets", []];
if (count _targets == 0) exitWith {  ['UNAVAILABLE', 0.5, warningIcon, colorRed, "warning"] spawn createAlert;   };

missionNamespace setVariable ["#FX", [_vehicle, 1]];
publicVariable "#FX";
playSound3D [
    "a3\sounds_f\weapons\other\sfx9.wss",
    _vehicle
];

_last = _targets select ((count _targets) -1);
_last setVariable ["triggered", true];

_targets deleteAt ((count _targets) -1);

_vehicle setVariable ["GW_teleportTargets", _targets];

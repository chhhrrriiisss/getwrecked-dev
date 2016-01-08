//
//      Name: fireRpg
//      Desc: Fires a dumbfire missile that carries a mild explosive 
//      Return: None
//

params ['_gun', '_target', '_vehicle'];

_repeats = 1;
_round = "R_PG32V_F";
_soundToPlay = "a3\sounds_f\weapons\Launcher\nlaw_final_2.wss";
_fireSpeed = 0.1;
_projectileSpeed = 250;
_range = 60;

[_gun] spawn muzzleEffect;

_targetPos = if (_target isEqualTo objNull) then { getPosASL _target } else { _target };
_gPos = _gun modelToWorldVisual [1,0,-0.7];
if (GW_DEBUG) then { [_gPos, _targetPos, 3] spawn debugLine; };

_targetPos = [_targetPos, 0.2, 0.2, 0] call setVariance;
_heading = [_gPos, _targetPos] call BIS_fnc_vectorFromXToY;
_velocity = [_heading, _projectileSpeed] call BIS_fnc_vectorMultiply; 
_velocity = (velocity _vehicle) vectorAdd _velocity;

_bullet = createVehicle [_round, _gPos, [], 0, "FLY"];

[(ATLtoASL _gPos), (ATLtoASL _targetPos), "RPG"] call markIntersects;

_bullet setVectorDir _heading; 
_bullet setVelocity _velocity; 

playSound3D [_soundToPlay, _gun, false, getPos _gun, 10, 1, 50];		

addCamShake [.5, 1,20];

true

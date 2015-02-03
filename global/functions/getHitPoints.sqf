//
//      Name: getHitPoints
//      Desc: Returns hit point selections for specified vehicle class
//      Return: Array 
//

// private ["_class", "_hitPoints", "_cfgVehicle", "_hitPointsCfg", "_nbHitPoints", "_hitPoint", "_i"];
// _class = _this;

// if (typeName _class == "OBJECT") then {  _class = typeOf _class; };

// _hitPoints = [];
// _cfgVehicle = configFile >> "CfgVehicles" >> _class;

// for "_i" from 0 to 1 step 0 do {

//     if (!isClass _cfgVehicle) exitWith {};

//     _hitPointsCfg = _cfgVehicle >> "HitPoints";

//     if (isClass _hitPointsCfg) then {
//         _nbHitPoints = count _hitPointsCfg;

//         for "_i" from 0 to (_nbHitPoints - 1) do
//         {
//             _hitPoint = _hitPointsCfg select _i;

//             if ({configName _hitPoint == configName _x} count _hitPoints == 0) then
//             {
//                 _hitPoints pushBack _hitPoint;
//             };
//         };
//     };

//     _cfgVehicle = inheritsFrom _cfgVehicle;
// };

// _hitPoints


private ["_hitpoints", "_hps_fnc", "_cfg", "_class", "_uniform", "_trt", "_trts", "_trts2"];
_hitpoints = [];

_hps_fnc = {
    private "_hitpoint";

    for "_i" from 0 to count(_this) - 1 do {
        _hitpoint = configName(_this select _i);
        if(_hitpoints find _hitpoint == -1) then {
            _hitpoints set [count _hitpoints, _hitpoint];
        };
    };
};

_cfg = configFile >> "CfgVehicles" >> (typeOf _this);
for "_i" from 0 to 0 do {
    if(_i > 0) then {_cfg = inheritsFrom _cfg};
    if(!isClass(_cfg)) exitWith {};

    if(isClass(_cfg >> "HitPoints")) then {
        (_cfg >> "HitPoints") call _hps_fnc;

        _trts = _cfg >> "turrets";
        for "_i" from 0 to (count _trts - 1) do {
            _trt = _trts select _i;
            _trts2 = _trt >> "turrets";

            (_trt >> "HitPoints") call _hps_fnc;

            for "_j" from 0 to (count _trts2 - 1) do {
                ((_trts2 select _j) >> "HitPoints") call _hps_fnc;
            };
        };
    };
};

_hitpoints

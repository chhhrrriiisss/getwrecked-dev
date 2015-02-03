//
//      Name: handleDamageVehicle
//      Return: None
//

private ["_vehicle", "_selection", "_damage", "_ammo"];

_vehicle = _this select 0;
_selection = _this select 1;
_damage = _this select 2;

_origDamage = _damage;
_oldDamage = nil;
_projectile = _this select 4;

if (_selection != "?") then  {

    _oldDamage = if (_selection == "") then { 
        damage _vehicle 
    } else {  
        _vehicle getHitPointDamage (_vehicle getVariable ["GW_hitPoint_" + _selection, ""]) 
    };

    if (!isNil "_oldDamage") then  {

        if (_projectile == "") then {

            _selSubstr = toArray _selection;
            _selSubstr resize 5;

            _scale = switch (true) do {
                case (toString _selSubstr == "wheel"): { WHEEL_COLLISION_DMG_SCALE };
                default                                { COLLISION_DMG_SCALE };
            };

            _damage = ((_damage - _oldDamage) * _scale) + _oldDamage;  

        } else {

            _scale = switch (_projectile) do
            {
                case ("R_PG32V_F"): { RPG_DMG_SCALE };
                case ("M_Titan_AT"): { TITAN_AT_DMG_SCALE };
                case ("M_NLAW_AT_F"): { GUD_DMG_SCALE };
                case ("B_127x99_Ball_Tracer_Red"): { LSR_DMG_SCALE };
                case ("B_127x99_Ball"): { HMG_DMG_SCALE };
                case ("B_127x99_Ball_Tracer_Yellow"): { HMG_IND_DMG_SCALE };
                case ("B_35mm_AA_Tracer_Yellow"): { HMG_HE_DMG_SCALE };
                case ("R_TBG32V_F"): { MORTAR_DMG_SCALE };                
                case ("G_40mm_HEDP"): { GMG_DMG_SCALE };
                case ("Bo_GBU12_LGB"): { EXP_DMG_SCALE };    
                case ("B_762x51_Tracer_Green"): { LMG_DMG_SCALE };
                default                                { 1 };
            };

            _status = _vehicle getVariable ['status', []];
            _scale = if ("nanoarmor" in _status) then { 0.01 } else { _scale };

            _damage = ((_damage - _oldDamage) * _scale) + _oldDamage; 

        };

    };

};

// Check tyres and whether we need to eject
[_vehicle] spawn checkTyres; 

// If we're invulnerable, ignore all damage
_status = _vehicle getVariable ["status", []];
if ("invulnerable" in _status) then {
    _damage = false;
}  else {
    
    // Match damage to crew
    _vDmg = getDammage _vehicle;
    _crew = crew _vehicle;
    { _x setDammage _vDmg; } ForEach _crew;

    // Match hull damage to other parts
    _dmg = _vehicle getHit "karoserie";
    {  _vehicle setHit [_x, _dmg]; } Foreach (_vehicle getVariable ['GW_Hitpoints', []]);

};

_damage


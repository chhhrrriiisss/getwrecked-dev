//
//      Name: handleDamageObject
//      Desc: Damage event handler for objects
//      Return: Bool (False, as health handled independently)
//

private ["_obj", "_damage", "_projectile"];

_obj = _this select 0;
_damage = _this select 2;
_projectile = _this select 4;

_firstHit = _obj getVariable ['firstHit', nil];
if (isNil "_firstHit") then {
	_obj setVariable ['firstHit', time];
};

_health = _obj getVariable ["GW_Health", 0];

_data = [typeof _obj, GW_LOOT_LIST] call getData;
_originalHealth = 0;
_tag = if (!isNil "_data") then { _originalHealth = (_data select 3); (_data select 6) } else { _originalHealth = 1; "" };

// Only handle damage outside of the workshop
if (GW_CURRENTZONE == "workshopZone" || ((count toArray _tag) > 0) ) exitWith {
	_obj setVariable ["GW_Health", _health, true];
    _obj setDammage 0;
    false
};

// Only handle damage outside of the workshop
if (_health > 0) then  {

    if (_projectile == "") then {

        _damage = (_damage * OBJ_COLLISION_DMG_SCALE);

    } else {

        _scale = switch (_projectile) do
        {
            case ("R_PG32V_F"): { OBJ_RPG_DMG_SCALE };
            case ("M_Titan_AT"): { OBJ_TITAN_AT_DMG_SCALE };
            case ("M_NLAW_AT_F"): { OBJ_GUD_DMG_SCALE };
            case ("B_127x99_Ball_Tracer_Red"): { OBJ_LSR_DMG_SCALE };
            case ("B_127x99_Ball"): { OBJ_HMG_DMG_SCALE };
            case ("B_127x99_Ball_Tracer_Yellow"): { OBJ_HMG_DMG_SCALE };
            case ("B_35mm_AA_Tracer_Yellow"): { OBJ_HMG_HE_DMG_SCALE };
            case ("R_TBG32V_F"): { OBJ_MORTAR_DMG_SCALE };
            case ("G_40mm_HEDP"): { OBJ_GMG_DMG_SCALE };
            case ("Bo_GBU12_LGB"): { OBJ_EXP_DMG_SCALE };       
            case ("B_762x51_Tracer_Green"): { OBJ_LMG_DMG_SCALE };   
            default                                { 1 };
        };

        _damage = (_damage * _scale);

    };
    
   
};

_health = _health - _damage;


_name = (_obj getVariable ['name', 'object']);


if (_health < 0) then {

	_firstHit = _obj getVariable ['firstHit', 0];
	_totalTime = time - _firstHit;
	if (GW_DEBUG) then { systemChat format['%1 destroyed in %2', _name, _totalTime]; };

    _obj spawn {       
        [_this, true] spawn destroyObj;
    };

} else {
	
	if (GW_DEBUG) then {  systemchat format['%1 / %2 / %3%', _name, _projectile, _health, ceil((_health / _originalHealth) * 100)]; };
	_obj setVariable["GW_Health", _health, true];

};


false

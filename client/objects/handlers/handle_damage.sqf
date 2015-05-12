//
//      Name: handleDamageObject
//      Desc: Damage event handler for objects
//      Return: Bool (False, as health handled independently)
//

private ["_obj", "_damage", "_projectile"];

_obj = _this select 0;
_damage = _this select 2;
_projectile = _this select 4;

_health = _obj getVariable ["GW_Health", 0];

_data = [typeof _obj, GW_LOOT_LIST] call getData;
_originalHealth = 0;
_tag = if (!isNil "_data") then { _originalHealth = (_data select 3); (_data select 6) } else { _originalHealth = 1; "" };

_inWorkshop = if (_obj distance getMarkerPos "workshopZone_camera" < 300) then { true } else { false };
_isProtected = if (_tag in GW_WEAPONSARRAY || _tag in GW_LOCKONWEAPONS || _tag in GW_TACTICALARRAY || _tag in GW_SPECIALARRAY) then { true } else { false };

// Only handle damage outside of the workshop for non-protected items
if (_inWorkshop || _isProtected) exitWith { _obj setDammage 0; false };

// If it's not already dead
if (_health > 0) then  {

    if (_projectile == "") then {

        _damage = (_damage * OBJ_COLLISION_DMG_SCALE);

    } else {

        _scale = _projectile call objectDamageData;
        _damage = (_damage * _scale);

    };
    
   
};

_health = _health - _damage;


_name = (_obj getVariable ['name', 'object']);


if (_health < 0) then {

    _obj spawn {       
        [_this, true] spawn destroyObj;
    };

} else {	
	_obj setVariable["GW_Health", _health, true];
};


false

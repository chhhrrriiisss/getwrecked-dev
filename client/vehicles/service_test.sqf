_vehicle = _this select 0;
_status = _this select 1;

SYSTEMCHAT 'TEST';

// If we're not disabled to any extent
if ( !("emp" in _status) && !("disabled" in _status) ) then {

    _nearbyService = _vehicle getVariable ["GW_NEARBY_SERVICE", nil];

    if (!isNil "_nearbyService") then {    
        systemchat format['over pad: %1 / %2', time, _nearbyService];
    };      

};
private ['_pos', '_objs'];

_pos = getMarkerPos "workshopZone_camera";

_objs = nearestObjects [_pos, [], 125];

if (count _objs <= 0) exitWith { true };

{	
	if ((typeOf _x) == "Land_PaperBox_closed_F") then {
		_x call setupSupplyBox;
	};
	false
} count _objs > 0;

true


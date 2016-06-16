//
//      Name: effectIsVisible
//      Desc: Check if a particular effect should be rendered by comparing max effect range and source FOV
//      Return: Bool
//

private ['_pos', '_duration', '_source', '_scope', '_dist', '_target'];
params ['_target'];

if (GW_PREVIEW_CAM_ACTIVE || count _target == 0) exitWith { false };

// Get the source for this client, even if we're currently in a preview camera
_source = if (GW_DEATH_CAMERA_ACTIVE) then {
	[(positionCameraToWorld [0,0,0]), [(positionCameraToWorld [0,0,0]), (positionCameraToWorld [0,0,4])] call dirTo]
} else {
	[GW_CURRENTPOS, GW_CURRENTDIR]
};

// Outside effects range dont worry about it
_dist = (_target distance (_source select 0));
if (_dist > GW_EFFECTS_RANGE) exitWith { false };

TRUE

//
//      Name: previewLocation
//      Desc: Move the preview camera to the desired preview location
//      Return: None
//

private ['_location', '_pos', '_typeOfZone'];

_location = _this select 0;
_typeOfZone = _this select 2;

switch(_typeOfZone) do {

	case "race": {
		// If this is the first time, create the camera		
		GW_RACE_ARRAY execVM 'client\ui\cameras\race_camera.sqf';
	};
	case "battle": {

		_pos = getMarkerPos format['%1%2_%3', GW_SPAWN_LOCATION, 'Zone', 'camera'];
		_pos set [2, 20];

		// If this is the first time, create the camera
		if (!GW_PREVIEW_CAM_ACTIVE) then {
			[_pos, 200, 0.0005, 1, 15] spawn previewCamera;

		} else {
			GW_PREVIEW_CAM_TARGET = _pos;
		};

	};
	default {};
};

// Grab our dialog items
disableSerialization;
_menu = (findDisplay 52000);
_title = ((findDisplay 52000) displayCtrl 52001);	
_list = ((findDisplay 52000) displayCtrl 52002);	

_title ctrlShow true;
_title ctrlSetText toUpper (_this select 1);
_title ctrlCommit 0;

GW_LASTLOCATION = GW_SPAWN_LOCATION;
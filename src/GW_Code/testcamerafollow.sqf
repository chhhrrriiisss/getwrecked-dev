_cam = "camera" camCreate (getpos player);
_cam camSetRelPos [0,-2,2];
_cam cameraeffect["internal","back"];
_cam camCommit 0;

[_cam, (vehicle player)] call bis_fnc_camFollow;


Sleep 10;

player cameraeffect["terminate","back"];
camdestroy _cam;
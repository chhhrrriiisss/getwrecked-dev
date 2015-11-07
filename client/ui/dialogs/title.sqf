//
//      Name: createTitle
//      Desc: Used for displaying a large full-screen message
//      Return: None
//

if (GW_TITLE_ACTIVE) then {
	GW_TITLE_ACTIVE = false;
	closeDialog 95000;
};

// Close the hud if its open
GW_HUD_ACTIVE = false;
GW_TITLE_ACTIVE = true;

private ['_buttonString', '_timeValue', '_showButton'];

_buttonString = [_this,0, "CANCEL", [""]] call filterParam;
_textString =  [_this,1, "", [""]] call filterParam;
_showButton = [_this,2, true, [false]] call filterParam;
_endFunction = [_this,3, { GW_TITLE_ACTIVE = false; }, [{}, ""]] call filterParam;
_condition = {true};

// _soundEnabled = [_this,3, false, [false]] call filterParam;

disableSerialization;
if(!(createDialog "GW_TitleScreen")) exitWith { GW_TITLE_ACTIVE = false; }; 
showChat false;

_timeout = time + 9999;

disableSerialization;
_text = ((findDisplay 95000) displayCtrl 95001);
_btn = ((findDisplay 95000) displayCtrl 95002);

_btn ctrlShow true;
_btn ctrlSetText _buttonString;
_btn ctrlCommit 0;	

if (!_showButton) then {
	_btn ctrlShow false;
	_btn CtrlCommit 0;
};

_text ctrlSetStructuredText parseText ( _textString );
_text ctrlCommit 0;

for "_i" from 0 to 1 step 0 do {
	if (isNull (findDisplay 95000) || (time > _timeout) || !(call _condition) || !GW_TITLE_ACTIVE) exitWith {};
	Sleep 0.1;
};

// Timer over, tidy up
showChat true;
GW_TITLE_ACTIVE = false;
closeDialog 95000;

call _endFunction;



// disableSerialization;
// _text = ((findDisplay 95000) displayCtrl 95001);
// _btn = ((findDisplay 94000) displayCtrl 94002);

// _btn ctrlSetText _buttonString;
// _btn ctrlShow true;
// _btn ctrlCommit 0;

// // Allows the timer to be cancelled via button
// if (!_showButton) then {
// 	_btn ctrlShow false;
// 	_btn ctrlCommit 0;
// };

// _exitWith = false;
// _sleepTime = 0.1;
// _lastSecond = 0;

// for "_i" from 0 to 1 step 0 do {

// 	if (isNull (findDisplay 94000) || (time > GW_TIMER_VALUE) || !GW_TITLE_ACTIVE) exitWith {};

// 	_left = (GW_TIMER_VALUE - time);
// 	_seconds = floor (_left);	
// 	_milLeft = floor ( abs ( floor( _left ) - _left) * 10);
// 	_hoursLeft = floor(_seconds / 3600);
// 	_minsLeft = floor((_seconds - (_hoursLeft*3600)) / 60);
// 	_secsLeft = floor(_seconds % 60);
// 	_timeLeft = format['-%1:%2:%3:%4', ([_hoursLeft, 2] call padZeros), ([_minsLeft, 2] call padZeros), ([_secsLeft, 2] call padZeros), ([_milLeft, 2] call padZeros)];

// 	disableSerialization;
// 	_text = ((findDisplay 94000) displayCtrl 94001);
// 	_text ctrlSetText _timeLeft;
// 	_text ctrlCommit 0;

// 	if (_soundEnabled) then {
// 		if (_seconds != _lastSecond) then {
// 			_lastSecond = _seconds;
// 			GW_CURRENTVEHICLE say "beepTarget";
// 		};
// 	};

// 	Sleep _sleepTime;

// };

// // Timer over, tidy up
// showChat true;
// _exitWith = if (GW_TITLE_ACTIVE && time > GW_TIMER_VALUE) then { true } else { false };
// GW_TITLE_ACTIVE = false;
// closeDialog 0;

// _exitWith



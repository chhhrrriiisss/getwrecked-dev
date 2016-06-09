//
//      Name: createTitle
//      Desc: Used for displaying a large full-screen message
//      Return: None
//

waitUntil {
	Sleep 1;
	isNull (findDisplay 602)
};

if (isNil "GW_OVERLAY_ACTIVE") then {
	GW_OVERLAY_ACTIVE = false;
};

if (GW_OVERLAY_ACTIVE) exitWith { 
	systemchat 'Overlay already active.'; 
	false
};

hint '';

GW_OVERLAY_ACTIVE = true;

// Close the hud if its open
GW_HUD_ACTIVE = false;
GW_HUD_LOCK = true;

private ['_buttonString', '_timeValue', '_canAbort', '_timeout'];

_textString =  [_this,0, "", ["", {}]] call filterParam;
_buttonString = [_this,1, "CANCEL", [""]] call filterParam;

_maxTime = 10;

// _soundEnabled = [_this,3, false, [false]] call filterParam;
disableSerialization;

closeDialog 99000;
if(!(createDialog "GW_Overlay")) exitWith { systemchat 'Error - couldnt create title.'; GW_OVERLAY_ACTIVE = false; false }; 
showChat false;

_timeout = time + _maxTime;

disableSerialization;
_title = ((findDisplay 99000) displayCtrl 99001);
_content = ((findDisplay 99000) displayCtrl 99002);
_btnA = ((findDisplay 99000) displayCtrl 99003);
_btnB = ((findDisplay 99000) displayCtrl 99004);
_bg = ((findDisplay 99000) displayCtrl 99005);

_bg ctrlShow true;
_bg ctrlCommit 0;

_btnA ctrlShow true;
_btnA ctrlSetText 'GOT IT!';
_btnA ctrlCommit 0;

_btnB ctrlShow true;
_btnB ctrlCommit 0;

_title ctrlShow true;
_t = format['<img image="%1" size="16" align="center"/>', MISSION_ROOT + "client\images\logo_isolation2.paa"];
_title ctrlSetStructuredText(parseText(_t));
_title ctrlCommit 0;

_content ctrlShow true;
_t = format[
	'<t size="0.85" font="puristaMedium" shadow="1" color="#FFFFFF" align="center">%1 </t>
	<br /><br />
	<t size="0.85" font="puristaLight" shadow="1" color="#FFFFFF" align="center">%2</t>
	<br /><br />
	<t size="0.85" font="puristaMedium" shadow="1" color="#FFFFFF" align="center">For additional hints, press <t color="#FCD93B">[ %3 ]</t> when near an item or object.</t>', 
	"Get Wrecked is a custom vehicle sandbox that challenges players to create armoured vehicles and then fight to the death in a race or battle.",
	"To begin, find an empty Vehicle Service Terminal to load or create a vehicle from scratch. <br /> If you have issues that are not fixed by rejoining, use the !reset command.",
	[ (['INFO'] call getGlobalBind) ] call codeToKey
];
_content ctrlSetStructuredText(parseText(_t));
_content ctrlCommit 0;


// _btn ctrlShow true;
// _btn ctrlSetText _buttonString;
// _btn ctrlCommit 0;	

// if (_text call _buttonCondition) then {
// 	_btn ctrlEnable true;
// 	_btn ctrlShow true;
// 	_btn CtrlCommit 0;	
// } else {
// 	_btn ctrlEnable false;
// 	_btn ctrlShow false;
// 	_btn CtrlCommit 0;	
// };

// // Show button if we can cancel this title
// if (!_canAbort) then {
// 	[95000, true] call toggleDisplayLock;	
// };

// // Hide/show top and bottom margins
// if (!_showBorders) then {

// 	{
// 		_x ctrlSetFade 1;
// 		_x ctrlCommit 0;
// 	} foreach _margins;

// } else {

// 	{
// 		_x ctrlSetFade 0;
// 		_x ctrlCommit 0;
// 	} foreach _margins;

// };

// Desaturate screen
"colorCorrections" ppEffectEnable true; 
"colorCorrections" ppEffectAdjust [1, 1, 0, [1, 1, 1, 0], [1, 1, 1, 0], [0.75, 0.25, 0, 1.0]];
"colorCorrections" ppEffectCommit 0;

for "_i" from 0 to 1 step 0 do {	

	// _textValue = if (_textString isEqualType "") then { _textString } else { ([time, _timeout] call _textString) };
	// _text ctrlSetStructuredText parseText ( _textValue );
	// _text ctrlCommit 0;

	// if (_text call _buttonCondition) then {		
	// 	_btn ctrlEnable true;
	// 	_btn ctrlShow true;
	// 	_btn CtrlCommit 0;
	// };

	if (isNull (findDisplay 99000) ||  !GW_OVERLAY_ACTIVE) exitWith {};

	Sleep 0.1;
};

// Desaturate screen
"colorCorrections" ppEffectAdjust [1, 1, 0,[ 0, 0, 0, 0],[ 1, 1, 1, 1],[ 0, 0, 0, 0]]; 
"colorCorrections" ppEffectEnable true; 
"colorCorrections" ppEffectCommit 0;


// Timer over, tidy up
showChat true;

GW_OVERLAY_ACTIVE = false;
GW_HUD_ACTIVE = false;
GW_HUD_LOCK = false;
closeDialog 99000;





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



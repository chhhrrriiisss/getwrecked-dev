//
//      Name: checkTimeout
//      Desc: Checks if the module or weapon is currently on timeout (being reloaded)
//      Return: Array [Time Left, State]
//

private ["_type", "_currentTime", "_state", '_timeLeft', "_count"];

_type = _this select 0;
_currentTime = _this select 1;

_state = [0, false, 0];

if (_currentTime == 0 || (count GW_WAITLIST == 0)) exitWith { _state };

_numberOfType = 0;
_timeLeft = 0;
{	
	_timeLeft = 0;
	_error = false;
	if (!isNil "_x") then {			
		_source = _x select 0;
		_timeNeeded = _x select 1;

		// If it has a time and tag
		if (!isNil "_timeNeeded" && !isNil "_source") then {

			_timeLeft = _timeNeeded - _currentTime;			

			// If we're checking an object reference, check both tag and object
			if (_timeLeft > 0 && { typename _source == "ARRAY" } && { (_source select 0) == _type || (_source select 1) == _type }) then {
				_state set[0, (_state select 0) + ceil(_timeLeft)];
				_state set[1, true];
				_numberOfType = _numberOfType + 1;
			};

			// If we're just checking a tag state
			if (_timeLeft > 0 && { typename _source == "STRING" } && { _source == _type }) then {
				_state set[0, (_state select 0) + ceil(_timeLeft)];
				_state set[1, true];
				_numberOfType = _numberOfType + 1;
			};

		};		
	} elsE {
		_error = true;
	};	

	// If it should have expired
	if (_timeLeft <= 0 || _error) then {
		GW_WAITLIST deleteAt _foreachindex;				
	};		


} ForEach GW_WAITLIST;

_state set[2, _numberOfType];

_state
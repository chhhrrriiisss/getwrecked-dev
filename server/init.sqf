//
//
//
//		Server Initialization
//
//
//

_startTime = time;

[] call GWS_fnc_initObjects;
[] call GWS_fnc_initPaint;
[] call GWS_fnc_initSupply;
[] call GWS_fnc_initBoundary;
[] call GWS_fnc_initNitro;

[] spawn initEvents;

serverSetupComplete = compileFinal "true";
publicVariable "serverSetupComplete";

_endTime = time;
_str =  format['Server setup completed in %1s.', (_endTime - _startTime)];
diag_log _str;
systemchat _str;
X_Server = false;
X_Client = false;
X_JIP = false;

// Used to determine if saved vehicles are out-of-date
GW_VERSION = 85.6;

if (isServer) then { X_Server = true };
if (!isDedicated) then { X_Client = true };
if (isNull player) then { X_JIP = true };

// Get the mission directory
MISSION_ROOT = call {
    private "_arr";
    _arr = toArray str missionConfigFile;
    _arr resize (count _arr - 15);
    toString _arr
};

// Global Variables / Functions
call compile preprocessFile "global\compile.sqf";
[] execVM "briefing.sqf";

hint "v0.8.6 DEV";

99999 cutText [localize "str_gw_loading", "BLACK", 0.01]; 

if (X_Client || X_JIP) then {
   
   [] spawn {  

        call compile preprocessFile "client\compile.sqf";  
        waitUntil {!isNull player && !isNil "clientCompileComplete"};               
        [] execVM 'client\init.sqf';

    };

};

if (X_Server) then {      

	[] spawn {

	    call compile preprocessFile "server\compile.sqf";   
	    waitUntil {!isNil "serverCompileComplete"};      
	    [] execVM 'server\init.sqf';

	};

};



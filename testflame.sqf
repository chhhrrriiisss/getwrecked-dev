// if (!isServer) exitWith {};

// {    

// 	_p = createVehicle ["UserTexture10m_F", (ASLtoATL getPosASL _x), [], 0, 'CAN_COLLIDE'];            
// 	_p setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
// 	_p setPos (_x modelToWorld [2.4,5.8,-0.3]);
// 	[_p, [-90,0,(getDir _x)]] call setPitchBankYaw;  

// 	false
	
// } count nitroPads >0;

_pos = ((vehicle player) modelToWorldVisual [0,15,0]);
_pos set [2, 0];
_pad = createVehicle ["ContainmentArea_01_sand_F", _pos, [], 0, 'CAN_COLLIDE']; 
_pad allowDamage false;

_pad spawn {
	
	Sleep 5;

	_duration = 5;
	_pos = getPos _this;
	_scale = 15;
	[_this, 0.5, 0.35] spawn magnetEffect;

	_bomb = createVehicle ["R_TBG32V_F", _pos, [], 0, "FLY"];		
	_bomb setVelocity [0,0,-10];
	[_pos, 40, 15] call shockwaveEffect;	

	_this spawn {

		_timeout = time + 5;
		waitUntil {

			_nearby = (ASLtoATL visiblePositionASL _this) nearEntities[["Car", "Tank"], 8];
			{ 				
				_null = [_x, 100, 6] spawn setVehicleOnFire;

				_x setDammage ((getdammage _x) + (random 0.25));
				[       
					_x,
					"updateVehicleDamage",
					_x,
					false
				] call bis_fnc_mp; 

				false
			} count _nearby > 0;

			Sleep 0.1;

			(time > _timeout)
		};

	};

	//"test_EmptyObjectForFireBig" createVehicleLocal _pos;
	// _fires = [];

	// for "_i" from 0 to 7 step 0 do {

	// 	Sleep (random 0.5);

	

	// 	_source spawn {
	// 		Sleep (random 3);
	// 		deleteVehicle _this;
	// 	};		

	// };

	_source2 = "#particlesource" createVehicleLocal _pos;
	_source2 setParticleParams 
	/*Sprite*/		[["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "",// File,Ntieth,Index,Count,Loop(Bool)
	/*Type*/			"Billboard",
	/*TimmerPer*/		1,
	/*Lifetime*/		8,
	/*Position*/		[0,0,0],
	/*MoveVelocity*/	[0,0,0.5],
	/*Simulation*/		0,1.277,1,0.025,//rotationVel,weight,volume,rubbing
	/*Scale*/			[5,6,7,8],
	/*Color*/			[[0,0,0,0],[0,0,0,0.6],[0,0,0,0.6],[0,0, 0,0.4], [0,0,0,0.15], [1,1,1,0]],
	/*AnimSpeed*/		[0.2],
	/*randDirPeriod*/	1,
	/*randDirIntesity*/	0.04,
	/*onTimerScript*/	"",
	/*DestroyScript*/	"",
	/*Follow*/			_this,
	/*Angle*/              0,
	/*onSurface*/          true,
	/*bounceOnSurface*/    0.5,
	/*emissiveColor*/      [[0,0,0,0]]];

	// RANDOM / TOLERANCE PARAMS
	_source2 setParticleRandom
	/*LifeTime*/		[2,
	/*Position*/		[2, 2, 0.5],
	/*MoveVelocity*/	[1.5, 1.5, 3],
	/*rotationVel*/		20,
	/*Scale*/		0.2,
	/*Color*/		[0, 0, 0, 0.1],
	/*randDirPeriod*/	0,
	/*randDirIntesity*/	0,
	/*Angle*/		360];

	_source2 setDropInterval 0.025;
	_source2 attachTo [_this];

	_scale = 0.5;

	_source3  = "#particlesource" createvehiclelocal _pos;
	_source3 setParticleCircle [0, [0, 0, 0]];
	_source3 setParticleRandom [0.2, [15 * _scale, 15 * _scale, 0], [0, 0, 0], 1, 0.5, [0, 0, 0, 0], 0, 0];
	_source3 setDropInterval 0.01;
	_source3 attachTo [_this];

	_source3 setParticleParams
	[
	["\A3\data_f\ParticleEffects\Universal\Refract",1, 0, 1, 0],					//ShapeName ,1,0,1],	
	"",																		//AnimationName
	"Billboard",															//Type
	3,																		//TimerPeriod
	6,																	//LifeTime
	[0.1, 0.1, 0.1],																//Position
	[30 * _scale, 30 * _scale, 0],															//MoveVelocity
	0,																		//RotationVelocity
	3,																		//Weight
	3,																		//Volume
	0.1,																	//Rubbing
	[5 * _scale, 60 * _scale],																	//Size
	[[1, 1, 1, 0.5], [1, 1, 1, 0.3],  [1, 1, 1, 0]],		//0.15												//Color
	[1],					  												//AnimationPhase
	0,																		//RandomDirectionPeriod
	0,																		//RandomDirectionIntensity
	"",																		//OnTimer
	"",																		//BeforeDestroy
	_this																	//Object
	];	

	// _scale = 0.1;
	_source = "#particlesource" createVehicle _pos;
	_source setParticleClass "ObjectDestructionFire1Smallx";
	_source setDropInterval 0.0025;
		// RANDOM / TOLERANCE PARAMS
	_source setParticleRandom
	/*LifeTime*/		[3,
	/*Position*/		[3, 3, 0.5],
	/*MoveVelocity*/	[1, 1, 2],
	/*rotationVel*/		20,
	/*Scale*/		1.2,
	/*Color*/		[0, 0, 0, 1],
	/*randDirPeriod*/	3,
	/*randDirIntesity*/	0.1,
	/*Angle*/		0];

	_source attachTo [_this];

	[		
		[
			_this,
			"flamethrower",
			50
		],
		"playSoundAll",
		true,
		false
	] call bis_fnc_mp;	

	Sleep _duration;

	deleteVehicle _source;
	deleteVehicle _source2;	
	deleteVehicle _source3;	

};


_pad setVectorUp (surfaceNormal _pos);

_dir = [getDir _pad + 90] call normalizeAngle;
_dir2 = [getDir _pad - 90] call normalizeAngle;
_dir3 = [getDir _pad + 180] call normalizeAngle;

// {    
_g = createVehicle ["UserTexture10m_F", _pos, [], 0, 'CAN_COLLIDE'];            
_g setObjectTextureGlobal [0,"client\images\grill_ts.paa"]; 
_g setPos (_pad modelToWorld [-1.4,0,-0.01]);
_g setVectorUp (surfaceNormal _pos);
[_g, [-90,0,(getDir _pad)]] call setPitchBankYaw;  

_g2 = createVehicle ["UserTexture10m_F", _pos, [], 0, 'CAN_COLLIDE'];            
_g2 setObjectTextureGlobal [0,"client\images\grill_ts.paa"]; 
_g2 setPos (_pad modelToWorld [1.4,0,-0.01]);
_g2 setVectorUp (surfaceNormal _pos);
[_g2, [-90,0,(getDir _pad)]] call setPitchBankYaw;  

_p = createVehicle ["UserTexture10m_F", _pos, [], 0, 'CAN_COLLIDE'];            
_p setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
_p setPos (_pad modelToWorld [11.5,0,-0.2]);
_p setVectorUp (surfaceNormal _pos);
[_p, [-90,0,_dir]] call setPitchBankYaw;  

_p = createVehicle ["UserTexture10m_F", _pos, [], 0, 'CAN_COLLIDE'];            
_p setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
_p setPos (_pad modelToWorld [-11.5,0,-0.2]);
_p setVectorUp (surfaceNormal _pos);
[_p, [-90,0,_dir2]] call setPitchBankYaw;  



// _p = createVehicle ["UserTexture10m_F", _pos, [], 0, 'CAN_COLLIDE'];            
// _p setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
// _p setPos (_pad modelToWorld [0,9.5,-0.2]);
// _p setVectorUp (surfaceNormal _pos);
// [_p, [-90,0,(getDir _pad)]] call setPitchBankYaw;  

// _p = createVehicle ["UserTexture10m_F", _pos, [], 0, 'CAN_COLLIDE'];            
// _p setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
// _p setPos (_pad modelToWorld [0,-9.5,-0.2]);
// _p setVectorUp (surfaceNormal _pos);
// [_p, [-90,0,_dir3]] call setPitchBankYaw;  

// _p2 = createVehicle ["UserTexture10m_F", _pos, [], 0, 'CAN_COLLIDE'];            
// _p2 setObjectTextureGlobal [0,"client\images\stripes_fade.paa"]; 
// _p2 setPos (_pad modelToWorld [0.5,-0.2,0.15]);
// _p2 setVectorUp (surfaceNormal _pos);
// [_p2, [-90,0,_dir2]] call setPitchBankYaw;  

// 	false
	
// } count nitroPads >0;


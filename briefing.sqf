if (!hasInterface) exitWith {};

waitUntil {!isNull player};

player createDiarySubject ["changelog", "Changelog"];
player createDiarySubject ["bindings", "Bindings"];
player createDiarySubject ["issues", "Issues"];


player createDiaryRecord ["issues",
[
"Common issues and fixes:",
"
- Simulated objects bumping vehicles <br /> 
Drop the object on the floor, wait a second then pick it back up <br />
<br />
- HUD does not show X weapon or X module<br />
Occasionally this does get stuck. If you hop out and back in the vehicle it should fix it.<br />
<br />
- Weapons and objects not facing the correct direction when you load a vehicle<br />
This is caused by lag and the object (especially if its a railgun/rpg) should eventually update, it just takes a while<br />
<br />
- Vehicle repair/rearm/refuel pads not working<br />
They can be temperamental and slow, but they do work - just give it a second!<br />
<br />
"
]];


player createDiaryRecord ["bindings",
[
"Available bindings:",
"
<br />
[ Editing ]<br />
<br />
Grab / Drop - User Action 1<br />
Attach / Detach - User Action 2<br />
Rotate CW - User Action 3<br />
Rotate CCW - User Action 4<br />
Hold Rotate - User Action 5<br />

<br />
[ Common ]<br />
<br />
Open Vehicle Settings - User Action 20<br />
"
]];



























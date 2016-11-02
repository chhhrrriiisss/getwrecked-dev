//
//
//
//
//		Custom compile
//
//      These are applied post all other global compilation — follow the templates to avoid issues
//      This section is intended to avoid needing to edit the arrays provided by the base mission and should allow easier for updating in the future
//
//
//
//


// Remove this if you intend to use this file
if (true) exitWith { true };

//
//      Custom Vehicles
//
//      Follow the example format to add a new vehicle to the game
//      Vehicle MUST be a type of LandVehicle
//

// Using append to add to existing vehicles, or re-declare the array to create your own custom list
GW_VEHICLES_LIST append [

    [

        "C_Quadbike_01_F", // Class for this vehicle
        "Quadbike", // Display Name
        "The quadbike is ideal for fast and stealthy surprise attacks.", // Vehicle description

        // Vehicle properties array
        [
            [
                0.05, // Mass Modifier [ Decrease to allow this vehicle to carry more weight ]
                850 // Mass limit [ Max weight cap at which adding more parts doesn't change vehicle agility ]
            ],
            3, // Max Weapons
            3, // Max Modules
            1, // Default Ammo Capacity
            1, // Default Fuel Capacity
            2, // Armor Rating [ Doesnt impact gameplay, but modifies visible armor rating in attributes list ]
            1.1, // Armor Modifier [ Lower value to increase time to kill, keep within 0.75 - 1.5 for best effect, small increments recommended ]
            "Tiny", // Radar Signature [ Tiny | Low | Medium | Large ]
            1000 // ? This had a use at some point...
        ],

        0 // Vehicle availability [ -1 Unspawnable, 0 Spawnable, > 0 Locked (And cost to unlock) ]

    ]

];

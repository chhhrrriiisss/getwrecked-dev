//
//
//
//
//		Custom compile
//
//      These are applied post all other global compilation — please follow the templates to avoid issues
//      This section is intended to avoid needing to edit the base arrays provided by the base mission and should allow easier for updating
//
//
//
//


// Remove this if you intend to use this file
if (true) exitWith {};

//
//      Custom Vehicles
//
//      Follow the example format to add a new vehicle to the game
//      Vehicle MUST be a type of LandVehicle
//

// Using append to add to existing vehicles, or re-declare the array to create your own custom list
GW_VEHICLE_LIST append [

    [

        "dbo_CIV_new_bike",
        "Bike",
        "The quadbike is ideal for fast and stealthy surprise attacks.",
        [
            [
                0.05,
                850
            ],
            3,
            3,
            1,
            1,
            2,
            1.1,
            "Tiny",
            1000
        ],
        0

    ],

    [

        "Tal_Murci_PC", // Class for this vehicle
        "Lamborghini", // Display Name
        "A fast strong reliable car!", // Vehicle description
        [
            [
                0.05, // Mass Modifier [ Decrease to allow this vehicle to carry more weight ]
                850 // Mass limit [ Max weight cap at which adding more parts doesn't change vehicle agility ]
            ],
            5, // Max Weapons
            5, // Max Modules
            1, // Default Ammo Capacity
            1, // Default Fuel Capacity
            3, // Armor Rating [ Doesnt impact gameplay, modifies visible armor rating in attributes list ]
            1.1, // Armor Modifier [ Lower value to increase time to kill, keep within 0.9 - 1.3 for best effect ]
            "Low", // Radar Signature [ Tiny | Low | Medium | Large ]
            1000 // ? This had a use at some point...
        ],
        0 // Vehicle availability [ -1 Unspawnable, 0 Spawnable, > 0 Locked (And cost to unlock) ]

    ]

];

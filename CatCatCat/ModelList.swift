import RealityKit

enum EntityType {
    case unknown
    case independent
    case walk          // Travel
    case walk_start    // Travel
    case walk_end
    case run           // Travel
    case run_fast      // Travel
    case trot          // Travel
    case turn
    case sit_to_lieside
    case sit_to_liebelly
    case lieside_to_sit
    case liebelly_to_sit
    case sit
    case sit_start
    case sit_end
    case lieside
    case lieside_start
    case lieside_end
    case lieside_sleep
    case lieside_sleep_start
    case lieside_sleep_end
    case liebelly
    case liebelly_start
    case liebelly_end
    case liebelly_sleep
    case liebelly_sleep_start
    case liebelly_sleep_end
    case jump_run       // Travel
    case jump_place
    case jump_fw        // Travel
    case eat
    case drink
    case eatdrink_start
    case eatdrink_end
}

let sampleNameUsdzList: [String: String] =
    [
        "Black"      : "black_idle",
        "Grey"       : "grey_idle",
        "Orange"     : "orange_idle",
        "Tiger"      : "tiger_idle",
        "White_Black": "white_black_idle",
    ]

let firstUsdzEntityTypeList: [String: EntityType] = [
    "Kitten_Lick": EntityType.independent,
    "Kitten_Walk_F_RM": EntityType.walk,
    "Kitten_Walk_start": EntityType.walk_start,
    "Kitten_Walk_end": EntityType.walk_end,
    "Kitten_Turn_180_R": EntityType.turn,
]

let usdzEntityTypeList: [String: EntityType] =
    [
        "Kitten_Attack_Down": EntityType.independent,
        "Kitten_Attack_F": EntityType.independent,
        "Kitten_Attack_L": EntityType.independent,
        "Kitten_Attack_R": EntityType.independent,
        "Kitten_Attack_Series": EntityType.independent,
        "Kitten_Caress_idle": EntityType.independent,
        "Kitten_Caress_lie": EntityType.liebelly,
        "Kitten_Caress_sit": EntityType.sit,
        "Kitten_Die_L": EntityType.independent,
        "Kitten_Die_R": EntityType.independent,
        "Kitten_Drinking": EntityType.drink,
        "Kitten_EatDrink_end": EntityType.eatdrink_end,
        "Kitten_EatDrink_start": EntityType.eatdrink_start,
        "Kitten_Eating": EntityType.eat,
        "Kitten_Hit_B": EntityType.independent,
        "Kitten_Hit_F": EntityType.independent,
        "Kitten_Hit_M": EntityType.independent,
        "Kitten_Idle_1": EntityType.independent,
        "Kitten_Idle_2": EntityType.independent,
        "Kitten_Idle_3": EntityType.independent,
        "Kitten_Idle_4": EntityType.independent,
        "Kitten_Idle_5": EntityType.independent,
        "Kitten_Idle_6": EntityType.independent,
        "Kitten_Idle_7": EntityType.independent,
        "Kitten_Idle_8": EntityType.independent,
        "Kitten_JumpFw_RM": EntityType.jump_fw,
        "Kitten_JumpPlace_RM": EntityType.jump_place,
        "Kitten_JumpRun_RM": EntityType.jump_run,
        "Kitten_Lick": EntityType.independent,
        "Kitten_Lie_belly_end": EntityType.liebelly_end,
        "Kitten_Lie_belly_loop_1": EntityType.liebelly,
        "Kitten_Lie_belly_loop_2": EntityType.liebelly,
        "Kitten_Lie_belly_loop_3": EntityType.liebelly,
        "Kitten_Lie_belly_sleep_end": EntityType.liebelly_sleep_end,
        "Kitten_Lie_belly_sleep_start": EntityType.liebelly_sleep_start,
        "Kitten_Lie_belly_sleep": EntityType.liebelly_sleep,
        "Kitten_Lie_belly_start": EntityType.liebelly_start,
        "Kitten_Lie_side_end": EntityType.lieside_end,
        "Kitten_Lie_side_loop_1": EntityType.lieside,
        "Kitten_Lie_side_loop_2": EntityType.lieside,
        "Kitten_Lie_side_sleep_end": EntityType.lieside_sleep_end,
        "Kitten_Lie_side_sleep_start": EntityType.lieside_sleep_start,
        "Kitten_Lie_side_sleep": EntityType.lieside_sleep,
        "Kitten_Lie_side_start": EntityType.lieside_start,
        "Kitten_Run_F_RM": EntityType.run,
        "Kitten_RunFast_F_RM": EntityType.run_fast,
        "Kitten_Scratching": EntityType.independent,
        "Kitten_SharpenClaws_Horiz": EntityType.independent,
        "Kitten_SharpenClaws_Vert": EntityType.independent,
        "Kitten_Sit_end": EntityType.sit_end,
        "Kitten_Sit_loop_1": EntityType.sit,
        "Kitten_Sit_loop_2": EntityType.sit,
        "Kitten_Sit_loop_3": EntityType.sit,
        "Kitten_Sit_loop_4": EntityType.sit,
        "Kitten_Sit_start": EntityType.sit_start,
        "Kitten_Trans_LieBelly_Sit": EntityType.liebelly_to_sit,
        "Kitten_Trans_LieSide_Sit": EntityType.lieside_to_sit,
        "Kitten_Trans_Sit_LieBelly": EntityType.sit_to_liebelly,
        "Kitten_Trans_Sit_LieSide": EntityType.sit_to_lieside,
        "Kitten_Trot_F_RM": EntityType.trot,
        "Kitten_Turn_90_L": EntityType.turn,
        "Kitten_Turn_90_R": EntityType.turn,
        "Kitten_Turn_180_L": EntityType.turn,
        "Kitten_Turn_180_R": EntityType.turn,
        "Kitten_Walk_end": EntityType.walk_end,
        "Kitten_Walk_F_RM": EntityType.walk,
        "Kitten_Walk_start": EntityType.walk_start,
    ]

let entityTypeUsdzList: [EntityType: [String]] = [
    EntityType.independent: [
        "Kitten_Attack_Down",
        "Kitten_Attack_F",
        "Kitten_Attack_L",
        "Kitten_Attack_R",
        "Kitten_Attack_Series",
        "Kitten_Caress_idle",
        "Kitten_Die_L",
        "Kitten_Die_R",
        "Kitten_Hit_B",
        "Kitten_Hit_F",
        "Kitten_Hit_M",
        "Kitten_Idle_1",
        "Kitten_Idle_2",
        "Kitten_Idle_3",
        "Kitten_Idle_4",
        "Kitten_Idle_5",
        "Kitten_Idle_6",
        "Kitten_Idle_7",
        "Kitten_Idle_8",
        "Kitten_Lick",
        "Kitten_Scratching",
        "Kitten_SharpenClaws_Horiz",
        "Kitten_SharpenClaws_Vert",
    ],
    EntityType.walk: [
        "Kitten_Walk_F_RM",
    ],
    EntityType.walk_start: [
        "Kitten_Walk_start",
    ],
    EntityType.walk_end: [
        "Kitten_Walk_end",
    ],
    EntityType.run: [
        "Kitten_Run_F_RM",
    ],
    EntityType.run_fast: [
        "Kitten_RunFast_F_RM",
    ],
    EntityType.trot: [
        "Kitten_Trot_F_RM",
    ],
    EntityType.turn: [
        "Kitten_Turn_90_L",
        "Kitten_Turn_90_R",
        "Kitten_Turn_180_L",
        "Kitten_Turn_180_R",
    ],
    EntityType.sit_to_lieside: [
        "Kitten_Trans_Sit_LieSide",
    ],
    EntityType.sit_to_liebelly: [
        "Kitten_Trans_Sit_LieBelly",
    ],
    EntityType.lieside_to_sit: [
        "Kitten_Trans_LieSide_Sit",
    ],
    EntityType.liebelly_to_sit: [
        "Kitten_Trans_LieBelly_Sit",
    ],
    EntityType.sit: [
        "Kitten_Sit_loop_1",
        "Kitten_Sit_loop_2",
        "Kitten_Sit_loop_3",
        "Kitten_Sit_loop_4",
        "Kitten_Caress_sit",
    ],
    EntityType.sit_start: [
        "Kitten_Sit_start",
    ],
    EntityType.sit_end: [
        "Kitten_Sit_end",
    ],
    EntityType.lieside: [
        "Kitten_Lie_side_loop_1",
        "Kitten_Lie_side_loop_2",
    ],
    EntityType.lieside_start: [
        "Kitten_Lie_side_start",
    ],
    EntityType.lieside_end: [
        "Kitten_Lie_side_end",
    ],
    EntityType.lieside_sleep: [
        "Kitten_Lie_side_sleep",
    ],
    EntityType.lieside_sleep_start: [
        "Kitten_Lie_side_sleep_start",
    ],
    EntityType.lieside_sleep_end: [
        "Kitten_Lie_side_sleep_end",
    ],
    EntityType.liebelly: [
        "Kitten_Lie_belly_loop_1",
        "Kitten_Lie_belly_loop_2",
        "Kitten_Lie_belly_loop_3",
        "Kitten_Caress_lie",
    ],
    EntityType.liebelly_start: [
        "Kitten_Lie_belly_start",
    ],
    EntityType.liebelly_end: [
        "Kitten_Lie_belly_end",
    ],
    EntityType.liebelly_sleep: [
        "Kitten_Lie_belly_sleep",
    ],
    EntityType.liebelly_sleep_start: [
        "Kitten_Lie_belly_sleep_start",
    ],
    EntityType.liebelly_sleep_end: [
        "Kitten_Lie_belly_sleep_end",
    ],
    EntityType.jump_run: [
        "Kitten_JumpRun_RM",
    ],
    EntityType.jump_place: [
        "Kitten_JumpPlace_RM",
    ],
    EntityType.jump_fw: [
        "Kitten_JumpFw_RM",
    ],
    EntityType.eat: [
        "Kitten_Eating",
    ],
    EntityType.drink: [
        "Kitten_Drinking",
    ],
    EntityType.eatdrink_start: [
        "Kitten_EatDrink_start",
    ],
    EntityType.eatdrink_end: [
        "Kitten_EatDrink_end",
    ],
]

let nextEntityList: [EntityType: [EntityType: Int]] = [
    EntityType.independent: [
        EntityType.sit_start: 5,
        EntityType.lieside_start: 5,
        EntityType.liebelly_start: 5,
        EntityType.walk_start: 85,
    ],
    EntityType.walk: [
        EntityType.trot: 5,
        EntityType.run: 5,
        EntityType.walk_end: 3,
        EntityType.walk: 87,
    ],
    EntityType.walk_start: [
        EntityType.walk: 100,
    ],
    EntityType.walk_end: [
        EntityType.eatdrink_start: 2,
        EntityType.lieside_start: 4,
        EntityType.liebelly_start: 4,
        EntityType.turn: 10,
        EntityType.sit_start: 10,
        EntityType.independent: 70,
    ],
    EntityType.run: [
        EntityType.run_fast: 10,
        EntityType.trot: 20,
        EntityType.run: 50,
        EntityType.walk: 20,
    ],
    EntityType.run_fast: [
        EntityType.run_fast: 20,
        EntityType.run: 80,
    ],
    EntityType.trot: [
        EntityType.run: 10,
        EntityType.trot: 40,
        EntityType.walk: 50,
    ],
    EntityType.turn: [
        EntityType.walk_start: 100,
    ],
    EntityType.sit_to_lieside: [
        EntityType.lieside_sleep_start: 20,
        EntityType.lieside: 80,
    ],
    EntityType.sit_to_liebelly: [
        EntityType.liebelly_sleep_start: 20,
        EntityType.liebelly: 80,
    ],
    EntityType.lieside_to_sit: [
        EntityType.sit: 100,
    ],
    EntityType.liebelly_to_sit: [
        EntityType.sit: 100,
    ],
    EntityType.sit: [
        EntityType.sit_to_lieside: 10,
        EntityType.sit_to_liebelly: 10,
        EntityType.sit_end: 80,
    ],
    EntityType.sit_start: [
        EntityType.sit: 100,
    ],
    EntityType.sit_end: [
        EntityType.walk_start: 100,
    ],
    EntityType.lieside: [
        EntityType.lieside_sleep_start: 10,
        EntityType.lieside_to_sit: 10,
        EntityType.lieside_end: 80,
    ],
    EntityType.lieside_start: [
        EntityType.lieside: 100,
    ],
    EntityType.lieside_end: [
        EntityType.walk_start: 100,
    ],
    EntityType.lieside_sleep: [
        EntityType.lieside_sleep_end: 100,
    ],
    EntityType.lieside_sleep_start: [
        EntityType.lieside_sleep: 100,
    ],
    EntityType.lieside_sleep_end: [
        EntityType.lieside: 20,
        EntityType.lieside_end: 80,
    ],
    EntityType.liebelly: [
        EntityType.liebelly_sleep_start: 10,
        EntityType.liebelly_to_sit: 10,
        EntityType.liebelly_end: 80,
    ],
    EntityType.liebelly_start: [
        EntityType.liebelly: 100,
    ],
    EntityType.liebelly_end: [
        EntityType.walk_start: 100,
    ],
    EntityType.liebelly_sleep: [
        EntityType.lieside_sleep_end: 100,
    ],
    EntityType.liebelly_sleep_start: [
        EntityType.lieside_sleep: 100,
    ],
    EntityType.liebelly_sleep_end: [
        EntityType.liebelly: 20,
        EntityType.liebelly_end: 80,
    ],
    EntityType.jump_run: [
        EntityType.run: 100,
    ],
    EntityType.jump_place: [
        EntityType.walk_start: 100,
    ],
    EntityType.jump_fw: [
        EntityType.walk_start: 100,
    ],
    EntityType.eat: [
        EntityType.eat: 10,
        EntityType.eatdrink_end: 90,
    ],
    EntityType.drink: [
        EntityType.drink: 10,
        EntityType.eatdrink_end: 90,
    ],
    EntityType.eatdrink_start: [
        EntityType.eat: 50,
        EntityType.drink: 50,
    ],
    EntityType.eatdrink_end: [
        EntityType.walk_start: 100,
    ],
]

let catNameTextureList: [String: String] =
    [
        "Black"      : "black.png",
        "Grey"       : "grey.png",
        "Orange"     : "orange.png",
        "Tiger"      : "tiger.png",
        "White_Black": "white_black.png",
    ]

import RealityKit

enum EntityType {
    case unknown
    case independent
    case idle
    case walk          // Travel
    case walk_start    // Travel
    case walk_end
    case run           // Travel
    case trot          // Travel
    case turn90
    case turn180
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
    case jump_place
    case eat
    case drink
    case eatdrink_start
    case eatdrink_end
}

let canTurnList: [EntityType] = [
    EntityType.independent,
    EntityType.idle,
    EntityType.walk_end,
    EntityType.sit_end,
    EntityType.lieside_end,
    EntityType.liebelly_end,
    EntityType.jump_place,
    EntityType.eatdrink_end,
]

let idleUsdzList:[String] = [
    "Kitten_Idle_1",
    "Kitten_Idle_2",
    "Kitten_Idle_3",
    "Kitten_Idle_4",
    "Kitten_Idle_5",
    "Kitten_Idle_6",
    "Kitten_Idle_7",
    "Kitten_Idle_8",
]

let sampleNameUsdzList: [String: String] =
    [
        "Black"      : "black_idle",
        "Grey"       : "grey_idle",
        "Orange"     : "orange_idle",
        "Tiger"      : "tiger_idle",
        "White_Black": "white_black_idle",
    ]

let firstUsdzEntityTypeList: [String: EntityType] = [
    "Kitten_Idle_2": EntityType.idle,
    "Kitten_Idle_3": EntityType.idle,
    "Kitten_Idle_5": EntityType.idle,
    "Kitten_Idle_6": EntityType.idle,
    "Kitten_Idle_7": EntityType.idle,
]

let travelEntityTypeList: [EntityType] = [
    EntityType.walk,
    EntityType.walk_start,
    EntityType.run,
    EntityType.trot
]

let usdzEntityTypeList: [String: EntityType] =
    [
        "Kitten_Attack_Down": EntityType.independent,
        "Kitten_Attack_F": EntityType.independent,
        "Kitten_Attack_L": EntityType.independent,
        "Kitten_Attack_R": EntityType.independent,
        "Kitten_Attack_Series": EntityType.independent,
        "Kitten_Caress_idle": EntityType.idle,
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
        "Kitten_Idle_1": EntityType.idle,
        "Kitten_Idle_2": EntityType.idle,
        "Kitten_Idle_3": EntityType.idle,
        "Kitten_Idle_4": EntityType.idle,
        "Kitten_Idle_5": EntityType.idle,
        "Kitten_Idle_6": EntityType.idle,
        "Kitten_Idle_7": EntityType.idle,
        "Kitten_Idle_8": EntityType.idle,
        "Kitten_JumpPlace_RM": EntityType.jump_place,
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
        "Kitten_Turn_90_L": EntityType.turn90,
        "Kitten_Turn_90_R": EntityType.turn90,
        "Kitten_Turn_180_L": EntityType.turn180,
        "Kitten_Turn_180_R": EntityType.turn180,
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
        "Kitten_Die_L",
        "Kitten_Die_R",
        "Kitten_Hit_B",
        "Kitten_Hit_F",
        "Kitten_Hit_M",
        "Kitten_Lick",
        "Kitten_Scratching",
        "Kitten_SharpenClaws_Horiz",
        "Kitten_SharpenClaws_Vert",
    ],
    EntityType.idle: [
        "Kitten_Caress_idle",
        "Kitten_Idle_1",
        "Kitten_Idle_2",
        "Kitten_Idle_3",
        "Kitten_Idle_4",
        "Kitten_Idle_5",
        "Kitten_Idle_6",
        "Kitten_Idle_7",
        "Kitten_Idle_8",
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
    EntityType.trot: [
        "Kitten_Trot_F_RM",
    ],
    EntityType.turn90: [
        "Kitten_Turn_90_L",
        "Kitten_Turn_90_R",
    ],
    EntityType.turn180: [
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
    EntityType.jump_place: [
        "Kitten_JumpPlace_RM",
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
        EntityType.idle: 70,
        EntityType.sit_start: 5,
        EntityType.lieside_start: 5,
        EntityType.liebelly_start: 5,
        EntityType.turn90: 10,
        EntityType.walk_start: 5,
    ],
    EntityType.idle: [
        EntityType.idle: 60,
        EntityType.sit_start: 5,
        EntityType.lieside_start: 5,
        EntityType.liebelly_start: 5,
        EntityType.independent: 10,
        EntityType.turn90: 10,
        EntityType.walk_start: 5,
    ],
    EntityType.walk: [
        EntityType.trot: 2,
        EntityType.run: 0,
        EntityType.walk_end: 91,
        EntityType.walk: 5,
    ],
    EntityType.walk_start: [
        EntityType.walk: 100,
    ],
    EntityType.walk_end: [
        EntityType.eatdrink_start: 2,
        EntityType.lieside_start: 4,
        EntityType.liebelly_start: 4,
        EntityType.turn90: 10,
        EntityType.sit_start: 10,
        EntityType.independent: 20,
        EntityType.idle: 50,
    ],
    EntityType.run: [
        EntityType.trot: 0,
        EntityType.run: 0,
        EntityType.walk: 100,
    ],
    EntityType.trot: [
        EntityType.run: 0,
        EntityType.trot: 0,
        EntityType.walk: 100,
    ],
    EntityType.turn90: [
        EntityType.idle: 60,
        EntityType.sit_start: 5,
        EntityType.lieside_start: 5,
        EntityType.liebelly_start: 5,
        EntityType.independent: 20,
        EntityType.walk_start: 5,
    ],
    EntityType.turn180: [
        EntityType.idle: 60,
        EntityType.sit_start: 5,
        EntityType.lieside_start: 5,
        EntityType.liebelly_start: 5,
        EntityType.independent: 20,
        EntityType.walk_start: 5,
    ],
    EntityType.sit_to_lieside: [
        EntityType.lieside_sleep_start: 50,
        EntityType.lieside: 50,
    ],
    EntityType.sit_to_liebelly: [
        EntityType.liebelly_sleep_start: 50,
        EntityType.liebelly: 50,
    ],
    EntityType.lieside_to_sit: [
        EntityType.sit: 100,
    ],
    EntityType.liebelly_to_sit: [
        EntityType.sit: 100,
    ],
    EntityType.sit: [
        EntityType.sit_to_lieside: 15,
        EntityType.sit_to_liebelly: 15,
        EntityType.sit: 40,
        EntityType.sit_end: 30,
    ],
    EntityType.sit_start: [
        EntityType.sit: 100,
    ],
    EntityType.sit_end: [
        EntityType.idle: 70,
        EntityType.independent: 25,
        EntityType.walk_start: 5,
    ],
    EntityType.lieside: [
        EntityType.lieside_sleep_start: 30,
        EntityType.lieside: 20,
        EntityType.lieside_to_sit: 10,
        EntityType.lieside_end: 40,
    ],
    EntityType.lieside_start: [
        EntityType.lieside: 100,
    ],
    EntityType.lieside_end: [
        EntityType.idle: 70,
        EntityType.independent: 25,
        EntityType.walk_start: 5,
    ],
    EntityType.lieside_sleep: [
        EntityType.lieside_sleep_end: 100,
    ],
    EntityType.lieside_sleep_start: [
        EntityType.lieside_sleep: 100,
    ],
    EntityType.lieside_sleep_end: [
        EntityType.lieside: 50,
        EntityType.lieside_end: 50,
    ],
    EntityType.liebelly: [
        EntityType.liebelly_sleep_start: 30,
        EntityType.liebelly_to_sit: 10,
        EntityType.liebelly: 20,
        EntityType.liebelly_end: 40,
    ],
    EntityType.liebelly_start: [
        EntityType.liebelly: 100,
    ],
    EntityType.liebelly_end: [
        EntityType.idle: 70,
        EntityType.independent: 25,
        EntityType.walk_start: 5,
    ],
    EntityType.liebelly_sleep: [
        EntityType.lieside_sleep_end: 100,
    ],
    EntityType.liebelly_sleep_start: [
        EntityType.lieside_sleep: 100,
    ],
    EntityType.liebelly_sleep_end: [
        EntityType.liebelly: 50,
        EntityType.liebelly_end: 50,
    ],
    EntityType.jump_place: [
        EntityType.idle: 70,
        EntityType.independent: 25,
        EntityType.walk_start: 5,
    ],
    EntityType.eat: [
        EntityType.eat: 50,
        EntityType.eatdrink_end: 50,
    ],
    EntityType.drink: [
        EntityType.drink: 50,
        EntityType.eatdrink_end: 50,
    ],
    EntityType.eatdrink_start: [
        EntityType.eat: 50,
        EntityType.drink: 50,
    ],
    EntityType.eatdrink_end: [
        EntityType.idle: 70,
        EntityType.independent: 25,
        EntityType.walk_start: 5,
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

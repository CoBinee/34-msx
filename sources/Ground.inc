; Ground.inc : 地面
;


; マクロの定義
;

; 地面
GROUND_STATE                    =   0x00
GROUND_FLAG                     =   0x01
GROUND_LENGTH                   =   0x02

; 状態
GROUND_STATE_NULL               =   0x00
GROUND_STATE_PLAY               =   0x10

; フラグ
GROUND_FLAG_NULL                =   0x00
GROUND_FLAG_PRINT_VIEW_BIT      =   0x00
GROUND_FLAG_PRINT_VIEW          =   (1 << GROUND_FLAG_PRINT_VIEW_BIT)

; ネーム
GROUND_NAME_SIZE_X              =   0x80
GROUND_NAME_SIZE_Y              =   0x80

; セル
GROUND_CELL_NULL                =   0x00
GROUND_CELL_TYPE_NULL           =   0x00
GROUND_CELL_TYPE_MASK           =   0xfc
GROUND_CELL_TYPE_SPACE          =   0x88
GROUND_CELL_TYPE_CORE_CLOSE     =   0x50
GROUND_CELL_TYPE_CORE_OPEN      =   0x70
GROUND_CELL_TYPE_CORE_DESTROY   =   0x74
GROUND_CELL_TYPE_TERMINAL_CLOSE =   0x40
GROUND_CELL_TYPE_TERMINAL_OPEN  =   0x60
GROUND_CELL_TYPE_BASE_CLOSE     =   0x58
GROUND_CELL_TYPE_BASE_OPEN      =   0x78
GROUND_CELL_TYPE_BASE_DESTROY   =   0x7c
GROUND_CELL_TYPE_TANK_OPEN      =   0x80
GROUND_CELL_TYPE_TANK_DESTROY   =   0x84
GROUND_CELL_TYPE_EDGE           =   0xb0
GROUND_CELL_TYPE_PATH_VERTICAL  =   0xf0
GROUND_CELL_TYPE_PATH_HORIZON   =   0xf4
GROUND_CELL_LIFE_NULL           =   0x00
GROUND_CELL_LIFE_MASK           =   0x03
GROUND_CELL_LIFE_MAXIMUM        =   0x03
GROUND_CELL_LIFE_BASE           =   0x01
GROUND_CELL_SIZE_X              =   0x40
GROUND_CELL_SIZE_Y              =   0x40

; エリア
GROUND_AREA_NULL                =   0x00
GROUND_AREA_TYPE_NULL           =   0x00
GROUND_AREA_TYPE_MASK           =   0x0f
GROUND_AREA_TYPE_BACK           =   0x00
GROUND_AREA_TYPE_SMALL_0        =   0x01
GROUND_AREA_TYPE_SMALL_1        =   0x02
GROUND_AREA_TYPE_SMALL_2        =   0x03
GROUND_AREA_TYPE_MEDIUM_0       =   0x04
GROUND_AREA_TYPE_MEDIUM_1       =   0x05
GROUND_AREA_TYPE_MEDIUM_2       =   0x06
GROUND_AREA_TYPE_LARGE_0        =   0x07
GROUND_AREA_TYPE_LARGE_1        =   0x08
GROUND_AREA_TYPE_LARGE_2        =   0x09
GROUND_AREA_TYPE_LARGE_3        =   0x0a
GROUND_AREA_EVENT_NULL          =   0x00
GROUND_AREA_EVENT_MASK          =   0xf0
GROUND_AREA_EVENT_START         =   0x10
GROUND_AREA_SIZE_X              =   0x08
GROUND_AREA_SIZE_Y              =   0x08
GROUND_AREA_CELL_SIZE_X         =   (GROUND_CELL_SIZE_X / GROUND_AREA_SIZE_X)
GROUND_AREA_CELL_SIZE_Y         =   (GROUND_CELL_SIZE_Y / GROUND_AREA_SIZE_Y)

; コア
GROUND_CORE_CELL_L              =   0x00
GROUND_CORE_CELL_H              =   0x01
GROUND_CORE_LIFE                =   0x02
GROUND_CORE_FRAME               =   0x03
GROUND_CORE_LENGTH              =   0x04

; コア／セル
GROUND_CORE_CELL_NULL           =   0x00

; コア／ライフ
GROUND_CORE_LIFE_NULL           =   0x00
GROUND_CORE_LIFE_MAXIMUM        =   0x08

; コア／フレーム
GOUND_CORE_FRAME_NULL           =   0x00

; 爆発
GROUND_BOMB_TYPE                =   0x00
GROUND_BOMB_POSITION_X          =   0x01
GROUND_BOMB_POSITION_Y          =   0x02
GROUND_BOMB_ANIMATION           =   0x03
GROUND_BOMB_LENGTH              =   0x04
GROUND_BOMB_ENTRY               =   0x04

; 爆発／種類
GROUND_BOMB_TYPE_NULL           =   0x00
GROUND_BOMB_TYPE_HIT            =   0x60
GROUND_BOMB_TYPE_BOMB           =   0x70

; 爆発／位置
GROUND_BOMB_POSITION_NULL       =   0x00

; 爆発／アニメーション
GROUND_BOMB_ANIMATION_NULL      =   0x00
GROUND_BOMB_ANIMATION_LENGTH    =   0x08

; 爆発／スプライト
GROUND_BOMB_SPRITE_X            =   (-0x08)
GROUND_BOMB_SPRITE_Y            =   (-0x08 - 0x01)
GROUND_BOMB_SPRITE_NUMBER       =   0x60
GROUND_BOMB_SPRITE_COLOR        =   VDP_COLOR_GRAY

; 外部関数宣言
;

    .globl  _GroundInitialize
    .globl  _GroundUpdate
    .globl  _GroundRender
    .globl  _GroundBuild
    .globl  _GroundIsCore
    .globl  _GroundGetStartPosition
    .globl  _GroundHit
    .globl  _GroundSetPrintView

; 外部変数宣言
;

    .globl  _ground

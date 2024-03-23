; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER              =   0x00
GAME_SPRITE_TARGET              =   0x2c
GAME_SPRITE_SHOT                =   0x30
GAME_SPRITE_ENEMY               =   0x0c
GAME_SPRITE_GROUND              =   0x70

; ゲーム
GAME_STATE                      =   0x00
GAME_FLAG                       =   0x01
GAME_FRAME                      =   0x02
GAME_COLOR                      =   0x03
GAME_LENGTH                     =   0x04

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_BUILD                =   0x10
GAME_STATE_START                =   0x20
GAME_STATE_PLAY                 =   0x30
GAME_STATE_OVER                 =   0x40
GAME_STATE_CLEAR                =   0x50
GAME_STATE_RESULT               =   0x60

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_TOP_BIT               =   0x00
GAME_FLAG_TOP                   =   (1 << GAME_FLAG_TOP_BIT)

; フレーム
GAME_FRAME_NULL                 =   0x00

; 色
GAME_COLOR_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;

    .globl  _game

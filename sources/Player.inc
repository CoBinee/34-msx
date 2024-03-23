; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X               =   0x02
PLAYER_POSITION_Y               =   0x03
PLAYER_DIRECTION                =   0x04
PLAYER_ANIMATION                =   0x05
PLAYER_PRINT_X                  =   0x06
PLAYER_PRINT_Y                  =   0x07
PLAYER_SPRITE_SHIP_L            =   0x08
PLAYER_SPRITE_SHIP_H            =   0x09
PLAYER_SPRITE_TARGET_L          =   0x0a
PLAYER_SPRITE_TARGET_H          =   0x0b
PLAYER_POWER_1000               =   0x0c
PLAYER_POWER_0100               =   0x0d
PLAYER_POWER_0010               =   0x0e
PLAYER_POWER_0001               =   0x0f
PLAYER_COST                     =   0x10
PLAYER_DAMAGE                   =   0x11
PLAYER_LENGTH                   =   0x12

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_STAY               =   0x10
PLAYER_STATE_PLAY               =   0x20
PLAYER_STATE_BOMB               =   0x30
PLAYER_STATE_LEAVE              =   0x40

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_BOMB_BIT            =   0x00
PLAYER_FLAG_BOMB                =   (1 << PLAYER_FLAG_BOMB_BIT)
PLAYER_FLAG_LEAVE_BIT           =   0x01
PLAYER_FLAG_LEAVE               =   (1 << PLAYER_FLAG_LEAVE_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00

; 向き
PLAYER_DIRECTION_NULL           =   0xff

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00
PLAYER_ANIMATION_BOMB           =   0x08

; 描画位置
PLAYER_PRINT_NULL               =   0x00

; スプライト
PLAYER_SPRITE_NULL              =   0x00

; パワー
PLAYER_POWER_NULL               =   0x00
PLAYER_POWER_LENGTH             =   0x04

; コスト
PLAYER_COST_NULL                =   0x00
PLAYER_COST_LENGTH              =   0x1e

; ダメージ
PLAYER_DAMAGE_NULL              =   0x00
PLAYER_DAMAGE_LENGTH            =   0x18

; 大きさ
PLAYER_SIZE_R                   =   0x04

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerIsLive
    .globl  _PlayerSetPlay
    .globl  _PlayerSetBomb
    .globl  _PlayerSetLeave
    .globl  _PlayerDamage

; 外部変数宣言
;

    .globl  _player

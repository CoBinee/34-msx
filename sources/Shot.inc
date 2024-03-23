; Shot.inc : ショット
;


; マクロの定義
;

; ショット
SHOT_TYPE                       =   0x00
SHOT_STATE                      =   0x01
SHOT_POSITION_X                 =   0x02
SHOT_POSITION_Y                 =   0x03
SHOT_DIRECTION                  =   0x04
SHOT_ANIMATION                  =   0x05
SHOT_SPRITE_L                   =   0x06
SHOT_SPRITE_H                   =   0x07
SHOT_LENGTH                     =   0x08

; 種類
SHOT_TYPE_NULL                  =   0x00
SHOT_TYPE_AIR                   =   0x01
SHOT_TYPE_GROUND                =   0x02

; 状態
SHOT_STATE_NULL                 =   0x00

; 位置
SHOT_POSITION_NULL              =   0x00

; 向き
SHOT_DIRECTION_NULL             =   0x00

; アニメーション
SHOT_ANIMATION_NULL             =   0x00
SHOT_ANIMATION_GROUND_LENGTH    =   0x04

; スプライト
SHOT_SPRITE_NULL                =   0x00

; 登録
SHOT_ENTRY                      =   0x08

; 大きさ
SHOT_SIZE_R                     =   0x08

; 外部関数宣言
;

    .globl  _ShotInitialize
    .globl  _ShotUpdate
    .globl  _ShotRender
    .globl  _ShotFireAir
    .globl  _ShotFireGround

; 外部変数宣言
;

    .globl  _shot

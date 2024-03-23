; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_POSITION_X_L              =   0x03
ENEMY_POSITION_X_H              =   0x04
ENEMY_POSITION_Y_L              =   0x05
ENEMY_POSITION_Y_H              =   0x06
ENEMY_DIRECTION                 =   0x07
ENEMY_SPEED_X_L                 =   0x08
ENEMY_SPEED_X_H                 =   0x09
ENEMY_SPEED_Y_L                 =   0x0a
ENEMY_SPEED_Y_H                 =   0x0b
ENEMY_ANIMATION                 =   0x0c
ENEMY_SPRITE_L                  =   0x0d
ENEMY_SPRITE_H                  =   0x0e
ENEMY_HIDDEN                    =   0x0f
ENEMY_PARAM_0                   =   0x10
ENEMY_PARAM_1                   =   0x11
ENEMY_PARAM_2                   =   0x12
ENEMY_PARAM_3                   =   0x13
ENEMY_LENGTH                    =   0x14

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_BOMB                 =   0x01
ENEMY_TYPE_CIRCLE               =   0x02
ENEMY_TYPE_TRIANGLE             =   0x03
ENEMY_TYPE_SQUARE               =   0x04

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_SE_BIT               =   0x07
ENEMY_FLAG_SE                   =   (1 << ENEMY_FLAG_SE_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 向き
ENEMY_DIRECTION_NULL            =   0x00

; 速度
ENEMY_SPEED_NULL                =   0x00

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00

; スプライト
ENEMY_SPRITE_NULL               =   0x00

; 隠す
ENEMY_HIDDEN_NULL               =   0x00

; パラメータ
ENEMY_PARAM_NULL                =   0x00

; 登録
ENEMY_ENTRY_REST                =   0x00
ENEMY_ENTRY_FRAME               =   0x01
ENEMY_ENTRY_GROUP               =   0x02
ENEMY_ENTRY_COUNT               =   0x03
ENEMY_ENTRY_DIRECTION           =   0x04
ENEMY_ENTRY_INTERVAL            =   0x05
ENEMY_ENTRY_LENGTH              =   0x06
ENEMY_ENTRY                     =   0x08

; 登録／残りの数
ENEMY_ENTRY_REST_NULL           =   0x00

; 登録／フレーム
ENEMY_ENTRY_FRAME_NULL          =   0x00

; 登録／グループ
ENEMY_ENTRY_GROUP_NULL          =   0x00

; 登録／カウント
ENEMY_ENTRY_COUNT_NULL          =   0x00

; 登録／向き
ENEMY_ENTRY_DIRECTION_NULL      =   0x00

; 登録／インターバル
ENEMY_ENTRY_INTERVAL_NULL       =   0x00

; 大きさ
ENEMY_SIZE_R                    =   0x08

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyEntry
    .globl  _EnemyKill
    .globl  _EnemyScroll
    .globl  _EnemyMove
    .globl  _EnemyAnimation
    .globl  _EnemySetBomb

; 外部変数宣言
;

    .globl  _enemy

; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_COLOR_TABLE                 =   0x2000
APP_PATTERN_NAME_TABLE          =   0x1800
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; アプリケーション
APP_STATE                       =   0x00
APP_FRAME                       =   0x01
APP_SCORE_1000                  =   0x02
APP_SCORE_0100                  =   0x03
APP_SCORE_0010                  =   0x04
APP_SCORE_0001                  =   0x05
APP_DEBUG                       =   0x08
APP_DEBUG_0                     =   0x08
APP_DEBUG_1                     =   0x09
APP_DEBUG_2                     =   0x0a
APP_DEBUG_3                     =   0x0b
APP_DEBUG_4                     =   0x0c
APP_DEBUG_5                     =   0x0d
APP_DEBUG_6                     =   0x0e
APP_DEBUG_7                     =   0x0f
APP_LENGTH                      =   0x10

; 状態
APP_STATE_NULL                  =   0x00
APP_STATE_TITLE_INITIALIZE      =   0x01
APP_STATE_TITLE_UPDATE          =   0x02
APP_STATE_GAME_INITIALIZE       =   0x03
APP_STATE_GAME_UPDATE           =   0x04

; フレーム
APP_FRAME_NULL                  =   0x00

; スコア
APP_SCORE_NULL                  =   0x00
APP_SCORE_LENGTH                =   0x04

; デバッグ
APP_DEBUG_NULL                  =   0x00
APP_DEBUG_LENGTH                =   0x08

; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppNull
    .globl  _AppUncompressPatternName

; 外部変数宣言
;

    .globl  _app
    
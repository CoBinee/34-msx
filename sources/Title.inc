; Title.inc : タイトル
;


; マクロの定義
;

; スプライト
TITLE_SPRITE_NULL               =   0x00

; タイトル
TITLE_STATE                     =   0x00
TITLE_FLAG                      =   0x01
TITLE_FRAME                     =   0x02
TITLE_SCROLL                    =   0x03
TITLE_BLINK                     =   0x04
TITLE_LENGTH                    =   0x05

; 状態
TITLE_STATE_NULL                =   0x00
TITLE_STATE_LOOP                =   0x10
TITLE_STATE_EXIT                =   0x20

; フラグ
TITLE_FLAG_NULL                 =   0x00

; フレーム
TITLE_FRAME_NULL                =   0x00

; スクロール
TITLE_SCROLL_NULL               =   0x00

; 点滅
TITLE_BLINK_NULL                =   0x00

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;

    .globl  _title

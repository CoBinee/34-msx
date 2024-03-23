; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; タイトルの初期化
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

    ; 背景の作成
    call    TitleBuildBack
    
    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x00c0) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)

    ; サウンドの停止
    call    _SoundStop

    ; 状態の設定
    ld      a, #TITLE_STATE_LOOP
    ld      (_title + TITLE_STATE), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_title + TITLE_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを待機する
;
TitleLoop:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; スクロールの設定
    xor     a
    ld      (_title + TITLE_SCROLL), a

    ; 点滅の設定
    xor     a
    ld      (_title + TITLE_BLINK), a

    ; スコアの描画
    call    TitlePrintScore

    ; OPLL の描画
    call    TitlePrintOpll

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; スクロールの更新
    call    TitleScrollLogo

    ; 点滅の更新
    ld      hl, #(_title + TITLE_BLINK)
    inc     (hl)

    ; SPACE の入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 10$

    ; 状態の更新
    ld      a, #TITLE_STATE_EXIT
    ld      (_title + TITLE_STATE), a
10$:

    ; ロゴの描画
    call    TitlePrintLogo

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; タイトルから抜ける
;
TitleExit:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 点滅の設定
    xor     a
    ld      (_title + TITLE_BLINK), a

    ; フレームの設定
    ld      a, #0x30
    ld      (_title + TITLE_FRAME), a

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; スクロールの更新
    call    TitleScrollLogo

    ; 点滅の更新
    ld      hl, #(_title + TITLE_BLINK)
    ld      a, (hl)
    add     a, #0x08
    ld      (hl), a

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 10$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
10$:

    ; ロゴの描画
    call    TitlePrintLogo

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; 背景を作成する
;
TitleBuildBack:

    ; レジスタの保存

    ; クリア
    ld      hl, #(titleBackPatternName + 0x0000)
    ld      de, #(titleBackPatternName + 0x0001)
    ld      bc, #(0x0200 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 星（小）をちりばめる
    ld      de, #titleBackPatternName
    ld      b, #0x20
10$:
    call    _SystemGetRandom
    and     #0xf0
    ld      h, #0x00
    add     a, a
    rl      h
    ld      l, a
    add     hl, de
    ld      (hl), #0xb8
    inc     de
    djnz    10$

    ; 星（中）をちりばめる
    ld      de, #titleBackPatternName
    ld      b, #0x10
20$:
    call    _SystemGetRandom
    and     #0xf0
    ld      h, #0x00
    add     a, a
    rl      h
    ld      l, a
    call    _SystemGetRandom
    and     #0x01
    add     a, l
    ld      l, a
    add     hl, de
    ld      (hl), #0xb9
    inc     de
    inc     de
    djnz    20$

    ; 星（大）をちりばめる
    ld      de, #titleBackPatternName
    ld      b, #0x08
30$:
    call    _SystemGetRandom
    and     #0xf0
    ld      h, #0x00
    add     a, a
    rl      h
    ld      l, a
    call    _SystemGetRandom
    and     #0x03
    add     a, l
    ld      l, a
    add     hl, de
    ld      (hl), #0xba
    inc     de
    inc     de
    inc     de
    inc     de
    djnz    30$

    ; レジスタの復帰

    ; 終了
    ret

; ロゴをスクロールさせる
;
TitleScrollLogo:

    ; レジスタの保存

    ; スクロールの更新
    ld      hl, #(_title + TITLE_SCROLL)
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

; ロゴを描画する
;
TitlePrintLogo:

    ; レジスタの保存

    ; 背景の描画
    ld      hl, #titleBackPatternName
    ld      de, #(_patternName + 0x0060)
    ld      a, (_title + TITLE_SCROLL)
    and     #0x1f
    jr      nz, 10$
    ld      bc, #0x0200
    ldir
    jr      19$
10$:
    ld      c, a
    ld      b, #0x10
11$:
    push    bc
    ld      b, #0x00
    push    hl
    push    bc
    push    hl
    add     hl, bc
    ld      a, #0x20
    sub     c
    ld      c, a
    ldir
    pop     hl
    pop     bc
    ldir
    pop     hl
    ld      c, #0x20
    add     hl, bc
    pop     bc
    djnz    11$
19$:

    ; ロゴの描画
    ld      a, (_title + TITLE_SCROLL)
    cp      #0x80
    jr      nc, 210$
200$:
    ld      hl, #titleLogoPatternName_0
    sub     #0x20
    jr      c, 201$
    ld      c, a
    ld      b, #0x00
    add     hl, bc
201$:
    push    hl
    ld      hl, #(_patternName + 0x0080)
    ld      a, (_title + TITLE_SCROLL)
    sub     #0x20
    jr      nc, 202$
    neg
    ld      c, a
    ld      b, #0x00
    add     hl, bc
202$:
    ex      de, hl
    pop     hl
    ld      c, #0x20
    ld      a, (_title + TITLE_SCROLL)
    cp      #0x20
    jr      nc, 203$
    ld      c, a
    jr      204$
203$:
    sub     #0x22
    jr      c, 204$
    neg
    add     a, #0x20
    ld      c, a
204$:
    ld      a, c
    or      a
    jr      z, 209$
    cp      #(0x20 + 0x01)
    jr      nc, 209$
    ld      b, #0x0e
205$:
    push    bc
    push    hl
    push    de
    ld      b, c
206$:
    ld      a, (hl)
    or      a
    jr      z, 207$
    ld      (de), a
207$:
    inc     hl
    inc     de
    djnz    206$
    pop     hl ; de
    ld      bc, #0x0020
    add     hl, bc
    ex      de, hl
    pop     hl
    ld      bc, #0x0022
    add     hl, bc
    pop     bc
    djnz    205$
209$:
    jr      290$
210$:
    cp      #0xf0
    jr      nc, 219$
    ld      hl, #titleLogoPatternName_1
    ld      de, #(_patternName + 0x014d)
    ld      bc, #0x0006
    ldir
    ld      de, #(_patternName + 0x016d)
    ld      bc, #0x0006
    ldir
219$:
;   jr      290$
290$:

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR を描画する
;
TitlePrintHitSpaceBar:

    ; レジスタの保存

    ; パターンネームの描画
    ld      a, (_title + TITLE_BLINK)
    and     #0x10
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleHitSpaceBarPatternName
    add     hl, de
    ld      de, #(_patternName + 0x00288)
    ld      bc, #0x0010
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; スコアを描画する
;
TitlePrintScore:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleScorePatternName
    ld      de, #(_patternName + 0x002c)
    ld      bc, #0x0003
    ldir
    ld      hl, #(_app + APP_SCORE_1000)
    inc     de
    ld      b, #(APP_SCORE_LENGTH - 0x01)
10$:
    ld      a, (hl)
    or      a
    jr      nz, 11$
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$
11$:
    inc     b
12$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    12$

    ; レジスタの復帰

    ; 終了
    ret

; OPLL を描画する
;
TitlePrintOpll:

    ; レジスタの保存

    ; パターンネームの描画
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 19$
    ld      hl, #(_patternName + 0x02a1)
    ld      a, #0x50
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
;   inc     hl
    ld      hl, #(_patternName + 0x02c1)
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
;   inc     hl
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
titleProc:
    
    .dw     TitleNull
    .dw     TitleLoop
    .dw     TitleExit

; タイトルの初期値
;
titleDefault:

    .db     TITLE_STATE_NULL
    .db     TITLE_FLAG_NULL
    .db     TITLE_FRAME_NULL
    .db     TITLE_SCROLL_NULL
    .db     TITLE_BLINK_NULL

; ロゴ
;
titleLogoPatternName_0:

    .db     0x00, 0x80, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0x91, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x91, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x91, 0x00
    .db     0x80, 0x88, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0x99, 0x91, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x88, 0x99, 0x91, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x88, 0x99, 0x91
    .db     0x90, 0x98, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0
    .db     0x00, 0x90, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa8, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0
    .db     0x00, 0x80, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb2, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa9, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb2, 0xb0, 0xb0, 0xa0
    .db     0x80, 0x88, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xa0
    .db     0x90, 0x98, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0x98, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xa0
    .db     0x00, 0x90, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa8, 0xb0, 0xb0, 0xa0, 0x00, 0x80, 0xb0, 0xb0, 0x91, 0x00, 0x00, 0x90, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa8, 0xb0, 0xb0, 0xa0
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0, 0x00, 0xb0, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0
    .db     0x00, 0x80, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb1, 0xb2, 0xb0, 0xb0, 0xa0, 0x00, 0xb0, 0xb0, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0
    .db     0x80, 0x88, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xa0, 0x00, 0x90, 0xa8, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0xb0, 0xb0, 0xa0
    .db     0x90, 0x98, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb3, 0xa1, 0x00, 0x80, 0xb2, 0xb0, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0x98, 0xb3, 0xa1
    .db     0x00, 0x90, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa1, 0x00, 0x00, 0x90, 0xa0, 0xa0, 0xa1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0xa1, 0x00

titleLogoPatternName_1:

    .db     0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5
    .db     0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb

; HIT SPACE BAR
;
titleHitSpaceBarPatternName:

    .db     0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; スコア
;
titleScorePatternName:

    .db     0x34, 0x2f, 0x30


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::
    
    .ds     TITLE_LENGTH

; 背景
;
titleBackPatternName:

    .ds     0x0020 * 0x0010

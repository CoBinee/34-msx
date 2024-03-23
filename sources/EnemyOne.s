; EnemyOne.s : それぞれのエネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Camera.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"
    .include    "EnemyOne.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; サークル
;
_EnemyCircle::

    ; レジスタの保存

    ; ix < エネミー

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 状態の更新
    inc     ENEMY_STATE(ix)
09$:

    ; 待機
    ld      a, ENEMY_HIDDEN(ix)
    or      a
    jr      z, 10$
    dec     ENEMY_HIDDEN(ix)
    jr      90$
10$:

    ; 速度の設定
    ld      bc, (_player + PLAYER_PRINT_X)
200$:
    ld      l, ENEMY_SPEED_X_L(ix)
    ld      h, ENEMY_SPEED_X_H(ix)
    ld      de, #0x0010
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      c
    jr      z, 210$
    jr      nc, 201$
    or      a
    adc     hl, de
    jp      m, 209$
    ld      a, h
    cp      #0x04
    jr      c, 209$
    ld      hl, #0x0400
    jr      209$
201$:
    or      a
    sbc     hl, de
    jp      p, 209$
    ld      a, h
    cp      #-0x04
    jr      nc, 209$
    ld      hl, #-0x0400
;   jr      209$
209$:
    ld      ENEMY_SPEED_X_L(ix), l
    ld      ENEMY_SPEED_X_H(ix), h
210$:
    ld      l, ENEMY_SPEED_Y_L(ix)
    ld      h, ENEMY_SPEED_Y_H(ix)
;   ld      de, #0x0010
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      b
    jr      z, 290$
    jr      nc, 211$
    or      a
    adc     hl, de
    jp      m, 219$
    ld      a, h
    cp      #0x04
    jr      c, 219$
    ld      hl, #0x0400
    jr      219$
211$:
    or      a
    sbc     hl, de
    jp      p, 219$
    ld      a, h
    cp      #-0x04
    jr      nc, 219$
    ld      hl, #-0x0400
;   jr      219$
219$:
    ld      ENEMY_SPEED_Y_L(ix), l
    ld      ENEMY_SPEED_Y_H(ix), h
290$:

    ; スクロール
    call    _EnemyScroll

    ; 移動
    call    _EnemyMove

    ; アニメーションの更新
    ld      hl, #enemyCircleSprite
    call    _EnemyAnimation

    ; サークルの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; トライアングル
;
_EnemyTriangle::

    ; レジスタの保存

    ; ix < エネミー

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_PARAM_0 : 移動時間
    ld      ENEMY_PARAM_0(ix), #0x00

    ; 状態の更新
    inc     ENEMY_STATE(ix)
09$:

    ; 待機
    ld      a, ENEMY_HIDDEN(ix)
    or      a
    jr      z, 10$
    dec     ENEMY_HIDDEN(ix)
    jr      90$
10$:

    ; 速度の設定
    ld      a, ENEMY_PARAM_0(ix)
    or      a
    jr      nz, 29$
    ld      hl, #enemyTriangleSpeedForward
    bit     #ENEMY_TRIANGLE_FLAG_TURN_BIT, ENEMY_FLAG(ix)
    jr      z, 20$
    ld      hl, #enemyTriangleSpeedLeft
    call    _SystemGetRandom
    and     #0x10
    jr      z, 20$
    ld      hl, #enemyTriangleSpeedRight
20$:
    ld      a, ENEMY_DIRECTION(ix)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_SPEED_X_L(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_SPEED_X_H(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_SPEED_Y_L(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_SPEED_Y_H(ix), a
 ;  inc     hl
29$:

    ; スクロール
    call    _EnemyScroll

    ; 移動
    call    _EnemyMove

    ; アニメーションの更新
    ld      hl, #enemyTriangleSprite
    call    _EnemyAnimation

    ; 移動時間の更新
    inc     ENEMY_PARAM_0(ix)
    ld      a, ENEMY_PARAM_0(ix)
    cp      #0x10
    jr      c, 39$
    ld      a, ENEMY_FLAG(ix)
    xor     #ENEMY_TRIANGLE_FLAG_TURN
    ld      ENEMY_FLAG(ix), a
    ld      ENEMY_PARAM_0(ix), #0x00
39$:

    ; トライアングルの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; スクエア
;
_EnemySquare::

    ; レジスタの保存

    ; ix < エネミー

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      a, ENEMY_DIRECTION(ix)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySquareSpeed
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_SPEED_X_L(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_SPEED_X_H(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_SPEED_Y_L(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_SPEED_Y_H(ix), a
 ;  inc     hl

    ; フラグの設定
    ld      de, (_player + PLAYER_PRINT_X)
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      e
    jr      c, 00$
    set     #ENEMY_SQUARE_FLAG_X_BIT, ENEMY_FLAG(ix)
00$:
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      d
    jr      c, 01$
    set     #ENEMY_SQUARE_FLAG_Y_BIT, ENEMY_FLAG(ix)
01$:

    ; 状態の更新
    inc     ENEMY_STATE(ix)
09$:

    ; 待機
    ld      a, ENEMY_HIDDEN(ix)
    or      a
    jr      z, 10$
    dec     ENEMY_HIDDEN(ix)
    jp      90$
10$:

    ; 方向別の移動
200$:
    bit     #ENEMY_SQUARE_FLAG_STRAIGHT_BIT, ENEMY_FLAG(ix)
    jr      nz, 290$
    ld      de, (_player + PLAYER_PRINT_X)
    ld      a, ENEMY_DIRECTION(ix)
    cp      #CAMERA_DIRECTION_LEFT
    jr      nc, 210$
    ld      l, ENEMY_SPEED_X_L(ix)
    ld      h, ENEMY_SPEED_X_H(ix)
    ld      c, e
    ld      a, ENEMY_POSITION_X_H(ix)
    bit     #ENEMY_SQUARE_FLAG_X_BIT, ENEMY_FLAG(ix)
    jr      nz, 201$
    call    220$
    jr      209$
201$:
    call    221$
;   jr      209$
209$:
    ld      ENEMY_SPEED_X_L(ix), l
    ld      ENEMY_SPEED_X_H(ix), h
    jr      290$
210$:
    ld      l, ENEMY_SPEED_Y_L(ix)
    ld      h, ENEMY_SPEED_Y_H(ix)
    ld      c, d
    ld      a, ENEMY_POSITION_Y_H(ix)
    bit     #ENEMY_SQUARE_FLAG_Y_BIT, ENEMY_FLAG(ix)
    jr      nz, 211$
    call    220$
    jr      219$
211$:
    call    221$
;   jr      219$
219$:
    ld      ENEMY_SPEED_Y_L(ix), l
    ld      ENEMY_SPEED_Y_H(ix), h
    jr      290$
220$:
    ld      de, #0x0010
    cp      c
    jr      nc, 229$
    or      a
    adc     hl, de
    jp      m, 229$
    ld      a, h
    cp      #0x02
    jr      c, 229$
    ld      hl, #0x0200
    jr      229$
221$:
    ld      de, #0x0010
    cp      c
    jr      c, 229$
    or      a
    sbc     hl, de
    jp      p, 229$
    ld      a, h
    cp      #-0x02
    jr      nc, 229$
    ld      hl, #-0x0200
;   jr      229$
229$:
    ret
290$:

    ; スクロール
    call    _EnemyScroll

    ; 移動
    call    _EnemyMove

    ; アニメーションの更新
    ld      hl, #enemySquareSprite
    call    _EnemyAnimation

    ; スクエアの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; サークル
;
_enemyCircleDefault::

    .db     ENEMY_TYPE_CIRCLE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_NULL
    .dw     ENEMY_SPEED_NULL
    .dw     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .dw     ENEMY_SPRITE_NULL
    .db     ENEMY_HIDDEN_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyCircleSprite:

    .db     -0x08 - 0x01, -0x08, 0x80, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x84, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x88, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x8c, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x90, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x94, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x98, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x9c, VDP_COLOR_LIGHT_GREEN

; トライアングル
;
_enemyTriangleDefault::

    .db     ENEMY_TYPE_TRIANGLE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_NULL
    .dw     ENEMY_SPEED_NULL
    .dw     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .dw     ENEMY_SPRITE_NULL
    .db     ENEMY_HIDDEN_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyTriangleSpeedForward:

    .dw      0x0000,  0x0000
    .dw      0x0000, -0x0200
    .dw      0x0000,  0x0200
    .dw     -0x0200,  0x0000
    .dw      0x0200,  0x0000
    .dw     -0x0180, -0x0180
    .dw      0x0180, -0x0180
    .dw     -0x0180,  0x0180
    .dw      0x0180,  0x0180

enemyTriangleSpeedLeft:

    .dw      0x0000,  0x0000
    .dw     -0x0200,  0x0000
    .dw      0x0200,  0x0000
    .dw      0x0000,  0x0200
    .dw      0x0000, -0x0200
    .dw     -0x0180,  0x0180
    .dw     -0x0180, -0x0180
    .dw      0x0180,  0x0180    
    .dw      0x0180, -0x0180

enemyTriangleSpeedRight:

    .dw      0x0000,  0x0000
    .dw      0x0200,  0x0000
    .dw     -0x0200,  0x0000
    .dw      0x0000, -0x0200
    .dw      0x0000,  0x0200
    .dw      0x0180, -0x0180
    .dw      0x0180,  0x0180    
    .dw     -0x0180, -0x0180
    .dw     -0x0180,  0x0180

enemyTriangleSprite:

    .db     -0x08 - 0x01, -0x08, 0xa0, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x08, 0xa4, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x08, 0xa8, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x08, 0xac, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x08, 0xa0, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x08, 0xa4, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x08, 0xa8, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x08, 0xac, VDP_COLOR_MEDIUM_RED

; スクエア
;
_enemySquareDefault::

    .db     ENEMY_TYPE_SQUARE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_NULL
    .dw     ENEMY_SPEED_NULL
    .dw     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .dw     ENEMY_SPRITE_NULL
    .db     ENEMY_HIDDEN_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemySquareSpeed:

    .dw      0x0000,  0x0000
    .dw      0x0000, -0x0200
    .dw      0x0000,  0x0200
    .dw     -0x0200,  0x0000
    .dw      0x0200,  0x0000
    .dw     -0x0180, -0x0180
    .dw      0x0180, -0x0180
    .dw     -0x0180,  0x0180
    .dw      0x0180,  0x0180

enemySquareSprite:

    .db     -0x08 - 0x01, -0x08, 0xb0, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0xb4, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0xb8, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0xbc, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0xb0, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0xb4, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0xb8, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0xbc, VDP_COLOR_LIGHT_BLUE


; DATA 領域
;
    .area   _DATA

; 変数の定義
;


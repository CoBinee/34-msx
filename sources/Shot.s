; Shot.s : ショット
;


; モジュール宣言
;
    .module Shot

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Camera.inc"
    .include	"Shot.inc"
    .include    "Ground.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ショットを初期化する
;
_ShotInitialize::
    
    ; レジスタの保存
    
    ; ショットの初期化
    ld      hl, #(_shot + 0x0000)
    ld      de, #(_shot + 0x0001)
    ld      bc, #(SHOT_ENTRY * SHOT_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; スプライトの初期化
    ld      de, #0x0000
    ld      (shotSpriteRotate), de

    ; レジスタの復帰
    
    ; 終了
    ret

; ショットを更新する
;
_ShotUpdate::
    
    ; レジスタの保存

    ; ショットの走査
    ld      ix, #_shot
    ld      b, #SHOT_ENTRY
10$:
    push    bc

    ; ショットの存在
    ld      a, SHOT_TYPE(ix)
    or      a
    jr      z, 19$

    ; 対空ショットの更新
    cp      #SHOT_TYPE_AIR
    jr      nz, 11$
    call    ShotAir
    jr      19$

    ; 対地ショットの更新
11$:
;   cp      #SHOT_TYPE_GROUND
;   jr      nz, 19$
    call    ShotGround
;   jr      19$

    ; 次のショットへ
19$:
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; ショットを描画する
;
_ShotRender::

    ; レジスタの保存

    ; ショットの走査
    ld      ix, #_shot
    ld      de, (shotSpriteRotate)
    ld      b, #SHOT_ENTRY
10$:
    push    bc

    ; ショットの存在
    ld      a, SHOT_TYPE(ix)
    or      a
    jr      z, 19$

    ; スプライトの取得
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
    add     hl, de
    ex      de, hl
    ld      l, SHOT_SPRITE_L(ix)
    ld      h, SHOT_SPRITE_H(ix)

    ; 対空ショットの描画
    cp      #SHOT_TYPE_AIR
    jr      nz, 11$
    ld      a, SHOT_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, SHOT_POSITION_X(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de
    jr      17$

    ; 対地ショットの描画
11$:
;   cp      #SHOT_TYPE_GROUND
;   jr      nz, 19$
    ld      bc, (_camera + CAMERA_POSITION_X)
    ld      a, SHOT_POSITION_X(ix)
    sub     c
    and     #(GROUND_NAME_SIZE_X - 0x01)
    cp      #CAMERA_VIEW_NAME_SIZE_X
    jr      nc, 12$
    ld      c, a
    ld      a, SHOT_POSITION_Y(ix)
    sub     b
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    cp      #CAMERA_VIEW_NAME_SIZE_Y
    jr      nc, 12$
;   ld      b, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_OFFSET_Y
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, a
    add     a, a
    add     a, a
    add     a, #CAMERA_VIEW_SPRITE_OFFSET_X
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de
12$:
;   jr      17$

    ; スプライトの更新
17$:
    pop     de
    ld      a, e
    add     a, #0x04
    cp      #(0x04 * SHOT_ENTRY)
    jr      c, 18$
    xor     a
18$:
    ld      e, a

    ; 次のショットへ
19$:
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ;  スプライトの更新
    ld      hl, #(shotSpriteRotate)
    ld      a, (hl)
    add     a, #0x04
    cp      #(0x04 * SHOT_ENTRY)
    jr      c, 20$
    xor     a
20$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; ショットを撃つ
;
_ShotFireAir::

    ; レジスタの保存
    push    bc
    push    ix

    ; de < 位置
    ; a  < 向き
    ; cf > 1 = 撃った

    ; 空のショットの取得
    ld      c, a
    call    ShotFire
    jr      nc, 19$

    ; ショットの設定
    xor     a
    ld      SHOT_TYPE(ix), #SHOT_TYPE_AIR
    ld      SHOT_STATE(ix), a
    ld      SHOT_POSITION_X(ix), e
    ld      SHOT_POSITION_Y(ix), d
    ld      SHOT_DIRECTION(ix), c
    ld      SHOT_ANIMATION(ix), a
    ld      SHOT_SPRITE_L(ix), a
    ld      SHOT_SPRITE_H(ix), a

    ; SE の再生
    ld      a, #SOUND_SE_AIR
    call    _SoundPlaySe

    ; ショットの完了
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     bc

    ; 終了
    ret

_ShotFireGround::

    ; レジスタの保存
    push    bc
    push    ix

    ; de < 位置
    ; a  < 向き
    ; cf > 1 = 撃った

    ; 空のショットの取得
    ld      c, a
    call    ShotFire
    jr      nc, 19$

    ; ショットの設定
    xor     a
    ld      SHOT_TYPE(ix), #SHOT_TYPE_GROUND
    ld      SHOT_STATE(ix), a
    ld      SHOT_POSITION_X(ix), e
    ld      SHOT_POSITION_Y(ix), d
    ld      SHOT_DIRECTION(ix), c
    ld      SHOT_ANIMATION(ix), a
    ld      SHOT_SPRITE_L(ix), a
    ld      SHOT_SPRITE_H(ix), a

    ; SE の再生
    ld      a, #SOUND_SE_GROUND
    call    _SoundPlaySe

    ; ショットの完了
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     bc

    ; 終了
    ret

ShotFire::

    ; レジスタの保存
    push    bc
    push    de

    ; ix > ショット
    ; cf > 1 = 撃つことが可能

    ; ショットの走査
    ld      ix, #_shot
    ld      de, #SHOT_LENGTH
    ld      b, #SHOT_ENTRY
10$:
    ld      a, SHOT_TYPE(ix)
    or      a
    jr      z, 11$
    add     ix, de
    djnz    10$
    or      a
    jr      19$
11$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; ショットを削除する
;
ShotKill:

    ; レジスタの保存

    ; ix < ショット

    ; ショットの削除
    ld      SHOT_TYPE(ix), #SHOT_TYPE_NULL

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
ShotNull:

    ; レジスタの保存

    ; ix < ショット

    ; レジスタの復帰

    ; 終了
    ret

; 対空ショットを飛ばす
;
ShotAir:

    ; レジスタの保存

    ; ix < ショット

    ; スクロールの取得
    ld      de, (_camera + CAMERA_VECTOR_X)

    ; 速度の取得
    ld      a, SHOT_DIRECTION(ix)
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #shotAirSpeed
    add     hl, bc

    ; 位置の更新
    ld      a, e
    add     a, SHOT_POSITION_X(ix)
    add     a, (hl)
    cp      #CAMERA_VIEW_SPRITE_OFFSET_X
    jr      c, 80$
    cp      #(CAMERA_VIEW_SPRITE_OFFSET_X + CAMERA_VIEW_SPRITE_SIZE_X)
    jr      nc, 80$
    ld      SHOT_POSITION_X(ix), a
    inc     hl
    ld      a, d
    add     a, SHOT_POSITION_Y(ix)
    add     a, (hl)
;   cp      #CAMERA_VIEW_SPRITE_OFFSET_Y
;   jr      c, 80$
    cp      #(CAMERA_VIEW_SPRITE_OFFSET_Y + CAMERA_VIEW_SPRITE_SIZE_Y)
    jr      nc, 80$
    ld      SHOT_POSITION_Y(ix), a
;   inc     hl

    ; スプライトの更新
    ld      a, SHOT_DIRECTION(ix)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #shotAirSprite
    add     hl, de
    ld      SHOT_SPRITE_L(ix), l
    ld      SHOT_SPRITE_H(ix), h
    jr      90$

    ; ショットの削除
80$:
    call    ShotKill
;   jr      90$

    ; ショットの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 対地ショットを落とす
;
ShotGround:

    ; レジスタの保存

    ; ix < ショット

    ; アニメーションの監視
    ld      a, SHOT_ANIMATION(ix)
    cp      #SHOT_ANIMATION_GROUND_LENGTH
    jr      nc, 80$
    
    ; 速度の取得
    ld      a, SHOT_DIRECTION(ix)
    add     a, a
    add     a, a
    add     a, SHOT_ANIMATION(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #shotGroundSpeed
    add     hl, de

    ; 位置の更新
    ld      a, SHOT_POSITION_X(ix)
    add     a, (hl)
    and     #(GROUND_NAME_SIZE_X - 0x01)
    ld      SHOT_POSITION_X(ix), a
    inc     hl
    ld      a, SHOT_POSITION_Y(ix)
    add     a, (hl)
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    ld      SHOT_POSITION_Y(ix), a
;   inc     hl

    ; スプライトの更新
    ld      a, SHOT_ANIMATION(ix)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #shotGroundSprite
    add     hl, de
    ld      SHOT_SPRITE_L(ix), l
    ld      SHOT_SPRITE_H(ix), h

    ; アニメーションの更新
    inc     SHOT_ANIMATION(ix)
    jr      90$

    ; 着弾
80$:
    ld      e, SHOT_POSITION_X(ix)
    ld      d, SHOT_POSITION_Y(ix)
    call    _GroundHit
    
    ; ショットの削除
    call    ShotKill
;   jr      90$

    ; ショットの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 対空ショット
;
shotAirSpeed:

    .db      0x00,  0x00
    .db      0x00, -0x0c
    .db      0x00,  0x0c
    .db     -0x0c,  0x00
    .db      0x0c,  0x00
    .db     -0x09, -0x09
    .db      0x09, -0x09
    .db     -0x09,  0x09
    .db      0x09,  0x09

shotAirSprite:

    .db     -0x08 - 0x01, -0x08, 0x00, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x08, 0x44, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x08, 0x44, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x08, 0x48, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x08, 0x4c, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x08, 0x4c, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x08, 0x48, VDP_COLOR_CYAN

; 対地ショット
;
shotGroundSpeed:

    .db      0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00
    .db      0x00,  0x00,  0x00, -0x02,  0x00, -0x02,  0x00, -0x01
    .db      0x00,  0x00,  0x00,  0x02,  0x00,  0x02,  0x00,  0x01
    .db      0x00,  0x00, -0x02,  0x00, -0x02,  0x00, -0x01,  0x00
    .db      0x00,  0x00,  0x02,  0x00,  0x02,  0x00,  0x01,  0x00
    .db      0x00,  0x00, -0x01, -0x01, -0x01, -0x01, -0x01, -0x01
    .db      0x00,  0x00,  0x01, -0x01,  0x01, -0x01,  0x01, -0x01
    .db      0x00,  0x00, -0x01,  0x01, -0x01,  0x01, -0x01,  0x01
    .db      0x00,  0x00,  0x01,  0x01,  0x01,  0x01,  0x01,  0x01
    
shotGroundSprite:

    .db     -0x08 - 0x01, -0x08, 0x50, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x54, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x58, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x5c, VDP_COLOR_LIGHT_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ショット
;
_shot::
    
    .ds     SHOT_ENTRY * SHOT_LENGTH

; スプライト
;
shotSpriteRotate:

    .ds     0x02


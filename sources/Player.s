; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Camera.inc"
    .include	"Player.inc"
    .include    "Shot.inc"
    .include    "Ground.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; 状態の設定
    ld      a, #PLAYER_STATE_STAY
    ld      (_player + PLAYER_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
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

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; 位置の取得
    ld      bc, (_player + PLAYER_PRINT_X)

    ; 船体の描画
    ld      hl, (_player + PLAYER_SPRITE_SHIP_L)
    ld      a, h
    or      l
    jr      z, 19$
    ld      a, (_player + PLAYER_DAMAGE)
    and     #0x01
    jr      nz, 19$
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
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
19$:

    ; 照準の描画
    ld      hl, (_player + PLAYER_SPRITE_TARGET_L)
    ld      a, h
    or      l
    jr      z, 29$
    ld      de, #(_sprite + GAME_SPRITE_TARGET)
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
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
29$:

    ; ステータスの描画
    ld      hl, #(_patternName + 0x0061)
    ld      de, #(_player + PLAYER_POWER_1000)
    ld      b, #(PLAYER_POWER_LENGTH - 0x01)
30$:
    ld      a, (de)
    or      a
    jr      nz, 31$
    ld      (hl), a
    push    de
    ld      de, #-0x0020
    add     hl, de
    pop     de
    inc     de
    djnz    30$
31$:
    inc     b
32$:
    ld      a, (de)
    add     a, #0x30
    ld      (hl), a
    push    de
    ld      de, #-0x0020
    add     hl, de
    pop     de
    inc     de
    djnz    32$

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを待機させる
;
PlayerStay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; スプライトの更新
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerShipSprite
    add     hl, de
    ld      (_player + PLAYER_SPRITE_SHIP_L), hl
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPRITE_TARGET_L), hl

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; カメラの位置の保存
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      (_camera + CAMERA_LAST_X), de

    ; 向きの変更
100$:
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 110$
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 101$
    ld      a, #CAMERA_DIRECTION_UP_LEFT
    jr      190$
101$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 102$
    ld      a, #CAMERA_DIRECTION_UP_RIGHT
    jr      190$
102$:
    ld      a, #CAMERA_DIRECTION_UP
    jr      190$
110$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 120$
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 111$
    ld      a, #CAMERA_DIRECTION_DOWN_LEFT
    jr      190$
111$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 112$
    ld      a, #CAMERA_DIRECTION_DOWN_RIGHT
    jr      190$
112$:
    ld      a, #CAMERA_DIRECTION_DOWN
    jr      190$
120$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 130$
    ld      a, #CAMERA_DIRECTION_LEFT
    jr      190$
130$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 140$
    ld      a, #CAMERA_DIRECTION_RIGHT
    jr      190$
140$:
    ld      a, (_player + PLAYER_DIRECTION)
;   xor     a
;   call    _CameraSetDirection
;   jr      199$
;   jr      190$
190$:
    ld      (_player + PLAYER_DIRECTION), a

    ; カメラの向きの設定
    call    _CameraSetDirection

    ; 移動
;   ld      a, (_player + PLAYER_DIRECTION)
    call    PlayerMove

    ; カメラの位置の設定
    ld      de, (_player + PLAYER_POSITION_X)
    call    _CameraSetPosition
199$:

    ; 発射
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 20$
    ld      de, #(((CAMERA_VIEW_SPRITE_OFFSET_Y + CAMERA_VIEW_SPRITE_SIZE_Y / 2) << 8) | (CAMERA_VIEW_SPRITE_OFFSET_X + CAMERA_VIEW_SPRITE_SIZE_X / 2))
    ld      a, (_player + PLAYER_DIRECTION)
    call    _ShotFireAir
    call    c, PlayerUsePower_1
;   jr      20$
20$:
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    dec     a
    jr      nz, 21$
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerFireGroundPosition
    add     hl, de
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, e
    add     a, (hl)
    ld      e, a
    inc     hl
    ld      a, d
    add     a, (hl)
    ld      d, a
    ld      a, (_player + PLAYER_DIRECTION)
    call    _ShotFireGround
    call    c, PlayerUsePower_10
;   jr      21$
21$:

    ; スプライトの更新
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerShipSprite
    add     hl, de
    ld      (_player + PLAYER_SPRITE_SHIP_L), hl
    ld      hl, #playerTargetSprite
    add     hl, de
    ld      (_player + PLAYER_SPRITE_TARGET_L), hl

    ; パワーの消費
    ld      hl, #(_player + PLAYER_COST)
    inc     (hl)
    ld      a, (hl)
    cp      #PLAYER_COST_LENGTH
    jr      c, 30$
    ld      (hl), #0x00
    call    PlayerUsePower_1
30$:
    ld      hl, #(_player + PLAYER_POWER_1000)
    xor     a
    ld      b, #PLAYER_POWER_LENGTH
31$:
    or      (hl)
    inc     hl
    djnz    31$
    or      a
    call    z, _PlayerSetBomb

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_DAMAGE)
    ld      a, (hl)
    or      a
    jr      z, 40$
    dec     (hl)
40$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが爆発する
;
PlayerBomb:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    xor     a
    ld      (_player + PLAYER_ANIMATION), a

    ; スプライトの設定
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPRITE_TARGET_L), hl

    ; ダメージの設定
    xor     a
    ld      (_player + PLAYER_DAMAGE), a

    ; SE の再生
    ld      a, #SOUND_SE_MISS
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; カメラの向きの設定
    ld      a, (_player + PLAYER_DIRECTION)
    call    _CameraSetDirection

    ; 移動
    ld      a, (_player + PLAYER_DIRECTION)
    call    PlayerMove

    ; カメラの位置の設定
    ld      de, (_player + PLAYER_POSITION_X)
    call    _CameraSetPosition

    ; 0x01 : 爆発中
10$:
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    dec     a
    jr      nz, 20$

    ; スプライトの更新
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0xfe
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerBombSprite
    add     hl, de
    ld      (_player + PLAYER_SPRITE_SHIP_L), hl

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    inc     (hl)
    ld      a, (hl)
    cp      #PLAYER_ANIMATION_BOMB
    jr      c, 19$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_BOMB_BIT, (hl)

    ; スプライトの設定
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPRITE_SHIP_L), hl

    ; 状態の更新
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
;   jr      19$
19$:
    jr      90$

    ; 0x02 : 待機
20$:
;   jr      90$
    
    ; 爆発の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが離脱する
;
PlayerLeave:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    ld      a, #0x20
    ld      (_player + PLAYER_ANIMATION), a

    ; スプライトの設定
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPRITE_TARGET_L), hl

    ; ダメージの設定
    xor     a
    ld      (_player + PLAYER_DAMAGE), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; カメラの向きの設定
    ld      a, (_player + PLAYER_DIRECTION)
    call    _CameraSetDirection

    ; 移動
    ld      a, (_player + PLAYER_DIRECTION)
    call    PlayerMove

    ; カメラの位置の設定
    ld      de, (_player + PLAYER_POSITION_X)
    call    _CameraSetPosition

    ; 0x01 : 後ろに下がる
10$:
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    dec     a
    jr      nz, 20$

    ; 描画位置の更新
    ld      hl, (_camera + CAMERA_VECTOR_X)
    ld      de, (_player + PLAYER_PRINT_X)
    ld      a, e
    sub     l
    sub     l
    ld      e, a
    ld      a, d
    sub     h
    sub     h
    ld      d, a
    ld      (_player + PLAYER_PRINT_X), de

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
;   jr      19$
19$:
    jr      90$

    ; 0x02 : 画面外へ出る
20$:
    dec     a
    jr      nz, 30$

    ; 描画位置の更新
    ld      hl, (_camera + CAMERA_VECTOR_X)
    ld      de, (_player + PLAYER_PRINT_X)
    ld      a, l
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      a, h
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, d
    ld      d, a
    ld      (_player + PLAYER_PRINT_X), de
;   ld      a, d
    cp      #(CAMERA_VIEW_SPRITE_OFFSET_Y + CAMERA_VIEW_SPRITE_SIZE_Y)
    jr      nc, 21$
    ld      a, e
    cp      #CAMERA_VIEW_SPRITE_OFFSET_X
    jr      c, 21$
    cp      #(CAMERA_VIEW_SPRITE_OFFSET_X + CAMERA_VIEW_SPRITE_SIZE_X)
    jr      c, 29$

    ; フラグの設定
21$:
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_LEAVE_BIT, (hl)

    ; スプライトの設定
    ld      hl, #0x00000
    ld      (_player + PLAYER_SPRITE_SHIP_L), hl

    ; 状態の更新
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
;   jr      29$
29$:
    jr      90$

    ; 0x03 : 待機
30$:
;   jr      90$

    ; 離脱の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが移動する
;
PlayerMove:

    ; レジスタの保存
    push    hl
    push    de

    ; a < 向き

    ; 移動
    ld      hl, (_camera + CAMERA_VECTOR_X)
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, e
    add     a, l
    and     #(GROUND_NAME_SIZE_X - 0x01)
    ld      e, a
    ld      a, d
    add     a, h
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    ld      d, a
    ld      (_player + PLAYER_POSITION_X), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; パワーを消費する
;
PlayerUsePower_1:

    ; レジスタの保存
    push    hl
    push    bc

    ; パワーを 1 減らす
    ld      hl, #(_player + PLAYER_POWER_0001)
    ld      bc, #((PLAYER_POWER_LENGTH << 8) | 0x09)
10$:
    ld      a, (hl)
    or      a
    jr      z, 11$
    dec     (hl)
    jr      19$
11$:
    ld      (hl), c
    dec     hl
    djnz    10$
    ld      hl, #0x0000
    ld      (_player + PLAYER_POWER_1000), hl
    ld      (_player + PLAYER_POWER_0010), hl
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

PlayerUsePower_10:

    ; レジスタの保存
    push    hl
    push    bc

    ; パワーを 10 減らす
    ld      hl, #(_player + PLAYER_POWER_0010)
    ld      bc, #(((PLAYER_POWER_LENGTH - 1) << 8) | 0x09)
10$:
    ld      a, (hl)
    or      a
    jr      z, 11$
    dec     (hl)
    jr      19$
11$:
    ld      (hl), c
    dec     hl
    djnz    10$
    ld      hl, #0x0000
    ld      (_player + PLAYER_POWER_1000), hl
    ld      (_player + PLAYER_POWER_0010), hl
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; プレイヤが存在しているかどうかを判定する
;
_PlayerIsLive::

    ; レジスタの保存

    ; cf > 1 = プレイヤの存在

    ; プレイヤの存在
    ld      a, (_player + PLAYER_FLAG)
    and     #(PLAYER_FLAG_BOMB | PLAYER_FLAG_LEAVE)
    jr      nz, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作させる
;
_PlayerSetPlay::

    ; レジスタの保存

    ; 状態の更新
    ld      a, #PLAYER_STATE_PLAY
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを爆発させる
;
_PlayerSetBomb::

    ; レジスタの保存

    ; 状態の更新
    ld      a, #PLAYER_STATE_BOMB
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを離脱させる
;
_PlayerSetLeave::

    ; レジスタの保存

    ; 状態の更新
    ld      a, #PLAYER_STATE_LEAVE
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤにダメージを与える
;
_PlayerDamage::

    ; レジスタの保存
    push    hl

    ; 1000 のダメージ
    ld      a, (_player + PLAYER_DAMAGE)
    or      a
    jr      nz, 19$
    ld      hl, #(_player + PLAYER_POWER_1000)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      11$
10$:
    ld      hl, #0x0000
    ld      (_player + PLAYER_POWER_1000), hl
    ld      (_player + PLAYER_POWER_0010), hl
;   jr      11$
11$:
    ld      a, #PLAYER_DAMAGE_LENGTH
    ld      (_player + PLAYER_DAMAGE), a
19$:

    ; SE の再生
    ld      a, #SOUND_SE_DAMAGE
    call    _SoundPlaySe

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerStay
    .dw     PlayerPlay
    .dw     PlayerBomb
    .dw     PlayerLeave

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_NULL
    .db     PLAYER_FLAG_NULL
    .db     PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_NULL
    .db     CAMERA_DIRECTION_UP ; PLAYER_DIRECTION_NULL
    .db     PLAYER_ANIMATION_NULL
    .db     CAMERA_VIEW_SPRITE_OFFSET_X + CAMERA_VIEW_SPRITE_SIZE_X / 2 ; PLAYER_PRINT_NULL
    .db     CAMERA_VIEW_SPRITE_OFFSET_Y + CAMERA_VIEW_SPRITE_SIZE_Y / 2 ; PLAYER_PRINT_NULL
    .dw     PLAYER_SPRITE_NULL
    .dw     PLAYER_SPRITE_NULL
    .db     0x09 ; PLAYER_POWER_NULL
    .db     0x09 ; PLAYER_POWER_NULL
    .db     0x09 ; PLAYER_POWER_NULL
    .db     0x09 ; PLAYER_POWER_NULL
    .db     PLAYER_COST_NULL
    .db     PLAYER_DAMAGE_NULL

; 移動
;

; 発射
;
playerFireGroundPosition:

    .db      0x00,  0x00
    .db      0x00, -0x01
    .db      0x00,  0x01
    .db     -0x01,  0x00
    .db      0x01,  0x00
    .db     -0x01, -0x01
    .db      0x01, -0x01
    .db     -0x01,  0x01
    .db      0x01,  0x01

; 船体
;
playerShipSprite:

    .db     -0x08 - 0x01, -0x08, 0x00, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x20, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x24, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x28, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x2c, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x30, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x34, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x38, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x3c, VDP_COLOR_WHITE

; 爆発
;
playerBombSprite:

    .db     -0x08 - 0x01, -0x08, 0x70, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x74, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x78, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x7c, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x00, VDP_COLOR_TRANSPARENT

; 離脱
;


; 照準
;
playerTargetSprite:

    .db     -0x08 - 0x01, -0x08, 0x00, VDP_COLOR_TRANSPARENT
    .db     -0x38 - 0x01, -0x08, 0x04, VDP_COLOR_GRAY
    .db      0x28 - 0x01, -0x08, 0x04, VDP_COLOR_GRAY
    .db     -0x08 - 0x01, -0x38, 0x04, VDP_COLOR_GRAY
    .db     -0x08 - 0x01,  0x28, 0x04, VDP_COLOR_GRAY
    .db     -0x28 - 0x01, -0x28, 0x04, VDP_COLOR_GRAY
    .db     -0x28 - 0x01,  0x18, 0x04, VDP_COLOR_GRAY
    .db      0x18 - 0x01, -0x28, 0x04, VDP_COLOR_GRAY
    .db      0x18 - 0x01,  0x18, 0x04, VDP_COLOR_GRAY


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH


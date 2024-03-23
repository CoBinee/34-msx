; Enemy.s : エネミー
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

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; エネミーの初期化
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_ENTRY * ENEMY_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 登録の初期化
    ld      hl, #enemyEntryDefault
    ld      de, #enemyEntry
    ld      bc, #ENEMY_ENTRY_LENGTH
    ldir
    call    EnemySetEntryGroup

    ; スプライトの初期化
    ld      de, #0x0000
    ld      (enemySpriteRotate), de

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$

    ; 種類別の処理
    ld      hl, #18$
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
18$:

    ; 次のエネミーへ
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      de, (enemySpriteRotate)
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    ld      a, ENEMY_HIDDEN(ix)
    or      a
    jr      nz, 19$

    ; スプライトの描画
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    ex      de, hl
    ld      l, ENEMY_SPRITE_L(ix)
    ld      h, ENEMY_SPRITE_H(ix)
    ld      a, ENEMY_POSITION_Y_H(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_POSITION_X_H(ix)
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
    pop     de

    ; スプライトの更新
    ld      a, e
    add     a, #0x04
    cp      #(0x04 * ENEMY_ENTRY)
    jr      c, 18$
    xor     a
18$:
    ld      e, a

    ; 次のエネミーへ
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ;  スプライトの更新
    ld      hl, #(enemySpriteRotate)
    ld      a, (hl)
    add     a, #0x04
    cp      #(0x04 * ENEMY_ENTRY)
    jr      c, 20$
    xor     a
20$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを登録する
;
_EnemyEntry::

    ; レジスタの保存

    ; フレームの更新
    ld      hl, #(enemyEntry + ENEMY_ENTRY_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 100$
    dec     (hl)
    jp      90$

    ; 0x00 : スクエアを一定方向から順次登場させる
100$:
    ld      a, (enemyEntry + ENEMY_ENTRY_GROUP)
    or      a
    jr      nz, 110$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_INTERVAL)
    ld      a, (hl)
    or      a
    jr      z, 101$
    dec     (hl)
    jr      109$
101$:
    call    20$
    jr      nc, 109$
    ld      hl, #_enemySquareDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    call    30$
    call    40$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_REST)
    dec     (hl)
    ld      hl, #(enemyEntry + ENEMY_ENTRY_COUNT)
    dec     (hl)
    jr      z, 108$
    ld      a, #0x10
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      109$
108$:
    call    EnemySetEntryGroup
;   jr      109$
109$:
    jp      190$

    ; 0x01 : スクエアを八方向から同時に登場させる
110$:
    dec     a
    jr      nz, 120$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_REST)
    ld      a, (hl)
    cp      #0x08
    jr      c, 119$
    ld      de, #enemyEntryPosition_8
    ld      b, #0x08
111$:
    call    20$
    jr      nc, 119$
    push    bc
    push    hl
    push    de
    ld      hl, #_enemySquareDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     hl
    ld      a, (de)
    ld      ENEMY_POSITION_X_H(ix), a
    inc     de
    ld      a, (de)
    ld      ENEMY_POSITION_Y_H(ix), a
    inc     de
    ld      a, (de)
    ld      ENEMY_DIRECTION(ix), a
    inc     de
    cp      #CAMERA_DIRECTION_UP_LEFT
    ld      a, #0x00
    jr      nc, 112$
    ld      a, #0x10
112$:
    ld      ENEMY_HIDDEN(ix), a
    set     #ENEMY_SQUARE_FLAG_STRAIGHT_BIT, ENEMY_FLAG(ix)
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     (hl)
    djnz    111$
119$:
    call    EnemySetEntryGroup
    jp      190$

    ; 0x02 : スクエアをランダムに順次登場させる
120$:
    dec     a
    jr      nz, 130$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_INTERVAL)
    ld      a, (hl)
    or      a
    jr      z, 121$
    dec     (hl)
    jr      129$
121$:
    call    20$
    jr      nc, 129$
    ld      hl, #_enemySquareDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    call    30$
    call    40$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_REST)
    dec     (hl)
    ld      hl, #(enemyEntry + ENEMY_ENTRY_COUNT)
    dec     (hl)
    jr      z, 128$
    ld      a, #0x10
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      129$
128$:
    call    EnemySetEntryGroup
;   jr      129$
129$:
    jp      190$

    ; 0x03 : トライアングルを一方向から順次登場させる
130$:
    dec     a
    jr      nz, 140$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_INTERVAL)
    ld      a, (hl)
    or      a
    jr      z, 131$
    dec     (hl)
    jr      139$
131$:
    call    20$
    jr      nc, 139$
    ld      hl, #_enemyTriangleDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    call    30$
    call    40$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_REST)
    dec     (hl)
    ld      hl, #(enemyEntry + ENEMY_ENTRY_COUNT)
    dec     (hl)
    jr      z, 138$
    ld      a, #0x10
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      139$
138$:
    call    EnemySetEntryGroup
;   jr      139$
139$:
    jp      190$

    ; 0x04 : トライアングルを八方向から同時に登場させる
140$:
    dec     a
    jr      nz, 150$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_REST)
    ld      a, (hl)
    cp      #0x08
    jr      c, 149$
    ld      de, #enemyEntryPosition_8
    ld      b, #0x08
141$:
    call    20$
    jr      nc, 149$
    push    bc
    push    hl
    push    de
    ld      hl, #_enemyTriangleDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     hl
    ld      a, (de)
    ld      ENEMY_POSITION_X_H(ix), a
    inc     de
    ld      a, (de)
    ld      ENEMY_POSITION_Y_H(ix), a
    inc     de
    ld      a, (de)
    ld      ENEMY_DIRECTION(ix), a
    inc     de
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     (hl)
    djnz    141$
149$:
    call    EnemySetEntryGroup
    jr      190$

    ; 0x05 : トライアングルをランダムに順次登場させる
150$:
    dec     a
    jr      nz, 160$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_INTERVAL)
    ld      a, (hl)
    or      a
    jr      z, 151$
    dec     (hl)
    jr      159$
151$:
    call    20$
    jr      nc, 159$
    ld      hl, #_enemyTriangleDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    call    _SystemGetRandom
    and     #0x07
    inc     a
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    call    30$
    call    40$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_REST)
    dec     (hl)
    ld      hl, #(enemyEntry + ENEMY_ENTRY_COUNT)
    dec     (hl)
    jr      z, 158$
    ld      a, #0x10
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      159$
158$:
    call    EnemySetEntryGroup
;   jr      159$
159$:
    jr      190$

    ; 0x06,0x07 : サークルをランダムに順次登場させる
160$:
;   dec     a
;   jr      nz, 170$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_INTERVAL)
    ld      a, (hl)
    or      a
    jr      z, 161$
    dec     (hl)
    jr      169$
161$:
    call    20$
    jr      nc, 169$
    ld      hl, #_enemyCircleDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    call    30$
    call    40$
    ld      hl, #(enemyEntry + ENEMY_ENTRY_REST)
    dec     (hl)
    ld      hl, #(enemyEntry + ENEMY_ENTRY_COUNT)
    dec     (hl)
    jr      z, 168$
    ld      a, #0x10
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      169$
168$:
    call    EnemySetEntryGroup
;   jr      169$
169$:
;   jr      190$

    ; グループ別処理の完了
190$:
    jr      90$

    ; エネミーの取得
20$:
    push    bc
    push    de
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
21$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 22$
    add     ix, de
    djnz    21$
    or      a
    jr      29$
22$:
    scf
;   jr      29$
29$:
    pop     de
    pop     bc
    ret

    ; 指定された方向からのランダムな出現位置の設定
30$:
    ld      a, (enemyEntry + ENEMY_ENTRY_DIRECTION)
31$:
    push    hl
    push    de
    dec     a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyEntryPosition_1
    add     hl, de
    call    _SystemGetRandom
    and     #0x1e
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    xor     a
    ld      ENEMY_POSITION_X_L(ix), a
    ld      ENEMY_POSITION_X_H(ix), e
    ld      ENEMY_POSITION_Y_L(ix), a
    ld      ENEMY_POSITION_Y_H(ix), d
    pop     de
    pop     hl
    ret

    ; 反対の向きの設定
40$:
    ld      a, (enemyEntry + ENEMY_ENTRY_DIRECTION)
41$:
    dec     a
    cp      #CAMERA_DIRECTION_RIGHT
    jr      nc, 42$
    xor     #0b00000001
    jr      49$
42$:
    xor     #0b00000011
;   jr      49$
49$:
    inc     a
    ld      ENEMY_DIRECTION(ix), a
    ret

    ; 登録の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの登録グループを設定する
;
EnemySetEntryGroup:

    ; レジスタの保存

    ; 0x00 : スクエアを一定方向から順次登場させる
100$:
    call    _SystemGetRandom
    and     #0x07
    ld      (enemyEntry + ENEMY_ENTRY_GROUP), a
    jr      nz, 110$
    call    30$
    ld      (enemyEntry + ENEMY_ENTRY_COUNT), a
    ld      a, (_player + PLAYER_DIRECTION)
    call    20$
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    xor     a
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      190$

    ; 0x01 : スクエアを八方向から同時に登場させる
110$:
    dec     a
    jr      nz, 120$
    ld      a, #0x08
    ld      (enemyEntry + ENEMY_ENTRY_COUNT), a
    xor     a
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      190$

    ; 0x02 : スクエアをランダムに順次登場させる
120$:
    dec     a
    jr      nz, 130$
    call    30$
    ld      (enemyEntry + ENEMY_ENTRY_COUNT), a
    xor     a
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      190$

    ; 0x03 : トライアングルを一方向から順次登場させる
130$:
    dec     a
    jr      nz, 140$
    call    30$
    ld      (enemyEntry + ENEMY_ENTRY_COUNT), a
    ld      a, (_player + PLAYER_DIRECTION)
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    xor     a
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      190$

    ; 0x04 : トライアングルを八方向から同時に登場させる
140$:
    dec     a
    jr      nz, 150$
    ld      a, #0x08
    ld      (enemyEntry + ENEMY_ENTRY_COUNT), a
    xor     a
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      190$

    ; 0x05 : トライアングルをランダムに順次登場させる
150$:
    dec     a
    jr      nz, 160$
    call    30$
    ld      (enemyEntry + ENEMY_ENTRY_COUNT), a
    xor     a
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
    jr      190$

    ; 0x06,0x07 : サークルをランダムに順次登場させる
160$:
;   dec     a
;   jr      nz, 170$
    call    30$
    ld      (enemyEntry + ENEMY_ENTRY_COUNT), a
    xor     a
    ld      (enemyEntry + ENEMY_ENTRY_DIRECTION), a
    ld      (enemyEntry + ENEMY_ENTRY_INTERVAL), a
;   jr      190$

    ; グループ別処理の完了
190$:
    jr      90$

    ; 斜めの補正
20$:
    cp      #(CAMERA_DIRECTION_UP_LEFT)
    jr      c, 29$
    jr      nz, 21$
    call    _SystemGetRandom
    and     #0x02
    inc     a
    jr      29$
21$:
    cp      #(CAMERA_DIRECTION_UP_RIGHT)
    jr      nz, 22$
    call    _SystemGetRandom
    and     #0x04
    cp      #0x04
    adc     a, #0x00
    jr      29$
22$:
    cp      #(CAMERA_DIRECTION_DOWN_LEFT)
    jr      nz, 23$
    call    _SystemGetRandom
    and     #0x01
    add     a, #0x02
    jr      29$
23$:
;   cp      #(CAMERA_DIRECTION_DOWN_RIGHT)
;   jr      nz, 29$
    call    _SystemGetRandom
    and     #0x01
    inc     a
    add     a, a
;   jr      29$
29$:
    ret

    ; 2-5 の数値の取得
30$:
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x02
;   cp      #0x04
;   adc     a, #0x01
    ret

    ; 設定の完了
90$:
    ld      a, #0x40
    ld      (enemyEntry + ENEMY_ENTRY_FRAME), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを削除する
;
_EnemyKill::

    ; レジスタの保存
    push    hl

    ; ix < エネミー

    ; エネミーの削除
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_NULL

    ; 登録の更新
    ld      hl, #(enemyEntry + ENEMY_ENTRY_REST)
    inc     (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; エネミーをスクロールさせる
;
_EnemyScroll::

    ; レジスタの保存
    push    de

    ; ix < エネミー

    ; 移動
    ld      de, (_camera + CAMERA_VECTOR_X)
    ld      a, ENEMY_POSITION_X_H(ix)
    sub     e
    ld      ENEMY_POSITION_X_H(ix), a
    ld      a, ENEMY_POSITION_Y_H(ix)
    sub     d
    ld      ENEMY_POSITION_Y_H(ix), a

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; エネミーを移動させる
;
_EnemyMove::

    ; レジスタの保存
    push    hl
    push    de

    ; ix < エネミー

    ; 移動
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      e, ENEMY_SPEED_X_L(ix)
    ld      d, ENEMY_SPEED_X_H(ix)
    add     hl, de
    ld      a, h
    cp      #CAMERA_VIEW_SPRITE_OFFSET_X
    jr      c, 18$
    cp      #(CAMERA_VIEW_SPRITE_OFFSET_X + CAMERA_VIEW_SPRITE_SIZE_X)
    jr      nc, 18$
    ld      ENEMY_POSITION_X_L(ix), l
    ld      ENEMY_POSITION_X_H(ix), h
    ld      l, ENEMY_POSITION_Y_L(ix)
    ld      h, ENEMY_POSITION_Y_H(ix)
    ld      e, ENEMY_SPEED_Y_L(ix)
    ld      d, ENEMY_SPEED_Y_H(ix)
    add     hl, de
    ld      a, h
    cp      #(CAMERA_VIEW_SPRITE_OFFSET_Y + CAMERA_VIEW_SPRITE_SIZE_Y)
    jr      nc, 18$
    ld      ENEMY_POSITION_Y_L(ix), l
    ld      ENEMY_POSITION_Y_H(ix), h
    jr      19$
18$:
    call    _EnemyKill
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; エネミーをアニメーションさせる
;
_EnemyAnimation::

    ; レジスタの保存
    push    hl
    push    de

    ; ix < エネミー
    ; hl < スプライト

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; スプライトの設定
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x1c
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; エネミーを爆発させる
;
_EnemySetBomb::

    ; レジスタの保存

    ; ix < エネミー
    ; a  < 1 = SE の再生

    ; 爆発の設定
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_BOMB
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    or      a
    jr      z, 10$
    set     #ENEMY_FLAG_SE_BIT, ENEMY_FLAG(ix)
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; ix < エネミー

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが爆発する
;
EnemyBomb:

    ; レジスタの保存

    ; ix < エネミー

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #0x00

    ; SE の再生
    ld      a, #SOUND_SE_HIT
    bit     #ENEMY_FLAG_SE_BIT, ENEMY_FLAG(ix)
    call    nz, _SoundPlaySe

    ; 状態の更新
    inc     ENEMY_STATE(ix)
09$:

    ; スクロール
    call    _EnemyScroll

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)
    ld      a, ENEMY_ANIMATION(ix)
    cp      #0x08
    jr      nc, 10$

    ; スプライトの設定
    and     #0xfe
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyBombSprite
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h
    jr      19$

    ; 爆発の完了
10$:
    call    _EnemyKill
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 種類別の処理
;
enemyProc:
    
    .dw     EnemyNull
    .dw     EnemyBomb
    .dw     _EnemyCircle
    .dw     _EnemyTriangle
    .dw     _EnemySquare

; 種類別の初期値
;
enemyDefault:

    .dw     enemyNullDefault
    .dw     enemyBombDefault
    .dw     _enemyCircleDefault
    .dw     _enemyTriangleDefault
    .dw     _enemySquareDefault

enemyNullDefault:

    .db     ENEMY_TYPE_NULL
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

enemyBombDefault:

    .db     ENEMY_TYPE_BOMB
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

; 登録
;
enemyEntryDefault:

    .db     ENEMY_ENTRY ; ENEMY_ENTRY_REST_NULL
    .db     ENEMY_ENTRY_FRAME_NULL
    .db     ENEMY_ENTRY_GROUP_NULL
    .db     ENEMY_ENTRY_COUNT_NULL
    .db     ENEMY_ENTRY_DIRECTION_NULL
    .db     ENEMY_ENTRY_INTERVAL_NULL

enemyEntryPosition_1:

    .db     0x2d, 0x00, 0x38, 0x00, 0x43, 0x00, 0x4e, 0x00, 0x59, 0x00, 0x64, 0x00, 0x6f, 0x00, 0x7a, 0x00, 0x86, 0x00, 0x91, 0x00, 0x9c, 0x00, 0xa7, 0x00, 0xb2, 0x00, 0xbd, 0x00, 0xc8, 0x00, 0xd3, 0x00
    .db     0x2d, 0xbf, 0x38, 0xbf, 0x43, 0xbf, 0x4e, 0xbf, 0x59, 0xbf, 0x64, 0xbf, 0x6f, 0xbf, 0x7a, 0xbf, 0x86, 0xbf, 0x91, 0xbf, 0x9c, 0xbf, 0xa7, 0xbf, 0xb2, 0xbf, 0xbd, 0xbf, 0xc8, 0xbf, 0xd3, 0xbf
    .db     0x20, 0x0d, 0x20, 0x18, 0x20, 0x23, 0x20, 0x2e, 0x20, 0x39, 0x20, 0x44, 0x20, 0x4f, 0x20, 0x5a, 0x20, 0x66, 0x20, 0x71, 0x20, 0x7c, 0x20, 0x87, 0x20, 0x92, 0x20, 0x9d, 0x20, 0xa8, 0x20, 0xb3
    .db     0xdf, 0x0d, 0xdf, 0x18, 0xdf, 0x23, 0xdf, 0x2e, 0xdf, 0x39, 0xdf, 0x44, 0xdf, 0x4f, 0xdf, 0x5a, 0xdf, 0x66, 0xdf, 0x71, 0xdf, 0x7c, 0xdf, 0x87, 0xdf, 0x92, 0xdf, 0x9d, 0xdf, 0xa8, 0xdf, 0xb3
    .db     0x2d, 0x00, 0x38, 0x00, 0x43, 0x00, 0x4e, 0x00, 0x59, 0x00, 0x64, 0x00, 0x6f, 0x00, 0x7a, 0x00, 0x20, 0x0d, 0x20, 0x18, 0x20, 0x23, 0x20, 0x2e, 0x20, 0x39, 0x20, 0x44, 0x20, 0x4f, 0x20, 0x5a
    .db     0x86, 0x00, 0x91, 0x00, 0x9c, 0x00, 0xa7, 0x00, 0xb2, 0x00, 0xbd, 0x00, 0xc8, 0x00, 0xd3, 0x00, 0xdf, 0x0d, 0xdf, 0x18, 0xdf, 0x23, 0xdf, 0x2e, 0xdf, 0x39, 0xdf, 0x44, 0xdf, 0x4f, 0xdf, 0x5a
    .db     0x2d, 0xbf, 0x38, 0xbf, 0x43, 0xbf, 0x4e, 0xbf, 0x59, 0xbf, 0x64, 0xbf, 0x6f, 0xbf, 0x7a, 0xbf, 0x20, 0x66, 0x20, 0x71, 0x20, 0x7c, 0x20, 0x87, 0x20, 0x92, 0x20, 0x9d, 0x20, 0xa8, 0x20, 0xb3
    .db     0x86, 0xbf, 0x91, 0xbf, 0x9c, 0xbf, 0xa7, 0xbf, 0xb2, 0xbf, 0xbd, 0xbf, 0xc8, 0xbf, 0xd3, 0xbf, 0xdf, 0x66, 0xdf, 0x71, 0xdf, 0x7c, 0xdf, 0x87, 0xdf, 0x92, 0xdf, 0x9d, 0xdf, 0xa8, 0xdf, 0xb3

enemyEntryPosition_8:

    .db     0x28, 0x00, CAMERA_DIRECTION_DOWN_RIGHT
    .db     0x80, 0x00, CAMERA_DIRECTION_DOWN
    .db     0xdf, 0x00, CAMERA_DIRECTION_DOWN_LEFT
    .db     0x28, 0x60, CAMERA_DIRECTION_RIGHT
    .db     0xdf, 0x60, CAMERA_DIRECTION_LEFT
    .db     0x28, 0xbf, CAMERA_DIRECTION_UP_RIGHT
    .db     0x80, 0xbf, CAMERA_DIRECTION_UP
    .db     0xdf, 0xbf, CAMERA_DIRECTION_UP_LEFT

; 爆発
;
enemyBombSprite:

    .db     -0x08 - 0x01, -0x08, 0x70, VDP_COLOR_GRAY
    .db     -0x08 - 0x01, -0x08, 0x74, VDP_COLOR_GRAY
    .db     -0x08 - 0x01, -0x08, 0x78, VDP_COLOR_GRAY
    .db     -0x08 - 0x01, -0x08, 0x7c, VDP_COLOR_GRAY


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_ENTRY * ENEMY_LENGTH

; 登録
;
enemyEntry:

    .ds     ENEMY_ENTRY_LENGTH

; スプライト
;
enemySpriteRotate:

    .ds     0x02


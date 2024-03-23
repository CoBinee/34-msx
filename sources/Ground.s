; Ground.s : 地面
;


; モジュール宣言
;
    .module Ground

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Camera.inc"
    .include	"Ground.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 地面を初期化する
;
_GroundInitialize::
    
    ; レジスタの保存
    
    ; 地面の初期化
    ld      hl, #groundDefault
    ld      de, #_ground
    ld      bc, #GROUND_LENGTH
    ldir

    ; コアの初期化
    ld      hl, #(groundCore + 0x0000)
    ld      de, #(groundCore + 0x0001)
    ld      bc, #(GROUND_CORE_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 爆発の初期化
    ld      hl, #(groundBomb + 0x0000)
    ld      de, #(groundBomb + 0x0001)
    ld      bc, #(GROUND_BOMB_LENGTH * GROUND_BOMB_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 状態の設定
    ld      a, #GROUND_STATE_PLAY
    ld      (_ground + GROUND_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 地面を更新する
;
_GroundUpdate::
    
    ; レジスタの保存

    ; コアの監視
    ld      a, (groundCore + GROUND_CORE_LIFE)
    or      a
    jr      nz, 19$

    ; コアの爆発
    ld      hl, #(groundCore + GROUND_CORE_FRAME)
    inc     (hl)
    ld      a, (hl)
    and     #0x03
    jr      nz, 19$
    ld      de, (groundCore + GROUND_CORE_CELL_L)
    ld      a, e
    add     a, a
    rl      d
    add     a, a
    rl      d
    sla     d
    inc     d
    srl     a
    ld      e, a
    inc     e
    call    _SystemGetRandom
    and     #0x07
    jr      nz, 10$
    ld      a, #0x04
10$:
    sub     #0x04
    add     a, d
    ld      d, a
    call    _SystemGetRandom
    and     #0x07
    jr      nz, 11$
    ld      a, #0x04
11$:
    sub     #0x04
    add     a, e
    ld      e, a
    ld      a, #GROUND_BOMB_TYPE_BOMB
    call    GroundEntryBomb
;   jr      19$
19$:

    ; 爆発の更新
    call    GroundUpdateBomb

    ; レジスタの復帰
    
    ; 終了
    ret

; 地面を描画する
;
_GroundRender::

    ; レジスタの保存

    ; 地面の描画
    ld      hl, #(_ground + GROUND_FLAG)
    bit     #GROUND_FLAG_PRINT_VIEW_BIT, (hl)
    jr      z, 10$
    res     #GROUND_FLAG_PRINT_VIEW_BIT, (hl)
    call    GroundPrintView
    jr      11$
10$:
    ld      hl, #11$
    push    hl
    ld      a, (_camera + CAMERA_DIRECTION)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #groundPrintProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
11$:

    ; 爆発の描画
    call    GroundPrintBomb

    ; レジスタの復帰

    ; 終了
    ret

; 地面を作成する
;
_GroundBuild::

    ; レジスタの保存

    ; 背景の作成
    call    GroundBuildBack

    ; エリアの作成
    call    GroundBuildArea

    ; セルの作成
    call    GroundBuildCell

    ; パスの作成
    call    GroundBuildPath

    ; 地上物の作成
    call    GroundBuildObject

    ; 全画面の描画
    ld      hl, #(_ground + GROUND_FLAG)
    set     #GROUND_FLAG_PRINT_VIEW_BIT, (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 背景を作成する
;
GroundBuildBack:

    ; レジスタの保存

    ; エリアの走査
    ld      hl, #groundCell
    ld      b, #GROUND_AREA_SIZE_Y
10$:
    push    bc
    ld      b, #GROUND_AREA_SIZE_X
11$:
    push    bc
    ld      de, #groundAreaCell
    ld      b, #GROUND_AREA_CELL_SIZE_Y
12$:
    push    bc
    ld      b, #GROUND_AREA_CELL_SIZE_X
13$:
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    djnz    13$
    ld      bc, #(GROUND_CELL_SIZE_X - GROUND_AREA_CELL_SIZE_X)
    add     hl, bc
    pop     bc
    djnz    12$
    ld      bc, #-(GROUND_CELL_SIZE_X * GROUND_AREA_CELL_SIZE_Y - GROUND_AREA_CELL_SIZE_X)
    add     hl, bc
    pop     bc
    djnz    11$
    ld      bc, #(GROUND_CELL_SIZE_X * (GROUND_AREA_CELL_SIZE_Y - 0x0001))
    add     hl, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; エリアを作成する
;
GroundBuildArea:

    ; レジスタの保存

    ; エリアの初期化
    ld      hl, #groundAreaDefault
    ld      de, #groundArea
    ld      bc, #(GROUND_AREA_SIZE_X * GROUND_AREA_SIZE_Y)
    ldir

    ; エリアを混ぜる
    ld      de, #groundArea
    ld      b, #(GROUND_AREA_SIZE_X * GROUND_AREA_SIZE_Y)
10$:
    push    bc
    call    _SystemGetRandom
    and     #(GROUND_AREA_SIZE_X * GROUND_AREA_SIZE_Y - 0x01)
    ld      c, a
    ld      b, #0x00
    ld      hl, #groundArea
    add     hl, bc
    ld      a, (hl)
    ld      b, a
    and     #GROUND_AREA_TYPE_MASK
    cp      #GROUND_AREA_TYPE_LARGE_0
    jr      nc, 11$
    ld      a, (de)
    ld      c, a
    and     #GROUND_AREA_TYPE_MASK
    cp      #GROUND_AREA_TYPE_LARGE_0
    jr      nc, 11$
    ld      (hl), c
    ld      a, b
    ld      (de), a
11$:
    inc     de
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する
;
GroundBuildCell:

    ; レジスタの保存

    ; エリアの走査
    ld      hl, #groundArea
    ld      bc, #(((GROUND_AREA_SIZE_X * GROUND_AREA_SIZE_Y) << 8) | 0x00)
100$:
    ld      a, (hl)
    and     #GROUND_AREA_TYPE_MASK
    jr      z, 190$

    ; セルの展開
    push    hl
    push    bc
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #groundAreaCell
    add     hl, de
    ex      de, hl
    ld      a, c
    and     #0x38
    rrca
    rrca
    ld      b, a
    ld      a, c
    and     #0x07
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      hl, #groundCell
    add     hl, bc
    ld      b, #GROUND_AREA_CELL_SIZE_Y
110$:
    push    bc
    ld      b, #GROUND_AREA_CELL_SIZE_X
111$:
    ld      a, (de)
    or      a
    jr      z, 112$
    ld      (hl), a
112$:
    inc     hl
    inc     de
    djnz    111$
    ld      bc, #(GROUND_CELL_SIZE_X - GROUND_AREA_CELL_SIZE_X)
    add     hl, bc
    pop     bc
    djnz    110$
    pop     bc
    pop     hl

    ; 次のエリアへ
190$:
    inc     hl
    inc     c
    djnz    100$

    ; レジスタの復帰

    ; 終了
    ret

; パスを作成する
;
GroundBuildPath:

    ; レジスタの保存

    ; パスをつなぐ
    ld      c, #0x00
100$:
    ld      b, #0x00
    ld      hl, #groundArea
    add     hl, bc
    ld      a, (hl)
    and     #GROUND_AREA_TYPE_MASK
    jr      z, 190$
    ld      a, c
    add     a, #0x08
    and     #0x38
    ld      e, a
    ld      a, c
    and     #0x07
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #groundArea
    add     hl, de
    ld      a, (hl)
    and     #GROUND_AREA_TYPE_MASK
    call    nz, 110$
    ld      a, c
    and     #0x38
    ld      e, a
    ld      a, c
    inc     a
    and     #0x07
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #groundArea
    add     hl, de
    ld      a, (hl)
    and     #GROUND_AREA_TYPE_MASK
    call    nz, 120$
    jr      190$

    ; 下につなぐ
110$:
    call    130$
    ld      b, #GROUND_AREA_CELL_SIZE_Y
111$:
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
;   and     #GROUND_CELL_TYPE_MASK
    cp      #GROUND_CELL_TYPE_SPACE
    jr      z, 112$
    cp      #GROUND_CELL_TYPE_EDGE
    jr      c, 113$
112$:
    ld      (hl), #GROUND_CELL_TYPE_PATH_VERTICAL
113$:
    call    GroundGetCellDown
    djnz    111$
    ret

    ; 右につなぐ
120$:
    call    130$
    ld      b, #GROUND_AREA_CELL_SIZE_X
121$:
    push    bc
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
;   and     #GROUND_CELL_TYPE_MASK
    cp      #GROUND_CELL_TYPE_SPACE
    jr      z, 122$
    cp      #GROUND_CELL_TYPE_EDGE
    jr      c, 123$
122$:
    ld      (hl), #GROUND_CELL_TYPE_PATH_HORIZON
123$:
    call    GroundGetCellRight
    pop     bc
    djnz    121$
    ret

    ; セル位置の取得
130$:
    ld      a, c
    and     #0x38
    rrca
    rrca
    inc     a
    ld      d, a
    ld      a, c
    and     #0x07
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x04
    ld      e, a
    ret

    ; 次のエリアへ
190$:
    inc     c
    ld      a, c
    cp      #(GROUND_AREA_SIZE_X * GROUND_AREA_SIZE_Y)
    jp      c, 100$

    ; レジスタの復帰

    ; 終了
    ret

; 地上物を作成する
;
GroundBuildObject:

    ; レジスタの保存

    ; コアの初期化
    ld      hl, #0x0000
    ld      (groundCore + GROUND_CORE_CELL_L), hl
    ld      a, #GROUND_CORE_LIFE_MAXIMUM
    ld      (groundCore + GROUND_CORE_LIFE), a
    xor     a
    ld      (groundCore + GROUND_CORE_FRAME), a

    ; ベースの初期化
    xor     a
    ld      (groundBaseEntry), a

    ; セルの走査
    ld      hl, #groundCell
    ld      de, #0x0000
    ld      bc, #(GROUND_CELL_SIZE_X * GROUND_CELL_SIZE_Y)
10$:
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    cp      #GROUND_CELL_TYPE_CORE_CLOSE
    jr      z, 11$
    cp      #GROUND_CELL_TYPE_BASE_CLOSE
    jr      z, 12$
    cp      #GROUND_CELL_TYPE_BASE_OPEN
    jr      z, 12$
    jr      19$
11$:
    ld      (groundCore + GROUND_CORE_CELL_L), de
    jr      19$
12$:
    push    hl
    ld      hl, #groundBaseEntry
    inc     (hl)
    pop     hl
;   jr      19$
19$:
    inc     hl
    inc     de
    dec     bc
    ld      a, b
    or      c
    jr      nz, 10$

    ; レジスタの復帰

    ; 終了
    ret

; セル位置を取得する
;
GroundGetCellUp:

    ; レジスタの保存

    ; de < セル位置
    ; de > 上のセル位置

    ; セル位置の取得
    ld      a, e
    sub     #0x40
    ld      e, a
    ld      a, d
    sbc     #0x00
    and     #0x0f
    ld      d, a
    
    ; レジスタの復帰

    ; 終了
    ret

GroundGetCellDown:

    ; レジスタの保存

    ; de < セル位置
    ; de > 下のセル位置

    ; セル位置の取得
    ld      a, e
    add     a, #0x40
    ld      e, a
    ld      a, d
    adc     a, #0x00
    and     #0x0f
    ld      d, a
    
    ; レジスタの復帰

    ; 終了
    ret

GroundGetCellLeft:

    ; レジスタの保存

    ; de < セル位置
    ; de > 左のセル位置

    ; セル位置の取得
    ld      a, e
    push    af
    dec     a
    and     #0x3f
    ld      e, a
    pop     af
    and     #0xc0
    add     a, e
    ld      e, a
    
    ; レジスタの復帰

    ; 終了
    ret

GroundGetCellRight:

    ; レジスタの保存

    ; de < セル位置
    ; de > 右のセル位置

    ; セル位置の取得
    ld      a, e
    push    af
    inc     a
    and     #0x3f
    ld      e, a
    pop     af
    and     #0xc0
    add     a, e
    ld      e, a
    
    ; レジスタの復帰

    ; 終了
    ret

; コアが存在するかどうかを判定する
;
_GroundIsCore::

    ; レジスタの保存

    ; cf > 1 = コアが存在

    ; コアの判定
    ld      a, (groundCore + GROUND_CORE_LIFE)
    or      a
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの開始位置を取得する
;
_GroundGetStartPosition::

    ; レジスタの保存
    push    hl
    push    bc

    ; de > 開始位置
    
    ; エリアの検索
    ld      hl, #groundArea
    ld      bc, #(((GROUND_AREA_SIZE_X * GROUND_AREA_SIZE_Y) << 8) | 0x00)
10$:
    ld      a, (hl)
    and     #GROUND_AREA_EVENT_MASK
    cp      #GROUND_AREA_EVENT_START
    jr      z, 11$
    inc     hl
    inc     c
    djnz    10$
    ld      de, #0x0000
    jr      19$
11$:
    ld      a, c
    and     #0x38
    add     a, a
    add     a, #0x08
    ld      d, a
    ld      a, c
    and     #0x07
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x08
    ld      e, a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 地上物とのヒット判定を行う
;
_GroundHit::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < 位置

    ; セルの取得
    ld      c, e
    ld      b, d
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    bit     #0x00, b
    jr      nz, 10$
    bit     #0x00, c
    jr      z, 11$
    jr      12$
10$:
    bit     #0x00, c
    jr      z, 13$
    jr      14$

    ; X:0, Y:0 の判定
11$:
    call    200$
    call    GroundGetCellUp
    call    200$
    call    GroundGetCellLeft
    call    200$
    call    GroundGetCellDown
    call    200$
    jp      90$

    ; X:1, Y:0 の判定
12$:
    call    200$
    push    de
    call    GroundGetCellLeft
    call    200$
    pop     de
    push    de
    call    GroundGetCellRight
    call    200$
    pop     de
    call    GroundGetCellUp
    call    200$
    push    de
    call    GroundGetCellLeft
    call    200$
    pop     de
    call    GroundGetCellRight
    call    200$
    jp      90$

    ; X:0, Y:1 の判定
13$:
    push    de
    call    200$
    call    GroundGetCellLeft
    call    200$
    pop     de
    push    de
    call    GroundGetCellUp
    call    200$
    call    GroundGetCellLeft
    call    200$
    pop     de
    call    GroundGetCellDown
    call    200$
    call    GroundGetCellLeft
    call    200$
    jp      90$

    ; X:1, Y:1 の判定
14$:
    call    200$
    push    de
    call    GroundGetCellUp
    call    200$
    pop     de
    push    de
    call    GroundGetCellDown
    call    200$
    pop     de
    push    de
    call    GroundGetCellLeft
    call    200$
    pop     de
    call    GroundGetCellRight
    call    200$
    jp      90$

    ; セルの判定
200$:
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    cp      #GROUND_CELL_TYPE_CORE_OPEN
    jr      z, 210$
    cp      #GROUND_CELL_TYPE_BASE_OPEN
    jr      z, 220$
    cp      #GROUND_CELL_TYPE_TANK_OPEN
    jr      z, 230$
    jp      290$

    ; コアへのヒット
210$:
    ld      hl, #(groundCore + GROUND_CORE_LIFE)
    dec     (hl)
    jp      nz, 280$
    ld      a, #GROUND_CELL_TYPE_CORE_DESTROY
    call    GroundChangeCell
    jp      270$

    ; ベースへのヒット
220$:
    ld      a, (hl)
    and     #GROUND_CELL_LIFE_MASK
    jr      z, 221$
    dec     (hl)
    jp      280$
221$:
    ld      a, #GROUND_CELL_TYPE_BASE_DESTROY
    call    GroundChangeCell
    ld      hl, #groundBaseEntry
    dec     (hl)
    jr      nz, 222$
    push    de
    ld      de, (groundCore + GROUND_CORE_CELL_L)
    ld      a, #GROUND_CELL_TYPE_CORE_OPEN
    call    GroundChangeCell
    ld      de, (groundCore + GROUND_CORE_CELL_L)
    call    GroundGetCellUp
    ld      a, #(GROUND_CELL_TYPE_TERMINAL_OPEN + 0x00)
    call    GroundChangeCell
    ld      de, (groundCore + GROUND_CORE_CELL_L)
    call    GroundGetCellDown
    ld      a, #(GROUND_CELL_TYPE_TERMINAL_OPEN + 0x04)
    call    GroundChangeCell
    ld      de, (groundCore + GROUND_CORE_CELL_L)
    call    GroundGetCellLeft
    ld      a, #(GROUND_CELL_TYPE_TERMINAL_OPEN + 0x08)
    call    GroundChangeCell
    ld      de, (groundCore + GROUND_CORE_CELL_L)
    call    GroundGetCellRight
    ld      a, #(GROUND_CELL_TYPE_TERMINAL_OPEN + 0x0c)
    call    GroundChangeCell
    pop     de
;   jr      222$
222$:
    jr      270$

    ; タンクへのヒット
230$:
    ld      a, #GROUND_CELL_TYPE_TANK_DESTROY
    call    GroundChangeCell
    push    de
    call    GroundGetCellUp
    call    240$
    pop     de
    jr      c, 239$
    push    de
    call    GroundGetCellDown
    call    240$
    pop     de
    jr      c, 239$
    push    de
    call    GroundGetCellLeft
    call    240$
    pop     de
    jr      c, 239$
    push    de
    call    GroundGetCellRight
    call    240$
    pop     de
;   jr      c, 239$
239$:
    jr      270$

    ; タンクに接するベースの更新
240$:
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    cp      #GROUND_CELL_TYPE_BASE_CLOSE
    jr      z, 241$
    or      a
    jr      249$
241$:
    ld      a, (hl)
    and     #GROUND_CELL_LIFE_MASK
    jr      z, 242$
    dec     (hl)
    jr      248$
242$:
    ld      a, #(GROUND_CELL_TYPE_BASE_OPEN + GROUND_CELL_LIFE_BASE)
    call    GroundChangeCell
248$:
    scf
;   jr      249$
249$:
    ret

    ; 爆発の登録
270$:
    push    de
    ld      a, e
    add     a, a
    rl      d
    add     a, a
    rl      d
    sla     d
    inc     d
    srl     a
    ld      e, a
    inc     e
    ld      a, #GROUND_BOMB_TYPE_BOMB
    call    GroundEntryBomb
    pop     de
    jr      290$

    ; ヒットの登録
280$:
    push    de
    ld      e, c
    ld      d, b
    ld      a, #GROUND_BOMB_TYPE_HIT
    call    GroundEntryBomb
    pop     de
;   jr      290$

    ; 判定の完了
290$:
    ret

    ; ヒットの完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; セルを書き換える
;
GroundChangeCell:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < セル位置
    ; a  < 書き換え後のセル

    ; セルの書き換え
    ld      hl, #groundCell
    add     hl, de
    ld      (hl), a
    and     #GROUND_CELL_TYPE_MASK
    ld      c, a

    ; パターンネームの書き換え
    push    bc
    ld      bc, (_camera + CAMERA_LAST_X)
    ld      a, e
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      a, d
    add     a, a
    sub     b
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    ld      d, a
    ld      a, e
    and     #0x3f
    add     a, a
    sub     c
    and     #(GROUND_NAME_SIZE_X - 0x01)
    ld      e, a
    pop     bc
    cp      #(GROUND_NAME_SIZE_X - 0x01)
    jr      z, 310$
    cp      #(CAMERA_VIEW_NAME_SIZE_X - 0x01)
    jr      c, 320$
    jp      z, 330$
    jp      390$

    ; 左の書き換え
310$:
    ld      a, d
    cp      #(GROUND_NAME_SIZE_Y - 0x01)
    jr      z, 311$
    cp      #(CAMERA_VIEW_NAME_SIZE_Y - 0x01)
    jr      c, 312$
    jr      z, 313$
    jp      390$

    ; 左上の書き換え
311$:
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    ld      a, c
    add     a, #0x03
    ld      (hl), a
    jp      390$

    ; 左中の書き換え
312$:
    xor     a
    srl     d
    rra
    srl     d
    rra
    srl     d
    rra
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    add     hl, de
    ld      a, c
    inc     a
    ld      (hl), a
    ld      bc, #0x0020
    add     hl, bc
    add     a, #0x02
    ld      (hl), a
    jp      390$

    ; 左下の書き換え
313$:
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x01) * 0x0020))
    ld      a, c
    inc     a
    ld      (hl), a
    jr      390$

    ; 中の書き換え
320$:
    ld      a, d
    cp      #(GROUND_NAME_SIZE_Y - 0x01)
    jr      z, 321$
    cp      #(CAMERA_VIEW_NAME_SIZE_Y - 0x01)
    jr      c, 322$
    jr      z, 323$
    jr      390$

    ; 中上の書き換え
321$:
    ld      d, #0x00
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    add     hl, de
    ld      a, c
    add     a, #0x02
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
    jr      390$

    ; 中央の書き換え
322$:
    xor     a
    srl     d
    rra
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    add     hl, de
    ld      a, c
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
    ld      bc, #(0x0020 - 0x0001)
    add     hl, bc
    inc     a
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
    jr      390$

    ; 中下の書き換え
323$:
    ld      d, #0x00
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x01) * 0x0020))
    add     hl, de
    ld      a, c
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
    jr      390$

    ; 右の書き換え
330$:
    ld      a, d
    cp      #(GROUND_NAME_SIZE_Y - 0x01)
    jr      z, 331$
    cp      #(CAMERA_VIEW_NAME_SIZE_Y - 0x01)
    jr      c, 332$
    jr      z, 333$
    jr      390$

    ; 右上の書き換え
331$:
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (CAMERA_VIEW_NAME_SIZE_X - 0x01))
    ld      a, c
    add     a, #0x02
    ld      (hl), a
    jr      390$

    ; 右央の書き換え
332$:
    xor     a
    srl     d
    rra
    srl     d
    rra
    srl     d
    rra
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (CAMERA_VIEW_NAME_SIZE_X - 0x01))
    add     hl, de
    ld      a, c
    ld      (hl), a
    ld      bc, #0x0020
    add     hl, bc
    add     a, #0x02
    ld      (hl), a
    jr      390$

    ; 右下の書き換え
333$:
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x01) * 0x0020) + (CAMERA_VIEW_NAME_SIZE_X - 0x01))
    ld      a, c
    ld      (hl), a
;   jr      390$

390$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 爆発を更新する
;
GroundUpdateBomb:

    ; レジスタの保存

    ; 爆発の走査
    ld      ix, #groundBomb
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      b, #GROUND_BOMB_ENTRY
10$:
    push    bc

    ; 爆発の存在
    ld      a, GROUND_BOMB_TYPE(ix)
    or      a
    jr      z, 19$

    ; 位置の判定
    ld      a, GROUND_BOMB_POSITION_X(ix)
    sub     e
    and     #(GROUND_NAME_SIZE_X - 0x01)
    cp      #(CAMERA_VIEW_NAME_SIZE_X + 0x01)
    jr      nc, 18$
    ld      a, GROUND_BOMB_POSITION_Y(ix)
    sub     d
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    cp      #(CAMERA_VIEW_NAME_SIZE_Y + 0x01)
    jr      nc, 18$

    ; アニメーションの更新
    inc     GROUND_BOMB_ANIMATION(ix)
    ld      a, GROUND_BOMB_ANIMATION(ix)
    cp      #GROUND_BOMB_ANIMATION_LENGTH
    jr      c, 19$

    ; 爆発の削除
18$:
    ld      GROUND_BOMB_TYPE(ix), #GROUND_BOMB_TYPE_NULL
;   jr      19$

    ; 次の爆発へ
19$:
    ld      bc, #GROUND_BOMB_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; 爆発を登録する
;
GroundEntryBomb:

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; de < 位置
    ; a  < 種類

    ; 位置の判定
    ld      c, a
    ld      a, (_camera + CAMERA_POSITION_X)
    sub     e
    neg
    and     #(GROUND_NAME_SIZE_X - 0x01)
    cp      #(CAMERA_VIEW_NAME_SIZE_X + 0x01)
    jr      nc, 19$
    ld      a, (_camera + CAMERA_POSITION_Y)
    sub     d
    neg
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    cp      #(CAMERA_VIEW_NAME_SIZE_Y + 0x01)
    jr      nc, 19$

    ; 爆発の登録
    ld      ix, #groundBomb
    ex      de, hl
    ld      de, #GROUND_BOMB_LENGTH
    ld      b, #GROUND_BOMB_ENTRY
10$:
    ld      a, GROUND_BOMB_TYPE(ix)
    or      a
    jr      z, 11$
    add     ix, de
    djnz    10$
    jr      19$
11$:
    ld      GROUND_BOMB_TYPE(ix), c
    ld      GROUND_BOMB_POSITION_X(ix), l
    ld      GROUND_BOMB_POSITION_Y(ix), h
    ld      GROUND_BOMB_ANIMATION(ix), #GROUND_BOMB_ANIMATION_NULL

    ; SE の再生
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySe
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 全画面の更新を設定する
;
_GroundSetPrintView::

    ; レジスタの保存
    push    hl

    ; 描画の設定
    ld      hl, #(_ground + GROUND_FLAG)
    set     #GROUND_FLAG_PRINT_VIEW_BIT, (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 何も描画しない
;
GroundPrintNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 地面を描画する
;
GroundPrintView:

    ; レジスタの保存

    ; カメラ位置別の処理
    ld      de, (_camera + CAMERA_POSITION_X)
    bit     #0x00, d
    jr      nz, 100$
    bit     #0x00, e
    jr      z, 110$
    jr      120$
100$:
    bit     #0x00, e
    jp      z, 130$
    jp      140$

    ; X:0, Y:0
110$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    ld      b, #CAMERA_VIEW_CELL_SIZE_Y
111$:
    push    bc
    push    de
    ld      b, #CAMERA_VIEW_CELL_SIZE_X
112$:
    push    bc
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      bc, #(0x0020 - 0x0001)
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
    add     hl, bc
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    or      a
    sbc     hl, bc
    call    GroundGetCellRight
    pop     bc
    djnz    112$
    ld      bc, #(0x0040 - CAMERA_VIEW_NAME_SIZE_X)
    add     hl, bc
    pop     de
    call    GroundGetCellDown
    pop     bc
    djnz    111$
    jp      190$
    
    ; X:1, Y:0
120$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    ld      b, #CAMERA_VIEW_CELL_SIZE_Y
121$:
    push    bc
    push    de
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    inc     a
    ld      bc, #0x0020
    ld      (hl), a
    add     a, #0x02
    add     hl, bc
    ld      (hl), a
;   inc     a
    dec     c
    or      a
    sbc     hl, bc
    call    GroundGetCellRight
    ld      b, #(CAMERA_VIEW_CELL_SIZE_X - 0x01)
122$:
    push    bc
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      bc, #(0x0020 - 0x0001)
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
    add     hl, bc
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    or      a
    sbc     hl, bc
    call    GroundGetCellRight
    pop     bc
    djnz    122$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      bc, #0x0020
    ld      (hl), a
    add     a, #0x02
    add     hl, bc
    ld      (hl), a
;   inc     a
;   inc     hl
    ld      bc, #(0x0020 - (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    pop     de
    call    GroundGetCellDown
    pop     bc
    djnz    121$
    jp      190$
    
    ; X:0, Y:1
130$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    push    de
    ld      b, #CAMERA_VIEW_CELL_SIZE_X
131$:
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x02
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    djnz    131$
    ld      bc, #(0x0020 - CAMERA_VIEW_NAME_SIZE_X)
    add     hl, bc
    pop     de
    call    GroundGetCellDown
    ld      b, #(CAMERA_VIEW_CELL_SIZE_Y - 0x01)
132$:
    push    bc
    push    de
    ld      b, #CAMERA_VIEW_CELL_SIZE_X
133$:
    push    bc
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      bc, #(0x0020 - 0x0001)
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
    add     hl, bc
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    or      a
    sbc     hl, bc
    call    GroundGetCellRight
    pop     bc
    djnz    133$
    ld      bc, #(0x0040 - CAMERA_VIEW_NAME_SIZE_X)
    add     hl, bc
    pop     de
    call    GroundGetCellDown
    pop     bc
    djnz    132$
    ld      b, #CAMERA_VIEW_CELL_SIZE_X
134$:
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    djnz    134$
    jp      190$
    
    ; X:1, Y:1
140$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    push    de
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x03
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    ld      b, #(CAMERA_VIEW_CELL_SIZE_X - 0x01)
141$:
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x02
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    djnz    141$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x02
    ld      (hl), a
;   inc     a
    ld      bc, #(0x0020 - (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    pop     de
    call    GroundGetCellDown
    ld      b, #(CAMERA_VIEW_CELL_SIZE_Y - 0x01)
142$:
    push    bc
    push    de
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    inc     a
    ld      bc, #0x0020
    ld      (hl), a
    add     a, #0x02
    add     hl, bc
    ld      (hl), a
;   inc     a
    dec     c
    or      a
    sbc     hl, bc
    call    GroundGetCellRight
    ld      b, #(CAMERA_VIEW_CELL_SIZE_X - 0x01)
143$:
    push    bc
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      bc, #(0x0020 - 0x0001)
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
    add     hl, bc
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    or      a
    sbc     hl, bc
    call    GroundGetCellRight
    pop     bc
    djnz    143$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      bc, #0x0020
    ld      (hl), a
    add     a, #0x02
    add     hl, bc
    ld      (hl), a
;   inc     a
;   inc     hl
    ld      bc, #(0x0020 - (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    pop     de
    call    GroundGetCellDown
    pop     bc
    djnz    142$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    inc     a
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    ld      b, #(CAMERA_VIEW_CELL_SIZE_X - 0x01)
144$:
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    djnz    144$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
;   inc     a
;   inc     hl
;   jr      190$
    
    ; 描画の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; 上スクロールを描画する
;
GroundPrintScrollUp:

    ; レジスタの保存

    ; スクロール
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x0002) * 0x0020))
    ld      de, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x0001) * 0x0020))
    ld      a, #(CAMERA_VIEW_NAME_SIZE_Y - 0x01)
10$:
    ld      bc, #CAMERA_VIEW_NAME_SIZE_X
    ldir
    ld      bc, #-(0x0020 + CAMERA_VIEW_NAME_SIZE_X)
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; 行を埋める
    call    GroundPrintLineUp

    ; レジスタの復帰

    ; 終了
    ret

; 下スクロールを描画する
;
GroundPrintScrollDown:

    ; レジスタの保存

    ; スクロール
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (0x0001 * 0x0020))
    ld      de, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (0x0000 * 0x0020))
    ld      a, #(CAMERA_VIEW_NAME_SIZE_Y - 0x01)
10$:
    ld      bc, #CAMERA_VIEW_NAME_SIZE_X
    ldir
    ld      bc, #(0x0020 - CAMERA_VIEW_NAME_SIZE_X)
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; 行を埋める
    call    GroundPrintLineDown

    ; レジスタの復帰

    ; 終了
    ret

; 左スクロールを描画する
;
GroundPrintScrollLeft:

    ; レジスタの保存

    ; スクロール
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (CAMERA_VIEW_NAME_SIZE_X - 0x0002))
    ld      de, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    ld      a, #CAMERA_VIEW_NAME_SIZE_Y
10$:
    ld      bc, #(CAMERA_VIEW_NAME_SIZE_X - 0x0001)
    lddr
    ld      bc, #(0x0020 + (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; 列を埋める
    call    GroundPrintColumnLeft

    ; レジスタの復帰

    ; 終了
    ret

; 右スクロールを描画する
;
GroundPrintScrollRight:

    ; レジスタの保存

    ; スクロール
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + 0x0001)
    ld      de, #(_patternName + CAMERA_VIEW_NAME_OFFSET + 0x0000)
    ld      a, #CAMERA_VIEW_NAME_SIZE_Y
10$:
    ld      bc, #(CAMERA_VIEW_NAME_SIZE_X - 0x0001)
    ldir
    ld      bc, #(0x0020 - (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; 列を埋める
    call    GroundPrintColumnRight

    ; レジスタの復帰

    ; 終了
    ret

; 左上スクロールを描画する
;
GroundPrintScrollUpLeft:

    ; レジスタの保存

    ; スクロール
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x0002) * 0x0020) + 0x0000)
    ld      de, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x0001) * 0x0020) + 0x0001)
    ld      a, #(CAMERA_VIEW_NAME_SIZE_Y - 0x0001)
10$:
    ld      bc, #(CAMERA_VIEW_NAME_SIZE_X - 0x0001)
    ldir
    ld      bc, #-(0x0020 + (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; 行列を埋める
    call    GroundPrintLineUp
    call    GroundPrintColumnLeft

    ; レジスタの復帰

    ; 終了
    ret

; 右上スクロールを描画する
;
GroundPrintScrollUpRight:

    ; レジスタの保存

    ; スクロール
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x0002) * 0x0020) + 0x0001)
    ld      de, #(_patternName + CAMERA_VIEW_NAME_OFFSET + ((CAMERA_VIEW_NAME_SIZE_Y - 0x0001) * 0x0020) + 0x0000)
    ld      a, #(CAMERA_VIEW_NAME_SIZE_Y - 0x0001)
10$:
    ld      bc, #(CAMERA_VIEW_NAME_SIZE_X - 0x0001)
    ldir
    ld      bc, #-(0x0020 + (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; 行列を埋める
    call    GroundPrintLineUp
    call    GroundPrintColumnRight

    ; レジスタの復帰

    ; 終了
    ret

; 左下スクロールを描画する
;
GroundPrintScrollDownLeft:

    ; レジスタの保存

    ; スクロール
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (0x0001 * 0x0020) + 0x0000)
    ld      de, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (0x0000 * 0x0020) + 0x0001)
    ld      a, #(CAMERA_VIEW_NAME_SIZE_Y - 0x0001)
10$:
    ld      bc, #(CAMERA_VIEW_NAME_SIZE_X - 0x0001)
    ldir
    ld      bc, #(0x0020 - (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; 行列を埋める
    call    GroundPrintLineDown
    call    GroundPrintColumnLeft

    ; レジスタの復帰

    ; 終了
    ret

; 右下スクロールを描画する
;
GroundPrintScrollDownRight:

    ; レジスタの保存

    ; スクロール
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (0x0001 * 0x0020) + 0x0001)
    ld      de, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (0x0000 * 0x0020) + 0x0000)
    ld      a, #(CAMERA_VIEW_NAME_SIZE_Y - 0x0001)
10$:
    ld      bc, #(CAMERA_VIEW_NAME_SIZE_X - 0x0001)
    ldir
    ld      bc, #(0x0020 - (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; 行列を埋める
    call    GroundPrintLineDown
    call    GroundPrintColumnRight

    ; レジスタの復帰

    ; 終了
    ret

; 行を埋める
;
GroundPrintLine:

    ; レジスタの保存

    ; de < セル位置
    ; hl < 描画位置

    ; セル位置別の処理
    bit     #0x00, d
    jr      nz, 100$
    bit     #0x00, e
    jr      z, 110$
    jr      120$
100$:
    bit     #0x00, e
    jr      z, 130$
    jp      140$

    ; X:0, Y:0
110$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      b, #CAMERA_VIEW_CELL_SIZE_X
111$:
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    djnz    111$
    jp      190$

    ; X:1, Y:0
120$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    inc     a
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    ld      b, #(CAMERA_VIEW_CELL_SIZE_X - 0x01)
121$:
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    djnz    121$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
;   inc     a
;   inc     hl
    jr      190$

    ; X:0, Y:1
130$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      b, #CAMERA_VIEW_CELL_SIZE_X
131$:
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x02
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    djnz    131$
    jr      190$

    ; X:1, Y:1
140$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x03
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    ld      b, #(CAMERA_VIEW_CELL_SIZE_X - 0x01)
141$:
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x02
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
;   inc     a
    inc     hl
    call    GroundGetCellRight
    djnz    141$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x02
    ld      (hl), a
;   inc     a
;   inc     hl
;   jr      190$

    ; 描画の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

GroundPrintLineUp:

    ; レジスタの保存

    ; 行を埋める
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    call    GroundPrintLine

    ; レジスタの復帰

    ; 終了
    ret

GroundPrintLineDown:

    ; レジスタの保存

    ; 行を埋める
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      a, #(CAMERA_VIEW_NAME_SIZE_Y - 0x01)
    add     a, d
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    ld      d, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (0x0020 * (CAMERA_VIEW_NAME_SIZE_Y - 0x0001)))
    call    GroundPrintLine

    ; レジスタの復帰

    ; 終了
    ret

; 列を埋める
;
GroundPrintColumn:

    ; レジスタの保存

    ; de < セル位置
    ; hl < 描画位置

    ; セル位置別の処理
    ld      bc, #0x0020
    bit     #0x00, d
    jr      nz, 100$
    bit     #0x00, e
    jr      z, 110$
    jr      120$
100$:
    bit     #0x00, e
    jr      z, 130$
    jp      140$

    ; X:0, Y:0
110$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      a, #CAMERA_VIEW_CELL_SIZE_Y
111$:
    push    af
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
    add     a, #0x02
    add     hl, bc
    ld      (hl), a
;   inc     a
    add     hl, bc
    call    GroundGetCellDown
    pop     af
    dec     a
    jr      nz, 111$
    jp      190$

    ; X:1, Y:0
120$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      a, #CAMERA_VIEW_CELL_SIZE_Y
121$:
    push    af
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    inc     a
    ld      (hl), a
    add     a, #0x02
    add     hl, bc
    ld      (hl), a
;   inc     a
    add     hl, bc
    call    GroundGetCellDown
    pop     af
    dec     a
    jr      nz, 121$
    jp      190$

    ; X:0, Y:1
130$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x02
    ld      (hl), a
;   inc     a
    add     hl, bc
    call    GroundGetCellDown
    ld      a, #(CAMERA_VIEW_CELL_SIZE_Y - 0x01)
131$:
    push    af
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
    add     a, #0x02
    add     hl, bc
    ld      (hl), a
;   inc     a
    add     hl, bc
    call    GroundGetCellDown
    pop     af
    dec     a
    jr      nz, 131$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    ld      (hl), a
;   inc     a
;   add     hl, bc
    jr      190$

    ; X:1, Y:1
140$:
    srl     e
    srl     d
    xor     a
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    add     a, #0x03
    ld      (hl), a
;   inc     a
    add     hl, bc
    call    GroundGetCellDown
    ld      a, #(CAMERA_VIEW_CELL_SIZE_Y - 0x01)
141$:
    push    af
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    inc     a
    ld      (hl), a
    add     a, #0x02
    add     hl, bc
    ld      (hl), a
;   inc     a
    add     hl, bc
    call    GroundGetCellDown
    pop     af
    dec     a
    jr      nz, 141$
    push    hl
    ld      hl, #groundCell
    add     hl, de
    ld      a, (hl)
    and     #GROUND_CELL_TYPE_MASK
    pop     hl
    inc     a
    ld      (hl), a
;   inc     a
;   add     hl, bc
;   jr      190$

    ; 描画の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

GroundPrintColumnLeft:

    ; レジスタの保存

    ; 行を埋める
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET)
    call    GroundPrintColumn

    ; レジスタの復帰

    ; 終了
    ret

GroundPrintColumnRight:

    ; レジスタの保存

    ; 行を埋める
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      a, #(CAMERA_VIEW_NAME_SIZE_X - 0x01)
    add     a, e
    and     #(GROUND_NAME_SIZE_X - 0x01)
    ld      e, a
    ld      hl, #(_patternName + CAMERA_VIEW_NAME_OFFSET + (CAMERA_VIEW_NAME_SIZE_X - 0x0001))
    call    GroundPrintColumn

    ; レジスタの復帰

    ; 終了
    ret

; 爆発を描画する
;
GroundPrintBomb:

    ; レジスタの保存

    ; 爆発の描画
    ld      ix, #groundBomb
    ld      hl, #(_sprite + GAME_SPRITE_GROUND)
    ld      de, (_camera + CAMERA_POSITION_X)
    ld      b, #GROUND_BOMB_ENTRY
10$:
    push    bc
    ld      a, GROUND_BOMB_TYPE(ix)
    or      a
    jr      z, 19$
    ld      a, GROUND_BOMB_POSITION_Y(ix)
    sub     d
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    add     a, a
    add     a, a
    add     a, a
    add     a, #(CAMERA_VIEW_SPRITE_OFFSET_Y + GROUND_BOMB_SPRITE_Y)
    ld      (hl), a
    inc     hl
    ld      a, GROUND_BOMB_POSITION_X(ix)
    sub     e
    and     #(GROUND_NAME_SIZE_X - 0x01)
    add     a, a
    add     a, a
    add     a, a
    add     a, #(CAMERA_VIEW_SPRITE_OFFSET_X + GROUND_BOMB_SPRITE_X)
    ld      (hl), a
    inc     hl
    ld      a, GROUND_BOMB_ANIMATION(ix)
    and     #0xfe
    add     a, a
    add     a, GROUND_BOMB_TYPE(ix)
    ld      (hl), a
    inc     hl
    ld      (hl), #GROUND_BOMB_SPRITE_COLOR
    inc     hl
19$:
    ld      bc, #GROUND_BOMB_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 地面の初期値
;
groundDefault:

    .db     GROUND_STATE_NULL
    .db     GROUND_FLAG_NULL

; 描画別の処理
;
groundPrintProc:

    .dw     GroundPrintNull
    .dw     GroundPrintScrollUp
    .dw     GroundPrintScrollDown
    .dw     GroundPrintScrollLeft
    .dw     GroundPrintScrollRight
    .dw     GroundPrintScrollUpLeft
    .dw     GroundPrintScrollUpRight
    .dw     GroundPrintScrollDownLeft
    .dw     GroundPrintScrollDownRight

; セル
;

; エリア
;
groundAreaDefault:

    .db     GROUND_AREA_TYPE_SMALL_0
    .db     GROUND_AREA_TYPE_SMALL_0
    .db     GROUND_AREA_TYPE_SMALL_0
    .db     GROUND_AREA_TYPE_SMALL_0
    .db     GROUND_AREA_TYPE_SMALL_1
    .db     GROUND_AREA_TYPE_SMALL_1
    .db     GROUND_AREA_TYPE_SMALL_1
    .db     GROUND_AREA_TYPE_SMALL_1

    .db     GROUND_AREA_TYPE_SMALL_1
    .db     GROUND_AREA_TYPE_SMALL_1
    .db     GROUND_AREA_TYPE_SMALL_2
    .db     GROUND_AREA_TYPE_SMALL_2
    .db     GROUND_AREA_TYPE_SMALL_2
    .db     GROUND_AREA_TYPE_SMALL_2
    .db     GROUND_AREA_TYPE_SMALL_2
    .db     GROUND_AREA_TYPE_SMALL_2

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_LARGE_0
    .db     GROUND_AREA_TYPE_LARGE_1
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_LARGE_2
    .db     GROUND_AREA_TYPE_LARGE_3
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_MEDIUM_0
    .db     GROUND_AREA_TYPE_MEDIUM_0
    .db     GROUND_AREA_TYPE_MEDIUM_1
    .db     GROUND_AREA_TYPE_MEDIUM_1
    .db     GROUND_AREA_TYPE_MEDIUM_1
    .db     GROUND_AREA_TYPE_MEDIUM_1
    .db     GROUND_AREA_TYPE_MEDIUM_1
    .db     GROUND_AREA_TYPE_MEDIUM_2

    .db     GROUND_AREA_TYPE_MEDIUM_2
    .db     GROUND_AREA_TYPE_MEDIUM_2
    .db     GROUND_AREA_TYPE_MEDIUM_2
    .db     GROUND_AREA_TYPE_MEDIUM_2
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL | GROUND_AREA_EVENT_START

; groundAreaDefault:

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_LARGE_0
    .db     GROUND_AREA_TYPE_LARGE_1
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_LARGE_2
    .db     GROUND_AREA_TYPE_LARGE_3
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL

    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL
    .db     GROUND_AREA_TYPE_NULL | GROUND_AREA_EVENT_START


groundAreaCell:

    ; GROUND_AREA_BACK
    .db     0xf8, 0x88, 0x88, 0xfc, 0xf8, 0x88, 0x88, 0xfc
    .db     0x88, 0xf8, 0xfc, 0x88, 0x88, 0xf8, 0xfc, 0x88
    .db     0x88, 0xfc, 0xf8, 0x88, 0x88, 0xfc, 0xf8, 0x88
    .db     0xfc, 0x88, 0x88, 0xf8, 0xfc, 0x88, 0x88, 0xf8
    .db     0xf8, 0x88, 0x88, 0xfc, 0xf8, 0x88, 0x88, 0xfc
    .db     0x88, 0xf8, 0xfc, 0x88, 0x88, 0xf8, 0xfc, 0x88
    .db     0x88, 0xfc, 0xf8, 0x88, 0x88, 0xfc, 0xf8, 0x88
    .db     0xfc, 0x88, 0x88, 0xf8, 0xfc, 0x88, 0x88, 0xf8
    ; GROUND_AREA_TYPE_SMALL_0 / NULL
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0xb4, 0xb0, 0xb0, 0xcc, 0xc4, 0x00
    .db     0x00, 0x00, 0xbc, 0xa0, 0x90, 0xa4, 0xe0, 0x00
    .db     0x00, 0x00, 0xd0, 0x98, 0x8c, 0x9c, 0xe0, 0x00
    .db     0x00, 0x00, 0xd0, 0xa8, 0x94, 0xac, 0xec, 0x00
    .db     0x00, 0x00, 0xd8, 0xdc, 0xc0, 0xc0, 0xe8, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; GROUND_AREA_TYPE_SMALL_1 / TANK
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0xb4, 0xb0, 0xb0, 0xcc, 0xc4, 0x00
    .db     0x00, 0x00, 0xbc, 0xa0, 0x90, 0xa4, 0xe0, 0x00
    .db     0x00, 0x00, 0xd0, 0x98, 0x80, 0x9c, 0xe0, 0x00
    .db     0x00, 0x00, 0xd0, 0xa8, 0x94, 0xac, 0xec, 0x00
    .db     0x00, 0x00, 0xd8, 0xdc, 0xc0, 0xc0, 0xe8, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; GROUND_AREA_TYPE_SMALL_2 / CORE OPEN
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0xb4, 0xb0, 0xb0, 0xcc, 0xc4, 0x00
    .db     0x00, 0x00, 0xbc, 0xa0, 0x90, 0xa4, 0xe0, 0x00
    .db     0x00, 0x00, 0xd0, 0x98, 0x79, 0x9c, 0xe0, 0x00
    .db     0x00, 0x00, 0xd0, 0xa8, 0x94, 0xac, 0xec, 0x00
    .db     0x00, 0x00, 0xd8, 0xdc, 0xc0, 0xc0, 0xe8, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; GROUND_AREA_MEDIUM_0 / NULL
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0xb4, 0xb0, 0xb0, 0xcc, 0xc4, 0x00
    .db     0x00, 0xb4, 0xb8, 0xa0, 0x90, 0xa4, 0xc8, 0xc4
    .db     0x00, 0xbc, 0xa0, 0x8c, 0x8c, 0x8c, 0xa4, 0xe0
    .db     0x00, 0xd0, 0x98, 0x8c, 0x8c, 0x8c, 0x9c, 0xe0
    .db     0x00, 0xd0, 0xa8, 0x8c, 0x8c, 0x8c, 0xac, 0xec
    .db     0x00, 0xd8, 0xd4, 0xa8, 0x94, 0xac, 0xe4, 0xe8
    .db     0x00, 0x00, 0xd8, 0xdc, 0xc0, 0xc0, 0xe8, 0x00
    ; GROUND_AREA_MEDIUM_1 / CORE OPEN
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0xb4, 0xb0, 0xb0, 0xcc, 0xc4, 0x00
    .db     0x00, 0xb4, 0xb8, 0xa0, 0x90, 0xa4, 0xc8, 0xc4
    .db     0x00, 0xbc, 0xa0, 0x8c, 0x5c, 0x8c, 0xa4, 0xe0
    .db     0x00, 0xd0, 0x98, 0x5c, 0x79, 0x5c, 0x9c, 0xe0
    .db     0x00, 0xd0, 0xa8, 0x8c, 0x5c, 0x8c, 0xac, 0xec
    .db     0x00, 0xd8, 0xd4, 0xa8, 0x94, 0xac, 0xe4, 0xe8
    .db     0x00, 0x00, 0xd8, 0xdc, 0xc0, 0xc0, 0xe8, 0x00
    ; GROUND_AREA_MEDIUM_2 / CORE CLOSE
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0xb4, 0xb0, 0xb0, 0xcc, 0xc4, 0x00
    .db     0x00, 0xb4, 0xb8, 0xa0, 0x90, 0xa4, 0xc8, 0xc4
    .db     0x00, 0xbc, 0xa0, 0x8c, 0x80, 0x8c, 0xa4, 0xe0
    .db     0x00, 0xd0, 0x98, 0x80, 0x5b, 0x80, 0x9c, 0xe0
    .db     0x00, 0xd0, 0xa8, 0x8c, 0x80, 0x8c, 0xac, 0xec
    .db     0x00, 0xd8, 0xd4, 0xa8, 0x94, 0xac, 0xe4, 0xe8
    .db     0x00, 0x00, 0xd8, 0xdc, 0xc0, 0xc0, 0xe8, 0x00
    ; GROUND_AREA_LARGE_0
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0xb4, 0xb0, 0xb0, 0xb0, 0xb0
    .db     0x00, 0x00, 0xb4, 0xb8, 0xa0, 0x90, 0x90, 0x90
    .db     0x00, 0xb4, 0xb8, 0xa0, 0x8c, 0x8c, 0x8c, 0x8c
    .db     0x00, 0xbc, 0xa0, 0x8c, 0x8c, 0x8c, 0x8c, 0x80
    .db     0x00, 0xd0, 0x98, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c
    .db     0x00, 0xd0, 0x98, 0x8c, 0x8c, 0x8c, 0x8c, 0x94
    .db     0x00, 0xd0, 0x98, 0x8c, 0x80, 0x8c, 0x9c, 0x88
    ; GROUND_AREA_LARGE_1
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0xb0, 0xb0, 0xb0, 0xb0, 0xcc, 0xc4, 0x00, 0x00
    .db     0x90, 0x90, 0x90, 0x90, 0xa4, 0xc8, 0xc4, 0x00
    .db     0x80, 0x8c, 0x8c, 0x8c, 0x8c, 0xa4, 0xc8, 0xc4
    .db     0x5b, 0x80, 0x8c, 0x8c, 0x8c, 0x8c, 0xa4, 0xe0
    .db     0x80, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x9c, 0xe0
    .db     0x94, 0x94, 0x8c, 0x8c, 0x8c, 0x8c, 0x9c, 0xe0
    .db     0x40, 0x88, 0x98, 0x8c, 0x80, 0x8c, 0x9c, 0xe0
    ; GROUND_AREA_LARGE_2
    .db     0x00, 0xd0, 0x98, 0x80, 0x5b, 0x80, 0x9c, 0x48
    .db     0x00, 0xd0, 0x98, 0x8c, 0x80, 0x8c, 0x9c, 0x88
    .db     0x00, 0xd0, 0x98, 0x8c, 0x8c, 0x8c, 0x8c, 0x90
    .db     0x00, 0xd0, 0x98, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c
    .db     0x00, 0xd0, 0xa8, 0x8c, 0x8c, 0x8c, 0x8c, 0x80
    .db     0x00, 0xd8, 0xd4, 0xa8, 0x8c, 0x8c, 0x8c, 0x8c
    .db     0x00, 0x00, 0xd8, 0xd4, 0xa8, 0x94, 0x94, 0x94
    .db     0x00, 0x00, 0x00, 0xd8, 0xdc, 0xc0, 0xc0, 0xc0
    ; GROUND_AREA_LARGE_3
    .db     0x50, 0x4c, 0x98, 0x80, 0x5b, 0x80, 0x9c, 0xe0
    .db     0x44, 0x88, 0x98, 0x8c, 0x80, 0x8c, 0x9c, 0xe0
    .db     0x90, 0x90, 0x8c, 0x8c, 0x8c, 0x8c, 0x9c, 0xe0
    .db     0x80, 0x8c, 0x8c, 0x8c, 0x8c, 0x8c, 0x9c, 0xe0
    .db     0x5b, 0x80, 0x8c, 0x8c, 0x8c, 0x8c, 0xac, 0xec
    .db     0x80, 0x8c, 0x8c, 0x8c, 0x8c, 0xac, 0xe4, 0xe8
    .db     0x94, 0x94, 0x94, 0x94, 0xac, 0xe4, 0xe8, 0x00
    .db     0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xe8, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 地面
;
_ground::
    
    .ds     GROUND_LENGTH

; セル
;
groundCell:

    .ds     GROUND_CELL_SIZE_X * GROUND_CELL_SIZE_Y

; エリア
;
groundArea:

    .ds     GROUND_AREA_SIZE_X * GROUND_AREA_SIZE_Y

; コア
;
groundCore:

    .ds     GROUND_CORE_LENGTH

; ベース
;
groundBaseEntry:

    .ds     0x01

; 爆発
;
groundBomb:

    .ds     GROUND_BOMB_LENGTH * GROUND_BOMB_ENTRY

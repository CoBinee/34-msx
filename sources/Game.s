; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Camera.inc"
    .include    "Player.inc"
    .include    "Shot.inc"
    .include    "Enemy.inc"
    .include    "Ground.inc"

; 外部変数宣言
;
    .globl  _voiceTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName
    
    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; カメラの初期化
    call    _CameraInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; ショットの初期化
    call    _ShotInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; 地面の初期化
    call    _GroundInitialize
    
    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)

    ; サウンドの停止
    call    _SoundStop

    ; 状態の設定
    ld      a, #GAME_STATE_BUILD
    ld      (_game + GAME_STATE), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_game + GAME_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; 色の更新
    ld      hl, #(_game + GAME_COLOR)
    inc     (hl)

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを作成する
;
GameBuild:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 地面の作成
    call    _GroundBuild

    ; プレイヤの設定
    call    _GroundGetStartPosition
    ld      (_player + PLAYER_POSITION_X), de
    ld      a, #CAMERA_DIRECTION_UP
    ld      (_player + PLAYER_DIRECTION), a

    ; カメラの設定
;   ld      de, (_player + PLAYER_POSITION_X)
    call    _CameraSetPosition

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 状態の更新
    ld      a, #GAME_STATE_START
    ld      (_game + GAME_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; ゲーム画面の描画
    call    GamePrintScreen

    ; 地面の全描画
    call    _GroundSetPrintView
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; カメラの更新
    call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ショットの更新
    call    _ShotUpdate

    ; 地面の更新
    call    _GroundUpdate

    ; カメラの描画
    call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ショットの描画
    call    _ShotRender

    ; 地面の描画
    call    _GroundRender

    ; プレイヤの設定
    call    _PlayerSetPlay

    ; 0x01 : 描画
10$:
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    dec     a
    jr      nz, 20$

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
    jr      90$

    ; 0x02 : ボイスの再生
20$:
    dec     a
    jr      nz, 30$
    ld      hl, #_voiceTable
    ld      bc, #5888
21$:
    push    bc
    ld      d, (hl)
    inc     hl
    ld      bc, #0x0800
22$:
    srl     d
    ld      a, c
    adc     a, c
    ld      e, a
    call    CHGSND
    djnz    22$
    pop     bc
    dec     bc
    ld      a, b
    or      c
    jr      nz, 21$

    ; フレームの設定
    ld      a, #0x30
    ld      (_game + GAME_FRAME), a

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
    jr      90$

    ; 0x03 : 待機
30$:
;   dec     a
;   jr      nz, 90$

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 39$

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (_game + GAME_STATE), a
39$:
;   jr      90$

    ; 開始の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; BGM の再生
    ld      a, #SOUND_BGM_GAME
    call    _SoundPlayBgm
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒット判定
    call    GameHit

    ; カメラの更新
    call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ショットの更新
    call    _ShotUpdate

    ; エネミーの登録
    call    _EnemyEntry

    ; エネミーの更新
    call    _EnemyUpdate

    ; 地面の更新
    call    _GroundUpdate

    ; カメラの描画
    call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ショットの描画
    call    _ShotRender

    ; エネミーの描画
    call    _EnemyRender

    ; 地面の描画
    call    _GroundRender

    ; カラーテーブルの更新
    ld      a, (_game + GAME_COLOR)
    and     #0x01
    add     a, #(APP_COLOR_TABLE >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; ゲームの判定
90$:

    ; ゲームをクリア
    call    _GroundIsCore
    jr      c, 91$
    ld      a, #GAME_STATE_CLEAR
    ld      (_game + GAME_STATE), a
    jr      99$
91$:

    ; ゲームオーバー
    call    _PlayerIsLive
    jr      c, 92$
    ld      a, #GAME_STATE_OVER
    ld      (_game + GAME_STATE), a
    jr      99$
92$:

    ; 判定の完了
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$
    
    ; フレームの設定
    ld      a, #0x20
    ld      (_game + GAME_FRAME), a

    ; BGM の停止
    ld      a, #SOUND_BGM_NULL
    call    _SoundPlayBgm
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; カメラの更新
    call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ショットの更新
    call    _ShotUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 地面の更新
    call    _GroundUpdate

    ; カメラの描画
    call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ショットの描画
    call    _ShotRender

    ; エネミーの描画
    call    _EnemyRender

    ; 地面の描画
    ld      a, (_game + GAME_FRAME)
    or      a
    call    z, _GroundSetPrintView
    call    _GroundRender

    ; ゲームオーバーの描画
    ld      a, (_game + GAME_FRAME)
    or      a
    call    z, GamePrintOver

    ; カラーテーブルの更新
    ld      a, (_game + GAME_COLOR)
    and     #0x01
    add     a, #(APP_COLOR_TABLE >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      19$

    ; SPACE の入力
10$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; プレイヤの設定
    call    _PlayerSetLeave
    
    ; カラーテーブルの更新
    ld      a, #((APP_COLOR_TABLE + 0x0080) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; BGM の再生
    ld      a, #SOUND_BGM_CLEAR
    call    _SoundPlayBgm
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; カメラの更新
    call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ショットの更新
    call    _ShotUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 地面の更新
    call    _GroundUpdate

    ; カメラの描画
    call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ショットの描画
    call    _ShotRender

    ; エネミーの描画
    call    _EnemyRender

    ; 地面の描画
    call    _GroundRender

    ; プレイヤの存在
    call    _PlayerIsLive
    jr      c, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_RESULT
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの結果を表示する
;
GameResult:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; ハイスコアの判定
    ld      hl, #(_app + APP_SCORE_1000)
    ld      de, #(_player + PLAYER_POWER_1000)
    ld      b, #APP_SCORE_LENGTH
00$:
    ld      a, (de)
    cp      (hl)
    jr      c, 02$
    jr      nz, 01$
    inc     hl
    inc     de
    djnz    00$
    jr      02$
01$:
    ld      hl, #(_player + PLAYER_POWER_1000)
    ld      de, #(_app + APP_SCORE_1000)
    ld      bc, #APP_SCORE_LENGTH
    ldir
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_TOP_BIT, (hl)
02$:

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; カメラの更新
    call    _CameraUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ショットの更新
    call    _ShotUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 地面の更新
    call    _GroundUpdate

    ; カメラの描画
    call    _CameraRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ショットの描画
    call    _ShotRender

    ; エネミーの描画
    call    _EnemyRender

    ; 地面の描画
    call    _GroundSetPrintView
    call    _GroundRender

    ; 結果の描画
    call    GamePrintResult

    ; SPACE の入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ヒット判定を行う
;
GameHit:

    ; レジスタの保存

    ; エネミーとの判定
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    cp      #(ENEMY_TYPE_BOMB + 0x01)
    jr      c, 190$
    ld      a, ENEMY_HIDDEN(ix)
    or      a
    jr      nz, 190$

    ; ショットとの判定
    ld      iy, #_shot
    ld      hl, #(((-(SHOT_SIZE_R + ENEMY_SIZE_R)) << 8) | (SHOT_SIZE_R + ENEMY_SIZE_R))
    ld      b, #SHOT_ENTRY
110$:
    push    bc
    ld      a, SHOT_TYPE(iy)
    cp      #SHOT_TYPE_AIR
    jr      nz, 119$
    ld      a, ENEMY_POSITION_X_H(ix)
    sub     SHOT_POSITION_X(iy)
    cp      l
    jr      c, 111$
    cp      h
    jr      c, 119$
111$:
    ld      a, ENEMY_POSITION_Y_H(ix)
    sub     SHOT_POSITION_Y(iy)
    cp      l
    jr      c, 112$
    cp      h
    jr      c, 119$
112$:
    ld      a, #0x01
    call    _EnemySetBomb
    ld      SHOT_TYPE(iy), #SHOT_TYPE_NULL
119$:
    ld      bc, #SHOT_LENGTH
    add     iy, bc
    pop     bc
    djnz    110$
    ld      a, ENEMY_TYPE(ix)
    cp      #(ENEMY_TYPE_BOMB + 0x01)
    jr      c, 190$

    ; プレイヤとの判定
    ld      hl, #(((-(SHOT_SIZE_R + ENEMY_SIZE_R)) << 8) | (SHOT_SIZE_R + ENEMY_SIZE_R))
    ld      de, (_player + PLAYER_PRINT_X)
    ld      a, ENEMY_POSITION_X_H(ix)
    sub     e
    cp      l
    jr      c, 120$
    cp      h
    jr      c, 129$
120$:
    ld      a, ENEMY_POSITION_Y_H(ix)
    sub     d
    cp      l
    jr      c, 121$
    cp      h
    jr      c, 129$
121$:
    xor     a
    call    _EnemySetBomb
    call    _PlayerDamage
129$:

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; レジスタの復帰

    ; 終了
    ret

; ゲーム画面を描画する
;
GamePrintScreen:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #gameScreenPatternName
    ld      de, #_patternName
    call    _AppUncompressPatternName

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーを描画する
;
GamePrintOver:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #(_patternName + 0x0144 + 0x0000)
    ld      de, #(_patternName + 0x0144 + 0x0001)
    ld      bc, #(0x0018 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #gameOverPatternName
    ld      de, #(_patternName + 0x0164)
    ld      bc, #0x0018
    ldir
    ld      hl, #(_patternName + 0x0184 + 0x0000)
    ld      de, #(_patternName + 0x0184 + 0x0001)
    ld      bc, #(0x0018 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 結果を描画する
;
GamePrintResult:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #(_patternName + 0x0104 + 0x0000)
    ld      de, #(_patternName + 0x0104 + 0x0001)
    ld      bc, #(0x0018 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #gameResultPatternName_GameClear
    ld      de, #(_patternName + 0x0124)
    ld      bc, #0x0018
    ldir
    ld      hl, #(_patternName + 0x0144 + 0x0000)
    ld      de, #(_patternName + 0x0144 + 0x0001)
    ld      bc, #(0x0018 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #(_patternName + 0x0164 + 0x0000)
    ld      de, #(_patternName + 0x0164 + 0x0001)
    ld      bc, #(0x0018 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #gameResultPatternName_Score
    ld      de, #(_patternName + 0x0184)
    ld      bc, #0x0018
    ldir
    ld      hl, #(_player + PLAYER_POWER_1000)
    ld      de, #(_patternName + 0x0191)
    call    20$
    ld      hl, #(_patternName + 0x01a4 + 0x0000)
    ld      de, #(_patternName + 0x01a4 + 0x0001)
    ld      bc, #(0x0018 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #(_patternName + 0x01e4 + 0x0000)
    ld      de, #(_patternName + 0x01e4 + 0x0001)
    ld      bc, #(0x0018 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_TOP_BIT, a
    jr      z, 10$
    ld      hl, #gameResultPatternName_TopScore
    ld      de, #(_patternName + 0x01c4)
    ld      bc, #0x0018
    ldir
    jr      19$
10$:
    ld      hl, #gameResultPatternName_Top
    ld      de, #(_patternName + 0x01c4)
    ld      bc, #0x0018
    ldir
    ld      hl, #(_app + APP_SCORE_1000)
    ld      de, #(_patternName + 0x01d1)
    call    20$
;   jr      19$
19$:
    jr      90$

    ; 数値の描画
20$:
    ld      b, #(APP_SCORE_LENGTH - 0x01)
21$:
    ld      a, (hl)
    or      a
    jr      nz, 22$
    ld      (de), a
    inc     hl
    inc     de
    djnz    21$
22$:
    inc     b
23$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    23$
    ret

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameBuild
    .dw     GameStart
    .dw     GamePlay
    .dw     GameOver
    .dw     GameClear
    .dw     GameResult

; ゲームの初期値
;
gameDefault:

    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     GAME_COLOR_NULL

; ゲーム画面
;
gameScreenPatternName:

    .db     0x00, 0x01, 0x30, 0x3f, 0x00, 0x1d
    .db     0x00, 0x02,       0x3f, 0x00, 0x1d
    .db     0x00, 0x02,       0x3f, 0x00, 0x1d
    .db     0x00, 0x02,       0x3f, 0x00, 0x1d
    .db     0x00, 0x02,       0x3f, 0x00, 0x1d
    .db     0x00, 0x01, 0x3e, 0x3f, 0x00, 0x1d
    .db     0x00, 0x01, 0x3d, 0x3f, 0x00, 0x1d
    .db     0x00, 0x01, 0x3c, 0x3f, 0x00, 0x1d
    .db     0x00, 0x01, 0x3b, 0x3f, 0x00, 0x1b, 0x3f, 0x00, 0x01
    .db     0x00, 0x01, 0x3a, 0x3f, 0x00, 0x1b, 0x3f, 0x00, 0x01
    .db     0x00, 0x02,       0x3f, 0x00, 0x1b, 0x3f, 0x00, 0x01
    .db     0x00, 0x02,       0x3f, 0x00, 0x1b, 0x3f, 0x00, 0x01
    .db     0x00, 0x02,       0x3f, 0x00, 0x1b, 0x3f, 0x00, 0x01
    .db     0x00, 0x02,       0x3f, 0x00, 0x1b, 0x3f, 0x00, 0x01
    .db     0x00, 0x02,       0x3f, 0x00, 0x1b, 0x3f, 0x00, 0x01
    .db     0x00, 0x02,       0x3f, 0x00, 0x1b, 0x3f, 0x00, 0x01
    .db     0x00, 0x1e,                         0x3f, 0x00, 0x01
    .db     0x00, 0x1e,                         0x3f, 0x00, 0x01
    .db     0x00, 0x1e,                         0x3f, 0x00, 0x01
    .db     0x00, 0x1e,                         0x3f, 0x00, 0x01
    .db     0x00, 0x1e,                         0x3f, 0x00, 0x01
    .db     0x00, 0x1e,                         0x3f, 0x00, 0x01
    .db     0x00, 0x1e,                         0x3f, 0x00, 0x01
    .db     0x00, 0x1e,                         0x3f, 0x00, 0x01
    .db     0xff

; ゲームオーバー
;
gameOverPatternName:

    ; GAME  OVER
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x27, 0x21, 0x28, 0x25, 0x00, 0x00, 0x29, 0x2a, 0x25, 0x2b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; 結果
;
gameResultPatternName_GameClear:

    ; GAME CLEAR
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x27, 0x21, 0x28, 0x25, 0x00, 0x00, 0x23, 0x2c, 0x25, 0x21, 0x2b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

gameResultPatternName_Score:

    ; SCORE
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2d, 0x23, 0x29, 0x2b, 0x25, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

gameResultPatternName_Top:

    ; SCORE
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2e, 0x29, 0x2f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

gameResultPatternName_TopScore:

    ; TOP SCORE!
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2e, 0x29, 0x2f, 0x00, 0x00, 0x2d, 0x23, 0x29, 0x2b, 0x25, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::
    
    .ds     GAME_LENGTH

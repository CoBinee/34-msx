; Camera.s : カメラ
;


; モジュール宣言
;
    .module Camera

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Camera.inc"
    .include    "Ground.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; カメラを初期化する
;
_CameraInitialize::
    
    ; レジスタの保存
    
    ; カメラの初期化
    ld      hl, #cameraDefault
    ld      de, #_camera
    ld      bc, #CAMERA_LENGTH
    ldir

    ; 状態の設定
    ld      a, #CAMERA_STATE_NULL
    ld      (_camera + CAMERA_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; カメラを更新する
;
_CameraUpdate::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; カメラを描画する
;
_CameraRender::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; カメラの位置を設定する
;
_CameraSetPosition::

    ; レジスタの保存
    push    de

    ; de < 中心の位置

    ; 位置の設定
    ld      a, e
    sub     #(CAMERA_VIEW_NAME_SIZE_X / 2)
    and     #(GROUND_NAME_SIZE_X - 0x01)
    ld      e, a
    ld      a, d
    sub     #(CAMERA_VIEW_NAME_SIZE_Y / 2)
    and     #(GROUND_NAME_SIZE_Y - 0x01)
    ld      d, a
    ld      (_camera + CAMERA_POSITION_X), de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; カメラの向きを設定する
;
_CameraSetDirection::

    ; レジスタの保存
    push    hl
    push    de

    ; a < 向き

    ; 向きの設定
    ld      (_camera + CAMERA_DIRECTION), a

    ; ベクトルの設定
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #cameraVector
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_camera + CAMERA_VECTOR_X), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; カメラの初期値
;
cameraDefault:

    .db     CAMERA_STATE_NULL
    .db     CAMERA_FLAG_NULL
    .db     CAMERA_POSITION_NULL
    .db     CAMERA_POSITION_NULL
    .db     CAMERA_LAST_NULL
    .db     CAMERA_LAST_NULL
    .db     CAMERA_DIRECTION_NULL

; ベクトル
;
cameraVector:

    .db      0x00,  0x00
    .db      0x00, -0x01
    .db      0x00,  0x01
    .db     -0x01,  0x00
    .db      0x01,  0x00
    .db     -0x01, -0x01
    .db      0x01, -0x01
    .db     -0x01,  0x01
    .db      0x01,  0x01


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; カメラ
;
_camera::
    
    .ds     CAMERA_LENGTH


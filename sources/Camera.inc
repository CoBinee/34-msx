; Camera.inc : カメラ
;


; マクロの定義
;

; カメラ
CAMERA_STATE                    =   0x00
CAMERA_FLAG                     =   0x01
CAMERA_POSITION_X               =   0x02
CAMERA_POSITION_Y               =   0x03
CAMERA_LAST_X                   =   0x04
CAMERA_LAST_Y                   =   0x05
CAMERA_DIRECTION                =   0x06
CAMERA_VECTOR_X                 =   0x07
CAMERA_VECTOR_Y                 =   0x08
CAMERA_LENGTH                   =   0x09

; 状態
CAMERA_STATE_NULL               =   0x00

; フラグ
CAMERA_FLAG_NULL                =   0x00

; 位置
CAMERA_POSITION_NULL            =   0x00

; 直前の位置
CAMERA_LAST_NULL                =   0x00

; 向き
CAMERA_DIRECTION_NULL           =   0x00
CAMERA_DIRECTION_UP             =   0x01
CAMERA_DIRECTION_DOWN           =   0x02
CAMERA_DIRECTION_LEFT           =   0x03
CAMERA_DIRECTION_RIGHT          =   0x04
CAMERA_DIRECTION_UP_LEFT        =   0x05
CAMERA_DIRECTION_UP_RIGHT       =   0x06
CAMERA_DIRECTION_DOWN_LEFT      =   0x07
CAMERA_DIRECTION_DOWN_RIGHT     =   0x08

; ベクトル
CAMERA_VECTOR_NULL              =   0x00

; 視野
CAMERA_VIEW_NAME_SIZE_X         =   0x18
CAMERA_VIEW_NAME_SIZE_Y         =   0x18
CAMERA_VIEW_NAME_OFFSET_X       =   0x04
CAMERA_VIEW_NAME_OFFSET_Y       =   0x00
CAMERA_VIEW_NAME_OFFSET         =   (CAMERA_VIEW_NAME_OFFSET_Y * 0x0020 + CAMERA_VIEW_NAME_OFFSET_X)
CAMERA_VIEW_CELL_SIZE_X         =   0x0c
CAMERA_VIEW_CELL_SIZE_Y         =   0x0c
CAMERA_VIEW_SPRITE_SIZE_X       =   0xc0
CAMERA_VIEW_SPRITE_SIZE_Y       =   0xc0
CAMERA_VIEW_SPRITE_OFFSET_X     =   0x20
CAMERA_VIEW_SPRITE_OFFSET_Y     =   0x00

; 外部関数宣言
;

    .globl  _CameraInitialize
    .globl  _CameraUpdate
    .globl  _CameraRender
    .globl  _CameraSetPosition
    .globl  _CameraSetDirection

; 外部変数宣言
;

    .globl  _camera

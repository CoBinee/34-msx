; EnemyOne.inc : それぞれのエネミー
;


; マクロの定義
;

; サークル

; トライアングル
ENEMY_TRIANGLE_FLAG_TURN_BIT    =   0x00
ENEMY_TRIANGLE_FLAG_TURN        =   (1 << ENEMY_TRIANGLE_FLAG_TURN_BIT)

; スクエア
ENEMY_SQUARE_FLAG_X_BIT         =   0x00
ENEMY_SQUARE_FLAG_X             =   (1 << ENEMY_SQUARE_FLAG_X_BIT)
ENEMY_SQUARE_FLAG_Y_BIT         =   0x01
ENEMY_SQUARE_FLAG_Y             =   (1 << ENEMY_SQUARE_FLAG_Y_BIT)
ENEMY_SQUARE_FLAG_STRAIGHT_BIT  =   0x02
ENEMY_SQUARE_FLAG_STRAIGHT      =   (1 << ENEMY_SQUARE_FLAG_STRAIGHT_BIT)

; 外部関数宣言
;

    .globl  _EnemyCircle
    .globl  _EnemyTriangle
    .globl  _EnemySquare

; 外部変数宣言
;

    .globl  _enemyCircleDefault
    .globl  _enemyTriangleDefault
    .globl  _enemySquareDefault

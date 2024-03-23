; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmGame_0, soundBgmGame_1, soundBgmGame_2
    .dw     soundBgmClear_0, soundBgmClear_1, soundBgmClear_2

; ゲーム
soundBgmGame_0:

    .ascii  "T3V15,3"
    .ascii  "@6L1O3BB"
    .ascii  "L3O3BB1B1BB1B1O4EF+G+O3B1B1BB1B1O4EG+1G+1F+D+O3BB1B1"
    .ascii  "L3O3BB1B1BB1B1O4EF+G+E1G+1B5R1A1G+1F+1EG+E"
    .ascii  "@7L1O4BB"
    .ascii  "L3O4BB1B1BB1B1O5EF+G+O4B1B1BB1B1O5EG+1G+1F+D+O4BB1B1"
    .ascii  "L3O4BB1B1BB1B1O5EF+G+E1G+1B5R1A1G+1F+1EG+E"
    .ascii  "@15L1O4G+G+"
    .ascii  "L3O4G+G+1G+1G+G+1G+1G+O5C+O4G+O5C+O4G+O5C+O4G+F+ED+C+G+1G+1"
    .ascii  "L3O4G+G+1G+1G+G+1G+1G+O5C+O4G+O5C+O4G+O5C+O4BA+BA+BG+1G+1"
    .ascii  "L3O4G+G+1G+1G+G+1G+1G+O5C+O4G+O5C+O4G+O5C+O4G+F+ED+C+G+1G+1"
    .ascii  "L3O4G+G+1G+1G+G+1G+1G+O5C+O4G+O5C+O4G+O5C+O4BA+B5R"
    .db     0xff

soundBgmGame_1:

    .ascii  "T3V13,3"
    .ascii  "@2L1O3G+G+"
    .ascii  "L3O3G+G+1G+1G+G+1G+1G+G+G+G+1G+1G+G+1G+1G+G+1G+1F+F+F+G+1G+1"
    .ascii  "L3O3G+G+1G+1G+G+1G+1G+G+G+RO2BO3B1B1BBG+O2BO3D+"
    .ascii  "@2L1O3BB"
    .ascii  "L3O3BB1B1BB1B1O4EF+G+O3B1B1BB1B1O4EG+F+D+O3BB1B1"
    .ascii  "L3O3BB1B1BB1B1O4EF+G+RO2BO3B1B1BBO4EG+E"
    .ascii  "@2L1O3G+G+"
    .ascii  "L3O3G+G+1G+1G+G+1G+1G+O4C+O3G+O4C+O3G+O4C+O3G+F+EC+C+G+1G+1"
    .ascii  "L3O3G+G+1G+1G+G+1G+1G+O4C+O3G+O4C+O3G+O4C+O3BF+BBBG+1G+1"
    .ascii  "L3O3G+G+1G+1G+G+1G+1G+O4C+O3G+O4C+O3G+O4C+O3G+F+EC+C+G+1G+1"
    .ascii  "L3O3G+G+1G+1G+G+1G+1G+O4C+O3G+O4C+O3G+O4C+O3BA+B5R"
    .db     0xff

soundBgmGame_2:

    .ascii  "T3V13,3"
    .ascii  "@2L1O3EE"
    .ascii  "L3O3EE1E1EE1E1EEEE1E1EE1E1EE1E1D+D+D+E1E1"
    .ascii  "L3O3EE1E1EE1E1EEERO2F+O3F+1F+1F+AEO2EE"
    .ascii  "@2L1O2G+G+"
    .ascii  "L3O3G+G+1G+1G+G+1G+1G+BBG+1G+1G+G+1G+1G+BO4DO3F+D+G+1G+1"
    .ascii  "L3O3G+G+1G+1G+G+1G+1G+BBRO2F+O3F+1F+1F+AG+BE"
    .ascii  "@15L1O4EE"
    .ascii  "L3O4EE1E1EE1E1EO5C+O4EO5C+O4EO5C+O4ED+C+D+C+E1E1"
    .ascii  "L3O4EE1E1EE1E1EO5C+O4EO5C+O4EO5C+O4D+C+D+C+D+E1E1"
    .ascii  "L3O4EE1E1EE1E1EO5C+O4EO5C+O4EO5C+O4ED+C+D+C+E1E1"
    .ascii  "L3O4EE1E1EE1E1EO5C+O4EO5C+O4EO5C+O4D+C+D+5R"
    .db     0xff

; クリア
soundBgmClear_0:

    .ascii  "T3@2V15,3"
    .ascii  "L0O5E4ERE2RD4RRD4RRD2R"
    .ascii  "L0O5F4FRF2RE4RRE4RRE2R"
    .ascii  "L0O5FRFRR1FRF2RGRGRR1GRG2RG2RG2R"
    .ascii  "L0O5ARARR1ARA2RA3"
    .ascii  "L0O6CO5A+G+F+EDCO4A+G+F+EDCO3BA+A"
    .db     0x00

soundBgmClear_1:

    .ascii  "T3@2V15,3"
    .ascii  "L1O4CEGO5CO4CEGO5CO4CEGO5CO4CEGO5C"
    .ascii  "L1O4CEGO5CO4CEGO5CO4CEGO5CO4CEGO5C"
    .ascii  "L0O5D-RD-RR1D-RD-2RE-RE-RR1E-RE-2RE-2RE-2R"
    .ascii  "L1O4FAO5CFFCO4AF"
    .ascii  "L7R"
    .db     0x00

soundBgmClear_2:

    .ascii  "T3@2V15,3"
    .ascii  "L5O4CO3GO4CO3G"
    .ascii  "L5O4CO3GO4CO3G"
    .ascii  "L0O3A-RA-RR1A-RA-2RB-RB-RR1B-RB-2RB-2RB-2R"
    .ascii  "L3O5F5CO4F"
    .ascii  "L7R"
    .db     0x00

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeAir
    .dw     soundSeGround
    .dw     soundSeHit
    .dw     soundSeBomb
    .dw     soundSeDamage
    .dw     soundSeMiss

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; 対空ショット
soundSeAir:

    .ascii  "T1@0V13L0O2F+O6F+O2GO6C+O2G+O5G+O2AO5D+"
    .db     0x00

; 対地ショット
soundSeGround:

    .ascii  "T1@0V13L0O5C+CC+RCO4BA+AG+GFD+C+O3BG+"
    .db     0x00

; ヒット
soundSeHit:

    .ascii  "T1@0V13L2O5AGBA"
    .db     0x00

; 爆発
soundSeBomb:

    .ascii  "T1@0V13L0O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-O3CO2D-O3D-O2CO3CO2D-O3D-O2CO3CO2D-O3D-O2CO3CO2D-O3D-O2C"
    .db     0x00

; ダメージ
soundSeDamage:

    .ascii  "T1@0L1O3V13CV12CV11CV10C"
    .db     0x00

; ミス
soundSeMiss:

    .ascii  "T1@0L0"
    .ascii  "V13O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
    .ascii  "V12O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
    .ascii  "V11O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
    .ascii  "V10O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

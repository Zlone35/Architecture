                    ; ==============================
                    ; Definitions of Constants
                    ; ==============================

                    ; Video Memory
                    ; ------------------------------

VIDEO_START         equ     $ffb500                         ; Starting address
VIDEO_WIDTH         equ     480                             ; Width in pixels
VIDEO_HEIGHT        equ     320                             ; Height in pixels
VIDEO_SIZE          equ     (VIDEO_WIDTH*VIDEO_HEIGHT/8)    ; Size in bytes
BYTE_PER_LINE       equ     (VIDEO_WIDTH/8)                 ; Number of bytes per line

                    ; Bitmaps
                    ; ------------------------------

WIDTH               equ     0                               ; Width in pixels
HEIGHT              equ     2                               ; Height in pixels
MATRIX              equ     4                               ; Dot matrix

                    ; ==============================
                    ; Vector Initialization
                    ; ==============================

                    org     $0

vector_000          dc.l    VIDEO_START                     ; Initial value of A7
vector_001          dc.l    Main                            ; Initial value of the PC

                    ; ==============================
                    ; Main Program
                    ; ==============================

                    org     $500

Main                lea     InvaderA_Bitmap,a0
                    lea     VIDEO_START+14+100*BYTE_PER_LINE,a1
                    jsr     CopyBitmap

                    lea     InvaderB_Bitmap,a0
                    lea     VIDEO_START+28+100*BYTE_PER_LINE,a1
                    jsr     CopyBitmap

                    lea     InvaderC_Bitmap,a0
                    lea     VIDEO_START+42+100*BYTE_PER_LINE,a1
                    jsr     CopyBitmap

                    lea     Ship_Bitmap,a0
                    lea     VIDEO_START+28+200*BYTE_PER_LINE,a1
                    jsr     CopyBitmap

                    illegal

                    ; ==============================
                    ; Subroutines
                    ; ==============================

PixelToByte         ; Size in pixels + 7 -> D3.W
                    addq.w  #7,d3
                    
                    ; D3.W/8 -> D3.W
                    lsr.w   #3,d3

                    ; Return from subroutine.
                    rts

CopyLine            ; Save registers on the stack.
                    movem.l d3/a1,-(a7)

                    ; Number of iterations = Width in bytes
                    ; Number of iterations - 1 -> D3.W (DBRA)
                    subq.w  #1,d3

\loop               ; Copy all the bytes of the line.
                    move.b  (a0)+,(a1)+
                    dbra    d3,\loop

                    ; Restore registers from the stack and return from subroutine.
                    movem.l (a7)+,d3/a1
                    rts

CopyBitmap          ; Save registers on the stack.
                    movem.l d3/d4/a0/a1,-(a7)

                    ; Width in bytes -> D3.W
                    move.w  WIDTH(a0),d3
                    jsr     PixelToByte

                    ; Number of iterations - 1 -> D4.W (DBRA)
                    ; Number of iterations = Height in pixels
                    move.w  HEIGHT(a0),d4
                    subq.w  #1,d4

                    ; Address of the dot matrix -> A0.L
                    lea     MATRIX(a0),a0

\loop               ; Copy a line of the matrix.
                    jsr     CopyLine

                    ; Point to the video address of the next line.
                    adda.l  #BYTE_PER_LINE,a1

                    ; Branch to loop as long as there are lines to draw.
                    dbra    d4,\loop

                    ; Restore registers from the stack and return from subroutine.
                    movem.l (a7)+,d3/d4/a0/a1
                    rts

                    ; ==============================
                    ; Data
                    ; ==============================

InvaderA_Bitmap     dc.w    24,16
                    dc.b    %00000000,%11111111,%00000000
                    dc.b    %00000000,%11111111,%00000000
                    dc.b    %00111111,%11111111,%11111100
                    dc.b    %00111111,%11111111,%11111100
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %11111100,%00111100,%00111111
                    dc.b    %11111100,%00111100,%00111111
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %00000011,%11000011,%11000000
                    dc.b    %00000011,%11000011,%11000000
                    dc.b    %00001111,%00111100,%11110000
                    dc.b    %00001111,%00111100,%11110000
                    dc.b    %11110000,%00000000,%00001111
                    dc.b    %11110000,%00000000,%00001111

InvaderB_Bitmap     dc.w    22,16
                    dc.b    %00001100,%00000000,%11000000
                    dc.b    %00001100,%00000000,%11000000
                    dc.b    %00000011,%00000011,%00000000
                    dc.b    %00000011,%00000011,%00000000
                    dc.b    %00001111,%11111111,%11000000
                    dc.b    %00001111,%11111111,%11000000
                    dc.b    %00001100,%11111100,%11000000
                    dc.b    %00001100,%11111100,%11000000
                    dc.b    %00111111,%11111111,%11110000
                    dc.b    %00111111,%11111111,%11110000
                    dc.b    %11001111,%11111111,%11001100
                    dc.b    %11001111,%11111111,%11001100
                    dc.b    %11001100,%00000000,%11001100
                    dc.b    %11001100,%00000000,%11001100
                    dc.b    %00000011,%11001111,%00000000
                    dc.b    %00000011,%11001111,%00000000

InvaderC_Bitmap     dc.w    16,16
                    dc.b    %00000011,%11000000
                    dc.b    %00000011,%11000000
                    dc.b    %00001111,%11110000
                    dc.b    %00001111,%11110000
                    dc.b    %00111111,%11111100
                    dc.b    %00111111,%11111100
                    dc.b    %11110011,%11001111
                    dc.b    %11110011,%11001111
                    dc.b    %11111111,%11111111
                    dc.b    %11111111,%11111111
                    dc.b    %00110011,%11001100
                    dc.b    %00110011,%11001100
                    dc.b    %11000000,%00000011
                    dc.b    %11000000,%00000011
                    dc.b    %00110000,%00001100
                    dc.b    %00110000,%00001100

Ship_Bitmap         dc.w    24,14
                    dc.b    %00000000,%00011000,%00000000
                    dc.b    %00000000,%00011000,%00000000
                    dc.b    %00000000,%01111110,%00000000
                    dc.b    %00000000,%01111110,%00000000
                    dc.b    %00000000,%01111110,%00000000
                    dc.b    %00000000,%01111110,%00000000
                    dc.b    %00111111,%11111111,%11111100
                    dc.b    %00111111,%11111111,%11111100
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %11111111,%11111111,%11111111
                    dc.b    %11111111,%11111111,%11111111

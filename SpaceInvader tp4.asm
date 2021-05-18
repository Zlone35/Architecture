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



                    org     $0

vector_000          dc.l    VIDEO_START                     ; Initial value of A7
vector_001          dc.l    Main                            ; Initial value of the PC

                    ; ==============================
                    ; Main Program
                    ; ==============================

                    org     $500


Main          move.l 		#$f0f0f0f0,d0
					jsr 				FillScreen

                    illegal



FillScreen         	
								movem.l		d7/a0,-(a7)
								lea     VIDEO_START,a0

								move.w	#VIDEO_SIZE/4-1,d7
								
\loop						
								move.l		d0,(a0)+
								dbra			d7,\loop
								
								movem.l 	(a7)+,d7/a0
								rts
								
Hlines
								movem.l	d6/d7/a0,-(a7)
								
								lea VIDEO_START,a0
								move.l	#VIDEO_START

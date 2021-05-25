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
WIDTH               equ	0                               ; Largeur en pixels
HEIGHT             equ	2                               ; Hauteur en pixels
MATRIX              equ	4                               ; Matrice de points


Invader_Bitmap
										dc.w	22,16                           ; Largeur, Hauteur
										dc.b    %00001100,%00000000,%11000000   ; Matrice de points
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


                    org     $0

vector_000          dc.l    VIDEO_START                     ; Initial value of A7
vector_001          dc.l    Main                            ; Initial value of the PC

                    ; ==============================
                    ; Main Program
                    ; ==============================

                    org     $500


Main               	; Fait pointer A0 sur la matrice de points de l'envahisseur.
							lea     Invader_Bitmap,a0
							; Fait pointer A1 sur la mémoire vidéo.
							lea     VIDEO_START,a1
							; D7.W = Compteur de boucles
							; 				= Nombre d'itérations - 1 (car DBRA)
							; Nombre d'itérations = Nombre de lignes
							move.w	#16-1,d7
\loop               	; Affiche une ligne de l'envahisseur.
							; (22 pixels nécessitent 3 octets.)
							move.b		(a0)+,(a1)
							move.b		(a0)+,1(a1)
							move.b		(a0)+,2(a1)
							; Passe à l'adresse vidéo de la ligne suivante.
							adda.l	#BYTE_PER_LINE,a1
							; Reboucle tant qu'il reste des lignes à afficher.
							dbra	d7,\loop
							
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
								move.l	#VIDEO_START/16-1,d7
								
\loop						move.w	#BYTE_PER_LINE*8/4-1,d6

\white_loop		move.l		#$ffffffff,(a0)+
								dbra			d6,\black_loop
								
								move.w	#BYTE_PER_LINE*8/4-1,d6
								
\black_loop		clr.l			(a0)+
								dbra			d6,\black_loop
								
								dbra			d7,\loop
								
								movem.l	(a7)+,d6/d7/a0
								rts
								
WhiteSquare32	movem.l	d7/a0,-(a7)


								lea	VIDEO_START+((BYTE_PER_LINE-4)/2)+(((VIDEO_HEIGHT-32)/2)*BYTE_PER_LINE),a0
								
								move.w	#32-1,d7
								
\loop						move.l		#$ffffffff,(a0)
								adda.l		#BYTE_PER_LINE,a0
								dbra			d7,\loop
								
								movem.l	(a7)+,d7/a0
								rts
								
WhiteSquare128	movem.l	d7/a0,-(a7)

									lea	VIDEO_START+((BYTE_PER_LINE-16)/2)+(((VIDEO_HEIGHT-128)/2)*BYTE_PER_LINE),a0
									
									move.w	#128-1,d7
									
\loop							move.l		#$ffffffff,(a0)
									move.l		#$ffffffff,4(a0)
									move.l		#$ffffffff,8(a0)
									move.l		#$ffffffff,12(a0)
									adda.l		#BYTE_PER_LINE,a0
									dbra			d7,\loop
									
									movem.l	(a7)+,d7/a0
									rts
WhiteLine				movem.l	d0/a0,-(a7)
									subq.w		#1,d0
									
\loop							move.b		#$ff,(a0)+
									dbra			d0,\loop
									
									movem.l (a7)+,d0/a0
									rts

WhiteSquare			movem.l	d0-d2/a0,-(a7)
									move.w	d0,d2
									lsl.w			#3,d2
									
									
									lea				VIDEO_START,a0
									
									
									move.w	#BYTE_PER_LINE,d1
									sub.w		d0,d1
									lsr.w			#1,d1
									adda.w		d1,a0
									
									move.w	#VIDEO_HEIGHT,d1
									sub.w		d2,d1
									lsr.w			#1,d1
									mulu.w		#BYTE_PER_LINE,d1
									adda.w		d1,a0
									
									subq.w		#1,d2
									
\loop							jsr	WhiteLine
									adda.l	#BYTE_PER_LINE,a0
									dbra	d2,\loop
									
									movem.l	(a7)+,d0-d2/a0
									rts

PixelToByte         ; Taille en pixels + 7 -> D3.W
								addq.w	#7,d3
								; D3.W/8 -> D3.W
								lsr.w	#3,d3
								; Sortie du sous-programme.
								rts
								
CopyLine            ; Sauvegarde les registres dans la pile.
								movem.l	d3/a1,-(a7)
								; Nombre d'itérations = Largeur en octets; Nombre d'itérations - 1 (car DBRA) -> D3.W
								subq.w		#1,d3
\loop               
								; Copie tous les octets de la ligne.
								move.b		(a0)+,(a1)+
								dbra	d3,\loop						
								;Restaure les registres puis sortie.
								movem.l	 (a7)+,d3/a1
								rts
								
CopyBitmap          ; Sauvegarde les registres dans la pile.
									movem.l	d3/d4/a0/a1,-(a7)
									; Largeur en octets -> D3.W
									move.w  WIDTH(a0),d3
									jsr     PixelToByte
									; Nombre d'itérations - 1 (car DBRA) -> D4.W
									; Nombre d'itérations = Hauteur en pixels
									move.w  HEIGHT(a0),d4
									subq.w		#1,d4
									; Adresse de la matrice de points -> A0.L
									lea     MATRIX(a0),a0
\loop               			; Copie une ligne de la matrice.
									jsr     CopyLine
									; Passe à l'adresse vidéo de ligne suivante.
									adda.l	#BYTE_PER_LINE,a1
									; Reboucle tant qu'il y a des lignes à afficher.
									dbra	d4,\loop
									; Restaure les registres puis sortie.
									movem.l	(a7)+,d3/d4/a0/a1
									rts

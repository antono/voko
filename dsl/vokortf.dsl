<!doctype style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN">

; Voko-RTF-DSL, versio 0.9
; 11.1.1998
;
; autoro: Wolfram Diestel 
;
; Tiu chi DSSSL-Style-Sheet apartenas al la Voko-projekto
; kaj estas uzata por transformi SGML-dosieron konstruitan
; lau la vortaro-DTD al RTF
;
; uzo: jade -t rtf -d vokortf.dsl -o vortaro.rtf vortaro.sgml

; *********** shangehablaj konstantoj ******

(define *tipar-alteco* 12pt)
(define *tipar-nomo* "times")
(define *margheno* 2cm)
(define *alineo-distanco* 6pt)
(define *unua-linio-shovigho* 6pt)

; tipar-alteco kaj suprenigo de fontindikoj, kiel Z,X,...
(define *alt-tipar-alteco* 8pt)
(define *alt-suprenigo* 3pt)

; tiparalteco, de IM en RIM
(define *rim-tipar-alteco* 10pt)

; *********** helpfunkcioj ************

; la nombro de la infanaj elementoj de nodo

(define (*children-count* chtype #!optional (nd (current-node)))
	(node-list-length (select-elements
		(children nd) chtype)))

; ************ difinoj por la elementoj *******

(element vortaro 
	(make simple-page-sequence
		input-whitespace-treatment: 'collapse
		font-size: *tipar-alteco*
		font-family-name: *tipar-nomo*
		top-margin: *margheno*
		left-margin: *margheno*
		bottom-margin: *margheno*
		right-margin: *margheno*))

(element titolo
	(make paragraph
		font-size: (* 2 *tipar-alteco*)
		quadding: 'center
		space-before: *alineo-distanco*))

(element autoro
	(make paragraph
		font-size: (quotient (* 3 *tipar-alteco*) 2)
		font-posture: 'italic
		quadding: 'center
		space-before: *alineo-distanco*	))

(element precipa-parto (make sequence))

(element sekcio (make sequence
	(make paragraph
		font-size: (* 2 *tipar-alteco*)
		(literal (attribute-string "litero")))
	(make sequence)))

(element art 
	(make paragraph
		first-line-start-indent: *unua-linio-shovigho*
		space-after: *alineo-distanco*
		quadding: 'start
		keep-with-next?: #t
		(process-children-trim)))

(element (art kap) 
	(make sequence
		font-weight: 'bold
		(process-children-trim)
		(literal " ")))


(element drv (make sequence))

(element (drv kap)
	(if (= (child-number (parent)) 1)
		(empty-sosofo)
	(make sequence
		font-weight: 'bold
		(process-children-trim)
		(literal " "))))

(element sncgrp
	(if (= (child-number) 1)
		(make sequence (make sequence
			font-weight: 'bold
			(literal (format-number (child-number) "I"))
			(literal "- "))
			(process-children-trim))
	(make paragraph
		first-line-start-indent: *unua-linio-shovigho*
		space-before: *alineo-distanco*
		(make sequence
			font-weight: 'bold
			(literal (format-number (child-number) "I"))
			(literal "- "))
		(process-children-trim))))

(element subsncgrp
		(make paragraph
			first-line-start-indent: 0pt
			space-before: *alineo-distanco*
			(make sequence
				font-weight: 'bold
				(literal (format-number (child-number) "A"))
				(literal ") "))
			(process-children-trim)))

(element snc (make sequence
		(make sequence
			font-weight: 'bold
			(if (attribute-string "num")
			; se estas inidkita sencnumero, skribu ghin
			(literal (attribute-string "num"))
			; alikaze ...
			(if (> (*children-count* '(SNC) (parent)) 1)
			; se temas pri pluraj sencoj, skribu la numeron
			(literal (format-number (child-number) "1"))
			; se temas pri sola senco, ne skribu numeron
			(empty-sosofo)))
			(literal " "))
		(process-children-trim)))

(element subsnc	(make sequence
	(make sequence
		font-weight: 'bold
		(literal (format-number (child-number) "a"))
		(literal ") "))
	(process-children-trim)))


(element dif (make sequence
		(process-children-trim)
		(literal " ")))

(element uzo
	(make sequence
;		(literal " [")
		(process-children)
;		(literal "]")
))

(element ekz
	(make sequence
		font-posture: 'italic
		(process-children-trim)
		(literal " ")))

(element rad (make sequence (process-children-trim)))

(element (ekz fnt)
	(make sequence
		font-size: *alt-tipar-alteco*
		font-posture: #f
		position-point-shift: *alt-suprenigo*))

(element (kap fnt)
	(make sequence
		font-size: *alt-tipar-alteco*
		font-posture: #f
		position-point-shift: *alt-suprenigo*
		(process-children-trim)))

(element fnt (make sequence (process-children-trim)))

(element tld (make sequence (literal "~")))

(element refgrp	(make sequence
	(case (attribute-string "tip")
		(("VID") (literal "-> "))		
		(("SIN") (literal "=> "))
		(("DIF") (literal "= "))
		(else (empty-sosofo)))
	(process-children)))

(element ref (make sequence
	(case (attribute-string "tip")
		(("VID") (literal "-> "))		
		(("SIN") (literal "=> "))
		(("DIF") (literal "= "))
		(else (empty-sosofo)))
	(make sequence 
		font-posture: 'italic
		(process-children))))

(element klr
	(make sequence
		font-posture: #f
		(process-children)))

(element rim
	(make sequence
		(make sequence
			font-size: *tipar-alteco* 
			(literal "R"))
		(make sequence
			font-size: *rim-tipar-alteco* 
			(literal "IM"))
		(if (attribute-string "num")
			(make sequence
				font-size: *tipar-alteco* 
				(literal ". ")
				(literal (attribute-string "num"))
				(literal " "))
			(make sequence 
				font-size: *tipar-alteco*
				(literal ". ")))
		(process-children)))

(element trd
	(let ((lingvo (attribute-string "lingvo")))
	(make paragraph
		(make sequence
			font-posture: 'italic
			(literal lingvo)
			(literal ": "))
		(process-children))))

(element (dif trd) (make sequence font-posture: 'italic))
(element (ekz trd) (make sequence font-posture: 'italic))
(element (klr trd) (make sequence font-posture: 'italic))

(element vspec	(make sequence (literal "(") 
		(process-children-trim)
		(literal ") ")))

(element em (make sequence
	font-weight: 'bold))


<!doctype style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN">

; Voko-HTML-DSL, versio 1.0
; kreita 11.1.1998 lasta sxangxo 5.5.1998
;
; autoro: Wolfram Diestel 
;
; Tiu chi DSSSL-Style-Sheet apartenas al la Voko-projekto
; kaj estas uzata por eltiri SGML-indekson el SGML-vortaro konstruita
; lau la vortaro-DTD.
;
; uzo: jade -t sgml -d dsl/vokoinx.dsl sgm/vortaro.sgm > sgm/indekso.sgm

;******************* deklaroj *********************

; deklaras la klason element, kiu estas bezonata
; por konstrui SGML-elementojn

(declare-flow-object-class element
  "UNREGISTERED::James Clark//Flow Object Class::element")
(declare-flow-object-class empty-element
  "UNREGISTERED::James Clark//Flow Object Class::empty-element")
(declare-flow-object-class document-type
  "UNREGISTERED::James Clark//Flow Object Class::document-type")
(declare-flow-object-class entity
  "UNREGISTERED::James Clark//Flow Object Class::entity")
(declare-flow-object-class entity-ref
  "UNREGISTERED::James Clark//Flow Object Class::entity-ref")
(declare-flow-object-class processing-instruction
  "UNREGISTERED::James Clark//Flow Object Class::processing-instruction")
(declare-flow-object-class formatting-instruction
  "UNREGISTERED::James Clark//Flow Object Class::formatting-instruction")
(declare-characteristic preserve-sdata?
  "UNREGISTERED::James Clark//Characteristic::preserve-sdata?" #f)

;******************* helpfunkcioj *****************

; la sekva funkcio trovas la radikon en kapvorto de
; artikolo, ghi estas uzata en anstatauigado de tildoj

(define (*radiko* #!optional majuskl (nd (current-node)))
   (let ((str (data (select-elements (descendants 
		(ancestor "art" nd)) '(RAD)))))
	(if majuskl
		(literal (string-append majuskl
			(substring str 1 (string-length str)))) 
	
		(literal str) 
)))

; la nombro de la infanaj elementoj de nodo

(define (*children-count* chtype #!optional (nd (current-node)))
	(node-list-length (select-elements
		(children nd) chtype)))

; traktu nur la indikitan sekcion
(define (*komparu-sekcion* nd)
	(let ((att (attribute-string "LITERO" nd)))
		(if (and att (string=? att *sekcio*))
			nd
			(empty-node-list))))

(define (*process-sekcion*)
	(process-node-list (node-list-map 
		*komparu-sekcion* (children (current-node)))))


;******************* transformreguloj ****************

; VORTARO - skribu la kadron vortaro 

	(element vortaro (make sequence
		(make document-type name: "vortaro" 
			public-id: "-//VoKo//DTD vortaro//EO")
		(make element gi: "vortaro")))

; du helpfunkcioj, kiuj formas liston el
; cxiuj traktendaj struktureroj
	
	(define (*indekseroj1* nd)
		(let ((dc (children nd))) (node-list
			(select-elements dc '(KAP))
			(select-elements dc '(DRV))
			(select-elements dc '(UZO))
			(select-elements dc '(TRD))
			(select-elements dc '(DIF))
			(select-elements dc '(REF)))))
;			(select-elements dc 'REFGRP))))

	(define (*indekseroj2* nd)
		(let ((dc (descendants nd))) (node-list
			(select-elements dc '(KAP))
			(select-elements dc '(UZO))
			(select-elements dc '(TRD))
			(select-elements dc '(REF)))))
;			(select-elements dc 'REFGRP))))
				

; ARTIKOLO - transprenu la markon kaj traktu cxiujn
; strukturerojn laux *indekseroj1*

	(element art (make element gi: "art" attributes: (list
		(list "mrk" (attribute-string "mrk")))
		(process-node-list (*indekseroj1* (current-node)))))

	(element (kap) (make element gi: "kap"))

	(element (drv) (make element gi: "drv" attributes: (list
		(list "mrk" (attribute-string "mrk")))
		(process-node-list (*indekseroj2* (current-node)))))

	(element (dif) (make sequence (process-node-list
		(*indekseroj2* (current-node)))))

	(element trd (make element gi: "trd" attributes: (list
		(list "lng" (attribute-string "LNG")))))

	(element uzo (if (string=? (attribute-string "TIP") "FAK")
		(make element gi: "uzo" (process-children))
		(empty-sosofo)))

	(element tld (make sequence 
		(*radiko* (attribute-string "MAJ"))))

	(element ref (make element gi: "ref"))

;	(element refgrp (make element gi: "refgrp"))	















<!doctype style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN">

; Voko-HTML-DSL, versio 1.0
; kreita 11.1.1998 lasta sxangxo 5.5.1998
;
; autoro: Wolfram Diestel 
;
; Tiu chi DSSSL-Style-Sheet apartenas al la Voko-projekto
; kaj estas uzata por transformi SGML-dosieron konstruitan
; lau la vortaro-DTD al HTML-dosiero
;
; uzo:
;  cd $VOKO/mia_vortaro 
;  jade -t sgml -c dsl/catalog -d dsl/vokohtml.dsl sgm/vortaro.sgm \
;  > titolo.htm
;

;******************* deklaroj *********************

; deklaras la klason element, kiu estas bezonata
; por konstrui HTML-elementojn

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

;**** parametroj influantaj la aspekton de al dokumento ***

; por unuopa artikolo uzu apartan dosieron vokoart.dsl kun
; *inx-dosiero* #f
; *pluraj-dosieroj* #f
; kaj laýnecese
; *lng-simboloj*, *ref-simboloj*, *fak-simboloj* #f

; *modo* difinas la modon lau kiu la SGML-dokumento estas transformata
; al HTML
;
; eblaj modoj: 
;
;   NORMALA - prezenti la kompletan enhavon
;   KOLORA - prezenti la kompletan enhavon kolore
(define *modo* "KOLORA")
;(define *modo* "NORMALA")

; *pluraj-dosieroj* difinas, æu la unuopaj artikoloj estu en unuopaj HTML-dosieroj
; aý ne
(define *pluraj-dosieroj* #t) ; artikoloj estu en unuopaj dosieroj

; *simboloj* difinas, æu por signi lingvoj, referencojn k.a. estu uzataj
; bildetoj aý nura teksto
(define *lng-simboloj* #f) ; enmetu simbolojn por lingvoj 
(define *ref-simboloj* #t) ; enmetu simbolojn por referenctipoj
(define *fak-simboloj* #t) ; enmetu simbolojn por fakoj

; *tiparnomo* difinas la uzitan tiparon - øi estu Latin-3-tiparo, 
; (momente ne plu uzata)
; (define *tiparnomo* "Times SudEuro")

; kien skribi la artikolojn kaj la indekson
(define *art-dosiero* "art/")
(define *inx-dosiero* "sgm/indekso.sgm")

; kie troviøas simboletoj (rilate al la artikoloj)
(define *smb-dosiero* "../smb/")

; kie troviøas stildosieroj (rilate al la artikoloj)
(define *stl-dosiero* "../stl/")

;******************* helpfunkcioj *****************

; la sekva funkcio trovas la radikon en kapvorto de
; artikolo, ghi estas uzata en anstatauigado de tildoj

(define (*radiko* #!optional litero (nd (current-node)))
   (let ((str (data (select-elements (descendants 
		(ancestor "art" nd)) '(RAD)))))
	(if litero
		(literal (string-append litero
			(substring str 1 (string-length str)))) 
	
		(literal str) 
)))

; la nombro de la infanaj elementoj de nodo

(define (*children-count* chtype #!optional (nd (current-node)))
	(node-list-length (select-elements
		(children nd) chtype)))

; redonas la nomon de la grafik-dosiero laý la referenctipo

(define (*refsmb-dosiero* tipo)
  (string-append *smb-dosiero*
		 (case tipo
		   (("VID") "vidu")	
		   (("SIN") "sinonimo")
		   (("DIF") "difino")
		   (("ANT") "antonimo")
		   (("SUPER") "supernoc")
		   (("SUB") "subnocio")
		   (("PRT") "parto")
		   (("MALPRT") "malparto"))
		 ".gif"))

; redonas tekstan reprezenton por referenctipo

(define (*refsmb-teksto2* tipo)
  (case tipo
    (("VID") (make sequence 
	       (literal "-") 
	       (make entity-ref name: "gt") 
	       (literal " ")))
    (("SIN") (make sequence 
	       (literal "=") 
	       (make entity-ref name: "gt") 
	       (literal " ")))
    (("DIF") (literal "= "))
    (("ANT") (make sequence 
	       (literal "x") 
	       (make entity-ref name: "gt") 
	       (literal " ")))
    (("SUPER") (make sequence 
		 (literal "/") 
		 (make entity-ref name: "gt") 
		 (literal " ")))
    (("SUB") (make sequence 
	       (literal "\\") 
	       (make entity-ref name: "gt") 
	       (literal " ")))
    (("PRT") (make sequence 
	       (literal "c") 
	       (make entity-ref name: "gt") 
	       (literal " ")))
    (("MALPRT") (make sequence 
		  (literal "e") 
		  (make entity-ref name: "gt") 
		  (literal " ")))
    (else (literal " "))))


; Meta/Link-elementoj por HTML-kapo

(define (*meta-encoding*)
   ; Latin-3-kodo 
  (make empty-element gi: "meta" attributes: 
	(list (list "http-equiv" "Content-Type")
	      (list "content" "text/html; charset=iso-8859-3"))))

(define (*link-style-sheet* #!optional (stldos *stl-dosiero*))
  ; CCS-dosiero
  (make empty-element gi: "link" attributes: 
	(list	(list "titel" "artikolo-stilo")
		(list "type" "text/css")
		(list "rel" "stylesheet")
		(list "href" (string-append stldos "artikolo.css")))))

; donas la pozicion de la unua okazo de singo en signaro

(define (*string-pos* chr str #!optional (start 0))
  (cond ((>= (+ 1 start) (string-length str)) #f)
	((char=? (string-ref str start) chr) start)
	(else (*string-pos* chr str (+ 1 start)))))

; transformas referencon en URLon
(define (*ref->url* ref)
  (let ((pos (*string-pos* #\. ref)))
    (if pos
	(string-append (string-downcase (substring ref 0 pos)) ".htm#" ref) 
	(string-append (string-downcase ref) ".htm"))))
  
; minuskligi signaron

(define upperalpha
  (list #\A #\B #\C #\D #\E #\F #\G #\H #\I #\J #\K #\L #\M
        #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W #\X #\Y #\Z))  

(define loweralpha
  (list #\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m
        #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y #\z)) 

(define (EQUIVLOWER c a1 a2)
  (cond ((null? a1) c)
        ((char=? c (car a1)) (car a2))
        ((char=? c (car a2)) c)
        (else (EQUIVLOWER c (cdr a1) (cdr a2)))))

(define (char-downcase c)
  (EQUIVLOWER c upperalpha loweralpha))     

(define (LOCASE slist)
  (if (null? slist)
      '()
      (cons (char-downcase (car slist)) (LOCASE (cdr slist)))))
    
(define (string->list s)
  (let ((start 0)
        (len (string-length s)))
    (let loop ((i start) (l len))
         (if (= i len)
             '()
              (cons (string-ref s i) (loop (+ i 1) l))))))  

(define (list->string x)
  (apply string x))

(define (string-downcase s)
  (list->string (LOCASE (string->list s))))     


;*********************************************************************
;                           transformreguloj 
;*********************************************************************

; VORTARO - kreas titolo.htm kaj indekso.sgm
; transformas la vortaron lau la supre donita modo

(element vortaro 
  ; La titolpaøo kaj la artikoloj
  (make sequence 
    (make document-type name: "HTML" 
	  public-id: "-//W3C//DTD HTML 3.2//EN")
    (make element gi: "html"
	  (with-mode HEAD (process-matching-children 'PROLOGO))
	  (make element gi: "body"
		(case *modo*
		  (("KOLORA") (with-mode KOLORA (process-children)))
		  (else       (with-mode NORMALA (process-children))))))
  
    ; La indekso estas eltira¼o el vortaro.sgml kaj uzas la saman DTD
    (if *inx-dosiero*
	(make entity system-id: *inx-dosiero*
	  (make sequence
	    (make document-type name: "vortaro" 
		  public-id: "-//VoKo//DTD vortaro//EO")
	    (make element gi: "vortaro"
		  (with-mode INDEKSO (process-children)))))
	(empty-sosofo))))

; ************************************************************
;      transformreguloj lau modo HEAD (por HTML-elemento HEAD)
; *************************************************************

(mode HEAD
  (element prologo 
    (make element gi: "head"
	  (make sequence
	    (*meta-encoding*)
	    (*link-style-sheet* "stl/")
	    (process-matching-children 'TITOLO)
	    (process-matching-children 'AUTORO))))

  (element titolo (make element gi: "title"))
  (element autoro (make empty-element gi: "meta" attributes: 
			(list (list "name" "author")
			      (list "content" (data (children (current-node)))))))
) ; fino de modo HEAD


; ************************************************************
;        transformreguloj lau modo KAP
;             (por la kapvortoj foje necesas aparta trakto)
; ************************************************************

(mode KAP
  (root (empty-sosofo))
  (element (drv kap) (make element gi: "h3"))
  (element fnt (make element gi: "sup" (process-children-trim)))
  (element tld (*radiko* (attribute-string "LIT")))
)


; ************************************************************
;                transformreguloj lau modo NORMALA
; ************************************************************

(mode NORMALA 

  (element prologo (make sequence (process-children-trim)))
  (element titolo (make element gi: "h1" (process-children-trim)))
  (element autoro (make element gi: "p" ;attributes:
;			(list (list "align" "center")) 
			(process-children-trim)))
  (element alineo (make element gi: "p" (process-children-trim)))
  (element url (make element gi: "a" attributes:
		     (list (list "href" (attribute-string "ref")))))
			
  (element precipa-parto (make sequence))
  (element epilogo (make sequence 
		     (make empty-element gi: "hr")
		     (process-children-trim)))

  (element sekcio (if *pluraj-dosieroj* 
		      (make sequence)
		      (make sequence
			(make empty-element gi: "hr") 
			(make element gi: "h1" 
			      (literal (attribute-string "litero")))
			(process-children))))	

  (element adm (make element gi: "p"))

  ; ARTIKOLO - skribu markon kiel referenccelo kaj poste la
  ; tutan enhavon de la artikolo

  (element art 
    (if *pluraj-dosieroj*
	(make sequence
	  ; enmetu ligon al la artikolo
	  ;(make sequence
	  ;  (make element gi: "a" attributes:
	  ;	  (list (list "href" (string-append 
	  ;			      (attribute-string "mrk") ".htm")))
	  ;	  (literal (*titolo*)))
	  ;  (make empty-element gi: "br"))
          ; kreu novan dosieron por la artikolo
	  (make entity system-id: 
		(string-append *art-dosiero* 
			       (string-downcase (attribute-string "mrk")) 
			       ".htm")
		(make element gi: "html"
		      (make element gi: "head"
			    (*meta-encoding*)
			    (*link-style-sheet*)
			    (make element gi: "title" 
				  (process-matching-children 'KAP)))
		      (make element gi: "body"
			    ; numerigu la subartikoloj se ekistas 
			    (if (> (*children-count* '(SUBART)) 0)
				(make element gi: "ol" attributes: 
				      (list (list "type" "I")))
				(process-children)
				)))))

        ; nur unu dosiero - normale traktu la artikolon
	(make sequence
		 (make empty-element gi:  "hr")
		 (if (attribute-string "mrk")
		     (make element gi: "a" attributes: 
			   (list (list "name" (attribute-string "mrk"))) 
			   (empty-sosofo))
		     (empty-sosofo))
		 (process-children))))
		
  ; KAPVORTO 

  (element (art kap) (make element gi: "h2"))

  ; SUBART

  (element (subart) (make element gi: "li"))
  ;(element (subart dif) (make element gi: "b"))

  ; DERIVAJHO - ghi disigas artikolon en plurajn partojn
  ; unue skribu markon kiel referenccelo poste komencu
  ; liston de sencoj
  ;
  ; pli bone estus, se "ol" resp. "ul" ne ampleksus
  ; la tutan derivajhon, sed nur la sencojn.
  ; por tio oni au jam en derivajho devus
  ; trakti la tutan enhavon
  ; au en senco devus konstati, chu 1a, lasta, intera

  (element drv (make sequence
		 ; derivajho povas esti referenccelo
		 (if (attribute-string "mrk")
		     (make element gi: "a" attributes: 
			   (list (list "name" (attribute-string "mrk"))) 
			   (empty-sosofo))
		     (empty-sosofo))
                 ; la kapvorto estu ekster la senclisto
		 (with-mode KAP (process-matching-children 'KAP))
		 ; numerigu la sencojn nur se estas pli ol unu
		 (if (> (*children-count* '(SUBDRV)) 0)
		     (make element gi: "ol" attributes: 
			   (list (list "type" "A")))
		     (if (= (*children-count* '(SNC)) 0) ; provo
			 (process-children)          ; provo
			 (if (> (*children-count* '(SNC)) 1)
			     (make element gi: "ol")
			     (make element gi: "ul"))))))

  ; KAPVORTO de DERIVAJHO

  (element (drv kap) (empty-sosofo))

  ; SENCGRUPO - se vorto havas tre multajn sencojn, tiuj 
  ; estas grupigitaj

  (element subdrv (make element gi: "li"
			(if (> (*children-count* '(SNC)) 1)
			    (make element gi: "ol")
			    (make element gi: "ul"))))

  ; SENCO - chiu vorto povas havi plurajn sencojn
  ; unue skribu markon kiel referenccelo, poste la enavon

  (element snc (make sequence
	         ; senco povas esti celo de referenco
		 (if (attribute-string "mrk")
		     (make element gi: "a" attributes: 
			   (list (list "name" (attribute-string "mrk"))) 
			   (empty-sosofo))
		     (empty-sosofo))
		 ; senco estas listero en la listo de sencoj
		 (make element gi: "li"
		       (if (> (*children-count* '(SUBSNC)) 1)
			   (make element gi: "ol" attributes: 
				 (list (list "type" "a")))
			   (process-children)))))

  (element subsenco (make sequence
		(if (attribute-string "mrk")
			(make element gi: "a" attributes: (list 
				(list "name" (attribute-string "mrk"))) 
				(empty-sosofo))
			(empty-sosofo))
		(make element gi: "li")))

  ; DIFINO - difinas la vorton


  (element dif (make sequence
		(process-children) 
		(if (> (*children-count* '(SUBSNC) (parent)) 0)
			(make empty-element gi: "br")
			(empty-sosofo))))

  (element (subdrv dif) (make sequence
		(make sequence)
		(make empty-element gi: "p")))

  (element (drv dif) (make sequence
		(make sequence)
		(if (> (*children-count* '(SNC) (parent)) 0) ;provo
			(make empty-element gi: "br")
			(empty-sosofo))))                    ;provo

  (element (dif trd) (make element gi: "i"))


  ; EKZEMPLO - donas ekzemplon, kiel vorto estas uzata, skribu cite

  (element ekz (make element gi: "cite" (process-children)))

  ; TILDO - anstatauas la radikon de la kapvorto
  ; per la funkcio *radiko* estas trovata la radiko
  ; kaj reenmetata

  (element tld (make sequence 
		(*radiko* (attribute-string "LIT"))))

  ; GRAMATIKO donas gramatikajn informojn pri la vorto

  (element gra (make sequence 
		(literal "(") (process-children) (literal ")")
		(make empty-element gi: "br")))

  ; KLARIGO estas enkrampa klarigo pri iu vorto, frazo ktp.

  (element klr (make sequence))

  ; FONTO - signas, de kie la vorto au citajho estas prenita, ghi
  ; tie chi estas indikata per supra malgranda alskribajho

  (element fnt (make element gi: "sup" (process-children-trim)))

  (element uzo (if (and *fak-simboloj* (string=? 
				(attribute-string "tip") "FAK"))
			(make empty-element gi: "img" attributes: (list
				(list "src" (string-append "../smb/" 
					(data (current-node)) ".gif"))
				(list "alt" (data (current-node)))
				(list "align" "absmiddle")))
			(make sequence (literal "[") 
				(process-children-trim) (literal "]"))))


  (element (drv uzo) (make sequence 
		(literal "[") (process-children-trim) (literal "]")
		; post la lasta uzindikoj de derivajho komencu novan linion
		; antau la unua senco
		(if (and 
				(string=? (attribute-string "tip") "FAK")
				(= (child-number) 
					(*children-count* '(UZO) (parent))))
			(make empty-element gi: "br")
			(empty-sosofo))))

  ; REFERENCO - referencas al alia vorto en la vortaro	

  (element refgrp (make sequence 
		    (*refsmb-teksto2* (attribute-string "tip"))
		    (process-children)))

	
  (element ref (make sequence
		 (*refsmb-teksto2* (attribute-string "tip"))
		 (if (attribute-string "cel")
		     (if *pluraj-dosieroj*
			 (make element gi: "a" attributes:
			       (list (list "href" 
					   (*ref->url* (attribute-string "cel")))))
			 (make element gi: "a" attributes: 
			       (list (list "href" 
					   (string-append "#" 
							  (attribute-string "cel"))))))
		     (make sequence (make element gi: "a" attributes:
					  (list (list "href" "#nenien"))
					  (process-children))))))

  ; RIMARKO - donas kromajn indikojn

  (element rim (make sequence
		(literal "RIM. ")
		(if (attribute-string "num") 
			(literal (string-append 
				(attribute-string "num") " ")) 
			(empty-sosofo))
		(process-children)))

  ; TRADUKO donas tradukon de vorto en alia lingvo

  (element trd (make element gi: "br" 
		(make element gi: "i" 
			(literal (attribute-string "lng"))
			(literal ": ")) 
		(process-children)))

  ; latina traduko en krampoj

  (element (klr trd) (make element gi: "i")) 

  (element (rim trd) (make element gi: "i")) 

  ; aliaj simplaj elementoj

  (element em (make element gi: "strong"))
  (element sup (make element gi: "sup"))
  (element sub (make element gi: "sub"))	

  ) ; fino de modo NORMALA


; ************************************************************
;                transformreguloj lau modo KOLORA
; ************************************************************

(mode KOLORA

  (element prologo (make sequence (process-children-trim)))
  (element titolo (make element gi: "h1" (process-children-trim)))
  (element autoro (make element gi: "p" ;attributes:
;			(list (list "align" "center")) 
			(process-children-trim)))
  (element alineo (make element gi: "p" (process-children-trim)))
  (element url (make element gi: "a" attributes:
		     (list (list "href" (attribute-string "ref")))))
			
  (element precipa-parto (make sequence))
  (element epilogo (make sequence 
		     (make empty-element gi: "hr")
		     (process-children-trim)))

  (element sekcio (if *pluraj-dosieroj*
		      (make sequence)
		      (make sequence
			(make empty-element gi: "hr")  
			(make element gi: "h1" 
			      (literal (attribute-string "litero")))
			(process-children))))	


  (element adm (make element gi: "p"))


  ; ARTIKOLO - skribu markon kiel referenccelo kaj poste la
  ; tutan enhavon de la artikolo

  (element art 
    (if *pluraj-dosieroj*
	(make sequence
	  ; enmetu ligon al la artikolo
	  ;(make sequence
	  ;  (make element gi: "a" attributes:
	  ;	  (list (list "href" (string-append 
	  ;			      (attribute-string "mrk") ".htm")))
	  ;	  (literal (*titolo*)))
	  ;  (make empty-element gi: "br"))
          ; kreu novan dosieron por la artikolo
	  (make entity system-id: 
		(string-append *art-dosiero*
			       (string-downcase (attribute-string "mrk")) 
			       ".htm")
		(make element gi: "html"
		      (make element gi: "head"
			    (*meta-encoding*)
			    (*link-style-sheet*)
			    (make element gi: "title"  
				  (process-matching-children 'KAP)))
		      (make element gi: "body"
			    ; numerigu la subartikoloj se ekistas 
			    (if (> (*children-count* '(SUBART)) 0)
				(make element gi: "ol" attributes: 
				      (list (list "type" "I")))
				(process-children)
			    )))))

        ; nur unu dosiero - normale traktu la artikolon
	(make sequence
	  (make empty-element gi:  "hr")
	  (if (attribute-string "mrk")
	      (make element gi: "a" attributes: 
		    (list (list "name" (attribute-string "mrk"))) 
		    (empty-sosofo))
	      (empty-sosofo))
	  (process-children))))
		
  ; KAPVORTO 

  (element (art kap) (make element gi: "h2"))
  ;(element (art dif) (make element gi:"p" (make element gi: "b")))

  ; SUBART

  (element (subart) 
    (make element gi: "li"
	  ; numerigu la sencojn nur se estas pli ol unu
	  (if (> (*children-count* '(SUBDRV)) 0)
	      (make element gi: "ol" attributes: 
		    (list (list "type" "A")))
	      (if (= (*children-count* '(SNC)) 0) 
		  (process-children)          
		  (if (> (*children-count* '(SNC)) 1)
		      (make element gi: "ol")
		      (make element gi: "ul"))))))
 
  
  ;(element (subart dif) (make element gi: "p" (make element gi: "b")))

  ; DERIVAJHO - ghi disigas artikolon en plurajn partojn
  ; unue skribu markon kiel referenccelo poste komencu
  ; liston de sencoj
  ;
  ; pli bone estus, se "ol" resp. "ul" ne ampleksus
  ; la tutan derivajhon, sed nur la sencojn.
  ; por tio oni au jam en derivajho devus
  ; trakti la tutan enhavon
  ; au en senco devus konstati, chu 1a, lasta, intera

  (element drv (make sequence
		 ; derivajho povas esti referenccelo
		 (if (attribute-string "mrk")
		     (make element gi: "a" attributes: 
			   (list (list "name" (attribute-string "mrk"))) 
			   (empty-sosofo))
		     (empty-sosofo))
                 ; la kapvorto estu ekster la senclisto
		 (with-mode KAP (process-matching-children 'KAP))
		 ; numerigu la sencojn nur se estas pli ol unu
		 (if (> (*children-count* '(SUBDRV)) 0)
		     (make element gi: "ol" attributes: 
			   (list (list "type" "A")))
		     (if (= (*children-count* '(SNC)) 0) ; provo
			 (process-children)          ; provo
				(if (> (*children-count* '(SNC)) 1)
				    (make element gi: "ol")
				    (make element gi: "ul"))))))

  ; KAPVORTO de DERIVAJHO

  (element (drv kap) (empty-sosofo))

  ; SENCGRUPO - se vorto havas tre multajn sencojn, tiuj 
  ; estas grupigitaj

  (element subdrv (make element gi: "li"
			(if (> (*children-count* '(SNC)) 1)
				(make element gi: "ol")
				(make element gi: "ul"))))

  ; SENCO - chiu vorto povas havi plurajn sencojn
  ; unue skribu markon kiel referenccelo, poste la enavon

  (element snc (make sequence
		; senco povas esti celo de referenco
		(if (attribute-string "mrk")
			(make element gi: "a" attributes: (list 
				(list "name" (attribute-string "mrk"))) 
				(empty-sosofo))
			(empty-sosofo))
		; senco estas listero en la listo de sencoj
		(if (attribute-string "num")
			(make element gi: "li" attributes:
				(list (list "value" (attribute-string "num")))
			(if (> (*children-count* '(SUBSNC)) 1)
				(make element gi: "ol" attributes: (list
					(list "type" "a")))
				(process-children)))	
			(make element gi: "li"
			(if (> (*children-count* '(SUBSNC)) 1)
				(make element gi: "ol" attributes: (list
					(list "type" "a")))
				(process-children))))))

  (element subsnc (make sequence
		(if (attribute-string "mrk")
			(make element gi: "a" attributes: (list 
				(list "name" (attribute-string "mrk"))) 
				(empty-sosofo))
			(empty-sosofo))
		(make element gi: "li")))

  ; DIFINO - diffinas la vorton

  (element dif (make sequence 
		(make element gi: "span" attributes: (list 
			(list "class" "dif")))
		(if (> (*children-count* '(SUBSNC) (parent)) 0)
			(make empty-element gi: "br")
			(empty-sosofo))))

  (element (subdrv dif) (make sequence
		(make element gi: "span" attributes:
			(list (list "class" "sncgrpdif")))
		(make empty-element gi: "p")))

  (element (drv dif) (make sequence
		(make element gi: "span" attributes:
			(list (list "class" "drvdif")))
		(if (> (*children-count* '(SNC) (parent)) 0) ;provo
			(make empty-element gi: "br")
			(empty-sosofo))))                    ;provo
	

  (element (dif trd) (make element gi: "span" attributes:
			(list (list "class" "diftrd"))))

  ; EKZEMPLO - donas ekzemplon, kiel vorto estas uzata, skribu cite

  (element ekz (make element gi: "cite" attributes:
			(list (list "class" "ekz"))))

	; ene de rimarko ekzemplo ne estus kolora
  (element (rim ekz) (make element gi: "cite" attributes:
			(list (list "class" "rimekz"))))

  ; TILDO - anstatauas la radikon de la kapvorto
  ; per la funkcio *radiko* estas trovata la radiko
  ; kaj reenmetata

  (element tld (*radiko* (attribute-string "LIT")))

  ; GRAMATIKO donas gramatikajn informojn pri la vorto

  (element gra (make sequence 
		(literal "(") (process-children) (literal ")")
		(make empty-element gi: "br")))

  ; KLARIGO estas enkrampa klarigo pri iu vorto, frazo ktp.

  (element klr (make element gi: "span" attributes: 
		(list (list "class" "klr"))))

  ; FONTO - signas, de kie la vorto au citajho estas prenita, ghi
  ; tie chi estas indikata per supra malgranda alskribajho

  (element fnt (make element gi: "sup" (process-children-trim)))

  (element uzo (if (and *fak-simboloj* (string=? 
				(attribute-string "tip") "FAK"))
			(make empty-element gi: "img" attributes: (list
				(list "src" (string-append "../smb/" 
					(data (current-node)) ".gif"))
				(list "alt" (data (current-node)))
				(list "align" "absmiddle")))
			(make sequence (process-children-trim) (literal " "))))

  (element (drv uzo) (make sequence 
		(if (and *fak-simboloj* (string=? 
				(attribute-string "tip") "FAK"))
			(make empty-element gi: "img" attributes: (list
				(list "src" (string-append "../smb/" 
					(data (current-node)) ".gif"))
				(list "alt" (data (current-node)))))
			(make sequence (process-children-trim) (literal " ")))

		; post la lasta uzindikoj de derivajho komencu novan linion
		; antau la unua senco
		(if (and 
				(string=? (attribute-string "tip") "FAK")
				(= (child-number)
					(*children-count* '(UZO) (parent))))
		    (make empty-element gi: "br")
		    (empty-sosofo))))

  ; REFERENCO - referencas al alia vorto en la vortaro	

  (element refgrp 
    (make sequence 
      (if *ref-simboloj* 
	  (make empty-element gi: "img" attributes: 
		(list (list "src" (*refsmb-dosiero* (attribute-string "tip")))
		      (list "alt" (attribute-string "tip"))))
		(*refsmb-teksto2* (attribute-string "tip")))
      (process-children)))

	
  (element ref 
    (make sequence 
      (if (and *ref-simboloj* (attribute-string "tip"))
	  (make empty-element gi: "img" attributes: 
		(list (list "src" (*refsmb-dosiero* (attribute-string "tip")))
		      (list "alt" (attribute-string "tip"))))
	  (*refsmb-teksto2* (attribute-string "tip")))
      (if (attribute-string "cel") 
	  (if *pluraj-dosieroj*
	      (make element gi: "a" attributes:
		    (list (list "href" (*ref->url* (attribute-string "cel")))))
	      (make element gi: "a" attributes: 
		    (list (list "href" (string-append "#" 
						      (attribute-string "cel"))))))
	  (make sequence 
	    (make element gi: "a" attributes:
		  (list (list "href" "#nenien"))
		  (process-children))))))

  ; RIMARKO - donas kromajn indikojn

  (element rim (make element gi: "span" attributes:
		(list (list "class" "rim"))
		(make sequence
			(literal "RIM. ")
			(if (attribute-string "num") 
				(literal (string-append 
					(attribute-string "num") " ")) 
				(empty-sosofo))
			(process-children))))

  ; TRADUKO donas tradukon de vorto en alia lingvo

  (element trd (make sequence
		(make empty-element gi: "br") 
		(make element gi: "span" attributes:
			(list (list "class" "trd"))
		(if *lng-simboloj* 
			(make empty-element gi: "img" attributes: (list
				(list "src" (string-append 
					"../smb/"
					(attribute-string "lng")
					".jpg"))
				(list "alt" (string-append 
					(attribute-string "lng")
					":"))))
			(make element gi: "i" 
				(literal (attribute-string "lng"))
				(literal ": "))) 
		(process-children))))

	; latina traduko en krampoj

  (element (klr trd) (make element gi: "span" attributes:
		(list (list "class" "klrtrd")))) 
  (element (rim trd) (make element gi: "span" attributes:
		(list (list "class" "klrtrd")))) 

  (element em (make element gi: "strong"))
  (element sup (make element gi: "sup"))
  (element sub (make element gi: "sub"))	

  (element bld (make sequence
		(make empty-element gi: "br")
		(make empty-element gi: "img" attributes:
			(list (list "src" (attribute-string "lok"))))))

) ; fino de modo KOLORA

; ************************************************************
;                transformreguloj lau modo INDEKSO
; ************************************************************

  ; du helpfunkcioj, kiuj formas liston el
  ; cxiuj traktendaj struktureroj

  (define (*indekseroj1* nd)
    (let ((dc (children nd))) 
      (node-list
       (select-elements dc '(KAP))
       (select-elements dc '(DRV))
       (select-elements dc '(UZO))
       (select-elements dc '(TRD))
       (select-elements dc '(DIF))
       (select-elements dc '(REF)))))
;  (select-elements dc 'REFGRP))))

  (define (*indekseroj2* nd)
    (let ((dc (descendants nd))) 
      (node-list
       (select-elements dc '(KAP))
       (select-elements dc '(UZO))
       (select-elements dc '(TRD))
       (select-elements dc '(REF)))))
;  (select-elements dc 'REFGRP))))
				
(mode INDEKSO
   ; VORTARO - skribu la kadron vortaro 

;  (element vortaro (make sequence
;		     (make document-type name: "vortaro" 
;			   public-id: "-//VoKo//DTD vortaro//EO")
;		     (make element gi: "vortaro")))

  (element prologo (empty-sosofo))
  (element epilogo (empty-sosofo))
  	
  ; ARTIKOLO - transprenu la markon kaj traktu cxiujn
  ; strukturerojn laux *indekseroj1*

  (element art (make element gi: "art" attributes: 
		     (list (list "mrk" (attribute-string "mrk")))
		     (process-node-list (*indekseroj1* (current-node)))))

  (element (kap) (make element gi: "kap"))

  (element (drv) (make element gi: "drv" attributes: 
		       (list (list "mrk" (attribute-string "mrk")))
		       (process-node-list (*indekseroj2* (current-node)))))

  (element (dif) (make sequence (process-node-list
				 (*indekseroj2* (current-node)))))

  (element trd (make element gi: "trd" attributes: 
		     (list (list "lng" (attribute-string "LNG")))))

  (element uzo (if (string=? (attribute-string "TIP") "FAK")
		   (make element gi: "uzo" (process-children))
		   (empty-sosofo)))

  (element tld (make sequence 
		 (*radiko* (attribute-string "MAJ"))))

  (element ref (make element gi: "ref"))

;  (element refgrp (make element gi: "refgrp"))	

) ; fino de modo INDEKSO





















(defpackage :grupo02pareja023ZG2804 ; se declara un paquete lisp que usa common-lisp
(:use :common-lisp :mancala) ; y mancala, y exporta la función de evaluación
(:export :heuristica :*alias*)) ; heurística y un alias para el torneo

(in-package grupo02pareja023ZG2804)

(defvar *alias* '|Gazorpazorpfield 104-66|) ; alias que aparecerá en el ranking

(defun prod-escalar (v1 v2)
  (apply #'+ (mapcar #'* v1 v2)))

(defun matriz-x-vector (m v)
  (mapcar #'(lambda (fila) (prod-escalar fila v)) m))

(defun suma-vectores (v1 v2)
  (mapcar #'+ v1 v2))

(defun inputs (estado)
  (let ((tablero (estado-tablero estado))
        (mi-lado (estado-lado-sgte-jugador estado)))
      (append (input-lado tablero mi-lado 0)
            (input-lado tablero (lado-contrario mi-lado) 0))))

(defun input-lado (tablero lado pos)
  (unless (equal pos 7)
    (cons (get-fichas tablero lado pos)
          (input-lado tablero lado (+ 1 pos)))))

(defun heuristica (estado)
(+ -0.2991526166032432
(prod-escalar '(-0.40498928687333446 0.13548952849423967 -0.8205614718289422 0.12257958402661284 0.724253296114439 -0.24471091908784004 -0.39072067365259744 -0.7354875756128427 0.22268448134732655 0.13027535252790878)
(suma-vectores '(-0.3445662928417532 0.657239367536731 0.18415676977357465 -0.42523699466990195 -0.727975033098158 0.09335283094261437 0.30389688080309996 0.3843152802892924 -0.36377269489068387 -0.6817222444646243)
(matriz-x-vector '((0.8764506484795094 -0.17182428113497816 -0.6645829740948024 -0.7505173624958603 0.04210867041904698 0.9990847963942802 0.5352607156266851 0.8670944431012026 0.7136264437742446 0.6788439406514373 -0.7132858803554838 -0.4835956092747653 -0.9102159916583563 0.6096235454314725)
 (-0.4164331650814854 -0.05288911716676381 -0.5776197858661416 -0.7590123089888894 -0.9612600100190758 -0.8509888510082515 0.34055183317516713 -0.4234372034013667 0.8962658060980433 0.16109715132871694 0.13256121789714692 -0.6848579914868314 -0.945722133738438 0.4692969327621308)
 (-0.5787281986680981 0.39339052106304484 0.008115963535544557 0.7003303992580665 0.21747097607721777 0.6363752152698934 -0.987778809316185 -0.5396139115415441 -0.6442982625616114 -0.6163531233308073 -0.7142009482751248 0.5360132247620537 0.5754311400654759 -0.23046831032309978)
 (-0.1631637933821024 -0.8560901731910477 0.23686772234520648 -0.166246823428162 -0.6900196684298416 0.7017039655331596 -0.08285185657700578 -0.9347716382829057 0.7599555865294336 0.2044189929734037 0.8074610656842702 -0.584901159840542 0.5414967705803657 -0.8176769830982105)
 (-0.07303814972509026 0.7090172085862818 0.4703377808867242 0.34493864288589005 0.07601102590432607 -0.271355429160554 -0.7557506439970347 -0.21428830742753768 0.5535288106734964 0.7827604823179994 0.5542806097801016 -0.5226893637801817 -0.22705209293732342 -0.47131273257655426)
 (0.7374643975657633 0.7090320424217138 0.32503552863681784 -0.9282459095107574 -0.533238942070339 -0.35698613948383495 0.38223629290317285 -0.018198877563843974 -0.20734338319418888 0.5412769149755934 -0.4939388305446166 0.7633773003850091 0.24072472315383675 0.8625523578959349)
 (0.8077477568427052 0.9668493727118133 0.0018565682820792517 0.36537205200852174 0.7454398657132568 -0.5956675024789486 0.004776947070227466 0.3100486230722064 0.8922406141710506 0.8855158183134781 0.0956943150386027 0.04892107540723334 0.38229061435057954 0.42690976206848474)
 (-0.14179334217498396 -0.09382621720414996 0.8388131723834324 0.7307990573021583 0.6213843121886793 0.1766345171659478 -0.3955063032987316 0.1260972584622131 0.889713053503516 0.7138574247090013 0.9914623691087148 0.6309157296481982 0.9223032618716316 0.8829411252949249)
 (-0.7546874374613954 0.5571434685832655 -0.22951600292681684 -0.4415016170073749 0.538862240287056 0.14211284658138967 0.8778513995728314 -0.18655699865536612 -0.26653115335424316 0.29637638124190735 0.1284571265641965 -0.5377665937709815 -0.7121384896730405 -0.9909592773065095)
 (0.10327660922364967 0.5711893713288716 -0.3304492685817737 -0.20284989133380749 0.523254344898058 0.7866731893441985 -0.9693162398394541 0.8808888896583695 -0.48464420333563907 0.9140202500627228 -0.9822051226949184 -0.42857194371534946 0.1740047829590201 0.5940064969008627)
)
(inputs estado))))))


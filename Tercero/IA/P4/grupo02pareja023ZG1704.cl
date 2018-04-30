(defpackage :grupo02pareja023ZG1704 ; se declara un paquete lisp que usa common-lisp
(:use :common-lisp :mancala) ; y mancala, y exporta la función de evaluación
(:export :heuristica :*alias*)) ; heurística y un alias para el torneo

(in-package grupo02pareja023ZG1704)

(defvar *alias* '|megaGazor2|) ; alias que aparecerá en el ranking

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

(defun h_gen199player5 (estado)
(+ 0.8876719294100102
(prod-escalar '(-0.43328800960930547 0.6633981416263164 0.9625301232639836 0.15339318749944342 -0.5872263800992552 0.6890982895293323 -0.7991460628901197 0.9303246500439346 0.27821095345083724 0.4136923082949322)
(suma-vectores '(-0.057738098497610135 -0.3576087290276768 0.0057323750059077305 0.39571957173476435 0.4402948929095374 0.5259998922905578 -0.27607425356271564 -0.1487984911035607 -0.11159519256852679 -0.4953387004765757)
(matriz-x-vector '((-0.9910553386329535 -0.3329499183786584 0.8937432743105147 0.9648952409399036 -0.10775480504247437 0.6430099030324898 0.39986248353358533 -0.9386734463229354 0.21407170792179975 -0.430687151553921 -0.943090323113452 0.6263348355070235 -0.7982009039148357 -0.831891423170096)
 (0.8179158033502476 0.11428886091255652 0.8999154774315548 -0.455905579086175 0.738358423836694 -0.01955391657988459 0.964219777756504 0.2294026643826006 0.09079081675542922 -0.3764824253454777 -0.7590918533760271 0.7197465166017085 0.7400967959297653 0.8515918346611222)
 (0.3601413692441717 -0.7708228706089033 0.6797986576166486 -0.48908244448574756 0.5624187348164573 -0.5449458112809846 0.587459209045879 0.7529562770113505 -0.3694422524988583 -0.05204638552737806 0.15474339954044125 0.5844737075169626 -0.5687025068152021 -0.9049487005003463)
 (-0.34757694696541264 -0.8791697658038506 -0.241498381687542 -0.1560242113881556 -0.7707719733149205 -0.5865665978677468 -0.3157685216758712 -0.3403275644239101 0.39078228822474204 0.46862373688507875 0.9873932167074777 0.46483906821915943 -0.9784225363351964 0.753777698240778)
 (0.5922924413255322 -0.31871059512677524 0.5891117727776638 0.24037145089049217 0.504439780876617 0.15782538088702713 -0.6162642244562757 0.39101767894725437 -0.3388795742975872 -0.5642531703161764 0.7981846034330726 0.8693004201190173 -0.8415090171395334 0.43554910116684753)
 (-0.5797815562779729 -0.898338068960647 -0.8610874447645875 -0.4639157058530574 -0.5370291566302805 -0.41250668831835635 0.7672953395914117 -0.4383165218273384 0.610452831793312 -0.32163146493501693 -0.46886909583220704 0.6414380761651484 0.16300514364501528 -0.10852902082457194)
 (-0.2182572652280974 -0.822526141932753 -0.1953450277575357 0.2802960209859571 0.9326846432422626 -0.7655896705444163 -0.010115062446578449 0.12445773185354825 0.38886215604716545 0.8130866258428093 0.8328178793690884 -0.6092299951033897 -0.6221175482781178 0.667808716304175)
 (-0.7983709106806882 -0.32184530692533464 -0.105727743702132 0.008652253007926936 0.3885928055975434 -0.991721191353599 0.3160684267224443 0.17568169065661898 0.790266031029915 -0.7756352174605508 0.7295038533952973 -0.372135576211009 -0.020867037767162255 -0.08453023899918088)
 (-0.3209485538772068 0.908467129051999 0.6548191987393741 0.47069166030481413 0.6313547662141841 -0.7702822514694123 0.5275797251957912 -0.5892450352393801 -0.6705187971236373 0.6137358939411262 0.1787858231474626 -0.23560347197753795 0.44545432323008183 -0.5444055765982281)
 (-0.8732283977386994 0.7691865821766408 -0.7402449368037622 0.9003061668083203 -0.8046907864902149 -0.934267889755416 -0.27159075458611603 0.6579912829896695 -0.5041196212648127 0.47579052860066295 0.5770866731815583 0.9521007686613274 0.39288079011202615 -0.8687591114917417)
)
(inputs estado))))))


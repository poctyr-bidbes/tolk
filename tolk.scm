#! /gnu/store/kphp5d85rrb3q1rdc2lfqc1mdklwh3qp-guile-3.0.9/bin/guile \
-e main -s
!#

;;Biblas a splunk for your telwise convenience. Enjoy!!
;;quantify 
;;https://www.youtube.com/watch?v=fY6B-xK6Fic
;;sudo apt-get install xdotool wmctrl imagemagick tesseract-ocr


(use-modules (web client)
	     (srfi srfi-19)   ;; date time
	     (srfi srfi-1)  ;;list searching; delete-duplicates in list 
	     (srfi srfi-9)  ;;records
	     (web response)
	     (web request)
	     (web uri)
	     (ice-9 rdelim)
	     (ice-9 i18n)   ;; internationalization
	     (ice-9 popen)
	     (ice-9 regex) ;;list-matches
	     (ice-9 receive)	     
	     (ice-9 string-fun)  ;;string-replace-substring
	     (ice-9 pretty-print)	    
	     )

(define win-name "E-book viewer")
(define image-name "im1.png")
(define max-count 15)
(define width 6)


(define (pad i)
  ;;i is integer
  (let* ((s (number->string i) )
	 (l (string-length s))
	 (zeros (cond
		    ((= l 1) "00000")
		    ((= l 2) "0000")
		    ((= l 3) "000")
		    ((= l 4) "00")
		    ((= l 5) "0"))))
    (string-append "img-" zeros s)))

(define (get-name-list)
  (let* ((i 0)
	 (lst '())
	 )
    (while (<  i 10000)
      (begin
       (set! lst (cons (pad i) lst))
       (set! i (+ i 1))
    ))
(reverse lst)
     ;;  (pretty-print (sort lst string<?))    
))

(define (get-window-num s)
  ;;s: the name string to search for
  (let* ((s2 (string-append "'/" s  "/ {print $1}'"))	 
	 (command (string-append "wmctrl -l | awk " s2))
	 (port (open-input-pipe command))
	 (result  (read-line port)) ; from (ice-9 rdelim)
	 (dummy (close-pipe port))	 
	 )
    result))


(define (send-to-window win key)
  (let* ((command (string-append "xdotool key --window " win " " key)))
    (system command)))

(define (grab-window win image-name)
  (let* ((command (string-append "import -window " win " " image-name)))
    (system command)))
  
(define (get-width-height i)
  ;;returned as a list: '(w h)
  (let* ((command (string-append "identify -format \"%wx%h\" " i))
	 (port (open-input-pipe command))
	 (result  (read-line port)) ; from (ice-9 rdelim)
	 (dummy (close-pipe port))	 
	 (l (string-length result))
	 (x (string-index result #\x))
	 (w (substring result 0 x))
	 (h (substring result (+ x 1) l)))
    (list (string->number w) (string->number h)) ))
   
(define (get-ocr-bounds)
(pretty-print (get-width-height win-name))
  )  

  
(define (trim-image i )
  ;;chop 20 pixels from bottom for E-book viewer
  ;;convert ./im1.png -gravity South -chop 0x20 ./im2.png
  (let* ((command (string-append "convert " i " -gravity South -chop 0x20 " i))


	 )
   (system command)))

(define (get-text i o)
  ;;i input image
  ;;o output text
  (let* ((command (string-append "tesseract --dpi 100 " i " " o)))
   (system command)))


(define imgname "")
(define txtname "")

(define (main args)
  (let* ((i 0)
	 (names (get-name-list))
	 (winnum (get-window-num win-name))
	 )
    (while (< i 10)
      (begin
	(set! imgname (string-append "./images/" (car names) ".png"))
	(set! txtname (string-append "./texts/" (car names)))
	(set! names  (cdr names))
	(grab-window  winnum imgname)
	(send-to-window winnum "space")
	(trim-image imgname)
	(get-text imgname txtname)		
	(set! i (+ i 1))
	(usleep 10000)
	) 
  (pretty-print (string-append "image: " imgname " txtname: " txtname))
; (pretty-print (get-name-list))
;  (trim-image image-name)
;  (grab-window  (get-window-num win-name) "./im1.png")
;  (send-to-window  (get-window-num win-name) "space")
;  (get-window-num win-name)
;  (get-width-height image-name)
  )))

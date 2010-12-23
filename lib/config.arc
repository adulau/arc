; by hasenj <hasan.aljudy@gmail.com>
; For temporarily overriding global variables
; as if we were simply passing config values to functions

(load "lib/util.arc")

(mac debug-show (var)
     `(prn:string ',var " is: " ,var))

(def symstore symlist
     "An alist that stores the values of bound symbols in symlist.
     Ignores things that are not bound symbols"
       (map [list _ (eval _)] 
          (keep [and (asym _) (bound _)] symlist)))

(mac w/config (params . body)
     "Temporary override global valriables as supplied in `params'"
     (let store (apply symstore (map sym:car (pair params)))
         (with (assignment-expression (map [cons '= _] (pair params))
                restoration-expression (map [cons '= _] store))
               `(do ,@assignment-expression
                  ,@body
                  ,@restoration-expression))))

;; test
(def try-to-tell() (debug-show a*))
(= a* 20)
(debug-show a*)
(prn ((rep w/config) '(a* 5) '(try-to-tell)))
(w/config (a* 5) (try-to-tell))
(try-to-tell)


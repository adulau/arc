; by hasenj <hasan.aljudy@gmail.com>
; For watching files and automatically reloading them on change

(load "lib/files.arc")

(mac set-once (s v)
     "like '= but doesn't run again when file is reloaded"
     `(if (no:bound ',s)
        (= ,s ,v)))

(mac run-once (name . exp)
     "For code that should not run again when file is reloaded"
     `(set-once ,name (do ,@exp)))

(= watch-interval* 2)

(def watch-fn (func on-change)
    "Watches the result of (func) for change
     and run (on-change) when value changes"
     (let init (func)
         (while (is init (func))
            (sleep watch-interval*))
     (on-change)))

(mac watch (value-exp on-change-exp)
    "Watch the value-exp expression for changes
    and run on-change-exp when it changes"
     `(watch-fn (fn() ,value-exp) (fn() ,on-change-exp)))

(def watch-file (file-name deleg)
     "Watches `file-name` for changes and runs (deleg file-name) on change"
     (watch (mtime file-name) (deleg file-name)))

(def safeload (file-name)
     (on-err 
       [do (prn "\n\n****** loading " file-name " failed") (prn (details _)) nil]
       (fn () (load file-name) t)))

(def auto-reload (file-name)
     (prn "auto-reloading " file-name)
     (until (watch-file file-name safeload)))


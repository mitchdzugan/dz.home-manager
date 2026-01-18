" my filetype file
if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
    au! BufRead,BufNewFile *.zkm      setfiletype clojure
    au! BufRead,BufNewFile *.zn       setfiletype fennel
augroup END

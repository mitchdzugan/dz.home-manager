#!/usr/bin/env zkm

(defn melee
  ([] (melee "ssbm.1_02.iso"))
  ([iso-name] ["kde-inhibit"
               "--power"
               "--screenSaver"
               "--notifications"
               "--nightLight"
               "gamemoderun"
               "/home/dz/.config/Slippi\\ Launcher/netplay/Slippi_Online-x86_64.AppImage"
               "-b"
               "-e"
               (str "/VOID/ssbm/iso/" iso-name)]))
(def uncle-punch "Training\\ Mode\\ v3.0\\ Alpha\\ 7.2.iso")
(def pick-melee
  (->> (concat ["ls /VOID/ssbm/iso | rofi-dmenu | pipe-exec"] (melee "~%"))
       (into [])))

(Title "dz system")
(Cmd :w "open web browser [firefox]" "firefox")
(Cmd :return "open terminal" "kitty")
(Cmd :m "play melee (default iso)" (melee))
(Cmd :a:m "play melee (select iso)" pick-melee)
(Cmd :c:m "play melee (unclepunch)" (melee uncle-punch))
(Cmd :s:M "open slippi launcher" "/home/dz/Downloads/Slippi-Launcher-2.13.3-x86_64.AppImage")

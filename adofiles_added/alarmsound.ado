program alarmsound
    if "`c(os)'" == "Windows" {
        shell "alarmsound.mp3"
    }
end
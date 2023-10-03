
function __complete_mcli
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /usr/bin/mcli
end
complete -f -c mcli -a "(__complete_mcli)"


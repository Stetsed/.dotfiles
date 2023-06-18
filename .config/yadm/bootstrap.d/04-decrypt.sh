#!/bin/bash

export GPG_TTY=$(tty)

gpg --import ~/Network/Storage/Long-Term/stetsed.asc

yadm decrypt

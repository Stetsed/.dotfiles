#!/bin/bash

export GPG_TTY=$(tty)

gpg --pinetry-mode ask --import ~/Network/Storage/Long-Term/stetsed.asc

yadm decrypt

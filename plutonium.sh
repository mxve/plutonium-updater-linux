#!/bin/bash
INSTALLDIR="plutonium"
FORCE=0
LAUNCHER=0
QUIETER=0

while getopts ":d:flq" opt; do
    case $opt in
    d)
        INSTALLDIR=$OPTARG
        echo "- Install path '$INSTALLDIR'"
        ;;
    f)
        FORCE=1
        echo "- Force file hash recheck"
        ;;
    l)
        LAUNCHER=1
        echo "- Download launcher files"
        ;;
    q)
        QUIETER=1
        echo "- Quieter"
        ;;
    \?)
        echo "Usage:"
        echo "  $0"
        echo "      -d <path>      Directory to install to"
        echo "      -f             Force file hash recheck, otherwise only revision number will be checked"
        echo "      -l             Don't skip launcher assets"
        echo "      -q             Quiet(er), don't output every file action"
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument."
        exit 1
        ;;
    esac
done

INFO=$(wget -qO- https://cdn.plutonium.pw/updater/prod/info.json)
REVISION=$(jq '.revision' <<<"$INFO")

echoVerbose() {
    if [ "$QUIETER" = "0" ]; then
        echo -e "$1"
    fi
}

downloadFile() {
    BASEURL=$(jq -r '.baseUrl' <<<"$INFO")
    echoVerbose "\033[0;33mDownloading\033[0m: File: $1, Size: $3, SHA1: $HASH"
    wget -qO "$1" "$BASEURL$2"
}

update() {
    mkdir -p $INSTALLDIR
    pushd $INSTALLDIR >/dev/null

    FILES=$(jq '.files' <<<"$INFO")

    jq -c '.[]' <<<"$FILES" | while read i; do
        FILEPATH=$(jq -r '.name' <<<"$i")
        FILEDIR="$(dirname $FILEPATH)"
        SIZE=$(jq '.size' <<<"$i")
        HASH=$(jq -r '.hash' <<<"$i")

        if test -f "$FILEPATH"; then
            SHA1=($(sha1sum "$FILEPATH"))
            if [ "$SHA1" = "$HASH" ]; then
                echoVerbose "\033[0;32mChecked\033[0m: File: $FILEPATH, Local: $SHA1, Remote: $HASH"
                continue
            fi
        fi

        if [ "$LAUNCHER" = "0" ] && [[ $FILEPATH == launcher* ]]; then
            echoVerbose "\033[0;36mSkipped\033[0m: File: $FILEPATH"
            continue
        fi

        mkdir -p $FILEDIR
        downloadFile $FILEPATH $HASH $SIZE
    done

    echo $REVISION >version.txt
    popd >/dev/null
}

checkVersion() {
    echo "Remote version:   $REVISION"
    if test -f "$INSTALLDIR/version.txt"; then
        LOCALREVISION=$(cat "$INSTALLDIR/version.txt")

        if [ "$REVISION" = "$LOCALREVISION" ]; then
            echo -e "Local version:    \033[0;32m$LOCALREVISION\033[0m"
            return 1
        else
            echo -e "Local version:    \033[0;31m$LOCALREVISION\033[0m"
        fi
    fi

    echo -e "Local version:    \033[0;33mNot found\033[0m"
    return 0
}

if checkVersion || [ "$FORCE" = "1" ]; then
    echo -e "\n\033[0;35mChecking for & applying updates..\033[0m"
    update
    echo -e "\n\033[0;35mFinished updating\033[0m"
    exit 0
else
    echo -e "\033[0;32mAlready up to date\033[0m"
    exit 0
fi

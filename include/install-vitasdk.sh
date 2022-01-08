#!/bin/bash

get_download_link () {
  wget -qO- https://github.com/vitasdk/vita-headers/raw/master/.travis.d/last_built_toolchain.py | python - $@
}

get_download_link_arm () {
  curl -s https://api.github.com/repos/SonicMastr/autobuilds/releases/latest | awk -F\" '/browser_download_url.*.tar.bz2/{print $(NF-1)}'
}

install_vitasdk () {
  INSTALLDIR=$1

  case "$(uname -s)" in
     Darwin*)
      mkdir -p $INSTALLDIR
      wget -O- "$(get_download_link master osx)" | tar xj -C $INSTALLDIR --strip-components=1
     ;;

     Linux*)
      if [ -n "${TRAVIS}" ]; then
          sudo apt-get install libc6-i386 lib32stdc++6 lib32gcc1 patch
      fi
      command -v curl || { echo "curl missing (install using: apt install curl)" ; exit 1; }
      if [ ! -d "$INSTALLDIR" ]; then
        sudo mkdir -p $INSTALLDIR
        sudo chown $USER:$(id -gn $USER) $INSTALLDIR
      fi
      if ! [[ "$(uname -m)" =~ ^(armv7l|arm64|aarch64)$ ]]; then
        wget -O- "$(get_download_link master linux)" | tar xj -C $INSTALLDIR --strip-components=1
      else
        wget -O- "$(get_download_link_arm)" | tar xj -C $INSTALLDIR --strip-components=1
      fi
     ;;

     MSYS*|MINGW64*)
      UNIX=false
      mkdir -p $INSTALLDIR
      wget -O- "$(get_download_link master win)" | tar xj -C $INSTALLDIR --strip-components=1
     ;;

     CYGWIN*|MINGW32*)
      echo "Please use msys2. Exiting..."
      exit 1
     ;;

     *)
       echo "Unknown OS"
       exit 1
      ;;
  esac

}

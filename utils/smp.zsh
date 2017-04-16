#!/usr/bin/env zsh

 # languages # {{{
get_base_java(){
  cat <<_EOF_
public class ${1} {
  public static void main(String[] args){
  }
}
_EOF_
}

get_base_c(){
  libs=(stdio stdlib string math time)
  for s ($libs) echo "#include <$s.h>"
  echo -e "\nint main(){\n}"
}

get_base_cpp(){
  libs=(iostream string array)
  for s ($libs) echo "#include <$s>"
  cat <<_EOF_
using namespace std;
template<typename T> void putv(const T& value){ cout << value << endl; }

int main(){
}
_EOF_
}
# }}}

error(){
  echo "${*}" >&2
  exit 1
}

make_shebang() {
  echo "#!/usr/bin/env ${1}"
}

get_shebang(){
  case "${1}" in
    ruby|rb)     make_shebang 'ruby' ;;
    shell|sh)    make_shebang 'sh' ;;
    bash)        make_shebang 'bash' ;;
    zsh)         make_shebang 'zsh' ;;
  esac
}

get_base_python(){
  make_shebang "${1}"
  echo "# -*- coding: UTF-8 -*-"
}

get_base_body(){
  case "${1}" in
    java) get_base_java $2 ;;
    c) get_base_c ;;
    cpp) get_base_cpp ;;
    python2|py2) get_base_python 'python2' ;;
    python|python3|py|py3) get_base_python 'python3' ;;
    *) get_shebang "$1" ;;
  esac
}

get_suffix() {
  case "${1}" in
    ruby) echo rb ;;
    python|py|python3|py3) echo py ;;
    *) echo $1
  esac
}

[[ $#  -eq 0 ]] &&   error "usage: ${0:t:r} TYPE [file]"

# parse file.type
if [[ $1 =~ "^.+\..+$" ]]; then
  2=${1:r}
  1=${1:e}
fi

readonly body=$(get_base_body "${1}" "${2}")
if [[ -z $body ]]; then
  error "this filetype is not support."
fi

readonly suffix=$(get_suffix $1)

# ファイルとパスを設定
if [[ $# -lt 2 ]]; then
  file=$(mktemp  --suffix=.${suffix})
  opt=(+ -c 'au QuitPre <buffer> nested update')
else
  file="$PWD/$2.$suffix"

  if [[ -e $file ]]; then
    echo "${file} already exist."
    return 1
  fi
fi

echo "${body}" > $file

[[ $? != 0 ]] &&  error "Error: ${file} is not writable."

$EDITOR "${file}" ${opt:-}

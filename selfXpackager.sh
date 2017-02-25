#!/bin/bash
BASEDIR=`dirname "${0}"`
cd "$BASEDIR"

while getopts ":t:s:n:b:m:o:a:" opt; do
  case $opt in
    t) targpkg="$OPTARG"
    ;;
    s) script="$OPTARG"
    ;;
    n) pname="$OPTARG"
    ;;
    b) nodebin="$OPTARG"
    ;;
    m) nmodule="$OPTARG"
    ;;
    o) outdir="$OPTARG"
    ;;
    a) arch="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

tmp=__extract__$RANDOM

[ "$script" != "" ] || read -e -p "Enter the name/path of the script: " script
[ "$pname" != "" ] || read -e -p "Enter the name for process: " pname
[ "$targpkg" != "" ] || [ "$nodebin" != "" ] || read -e -p "Enter the path of node binary: " nodebin
[ "$targpkg" != "" ] || [ "$nmodule" != "" ] || read -e -p "Enter the path of the node module: " nmodule
[ "$outdir" != "" ] || read -e -p "Enter output directory: " outdir

if [ "$targpkg" == "" ] && [ -z "$nodebin" ]; then 
    echo "Error: Either package archive (t) or node binary and module paths are mandatory."
    exit 1;
fi

archname=""
if [  "$arch" != "" ]; then
    archname="_$arch"
fi

echo "Info: Begin packaging.."
if [ "$targpkg" == "" ]; then
    echo "Info: Creating bundle.."
    mkdir /tmp/selfXPkger
    cp $nodebin /tmp/selfXPkger/node
    cp -r $nmodule/* /tmp/selfXPkger/
    tar -czf /tmp/selfXPkger_payload.tar.gz -C /tmp/selfXPkger .
    targpkg=/tmp/selfXPkger_payload.tar.gz
    rm -r /tmp/selfXPkger/*
    rmdir /tmp/selfXPkger
fi

cd "$BASEDIR"

echo "Info: Creating executable.."
printf "#!/bin/bash
targpkg_LINE=\`awk '/^__targpkg_BELOW__/ {print NR + 1; exit 0; }' \$0\`
rm -r /tmp/$pname
mkdir /tmp/$pname
tail -n+\$targpkg_LINE \$0 | tar -xz -C /tmp/$pname/
WORKDIR="\`pwd\`"
cd /tmp/$pname
#you can add custom installation command here
./node . $pname \$WORKDIR/application.json

exit 0
__targpkg_BELOW__\n" > "$tmp"

pname+=$archname
pname+="_launcher.sh"
cp $script $outdir/$pname

echo "Info: Copying executable to output.."
cat "$tmp" "$targpkg" > "$outdir/$pname" && rm "$tmp"
chmod +x "$script"
echo "Info: Done. Executable at: $outdir/$pname"
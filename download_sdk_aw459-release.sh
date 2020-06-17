if [ -z "$1" ];then
  echo "usage: $0 sdk_dir"
  exit -1
fi
if [ -e "$1" ];then
  rm -rf "$1"
fi
cur_path=`pwd`
mkdir -p "$1"
cd "$1" && repo init -u git@192.168.19.90:AW_SDK/manifest.git -b master -m release.xml
cd $cur_path
echo "----------------The End---------------"

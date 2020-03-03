target_path=`pwd`
if [ ! -z "$1" ];then
  target_path="$1"
fi
echo $target_path
echo --------------------------------
find $target_path -name '*.c' |xargs sed -i "s/\t/    /g" 
find $target_path -name '*.h' |xargs sed -i "s/\t/    /g"
find $target_path -name '*.cpp' |xargs sed -i "s/\t/    /g"

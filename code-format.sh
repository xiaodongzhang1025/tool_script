target_path=`pwd`
if [ ! -z "$1" ];then
  target_path="$1"
fi
echo $target_path
echo --------------------------------
target_files=('.c' '.h' '.cpp')
for target_file in ${target_files[*]}; do
  echo "*$target_file"
  #find $target_path -name "*$target_file" |xargs sed -i "s/\t/    /g" 
  find $target_path -name "*$target_file" |xargs astyle --style=linux
done

find $target_path -name "*.orig" |xargs rm -f


CUR_DIR=$(pwd)
cur_git_dir=$(git rev-parse --show-toplevel)
target_git_dir=$1
if [ "$CUR_DIR" == "/" ] ; then
  echo "$CUR_DIR is dangerous!!!!"
  exit 1
fi
if [ -z "$1" ] || [ "$CUR_DIR" == "/" ] ; then
  echo "Usage: $0 target-dir"
  exit 1
fi

cur_dir_content=`ls $cur_git_dir -al | awk -F " " '{print $9}'`
target_dir_content=`ls $target_git_dir -al | awk -F " " '{print $9}'`

echo "============================="
echo "$cur_git_dir -----------------------------"
echo $cur_dir_content
echo "$cur_dir_content" | while read line
do
  #echo =============================
  #echo "$line"
  if [ -z "$line" ] || [ "$line" == "." ] || [ "$line" == ".." ] || [ "$line" == ".git" ] ; then
    echo "    skip $line"
  else
    #echo "rm -rf $line"
    rm -rf $line
  fi
  
done

echo "============================="
echo "$target_git_dir -----------------------------"
echo $target_dir_content
echo "$target_dir_content" | while read line
do
  #echo =============================
  #echo "$line"
  if [ -z "$line" ] || [ "$line" == "." ] || [ "$line" == ".." ] || [ "$line" == ".git" ] ; then
    echo "    skip $line"
  else
    #echo "cp $target_git_dir/$line  $cur_git_dir/ -r"
    cp $target_git_dir/$line  $cur_git_dir/ -r
  fi
done

echo '-----------------The End-----------------'
cd $CUR_DIR

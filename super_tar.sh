if [ -z "$1" ] || [ ! -d "$1" ] ; then
  echo "usage:"
  echo "  $0 dir_path"  
  exit -1
fi
starttime=`date +'%Y-%m-%d %H:%M:%S'`

cur_path=`pwd`

dir_path=`cd $1 && pwd`
dir_path=${dir_path%%/}

base_dir=${dir_path%/*}
dir_name=${dir_path##*/}

cd $cur_path
tmp_time=$(date "+%Y-%m-%d_%H-%M-%S")
tmp_cmd="tar -C $base_dir -cvf $dir_name-$tmp_time.tar $dir_name"

$tmp_cmd

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);

echo -----------------------------------------------
echo ${tmp_cmd}
echo "TimeUsed： "$((end_seconds-start_seconds))"s"

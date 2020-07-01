
CUR_DIR=$(pwd)
if [ -z "$1" ] ; then
  TARGET=$(pwd)
else
  TARGET="$1"
fi

echo "target $TARGET"
echo ".text  .data  .bss"
echo ""
TARGET_OBJS=""
TARGET_LIBS=""
if [ -d "$TARGET" ];then
  TARGET_OBJS=`find $TARGET -name "*.o"`
  TARGET_LIBS=`find $TARGET -name "*.a"`
elif [ -f "$TARGET" ];then
  if [ "${TARGET##*.}" = "o" ];then
    TARGET_OBJS=$TARGET
  fi
  if [ "${TARGET##*.}" = "a" ];then
    TARGET_LIBS=$TARGET
  fi
fi

#echo "TARGET_OBJS-------------------"
#echo "$TARGET_OBJS"
objs_text_size=0
objs_data_size=0
objs_bss_size=0
while read line
do
  if [ -z "$line" ];then
    continue
  fi
  tmp_text_size=`size $line|sed -n '2p'|awk '{printf $1}'`
  tmp_data_size=`size $line|sed -n '2p'|awk '{printf $2}'`
  tmp_bss_size=`size $line|sed -n '2p'|awk '{printf $3}'`
  if [ -z "$tmp_text_size" ] || [ -z "$tmp_data_size" ] || [ -z "$tmp_bss_size" ];then
    #echo "$line"
    #echo `size $line`
    continue
  fi
  
  objs_text_size=$((objs_text_size+tmp_text_size))
  objs_data_size=$((objs_data_size+tmp_data_size))
  objs_bss_size=$((objs_bss_size+tmp_bss_size))
done <<< "$TARGET_OBJS"

if [ ! -z "$TARGET_OBJS" ];then
  echo "TARGET_OBJS    B $objs_text_size $objs_data_size $objs_bss_size"
  echo "              KB `echo "scale=2; $objs_text_size/1024" | bc` `echo "scale=2; $objs_data_size/1024" | bc` `echo "scale=2; $objs_bss_size/1024" | bc`"
  echo "              MB `echo "scale=2; $objs_text_size/1024/1024" | bc` `echo "scale=2; $objs_data_size/1024/1024" | bc` `echo "scale=2; $objs_bss_size/1024/1024" | bc`"
fi
#echo ""
#echo "TARGET_LIBS-------------------"
#echo "$TARGET_LIBS"
libs_text_size=0
libs_data_size=0
libs_bss_size=0
while read line
do
  if [ -z "$line" ];then
    continue
  fi
  tmp_text_size=0
  tmp_data_size=0
  tmp_bss_size=0
  
  
  tmp_lib_sizes=`size $line|awk 'NR>1'`
  tmp_each_text_size=0
  tmp_each_data_size=0
  tmp_each_bss_size=0
  while read line_size
  do
    #echo "$line_size"
    tmp_each_text_size=`echo $line_size|awk '{printf $1}'`
    tmp_each_data_size=`echo $line_size|awk '{printf $2}'`
    tmp_each_bss_size=`echo $line_size|awk '{printf $3}'`
    tmp_text_size=$(($tmp_text_size+$tmp_each_text_size))
    tmp_data_size=$(($tmp_data_size+$tmp_each_data_size))
    tmp_bss_size=$(($tmp_bss_size+$tmp_each_bss_size))
  done <<< "$tmp_lib_sizes"
  
  #echo "    $line"
  #echo "    $tmp_text_size $tmp_data_size $tmp_bss_size"
  libs_text_size=$(($libs_text_size+$tmp_text_size))
  libs_data_size=$(($libs_data_size+$tmp_data_size))
  libs_bss_size=$(($libs_bss_size+$tmp_bss_size))
done <<< "$TARGET_LIBS"
if [ ! -z "$TARGET_LIBS" ];then
  echo "TARGET_LIBS    B $libs_text_size $libs_data_size $libs_bss_size"
  echo "              KB `echo "scale=2; $libs_text_size/1024" | bc` `echo "scale=2; $libs_data_size/1024" | bc` `echo "scale=2; $libs_bss_size/1024" | bc`"
  echo "              MB `echo "scale=2; $libs_text_size/1024/1024" | bc` `echo "scale=2; $libs_data_size/1024/1024" | bc` `echo "scale=2; $libs_bss_size/1024/1024" | bc`"
fi
echo '-----------------The End-----------------'
cd $CUR_DIR

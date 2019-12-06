#!/bin/bash

if [ -z "$1" ]; then
  echo "para error!!"
  echo "usage: $0 docx md_dir_path [template_file_abs_path]"
  echo "       $0 pdf  md_dir_path [template_file_abs_path]"
  exit -1
fi
file_type="$1"
if [ "$file_type" == "docx" ] || [ "$file_type" == "pdf" ];then
  echo -e "\033[32m ===> $file_type \033[0m"
else
  echo -e "\033[31m !!!! no support for $file_type \033[0m"
  exit -1
fi

if [ ! -d "$2" ];then
  echo "$2 not dir!!"
  exit -1
fi

sys_type=$(uname -a|grep Linux -i)
if [ -z "$sys_type" ];then
  sys_type=Windows
else
  sys_type=Linux
fi
#echo $sys_type

template_file_path=$3
if [ ! -z "$template_file_path" ];then
  if [ ! -e "$template_file_path" ];then 
    echo "$3 check your template file path!!"
    exit -1
  fi
  if [ -d "$template_file_path" ];then
    echo "$3 must be template file path, not dir path!!"
    exit -1
  fi
  template_file_path=$(readlink -f "$template_file_path")
  echo -e "\033[42m template file: $template_file_path \033[0m"
fi


cur_path=$(pwd)
md_files=$(find "$2" -name *.md)

echo "$md_files" | while read line
do
  echo "----------------------------"
  echo $line
  base_dir=${line%/*}
  #echo $base_dir
  file_name=${line##*/}
  file_name_no_ext=${file_name%.md*}
  #echo $file_name
  #echo $file_name_no_ext
  
  cd $cur_path
  cp document-config -r $base_dir/
  cd $base_dir

  if [ -z "$template_file_path" ];then
    if [ "$sys_type" == "Linux" ];then
      pandoc  $file_name -o $file_name_no_ext.$file_type -V mainfont="黑体" --latex-engine=xelatex
    else
      pandoc  $file_name -o $file_name_no_ext.$file_type -V mainfont="黑体" --pdf-engine=xelatex
    fi
  else
    if [ "$sys_type" == "Linux" ];then
      pandoc  $file_name -o $file_name_no_ext.$file_type --latex-engine=xelatex --toc --smart --template="$template_file_path" #-V mainfont="黑体" 
    else
      pandoc  $file_name -o $file_name_no_ext.$file_type --pdf-engine=xelatex --toc --template="$template_file_path"
    fi
  fi
  if [ "$?" == "0" ];then
    echo -e "\033[32m ===> $base_dir/$file_name_no_ext.$file_type \033[0m"
  else
    echo -e "\033[31m ===> $base_dir/$file_name_no_ext.$file_type \033[0m"
    #exit -1
  fi
done

cd $cur_path

echo ------------------The End-------------------



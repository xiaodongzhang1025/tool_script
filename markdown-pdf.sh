#!/bin/bash

if [ -z "$1" ]; then
  echo "para error!!"
  echo "usage: $0 md_dir_path [template_file_abs_path]"
  exit -1
fi

if [ ! -d "$1" ];then
  echo "$1 not dir!!"
  exit -1
fi

template_file_path=$2
if [ ! -z "$template_file_path" ];then
  if [ ! -e "$template_file_path" ];then 
    echo "$2 check your template file path!!"
    exit -1
  fi
  if [ -d "$template_file_path" ];then
    echo "$2 must be template file path, not dir path!!"
    exit -1
  fi
  template_file_path=$(readlink -f "$template_file_path")
  echo -e "\033[42m template file: $template_file_path \033[0m"
fi

cur_path=$(pwd)
md_files=$(find "$1" -name *.md)

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
  cd $base_dir

  if [ -z "$template_file_path" ];then
    pandoc  $file_name -o $file_name_no_ext.pdf -V mainfont="黑体" --latex-engine=xelatex
  else
    pandoc  $file_name -o $file_name_no_ext.pdf --latex-engine=xelatex --toc --smart --template="$template_file_path" -V mainfont="黑体" 
  fi
  if [ "$?" == "0" ];then
    echo -e "\033[32m ===> $base_dir/$file_name_no_ext.pdf \033[0m"
  else
    echo -e "\033[31m ===> $base_dir/$file_name_no_ext.pdf \033[0m"
  fi
done

cd $cur_path

echo ------------------The End-------------------



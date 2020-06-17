num=$1
if [ -z "$num" ];then
  num=10
fi

    
#git log -n $num --pretty=short|grep -v "Change-Id:"|grep -v "Signed-off-by:"|grep -v "^Author:"|grep -v "^Date:"|grep -v "^commit"|grep -v '^$'|sort -u
#git log -n $num |grep -v "Change-Id:"|grep -v "Signed-off-by:"|grep -v "^Author:"|grep -v "^Date:"|grep -v "^commit"|tr -s '\n'|sort -u
echo "============================="
git log -n $num |grep -v "Change-Id:"|grep -v "Signed-off-by:"|grep -v "^Author:"|grep -v "^commit"| sed -e 's/^[ \t]*//g'|grep -v '^$'

echo "============================= remove repeat info"
#git log -n $num |grep -v "Change-Id:"|grep -v "Signed-off-by:"|grep -v "^Author:"|grep -v "^Date:"|grep -v "^commit"|grep -v '^$'|sort -u
git log -n $num |grep -v "Change-Id:"|grep -v "Signed-off-by:"|grep -v "^Author:"|grep -v "^Date:"|grep -v "^commit"| sed -e 's/^[ \t]*//g'|grep -v '^$'|awk '!a[$0]++'


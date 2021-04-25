#!/usr/bin/env bash

##############################################################################
#                                                                            #
#                              2021年4月24日 20:37:42
#                                                                            #
##############################################################################

##############################同步 diy.sh ##########################################
cd $ConfigDir
echo -e "开始更新 diy.sh "
wget -q --no-check-certificate https://gitee.com/jiandjh/docker/raw/main/diy.sh -O diy.sh.new
if [ $? -eq 0 ]; then
  mv -f diy.sh.new diy.sh
  echo -e "更新 diy.sh 完成"
else
  rm -rf diy.sh.new
  echo -e "更新 diy.sh 失败，使用上一次正常的版本...\n"
fi

############################## 作者名称 ##############################
author_list="
jiandjh
i-chenzhe
normal
qq34347476
member
whyour

"
######################################################################

############################## 维护:jiandjh ##############################
scripts_base_url_1=https://gitee.com/jiandjh/docker/raw/main/jd/
my_scripts_list_1="
jd_cash.js
jd_crazy_joy_collect.js
jd_crazy_joy_compose.js
jd_priceProtect.js
monk_inter_shop_sign.js

"
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

############################## 维护:i-chenzhe ##############################
scripts_base_url_2=https://gitee.com/mumuba2020/dust/raw/dust/i-chenzhe/
my_scripts_list_2="
z_carnivalcity.js
z_fanslove.js
z_marketLottery.js

"
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

############################## 维护:normal ##############################
scripts_base_url_3=https://gitee.com/mumuba2020/dust/raw/dust/normal/
my_scripts_list_3="
monk_inter_shop_sign.js
monk_shop_follow_sku.js
monk_shop_lottery.js
monk_skyworth.js

"

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

############################## 维护:qq34347476 ##############################
# 库地址:https://github.com/qq34347476/js_script
scripts_base_url_4=https://ghproxy.com/https://raw.githubusercontent.com/qq34347476/js_script/master/scripts/
my_scripts_list_4="
getShareCode_format.js

"
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

############################## 维护:member ##############################
scripts_base_url_5=https://gitee.com/mumuba2020/dust/raw/dust/member/
my_scripts_list_5="
monk_pasture.js

"
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

############################## 维护:whyour ##############################
scripts_base_url_6=https://ghproxy.com/https://raw.githubusercontent.com/whyour/hundun/master/quanx/
my_scripts_list_6="
jx_nc.js
jx_factory.js
jx_factory_component.js
jx_products_detail.js

"


############################ 是否强制替换脚本的定时 ############################
# 设为"ture"时强制替换脚本的定时，设为"false"则不替换脚本的定时...
Enablerenew="false"

############################## 随机函数 ##############################
rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /proc/sys/kernel/random/uuid | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))
}

############################## 下载脚本 ##############################
cd $ScriptsDir
index=1

for author in $author_list
do
  echo -e "######################### 开始下载 $author 的脚本 #########################"
  # 下载my_scripts_list中的每个js文件，重命名增加前缀"作者昵称_"，增加后缀".new"
  eval scripts_list=\$my_scripts_list_${index}
  eval url_list=\$scripts_base_url_${index}
  for js in $scripts_list
  do
    eval url=$url_list$js
    eval name=$author"_"$js
    echo $name
    wget -q --no-check-certificate $url -O $name.new

    # 如果上一步下载没问题，才去掉后缀".new"，如果上一步下载有问题，就保留之前正常下载的版本
    if [ $? -eq 0 ]; then
      mv -f $name.new $name
      echo -e "$name 更新成功!!!"
	  croname=`echo "$name"|awk -F\. '{print $1}'`
	  script_date=`cat  $name|grep "http"|awk '{if($1~/^[0-59]/) print $1,$2,$3,$4,$5}'|sort |uniq|head -n 1`
	  [ -z "${script_date}" ] && script_date=`cat  $name|grep -Eo "([0-9]+|\*) ([0-9]+|\*) ([0-9]+|\*) ([0-9]+|\*) ([0-9]+|\*)"|sort |uniq|head -n 1`
	  if [ -z "${script_date}" ]; then
	    cron_min=$(rand 1 59)
	    cron_hour=$(rand 7 9)
      [ $(grep -c "$croname" ${ConfigDir}/crontab.list) -eq 0 ] && sed -i "/hangup/a${cron_min} ${cron_hour} * * * bash jd $croname"  ${ConfigDir}/crontab.list
	  else
	    check_existing_cron=`grep -c "$croname" /jd/config/crontab.list`
	    echo $name "开始添加定时..."
	    if [ "${check_existing_cron}" -eq 0 ]; then
	      sed -i "/hangup/a${script_date} bash jd $croname"  /jd/config/crontab.list
	      echo -e "$name 成功添加定时!!!\n"
	    else
	      if [ "${Enablerenew}" = "true" ]; then
	      	echo -e "检测到"$name"定时已存在开始替换...\n"
	        grep -v "$croname" /jd/config/crontab.list > output.txt
		      mv -f output.txt /jd/config/crontab.list
		      sed -i "/hangup/a${script_date} bash jd $croname"  /jd/config/crontab.list
	        echo -e "替换"$name"定时成功!!!"
	      else
	        echo -e "$name 存在定时,已选择不替换...\n"
	      fi
	    fi
	  fi
    else
      [ -f $name.new ] && rm -f $name.new
      echo -e "$name 脚本失效,已删除脚本...\n"
      croname=`echo "$name"|awk -F\. '{print $1}'`
      check_existing_cron=`grep -c "$croname" /jd/config/crontab.list`
      if [ "${check_existing_cron}" -ne 0 ]; then
        grep -v "$croname" /jd/config/crontab.list > output.txt
        mv -f output.txt /jd/config/crontab.list
        echo -e \b"检测到"$name"残留文件..."
        rm -f ${name:-default}
        echo -e "开始清理"$name"残留文件..."
        cd $LogDir
        rm -rf ${croname:-default}
        echo -e "清理"$name"残留文件完成!!!\n"
        cd $ScriptsDir
      fi
    fi
  done
  index=$[$index+1]
done

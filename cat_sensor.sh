#!/bin/sh

# cat sensor's config

#Project_Dir=$(dirname $(readlink -f $0))
#Program=$2
#Platform=$1'-'$Program

Top_Path=${TINA_BUILD_TOP}
Target_Plan=${TARGET_PLAN}
Target_Board=${TARGET_BOARD}
Target__Platform=${TARGET_PLATFORM}


echo  "\n--------------------- sensor Makefile --------------------"
cat -n $Top_Path/lichee/linux-4.9/drivers/media/platform/sunxi-vin/modules/sensor/Makefile
echo  "\nThe file_path : lichee/linux-4.9/drivers/media/platform/sunxi-vin/modules/sensor/Makefile\n"
echo  "------------------------------------------------------------\n"


if [ "$Target__Platform" = "v536" ]; then
	board_cfg="sys_config.fex"
else
	board_cfg="board.dts"
fi
echo  "----------------------- $board_cfg --------------------------"
grep -n "sensor0" $Top_Path/device/config/chips/$Target__Platform/configs/$Target_Plan/$board_cfg
echo "\nThe file_path : device/config/chips/$Target__Platform/configs/$Target_Plan/$board_cfg"

echo  "----------------------- modules.mk -------------------------"
sed -n '6,22p' $Top_Path/target/allwinner/$Target_Board/modules.mk
echo  "\nThe file_path : target/allwinner/$Target_Board/modules.mk"
echo  "------------------------------------------------------------\n"

echo  "----------------------- S00mpp -----------------------------"
sed -n '8,32p' $Top_Path/target/allwinner/$Target_Board/busybox-init-base-files/etc/init.d/S00mpp
echo  "\nThe file_path : target/allwinner/$Target_Board/busybox-init-base-files/etc/init.d/S00mpp"
echo  "------------------------------------------------------------\n"
echo  "Please check your menuconfig for sensor cfg !!!\n"

#	echo  "----------------------- defcfg -----------------------------"
#	sed -n '2278,2284p' $Project_Dir/target/allwinner/$Platform/defconfig
#	echo  "------------------------------------------------------------\n"

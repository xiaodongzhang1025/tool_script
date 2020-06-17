#!/bin/sh


# top dir
Top_Path=${LOKI_BUILD_TOP}
Target_Plan=${TARGET_PLAN}
Target_Board=${TARGET_BOARD}
Target__Platform=${TARGET_PLATFORM}

if [ ! -n "$1" ] ;then
	echo "please enter the target_sensor's name( like imx317) !"
elif [ ! -n "$2" ] ;then
	echo "please enter the sensor's IIC_addr( like 0x34) !"
else

	# sensor_info
	sensor="$1"
	str_mipi="_mipi"
	sensor_name=$sensor$str_mipi
	iic_addr=$2

	if [ "$Target__Platform" = "v536" ]; then
		board_cfg="sys_config.fex"
		sensor0_mname="sensor0_mname         = \"$sensor_name\""
		sensor0_twi_addr="sensor0_twi_addr      = $iic_addr"
	else
		board_cfg="board.dts"
		sensor0_mname="			sensor0_mname = \"$sensor_name\";"
		sensor0_twi_addr="			sensor0_twi_addr = <$iic_addr>;"
	fi

	echo "sensor_name : $sensor_name"
	echo "IIC_Addr : $2\n"

	ls $Top_Path/lichee/linux-4.9/drivers/media/platform/sean-vin/modules/sensor/$sensor_name*.c
	#find -name "$sensor_name*.c" $Top_Path/lichee/linux-4.9/drivers/media/platform/sean-vin/modules/sensor/

	if [ $? -eq 0 ] ;then
		echo "\nTarget_sensor's driver is in the kernel !\n"
	else
		echo "\nKernel have no driver for target_sensor , please add in it !\n"
		mv $Top_Path/$sensor_name.c  $Top_Path/lichee/linux-4.9/drivers/media/platform/sean-vin/modules/sensor/
		if [ $? -eq 0 ] ;then
			echo "The driver is added in kernel !\n"
		else
			echo "please support the sensor driver !\n"
		fi
	fi

	grep "$sensor_name" $Top_Path/lichee/linux-4.9/drivers/media/platform/sean-vin/modules/sensor/Makefile
	if [ $? -eq 0 ] ;then
		echo "The file_path : lichee/linux-4.9/drivers/media/platform/sean-vin/modules/sensor/Makefile\n"
	else
		echo "obj-m                   += $sensor_name.o" >> $Top_Path/lichee/linux-4.9/drivers/media/platform/sean-vin/modules/sensor/Makefile
		echo "Target_sensor is added in the Makefile !\n"
	fi

	#  write board.dts | sys_config.fex
	board_dts_dir=$Top_Path/device/config/chips/$Target__Platform/configs/$Target_Plan/$board_cfg
	sed -i "/sensor0_mname/c\	$sensor0_mname"  $board_dts_dir
	sed -i "/sensor0_twi_addr/c\	$sensor0_twi_addr"  $board_dts_dir

	#  write modules.mk
	modules_mk_dir=$Top_Path/target/qigan/$Target_Board/modules.mk
	sensor_module_1=" FILES+=\$(LINUX_DIR)/drivers/media/platform/sean-vin/modules/sensor/$sensor_name.ko"

	#
	if [ "$Target__Platform" = "v536" ]; then
		sensor_module_2=" AUTOLOAD:=\$(call AutoProbe,videobuf2-core videobuf2-dma-contig videobuf2-memops videobuf2-v4l2 vin_io $sensor_name tp9950 da380 vin_v4l2)"
		sed -i "16 c \ $sensor_module_1"  $modules_mk_dir
	else
		sensor_module_2=" AUTOLOAD:=\$(call AutoProbe,videobuf2-core videobuf2-dma-contig videobuf2-memops videobuf2-v4l2 vin_io $sensor_name vin_v4l2)"
		sed -i "/modules\/sensor\//c\ $sensor_module_1"  $modules_mk_dir
	fi
	sed -i "/call AutoProbe,videobuf2-core videobuf2-dma-contig videobuf2-memops videobuf2-v4l2 vin_io/c\ $sensor_module_2"  $modules_mk_dir

	#  write S00mpp
	S00mpp_dir=$Top_Path/target/qigan/$Target_Board/busybox-init-base-files/etc/init.d/S00mpp
	insmod_line="   insmod \$MODULES_DIR/$sensor_name.ko"
	rmmod_line="   rmmod \$MODULES_DIR/$sensor_name.ko"
	sed -i "/insmod.*mipi.ko/c\ $insmod_line"  $S00mpp_dir
	sed -i "/rmmod.*mipi.ko/c\ $rmmod_line"  $S00mpp_dir

	echo "Please check the menuconfig for the target_sensor !\n"
fi

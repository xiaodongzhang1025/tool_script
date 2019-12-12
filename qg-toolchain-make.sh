CUR_PATH=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
PARA0=$0
#echo $CUR_PATH
if [ "$PARA0" == "bash" ]; then
  echo  -e "\033[41m do not source ${BASH_SOURCE[0]}, run it directly [./${BASH_SOURCE[0]}]!!\033[0m"
  return
fi

export PATH=$PATH:$CUR_PATH/out/bin
export SOURCE_DIR=$CUR_PATH/source
export BUILD_DIR=$CUR_PATH/build
export OUT_DIR=$CUR_PATH/out
binutils_pkg_file=`ls -l source/ |grep "binutils.*tar.*" |awk '{print $9}'`
musl_pkg_file=`ls -l source/ |grep "musl.*tar.*" |awk '{print $9}'`
gcc_pkg_file=`ls -l source/ |grep "gcc.*tar.*" |awk '{print $9}'`
fortify_pkg_file=`ls -l source/ |grep "fortify.*tar.*" |awk '{print $9}'`
gdb_pkg_file=`ls -l source/ |grep "gdb.*tar.*" |awk '{print $9}'`

binutils_pkg_dir=
gcc_pkg_dir_minimal=
kernel_header_dir=
musl_pkg_dir=
gcc_pkg_dir_initial=
gcc_pkg_dir_final=
fortify_pkg_dir=

binutils_pkg_dir=`echo $binutils_pkg_file|awk -F ".tar" '{print $1}'`
gcc_pkg_dir_minimal=`echo $gcc_pkg_file|awk -F ".tar" '{print $1}'`
kernel_header_dir="/Work/QG2101-SDK-v1.0/lichee/linux-4.9"
musl_pkg_dir=`echo $musl_pkg_file|awk -F ".tar" '{print $1}'`
gcc_pkg_dir_initial=`echo $gcc_pkg_file|awk -F ".tar" '{print $1}'`
gcc_pkg_dir_final=`echo $gcc_pkg_file|awk -F ".tar" '{print $1}'`
fortify_pkg_dir=`echo $fortify_pkg_file|awk -F ".tar" '{print $1}'`


#####################################################################
#gmp-5.0.1        https://gmplib.org/download/gmp/gmp-5.0.1.tar.xz
#mpfr-3.1.4       
#mpc-1.0.2        
echo -e "\033[42m 0. checking gmp mpfr mpc \033[0m"
gmp_path="/usr/local/gmp"
mpfr_path="/usr/local/mpfr"
mpc_path="/usr/local/mpc"
check_flag=1
if [ ! -d $gmp_path ] ;then
    echo -e "\033[41m 0. checking gmp  not found!!\033[0m"
    check_flag=0
    #./configure --prefix=/usr/local/gmp/  --enable-cxx
    #make && make install
fi
if [ ! -d $mpfr_path ] ;then
    echo -e "\033[41m 0. checking mpfr  not found!!\033[0m"
    check_flag=0
    #./configure --prefix=/usr/local/mpfr/  --enable-cxx
    #make && make install
fi
if [ ! -d $mpc_path ] ;then
    echo -e "\033[41m 0. checking mpc  not found!!\033[0m"
    check_flag=0
    #./configure --prefix=/usr/local/mpc/  --with-mpfr=/usr/local/mpfr
    #make && make install
fi
if [ "$check_flag" == "0" ]; then
    echo "    not pass."
    exit -1
else
    echo "    pass."
fi

#####################################################################
if [ -n "$binutils_pkg_dir" ]; then
    echo -e "\033[42m 1. $binutils_pkg_file \033[0m"
    cd $SOURCE_DIR
    if [ -d $binutils_pkg_dir ] ; then
      rm -rf $binutils_pkg_dir
    fi
    tar -xvf $SOURCE_DIR/$binutils_pkg_file
    cd $BUILD_DIR
    if [ -d $binutils_pkg_dir ] ; then
      rm -rf $binutils_pkg_dir
    fi
    mkdir -p $BUILD_DIR/$binutils_pkg_dir
    cd $BUILD_DIR/$binutils_pkg_dir
    $SOURCE_DIR/$binutils_pkg_dir/configure --prefix=$OUT_DIR --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=arm-openwrt-linux-muslgnueabi \
      --with-sysroot=$OUT_DIR --enable-deterministic-archives --enable-plugins --enable-lto --disable-multilib --disable-werror \
      --disable-nls --disable-sim --disable-gdb --disable-libssp
    make all
    mkdir -p $OUT_DIR/initial
    make prefix=$OUT_DIR/initial install
    make $OUT_DIR install
    
    #ln -sf $OUT_DIR/lib $OUT_DIR/initial/lib64
    #rm -f $OUT_DIR/initial/lib/libiberty.a
    #cp -fpR $OUT_DIR/bin/arm-openwrt-linux-muslgnueabi-readelf $OUT_DIR/readelf
else
    echo -e "\033[41m 1. $binutils_pkg_file not found!!\033[0m"
fi
###################################################################
if [ -n "$gcc_pkg_dir_minimal" ]; then
    echo -e "\033[42m 2. $gcc_pkg_file [minimal] \033[0m"
    cd $SOURCE_DIR
    if [ -d $gcc_pkg_dir_minimal ] ; then
      rm -rf $gcc_pkg_dir_minimal
    fi
    tar -xvf $SOURCE_DIR/$gcc_pkg_file
    cd $BUILD_DIR
    if [ -d $gcc_pkg_dir_minimal-minimal ] ; then
      rm -rf $gcc_pkg_dir_minimal-minimal
    fi
    mkdir -p $BUILD_DIR/$gcc_pkg_dir_minimal-minimal
    cd $BUILD_DIR/$gcc_pkg_dir_minimal-minimal
    
    $SOURCE_DIR/$gcc_pkg_dir_minimal/configure --with-bugurl=https://dev.openwrt.org/ --with-pkgversion="OpenWrt/$gcc_pkg_dir_minimal" --prefix=$OUT_DIR \
      --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=arm-openwrt-linux-muslgnueabi --with-gnu-ld --enable-target-optspace \
      --enable-libgomp --disable-libmudflap --disable-multilib --disable-nls --without-isl --without-cloog --with-host-libstdcxx=-lstdc++ \
      --with-gmp=/usr/local/gmp --with-mpfr=/usr/local/mpfr --with-mpc=/usr/local/mpc --disable-decimal-float \
      --with-diagnostics-color=auto-if-env --disable-libssp --enable-__cxa_atexit --with-arch=armv7-a --with-float=hard --with-newlib \
      --without-headers --enable-languages=c --disable-libsanitizer --disable-libssp --disable-shared --disable-threads
      
    make CFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      CXXFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      all-gcc all-target-libgcc 
    
    make CFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      CXXFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      install-gcc install-target-libgcc
else
    echo -e "\033[41m 2. $gcc_pkg_file [minimal] not found!!\033[0m"
fi
###################################################################
if [ -n "$kernel_header_dir" ]; then
    echo -e "\033[42m 3. kernel_header install \033[0m"
    
    make -C "$kernel_header_dir" HOSTCFLAGS="-O2 -Wall -Wmissing-prototypes -Wstrict-prototypes" ARCH=arm CC="arm-openwrt-linux-muslgnueabi-gcc" \
      CFLAGS="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -fno-plt -fhonourcopts -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      CROSS_COMPILE=arm-openwrt-linux-muslgnueabi- KBUILD_HAVE_NLS=no CONFIG_SHELL=bash oldconfig
    
    if [ -d "$BUILD_DIR/linux-dev" ]; then
        rm -rf "$BUILD_DIR/linux-dev"
    fi
    mkdir -p "$BUILD_DIR/linux-dev"
    make -C "$kernel_header_dir" HOSTCFLAGS="-O2 -Wall -Wmissing-prototypes -Wstrict-prototypes" ARCH=arm CC="arm-openwrt-linux-muslgnueabi-gcc" \
      CFLAGS="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -fno-plt -fhonourcopts -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      CROSS_COMPILE=arm-openwrt-linux-muslgnueabi- KBUILD_HAVE_NLS=no CONFIG_SHELL=bash INSTALL_HDR_PATH="$BUILD_DIR/linux-dev/" headers_install
    cp -fpR $BUILD_DIR/linux-dev/* $OUT_DIR/
else
    echo -e "\033[41m 3. kernel_header not found!!\033[0m"
fi
####################################################################
if [ -n "$musl_pkg_dir" ]; then
    echo -e "\033[42m 4. $musl_pkg_file \033[0m"
    cd $SOURCE_DIR
    if [ -d $musl_pkg_dir ] ; then
      rm -rf $musl_pkg_dir
    fi
    tar -xvf $SOURCE_DIR/$musl_pkg_file
    cp -fpR $BUILD_DIR/linux-dev/include/* $SOURCE_DIR/$musl_pkg_dir/include
else
    echo -e "\033[41m 4. $musl_pkg_file not found!!\033[0m"
fi
###################################################################
if [ -n "$gcc_pkg_dir_initial" ]; then
    echo -e "\033[42m 5. $gcc_pkg_file [initial] \033[0m"
    cd $SOURCE_DIR
    if [ -d $gcc_pkg_dir_initial ] ; then
      rm -rf $gcc_pkg_dir_initial
    fi
    tar -xvf $SOURCE_DIR/$gcc_pkg_file
    cd $BUILD_DIR
    if [ -d $gcc_pkg_dir_initial-initial ] ; then
      rm -rf $gcc_pkg_dir_initial-initial
    fi
    mkdir -p $BUILD_DIR/$gcc_pkg_dir_initial-initial
    cd $BUILD_DIR/$gcc_pkg_dir_initial-initial
    
    $SOURCE_DIR/$gcc_pkg_dir_initial/configure --with-bugurl=https://dev.openwrt.org/ --with-pkgversion="OpenWrt/$gcc_pkg_dir_initial" --prefix=$OUT_DIR \
      --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=arm-openwrt-linux-muslgnueabi --with-gnu-ld --enable-target-optspace \
      --enable-libgomp --disable-libmudflap --disable-multilib --disable-nls --without-isl --without-cloog --with-host-libstdcxx=-lstdc++ \
      --with-gmp=/usr/local/gmp --with-mpfr=/usr/local/mpfr --with-mpc=/usr/local/mpc --disable-decimal-float \
      --with-diagnostics-color=auto-if-env --disable-libssp --enable-__cxa_atexit --with-arch=armv7-a --with-float=hard --with-newlib \
      --with-sysroot=$OUT_DIR --enable-languages=c --disable-shared --disable-threads
      
    make CFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      CXXFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      all-build-libiberty all-gcc all-target-libgcc
      
    make CFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      CXXFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      prefix="$OUT_DIR/initial" install-gcc install-target-libgcc
else
    echo -e "\033[41m 5. $gcc_pkg_file [initial] not found!!\033[0m"
fi
###################################################################
if [ -d "$OUT_DIR/initial/lib/gcc/arm-openwrt-linux-muslgnueabi/6.4.1" ]; then
    cd $OUT_DIR/initial/lib/gcc/arm-openwrt-linux-muslgnueabi/6.4.1
    ln -sf libgcc.a libgcc_eh.a
    cp libgcc.a libgcc_initial.a
    ln -sf lib $OUT_DIR/initial/lib64

    #!/bin/sh
    for src_dir in $OUT_DIR/initial/; do
    ( cd $src_dir; find -type f -or -type d ) | ( cd $OUT_DIR/; while :; do read FILE; [ -z "$FILE" ]&& break; [ -L "$FILE" ] || continue; echo "Removing symlink $OUT_DIR/$FILE"; rm -f "$FILE"; done; );
    done;
    cp -fpR $OUT_DIR/initial/. $OUT_DIR/
fi
###################################################################
if [ -n "$musl_pkg_dir" ]; then
  echo -e "\033[41m 6. $musl_pkg_file compile !!\033[0m"
  cd $BUILD_DIR
  if [ -d $musl_pkg_dir ] ; then
    rm -rf $musl_pkg_dir
  fi
  mkdir -p $BUILD_DIR/$musl_pkg_dir
  cd $BUILD_DIR/$musl_pkg_dir
  AR="arm-openwrt-linux-muslgnueabi-gcc-ar" 
  AS="arm-openwrt-linux-muslgnueabi-gcc -c -Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro" \
  LD=arm-openwrt-linux-muslgnueabi-ld NM="arm-openwrt-linux-muslgnueabi-gcc-nm" CC="arm-openwrt-linux-muslgnueabi-gcc" GCC="arm-openwrt-linux-muslgnueabi-gcc" CXX="arm-openwrt-linux-muslgnueabi-g++" \
  RANLIB="arm-openwrt-linux-muslgnueabi-gcc-ranlib" STRIP=arm-openwrt-linux-muslgnueabi-strip OBJCOPY=arm-openwrt-linux-muslgnueabi-objcopy OBJDUMP=arm-openwrt-linux-muslgnueabi-objdump \
  SIZE=arm-openwrt-linux-muslgnueabi-size CFLAGS="-Os -pipe-march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -fno-plt -fhonour-copts -Wno-error=unusedbut-set-variable \
  Wno-error=unused-result -mfloat-abi=hard -Wformat -Werror=format-security -fstack-protector -D_FORTIFY_SOURCE=1 -Wl,-z,now -Wl,-z,relro" CROSS_COMPILE="arm-openwrt-linux-muslgnueabi-" \
  
  $SOURCE_DIR/$musl_pkg_dir/configure --prefix=/ --host=x86_64-linux-gnu --target=arm-openwrt-linux-muslgnueabi --disable-gcc-wrapper --enable-debug
  make DESTDIR="$OUT_DIR" LIBCC="$OUT_DIR/lib/gcc/arm-openwrt-linux-muslgnueabi/6.4.1/libgcc_initial.a" CONFIG_MUSL_OPTIMIZATION=y all
  make DESTDIR="$OUT_DIR" LIBCC="$OUT_DIR/lib/gcc/arm-openwrt-linux-muslgnueabi/6.4.1/libgcc_initial.a" CONFIG_MUSL_OPTIMIZATION=y DESTDIR="$OUT_DIR" install
else
    echo -e "\033[41m 6. $musl_pkg_file compile not found!!\033[0m"
fi
####################################################################
if [ -n "$gcc_pkg_dir_final" ]; then
    echo -e "\033[42m 7. $gcc_pkg_file [final] \033[0m"
    cd $SOURCE_DIR
    if [ -d $gcc_pkg_dir_final ] ; then
      rm -rf $gcc_pkg_dir_final
    fi
    tar -xvf $SOURCE_DIR/$gcc_pkg_file
    cd $BUILD_DIR
    if [ -d $gcc_pkg_dir_final-final ] ; then
      rm -rf $gcc_pkg_dir_final-final
    fi
    mkdir -p $BUILD_DIR/$gcc_pkg_dir_final-final
    cd $BUILD_DIR/$gcc_pkg_dir_final-final
    $SOURCE_DIR/$gcc_pkg_dir_final/configure --with-bugurl=https://dev.openwrt.org/ --with-pkgversion="OpenWrt/$gcc_pkg_dir_final" --prefix=$OUT_DIR \
      --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=arm-openwrt-linux-muslgnueabi --with-gnu-ld --enable-target-optspace \
      --enable-libgomp --disable-libmudflap --disable-multilib --disable-nls --without-isl --without-cloog --with-host-libstdcxx=-lstdc++ \
      --with-gmp=/usr/local/gmp --with-mpfr=/usr/local/mpfr --with-mpc=/usr/local/mpc --disable-decimal-float \
      --with-diagnostics-color=auto-if-env --disable-libssp --enable-__cxa_atexit --with-arch=armv7-a --with-float=hard --with-headers=$OUT_DIR/include \
      --disable-libsanitizer --enable-languages="c,c++" --enable-shared --enable-threads --with-slibdir=$OUT_DIR/lib --enable-lto
    
    rm -rf $OUT_DIR/arm-openwrt-linux-muslgnueabi/sys-include
    ln -sf ../include $OUT_DIR/arm-openwrt-linux-muslgnueabi/sys-include
    rm -rf $OUT_DIR/arm-openwrt-linux-muslgnueabi/lib
    ln -sf ../lib $OUT_DIR/arm-openwrt-linux-muslgnueabi/lib
    
    make CFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      CXXFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      gcc_cv_libc_provides_ssp=yes all-build-libiberty all-gcc all-target-libgcc all
    
    echo "7. $gcc_pkg_file [final] build end!!"
    
    make CFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      CXXFLAGS_FOR_TARGET="-Os -pipe -march=armv7-a -mtune=cortex-a7 -mfpu=neon -fno-caller-saves -Wno-error=unused-but-set-variable -Wno-error=unused-result -mfloat-abi=hard" \
      gcc_cv_libc_provides_ssp=yes install
else
    echo -e "\033[41m 7. $gcc_pkg_file [final] not found!!\033[0m"
fi

####################################################################
if [ -n "$fortify_pkg_dir" ]; then
    echo -e "\033[42m 8. $fortify_pkg_file \033[0m"
    cd $SOURCE_DIR
    if [ -d $fortify_pkg_dir ] ; then
      rm -rf $fortify_pkg_dir
    fi
    tar -xvf $SOURCE_DIR/$fortify_pkg_file
    make -C $SOURCE_DIR/$fortify_pkg_dir PREFIX="" DESTDIR="$OUT_DIR" install
else
    echo -e "\033[41m 8. $fortify_pkg_file not found!!\033[0m"
fi
###################################################################
cd $OUT_DIR
rm arm-openwrt-linux lib32
ln -sf arm-openwrt-linux-muslgnueabi arm-openwrt-linux
ln -sf lib lib32
cd $CUR_PATH


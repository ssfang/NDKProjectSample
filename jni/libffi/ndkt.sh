
function echo_no_exit {
    echo -e "\033[31m No \033[0m" #Foreground: red
    exit 1
}

function echo_yes {
    #Foreground: Green
	echo -e "\033[32m Yes \033[0m"
    
	if [ -n "$1" ]; then
        #Foreground: Sky blue / Cyan
        echo -en "\033[36m "
        echo -n "$1"
        echo -e "\033[0m"
    fi
}

#check the subpath relative to the directory specified by the environment variable NDK_ROOT
function check_subpath_exist {
    echo -n "Checking whether \$NDK_ROOT/$1 exist:"
    if [ -z "$NDK_ROOT/$1" ];then
        echo_no_exit;
    else
        echo_yes;
    fi  
}

ARCH=$1
ARCH=${ARCH:="arm"}

# # APP_ABI := armeabi armeabi-v7a x86  # APP_ABI := all
# case "$ARCH" in
   # armeabi)
     # echo 'APP_ABI = armeabi'
     # ;;
   # armeabi-v7a)
     # echo 'APP_ABI = armeabi-v7a'
     # ;;
   # x86)
     # echo 'APP_ABI = x86'
     # ;;
   # *)
     # echo 'APP_ABI = armeabi'
     # ;;
# esac

APP_PLATFORM=$1
# >> determine sysroot for android-x by $APP_PLATFORM
if [ "$APP_PLATFORM" -gt 0 ] 2>/dev/null;then
	#A number greater than zero
	APP_PLATFORM="android-$APP_PLATFORM" 
else
	APP_PLATFORM=${APP_PLATFORM:="android-9"}
fi

echo "APP_PLATFORM = $APP_PLATFORM"


# >> determine the toolchain name by $ARCH
TOOLCHAIN_VERSION=4.6 # 4.6, 4.8, 4.9 for gcc; clang3.5, clang3.6, ...
case "$ARCH" in
   arm64)
     TOOLCHAIN_NAME=aarch64-linux-android-$TOOLCHAIN_VERSION
     ;;
   x86_64)
     TOOLCHAIN_NAME=x86_64-$TOOLCHAIN_VERSION
     ;;
   mips64)
     TOOLCHAIN_NAME=mips64el-linux-android-$TOOLCHAIN_VERSION
     ;;
   arm*) # arm|armeabi|armeabi-v7a
	 TOOLCHAIN_NAME=arm-linux-androideabi-$TOOLCHAIN_VERSION
     ;;
   x86)
     TOOLCHAIN_NAME=x86-$TOOLCHAIN_VERSION
     ;;
   mips)
     #TOOLCHAIN_NAME_PREFIX='mips'
	 TOOLCHAIN_NAME=mipsel-linux-android-$TOOLCHAIN_VERSION
     ;;
   *)
     echo "Cannot determine the toolchain for ARCH=$ARCH, see below:"
	 ls -l $NDK_ROOT/toolchains
     exit 1
     ;;
esac

echo -e "\nDetermine \$TOOLCHAIN_NAME=$TOOLCHAIN_NAME"
check_subpath_exist toolchains/$TOOLCHAIN_NAME;


# >> determine the toolchain prebuilt directory
UNAME_MACHINE=`(uname -m) 2>/dev/null` || UNAME_MACHINE=unknown
UNAME_OS=$(uname -s)
case "$UNAME_OS" in
   Darwin)
     OS_NAME='mac'
     ;;
   Linux)
	 OS_NAME='linux'
     ;;
   CYGWIN*|MINGW32*|MSYS*)
     OS_NAME='windows'
     ;;
   # Add here more strings to compare
   # See correspondence table at the bottom of this answer
   *)
     echo "Unsupported os for $OS_NAME"
     exit 1
     ;;
esac

echo -e "\nDetect OS: $OS_NAME $UNAME_MACHINE, \`uname -s\` = $UNAME_OS"
OS_DIR=`ls -d $NDK_ROOT/toolchains/$TOOLCHAIN_NAME/prebuilt/$OS_NAME* 2>/dev/null`
OS_DIR_COUNT=`echo $OS_DIR | wc -l`


echo -n "Check toolchain exist:"
if [ $OS_DIR_COUNT -gt 1 ]; then
	echo 'Warning' 
	echo "Multiple toolchains for $TOOLCHAIN_NAME, but first adopt!!"
	OS_DIR=`echo $OS_DIR | head -1`
elif [ $OS_DIR_COUNT -eq 0 ]; then
	echo_no_exit;
else
	echo_yes;
fi
OS_NAME=${OS_NAME##*/}

echo "\$OS_NAME = $OS_NAME"
echo "\$OS_DIR = \$NDK_ROOT/toolchains/$TOOLCHAIN_NAME/prebuilt/$OS_NAME"

# configure后，建议使用cygwin的make，因为ndk的make只认windows路径，而前者既可以识别添加双引号的windows路径也认得unix风格路径，而且认得cygwin下ln创建的符号链接symlink -s 
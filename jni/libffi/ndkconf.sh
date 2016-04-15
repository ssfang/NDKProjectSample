#!/bin/bash --posix

# Avoid an error about function xx() statement on some os, e.g. on ubuntu, Syntax error: "(" unexpected 
# http://ubuntuforums.org/archive/index.php/t-499045.html

#filename: ndk-path.sh

###############################################
# . ./ndk-path.sh -tla 4.9 9 mips > result.txt
###############################################


#######################################
# Get the toolchain prefix for the subdirectory under $NDK_ROOT/toolchains and for binary file prefix 
# http://developer.android.com/intl/zh-cn/ndk/guides/abis.html
# under $NDK_ROOT/toolchains/<TOOLCHAIN_NAME>/prebuilt/<NDK4OS_DIRNAME>/bin
# Globals:
# 									aarch64			x86_64		x86				arm*
#	TOOLCHAIN_PREFIX_ARCH			aarch64			x86_64		x86				arm
#	TOOLCHAIN_PREFIX_OS			-linux-android-		   -		-		-linux-androideabi-
#	TOOLCHAIN_BIN_PREFIX_ARCH		aarch64			x86_64		i686			arm
#	TOOLCHAIN_BIN_PREFIX_OS		linux-android linux-android linux-android	linux-androideabi
# Arguments:
#   arch: [arm64, x86_64, mips64, x86, mips, arm*]
# Returns:
#	None
#######################################
function initToolchainPrefix(){
	## TOOLCHAIN_PREFIX=$tc_os$tc_arch
	## TOOLCHAIN_BIN_PREFIX=$TOOLCHAIN_BIN_PREFIX_ARCH-$TOOLCHAIN_BIN_PREFIX_OS-
	local tc_os tc_arch tc_bin_prefix_arch tc_bin_prefix_os
	case "$1" in
		arm64)
			tc_arch='aarch64'
	     ;;
		x86_64)
			tc_arch='x86_64'
			tc_os=-
		;;
		mips64)
			tc_arch='mips64el'
		;;
		x86) ## toolchains\x86-4.9\prebuilt\windows-x86_64\bin\i686-linux-android-gcc.exe
			tc_arch='x86'
			tc_os=-
			tc_bin_prefix_arch='i686'
		;;
		mips)
			tc_arch='mipsel'
		;;
		arm*) # # arm|armeabi|armeabi-v7a
			tc_arch='arm'
			tc_os='-linux-androideabi-'
			tc_bin_prefix_os='linux-androideabi'
		;;
		*)
			tc_arch='unknown' 
		;;
	esac
	## Set if declared but not set or is null
	TOOLCHAIN_PREFIX_ARCH=$tc_arch
	TOOLCHAIN_BIN_PREFIX_ARCH=${tc_bin_prefix_arch:-$tc_arch}
	TOOLCHAIN_PREFIX_OS=${tc_os:--linux-android-}
	TOOLCHAIN_BIN_PREFIX_OS=${tc_bin_prefix_os:-linux-android}
}

## @param $1 toolchain 4.6, 4.8, 4.9 for gcc; clang3.3, clang3.4 for clang
## @global TOOLCHAIN_NAME
function initToolchainName(){
	if [ -z "$1" ];then
		## strip tailing dash
		TOOLCHAIN_NAME=$TOOLCHAIN_PREFIX_ARCH${TOOLCHAIN_PREFIX_OS%-}
		## check exist
		local path=`ls -d "$NDK_ROOT/toolchains/$TOOLCHAIN_NAME-"[1-9]* | head -n1`
		TOOLCHAIN_NAME=${path##*[/\\]}
	elif [[ "$1" == *-* ]]; then
		TOOLCHAIN_NAME=$1
	else
		TOOLCHAIN_NAME=$TOOLCHAIN_PREFIX_ARCH$TOOLCHAIN_PREFIX_OS$1
	fi
}

#######################################
# Determine the toolchain prebuilt directory
# Globals:
#	NDK4OS [darwin, linux, windows, unknown]
# Arguments:
#   None
# Returns:
#	the toolchain bin parent directory name: [windows, windows-x86_64, linux-x86, linux-x86_64]
#######################################
function detectNdkOsDirName(){
    # $MACHTYPE machine type that identifies the system hardware.
    # UNAME_M = `(uname -m) 2>/dev/null` || UNAME_M=unknown
	local ndk4os_suffix
	
	if [[ "`(uname -m) 2>/dev/null`" == *64 ]]; then
		ndk4os_suffix=-x86_64
	fi
	
	case "`uname -s`" in
		Darwin)
			NDK4OS='darwin'
			: ${ndk4os_suffix=-x86}
		;;
		Linux)
			NDK4OS='linux'
			: ${ndk4os_suffix=-x86}
		;;
		CYGWIN*|MINGW32*|MSYS*)
			NDK4OS='windows'
		;;
		*)
			NDK4OS='unknown'
		exit 1
		;;
	esac
	echo "$NDK4OS$ndk4os_suffix"
}

function blue_echo {
	#Foreground: Sky blue / Cyan
	echo && echo -en "\033[36m" && echo -n "$1" && echo -e "\033[0m"
}

#######################################
# Check the subdirectory under the NDK_ROOT directory, special when subpath=''
# @param_$1 label 
# @param_$2 subpath
# @returns TRUE if exists
#######################################
function check_dir {
	local path;
	if [ -z "$2" ]; then
		blue_echo "NDK_ROOT=$NDK_ROOT"
		path=$NDK_ROOT
	else
		blue_echo "$1=\$NDK_ROOT/$2"
		path=$NDK_ROOT/$2
	fi
	echo -n "Checking whether $1 exist:"
	if [ -d "$path" ];then
		echo -e "\033[32m Yes \033[0m"
	else
		echo -e "\033[31m No \033[0m" #Foreground: red
		return 1
	fi
}
## api_level, api_arch, toolchain

###################
## @see http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
## @see getopt
# Supported option formats:
#	-x x_value
#	--long_x x_value
#	-xy x_value y_value			Next option must remove a prefix '-'
#	-x-long_y x_value y_value

# @see http://tldp.org/LDP/abs/html/parameter-substitution.html#PARAMSUBREF
# @see http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
###############

while [[ $# > 0 ]]
do
    key="$1"
    while [[ ${key+x} ]] #
    do
        case $key in
			-l*|--level)
				api_level="$2"
				echo "api_level=$api_level"
			;;
			-a*|--arch)
				api_arch="$2"
				echo "api_arch=$api_arch"
			;;
			-t*|--toolchain*)
				toolchain="$2"
			;;
			-h*|--help*)
				echo "\
Usage: [option value] [option-list corresponding-value-list]...
 For option-list, subsequent options must remove a prefix '-', 
 e.g. -a-level arm 12, -tla 4.9 9 x86
Options:
 -l|--level     NDK_API_LEVEL, default:9, ls \$NDK_ROOT/platforms
 -a|--arch      NDK_API_ARCH, default:arm, values: 
                [arm64, x86_64, mips64, x86, mips, arm*]
 -t|--toolchain version of gcc or full name, ls \$NDK_ROOT/toolchains
 -h|--help      print short or long help message and exit
"
				exit
				;;
			*)
				# unknown option
				echo Unknown option: $key #1>&2
				exit 10 # either this: my preferred way to handle unknown options
				break # or this: do this to signal the option has been handled (if exit isn't used)
			;;
		esac
		shift
		# prepare for next option in this key, if any
		[[ "$key" = -? || "$key" == --* ]] && unset key || key="${key/#-?/-}"
	done ## end of while
	shift # option(s) fully processed, proceed to next input argument
done

# 决定NDK根目录，如 /opt/android-ndk-r10c
: ${NDK_ROOT:=${ANDROID_NDK_HOME:-/opt/android-ndk}}
check_dir 'the environment variable NDK_ROOT' || exit 1

# 决定API等级和要编译二进制的架构
: ${api_level:=9}
: ${api_arch:=arm}
API_LEVEL_DIRNAME=android-$api_level
API_ARCH_DIRNAME=arch-$api_arch

# 决定工具链路径上的一些子目录名字
initToolchainPrefix $api_arch && initToolchainName $toolchain
: ${NDK4OS_DIRNAME:=`detectNdkOsDirName`}

API_SUBPATH=platforms/$API_LEVEL_DIRNAME/$API_ARCH_DIRNAME
TC_BIN_SUBPATH=toolchains/$TOOLCHAIN_NAME/prebuilt/$NDK4OS_DIRNAME/bin

check_dir 'ABI_PATH' $API_SUBPATH || exit 1
check_dir 'TOOLCHAIN_BIN_PATH' $TC_BIN_SUBPATH || exit 1

blue_echo "NDK_MAKE=$NDK_ROOT/prebuilt/$NDK4OS_DIRNAME/bin/make.exe"

# 检查windows上运行cygwin的情况，需要注意在Windows上编译可能比较慢，也许相当慢
OS_NAME=$(uname -s)
if [[ "$OS_NAME" == CYGWIN* ]];then
	export PATH="`cygpath $NDK_ROOT/$TC_BIN_SUBPATH`":${oldPATH=$PATH}
	##@TODO like --windows, windows form path but with regular slashes (C:/WINNT)
	export NDK_ROOT=`cygpath -m $NDK_ROOT`


	# ln -s (target exists) (link is made)
	# mklink (link is made) (target exists)
	
	## which make.exe to use? of NDK or cygwin...
	
	## http://stackoverflow.com/questions/3648819/how-to-make-symbolic-link-with-cygwin-in-windows-7
	## https://cygwin.com/cygwin-ug-net/using-cygwinenv.html
	## https://cygwin.com/cygwin-ug-net/using.html#pathnames-symlinks
	# export CYGWIN="winsymlinks" # ln -s: The shortcut style symlinks with file extension '.lnk'
	# export CYGWIN="winsymlinks:native" # ln -s: plain text file
	
	# hook ln and propagate it to other scripts to pollute the environment of subsequently executed commands
	function ln(){ 
		if [[ "-s" == "$1" ]]; then
			cmd /C mklink /H "$(cygpath -aw "$3")" "`cygpath -aw "$2"`"
		else
			echo -e "\033[32m >>ln $* \033[0m"
			command ln "$*"
		fi
	}
	export -f ln
else
	export PATH="$NDK_ROOT/$TC_BIN_SUBPATH":${OLDPATH=$PATH}
fi
echo "OS_NAME=$OS_NAME"

# 以下是配置编译环境 

export SYSROOT=$NDK_ROOT/$API_SUBPATH
echo "SYSROOT=$SYSROOT"

tc_bin_prefix=$TOOLCHAIN_BIN_PREFIX_ARCH-$TOOLCHAIN_BIN_PREFIX_OS-
export CC=${tc_bin_prefix}gcc  # C编译程序。默认是"cc"
export CXX=${tc_bin_prefix}g++ # C++编译程序。默认是"g++"
export CPP=${tc_bin_prefix}cpp # C/C++预处理器。默认是"$(CC) -E"
export AR=${tc_bin_prefix}ar # 函数库打包程序，可创建静态库.a文档。默认是"ar"
export AS=${tc_bin_prefix}as # 汇编程序。默认是"as"
export NM=${tc_bin_prefix}nm
export LD=${tc_bin_prefix}ld
export RANLIB=${tc_bin_prefix}ranlib # ar -s

# export FC=${tc_bin_prefix}fc  # Fortran编译器。默认是"f77"
# export PC=${tc_bin_prefix}pc  # Pascal语言编译器。默认是"pc"。
# export YACC=${tc_bin_prefix}yacc # Yacc文法分析器。默认是"yacc"。

#ARFLAGS	# 函数库打包程序的命令行参数。默认值是"rv"
#ASFLAGS	# 汇编程序的命令行参数
#FFLAGS		# Fortran编译器的命令行参数
#PFLAGS		# Pascal编译器的命令行参数
#YFLAGS		# Yacc文法分析器的命令行参数

TOOLCHAIN_INC=$NDK_ROOT/toolchains/$TOOLCHAIN_NAME/prebuilt/$NDK4OS_DIRNAME
LOCAL_CFLAGS="--sysroot=$SYSROOT -I${SYSROOT}/usr/include -Wall -Wextra" # -I${TOOLCHAIN_INC}/include
export CFLAGS="${oldCFLAGS=$CFLAGS} $LOCAL_CFLAGS" # C编译程序的命令行参数
export CPPFLAGS="${oldCPPFLAGS=$CPPFLAGS} $LOCAL_CFLAGS" # C/C++预处理器的命令行参数
export CXXFLAGS="${oldCXXFLAGS=$CXXFLAGS} -Os" # C++编译程序的命令行参数
export LDFLAGS="${oldLDFLAGS=$LDFLAGS} -L${SYSROOT}/usr/lib -L${TOOLCHAIN_INC}/lib" # 链接器的命令行参数


# autoreconf -vfi && ./configure && make && make install 
# echo 
# if [ -f "./configure" ];then
#	echo "./configure found";
# else
#	echo "Start updating generated configuration files..."
#	autoreconf -v -f -i # remake to get configure
#	echo "autoreconf done";
# fi 

# 生成 Makefile 文件 
# --host=HOST # 编译后的代码在哪个平台执行
# --build=BUILD # 代码在哪个平台上编译，我把它称作本机Native machine，一般就是平时写代码的pc
# --target=TARGET # 一般仅用于编译一个编译器，可选，默认=HOST
# 一般 --build 可以通过config.guess脚本探测，如我在64位Windows上装了32位的cygwin，然后运行它，输出i686-pc-cygwin。
# 比如：
#	1. 在Linux上使用NDK目录下arm-linux-androideabi工具链编译代码生成目标二进制在Android上运行
#	--build=x86_64-unknown-linux-gnu --host=arm-linux-androideabi
#	2. 在i686机器上，想编译一个在 Android-arm 上运行的交叉工具链 gcc ，然而这个工具链是为了在 Android 上能编译x86的程序，这样配置也许这样：
#	--build=i686-pc-linux-gnu --host=arm-linux-androideabi --target=x86-xx
# file命令看结果，里面包含的是--host信息

# System types:
#	--build=BUILD		configure for building on BUILD [guessed]
#	--host=HOST			cross-compile to build programs to run on HOST [BUILD]
#	--target=TARGET		configure for building compilers for TARGET [HOST]

# echo && echo "Start configuring the makefile..."
# This is just an empty directory where I want the built objects to be installed
# export CONFIGURE_PREFIX=.
# ./configure --host=arm-linux-androideabi --prefix=${CONFIGURE_PREFIX}

blue_echo "Suggestion: ./configure --host=$TOOLCHAIN_BIN_PREFIX_ARCH-$TOOLCHAIN_BIN_PREFIX_OS --prefix=`pwd`/$TOOLCHAIN_BIN_PREFIX_ARCH-out"
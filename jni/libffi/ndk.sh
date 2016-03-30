#!/bin/sh
#filename: ndk-cross-compile.sh

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

function parse_arg {
	# not a number
    if [[ $1 == *[!0-9]* ]]; then
        ANDROID_ARCH=$1
    else
        API_LEVEL=$1
    fi
}

# /home/android-ndk-r10c
echo -n "Checking whether the environment variable NDK_ROOT exist:"
if [ -z "${NDK_ROOT}" ];then
	echo_no_exit;
else
	echo_yes "NDK_ROOT=${NDK_ROOT}"
fi



parse_arg $1;
parse_arg $2;

# $NDK_ROOT/platforms/android-{level: 9,...}/arch-{arch: arm|x86|mips}, in which, X86 and MIPS since android-9.
ANDROID_ARCH=${ANDROID_ARCH:="arm"}
API_LEVEL=${API_LEVEL:=9}

TOOLCHAIN_VERSION=4.8 # http://developer.android.com/ndk/guides/standalone_toolchain.html#syt
NDK_OS=windows  #windows-x86_64, linux, linux-x86_64...

#arm-linux-androideabi-4.6   => build programs to run on ARM-based Android device
#x86-4.6                     => build programs to run on x86-based Android device
#mipsel-linux-android-4.6    => build programs to run on MIPS-based Android device
export CROSS_COMPILE=arm-linux-androideabi
export TOOLCHAIN_PREFIX=${CROSS_COMPILE}-

TOOLCHAIN_BIN_SUBPATH=toolchains/$CROSS_COMPILE-$TOOLCHAIN_VERSION/prebuilt/$NDK_OS/bin
API_ARCH_SUBPATH=platforms/android-$API_LEVEL/arch-$ANDROID_ARCH

#check the subpath relative to the directory specified by the environment variable NDK_ROOT
function check_subpath_exist {
    echo -n "Checking whether \$NDK_ROOT/$1 exist:"
    if [ -z "$NDK_ROOT/$1" ];then
        echo_no_exit;
    else
        echo_yes;
    fi  
}

check_subpath_exist $API_ARCH_SUBPATH;
check_subpath_exist $TOOLCHAIN_BIN_SUBPATH;
export PATH=$NDK_ROOT/$TOOLCHAIN_BIN_SUBPATH:$PATH  # resolve toolchains bin path for all os
export SYSROOT=$NDK_ROOT/$API_ARCH_SUBPATH

#note: ndk toolchains bins cannot recognize a unix-style path
function check_cygwin {
	echo -n "Check operating system: "
	OS_NAME=$(uname -s)
	if [[ $OS_NAME =~ ^CYGWIN* ]];then
		echo "OS_NAME=$OS_NAME"
		export SYSROOT=$(cygpath -p $SYSROOT -a -w)
		echo "SYSROOT=$SYSROOT"
		# ln -s (target exists) (link is made)
		# mklink (link is made) (target exists)
	fi

	# case "$(uname -s)" in
	#    Darwin)
	#      echo 'Mac OS X'
	#      ;;
	#    Linux)
	#      echo 'Linux'
	#      ;;
	#    CYGWIN*|MINGW32*|MSYS*)
	#      echo 'MS Windows'
	# 	 export SYSROOT=$(cygpath -p $SYSROOT -a -w)
	# 	 echo " SYSROOT=$SYSROOT"
	#      ;;
	#    # Add here more strings to compare
	#    # See correspondence table at the bottom of this answer
	#    *)
	#      echo 'other OS' 
	#      ;;
	# esac
}
check_cygwin;


export CC=${TOOLCHAIN_PREFIX}gcc  # C编译程序。默认是"cc"
export CXX=${TOOLCHAIN_PREFIX}g++ # C++编译程序。默认是"g++"
export CPP=${TOOLCHAIN_PREFIX}cpp # C/C++预处理器。默认是"$(CC) -E"
export AR=${TOOLCHAIN_PREFIX}ar # 函数库打包程序，可创建静态库.a文档。默认是"ar"
export AS=${TOOLCHAIN_PREFIX}as # 汇编程序。默认是"as"
export NM=${TOOLCHAIN_PREFIX}nm
export LD=${TOOLCHAIN_PREFIX}ld

# export RANLIB=${TOOLCHAIN_PREFIX}ranlib
# export FC=${TOOLCHAIN_PREFIX}fc  # Fortran编译器。默认是"f77"
# export PC=${TOOLCHAIN_PREFIX}pc  # Pascal语言编译器。默认是"pc"。
# export YACC=${TOOLCHAIN_PREFIX}yacc # Yacc文法分析器。默认是"yacc"。

#ARFLAGS     # 函数库打包程序的命令行参数。默认值是"rv"
#ASFLAGS     # 汇编程序的命令行参数
#FFLAGS      # Fortran编译器的命令行参数
#PFLAGS      # Pascal编译器的命令行参数
#YFLAGS      # Yacc文法分析器的命令行参数

export CFLAGS="--sysroot=$SYSROOT -Wall -Wextra" # C编译程序的命令行参数
export CPPFLAGS="${CPPFLAGS} --sysroot=$SYSROOT" # C/C++预处理器的命令行参数
export CXXFLAGS="${CXXFLAGS} -Os" # C++编译程序的命令行参数
export LDFLAGS="${LDFLAGS}" # 链接器的命令行参数

echo $(ls $NDK_ROOT/$TOOLCHAIN_BIN_SUBPATH/$TOOLCHAIN_PREFIX*)
echo " NDK_OS = $NDK_OS"
echo " TOOLCHAIN_PREFIX = $TOOLCHAIN_PREFIX"
echo " TOOLCHAIN_VERSION = $TOOLCHAIN_VERSION"
echo " API_LEVEL = $API_LEVEL"
echo " ANDROID_ARCH = $ANDROID_ARCH"
echo " NDK_MAKE = \$NDK_ROOT/prebuilt/$NDK_OS/bin/make.exe"

# autoreconf -vfi && ./configure && make && make install 
echo 
if [ -z "./configure" ];then
	echo "Start updating generated configuration files..."
	autoreconf -v -f -i # remake to get configure
	echo "autoreconf done";
else
	echo "./configure found";
fi 
# 生成 Makefile 文件 
# --host=HOST # 编译后的代码在哪个平台执行
# --build=BUILD # 代码在哪个平台上编译，我把它称作本机Native machine，一般就是平时写代码的pc
# --target=TARGET # 一般仅用于编译一个编译器，可选，默认=HOST
# 一般 --build 可以通过config.guess脚本探测，如我在64位Windows上装了32位的cygwin，然后运行它，输出i686-pc-cygwin。
# 比如：
#  1. 在Linux上使用NDK目录下arm-linux-androideabi工具链编译代码生成目标二进制在Android上运行
#  --build=x86_64-unknown-linux-gnu --host=arm-linux-androideabi
#  2. 在i686机器上，想编译一个在 Android-arm 上运行的交叉工具链 gcc ，然而这个工具链是为了在 Android 上能编译x86的程序，这样配置也许这样：
# --build=i686-pc-linux-gnu --host=arm-linux-androideabi --target=x86-xx
# file命令看结果，里面包含的是--host信息

# System types:
#   --build=BUILD     configure for building on BUILD [guessed]
#   --host=HOST       cross-compile to build programs to run on HOST [BUILD]
#   --target=TARGET   configure for building compilers for TARGET [HOST]

echo && echo "Start configuring the makefile..."
#./configure --host=arm-linux-androideabi

#echo "compiling the code"


# 参考资料:
# http://en.wikipedia.org/wiki/Cross_compile
# http://www.airs.com/ian/configure/configure_5.html#SEC30
# build 就是你现在使用的机器。
# host 就是你编译好的程序能够运行的平台。
# target 编译程序能够处理的平台。一般都用在构建编译本身的时候(gcc), 才用target, 也就是说平时我们所说的交叉编译用不到target.


# The GNU autotools packages (i.e. autoconf, automake, and libtool) use the notion of a build platform, a host platform, and a target platform.
# 1. The build platform is where the code is actually compiled.
# 2. The host platform is where the compiled code will execute.
# 3. The target platform usually only applies to compilers. It represents what type of object code the package itself will produce (such as cross-compiling a cross-compiler); otherwise the target platform setting is irrelevant. 
# For example, consider cross-compiling a video game that will run on a Dreamcast. The machine where the game is compiled is the build platform while the Dreamcast is the host platform.


# When building cross compilation tools, there are two different systems involved: the system on which the tools will run, and the system for which the tools generate code.
# The system on which the tools will run is called the host system.
# The system for which the tools generate code is called the target system.
# For example, suppose you have a compiler which runs on a GNU/Linux system and generates ELF programs for a MIPS embedded system. In this case the GNU/Linux system is the host, and the MIPS ELF system is the target. Such a compiler could be called a GNU/Linux cross MIPS ELF compiler, or, equivalently, a ‘i386-linux-gnu’ cross ‘mips-elf’ compiler.

# Target usually have a meaning for developemt tool only.



#比如: 在386的平台上编译可以运行在arm板的程序 ./configure –build=i386-linux,–host=arm-linux就可以了.
#因为一般我们都是编译程序而不是编译工具.
#如果我们编译工具,比如gcc,这个target就有用了.如果我们需要在一个我们的机器上为arm开发板编译一个可以处理 mips程序的gcc,那么target就是mips了.


#Example:
#    1. ./configure --build=mipsel-linux --host=mipsel-linux --target=mipsel-linux
#     # will build native mipsel-linux binutils on mipsel-linux.
#    2. ./configure --build=i386-linux --host=mipsel-linux --target=mipsel-linux
#	 # will cross-build native mipsel-linux binutils on i386-linux.
#    3. ./configure --build=i386-linux --host=i386-linux --target=mipsel-linux
#     # will build mipsel-linux cross-binutils on i386-linux.
#    4. ./configure --build=mipsel-linux --host=i386-linux --target=mipsel-linux
#     # will cross-build mipsel-linux cross-binutils for i386-linux on mipsel-linux.
#As you see, only if $build != $host a cross-compilation is performed.

# NDK Project

参考NDK例子native-activity，含有比较简单的工程结构，既能cygwin下ndk-build（无IDE），也可以作为Android工程导入（使用IDE）

1. copy android-ndk-r10/samples/native-activity and remove or replace main.c, to get a ndk project
2. code and modify Android.mk to your module, note APP_ABI armeabi-v7a x86 (Application.mk)

3. $ ndk-build NDK_PROJECT_PATH=/cygdrive/f/Android/android-ndk-r10/samples/z_ndk_workspace/messagepack
4. $ adb push 'F:\Android\android-ndk-r10\samples\z_ndk_workspace\messagepack\libs\armeabi-v7a\cmp_unpack' /data/local/tmp
5. $ adb shell chmod 6755 /data/local/tmp/cmp_unpack
6. $ adb shell a /data/local/tmp/cmp_unpack
7. OK.

$ ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk

NDK_PROJECT_PATH 指定了需要编译的代码的工程目录，这里给出的是当前目录，APP_BUILD_SCRIPT给出的是Android makefile文件的路径，当然，如果你还有 Application.mk 文件的话，则可以添加 NDK_APP_APPLICATION_MK=./Application.mk 


# a ndk-build problem
* question
```
$ ndk-build
Android NDK: Could not find application project directory !    
Android NDK: Please define the NDK_PROJECT_PATH variable to point to it.    
/opt/android-ndk-r10b/build/core/build-local.mk:148: *** Android NDK: Aborting    .  Stop.
```
* answer
```
You need to specify 3 things.
NDK_PROJECT_PATH - the location of your project
NDK_APPLICATION_MK - the path of the Application.mk file
APP_BUILD_SCRIPT - the path to the Android.mk file

These are needed to override the default values of the build script, which expects things to be in the jni folder.

When calling ndk-build use
ndk-build NDK_PROJECT_PATH=/path/to/proj NDK_APPLICATION_MK=/path/to/Application.mk

In Application.mk add
APP_BUILD_SCRIPT := /path/to/Android.mk
```

VistualGDB

#VS+VA

(参考)[http://bbs.pediy.com/showthread.php?p=1353066]

打开VS2008，新建Makefile项目

环境变量：

将NDK根目录加入%PATH%环境变量，这样直接使用命令ndk-build。

在项目向导中填写以下内容

* Build command line: ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk
* Clean commands: ndk-build clean NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk
* Rebuild command line: ndk-build -B NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk
* Include search path: E:\Android\android-ndk-r9d\platforms\android-12\arch-arm\usr\include // 对应到你本机的目录及版本。
点击完成。

#使用makefile的库

一般Android写c/c++的NDK使用Android.mk。当使用其他开源库时，大多是通过Makefile编译的，而又可能再使用其它开源库，如果再写Android.mk会很麻烦。虽然一些可以在AOSP中可以找到。这些其实和toolchain有关。故可以独立出一个toolchain，直接使用Makefile，而不需要自己去重新编写Android.mk文件，减少了很多麻烦。

从Android NDK中独立toolchain步骤（系统为Ubuntu(32位)）：

下载Android NDK
独立toolchain

把NDK压缩包解压到系统，如/mnt目录下，后在/mnt目录下建立文件夹my_ndk_toolchain，然后再/mnt目录下执行以下命令：

/mnt/android-ndk-r9c/build/tools/make-standalone-toolchain.sh --platform=android-19 --toolchain=arm-linux-androideabi-4.8 --stl=stlport --install-dir=/mnt/my_ndk_toolchain

出现以下打印：

dir=/mnt/my_ndk_toolchain  
Copying prebuilt binaries...  
Copying sysroot headers and libraries...  
Copying libstdc++ headers and libraries...  
Copying files to: /mnt/my_ndk_toolchain  
Cleaning up...  
Done.  

说明独立的工具链成功，对执行的命令进行简单说明：

* /mnt/android-ndk-r9c/build/tools/make-standalone-toolchain.sh：执行NDK目录下make-standalone-toolchain.sh脚本；
* --platform：指工具链将使用哪个版本的Android API，可cd /mnt/android-ndk-r9c/platform中查看，我这里使用的是Android-19；
* --toolchain:指独立出来的工具链哪种用途的编译，arm(arm-linux-androideabi-4.8),X86(x86-4.8)或MIPS(mipsel-linux-android-4.8)，可cd toolchains中查看并选择适合的类型，我这里使用的是嵌入式；
* --stl:指工具链支持C++ stl，stlport代表C++库将静态链接，stlport_shared将动态链接；
* --install-dir:指安装目录；

注意：因为我使用的是32-bit Ubuntu，独立工具链默认是32位，所以在参数中没有指定系统类型，如果是64-bit Linux系统，需加入--system=linux-x86_64 或MacOSX加入--system=darwin-x86_64。


3、测试程序
```c++
hello.cpp
#include <iostream>
#include <string>
int main(int argc, char **argv)
{
    std::string str = "hello, ndk! this is my own toolchain! ^-^";
    std::cout << str << std::endl;
    return 0;
}
```
Makefile
```makefile
rm=/bin/rm -f
CC=/mnt/my_ndk_toolchain/bin/arm-linux-androideabi-g++
PROGNAME = main
INCLUDES= -I.
CFLAGS  = $(INCLUDES) -g -fPIC -D_FILE_OFFSET_BITS=64 -D_LARGE_FILE
OBJS   = hello.o
LDFLAGS =
all :$(PROGNAME)
%.o: %.cpp
        $(CC) $(CFLAGS) -c -o $@ $<
$(PROGNAME) : $(OBJS)
        @echo  "Linking $(PROGNAME)......"
        ${CC} ${LDFLAGS} -o ${PROGNAME} ${OBJS}
        @echo  "Linking Success!"
clean:
        $(rm) *.o  $(PROGNAME)
```
编译后得到可执行文件:main，adb push到嵌入式Android平台后，./main运行，得到以下结果：
```shell
root@android :/data # ./main                                                
hello, ndk! this is my own toolchain! ^-^
```


#NDK编译器

1. 创建工具链

android ndk提供脚本，允许自己定制一套工具链。例如：

$NDK/build/tools/make-standalone-toolchain.sh --platform=android-5 --install-dir=/tmp/my-android-toolchain [ --arch=x86 ]

将会在/tmp/my-android-toolchain 中创建 sysroot 环境和 工具链。--arch 选项选择目标程序的指令架构，默认是为 arm。
如果不加 --install-dir 选项，则会创建 /tmp/ndk/<toolchain-name>.tar.bz2。

2. 设置环境变量

运行上面make-standalone-toolchain.sh命令创建工具链之后，再：
```shell
$ export PATH=/tmp/my-android-toolchain/bin:$PATH
$ export CC=arm-linux-androideabi-gcc
$ export CXX=arm-linux-androideabi-g++
$ export CXXFLAGS="-lstdc++"
```

3. 使用make

执行完以上设置环境变量的命令之后，就可以直接编译了（例如，执行 ./configure 然后 make 得到的就是 arm 程序了）。不用再设定 sysroot, CC 了。而且，可以使用 STL，异常，RTTI。

4. make-standalone-toolchain.sh --help 查看帮助
```shell
$ /cygdrive/f/Android/android-ndk-r10/build/tools/make-standalone-toolchain.sh --help

Usage: make-standalone-toolchain.sh [options]

Generate a customized Android toolchain installation that includes
a working sysroot. The result is something that can more easily be
used as a standalone cross-compiler, e.g. to run configure and
make scripts.

Valid options (defaults are in brackets):

  --help                   Print this help.
  --verbose                Enable verbose mode.
  --toolchain=<name>       Specify toolchain name
  --llvm-version=<ver>     Specify LLVM version
  --stl=<name>             Specify C++ STL [gnustl]
  --arch=<name>            Specify target architecture
  --abis=<list>            Specify list of target ABIs.
  --ndk-dir=<path>         Take source files from NDK at <path> [/cygdrive/f/Android/android-ndk-r10]
  --system=<name>          Specify host system [windows]
  --package-dir=<path>     Place package file in <path> [/tmp/ndk-fangss]
  --install-dir=<path>     Don't create package, install files to <path> instead.
  --platform=<name>        Specify target Android platform/API level. [android-3]
```


比如，android-ndk-r10自带的工具链，我这里在F:\Android\android-ndk-r10\toolchains目录下：
```shell
fangss@fangss-PC ~
$ ll /cygdrive/f/Android/android-ndk-r10/toolchains
total 0
d---------+ 1 fangss None 0 Dec  9  2014 arm-linux-androideabi-4.6
d---------+ 1 fangss None 0 Dec  9  2014 arm-linux-androideabi-4.8
d---------+ 1 fangss None 0 Dec  9  2014 arm-linux-androideabi-clang3.3
d---------+ 1 fangss None 0 Dec  9  2014 arm-linux-androideabi-clang3.4
d---------+ 1 fangss None 0 Dec  9  2014 llvm-3.3
d---------+ 1 fangss None 0 Dec  9  2014 llvm-3.4
d---------+ 1 fangss None 0 Dec  9  2014 mipsel-linux-android-4.6
d---------+ 1 fangss None 0 Dec  9  2014 mipsel-linux-android-4.8
d---------+ 1 fangss None 0 Dec  9  2014 mipsel-linux-android-clang3.3
d---------+ 1 fangss None 0 Dec  9  2014 mipsel-linux-android-clang3.4
d---------+ 1 fangss None 0 Dec  9  2014 renderscript
d---------+ 1 fangss None 0 Dec  9  2014 x86-4.6
d---------+ 1 fangss None 0 Dec  9  2014 x86-4.8
d---------+ 1 fangss None 0 Dec  9  2014 x86-clang3.3
d---------+ 1 fangss None 0 Dec  9  2014 x86-clang3.4
```
[OUTPUT TRUNCATED]

现在我们自己创建，在Cygwin下执行make-standalone-toolchain.sh，如果出现如下权限问题，可以右键管理员身份运行Cygwin。
```shell
fangss@fangss-PC ~
$ /cygdrive/f/Android/android-ndk-r10/build/tools/make-standalone-toolchain.sh --platform=android-9  --install-dir=/cygdrive/f/Android/android-ndk-r10/toolchains/my-arm-linux-androideabi
Auto-config: --toolchain=arm-linux-androideabi-4.6
Copying prebuilt binaries...
find: '/tmp/ndk-fangss/tmp/build-8324/standalone/arm-linux-androideabi-4.6/arm-linux-androideabi': Permission denied
find: '/tmp/ndk-fangss/tmp/build-8324/standalone/arm-linux-androideabi-4.6/bin': Permission denied
find: '/tmp/ndk-fangss/tmp/build-8324/standalone/arm-linux-androideabi-4.6/lib': Permission denied
find: '/tmp/ndk-fangss/tmp/build-8324/standalone/arm-linux-androideabi-4.6/libexec': Permission denied
find: '/tmp/ndk-fangss/tmp/build-8324/standalone/arm-linux-androideabi-4.6/share': Permission denied
mkdir: cannot create directory '/tmp/ndk-fangss/tmp/build-8324/standalone/arm-linux-androideabi-4.6/lib': Permission denied
ERROR: Cannot copy to directory: /tmp/ndk-fangss/tmp/build-8324/standalone/arm-linux-androideabi-4.6/lib/python2.7
```
正确的输出，结果可能my-arm-linux-androideabi文件夹很大
```shell
$ /cygdrive/f/Android/android-ndk-r10/build/tools/make-standalone-toolchain.sh --platform=android-9  --install-dir=/cygdrive/f/Android/android-ndk-r10/toolchains/my-arm-linux-androideabi
Auto-config: --toolchain=arm-linux-androideabi-4.6
Copying prebuilt binaries...
Copying sysroot headers and libraries...
Copying c++ runtime headers and libraries...
Copying files to: /cygdrive/f/Android/android-ndk-r10/toolchains/
Cleaning up...
Done.
```
其中，生成的一些文件：

* add2line：将你要找的地址转成文件和行号，它要使用 debug 信息。
* ar      ：产生、修改和解开一个存档文件
* as      ：gnu的汇编器
* c++filt ：C++ 和 java 中有一种重载函数，所用的重载函数最后会被编译转化成汇编的标，c++filt 就是实现这种反向的转化，根据标号得到函数名。
* gprof   ：gnu 汇编器预编译器。
* ld      ：gnu 的连接器
* nm      ：列出目标文件的符号和对应的地址
* objcopy ：将某种格式的目标文件转化成另外格式的目标文件
* objdump ：显示目标文件的信息
* ranlib  ：为一个存档文件产生一个索引，并将这个索引存入存档文件中
* readelf ：显示 elf 格式的目标文件的信息
* size    ：显示目标文件各个节的大小和目标文件的大小
* strings ：打印出目标文件中可以打印的字符串，有个默认的长度，为4
* strip   ：剥掉目标文件的所有的符号信息


之后就可以使用了，还可配置如下环境

```shell
export PATH=/cygdrive/f/Android/android-ndk-r10/toolchains/my-arm-linux-androideabi/bin:$PATH
export CC=arm-linux-androideabi-gcc
export RANLIB=arm-linux-androideabi-ranlib
export AR=arm-linux-androideabi-ar
export LD=arm-linux-androideabi-ld
```

再就是可以编译第三方库，如libpcap
cd libpcap-1.7.4
./configure --host=arm-linux --with-pcap=~/tcpdump/libpcap-1.7.4 ac_cv_linux_vers=2
make


# Windows支持

Windows上的NDK工具链不依赖 Cygwin，但是这些工具不能理解Cygwin的路径名（例如，/cygdrive/c/foo/bar）。只能理解C:/cygdrive/c/foo/bar这类路径。不过，NDK 提供的build工具能够很好地应对上述问题（ndk-build）。

5.2 wchar_t 支持  
wchar_t  类型仅从 Android 2.3 开始支持。在 android-9 上， wchar_t 是 4字节。 并且 C语言库提供支持宽字符的函数（例外：multi-byte 编码/解码 函数 和 wsprintf/wsscanf ）在android-9 以前的平台上，wchar_t 是1字节，而且宽字符函数不起作用。建议不使用 wchar_t，提供 wchar_t 支持是为了方便移植以前的代码。

5.3 异常， RTTI 和 STL  
NDK 工具链默认支持C++异常和RTTI（Run Time Type Information），可以用 -fno-exception 和 -fno-rtti 关闭（生成的机器码更小）
注意： 如果要用这两个特性，需要显式链接 libsupc++。例如： arm-linux-androideabi-g++ .... -lsupc++ 
NDK 提供了 libstdc++，因而可以用 STL，但需要显式链接 libstdc++ ( gcc ... -lstdc++)。不过在将来可以不用手动指定这个链接参数。

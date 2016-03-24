#Application.mk目的是描述在你的应用程序中所需要的模块(即静态库或动态库)。
#Application.mk文件通常被放置在 $PROJECT/jni/Application.mk下，$PROJECT指的是您的项目。

#APP_BUILD_SCRIPT := Android.mk
APP_PLATFORM := android-10
APP_ABI = armeabi armeabi-v7a x86  # APP_ABI := all

LOCAL_CPP_FEATURES := # empty exceptions

## By APP_STL, the NDK toolchain will correctly tell the linker what lib to use, no need LOCAL_LDLIBS in Android.mk.
APP_STL := c++_static # libc++ : c++_static or c++_shared
 # APP_STL := stlport_static # stlport_static is poor to support c++11, such as std::tuple
 # APP_STL := gnustl_static
 # APP_GNUSTL_FORCE_CPP_FEATURES := # empty (enum{ exceptions rtti })

# Enable c++11 extentions in source code for all
# http://stackoverflow.com/questions/15616254/enable-c11-support-on-android
# http://stackoverflow.com/questions/17142759/latest-c11-features-with-android-ndk/19874831#19874831
# https://vilimpoc.org/blog/2013/10/05/c11-support-on-android-with-g-4-8/
# APP_CPPFLAGS += -std=c++11
# APP_CPPFLAGS := -std=gnu++11

# APP_PROJECT_PATH这个变量是强制性的，并且会给出应用程序工程的根目录的一个绝对路径。
# 这是用来复制或者安装一个没有任何版本限制的JNI库，从而给APK生成工具一个详细的路径。

#APP_PIE := false

# APP_PLATFORM 警告的意思就是说,使用的Native API Version比最低版本Java API要高,可能导致的问题就是:
# 在Native Code里使用了一个platforms/android-14下的API函数,然后程序在 android-8 的设
# 备上运行,当然这个函数在android-8设备上是不存在的,就会崩溃了

#APP_ABI：编译架构，so文件都会打在apk中，而且会依据系统CPU架构进行安装。如下两种方法：
#方法1、创建Application.mk文件，则在该文件添加，APP_ABI := armeabi armeabi-v7a x86
#方法2、在ndk-build 参数中添加，APP_ABI="armeabi armeabi-v7a x86"
#比如：
#    为了在ARMv7的设备上支持硬件FPU指令。可以使用  APP_ABI := armeabi-v7a 
#    或者为了支持IA-32指令集，可以使用      APP_ABI := x86 
#    或者为了同时支持这三种，可以使用       APP_ABI := armeabi armeabi-v7a x86
# APP_ABI := all

#APP_CFLAGS：一个C编译器开关集合，在编译任意模块的任意C或C++源代码时传递。
#它可以用于改变一个给定的应用程序需要依赖的模块的构建，而不是修改它自身的Android.mk文件


# APP_STL
# To select the runtime you want to use, define APP_STL inside your Application.mk to one of the following values:
#
#    system          -> Use the default minimal system C++ runtime library.
#    gabi++_static   -> Use the GAbi++ runtime as a static library.
#    gabi++_shared   -> Use the GAbi++ runtime as a shared library.
#    stlport_static  -> Use the STLport runtime as a static library.
#    stlport_shared  -> Use the STLport runtime as a shared library.
#    gnustl_static   -> Use the GNU STL as a static library.
#    gnustl_shared   -> Use the GNU STL as a shared library.
#    c++_static      -> Use the LLVM libc++ as a static library.
#    c++_shared      -> Use the LLVM libc++ as a shared library.
#The 'system' runtime is the default if there is no APP_STL definition in your Application.mk. As an example, to use the static GNU STL, add a line like:
#
#    APP_STL := gnustl_static
#To your Application.mk. You can only select a single C++ runtime that all your code will depend on. It is not possible to mix shared libraries compiled against different C++ runtimes.
#
#IMPORTANT: Defining APP_STL in Android.mk has no effect!
#
#If you are not using the NDK build system, you can still use on of STLport, libc++ or GNU STL via "make-standalone-toolchain.sh --stl=". see STANDALONE-TOOLCHAIN for more details.
#
#The capabilities of the various runtimes vary. See this table:
#
#                C++       C++   Standard
#              Exceptions  RTTI    Library
#
#    system        no       no        no
#    gabi++       yes      yes        no
#    stlport      yes      yes       yes
#    gnustl       yes      yes       yes
#    libc++       yes      yes       yes

#APP_OPTIM：这个变量是可选的，用来定义“release”或"debug"。在编译您的应用程序模块的时候，可以用来改变优先级。
#     "release"模式是默认的，并且会生成高度优化的二进制代码。
#     "debug"模式生成的是未优化的二进制代码，但可以检测出很多的BUG，可以用于调试。
# 注意：如果你的应用程序是可调试的（即，如果你的清单文件在它的<application>标签中把android:debuggable属性设为true），
#          默认将是debug而非release。把APP_OPTIM设置为release可以覆写它。
# 注意：可以调试release和debug版二进制，但release版构建倾向于在调试会话中提供较少信息：一些变量被优化并且不能被检测，
#          代码重新排序可能致使代码步进变得困难，堆栈跟踪可能不可靠，等等。

#APP_OPTIM := release


#######################################################
# Latest C++11 features with Android NDK
#######################################################
# (I'm addressing the NDK version r9b) To enable C++11 support for all source code of the 
# application (and so any modules included) make the following change in the Application.mk:
# 
# # use this to select gcc instead of clang
# NDK_TOOLCHAIN_VERSION := 4.8
# # NDK revision 10 has the Clang 3.6 toolchain. Use it:
# NDK_TOOLCHAIN_VERSION := clang3.6
# # OR use this to select the latest clang version:
# NDK_TOOLCHAIN_VERSION := clang
# 
# 
# # then enable c++11 extentions in source code
# APP_CPPFLAGS += -std=c++11
# # or use APP_CPPFLAGS := -std=gnu++11
# Otherwise, if you wish to have C++11 support only in your module, add this lines into your
# Android.mk instead of use APP_CPPFLAGS
# 
# LOCAL_CPPFLAGS += -std=c++11
#
# Read more here: http://adec.altervista.org/blog/ndk_c11_support/
# 
# See http://stackoverflow.com/questions/25970252/build-android-with-clang-instead-of-gcc-and-the-clang-stl-lib-instead-of-gnust
# See http://libcxx.llvm.org/, which says libc++ is a new implementation of the C++ standard 
# library, targeting C++11.

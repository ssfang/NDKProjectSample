
## From

Android.mk, Libffi.mk, ... are from [github:platform_external_libffi](https://github.com/android/platform_external_libffi )or [googlesource:libffi](https://android.googlesource.com/platform/external/libffi.git)

Others are from [googlesource:libffi](https://github.com/atgreen/libffi)



基本上每一个`Android.mk`都会有一条`LOCAL_PATH := $(call my-dir)`语句。一般它返回的是相对根工程的相对路径。
```
RootProject
   |
   +jni   
RootProject
  +----jni
  |     |
  |     |____Makefile
  |     |____DBC.cpp
  |     |____Lock.cpp
  |     |____Trace.cpp
  |
  |___StdCUtil
        |___split.h	   
```


$(LOCAL_PATH)

all-makefiles-under = $(wildcard $1/*/Android.mk)

#
# Check the definition of LOCAL_MODULE_FILENAME. If none exists,
# infer it from the LOCAL_MODULE name.
#
# $1: default file prefix
# $2: default file suffix
#
define ev-handle-module-filename
LOCAL_MODULE_FILENAME := $$(strip $$(LOCAL_MODULE_FILENAME))
ifndef LOCAL_MODULE_FILENAME
    LOCAL_MODULE_FILENAME := $1$$(LOCAL_MODULE)
endif
$$(eval $$(call ev-check-module-filename))
LOCAL_MODULE_FILENAME := $$(LOCAL_MODULE_FILENAME)$2
endef

define pathjoin
$(if $(LOCAL_PATH), $(LOCAL_PATH)/)

http://stackoverflow.com/questions/8941143/configure-failing-with-android-ndk-standalone-toolchain
http://stackoverflow.com/questions/22545029/makefile-how-to-correctly-include-header-file-and-its-directory
http://stackoverflow.com/questions/17352005/how-to-incorporate-existing-make-file-with-android-ndk
http://stackoverflow.com/questions/10040693/how-to-rewrite-the-makefile-into-android-mk
http://stackoverflow.com/questions/179213/c-include-semantics
https://www.gnu.org/software/autoconf/manual/autoconf-2.69/html_node/Hosts-and-Cross_002dCompilation.html

http://danielpocock.com/building-existing-autotools-c-projects-on-android

./configure --host arm-toshiba-linux-androideabi --build x86_64-linux-gnu \
            --prefix=/data/local/ host_alias=arm-linux-androideabi \
           "CFLAGS=--sysroot=$NDK_ROOT/platforms/android-9/arch-arm  -Wall -Wextra" \
           "CPPFLAGS=--sysroot=$NDK_ROOT/platforms/android-9/arch-arm" \
            CPP=arm-linux-androideabi-cpp

			
export CROSS_COMPILE=arm-linux-androideabi

export CC=${CROSS_COMPILE}-gcc
export CXX=${CROSS_COMPILE}-g++


export TARGET_API_LEVEL=8
export TARGET_ARCH=arm

# export TOOLCHAINS_BIN_PATH
# export NDK_ROOT=/home/username/android-ndk-r10
export TOOLCHAINS_VERSION=4.8
export WORK_HOST=windows
# export WORK_HOST=windows-x86_64

export SYSROOT=$NDK_ROOT/platforms/android-$TARGET_API_LEVEL/arch-$TARGET_ARCH
PATH=$PATH:$NDK_ROOT/toolchains/$CROSS_COMPILE-$TOOLCHAINS_VERSION/prebuilt/$WORK_HOST/bin

./configure --build=x86_64-unknown-linux-gnu --host=arm-linux-androideabi --target=arm-linux-androideabi


./configure --host arm-unknown-linux-androideabi --build x86-windows-gnu \
            --prefix=/tmp/ host_alias=arm-linux-androideabi \
           "CFLAGS=--sysroot=$SYSROOT -Wall -Wextra" \
           "CPPFLAGS=--sysroot=$SYSROOT" \
            CPP=${CROSS_COMPILE}-cpp
			
./configure --prefix=/home/not/exist/output/directory --sysconfdir=/tmp 
		
$ /setup-x86.exe -h

Command Line Options:

 -D --download                     Download from internet
 -L --local-install                Install from local directory
 -s --site                         Download site
 -O --only-site                    Ignore all sites except for -s
 -R --root                         Root installation directory
 -x --remove-packages              Specify packages to uninstall
 -c --remove-categories            Specify categories to uninstall
 -P --packages                     Specify packages to install
 -C --categories                   Specify entire categories to install
 -p --proxy                        HTTP/FTP proxy (host:port)
 -a --arch                         architecture to install (x86_64 or x86)
 -q --quiet-mode                   Unattended setup mode
 -M --package-manager              Semi-attended chooser-only mode
 -B --no-admin                     Do not check for and enforce running as
                                   Administrator
 -W --wait                         When elevating, wait for elevated child
                                   process
 -h --help                         print help
 -i --ini-basename                 Use a different basename, e.g. "foo",
                                   instead of "setup"
 -v --verbose                      Verbose output
 -l --local-package-dir            Local package directory
 -r --no-replaceonreboot           Disable replacing in-use files on next
                                   reboot.
 -X --no-verify                    Don't verify setup.ini signatures
 -I --include-source               Automatically include source download
 -n --no-shortcuts                 Disable creation of desktop and start menu
                                   shortcuts
 -N --no-startmenu                 Disable creation of start menu shortcut
 -d --no-desktop                   Disable creation of desktop shortcut
 -K --pubkey                       URL of extra public key file (gpg format)
 -S --sexpr-pubkey                 Extra public key in s-expr format
 -u --untrusted-keys               Use untrusted keys from last-extrakeys
 -U --keep-untrusted-keys          Use untrusted keys and retain all
 -g --upgrade-also                 also upgrade installed packages
 -o --delete-orphans               remove orphaned packages
 -Y --prune-install                prune the installation to only the requested
                                   packages
 -m --mirror-mode                  Skip availability check when installing from
                                   local directory (requires local directory to
                                   be clean mirror!)
 -A --disable-buggy-antivirus      Disable known or suspected buggy anti virus
                                   software packages during execution.


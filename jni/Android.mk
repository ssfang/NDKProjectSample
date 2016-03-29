# 这是一个顶级Android.mk书写举例

LOCAL_PATH := $(call my-dir)

# PRINT_TEST := 0
# PRINT_PATH := 0

$(info [^-^] TOOLCHAIN_VERSION = "$(TOOLCHAIN_VERSION)")
 
#http://stackoverflow.com/questions/18136918/how-to-get-current-directory-of-your-makefile
#Code below will work for any for Makefiles invoked from any directory:

# https://www.gnu.org/software/make/manual/html_node/Text-Functions.html
# http://wiki.ubuntu.org.cn/index.php?title=%E8%B7%9F%E6%88%91%E4%B8%80%E8%B5%B7%E5%86%99Makefile:%E4%BD%BF%E7%94%A8%E5%87%BD%E6%95%B0&variant=zh-hans
# $(notdir <names...>)取文件函数 从文件名序列<names>中取出非目录部分。非目录部分是指最后一个反斜杠（“/”）之后的部分。
# $(patsubst <pattern>,<replacement>,<text>)模式字符串替换函数  
# $(strip <string>)去空格函数 去掉<string>;字串中开头和结尾的空字符。

#对于表示路径的名字，以PATH后缀不带（反）斜杠，DIR则带（反）斜杠

mkfile_path := $(strip $(abspath $(lastword $(MAKEFILE_LIST)))) #取出当前makefile的路径，并且是绝对路径
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path)))) #patsubst一句表示去尾部斜杠，%是任意长度通配符

TOP_ABS_DIR :=$(dir $(mkfile_path))
TOP_ABS_PATH :=$(patsubst %/,%,$(TOP_ABS_DIR)) #在下面打印中结尾会出现空格，不明

ifeq ($(PRINT_PATH), 1)
 #print a info about the current dir, maybe a relative path, such as "jni"
 $(info [^-^] LOCAL_PATH = "$(LOCAL_PATH)")
 $(info [^-^] mkfile_path = "$(mkfile_path)") #上面不知为何结尾带空格，strip不掉
 $(info [^-^] current_absolute_direcory_with_last_slash = "$(TOP_ABS_DIR)") # OK
 $(info [^-^] current_absolute_direcory_without_last_slash = "$(TOP_ABS_PATH)") #尾空格
endif

ifdef USE_UNDISTRIBUTED
  UNDISTRIBUTED_C_INCLUDES := $(LOCAL_PATH)/undistributed/include
  UNDISTRIBUTED_LDLIBS := $(TOP_ABS_DIR)undistributed/lib/$(TARGET_ARCH)
  $(info [^-^] UNDISTRIBUTED_LDLIBS = $(UNDISTRIBUTED_LDLIBS))
endif

#################################################################
# xxModule                                                      
#################################################################

#include $(CLEAR_VARS)
#LOCAL_MODULE    := xx
#LOCAL_SRC_FILES := yy.c zz.c
#LOCAL_LDLIBS    := -llog -landroid
#include $(BUILD_EXECUTABLE)


#################################################################
# Include other Android.mk files                                
#################################################################

# Include makefiles here. Its important that these includes are 
# done after the main module, explanation below.

#注意，如果其他mk文件也使用LOCAL_PATH，是共享的
# create a temp variable with the current path, because it changes
# after each include 
# @see http://developer.android.com/ndk/guides/android_mk.html#npfm
TOP_LOCAL_PATH := $(LOCAL_PATH)

# @see https://www.gnu.org/software/make/manual/html_node/Include.html
include $(TOP_LOCAL_PATH)/HelloWorld/Android.mk
#include $(TOP_LOCAL_PATH)/MessagePack/Android.mk
#include $(TOP_LOCAL_PATH)/toy/Android.mk

## I want only second-level mk files, that is the direct sub-directories
## in the current path.
# include $(wildcard */*/Android.mk)
# include $(call all-subdir-makefiles)  ## $(wildcard $(call my-dir)/*/Android.mk)
# include $(call all-makefiles-under,$(LOCAL_PATH))

LOCAL_PATH = $(TOP_LOCAL_PATH) ## restore it


#################################################################
# print test (first, "cd project_path", then, "ndk-build")      
#################################################################

# I dunno why it's an empty result for $(call all-subdir-makefiles).
ifdef PRINT_TEST
  # $(info [print-test] all-subdir-makefiles = "$(call all-subdir-makefiles) ")
  $(info [print-test] "$(wildcard $(TOP_ABS_DIR)*/Android.mk)") # print: xx/project_path/jni/xxdir/Android.mk
  $(info [print-test] assert "jni/Android.mk" = "$(wildcard */Android.mk)") # print: jni/Android.mk
  $(info [print-test] $$(wildcard */*/Android.mk) = "$(wildcard */*/Android.mk)") # print: jni/xxdir/Android.mk
endif

#ifeq ($(TARGET_ARCH), arm)
#    LOCAL_CFLAGS += -DPACKED="__attribute__ ((packed))"
#else
#    LOCAL_CFLAGS += -DPACKED=""
#endif

## can we use shell ls?
# LOCAL_C_INCLUDES := F:\Android\android-ndk-r10\sources\cxx-stl\stlport
# LOCAL_C_INCLUDES += $(shell ls -FR $(LOCAL_C_INCLUDES) | grep $(LOCAL_PATH)/$ )
# LOCAL_C_INCLUDES := $(LOCAL_C_INCLUDES:$(LOCAL_PATH)/%:=$(LOCAL_PATH)/%)

# 
# 查看二进制的库依赖
# arm-linux-readelf -d libc.so 打印Dynamic section，其中带有[NEEDED] Shared library行

# 查看符号
# readelf -s libcutils.so 打印Symbol table '.dynsym'等
# nm -D libcutils.so
# objdump -tT libcutils.so 打印SYMBOL TABLE和DYNAMIC SYMBOL TABLE

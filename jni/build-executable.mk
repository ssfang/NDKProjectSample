# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# this file is included from Android.mk files to build a target-specific
# executable program
#

LOCAL_BUILD_SCRIPT := BUILD_EXECUTABLE
LOCAL_MAKEFILE     := $(local-makefile)

$(call check-defined-LOCAL_MODULE,$(LOCAL_BUILD_SCRIPT))
$(call check-LOCAL_MODULE,$(LOCAL_MAKEFILE))
$(call check-LOCAL_MODULE_FILENAME)

# we are building target objects
my := TARGET_

$(call handle-module-filename,,)
$(call handle-module-built)

## =======================Substitute $(BUILD_EXECUTABLE)=====================
## @see 
##   http://jeyechao.iteye.com/blog/2164286
##   https://groups.google.com/forum/?hl=en#!searchin/android-ndk/excutable$20in$20libs%7Csort:relevance/android-ndk/V7CC_b0-JUQ/Fz8HgdNNDLoJ
##   https://groups.google.com/forum/?hl=en#!searchin/android-ndk/excutable$20in$20libs%7Csort:relevance/android-ndk/JrA4sKHJpNU/6uclie7sYiUJ
##   Java中System.loadLibrary() 的执行过程http://my.oschina.net/wolfcs/blog/129696
## @desc
##     NDK是通过在Android.mk文件中include $(BUILD_EXECUTABLE)来编译可执行
## 文件，其实就是调用了一个已经写好的脚本——build-executable.mk。但不会打包
## 进apk。（编译脚本都在NDK_ROOT/build/core目录里面）。
## @usage 
##    1、本文件放在jni根目录。
##    2、根目录下的Android.mk代码：
##       1) 【引用头】为了包含我们自定义的mk文件，就像c语言引用第三方库一样定义头：
##       	    MY_BUILD_EXECUTABLE := $(JNI_ROOT)/build-executable.mk
##            include $(call all-subdir-makefiles) lib<name>.so
##       2) 【编译模块】需要编译可执行文件xxx的模块这样写（<name>按要求替换）：
##          *  正常的include $(BUILD_EXECUTABLE) 要改为 include $(MY_BUILD_EXECUTABLE) 
##          ~ LOCAL_MODULE := <name>
##          + 添加：MY_LOCAL_MODULE_FILENAME := lib<name>.so
##          e.g
##              LOCAL_PATH := $(call my-dir)
##              include $(CLEAR_VARS)
##
##              LOCAL_SRC_FILES := ...
##              LOCAL_MODULE := xxx
##              MY_LOCAL_MODULE_FILENAME := libxxx.so
##              LOCAL_C_INCLUDES := ...
##              LOCAL_LDLIBS:=-L$(SYSROOT)/usr/lib -llog
##              LOCAL_CFLAGS := -fPIC
##
##              include $(MY_BUILD_EXECUTABLE)
## ==========下面一行为NDK里build-executable.m拷贝来后添加行=============
$(eval LOCAL_BUILT_MODULE := $(TARGET_OUT)/$(MY_LOCAL_MODULE_FILENAME))  

LOCAL_MODULE_CLASS := EXECUTABLE
include $(BUILD_SYSTEM)/build-module.mk

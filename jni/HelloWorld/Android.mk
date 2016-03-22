
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE    := helloworld
LOCAL_SRC_FILES := helloworld.cpp

# FLAGS += -fvisibility=default -fPIE
# LDFLAGS += -rdynamic -fPIE -pie

LOCAL_CPPFLAGS += -std=c++11

include $(BUILD_EXECUTABLE)



LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE    := cmp_unpack
LOCAL_SRC_FILES := cmp_unpacker.c cmp.c
include $(BUILD_EXECUTABLE)
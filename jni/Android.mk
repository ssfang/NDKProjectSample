# Copyright (C) 2010 The Android Open Source Project

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE    := cmp_unpack
LOCAL_SRC_FILES := cmp_unpacker.c cmp.c
#LOCAL_LDLIBS    := -llog -landroid
include $(BUILD_EXECUTABLE)


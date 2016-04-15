LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
# Single test file to use when doing a default build.
FFI_SINGLE_TEST_FILE := libffi.call/struct5.c
# We only build ffi at all for non-arm, non-x86 targets.
include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(FFI_SINGLE_TEST_FILE)
LOCAL_C_INCLUDES := $(addprefix $(FFI_DIR), include $(FFI_INC_DIRNAME) $(FFI_INC_DIRNAME)/include)
LOCAL_SHARED_LIBRARIES := libffi
LOCAL_MODULE := ffi-test
LOCAL_MODULE_TAGS := tests
include $(BUILD_EXECUTABLE)

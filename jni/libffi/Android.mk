
LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

## $NDK_ROOT/build/core/init.mk NDK_KNOWN_DEVICE_ABIS
# the list of known abis and archs
# NDK_KNOWN_DEVICE_ABI64S := arm64-v8a x86_64 mips64
# NDK_KNOWN_DEVICE_ABI32S := armeabi-v7a armeabi x86 mips
ffi_arch:=$(TARGET_ARCH_ABI)
ffi_arch := $(TARGET_ARCH)

ffi_os := $(if $(TARGET_OS),$(TARGET_OS),linux)


# LOCAL_C_INCLUDES := $(if $(LOCAL_PATH), $(LOCAL_PATH)/)$(ffi_os)-$(ffi_arch)
FFI_DIR:=$(if $(LOCAL_PATH), $(LOCAL_PATH)/)

ifeq ($(ffi_arch),mips)
 FFI_INC_DIRNAME:=mipsel-unknown-linux-android
 LOCAL_SRC_FILES += src/mips/ffi.c src/mips/o32.S
else ifeq ($(ffi_arch),x86)
 FFI_INC_DIRNAME:=i686-pc-linux-android
 LOCAL_SRC_FILES := src/x86/ffi.c src/x86/sysv.S
else ifeq ($(ffi_arch),x86_64)
 FFI_INC_DIRNAME:=i686-pc-linux-android
 LOCAL_SRC_FILES := src/x86/ffi64.c src/x86/unix64.S
else ifneq ($(findstring arm,$(ffi_arch)),)
 FFI_INC_DIRNAME:=arm-unknown-linux-androideabi
 LOCAL_SRC_FILES := src/arm/sysv.S src/arm/ffi.c
else
 $(error The os/architecture linux-$(ffi_arch) is not supported by libffi.)
 LOCAL_SRC_FILES := your-architecture-not-supported-by-ffi-makefile.c
endif

LOCAL_SRC_FILES += src/closures.c # src/dlmalloc.c
LOCAL_SRC_FILES += \
	src/debug.c \
	src/java_raw_api.c \
	src/prep_cif.c \
	src/raw_api.c \
	src/types.c

LOCAL_C_INCLUDES := $(addprefix $(FFI_DIR), include $(FFI_INC_DIRNAME) $(FFI_INC_DIRNAME)/include)

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := ffi

include $(BUILD_SHARED_LIBRARY)


## Also include the rules for the test suite.
include $(LOCAL_PATH)/testsuite/Android.mk
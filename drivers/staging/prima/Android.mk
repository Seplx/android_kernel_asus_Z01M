# Android makefile for the WLAN Module

WLAN_CHIPSET := pronto
WLAN_SELECT := CONFIG_PRONTO_WLAN=m

LOCAL_PATH := $(call my-dir)

# This makefile is only for DLKM
ifneq ($(findstring vendor,$(LOCAL_PATH)),)

WLAN_BLD_DIR := vendor/qcom/opensource/wlan

DLKM_DIR := $(TOP)/device/asus/Z01M/dlkm

ifeq ($(TARGET_KERNEL_VERSION),)
$(info "WLAN: TARGET_KERNEL_VERSION is not defined, assuming default")
TARGET_KERNEL_SOURCE := kernel
KERNEL_TO_BUILD_ROOT_OFFSET := ../
endif

ifeq ($(KERNEL_TO_BUILD_ROOT_OFFSET),)
$(info "WLAN: KERNEL_TO_BUILD_ROOT_OFFSET is not defined, assuming default")
KERNEL_TO_BUILD_ROOT_OFFSET := ../
endif

# Build wlan.ko as either prima_wlan.ko or pronto_wlan.ko
###########################################################

# This is set once per LOCAL_PATH, not per (kernel) module
KBUILD_OPTIONS := WLAN_ROOT=$(KERNEL_TO_BUILD_ROOT_OFFSET)$(WLAN_BLD_DIR)/prima
# We are actually building wlan.ko here, as per the
# requirement we are specifying <chipset>_wlan.ko as LOCAL_MODULE.
# This means we need to rename the module to <chipset>_wlan.ko
# after wlan.ko is built.
KBUILD_OPTIONS += MODNAME=wlan
KBUILD_OPTIONS += BOARD_PLATFORM=$(TARGET_BOARD_PLATFORM)
KBUILD_OPTIONS += $(WLAN_SELECT)


VERSION=$(shell grep -w "VERSION =" $(TOP)/kernel/Makefile | sed 's/^VERSION = //' )
PATCHLEVEL=$(shell grep -w "PATCHLEVEL =" $(TOP)/kernel/Makefile | sed 's/^PATCHLEVEL = //' )

include $(CLEAR_VARS)
LOCAL_MODULE              := $(WLAN_CHIPSET)_wlan.ko
LOCAL_MODULE_KBUILD_NAME  := wlan.ko
LOCAL_MODULE_TAGS         := debug
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(TARGET_OUT)/lib/modules/$(WLAN_CHIPSET)
include $(DLKM_DIR)/AndroidKernelModule.mk
###########################################################

#Create symbolic link
$(shell mkdir -p $(TARGET_OUT)/lib/modules; \
        ln -sf /system/lib/modules/$(WLAN_CHIPSET)/$(WLAN_CHIPSET)_wlan.ko \
               $(TARGET_OUT)/lib/modules/wlan.ko)

endif # DLKM check

endif # supported target check

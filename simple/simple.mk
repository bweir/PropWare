# #########################################################
# This makefile fragment builds CMM/LMM/XMM/XMMC demo programs
#
# To use it, define:
#  PROPWARE_PATH to be the path to this directory
#  NAME to be the name of project
#       - this is used to create the final program $(NAME).elf
#  OBJS to be the object files needed for the project
#  MODEL to cmm, lmm, xmm, or xmmc
#  CFLAGS to be desired CFLAGS
#
#  Then set up a default "all" target (normally this will be
#    all: $(NAME).elf
#  and finally
#    include $(PROPLIB)/demo.mk
#
# Copyright (c) 2011 Parallax Inc.
# All rights MIT licensed
# #########################################################

# *********************************************************
# Modification by David Zemon...
#
# !!! NOTE !!!
# All C source files must have an accompanying header file
# in the same directory as the source.
# Without this mod, changes in header files would be ignored
# until the source file was modified (and therefore rebuilt)
#
# *********************************************************

# #########################################################
# Variable Definitions
# #########################################################
# where we installed the propeller binaries and libraries

# Depending on OS type, set the file deletion commands appropriately
ifeq ($(OS), Windows_NT)
	CLEAN=del /f
# When the Windows command del tries to delete a file that does not exist, an
# error is thrown. Though this does not cause any problems for Make, it does
# clutter up the terminal significantly. These "errors" can be safely ignored
# and thrown into nul
	NULL=2> nul
else
	CLEAN=rm -f
endif

# Find PropGCC
ifndef PROPGCC_PREFIX
	PROPGCC_PREFIX = /opt/parallax
endif

# libgcc directory
LIBGCC = $(PROPGCC_PREFIX)/lib/gcc/propeller-elf/4.6.1

CFLAGS_NO_MODEL := -Wextra $(CFLAGS)
CFLAGS += -m$(MODEL) -Wall -m32bit-doubles -std=c99
CXXFLAGS += $(CFLAGS) -Wall
ASFLAGS += -m$(MODEL) -xassembler-with-cpp
INC += -I'$(PROPWARE_PATH)' -I'$(PROPGCC_PREFIX)/propeller-elf/include'

# Add the propeller library to the search path
ifeq ($(MODEL), cmm)
	LIB_INC += -L'$(PROPGCC_PREFIX)/propeller-elf/lib/cmm'
else
	LIB_INC += -L'$(PROPGCC_PREFIX)/propeller-elf/lib'
endif

# basic gnu tools
GCC_PATH = $(PROPGCC_PREFIX)/bin
CC = $(GCC_PATH)/propeller-elf-gcc
CXX = $(GCC_PATH)/propeller-elf-g++
LD = $(GCC_PATH)/propeller-elf-ld
AS = $(GCC_PATH)/propeller-elf-as
AR = $(GCC_PATH)/propeller-elf-ar
OBJCOPY = $(GCC_PATH)/propeller-elf-objcopy
LOADER = $(GCC_PATH)/propeller-load

# BSTC program
BSTC=$(GCC_PATH)/bstc
SPINDIR=.

# #########################################################
# Build Commands
# #########################################################
ifneq ($(LIBNAME),)
lib$(LIBNAME).a: $(OBJS)
	$(AR) rs $@ $(OBJS)
endif

%.o: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: PropGCC Compiler'
	$(CC) $(INC) $(CFLAGS) -o $@ -c $<
	@echo 'Finished building: $<'
	@echo ' '

%.o: ../%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: PropG++ Compiler'
	$(CC) $(INC) $(CXXFLAGS) -o $@ -c $<
	@echo 'Finished building: $<'
	@echo ' '

%.o: ../%.s
	@echo 'Building file: $<'
	@echo 'Invoking: PropGCC Assembler'
	$(CC) $(INC) $(ASFLAGS) -o $@ -c $<
	@echo 'Finished building: $<'
	@echo ' '

%.o: ../%.S
	@echo 'Building file: $<'
	@echo 'Invoking: PropGCC Assembler'
	$(CC) $(INC) $(ASFLAGS) -o $@ -c $<
	@echo 'Finished building: $<'
	@echo ' '

#
# a .cog program is an object file that contains code intended to
# run in a COG separate from the main program; i.e., it's a COG
# driver that the linker will place in the .text section.
#
%.cog: ../%.c
	@echo "Building file: $<'
	@echo "Invoking: PropGCC Compiler"
	$(CC) $(INC) $(CFLAGS_NO_MODEL) -mcog -r -o $@ $<
	$(OBJCOPY) --localize-text --rename-section .text=$@ $@
	@echo "Finished building: $<'
	@echo ' '

%.cog: ../%.cogc
	@echo "Building file: $<'
	@echo "Invoking: PropGCC Compiler"
	$(CC) $(INC) $(CFLAGS_NO_MODEL) -mcog -xc -r -o $@ $<
	$(OBJCOPY) --localize-text --rename-section .text=$@ $@
	@echo "Finished building: $<'
	@echo ' '

#
# a .ecog program is an object file that contains code intended to
# run in a COG separate from the main program; i.e., it's a COG
# driver that the linker will place in the .drivers section which
# gets loaded to high EEPROM space above 0x8000.
#
%.ecog: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: PropGCC Compiler'
	$(CC) $(INC) $(CFLAGS_NO_MODEL) -mcog -r -o $@ $<
	@echo 'Renaming: ".text" section'
	$(OBJCOPY) --localize-text --rename-section .text=$@ $@
	@echo 'Finished building: $<'
	@echo ' '

%.ecog: ../%.ecogc
	@echo 'Building file: $<'
	@echo 'Invoking: PropGCC Compiler'
	$(CC) $(INC) $(CFLAGS_NO_MODEL) -mcog -xc -r -o $@ $<
	@echo 'Renaming: ".text" section'
	$(OBJCOPY) --localize-text --rename-section .text=$@ $@
	@echo 'Finished building: $<'
	@echo ' '

%.binary: ../%.elf
	@echo 'Building file: $<'
	@echo 'Invoking: PropGCC Loader'
	$(LOADER) -s $<
	@echo 'Finished building: $<'
	@echo ' '

%.dat: $(SPINDIR)/%.spin
	@echo 'Building file: $<'
	@echo 'Invoking: bstc'
	$(BSTC) -Ox -c -o $(basename $@) $<
	@echo 'Finished building: $<'
	@echo ' '

%_firmware.o: ../%.dat
	@echo 'Building file: $<'
	@echo 'Invoking: PropGCC Object Copy'
	$(OBJCOPY) -I binary -B propeller -O $(CC) $< $@
	@echo 'Finished building: $<'
	@echo ' '

clean:
	$(CLEAN) *.o *.elf *.a *.cog *.ecog *.binary $(NULL)
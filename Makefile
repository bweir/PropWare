# Build all source code files within PropWare for easy testing of compilation errors
PRJ = PropWare

all: gpio.o spi.o spi_as.o sd.o
BOARD = QUICKSTART
MODEL = cmm
CFLAGS = -Os

# Insert your own path here - it should be the same directory that contains "common.mk"
PROPWARE_PATH = /home/david/PropWare

# Optionally, specify where your compiler is installed
PREFIX = /opt/parallax

include $(PROPWARE_PATH)/common.mk

# This file is configured at cmake time, and loaded at cpack time.
# To pass variables to cpack from cmake, they must be configured
# in this file.

if (CPACK_GENERATOR MATCHES "ZIP")
    set(CPACK_COMPONENTS_ALL propware examples win_cmake cmake osx_cmake)
elseif (CPACK_GENERATOR MATCHES "NSIS")
    set(CPACK_COMPONENTS_ALL propware examples win_cmake)
elseif (CPACK_GENERATOR MATCHES "DEB")
    set(CPACK_COMPONENTS_ALL propware examples cmake)
elseif (CPACK_GENERATOR MATCHES "RPM")
    set(CPACK_COMPONENTS_ALL propware examples cmake)
endif ()
if(DEFINED ENV{ZZPKG_ROOT})
  set(ZZPKG_ROOT $ENV{ZZPKG_ROOT})
else()
  set(ZZPKG_ROOT "~/.zzpkg")
endif()
file(TO_CMAKE_PATH "${ZZPKG_ROOT}" ZZPKG_ROOT)


# Set default installation directory
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "" FORCE)
endif()

# Set default RPATH for installed binaries
if(NOT CMAKE_INSTALL_RPATH)
  set(CMAKE_INSTALL_RPATH "$ORIGIN:$ORIGIN/../lib")
endif()
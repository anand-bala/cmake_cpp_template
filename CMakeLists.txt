cmake_minimum_required(VERSION 3.11)

# Check if myproject is being used directly or via add_subdirectory
set(MYPROJECT_MASTER_PROJECT OFF)
if(CMAKE_CURRENT_LIST_DIR STREQUAL CMAKE_SOURCE_DIR)
  set(MYPROJECT_MASTER_PROJECT ON)
endif()

include(cmake/Version.cmake)
message(STATUS "Configuring myproject: v${myproject_FULL_VERSION}")

project(
  myproject
  VERSION "${myproject_VERSION}"
  DESCRIPTION "Temporal Logic Monitoring Tool"
  LANGUAGES CXX
)

include(CMakeDependentOption)

option(BUILD_DOCS "Build the documentation?" OFF)
option(BUILD_EXAMPLES "Build the examples?" ${MYPROJECT_MASTER_PROJECT})

option(ENABLE_CACHE "Enable cache if available" ${MYPROJECT_MASTER_PROJECT})
option(ENABLE_TESTING "Build myproject test suite?" ${MYPROJECT_MASTER_PROJECT})
# Coverage is available only if Testing is enabled, and if it is, it is default
# on
cmake_dependent_option(
  ENABLE_COVERAGE "Generate coverage information from test suite?" ON
  "ENABLE_TESTING" OFF
)

# ##############################################################################
# Include CMake Modules  #
# ##############################################################################

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(StandardProjectSettings)
include(PreventInSourceBuilds)
include(CompilerWarnings)
include(Cache)

include(CTest)
include(Codecov)

include(GNUInstallDirs)

# ##############################################################################
# Some Global Configuration  #
# ##############################################################################

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)

# ##############################################################################
# Third Party dependencies  #
# ##############################################################################

include(ThirdPartyDeps)

# ##############################################################################
# Sources  #
# ##############################################################################

add_subdirectory(src)

# add_subdirectory(examples)

if((MYPROJECT_MASTER_PROJECT AND ENABLE_TESTING) AND BUILD_TESTING)
  add_subdirectory(tests)
endif()

# ##############################################################################
# Installation  #
# ##############################################################################

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(MYPROJECT_CMAKECONFIG_INSTALL_DIR
    "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
    CACHE STRING "install path for myprojectConfig.cmake"
)
set(INSTALL_CONFIGDIR ${MYPROJECT_CMAKECONFIG_INSTALL_DIR})

install(
  EXPORT myprojectTargets
  FILE myprojectTargets.cmake
  NAMESPACE myproject::
  DESTINATION ${INSTALL_CONFIGDIR}
)

# Create a ConfigVersion.cmake file
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/myprojectConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
  ${CMAKE_CURRENT_LIST_DIR}/cmake/myprojectConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/myprojectConfig.cmake
  INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
)

# Install the include dir
install(DIRECTORY include/myproject TYPE INCLUDE)

# Install the config, configversion and custom find modules
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/myprojectConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/myprojectConfigVersion.cmake
        DESTINATION ${INSTALL_CONFIGDIR}
)

install(EXPORT myprojectTargets DESTINATION ${INSTALL_CONFIGDIR})

install(FILES LICENSE LICENSE-3rdParty DESTINATION ${CMAKE_INSTALL_DOCDIR})

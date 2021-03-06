set(myproject_VERSION_MAJOR 0)
set(myproject_VERSION_MINOR 1)
set(myproject_VERSION_PATCH 0)
set(myproject_VERSION
    "${myproject_VERSION_MAJOR}.${myproject_VERSION_MINOR}.${myproject_VERSION_PATCH}"
    CACHE STRING "myproject library version"
)

set(myproject_FULL_VERSION
    ""
    CACHE STRING "myproject library version (with pre-release metadata)"
)

message(CHECK_START "Finding working git")
find_program(GIT_EXE git REQUIRED)
if(NOT GIT_EXE)
  message(CHECK_FAIL "not found")
  return()
endif()

message(CHECK_PASS "found ${GIT_EXE}")
execute_process(
  COMMAND ${GIT_EXE} -C ${CMAKE_CURRENT_SOURCE_DIR} describe --match *.*.*
          --tags
  RESULT_VARIABLE EXIT_STATUS
  OUTPUT_VARIABLE GIT_DESCRIBE
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(EXIT_STATUS EQUAL "0")
  message(STATUS "Attempting to parse for tagged release version.")
  if(GIT_DESCRIBE MATCHES "^v?([0-9]+\\.[0-9]+\\.[0-9]+)$")
    # Tagged release version.
    set(GIT_TAG ${CMAKE_MATCH_1})
    if(NOT GIT_TAG VERSION_EQUAL myproject_VERSION)
      message(
        SEND_ERROR
          "myproject version (${myproject_VERSION}) does not match Git tag (${GIT_TAG})."
      )
    endif()
  elseif(GIT_DESCRIBE MATCHES
         "^v?([0-9]+\\.[0-9]+\\.[0-9]+)(-[a-z0-9]+)?-([0-9]+)-g(.+)$"
  )
    # Untagged pre-release. The myproject version is updated to include the number
    # of commits since the last tagged version and the commit hash. The version
    # is formatted in accordance with the https://semver.org specification.
    set(GIT_TAG ${CMAKE_MATCH_1})
    set(GIT_COMMITS_AFTER_TAG ${CMAKE_MATCH_3})
    set(GIT_COMMIT ${CMAKE_MATCH_4})
    if(NOT myproject_VERSION VERSION_GREATER GIT_TAG)
      message(
        SEND_ERROR
          "myproject version (${myproject_VERSION}) must be greater than tagged ancestor (${GIT_TAG})."
      )
    endif()
    set(myproject_FULL_VERSION
        "${myproject_VERSION}-dev${GIT_COMMITS_AFTER_TAG}+${GIT_COMMIT}"
        CACHE STRING "myproject library version (with pre-release metadata)" FORCE
    )
  else()
    message(SEND_ERROR "Failed to parse version from output of `git describe`.")
  endif()
else()
  message(AUTHOR_WARNING "Failed to match tag using git. Using hard-coded")
  set(myproject_FULL_VERSION
      "${myproject_VERSION}-dev"
      CACHE STRING "myproject library version (with pre-release metadata)" FORCE
  )
endif()

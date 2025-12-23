# Include Guard: Prevents redefinition errors
if (COMMAND parse_project_version)
  return()
endif ()

# Function Definition parse_project_version
# ---------------------
# Reads a version file, parses semantic components, and exports them to the
# parent scope.
function (parse_project_version version_file variable_prefix)

  # Check if file exists relative to the caller's current source directory
  if (NOT IS_ABSOLUTE "${version_file}")
    message("Version file not found at: ${version_file}")
    set(version_file "${CMAKE_CURRENT_SOURCE_DIR}/${version_file}")
    message(
      "Setting version file relative to current source directory: ${version_file}"
    )
  endif ()

  if (NOT EXISTS "${version_file}")
    message(FATAL_ERROR "Version file not found at: ${version_file}")
  endif ()

  # Read and strip whitespace
  file(READ "${version_file}" local_raw_version)
  string(STRIP "${local_raw_version}" local_raw_version)

  # Extract numeric part (e.g., "2.0.0")
  string(REGEX MATCH "^[0-9]+\\.[0-9]+\\.[0-9]+" local_numeric_version
               "${local_raw_version}"
  )

  # Split into list
  string(REPLACE "." ";" local_version_list "${local_numeric_version}")

  # Check for pre-release (e.g., "-beta")
  if ("${local_raw_version}" MATCHES "-")
    set(${variable_prefix}_IS_PRERELEASE "true" PARENT_SCOPE)
    set(${variable_prefix}_IS_PRERELEASE_INT "1" PARENT_SCOPE)
  else ()
    set(${variable_prefix}_IS_PRERELEASE "false" PARENT_SCOPE)
    set(${variable_prefix}_IS_PRERELEASE_INT "0" PARENT_SCOPE)
  endif ()

  list(GET local_version_list 0 local_major)
  list(GET local_version_list 1 local_minor)
  list(GET local_version_list 2 local_patch)

  # Export variables to the caller's scope
  set(${variable_prefix}_FULL "${local_raw_version}" PARENT_SCOPE)
  set(${variable_prefix}_NUMERIC "${local_numeric_version}" PARENT_SCOPE)
  set(${variable_prefix}_MAJOR "${local_major}" PARENT_SCOPE)
  set(${variable_prefix}_MINOR "${local_minor}" PARENT_SCOPE)
  set(${variable_prefix}_PATCH "${local_patch}" PARENT_SCOPE)

endfunction ()

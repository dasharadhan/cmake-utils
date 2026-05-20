# Include Guard: Prevents redefinition errors
if (COMMAND find_doxygen_tags)
  return()
endif ()

# Function Definition: find_doxygen_tags
# --------------------------------------
# Searches for installed Doxygen tagfiles for a list of dependencies.
function (find_doxygen_tags)
  cmake_parse_arguments(
    ARG
    ""
    "TAGFILES_OUT"
    "DEPENDENCIES"
    ${ARGN}
  )

  if (NOT ARG_DEPENDENCIES)
    message(WARNING "find_doxygen_tags: no DEPENDENCIES specified")
    return()
  endif ()

  if (NOT ARG_TAGFILES_OUT)
    message(FATAL_ERROR "find_doxygen_tags: TAGFILES_OUT is required")
  endif ()

  set(tagfiles "")

  foreach (DEP ${ARG_DEPENDENCIES})
    string(TOUPPER ${DEP} DEP_UPPER)

    # Look for <DEP>_TAG_FILE and <dep>_TAG_FILE (case variations)
    set(tag_file "")
    if (DEFINED ${DEP}_TAG_FILE)
      set(tag_file ${${DEP}_TAG_FILE})
    elseif (DEFINED ${DEP_UPPER}_TAG_FILE)
      set(tag_file ${${DEP_UPPER}_TAG_FILE})
    endif ()

    set(docs_url "")
    if (DEFINED ${DEP}_DOCS_URL)
      set(docs_url ${${DEP}_DOCS_URL})
    elseif (DEFINED ${DEP_UPPER}_DOCS_URL)
      set(docs_url ${${DEP_UPPER}_DOCS_URL})
    endif ()

    if (NOT tag_file)
      message(
        STATUS "find_doxygen_tags: no tagfile found for ${DEP} - skipping"
      )
      continue()
    endif ()

    if (NOT EXISTS ${tag_file})
      message(
        STATUS
          "find_doxygen_tags: tagfile for ${DEP} not found at ${tag_file} - skipping"
      )
      continue()
    endif ()

    if (NOT docs_url)
      message(
        STATUS
          "find_doxygen_tags: no docs URL for ${DEP} - reverting to local links"
      )
      get_filename_component(tag_dir ${tag_file} DIRECTORY)
      set(docs_url "file://${tag_dir}/html")
    endif ()

    message(STATUS "find_doxygen_tags: found tagfile for ${DEP} at ${tag_file}")
    string(APPEND tagfiles "${tag_file}=${docs_url} ")
  endforeach ()

  string(STRIP "${tagfiles}" tagfiles)
  set(${ARG_TAGFILES_OUT} "${tagfiles}" PARENT_SCOPE)
endfunction ()

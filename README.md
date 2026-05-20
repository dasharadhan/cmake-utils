# cmake-utils

A modular collection of zero-dependency CMake utilities designed to simplify C++ project configuration.

The utilities are **submodule-safe**, ensuring that nested projects can use these utilities without variable collisions or redefinition errors.

## Core Features

- **Modular Design:** Functions are split into separate files within `cmake/`. Include only what you need.
- **Submodule Safe:** All scripts use include guards to prevent redefinition errors in complex dependency trees.
- **Namespace Aware:** Functions utilize variable prefixes to ensure submodules don't overwrite global project variables.
- **FetchContent Ready:** Designed to be dropped into any project using modern CMake fetching.

## Integration

### Option A: FetchContent (Recommended)

Add the following to your `CMakeLists.txt` to download and make the utilities available:

```cmake
include(FetchContent)

FetchContent_Declare(
  cmake_utils
  GIT_REPOSITORY https://github.com/dasharadhan/cmake-utils.git
  GIT_TAG        main
)

FetchContent_MakeAvailable(cmake_utils)
# The 'cmake/' directory is now in your CMAKE_MODULE_PATH.

```

### Option B: Git Submodule

1. Add the submodule:

```bash
git submodule add https://github.com/dasharadhan/cmake-utils.git external/cmake-utils

```

2. Add to your `CMakeLists.txt`:

```cmake
add_subdirectory(external/cmake-utils)

```

## Available Modules

### 1. Project Versioning (`ParseVersion.cmake`)

Reads a standard semantic version file (e.g., `version.txt`), parses it, and exports scoped variables to the parent project.

**Usage:**

```cmake
include(ParseVersion)

# Usage: parse_project_version(<version_file> <variable_prefix>)
parse_project_version("version.txt" "MY_APP")

```

**Parameters:**

- **`<version_file>`**: Path to the file containing the version string (e.g., `2.1.0-beta`). Can be relative to the caller's directory.
- **`<variable_prefix>`**: A unique string to prefix the output variables (e.g., `MYLIB`, `APP`).

**Output Variables:**

Given the prefix `MY_APP`, the function sets:

| Variable                   | Description                      | Example      |
| -------------------------- | -------------------------------- | ------------ |
| `MY_APP_VERSION_FULL`      | The raw string from the file.    | `2.1.0-beta` |
| `MY_APP_VERSION_NUMERIC`   | The numeric component only.      | `2.1.0`      |
| `MY_APP_VERSION_MAJOR`     | Major version number.            | `2`          |
| `MY_APP_VERSION_MINOR`     | Minor version number.            | `1`          |
| `MY_APP_VERSION_PATCH`     | Patch version number.            | `0`          |
| `MY_APP_IS_PRERELEASE`     | Boolean string (`true`/`false`). | `true`       |
| `MY_APP_IS_PRERELEASE_INT` | Boolean flag (`1`/`0`).          | `1`          |

### 2. Finding Doxygen Documentation Tags (`FindDoxygenTags.cmake`)

Finds the Doxygen documentation tags of dependencies if they exist. Used to link the project documentation generated using Doxygen against the documentation of the dependency libraries. Requires the dependency libraries to export the paths to the tag files.

**Usage:**

```cmake
# Find dependencies
find_package(libA REQUIRED)
find_package(libB REQUIRED)
find_package(libC REQUIRED)

# Provided that lib<A/B/C> exports lib<A/B/C>_TAG_FILE and lib<A/B/C>_DOCS_URL
# find_doxygen_tags exports a space-separated string of tagfile=url pairs, one per dependency
# Usage:
#   find_doxygen_tags(
#       DEPENDENCIES <dependencies>
#       TAGFILES_OUT <string_of_tagfiles>
#   )
find_doxygen_tags(
    DEPENDENCIES libA libB libC
    TAGFILES_OUT DOXYGEN_TAGFILES
)

```

**Parameters:**

- **`DEPENDENCIES`**: A space-separated list of dependent packages
- **`TAGFILES_OUT`**: The variables which will hold the resulting tagfile string

## Extending the Toolkit

To add new functionality (e.g., compiler warnings, sanitizer helpers), follow this pattern to ensure safety across submodules:

1. **Create a new file** in `cmake/` (e.g., `cmake/CompilerSettings.cmake`).
2. **Add an Include Guard** at the top of the file:

```cmake
if(COMMAND my_new_function)
  return()
endif()

```

3. **Define your function**, ensuring you use a `prefix` argument if setting parent variables.
4. **Usage:** The file will automatically be available to `include()` by name once the project is updated.

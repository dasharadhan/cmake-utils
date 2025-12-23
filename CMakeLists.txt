cmake_minimum_required(VERSION 3.10)
project(cmake-utils NONE) # NONE = No compiler needed (script only)

# Automatically add the 'cmake' directory to the module path so the parent
# project can simply call "include(ParseVersion)"
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Export this change to the Parent Scope (The Main Project)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)

message(STATUS "cmake-utils: Ready. functions available.")

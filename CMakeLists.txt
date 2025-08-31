cmake_minimum_required(VERSION 3.10)

# Project name
project(WallPin LANGUAGES C)

# Set the output executable
set(EXECUTABLE_NAME "wallpin")

# Find required packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB REQUIRED glib-2.0)
include_directories(${GLIB_INCLUDE_DIRS})
link_directories(${GLIB_LIBRARY_DIRS})
add_definitions(${GLIB_CFLAGS_OTHER})

pkg_check_modules(SYSPROF REQUIRED sysprof-6)
include_directories(${SYSPROF_INCLUDE_DIRS})
link_directories(${SYSPROF_LIBRARY_DIRS})
add_definitions(${SYSPROF_CFLAGS_OTHER})

pkg_check_modules(GTK4 REQUIRED gtk4)
include_directories(${GTK4_INCLUDE_DIRS})
link_directories(${GTK4_LIBRARY_DIRS})
add_definitions(${GTK4_CFLAGS_OTHER})

pkg_check_modules(GDKPIXBUF REQUIRED gdk-pixbuf-2.0)
include_directories(${GDKPIXBUF_INCLUDE_DIRS})
link_directories(${GDKPIXBUF_LIBRARY_DIRS})
add_definitions(${GDKPIXBUF_CFLAGS_OTHER})

pkg_check_modules(GTKSHELL REQUIRED gtk4-layer-shell-0)
include_directories(${GTKSHELL_INCLUDE_DIRS})
link_directories(${GTKSHELL_LIBRARY_DIRS})
add_definitions(${GTKSHELL_CFLAGS_OTHER})


# Add the source files
set(SOURCE_FILES src/config.c
                  src/layer_shell.c
                  src/layout.c 
                  src/main.c 
                  src/utils.c 
                  src/wallpaper.c
)

# Define the executable
add_executable(${EXECUTABLE_NAME} ${SOURCE_FILES})

# Link GLib and sysprof statically
# set(CMAKE_EXE_LINKER_FLAGS "-static")
target_link_libraries(${EXECUTABLE_NAME} 
  ${GLIB_LIBRARIES} 
  ${SYSPROF_LIBRARIES} 
  ${GTK4_LIBRARIES}
  ${GDKPIXBUF_LIBRARIES}
  ${GTKSHELL_LIBRARIES}
  -pg
  -pthread)

# Remove unused linker flags
string(REPLACE "-Wl,--no-undefined" "" CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")

# Print configuration for debugging
message(STATUS "GLIB_INCLUDE_DIRS: ${GLIB_INCLUDE_DIRS}")
message(STATUS "GLIB_LIBRARY_DIRS: ${GLIB_LIBRARY_DIRS}")
message(STATUS "GLIB_LIBRARIES: ${GLIB_LIBRARIES}")
message(STATUS "SYSPROF_INCLUDE_DIRS: ${SYSPROF_INCLUDE_DIRS}")
message(STATUS "SYSPROF_LIBRARY_DIRS: ${SYSPROF_LIBRARY_DIRS}")
message(STATUS "SYSPROF_LIBRARIES: ${SYSPROF_LIBRARIES}")
message(STATUS "CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}")
message(STATUS "CMAKE_SHARED_LINKER_FLAGS: ${CMAKE_SHARED_LINKER_FLAGS}")
message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
# Install the executable
install(TARGETS ${EXECUTABLE_NAME} DESTINATION /usr/local/bin)


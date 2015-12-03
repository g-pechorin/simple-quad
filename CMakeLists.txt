cmake_minimum_required (VERSION 3.0)

if(WIN32)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
else(WIN32)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -std=gnu++11 -static-libstdc++")
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libstdc++")
endif(WIN32)

include(cmade/pal_glfw.cmake)

project(simple-quad)

add_definitions(-DCMAKE_BINARY_DIR="${CMAKE_BINARY_DIR}") 
add_definitions(-DCMAKE_SOURCE_DIR="${CMAKE_SOURCE_DIR}") 

add_executable(
	simple-quad
		src/simple-quad.cpp
	)
	target_link_libraries(simple-quad glfw ${GLFW_LIBRARIES})

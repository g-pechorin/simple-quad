###	Peter LaValle
###	pal_gtest.cmake
###		Voodoo to rope Google Test. Needs some form of verification to prevent hypothetical man-in-the-middle
###
###	License:
###		This software is in the public domain. Where that dedication is not
###		recognized, you are granted a perpetual, irrevocable license to copy
###		and modify this file however you want.
###
### 2015-07-31 ;
###			- shuffled the tests into their own V$ folder
### ====================================================================================================================


####
## PAL_CMAKE
#
# 2015-07-31 ;
#			- (optional) simplification for when you're loading scraped archives
#			- supports local copies of scrape'ed archives (which sort of require the above)
# 2015-07-27 ; supports local copies of scrape'ed headers
# 2015-07-22 ; "improved" scraping stuff, added more docs, fixed hash-sum
# 2015-06-29 ; Don't use shared libs - ever
# 2015-06-24 ; moved cache to the binary dir
# 2015-06-07 ; added macro for such things pal_chromium_googlesource to 
# 2015-02-05 ; tweaked the extraction so that they'll work correctly when the cache'd files are present but the dumped ones are not
# 2015-02-05 ; put things you shouldn't commit and don't have to commit in separate folders
# 2015-02-07 ; normalised stuff and put the group command into the duplicated block
##
# if pal_cmake stuff hasn't been included, try to do that
if(NOT DEFINED pal_cmake)
							set(pal_cmake "pal_cmake")
							set_property(GLOBAL PROPERTY USE_FOLDERS ON)
							
							# setup a place to store files pulled down from HTTP
							# ... if you want to put this under VCS create `.http-cache/` next to your `CMakeLists.txt`
							if(NOT DEFINED PAL_HTTP_CACHE)
								if(EXISTS				${CMAKE_SOURCE_DIR}/.http-cache/)
									# should it go in the "rootiest" source dir?
									set(PAL_HTTP_CACHE	${CMAKE_SOURCE_DIR}/.http-cache)
									
								elseif(EXISTS			${CMAKE_CURRENT_SOURCE_DIR}/.http-cache/)
									# no? should it go in the current source dir?
									set(PAL_HTTP_CACHE	${CMAKE_CURRENT_SOURCE_DIR}/.http-cache)
								else()
									# fine; put it in the binary dir
									set(PAL_HTTP_CACHE	${CMAKE_BINARY_DIR}/.http-cache)
								endif()
							endif(NOT DEFINED PAL_HTTP_CACHE)
							
							# setup a place to untar (or whatever) the files we've downloaded
							# ... don't put this under VCS - that's just silly
							# ... because if you do, someone might modify the included sources and expect those changes to persist
							# ... which contradicts the ethos (or whatever) of this system
							if(NOT DEFINED PAL_DUMP_CACHE)
								set(PAL_DUMP_CACHE ${CMAKE_BINARY_DIR}/.do-not-commit)
							endif(NOT DEFINED PAL_DUMP_CACHE)

							macro(scrape_file name hashsum url)
								# if ((a local copy exists) OR (a root exists)) we should use that an delete any downloaded copy
								if ((EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/inc/${name}) OR (EXISTS ${CMAKE_SOURCE_DIR}/inc/${name}))
									MESSAGE("Using local copy of `${name}`")
									file(REMOVE ${PAL_HTTP_CACHE}/pal-inc/${name})
								else()
									if (EXISTS ${PAL_HTTP_CACHE}/pal-inc/${name})
										file(MD5 ${PAL_HTTP_CACHE}/pal-inc/${name} pal_check_sum)
									else()
										# if the file doesn't exist - we want this nonsense value
										set(pal_check_sum "1337")
									endif()
									
									if (NOT "${hashsum}" STREQUAL pal_check_sum)
										MESSAGE("Downloading `${name}`")
										file(DOWNLOAD ${url}
											${PAL_HTTP_CACHE}/pal-inc/${name}
											EXPECTED_MD5 ${hashsum})
									else()
										MESSAGE("Reusing `${name}`")
									endif()
								endif()
							endmacro()
							
							# add those to the include
							include_directories(${PAL_HTTP_CACHE}/pal-inc/ ${CMAKE_CURRENT_SOURCE_DIR}/inc/ ${CMAKE_SOURCE_DIR}/inc/)

							##
							## Use this to scrape an archive from somewhere
							## It can be a .zip, .tar.gz or a few others
							macro(scrape_archive name hashsum url)
								if(NOT DEFINED scraped_archive_${name})
								
									if ((EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/sub/${name}) OR (EXISTS ${CMAKE_SOURCE_DIR}/sub/${name}))
									
										if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/sub/${name})
											set(scraped_archive_${name} "${CMAKE_CURRENT_SOURCE_DIR}/sub/${name}")									
											set(scraped__last "${CMAKE_CURRENT_SOURCE_DIR}/sub/${name}")
										elseif (EXISTS ${CMAKE_SOURCE_DIR}/sub/${name})
											set(scraped_archive_${name} "${CMAKE_SOURCE_DIR}/sub/${name}")									
											set(scraped__last "${CMAKE_SOURCE_DIR}/sub/${name}")
										endif()
									else()
								
										if (EXISTS ${PAL_HTTP_CACHE}/pal-tar/${name})
											file(MD5 ${PAL_HTTP_CACHE}/pal-tar/${name} pal_check_sum)
										else()
											# if the file down's exist - we want this nonsense value
											set(pal_check_sum "1337")
										endif()
										if (NOT "${hashsum}" STREQUAL pal_check_sum)
											file(DOWNLOAD ${url}
												${PAL_HTTP_CACHE}/pal-tar/${name}
												EXPECTED_MD5 ${hashsum})
									
											if (EXISTS ${PAL_DUMP_CACHE}/pal-rat/${name})
												file(REMOVE_RECURSE ${PAL_DUMP_CACHE}/pal-rat/${name})
											endif (EXISTS ${PAL_DUMP_CACHE}/pal-rat/${name})
										endif(NOT "${hashsum}" STREQUAL pal_check_sum)
								
										if (NOT EXISTS ${PAL_DUMP_CACHE}/pal-rat/${name})
											file(MAKE_DIRECTORY ${PAL_DUMP_CACHE}/pal-rat/${name})
											execute_process(
												COMMAND ${CMAKE_COMMAND} -E tar xzf ${PAL_HTTP_CACHE}/pal-tar/${name}
												WORKING_DIRECTORY ${PAL_DUMP_CACHE}/pal-rat/${name}
											)
										endif (NOT EXISTS ${PAL_DUMP_CACHE}/pal-rat/${name})
									
										set(scraped_archive_${name} "${PAL_DUMP_CACHE}/pal-rat/${name}")									
										set(scraped__last "${PAL_DUMP_CACHE}/pal-rat/${name}")
									endif()
									
									MESSAGE("Getting `${name}` from ${scraped__last}")
									unset(scraped__last)
								endif(NOT DEFINED scraped_archive_${name})
							endmacro()
							
							function(add_scraped_directories name path)
								if (EXISTS ${path}/CMakeLists.txt)
									MESSAGE("Found `${name}` at `${path}`")
									add_subdirectory(${path} ${name})
								else()
									#MESSAGE("Drilling `${path}` ...")
									file(GLOB find_scraped_cmake ${path}/*)
									
									if("" EQUAL find_scraped_cmake)
										MESSAGE("Could not find `${name}`")
									else("" EQUAL find_scraped_cmake)
										add_scraped_directories(${name} ${find_scraped_cmake})
									endif("" EQUAL find_scraped_cmake)
								endif()
							endfunction(add_scraped_directories)
							
							function(inc_scraped_directories name path home)
								if (EXISTS "${path}/${home}")
									MESSAGE("Found ${home} for ${name} at `${path}`")
									include_directories("${path}/${home}")
								else()
									#MESSAGE("Drilling `${path}` ...")
									file(GLOB find_scraped_cmake ${path}/*)
									
									if("" EQUAL find_scraped_cmake)
										MESSAGE("Could not find ${home} for ${name}")
									else("" EQUAL find_scraped_cmake)
										inc_scraped_directories(${name} "${find_scraped_cmake}" ${home})
									endif("" EQUAL find_scraped_cmake)
								endif()
							endfunction(inc_scraped_directories)
							
							macro(group_target target group)
								if (TARGET ${target})
									set_property(TARGET ${target} PROPERTY FOLDER ${group})
								endif()
							endmacro()

							macro(pal_chromium_googlesource name commit_id)
								
								# http://www.cmake.org/cmake/help/v3.0/module/FindGit.html
								# http://stackoverflow.com/questions/3489173/how-to-clone-git-repository-with-specific-revision-changeset#14091182
								# http://www.cmake.org/cmake/help/v3.0/command/execute_process.html
								
								MESSAGE("No security checks are being done on " ${name} " ... because PAL hasn't built a script which can do them")
								
								find_package(Git)
								if(GIT_FOUND)
									###
									# was git found? then we shall clone the thing!
									file(MAKE_DIRECTORY ${PAL_DUMP_CACHE}/pal-git/)
									if (NOT EXISTS ${PAL_DUMP_CACHE}/pal-git/${name}/.git/)
										if (EXISTS ${PAL_DUMP_CACHE}/pal-git/${name}/)
											file(REMOVE_RECURSE ${PAL_DUMP_CACHE}/pal-git/${name}/)
										endif()
										execute_process(
											COMMAND ${GIT_EXECUTABLE} clone https://chromium.googlesource.com/external/${name}/ ${name}
											WORKING_DIRECTORY ${PAL_DUMP_CACHE}/pal-git/)
									endif()
									
									# switch to the revision we want
									execute_process(
										COMMAND ${GIT_EXECUTABLE} reset --hard ${commit_id}
										WORKING_DIRECTORY ${PAL_DUMP_CACHE}/pal-git/${name}/ )
									
								else(GIT_FOUND)
								
									###
									# was git not found? then we must scrape an archive
									file(DOWNLOAD https://chromium.googlesource.com/external/${name}/+archive/${commit_id}.tar.gz ${PAL_HTTP_CACHE}/pal-tar/${name})
									
									# extract!
									if (EXISTS ${PAL_DUMP_CACHE}/pal-git/${name}/.git/)
										if (EXISTS ${PAL_DUMP_CACHE}/pal-git/${name}/)
											file(REMOVE_RECURSE ${PAL_DUMP_CACHE}/pal-git/${name}/)
										endif()
									endif()
									
									file(MAKE_DIRECTORY ${PAL_DUMP_CACHE}/pal-git/${name})
									execute_process(
										COMMAND ${CMAKE_COMMAND} -E tar xzf ${PAL_HTTP_CACHE}/pal-tar/${name}
										WORKING_DIRECTORY ${PAL_DUMP_CACHE}/pal-git/${name}
									)
								
								endif(GIT_FOUND)
								
								add_subdirectory(${PAL_DUMP_CACHE}/pal-git/${name}/ ${name})
							endmacro()
endif(NOT DEFINED pal_cmake)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Don't use shared libs - ever" FORCE)
##
# (end of PAL_CMAKE)
####

if(NOT DEFINED pal__gtest)
	set(gtest_force_shared_crt ON CACHE BOOL "Link GTest with shared CRC" FORCE)
	# get the project
	pal_chromium_googlesource(googletest 23574bf2333f834ff665f894c97bef8a5b33a0a9)
	
	# add whatever to our include directories
	include_directories(${PAL_DUMP_CACHE}/pal-git/googletest/include)

	# setup testing
	enable_testing()
	
	# tweak gtest to not-die on windows
	set(gtest_force_shared_crt ON)
	
	# create a macro
	macro(pal_gtest name source)
		add_executable(gtest__${name} ${source})
		target_link_libraries(gtest__${name} gtest gtest_main)
		
		add_custom_command(TARGET gtest__${name}
			PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:gtest> $<TARGET_FILE_DIR:gtest__${name}>
			MAIN_DEPENDENCY gtest)
		add_custom_command(TARGET gtest__${name}
			PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:gtest_main> $<TARGET_FILE_DIR:gtest__${name}>
			MAIN_DEPENDENCY gtest_main)
		
		add_test(NAME ${name} COMMAND gtest__${name})
		set_property(TARGET gtest__${name} PROPERTY FOLDER pal_tests)
	endmacro()
	SET(pal__gtest "pal__gtest")
	
	set_property(TARGET gtest		PROPERTY FOLDER pal_tests/gtest)
	set_property(TARGET gtest_main	PROPERTY FOLDER pal_tests/gtest)
endif(NOT DEFINED pal__gtest)

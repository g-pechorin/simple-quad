
	# > TODO ; make this part of ... something ... and don't re-exec it every time
	# > TODO ; make this a macro (or whatever) that can be pointed at directories
	add_custom_target(
		dump_models ALL
		
#			#
#			# somehow export .blend to .fbx
#			# http://indygamedev.com/blender/automating-fbx-model-export-process/
#			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/fbx/examples/"			
#			COMMAND blender -b "${CMAKE_CURRENT_SOURCE_DIR}/examples/scene.blend" --python "${CMAKE_CURRENT_SOURCE_DIR}/examples/dump-fbx.py" -- "${CMAKE_BINARY_DIR}/fbx/examples/scene.fbx"
#			# > TODO ;	deal with missing duplis? what the hell is a duplis?
#			# >			... did I introduce this by switching away from the original exporter?
#			
#			# the dump the .fbx to .assbin using assimp_cmd
#			# ... after compiling assimp_cmd
#			# ... NOTE ; we don't need to select assimp or assimpd if we use the macro $<TARGET_FILE:assimp_cmd>
#			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump/examples/"
#			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/examples/scene.fbx" "${CMAKE_BINARY_DIR}/dump/examples/scene.assbin" -b
#			
#			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump-z/examples/"
#			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/examples/scene.fbx" "${CMAKE_BINARY_DIR}/dump-z/examples/scene.assbin" -b -z
#
#			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump-cfast/examples/"
#			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/examples/scene.fbx" "${CMAKE_BINARY_DIR}/dump-cfast/examples/scene.assbin" -b -cfast
#			
#			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump-cdefault/examples/"
#			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/examples/scene.fbx" "${CMAKE_BINARY_DIR}/dump-cdefault/examples/scene.assbin" -b -cdefault
#			
#			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump-cfull/examples/"
#			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/examples/scene.fbx" "${CMAKE_BINARY_DIR}/dump-cfull/examples/scene.assbin" -b -cfull
			
			DEPENDS assimp_cmd
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIRECTORY}"
		)
		
	macro(dump_blend path)
		add_custom_command(TARGET dump_models PRE_BUILD
			#
			# somehow export .blend to .fbx
			# http://indygamedev.com/blender/automating-fbx-model-export-process/
			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/fbx/examples/"			
			COMMAND blender -b "${CMAKE_CURRENT_SOURCE_DIR}/${path}.blend" --python "${CMAKE_CURRENT_SOURCE_DIR}/examples/dump-fbx.py" -- "${CMAKE_BINARY_DIR}/fbx/${path}.fbx"
			# > TODO ;	deal with missing duplis? what the hell is a duplis?
			# >			... did I introduce this by switching away from the original exporter?
			
			# the dump the .fbx to .assbin using assimp_cmd
			# ... after compiling assimp_cmd
			# ... NOTE ; we don't need to select assimp or assimpd if we use the macro $<TARGET_FILE:assimp_cmd>
			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump/examples/"
			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/${path}.fbx" "${CMAKE_BINARY_DIR}/dump/${path}.assbin" -b
			
			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump-z/examples/"
			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/${path}.fbx" "${CMAKE_BINARY_DIR}/dump-z/${path}.assbin" -b -z

			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump-cfast/examples/"
			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/${path}.fbx" "${CMAKE_BINARY_DIR}/dump-cfast/${path}.assbin" -b -cfast
			
			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump-cdefault/examples/"
			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/${path}.fbx" "${CMAKE_BINARY_DIR}/dump-cdefault/${path}.assbin" -b -cdefault
			
			COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/dump-cfull/examples/"
			COMMAND $<TARGET_FILE:assimp_cmd> dump "${CMAKE_BINARY_DIR}/fbx/${path}.fbx" "${CMAKE_BINARY_DIR}/dump-cfull/${path}.assbin" -b -cfull
			
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIRECTORY}"
		)
	endmacro(dump_blend)
	
	dump_blend(examples/prowship)
	dump_blend(examples/scene)
	
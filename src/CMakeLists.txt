cmake_minimum_required(VERSION 3.10)
project(miskai_flutter)

set(CMAKE_CXX_STANDARD 17)

# Add source files
add_library(miskai_flutter SHARED
    miskai_core.cpp
)

# Platform-specific settings
if(WIN32)
    set_target_properties(miskai_flutter PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS ON
    )
elseif(APPLE)
    set_target_properties(miskai_flutter PROPERTIES
        FRAMEWORK TRUE
        MACOSX_FRAMEWORK_IDENTIFIER com.example.miskai_flutter
    )
endif()

# Include directories
target_include_directories(miskai_flutter PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Link libraries
if(WIN32)
    # Windows-specific libraries
elseif(APPLE)
    # macOS-specific libraries
elseif(UNIX)
    # Linux-specific libraries
endif()

# Optional: Link eSpeak-ng if available
find_library(ESPEAK_LIB espeak-ng)
if(ESPEAK_LIB)
    target_link_libraries(miskai_flutter ${ESPEAK_LIB})
    target_compile_definitions(miskai_flutter PRIVATE HAS_ESPEAK=1)
endif()
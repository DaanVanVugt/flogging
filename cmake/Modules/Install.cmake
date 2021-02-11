# export targets to be found by CMake in another project
install(
        EXPORT FloggingTargets
        FILE FloggingTargets.cmake
        DESTINATION lib/cmake/Flogging
        NAMESPACE "${PROJECT_NAME}::"
)

# generate config
configure_package_config_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/FloggingConfig.cmake"
        INSTALL_DESTINATION lib/cmake/Flogging
        NO_SET_AND_CHECK_MACRO
        NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# add version of the project to config
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/FloggingConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY AnyNewerVersion
)

# export config
install(
        FILES
                "${CMAKE_CURRENT_BINARY_DIR}/FloggingConfig.cmake"
        DESTINATION lib/cmake/Flogging
)

find_program(FORD_EXE NAMES ford)

if(FORD_EXE)
        set(FORD_CONFIG "${CMAKE_SOURCE_DIR}/flogging.md")
        add_custom_target(
                doc
                COMMAND ${FORD_EXE} -o "${CMAKE_DOC_OUTPUT_DIRECTORY}" "${FORD_CONFIG}"
        )

        add_custom_target(
                doc-deploy
                COMMAND git subtree push --prefix doc origin gh-pages
        )
endif()

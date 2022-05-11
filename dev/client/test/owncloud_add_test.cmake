find_package(Qt5 COMPONENTS Core Test Xml Network REQUIRED)

include(ECMAddTests)

function(owncloud_add_test test_class)
    set(OWNCLOUD_TEST_CLASS ${test_class})
    string(TOLOWER "${OWNCLOUD_TEST_CLASS}" OWNCLOUD_TEST_CLASS_LOWERCASE)

    ecm_add_test(test${OWNCLOUD_TEST_CLASS_LOWERCASE}.cpp
        ${ARGN}
        TEST_NAME "${OWNCLOUD_TEST_CLASS}Test"
        LINK_LIBRARIES
        owncloudCore syncenginetestutils testutilsloader Qt5::Test
    )
    target_compile_definitions(${OWNCLOUD_TEST_CLASS}Test PRIVATE OWNCLOUD_BIN_PATH="${CMAKE_BINARY_DIR}/bin" SOURCEDIR="${PROJECT_SOURCE_DIR}")

    target_include_directories(${OWNCLOUD_TEST_CLASS}Test PRIVATE "${CMAKE_SOURCE_DIR}/test/")
    if (UNIX AND NOT APPLE)
        set_property(TEST ${OWNCLOUD_TEST_CLASS}Test PROPERTY ENVIRONMENT "QT_QPA_PLATFORM=offscreen")
    endif()
endfunction()

macro(owncloud_add_benchmark test_class)
    set(OWNCLOUD_TEST_CLASS ${test_class})
    string(TOLOWER "${OWNCLOUD_TEST_CLASS}" OWNCLOUD_TEST_CLASS_LOWERCASE)

    add_executable(${OWNCLOUD_TEST_CLASS}Bench benchmarks/bench${OWNCLOUD_TEST_CLASS_LOWERCASE}.cpp ${additional_cpp})
    ecm_mark_nongui_executable(${OWNCLOUD_TEST_CLASS}Bench)

    target_link_libraries(${OWNCLOUD_TEST_CLASS}Bench
        libsync
        syncenginetestutils
        Qt5::Core Qt5::Test Qt5::Xml Qt5::Network
    )
    target_compile_definitions(${OWNCLOUD_TEST_CLASS}Bench PRIVATE OWNCLOUD_BIN_PATH="${CMAKE_BINARY_DIR}/bin")
endmacro()

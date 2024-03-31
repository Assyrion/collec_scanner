cmake_minimum_required(VERSION 3.16)

project(collecscanner VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QZXING_MULTIMEDIA ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(APPNAME ${PROJECT_NAME})

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Sql Network LinguistTools Qml Quick QuickControls2 Multimedia)

configure_file(cmake_global.h.in ${CMAKE_CURRENT_SOURCE_DIR}/cmake_global.h @ONLY)

include_directories(".")
add_subdirectory(qzxing)

qt_standard_project_setup(REQUIRES 6.5)

set(TRANSLATIONS
    i18n/qml_fr_FR.ts
    i18n/qml_en_EN.ts
)

qt_add_translation(TS_FILES ${TRANSLATIONS})

set(RESOURCES
    qml.qrc
    media.qrc
    translations.qrc
)

set(SOURCES
    main.cpp
    commanager.cpp
    databasemanager.cpp
    ebayobject.cpp
    filemanager.cpp
    gamedata.cpp
    imagemanager.cpp
    sortfilterproxymodel.cpp
    sqltablemodel.cpp
)

set(HEADERS
    commanager.h
    databasemanager.h
    ebayobject.h
    filemanager.h
    gamedata.h
    imagemanager.h
    global.h
    sortfilterproxymodel.h
    sqltablemodel.h
)

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCES ${RESOURCES}
    SOURCES ${SOURCES} ${HEADERS}
)

qt_policy(SET QTP0002 NEW)

set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${PROJECT_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.collecscanner
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    Qt6::Core
    Qt6::Sql
    Qt6::Network
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    qzxing
)

if(ANDROID)
    set(AHOME $ENV{ANDROID_HOME})
    include_directories(${AHOME}/openSSL)
    include(${AHOME}/openSSL/CMakeLists.txt)
endif()

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

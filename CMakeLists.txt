cmake_minimum_required(VERSION 3.5)

project(collecscanner)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QZXING_MULTIMEDIA ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(APPNAME ${PROJECT_NAME})

find_package(Qt6 REQUIRED COMPONENTS Core Sql Network LinguistTools Qml Quick QuickControls2)

configure_file(cmake_global.h.in ${CMAKE_CURRENT_SOURCE_DIR}/cmake_global.h @ONLY)

include_directories(".")
add_subdirectory(qzxing)

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

set(RESOURCES
    qml.qrc
    media.qrc
    translations.qrc
)

qt_add_resources(RESOURCES_RCC ${RESOURCES})

set(TRANSLATIONS
    i18n/qml_fr_FR.ts
    i18n/qml_en_EN.ts
)

qt_add_translation(QM_FILES ${TRANSLATIONS})

set(RC_ICONS ${CMAKE_CURRENT_SOURCE_DIR}/img/${PROJECT_NAME}.ico)

add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    ${RESOURCES_RCC}
    ${QM_FILES}
    ${RC_ICONS}
)

target_link_libraries(${PROJECT_NAME}
    Qt6::Core
    Qt6::Sql
    Qt6::Network
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    qzxing
)

if (ANDROID_ABI STREQUAL "arm64-v8a")
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android)
endif()

if(ANDROID)
    set(AHOME $ENV{ANDROID_HOME})
    include_directories(${AHOME}/openSSL)
endif()

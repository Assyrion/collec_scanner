QT += sql network
CONFIG += c++14 qzxing_multimedia
TARGET = collecscanner
DEFINES += APPNAME='\\"$${TARGET}\\"'

android {
    QT += core-private
}

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += main.cpp \
    commanager.cpp \
    filemanager.cpp \
    gamedata.cpp \
    imagemanager.cpp \
    sortfilterproxymodel.cpp \
    sqltablemodel.cpp

RESOURCES += \
    qml.qrc \
    media.qrc \
    translations.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

include (qzxing/QZXing.pri)

HEADERS += \
    commanager.h \
    filemanager.h \
    gamedata.h \
    imagemanager.h \
    global.h \
    sortfilterproxymodel.h \
    sqltablemodel.h

TRANSLATIONS += i18n/qml_fr_FR.ts \
                i18n/qml_en_EN.ts

RC_ICONS = $${PWD}/img/$${TARGET}.ico

contains(ANDROID_TARGET_ARCH,arm64-v8a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
}


import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects

Item {
    id: root

    signal clicked

    implicitHeight: mainImg.height + 5

    Connections {
        target: coverProcessingPopup
        function onAboutToHide() {
            mainImg.source =
                    imageManager.getFrontPic(tag)
        }
    }

    Image {
        id: mainImg
        width: parent.width
        fillMode: Image.PreserveAspectFit
        source: imageManager.getFrontPic(tag)
        cache: false
        mipmap: true
        smooth: true

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: root.clicked()
        }
    }

    Colorize {
        visible: !owned
        anchors.fill: mainImg
        source: mainImg
        saturation: 0
        lightness: 0.6
        hue: 0
    }
}

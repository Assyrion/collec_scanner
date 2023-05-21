import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects

import "../utils"

Item {
    id: root

    signal clicked

    Connections {
        target: coverProcessingPopup
        function onAboutToHide() {
            frontPic.frontSource =
                    imageManager.getFrontPic(tag)
        }
    }

    Item {
        id: frontPic
        anchors.fill: parent

        property alias frontSource : frontPicImg.source
        Image {
            id: frontPicImg
            width: parent.width + 5 // not sourceSize !
            anchors.top: parent.top
            anchors.topMargin:
                -implicitHeight/2 + 30
            anchors.horizontalCenter:
                parent.horizontalCenter
            source: imageManager.getFrontPic(tag)
            fillMode: Image.Stretch
            antialiasing: true
            cache: false
            mipmap: true
            smooth: true
        }
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width : frontPic.width
                height: frontPic.height
                radius: 10
            }
        }
    }
    CSGlowText {
        id: titleText
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter:
            parent.verticalCenter
        anchors.right: platformText.left
        anchors.rightMargin: 10
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: title
    }
    CSGlowText {
        id: platformText
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter:
            parent.verticalCenter
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: platform
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}

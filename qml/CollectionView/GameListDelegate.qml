import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects

import "../utils"

Item {
    id: root
    signal clicked

    Item {
        id: frontPicImg
        anchors.fill: parent
        Image {
            width: parent.width + 5 // not sourceSize !
            anchors.top: parent.top
            anchors.topMargin:
                -implicitHeight/2 + 30
            anchors.horizontalCenter:
                parent.horizontalCenter
            source: imageManager ? imageManager.getFrontPic(tag)
                                 : "qrc:/no_pic"
            fillMode: Image.Stretch
            antialiasing: true
            cache: false
            mipmap: true
            smooth: true
        }
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width : frontPicImg.width
                height: frontPicImg.height
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

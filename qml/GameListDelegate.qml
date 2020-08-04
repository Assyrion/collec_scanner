import QtQuick 2.8
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import GameData 1.0
import "utils"

Item {
    id: root
    signal clicked
    Component.onCompleted: {
        mouseArea.clicked.connect(clicked)
    }
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
            Math.min(17, parent.width/3)
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
            Math.min(17, parent.width/3)
        font.family: "Roboto"
        text: platform
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

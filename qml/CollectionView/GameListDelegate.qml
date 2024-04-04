import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt5Compat.GraphicalEffects

import "../utils"

Item {
    id: root

    signal clicked
    property string subfolderPic: platformName + "/" + model.tag

    opacity: model.subgame === 1? 0.2 : 1

    Component.onCompleted: {
        console.log(model.subgame)
        console.log(model.tag)
    }

    Item {
        id: frontPic

        property alias frontSource : frontPicImg.source

        anchors.fill: parent
        visible: false

        Image {
            id: frontPicImg
            width: parent.width + 5 // not sourceSize !
            anchors.top: parent.top
            anchors.topMargin: -implicitHeight/2 + 30
            anchors.horizontalCenter: parent.horizontalCenter
            source: ("image://coverProvider/%1.front").arg(root.subfolderPic)
            fillMode: Image.PreserveAspectCrop
            antialiasing: true
            cache: false
            mipmap: true
            smooth: true
        }
    }
    OpacityMask {
        id: opacityMask
        anchors.fill: frontPic
        source: frontPic
        maskSource: Rectangle {
            width : frontPic.width
            height: frontPic.height
            radius: 10
        }
    }

    Colorize {
        visible: !owned
        anchors.fill: opacityMask
        source: opacityMask
        saturation: 0
        lightness: 0.3
        hue: 0
    }

    CSGlowText {
        id: titleText
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter:
            parent.verticalCenter
        anchors.right: platformText.left
        anchors.rightMargin: 10
        opacity: model?.owned ? 1 : 0.4
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: model?.title ?? ""
    }
    CSGlowText {
        id: platformText
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter:
            parent.verticalCenter
        opacity: model?.owned ? 1 : 0.4
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: platformName
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}

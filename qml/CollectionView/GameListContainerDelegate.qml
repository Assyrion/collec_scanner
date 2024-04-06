import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt5Compat.GraphicalEffects

import "../utils"

ItemDelegate {
    id: root

    checkable: true

    Item {
        id: frontPic

        anchors.top: parent.top
        width: parent.width
        height: 50

        visible: false
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
            frontPic.verticalCenter
        anchors.right: platformText.left
        anchors.rightMargin: 10
        opacity: model?.owned ? 1 : 0.4
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: (model?.title ?? "") + " - " + subgamesView.count + " variantes"
    }
    CSGlowText {
        id: platformText
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter:
            frontPic.verticalCenter
        opacity: model?.owned ? 1 : 0.4
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: platformName
    }

    Rectangle {
        anchors.fill: frontPic
        color: "transparent"
        border.color: "white"
        border.width: 5
        radius: 10
    }

    ListView {
        id: subgamesView
        width: parent.width
        height: 0
        anchors.top: frontPic.bottom
        interactive: false
        spacing: 5
        model: dbManager.currentProxyModel.getCodeFilterProxyModel(code)
        delegate: GameListDelegate {
            width:  root.width - 10
            height: 50
            onClicked: root.showGameRequired(index)
        }
    }

    onClicked: {
        subgamesView.height = checked ? 0 : subgamesView.contentHeight
    }
}

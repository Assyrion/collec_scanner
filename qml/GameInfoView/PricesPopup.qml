import QtQuick 6.2
import QtMultimedia 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects

import "../utils"

Popup {
    id: root

    required property string tag
    property var priceModel

    Component.onCompleted:  {
        open()
        priceModel = comManager.getPriceFromEbay(tag)
    }

    topPadding: 1
    bottomPadding: 1
    leftPadding: 1
    rightPadding: 1

    modal: true
//    dim: false

    background: RectangularGlow {
        glowRadius: 10
        spread: 0
        color: "#222222"
        cornerRadius: 0
    }

    contentItem : Pane {

        ListView {
            width: parent.width
            height: parent.height * 0.85
            anchors.left: parent.left
            anchors.verticalCenter:
                parent.verticalCenter
            model: priceModel
            spacing: 10
            snapMode: ListView.SnapToItem
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
                width: 10
            }

            delegate: Label {
                width: root.width - 40
                height: 70
                leftPadding: 10
                font.pixelSize: 12
                verticalAlignment:
                    Label.AlignVCenter
                wrapMode: Text.WordWrap
                color: "white"
                text: modelData
                background: Rectangle {
                    color: "burlywood"
                    border.color: "transparent"
                    opacity: 0.1
                    radius: 8
                }
            }
        }
    }
}

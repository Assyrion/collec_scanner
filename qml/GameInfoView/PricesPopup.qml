import QtQuick 6.3
import QtQuick.Controls 6.3
import QtQuick.Layouts 6.3
import Qt5Compat.GraphicalEffects

import "../utils"

Popup {
    id: root

    required property string tag
    property var priceModel: null

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
            id: ebayItemListView

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

            delegate: Item {
                width: root.width - 40
                height: 70
                Rectangle {
                    anchors.fill: parent
                    color: "burlywood"
                    border.color: "transparent"
                    opacity: 0.1
                    radius: 8
                }

                RowLayout {
                    height: parent.height
                    width: parent.width - 20
                    anchors.horizontalCenter:
                        parent.horizontalCenter
                    spacing: 7

                    Text {
                        text: modelData.title
                        font.pixelSize: 12
                        color: "white"
                        wrapMode: Text.WordWrap
                        verticalAlignment: Text.AlignVCenter
                        Layout.preferredWidth: parent.width * 0.55
                    }
                    ColumnLayout {
                        Layout.maximumWidth: parent.width * 0.25
                        Layout.minimumWidth: parent.width * 0.25
                        Layout.fillHeight: true
                        spacing: 10

                        Text {
                            text: modelData.condition
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap

                            color: "white"
                            horizontalAlignment: Text.AlignLeft
                        }
                        Text {
                            text: modelData.price + " €"
                            font.pixelSize: 12
                            color: "white"
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                    Button {
                        Layout.preferredWidth: parent.width * 0.15
                        Layout.preferredHeight: parent.height * 0.6
                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        text: "\u{1F517}"
                        onClicked: {
                            Qt.openUrlExternally(modelData.itemUrl);
                        }
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 10
                        bottomPadding: 10

                        font.pointSize: 10
                    }
                }
            }
        }

        BusyIndicator{
            anchors.centerIn: parent
            visible: priceModel === null
        }
        Text {
            anchors.centerIn: parent
            color: "white"
            text: qsTr("No Data")
            font.pointSize: 20
            visible: priceModel !== null
                     && ebayItemListView.count === 0
        }
    }
}

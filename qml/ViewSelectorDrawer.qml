import QtQuick 2.8
import QtQuick.Controls 2.2

Drawer {
    id: root

    signal gridViewRequired
    signal listViewRequired

    edge: Qt.TopEdge

    Row {
        anchors.centerIn: parent
        spacing: 10

        Button {
            id: listViewBtn

            padding: 5
            icon.source: "qrc:/list_view"
            icon.width: 35
            icon.height: 35
            background: Rectangle {
                   implicitWidth: 40
                   implicitHeight: 40
                   opacity: listViewBtn.hovered ? 1.0 : 0.7
                   color: "#3fcccccc"
                   radius: 4
               }
            onClicked: {
                listViewRequired()
                close()
            }
        }

        Button {
            id: gridViewBtn

            padding: 5
            icon.source: "qrc:/grid_view"
            icon.width: 35
            icon.height: 35
            background: Rectangle {
                   implicitWidth: 40
                   implicitHeight: 40
                   opacity: gridViewBtn.hovered ? 1.0 : 0.7
                   color: "#3fcccccc"
                   radius: 4
               }

            onClicked: {
                gridViewRequired()
                close()
            }
        }
    }
}

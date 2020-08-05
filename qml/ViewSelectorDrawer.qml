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

            text: "list"
            onClicked: {
                listViewRequired()
                close()
            }
        }

        Button {
            id: gridViewBtn
            text: "grid"
            onClicked: {
                gridViewRequired()
                close()
            }
        }
    }
}

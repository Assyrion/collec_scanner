import QtQuick 6.2
import QtQuick.Controls 6.2


MenuBar {
    id: root

    signal newGameRequired
    signal gridViewRequired
    signal listViewRequired

    background: Rectangle {
        color: "#222222"
        radius: 10
        opacity: 0.7
        border.color: "white"
    }

    font.pointSize: 12
    Menu {
        title: "\u{1F527}"
        width: root.width + 40
        background: Rectangle {
            color: "black"
            opacity: 0.8
            radius: 5
        }
        MenuItem {
            icon.source: "qrc:/add_notag"
            onTriggered: root.newGameRequired()
        }
        Menu {
            title: qsTr("View")
            width: root.width
            font.pointSize: 18

            MenuItem {
                text: "\u{2630}"
                onTriggered: root.listViewRequired()
            }
            MenuItem {
                text: "\u{2637}"
                onTriggered: root.gridViewRequired()
            }
        }
    }
}

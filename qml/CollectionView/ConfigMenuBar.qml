import QtQuick 6.2
import QtQuick.Controls 6.2


MenuBar {
    id: root

    signal gridViewRequired
    signal listViewRequired

    background: Rectangle {
        color: "black"
        opacity: 0.6
        radius: 10
    }

    font.pointSize: 20
    Menu {
        title: "\u{1F527}"
        width: root.width*2
        background: Rectangle {
            color: "black"
            opacity: 0.8
            radius: 5
        }
        Menu {
            title: "View"
            width: root.width - 10
            font.pointSize: 20
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

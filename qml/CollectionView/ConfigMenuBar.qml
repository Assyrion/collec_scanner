import QtQuick 6.2
import QtQuick.Controls 6.2


MenuBar {
    id: root

    signal gridViewRequired
    signal listViewRequired
    signal newGameRequired
    signal configRequired

    property Component backgroundRec : Rectangle {
        color: "#222222"
        radius: 10
        opacity: 0.8
        border.color: "white"
    }

    background: backgroundRec.createObject(root)
    font.pointSize: 16
    Menu {
        title: "\u{1F527}"
        width: root.width*3
        background: backgroundRec.createObject(root)
        MenuItem {
            text: qsTr("Filter")
            icon.source: "qrc:/filter"
            onTriggered: root.configRequired()
            highlighted: false
        }
        MenuItem {
            text: qsTr("New")
            icon.source: "qrc:/add_notag"
            onTriggered: root.newGameRequired()
            highlighted: false
        }
        Menu {
            title: qsTr("View")
            width: root.width*3
            background: backgroundRec.createObject(root)
            MenuItem {
                text: qsTr("List")
                icon.source: "qrc:/list_view"
                onTriggered: root.listViewRequired()
            }
            MenuItem {
                text: qsTr("Grid")
                icon.source: "qrc:/grid_view"
                onTriggered: root.gridViewRequired()
            }
        }
        Menu {
            title: qsTr("Platform")
            width: root.width*3
            background: backgroundRec.createObject(root)
            MenuItem {
                text: qsTr("ps2")
                onTriggered: platformName = text
            }
            MenuItem {
                text: qsTr("ps3")
                onTriggered: platformName = text
            }
        }
    }
}

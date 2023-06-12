import QtQuick 6.2
import QtQuick.Controls 6.2

import "../utils/PlatformSelector.js" as Platforms

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
        id: rootMenu
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
            id: viewMenu
            title: qsTr("View")
            width: root.width*3
            background: backgroundRec.createObject(root)
            ListView {
                height: contentHeight
                model: ListModel {
                    ListElement {
                        titleRole: qsTr("List")
                        iconRole: "qrc:/list_view"
                        triggerRole: () => root.listViewRequired()
                    }
                    ListElement {
                        titleRole: qsTr("Grid")
                        iconRole: "qrc:/grid_view"
                        triggerRole: () => root.gridViewRequired()
                    }
                }
                delegate : MenuItem {
                    text: titleRole
                    icon.source: iconRole
                    highlighted: index === collectionView
                    onTriggered: {
                        triggerRole()
                        viewMenu.close()
                        rootMenu.close()
                    }
                }
            }
        }
        Menu {
            id: platformMenu
            title: qsTr("Platform")
            width: root.width*2
            background: backgroundRec.createObject(root)
            ListView {
                height: contentHeight
                model: Object.keys(Platforms.list)
                delegate: MenuItem {
                    text: modelData
                    highlighted: modelData === platformName
                    onTriggered: {
                        platformName = modelData
                        platformMenu.close()
                        rootMenu.close()
                    }
                }
            }
        }
    }
}

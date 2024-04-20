import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt5Compat.GraphicalEffects

import "../utils/PlatformSelector.js" as Platforms

ItemDelegate {
    id: root

    property string rootTitle: model?.title ?? ""
    property var titleProxyModel:
        dbManager.currentProxyModel.getTitleFilterProxyModel(rootTitle)

    signal subGameClicked(int idx)

    Component.onCompleted: {
        var idx = model.title.indexOf('(');
        if (idx !== -1) {
            rootTitle = model.title.slice(0, idx).trim()
        }
    }

    onClicked: containerPopup.open()

    background: Rectangle {
        id: bckgndRec

        color: "transparent"
        border.color: "burlywood"
        border.width: 1
    }

    contentItem: GridView {
        id: subgamesView
        anchors.fill: parent

        anchors.margins: 3
        interactive: false
        clip: true

        Component.onCompleted: {
            model = root.titleProxyModel
        }

        cellWidth: width/2
        cellHeight: cellWidth / Platforms.list[platformName].coverRatio

        delegate: Item {
            width: subgamesView.cellWidth
            height: subgamesView.cellHeight

            GameGridDelegate {
                anchors.centerIn: parent
                width:  parent.width - 5
                height: parent.height - 5
                onClicked: containerPopup.open()
            }
        }
    }

    Popup {
        id: containerPopup

        width: parent.width * 2 + 20
        height: parent.height * 2 + 20

        padding: 1

        modal: true
        dim: false

        onAboutToShow: {
            var windowRect = mainWindow.contentItem
            var global_pt = mapToItem(windowRect, -width/4, -height/4)

            if(global_pt.x < 0) {
                x = 0
            } else if((global_pt.x + width) > windowRect.width) {
                x = -width/2
            } else {
                x = -width/4
            }
            if(global_pt.y < 0) {
                y = 0
            } else if((global_pt.y + height) > windowRect.height) {
                y = -height/2
            } else {
                y = -height/4
            }
        }

        background: Rectangle {
            color: "transparent"
            border.color: "burlywood"
            border.width: 1
        }

        contentItem: Pane {
            padding: 3

            MouseArea {
                anchors.fill: parent
                onClicked: containerPopup.close()
            }

            GridView {
                id: subgamesZoomedView
                anchors.fill: parent

                model: root.titleProxyModel
                interactive: subgamesZoomedView.count > 4
                highlightRangeMode: GridView.StrictlyEnforceRange
                clip: true

                cellWidth: width/2
                cellHeight: cellWidth / Platforms.list[platformName].coverRatio

                ScrollBar.vertical: ScrollBar {
                    visible: subgamesZoomedView.count > 4
                    width: 10
                }

                delegate: Item {
                    width: subgamesZoomedView.cellWidth
                    height: subgamesZoomedView.cellHeight

                    GameGridDelegate {
                        anchors.centerIn: parent
                        width: parent.width - 5
                        height: parent.height - 5
                        onClicked: {
                            var sourceIdx = root.titleProxyModel.mapIndexToSource(index)
                            root.subGameClicked(sourceIdx) // source is SortFilterProxyModel
                        }
                    }
                }
            }
        }
    }
}

import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt5Compat.GraphicalEffects

import "../utils/PlatformSelector.js" as Platforms

Item{
    id: root

    property string rootTitle: model?.title ?? ""

    signal subGameClicked(int idx)

    Component.onCompleted: {
        var idx = model.title.indexOf('(');
        if (idx !== -1) {
            rootTitle = model.title.slice(0, idx).trim()
        }
    }

    Rectangle {
        id: bckgndRec

        anchors.fill: parent

        color: "transparent"
        border.color: "burlywood"
        border.width: 1
    }

    GridView {
        id: subgamesView
        anchors.fill: bckgndRec
        anchors.margins: 3
        anchors.centerIn: bckgndRec
        interactive: subgamesView.count > 4

        property var titleProxyModel:
            dbManager.currentProxyModel.getTitleFilterProxyModel(rootTitle)

        Component.onCompleted: {
            model = titleProxyModel
        }

        highlightRangeMode: GridView.StrictlyEnforceRange

        cellWidth: width/2
        cellHeight: cellWidth / Platforms.list[platformName].coverRatio

        ScrollBar.vertical: ScrollBar {
            visible: subgamesView.count > 4
            width: 10
        }

        clip: true
        delegate: Item {
            width: subgamesView.cellWidth
            height: subgamesView.cellHeight

            GameGridDelegate {
                property string subfolderPic: platformName + "/" + model.tag

                anchors.centerIn: parent
                width: parent.width - 3
                height: parent.height - 3

                onClicked: {
                    var sourceIdx = subgamesView.titleProxyModel.mapIndexToSource(index)
                    root.subGameClicked(sourceIdx) // source is SortFilterProxyModel
                }
            }
        }
    }
}

import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt.labs.qmlmodels

import "../utils"
import "../utils/PlatformSelector.js" as Platforms

GridView {
    id: root

    signal showGameRequired(int idx)
    signal movingChanged(bool moving)

    property var subgameFilterProxyModel:
        dbManager.currentProxyModel.subgameFilterProxyModel

    Component.onCompleted: {
        model = subgameFilterProxyModel// initial DB
    }

    // update model when pointing to new DB
    Connections {
        target: dbManager
        function onDatabaseChanged() {
            model = subgameFilterProxyModel
        }
    }

    highlightMoveDuration: 0

    cellWidth: Math.min((width-5)/4, 169)
    cellHeight: cellWidth / Platforms.list[platformName].coverRatio

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AlwaysOn
        width: 10
    }

    onMovingChanged: root.movingChanged(moving)

    delegate: DelegateChooser {
        id: chooser
        role: "subgame"
        DelegateChoice {
            roleValue: 0
            GameGridDelegate {
                width: root.cellWidth - 5
                height: root.cellHeight - 5
                onClicked: {
                    var sourceIdx = subgameFilterProxyModel.mapIndexToSource(index)
                    root.showGameRequired(sourceIdx) // source is SortFilterProxyModel
                }
            }
        }
        DelegateChoice {
            roleValue: 1
            GameGridContainerDelegate {
                width: root.cellWidth - 5
                height: root.cellHeight - 5
                onSubGameClicked: (idx) => root.showGameRequired(idx)
            }
        }
    }
}


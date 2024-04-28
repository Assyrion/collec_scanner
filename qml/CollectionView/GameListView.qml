import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt.labs.qmlmodels

import "../utils"

ListView {
    id: root

    signal showGameRequired(int idx)
    signal movingChanged(bool moving)

    property var subgameFilterProxyModel:
        dbManager.currentProxyModel.subgameFilterProxyModel

    Component.onCompleted: {
        model = subgameFilterProxyModel // initial DB
    }

    // update model when pointing to new DB
    Connections {
        target: dbManager
        function onDatabaseChanged() {
            model = subgameFilterProxyModel
        }
    }

    highlightMoveDuration: 0
    spacing: 5

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
            GameListDelegate {
                width:  root.width - 10
                height: 50
                onClicked: {
                    var sourceIdx = subgameFilterProxyModel.mapIndexToSource(index)
                    root.showGameRequired(sourceIdx) // source is SortFilterProxyModel
                }
            }
        }
        DelegateChoice {
            roleValue: 1
            GameListContainerDelegate {
                width:  root.width - 10
                height: implicitHeight
                onSubGameClicked: (idx) => root.showGameRequired(idx)
            }
        }
    }
}


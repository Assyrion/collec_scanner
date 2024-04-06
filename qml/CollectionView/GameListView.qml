import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt.labs.qmlmodels

import "../utils"

ListView {
    id: root

    signal showGameRequired(int idx)
    signal movingChanged(bool moving)

    Component.onCompleted: {
        model = dbManager.currentProxyModel // initial DB
    }

    // update model when pointing to new DB
    Connections {
        target: dbManager
        function onDatabaseChanged() {
            model = dbManager.currentProxyModel
        }
    }

    highlightMoveDuration: 0
    spacing: 5

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AlwaysOn
        width: 10
    }
    delegate: chooser
    onMovingChanged: root.movingChanged(moving)

    DelegateChooser {
        id: chooser
        role: "subgame"
        DelegateChoice {
            roleValue: 0
            GameListDelegate {
                width:  root.width - 10
                height: 50
                onClicked: root.showGameRequired(index)
            }
        }
        DelegateChoice {
            roleValue: 1
            GameListContainerDelegate {
                width:  root.width - 10
                implicitHeight: 200
            }
        }
        DelegateChoice {
            roleValue: 2
            GameListDelegate {
                visible: false
            }
        }
    }
}


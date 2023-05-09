import QtQuick 6.2
import QtQuick.Controls 6.2

import "../utils"

Pane {
    id: root

    padding: 0

    function diplayListView() {
        gameStackView.replace(gameListViewCpt)
    }

    function diplayGridView() {
        gameStackView.replace(gameGridViewCpt)
    }

    signal showGameRequired(int idx)
    signal showNewGameRequired

    StackView {
        id: gameStackView

        anchors.fill: parent
        initialItem: gameListViewCpt

        Connections {
            target: gameStackView.currentItem
            function onShowGameRequired(idx) {
                root.showGameRequired(idx)
            }
            function onMovingChanged(moving) {
                addGameBtn.opacity = !moving
            }
        }
    }

    Component {
        id: gameListViewCpt
        GameListView {}
    }

    Component {
        id: gameGridViewCpt
        GameGridView {}
    }

    AddGameButton {
        id: addGameBtn
        maxWidth : root.width
        maxHeight: root.height
        onClicked: root.showNewGameRequired()

        Behavior on opacity {
            NumberAnimation { duration : 200 }
        }
    }

    ViewSelectorDrawer {
        id: viewSelectorDrawer
        width: parent.width
        height: parent.height/10
        onListViewRequired: diplayListView()
        onGridViewRequired: diplayGridView()
    }
}

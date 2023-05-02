import QtQuick 6.2
import QtQuick.Controls 6.2

import ".."
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
    }

    ConfigDrawer {
        id: drawer
        width: parent.width * 0.7
        height: parent.height
    }

    ViewSelectorDrawer {
        id: viewSelectorDrawer
        width: parent.width
        height: parent.height/10
        onListViewRequired: diplayListView()
        onGridViewRequired: diplayGridView()
    }
}

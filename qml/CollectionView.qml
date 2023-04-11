import QtQuick 6.2
import QtQuick.Controls 6.2
import "utils"

Pane {
    id: root

    padding: 0

    function showGameData(game, index) {
        gameDataLoader.setSource("GameDataView.qml",
                                 {"game": game,
                                     "row" : index})
    }
    function showNewGameData() {
        gameDataLoader.setSource("GameDataView.qml",
                                 {"editMode": true,
                                     "manuMode": true})
    }

    function diplayListView() {
        gameStackView.replace(gameListViewCpt)
    }

    function diplayGridView() {
        gameStackView.replace(gameGridViewCpt)
    }

    StackView {
        id: gameStackView

        anchors.fill: parent
        initialItem: gameListViewCpt
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
    }

    ConfigDrawer {
        id: drawer
        width: parent.width/2
        height: parent.height
    }

    ViewSelectorDrawer {
        id: viewSelectorDrawer
        width: parent.width
        height: parent.height/10
        onListViewRequired: diplayListView()
        onGridViewRequired: diplayGridView()
    }

    Loader {
        id: gameDataLoader
        anchors.fill: parent
        Connections {
            target: gameDataLoader.item
            function onClosed() {
                gameDataLoader.sourceComponent
                        = undefined
            }
        }
    }
}

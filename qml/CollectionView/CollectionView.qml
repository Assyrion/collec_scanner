import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

import "../utils"

Pane {
    id: root

    padding: 0

    function diplayListView() {
        if(gameStackView.currentItem != gameListViewCpt) {
            gameStackView.replace(gameListViewCpt)
        }
    }

    function diplayGridView() {
        if(gameStackView.currentItem != gameGridViewCpt)
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

        replaceEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0; to: 1
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        replaceExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1; to: 0
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        GameListView { id: gameListViewCpt }
        GameGridView { id: gameGridViewCpt }
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

    ConfigMenuBar {
        id: configMenuBar
        anchors.centerIn: parent
        onListViewRequired: diplayListView()
        onGridViewRequired: diplayGridView()
    }
}

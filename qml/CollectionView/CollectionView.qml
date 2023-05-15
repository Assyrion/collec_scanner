import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

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
    signal showConfigRequired

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
                configMenuBar.opacity = !moving
            }
        }

        replaceEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0; to: 1
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }

        replaceExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1; to: 0
                duration: 400
                easing.type: Easing.InOutQuad
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

    ConfigMenuBar {
        id: configMenuBar
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 10
        onListViewRequired: root.diplayListView()
        onGridViewRequired: root.diplayGridView()
        onNewGameRequired:  root.showNewGameRequired()
        onConfigRequired:   root.showConfigRequired()

        Behavior on opacity {
            NumberAnimation { duration : 200 }
        }
    }
}

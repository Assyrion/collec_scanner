import QtQuick 6.3
import QtQuick.Controls 6.3
import QtQuick.Layouts 6.3

import "../utils"

Pane {
    id: root

    padding: 0

    function diplayListView() {
        gameStackView.replace(gameListViewCpt)
        collectionView = 0
    }

    function diplayGridView() {
        gameStackView.replace(gameGridViewCpt)
        collectionView = 1
    }

    function setCurrentIndex(sourceIdx) {
        var proxyModel = dbManager.currentProxyModel.subgameFilterProxyModel
        var idx = proxyModel.mapIndexFromSource(sourceIdx)
        gameStackView.currentItem.currentIndex = idx
    }

    signal showGameRequired(int idx)
    signal showNewGameRequired
    signal showConfigRequired
    signal menuClosing

    StackView {
        id: gameStackView

        width : parent.width-5
        height: parent.height-10
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5

        initialItem: {
            switch(collectionView) {
            case 1 : return gameGridViewCpt
            default: return gameListViewCpt
            }
        }

        Connections {
            target: gameStackView.currentItem
            function onShowGameRequired(idx) {
                root.showGameRequired(idx)
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
        onClosing: root.menuClosing()

        Behavior on opacity {
            NumberAnimation { duration : 200 }
        }
    }
}

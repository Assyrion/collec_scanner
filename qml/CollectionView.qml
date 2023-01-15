import QtQuick 2.8
import QtQuick.Controls 2.2
import Qt5Compat.GraphicalEffects
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

    Image {
        id: addGameBtn
        Component.onCompleted: {
            visible = true // fix bug on android
        }
        visible: false
        sourceSize.width: 55
        sourceSize.height: 55
        source: "qrc:/add_notag"
        Drag.active: maBtn.drag.active
        Drag.hotSpot.x: width/2
        Drag.hotSpot.y: height/2
        x: Math.random()*maBtn.drag.maximumX
        y: Math.random()*maBtn.drag.maximumY
        layer.enabled: maBtn.pressed
        layer.effect: BrightnessContrast {
            brightness: 0.5
            contrast: 0.5
        }
        MouseArea {
            id: maBtn
            anchors.fill: parent
            drag.target: parent
            drag.minimumX: 0
            drag.maximumX: root.width
                           -parent.width
            drag.minimumY: 0
            drag.maximumY: root.height
                           -parent.height
            onClicked: {
                showNewGameData()
            }
        }
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

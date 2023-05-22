import QtQuick 6.2
import QtQuick.Window 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

import "qml"
import "qml/utils"
import "qml/GameInfoView"
import "qml/CollectionView"
import "qml/BarcodeScannerView"

import ComManager 1.0
import FileManager 1.0
import ImageManager 1.0
import SQLTableModel 1.0

Window {
    id: mainWindow

    visible: true
    visibility: Window.AutomaticVisibility

    required property ComManager comManager
    required property FileManager fileManager
    required property ImageManager imageManager
    required property SQLTableModel sqlTableModel

    required property int collectionView

    ConfigDrawer {
        id: drawer
        width: parent.width * 0.7
        height: parent.height
        interactive: view.currentItem == cv
    }

    CoverProcessingPopup {
        id: coverProcessingPopup
        objectName: "coverProcessingPopup"
        width: 2*parent.width/3
        height: parent.height/5
        anchors.centerIn: parent
    }

    SwipeView {
        id: view

        anchors.fill: parent

        readonly property int defaultIndex: 1
        // Need to check when the item is fully loaded on the view
        property int viewX : contentItem.contentX
        onViewXChanged: {
            if(viewX % width == 0) {
                if(bsv == currentItem) {
                    bsv.barcodeScanner.startScanning()
                } else {
                    bsv.barcodeScanner.stopScanning()
                }
            }
        }

        currentIndex: defaultIndex

        GameSwipeView {
            id: gsv

            onClosed: view.setCurrentIndex(view.defaultIndex)
            onEditModeChanged: view.interactive = !editMode
        }
        CollectionView {
            id: cv

            onShowGameRequired: (idx) => showGame(idx)
            onShowNewGameRequired: showNewGame()
            onShowConfigRequired: showConfig()
        }
        BarcodeScannerView {
            id: bsv

            onShowGameRequired: (idx) => {
                                    showGame(idx)
                                    checkOwnedGame(idx)
                                }
            onShowNewGameRequired: (tag) => showNewGame(tag)
        }
    }

    function showGame(idx) {
        view.setCurrentIndex(0)
        gsv.currentIndex = idx
    }

    function showNewGame(tag = "") {
        view.setCurrentIndex(0)
        var obj = newGameCpt.createObject(gsv, {"tag": tag})
    }

    function showConfig() {
        drawer.open()
    }

    function checkOwnedGame(idx) {
        var modelIdx = sqlTableModel.index(idx, 7) // 7 is owned !
        if(sqlTableModel.data(modelIdx) === 0) {
            var cpt = Qt.createComponent("qml/utils/CSActionPopup.qml")
            if (cpt.status === Component.Ready) {
                var obj = cpt.createObject(gsv, {"contentText" : qsTr("You don't own this game, would you want to add it to your collection ?"),
                                     "width" : 2*gsv.width/3,
                                     "height": gsv.height/4,
                                     "x"     : gsv.width/6,
                                     "y"     : gsv.height/4+20})
                obj.accepted.connect(function() {
                    sqlTableModel.setData(modelIdx, 1)
                    gsv.currentIndex = idx
                })
                obj.refused.connect(function() {
                    view.setCurrentIndex(2)
                })
            }
        }
    }

    Component {
        id: newGameCpt
        NewGameView {
            width: mainWindow.width
            height: mainWindow.height
            onClosed: {
                view.setCurrentIndex(view.defaultIndex)
                destroy()
            }
            onSaved: (tag) => {
                         var idx = sqlTableModel.getIndexFiltered(tag)
                         showGame(idx)
                         destroy()
                     }
            Component.onCompleted:   view.interactive = false
            Component.onDestruction: view.interactive = true
        }
    }

    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.bottom: view.bottom
        anchors.horizontalCenter:
            parent.horizontalCenter
    }
}

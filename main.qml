import QtQuick 6.2
import QtQuick.Window 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

import "qml"
import "qml/utils"
import "qml/GameInfoView"
import "qml/CollectionView"
import "qml/BarcodeScannerView"

Window {
    id: mainWindow
    visible: true
    visibility: Window.AutomaticVisibility

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

            onShowGameRequired : (idx) => showGame(idx)
            onShowNewGameRequired : showNewGame()
        }
        BarcodeScannerView {
            id: bsv

            onShowGameRequired : (idx) => showGame(idx)
            onShowNewGameRequired : (tag) => showNewGame(tag)
        }
    }

    function showGame(idx) {
        view.setCurrentIndex(0)
        gsv.currentIndex = idx
    }

    function showNewGame(tag = "") {
        view.setCurrentIndex(0)
        var obj = cpt.createObject(mainWindow, {"tag": tag})
    }

    Component {
        id: cpt
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
        }
    }

    ConfigDrawer {
        id: drawer
        width: parent.width * 0.7
        height: parent.height
        interactive: view.currentItem == cv
    }

    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.bottom: view.bottom
        anchors.horizontalCenter:
            parent.horizontalCenter
    }

    CoverProcessingPopup {
        id: coverProcessingPopup
        objectName: "coverProcessingPopup"
        width: 2*parent.width/3
        height: parent.height/5
        anchors.centerIn: parent
    }
}

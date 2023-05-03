import QZXing 3.3
import QtQuick 6.2
import QtMultimedia
import QtQuick.Controls 6.2
import Qt.labs.platform 1.0

import "../utils"

Item {
    id: root

    property alias barcodeScanner: barcodeScanner

    signal showGameRequired(int idx)
    signal showNewGameRequired(string tag)

    TagUnknownPopup {
        id: tagUnknownPopup
        width : parent.width
        height: parent.height
        onRefused: () => {
            barcodeScanner.startScanning()
        }
        onAccepted: (tag) => {
            showNewGameRequired(tag)
        }
    }

    BarcodeScanner {
        id: barcodeScanner
        anchors.fill: parent
        onBarcodeFound: (barcode) => {
            barcodeScanner.stopScanning()
            var idx = sqlTableModel.getIndex(barcode)
            if(idx >= 0) {
                showGameRequired(idx)
            } else {
                tagUnknownPopup.show(barcode)
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        function showGameData(idx, tag, editMode) {
            loader.setSource("../GameInfoView/GameSwipeView.qml",
                             {"currentGameIndex": idx,
                              "currentGameTag" : tag,
                              "editMode": editMode})
        }
        Connections {
            target: loader.item
            function onClosed() {
                loader.sourceComponent = undefined
                barcodeScanner.startScanning()
            }
        }
    }
}

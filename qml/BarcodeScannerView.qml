import QZXing 3.3
import QtQuick 2.6
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import GameData 1.0
import "utils"

Item {
    id: root

    property alias barcodeScanner: barcodeScanner

    TagUnknownPopup {
        id: tagUnknownPopup
        width : parent.width
        height: parent.height
        onRefused: {
            barcodeScanner.startScanning()
        }
        onAccepted: {
            var game = GameDataMaker.createNew(tag)
            loader.showGameData(game, true)
        }
    }

    BarcodeScanner {
        id: barcodeScanner
        anchors.fill: parent
        onBarcodeFound: {
            barcodeScanner.stopScanning()
            var game = sqlTableModel.get(barcode)
            if(game) {
                loader.showGameData(game, false)
            } else {
                tagUnknownPopup.show(barcode)
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        function showGameData(game, editMode) {
            loader.setSource("GameDataView.qml",
                             {"game"    : game,
                              "editMode": editMode})
        }
        Connections {
            target: loader.item
            onClosed: {
                loader.sourceComponent = undefined
                barcodeScanner.startScanning()
            }
        }
    }
}

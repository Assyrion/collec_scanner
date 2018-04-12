import QZXing 2.3
import QtQuick 2.6
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import GameData 1.0
import "utils"

Item {
    id: root

    property alias barcodeScanner: barcodeScanner

    function showGameData(game) {
        gameDataLoader.setSource("ViewGameData.qml",
                                 {"game": game})
    }

    PopupTagUnknown {
        id: popupTagUnknown
        width : parent.width
        height: parent.height
        onRefused: {
            barcodeScanner.startScanning()
        }
        onAccepted: {
            var game = GameDataMaker.createNew(tag)
            showGameData(game)
        }
    }

    BarcodeScanner {
        id: barcodeScanner
        anchors.fill: parent
        onBarcodeFound: {
            barcodeScanner.stopScanning()
            var game = dbManager.getEntry(barcode)
            if(game) {
                showGameData(game)
            } else {
                popupTagUnknown.show(barcode)
            }
        }
    }

    Loader {
        id: gameDataLoader
        anchors.fill: parent
        Connections {
            target: gameDataLoader.item
            onClosed: {
                gameDataLoader.sourceComponent = undefined
                barcodeScanner.startScanning()
            }
        }
    }
}

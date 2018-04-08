import QZXing 2.3
import QtQuick 2.6
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import GameData 1.0
import "utils"

Item {
    id: root

    signal newGameCreationRequired(string tag)
    signal gameShowInfo(GameData game)
    signal backToMenuRequired

    Component.onCompleted: {
        barcodeScanner.startScanning()
    }

    PopupTagUnknown {
        id: popupTagUnknown
        width : parent.width
        height: parent.height
        onRefused: {
            barcodeScanner.startScanning()
        }
        onAccepted: {
            newGameCreationRequired(tag)
        }
    }

    BarcodeScanner {
        id: barcodeScanner
        anchors.fill: parent
        onBarcodeFound: {
            barcodeScanner.stopScanning()
            var game = dbManager.getEntry(barcode)
            if(game) {
                gameDataLoader.setSource("ViewGameData.qml", {"initial_game": game})
            } else {
                popupTagUnknown.show(barcode)
            }
        }
    }

    CSButton {
        id: returnBtn
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        text: "Menu"
        onClicked: {
            backToMenuRequired()
        }
    }

    Loader {
        id: gameDataLoader
        anchors.fill: parent
        Connections {
            target: gameDataLoader.item ?
                        gameDataLoader.item : null
            onClosed: {
                gameDataLoader.sourceComponent = undefined
                barcodeScanner.startScanning()
            }
        }
    }
}

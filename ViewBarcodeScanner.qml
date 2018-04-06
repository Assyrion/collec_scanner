import QZXing 2.3
import QtQuick 2.6
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import GameData 1.0

Item {
    id: root

    signal newGameCreationRequired(string tag)
    signal gameShowInfo(GameData game)
    signal backToMenuRequired

    Component.onCompleted: {
        barcodeScanner.startScanning()
    }

    Button {
        id: returnBtn
        anchors.top: parent.top
        anchors.left: parent.left
        text: "Menu"
        onClicked: {
            backToMenuRequired()
        }
    }

    PopupTagUnknown {
        id: popupTagUnknown
        width: parent.width/2
        height: parent.height/2
        x: width/2
        y: height/2
        onRefused: {
            barcodeScanner.startScanning()
        }
        onAccepted: {
            newGameCreationRequired(tag)
        }
    }

    PopupGameData {
        id: popupGameData
        width: parent.width
        height: parent.height
    }

    BarcodeScanner {
        id: barcodeScanner
        anchors.fill: parent
        onBarcodeFound: {
            var game = dbManager.getEntry(barcode)
            if(game) {
                popupGameData.show(game)
            } else {
                popupTagUnknown.show(barcode)
            }
        }
    }
}

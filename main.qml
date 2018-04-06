import QtQuick 2.6
import QtQuick.Window 2.2

Window {
    id: root
    visible: true
    visibility: Window.AutomaticVisibility
    //    title: qsTr("Hello World")
    height:1000
    width: 1000

    Rectangle {
        id: bckgnd
        anchors.fill: parent
        color: "black"
    }

    AENPopup {
        id: popup
        width: parent.width/2
        height: parent.height/2
        x: width/2
        y: height/2
        onRefused: {
            barcodeScanner.startScanning()
        }
    }

    BarcodeScanner {
        id: barcodeScanner
        anchors.fill: parent
        onBarcodeFound: {
            stopScanning()
            if(dbManager.getEntry(barcode) === "") {
                popup.open()
            }
        }
    }
}

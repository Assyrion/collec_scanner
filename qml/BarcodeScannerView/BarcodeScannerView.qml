import QZXing 3.3
import QtQuick 6.2
import QtMultimedia
import QtQuick.Controls 6.2
import Qt.labs.platform 1.0

import "../utils/PopupMaker.js" as PopupMaker

Item {
    id: root
    
    property alias barcodeScanner: barcodeScanner
    
    signal showGameRequired(int idx)
    signal showNewGameRequired(string tag)
    
    function showUnknownGame(tag) {
        var obj = PopupMaker.showUnknownGame(root, tag)

        obj.refused.connect(function() {
            barcodeScanner.startScanning()
        })
        obj.accepted.connect(function() {
            showNewGameRequired(tag)
        })
    }

    function showFilteredGame(tag, idx) {
        var obj = PopupMaker.showFilteredGame(root, tag)

        obj.refused.connect(function() {
            barcodeScanner.startScanning()
        })
        obj.accepted.connect(function() {
            sqlTableModel.removeFilter()
            showGameRequired(idx)
        })
    }
    
    BarcodeScanner {
        id: barcodeScanner
        anchors.fill: parent
        onBarcodeFound: (barcode) => {
                            barcodeScanner.stopScanning()
                            var idx = sqlTableModel.getIndexFiltered(barcode)
                            if(idx >= 0) {
                                showGameRequired(idx)
                            } else {
                                idx = sqlTableModel.getIndexNotFiltered(barcode)
                                if(idx >= 0) {
                                    showFilteredGame(barcode, idx)
                                } else {
                                    showUnknownGame(barcode)
                                }
                            }
                        }
    }
}


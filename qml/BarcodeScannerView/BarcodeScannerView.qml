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

    function showFilteredGame(tag) {
        var obj = PopupMaker.showFilteredGame(root, tag)

        obj.refused.connect(function() {
            barcodeScanner.startScanning()
        })
        obj.accepted.connect(function() {
            sortFilterProxyModel.resetFilter()
            var idx = sortFilterProxyModel.getIndexFiltered(tag)
            showGameRequired(idx)
        })
    }
    
    BarcodeScanner {
        id: barcodeScanner
        anchors.fill: parent
        onBarcodeFound: (barcode) => {
                            barcodeScanner.stopScanning()
                            var idx_f = sortFilterProxyModel.getIndexFiltered(barcode)
                            if(idx_f >= 0) {
                                showGameRequired(idx_f)
                            } else {
                                var idx_nf = sortFilterProxyModel.getIndexNotFiltered(barcode)
                                if(idx_nf >= 0) {
                                    showFilteredGame(barcode)
                                } else {
                                    showUnknownGame(barcode)
                                }
                            }
                        }
    }
}


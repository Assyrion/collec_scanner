import QZXing 3.3
import QtQuick 6.2
import QtMultimedia
import QtQuick.Controls 6.2
import Qt.labs.platform 1.0

Item {
    id: root
    
    property alias barcodeScanner: barcodeScanner
    
    signal showGameRequired(int idx)
    signal showNewGameRequired(string tag)
    
    
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
                                    loader.showFilteredGame(barcode, idx)
                                } else {
                                    loader.showUnknownGame(barcode)
                                }
                            }
                        }
    }
    
    Loader {
        id: loader
        
        function showUnknownGame(tag) {
            loader.setSource("../utils/CSActionPopup.qml",
                             { "contentText" : qsTr("Game with tag = %1 is new.<br><br>Add it ?").arg(tag),
                                 "width" : root.width,
                                 "height": root.height})
            
            loader.item.refused.connect(  function() { barcodeScanner.startScanning() })
            loader.item.accepted.connect( function() { showNewGameRequired(tag) })
        }
        
        function showFilteredGame(tag, idx) {
            loader.setSource("../utils/CSActionPopup.qml",
                             { "contentText" : qsTr("Game with tag = %1 exists but has been filtered.<br><br>Remove filter and show it ?").arg(tag),
                                 "width" : root.width,
                                 "height": root.height})
            
            loader.item.refused.connect(  function() { barcodeScanner.startScanning() })
            loader.item.accepted.connect( function() {
                sqlTableModel.filterByTitle("") // remove filter
                showGameRequired(idx)
            })
        }
    }
}

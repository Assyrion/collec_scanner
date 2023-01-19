import QtQuick 6.2
import QtQuick.Window 2.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 1.3
import GameData 1.0
import "qml"
import "qml/utils"

Window {
    id: mainWindow
    visible: true
    visibility: Window.AutomaticVisibility

    width : Screen.desktopAvailableWidth / 8
    height: Screen.desktopAvailableHeight / 2

    SwipeView {
        id: view
        anchors.fill: parent

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

        CollectionView {
            id: cl
        }
        BarcodeScannerView {
            id: bsv
        }
    }
    PageIndicator {
        id: indicator

        count: view.count
        currentIndex: view.currentIndex

        anchors.bottom: view.bottom
        anchors.horizontalCenter:
            parent.horizontalCenter
    }
}

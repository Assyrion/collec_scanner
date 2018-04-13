import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import GameData 1.0
import "qml"
import "qml/utils"

Window {
    id: mainWindow
    visible: true
    visibility: Window.AutomaticVisibility

    height: 568
    width : 360

    function showError(err) {
        pop.lol = err
        pop.open()
    }

    Popup {
        id: pop

        property alias lol: lol.text
        Text {
            id: lol
            color: "white"
        }
    }

    SwipeView {
        id: view
        anchors.fill: parent

        // Need to check when the item is fully loaded on the view
        property int contentX : contentItem.contentX
        onContentXChanged: {
            if(contentX % width == 0) {
                if(vbs == currentItem) {
                    vbs.barcodeScanner.startScanning()
                } else {
                    vbs.barcodeScanner.stopScanning()
                }
            }
        }

        ViewGameList {
            id: vgl
        }
        ViewBarcodeScanner {
            id: vbs
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

import QtQuick 6.2
import QtQuick.Window 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2

import "qml"
import "qml/utils"
import "qml/GameInfoView"
import "qml/CollectionView"
import "qml/BarcodeScannerView"

Window {
    id: mainWindow
    visible: true
    visibility: Window.AutomaticVisibility

    width : Screen.desktopAvailableWidth /*/ 8*/
    height: Screen.desktopAvailableHeight /*/ 2*/

    SwipeView {
        id: view
        anchors.fill: parent

        readonly property int defaultIndex: 1
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

        currentIndex: defaultIndex

        GameSwipeView {
            id: gsv

            onClosed: view.currentIndex = view.defaultIndex
            onEditModeChanged: view.interactive = !editMode
        }
        CollectionView {
            id: cv

            onShowGameRequired : (idx) => {
                                     view.currentIndex = 0
                                     gsv.currentIndex = idx
                                 }
            onShowNewGameRequired :  () => {
                                         view.interactive = false
                                         var cpt = Qt.createComponent("qml/GameInfoView/NewGameView.qml")
                                         if (cpt.status === Component.Ready) {
                                             var obj = cpt.createObject(cv, {
                                                                            "width": view.width,
                                                                            "height": view.height
                                                                        })
                                             obj.closed.connect(function() {
                                                 view.interactive = true
                                                 obj.destroy()
                                             })
                                         }
                                     }
        }
        BarcodeScannerView {
            id: bsv

            onShowGameRequired : (idx) => {
                                     view.currentIndex = 0
                                     gsv.currentIndex = idx
                                 }
            onShowNewGameRequired : (tag) => {
                                        view.interactive = false
                                        var cpt = Qt.createComponent("qml/GameInfoView/NewGameView.qml")
                                        if (cpt.status === Component.Ready) {
                                            var obj = cpt.createObject(bsv, {
                                                                           "tag": tag,
                                                                           "width": view.width,
                                                                           "height": view.height
                                                                       })
                                            obj.closed.connect(function() {
                                                view.interactive = true
                                                obj.destroy()
                                            })
                                        }
                                    }
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

    CoverProcessingPopup {
        id: coverProcessingPopup
        objectName: "coverProcessingPopup"
        width: 2*parent.width/3
        height: parent.height/5
        anchors.centerIn: parent
    }
}

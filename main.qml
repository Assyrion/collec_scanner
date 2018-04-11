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

    SwipeView {
        id: view
        anchors.fill: parent

        ViewBarcodeScanner {
            id: vsb
        }
        ViewGameList {
            id: vgl
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

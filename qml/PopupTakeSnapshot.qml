import QtQuick 2.6
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import "utils"

Popup {
    id: root

    Component.onCompleted:  {
//        cameraOutput.imageCaptured.connect()
    }

    onOpened: {
        loader.sourceComponent = cameraOutputCpt
    }

    onClosed: {
        loader.sourceComponent = undefined
    }

    padding:  0

    contentItem : Pane {
        Loader {
            id: loader
            anchors.fill: parent
        }

        Component {
            id: cameraOutputCpt
            CSCameraOutput {
                id: cameraOutput
                onImageCaptured: {
                    snapshot.source = preview
                }
            }
        }

        CSButton {
            text : "Take pic"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                loader.item.capture()
            }
        }

        Image {
            id: snapshot
            width: parent.width/4
            height: parent.height/4
            anchors.left: parent.left
            anchors.top: parent.top
        }
    }
}

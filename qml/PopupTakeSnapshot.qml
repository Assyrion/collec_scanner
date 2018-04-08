import QtQuick 2.8
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import "utils"

Popup {
    id: root
    Component.onCompleted:  {
        open()
    }

    property var boundImg

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
            width: 13.7*height/17
            height: 2*parent.height/3
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter:
                parent.horizontalCenter
        }

        Component {
            id: cameraOutputCpt
            CSCameraOutput {
                id: cameraOutput
                fillMode:
                    VideoOutput.PreserveAspectCrop
                onImageCaptured: {
//                    snapshot.source = preview
                }
            }
        }

        CSButton {
            text : "Take pic"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter:
                parent.horizontalCenter
            onClicked: {
//                loader.item.capture()
                loader.item.grabToImage(function(result) {
                    boundImg.grabResult = result;
                });
            }
        }
    }
}

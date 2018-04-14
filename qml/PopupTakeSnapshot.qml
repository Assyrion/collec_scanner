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
        loader.active = true
    }

    onClosed: {
        loader.active = false
    }

    padding:  0
    modal: true

    contentItem : Pane {
        Loader {
            id: loader
            active: false
            width: 13.7*height/17
            height: 2*parent.height/3
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter:
                parent.horizontalCenter
            sourceComponent: Component {
                CSCameraOutput {
                    id: cameraOutput
                    fillMode:
                        VideoOutput.PreserveAspectCrop
                    onImageCaptured: {
    //                    snapshot.source = preview
                    }
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

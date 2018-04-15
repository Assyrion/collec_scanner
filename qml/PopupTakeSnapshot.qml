import QtQuick 2.8
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
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

    topPadding: 4
    bottomPadding: 4
    leftPadding: 1
    rightPadding: 1

    modal: true
    dim: false

    background: DropShadow {}

    contentItem : Pane {
        Loader {
            id: loader
            active: false
            width: 13.7*height/17
            height: 6*parent.height/7-2
            anchors.top: parent.top
            anchors.topMargin: -12
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

        Button {
            text : "Take pic"
            anchors.bottom: parent.bottom
            width: 2*implicitWidth
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

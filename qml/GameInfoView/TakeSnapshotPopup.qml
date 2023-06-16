import QtQuick 6.2
import QtMultimedia 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects

import "../utils"

Popup {
    id: root

    required property double coverRatio

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

    topPadding: 1
    bottomPadding: 1
    leftPadding: 1
    rightPadding: 1

    modal: true
    dim: false

    background: RectangularGlow {
        glowRadius: 10
        spread: 0
        color: "#222222"
        cornerRadius: 0
    }

    contentItem : Pane {
        Loader {
            id: loader
            active: false
            width: height * root.coverRatio
            height: 5*parent.height/6 - 10
            scale: width > parent.width ? (parent.width/width) : 1
            anchors.top: parent.top
            anchors.topMargin: -12
            anchors.horizontalCenter:
                parent.horizontalCenter
            sourceComponent: Component {
                CSCameraOutput {
                    id: cameraOutput
                    camera.exposureMode:
                        Camera.ExposurePortrait
                    videoOutput.fillMode:
                        VideoOutput.PreserveAspectCrop
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
                loader.item.grabToImage(function(result) {
                    boundImg.imgData = result.image;
                    boundImg.imgUrl  = result.url;
                }, Qt.size(loader.width*2,
                           loader.height*2));
            }
        }
    }
}

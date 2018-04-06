import QtQuick 2.6
import QtQuick.Window 2.2
import QtMultimedia 5.8
import Qt.labs.platform 1.0
import QZXing 2.3

Window {
    id: root
    visible: true
//    visibility: Window.FullScreen
//    title: qsTr("Hello World")
    height:1000
    width: 1000
    Rectangle {
        id: bckgnd
        anchors.fill: parent
        color: "black"
    }
    Text {
        id: info
        color: "white"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        font.pointSize: 15
        z: 2
    }

    VideoOutput {
        id: output
        anchors.fill: parent;
        autoOrientation: true
        source: camera
        filters: [ zxingFilter ]

        MouseArea {
            anchors.fill: parent;
            propagateComposedEvents : true
            onClicked: camera.imageCapture.capture();
            onDoubleClicked: root.close()
        }

        Camera {
            id: camera
            position: Camera.BackFace
            captureMode: Camera.CaptureStillImage
            imageProcessing {
                whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
            }
            focus {
                focusMode: Camera.FocusContinuous
                focusPointMode: Camera.FocusPointAuto
            }
            exposure {
                exposureMode: Camera.ExposureAuto
            }
            imageCapture {
                onImageCaptured:{
                    snapshot.source = preview
                    decoder.decodeImageQML(snapshot);
                }
            }
        }
    }

//    Image {
//        id: snapshot
//        width: output.width/4
//        height: output.height/4
//        anchors.left: output.left
//        anchors.top: output.top
//        onSourceChanged: {
//            fadeOut.start()
//        }
//        opacity: 0

//        SequentialAnimation {
//            id: fadeOut
//            NumberAnimation {
//                target: snapshot
//                property: "opacity"
//                from: 0; to: 1
//                duration: 100
//            }
//            NumberAnimation {
//                target: snapshot
//                property: "opacity"
//                from: 1; to: 0
//                duration: 1000
//            }
//        }
//    }

    QZXingFilter {
        id: zxingFilter
        captureRect: {
            // setup bindings
            output.contentRect;
            output.sourceRect;
            return output.mapRectToSource(output.mapNormalizedRectToItem(Qt.rect(0.25, 0.25, 0.5, 0.5)));
        }

        decoder {
            enabledDecoders: QZXing.DecoderFormat_EAN_13
            onTagFound: {
                info.text = tag + " | " + decoder.foundedFormat() + " | "
                        + StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + " | " + fileManager.checkEntry(tag);
                camera.stop()
                if(!fileManager.checkEntry(tag)) {
                    fileManager.addEntry(tag, "Dmc Devil May Cry")
                } else {
                    info.text = fileManager.getEntry(tag)
                }
            }

            tryHarder: false
        }
    }
}

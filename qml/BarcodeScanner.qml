import QZXing 2.3
import QtQuick 2.6
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

Rectangle {
    id: root

    signal barcodeFound(string barcode)

    function startScanning() {
        camera.start()
    }

    function stopScanning() {
        camera.stop()
    }

    color: "black"

    VideoOutput {
        id: output

        anchors.fill: parent
        autoOrientation: true
        filters: [ zxingFilter ]

        source: Camera {
            id: camera
            position:    Camera.BackFace
            captureMode: Camera.CaptureStillImage
            imageProcessing {
                whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
            }
            focus {
                focusMode:      Camera.FocusContinuous
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

    Image {
        id: snapshot
        width: parent.width/4
        height: parent.height/4
        anchors.left: parent.left
        anchors.top: parent.top
        function show() {
            fadeInOut.start()
        }
        SequentialAnimation on opacity {
            id: fadeInOut
            NumberAnimation {from: 0; to: 1; duration: 100 }
            NumberAnimation {from: 1; to: 0; duration: 1000}
        }
    }

    QZXingFilter {
        id: zxingFilter
        captureRect: {
            output.contentRect;
            output.sourceRect;
            return output.mapRectToSource(output.mapNormalizedRectToItem(Qt.rect(0.25, 0.25, 0.5, 0.5)));
        }

        decoder {
            enabledDecoders: QZXing.DecoderFormat_EAN_13
            onTagFound: {
                barcodeFound(tag)
            }

            tryHarder: false
        }
    }
}

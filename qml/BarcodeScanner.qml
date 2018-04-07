import QZXing 2.3
import QtQuick 2.6
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import "utils"

Rectangle {
    id: root

    signal barcodeFound(string barcode)

    function startScanning() {
        cameraOutput.camera.start()
    }

    function stopScanning() {
        cameraOutput.camera.stop()
    }

    color: "black"

    CSCameraOutput {
        id: cameraOutput

        anchors.fill: parent
        filters: [ zxingFilter ]
        onImageCaptured:{
            snapshot.source = preview
            decoder.decodeImageQML(preview);
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
            cameraOutput.contentRect;
            cameraOutput.sourceRect;
            return cameraOutput.mapRectToSource(cameraOutput.mapNormalizedRectToItem(Qt.rect(0.25, 0.25, 0.5, 0.5)));
        }

        decoder {
            enabledDecoders: QZXing.DecoderFormat_EAN_13
                           | QZXing.DecoderFormat_EAN_8
            onTagFound: {
                barcodeFound(tag)
            }

            tryHarder: false
        }
    }
}

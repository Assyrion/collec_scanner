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

//    Rectangle {
//        x:cameraOutput.contentRect.x
//        y:cameraOutput.contentRect.y
//        width: zxingFilter.captureRect.width
//        height: zxingFilter.captureRect.height
//        color: "red"
//        opacity: 0.5
//    }

    QZXingFilter {
        id: zxingFilter
        captureRect: {
            cameraOutput.contentRect;
            cameraOutput.sourceRect;
            var rect = Qt.rect(0.25, 0.25, 0.5, 0.5)
            var normalizedRect = cameraOutput.mapNormalizedRectToItem(rect)
            return cameraOutput.mapRectToSource(normalizedRect)
        }

        decoder {
            enabledDecoders: QZXing.DecoderFormat_EAN_13
//                           | QZXing.DecoderFormat_EAN_8
            onTagFound: {
                barcodeFound(tag)
            }

            tryHarder: false
        }
    }
}

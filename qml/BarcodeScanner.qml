import QZXing 3.3
import QtQuick 2.6
import QtMultimedia
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import "utils"

Rectangle {
    id: root

    signal barcodeFound(string barcode)

    function startScanning() {
        loader.active = true
    }

    function stopScanning() {
        loader.active = false
    }

    color: "black"

    Loader {
        id: loader
        active: false
        anchors.fill: parent
        sourceComponent: Component {
            CSCameraOutput {
                id: cameraOutput
//                camera.filters: [ zxingFilter ]
                onImageCaptured:{
                    snapshot.source = preview
                    decoder.decodeImageQML(preview);
                }
            }
        }
    }

    QZXingFilter {
        id: zxingFilter
        captureRect: {
            loader.item.contentRect;
            loader.item.sourceRect;
            var rect = Qt.rect(0.25, 0.25, 0.5, 0.5)
            var normalizedRect = loader.item.mapNormalizedRectToItem(rect)
            return loader.item.mapRectToSource(normalizedRect)
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

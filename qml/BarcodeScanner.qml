import QZXing 3.3
import QtQuick 6.2
import QtMultimedia
import QtQuick.Controls 6.2
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
            rec.x = root.width * 0.25
            rec.y = root.height * 0.25
            rec.width = root.width * 0.5
            rec.height = root.height * 0.5
            return Qt.rect(root.width * 0.25,
                           root.height * 0.25,
                           root.width * 0.5,
                           root.height * 0.5)
        }

        videoSink:  loader.item.videoOutput.videoSink
        decoder {
            enabledDecoders: QZXing.DecoderFormat_EAN_13
                             | QZXing.DecoderFormat_QR_CODE
            onTagFound: {
                textLOL.text = qsTr(tag + " found")
                barcodeFound(tag)
            }
            tryHarder: false
        }
    }
    Text {
        id: textLOL
        anchors.centerIn: parent
        color: "red"
    }
    Rectangle {
        id: rec
        color : "blue"
        opacity : 0.3
    }
}

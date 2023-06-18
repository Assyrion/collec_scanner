import QtQuick 6.2
import QtMultimedia
import QtQuick.Controls 6.2
import QZXing 3.3

import "../utils"

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
            Item {
                CSCameraOutput {
                    id: cameraOutput
                    anchors.fill: parent
                }
                QZXingFilter {
                    id: zxingFilter
                    captureRect: {
                        var rec = cameraOutput.videoOutput.sourceRect
                        return Qt.rect(rec.width * 0.125, rec.height * 0.25,
                                       rec.width * 0.75,  rec.height * 0.5)

                    }

                    videoSink:  cameraOutput.videoOutput.videoSink
                    orientation: cameraOutput.videoOutput.orientation

                    decoder {
                        enabledDecoders: QZXing.DecoderFormat_EAN_13
                        onTagFound: (tag) => barcodeFound(tag)
                        tryHarder: false
                    }
                }
                Rectangle {
                    color: "transparent"
                    border.color: "yellow"
                    border.width: 1
                    width: root.width * 0.75
                    height: root.height * 0.5
                    x: root.width/2 - width/2
                    y: root.height/2 - height/2
                }
            }
        }
    }
}

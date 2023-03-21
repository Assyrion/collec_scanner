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
            Item {
                CSCameraOutput {
                    id: cameraOutput
                    anchors.fill: parent
                    onImageCaptured:{
                        snapshot.source = preview
                        decoder.decodeImageQML(preview);
                    }
                }
                QZXingFilter {
                    id: zxingFilter
                    captureRect: {
                        cameraOutput.videoOutput.sourceRect;
                        return Qt.rect(cameraOutput.videoOutput.sourceRect.width * 0.25,
                                       cameraOutput.videoOutput.sourceRect.height * 0.25,
                                       cameraOutput.videoOutput.sourceRect.width * 0.5,
                                       cameraOutput.videoOutput.sourceRect.height * 0.5)

                    }

                    videoSink:  cameraOutput.videoOutput.videoSink
                    orientation: cameraOutput.videoOutput.orientation

                    decoder {
                        enabledDecoders: QZXing.DecoderFormat_EAN_13
                        onTagFound: {
                            barcodeFound(tag)
                        }
                        tryHarder: false
                    }
                }
            }
        }
    }
}

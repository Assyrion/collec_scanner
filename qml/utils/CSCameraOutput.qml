import QtQuick 2.8
import QtMultimedia 5.8
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import QtGraphicalEffects 1.0

VideoOutput {
    id: root

    signal imageCaptured(string preview)
    property alias camera: camera
    focus: visible
    function capture() {
        camera.imageCapture.capture()
    }

    autoOrientation: true

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
                root.imageCaptured(preview)
            }
        }
    }
}

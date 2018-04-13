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

    Component.onCompleted: {
        camera.start()
    }
    Component.onDestruction: {
        camera.stop()
    }

    autoOrientation: true

    source: Camera {
        id: camera
        position:    Camera.BackFace
        cameraState: Camera.UnloadedState
        captureMode: Camera.CaptureStillImage
        focus {
            focusMode:      Camera.FocusContinuous
            focusPointMode: Camera.FocusPointAuto
        }
        imageProcessing {
            whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
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

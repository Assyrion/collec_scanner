import QtQuick 2.8
import QtMultimedia
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import Qt5Compat.GraphicalEffects

Item {
    id: root

    signal imageCaptured(string preview)
    property alias camera: mainCamera
    //    focus: visible
    function capture() {
        camera.imageCapture.capture()
    }

    Component.onCompleted: {
        camera.start()
    }
    Component.onDestruction: {
        camera.stop()
    }

    MediaDevices {
        id: deviceList
    }

    Camera {
        id: mainCamera
        //        position:    Camera.BackFace
        //        cameraState: Camera.UnloadedState
        //        captureMode: Camera.CaptureStillImage

        cameraDevice: deviceList.defaultVideoInput
        focusMode: Camera.FocusModeAutoNear

        //        focus {
        //            focusMode:      Camera.FocusContinuous
        //            focusPointMode: Camera.FocusPointAuto
        //        }
        //        imageProcessing {
        //            whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
        //        }
        //        exposure {
        //            exposureMode: Camera.ExposureAuto
        //        }
    }

    VideoOutput {
        id: mainVideoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
    }

    CaptureSession {
        videoOutput : mainVideoOutput
        camera: mainCamera

        onImageCaptureChanged: root.imageCaptured(preview)
    }
}

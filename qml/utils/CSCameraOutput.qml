import QtQuick 6.2
import QtMultimedia
import QtQuick.Controls 6.2
import Qt.labs.platform 1.0
import Qt5Compat.GraphicalEffects
import QZXing 3.3

Item {
    id: root

    signal imageCaptured(string preview)

    property alias camera: mainCamera
    property alias videoOutput: mainVideoOutput

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
        cameraDevice:  deviceList.defaultVideoInput
//                cameraState: Camera.UnloadedState
        //        captureMode: Camera.CaptureStillImage

        focusMode: Camera.FocusModeAutoNear
        whiteBalanceMode: Camera.WhiteBalanceFlash
        exposureMode: Camera.ExposureBarcode
    }

    VideoOutput {
        id: mainVideoOutput
        anchors.fill: parent
        fillMode: VideoOutput.Stretch
    }

    CaptureSession {
        videoOutput : mainVideoOutput
        camera: mainCamera

        onImageCaptureChanged: root.imageCaptured(preview)
    }
}

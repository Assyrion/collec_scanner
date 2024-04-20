import QtQuick 6.3
import QtMultimedia
import QtQuick.Controls 6.3

Item {
    id: root

    property alias camera: mainCamera
    property alias videoOutput: mainVideoOutput

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
        cameraDevice: deviceList.defaultVideoInput
        focusMode: Camera.FocusModeAutoNear
        exposureMode: Camera.ExposureBarcode
    }

    VideoOutput {
        id: mainVideoOutput
        anchors.fill: parent
    }

    CaptureSession {
        videoOutput : mainVideoOutput
        camera: mainCamera
    }
}

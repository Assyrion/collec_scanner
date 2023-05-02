import QtQuick 6.2
import Qt5Compat.GraphicalEffects

Image {
    id: root

    property double maxWidth
    property double maxHeight

    signal clicked

    sourceSize.width: 55
    sourceSize.height: 55
    source: "qrc:/add_notag"
    Drag.active: maBtn.drag.active
    Drag.hotSpot.x: width/2
    Drag.hotSpot.y: height/2
    x: Math.random()*maBtn.drag.maximumX
    y: Math.random()*maBtn.drag.maximumY
    layer.enabled: maBtn.pressed
    layer.effect: BrightnessContrast {
        brightness: 0.5
        contrast: 0.5
    }
    MouseArea {
        id: maBtn
        anchors.fill: parent
        drag.target: parent
        drag.minimumX: 0
        drag.maximumX: maxWidth - parent.width
        drag.minimumY: 0
        drag.maximumY: maxHeight - parent.height
        onClicked: root.clicked()
    }
}

import QtQuick 2.8
import QtGraphicalEffects 1.0

Item {
    id: root

    signal clicked
    property alias source: pic.source
    property var grabResult
    onGrabResultChanged: {
        if(grabResult)
            source = grabResult.url
    }

    implicitWidth: pic.width

    Component.onCompleted: {
        mouseArea.clicked.connect(clicked)
    }

    RectangularGlow {
        id: effect
        anchors.fill: pic
        glowRadius: 10
        spread: 0.2
        color: "white"
        cornerRadius: maskRec.radius + glowRadius
    }

    Rectangle {
        id: maskRec
        visible: false
        anchors.fill: pic
        radius : 25
    }

    Image {
        id: pic
        visible: false
        height: parent.height
        cache: false
        mipmap: true
        smooth: true
        fillMode: Image.PreserveAspectFit
    }


    OpacityMask {
        id: opacityMask
        anchors.fill: pic
        source: pic
        maskSource: maskRec
        layer.enabled: !enabled
        layer.effect: Colorize {
            saturation: 0
            lightness: 0
            hue: 0
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

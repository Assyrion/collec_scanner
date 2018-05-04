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

    Component.onCompleted: {
        mouseArea.clicked.connect(clicked)
    }

    implicitWidth: pic.width

    RectangularGlow {
        id: effect
        anchors.fill: pic
        glowRadius: 7
        spread: 0.2
        color: "black"
        cornerRadius: maskRec.radius
                      + glowRadius
    }

    Rectangle {
        id: maskRec
        visible: false
        anchors.fill: pic
        radius : 10
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
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

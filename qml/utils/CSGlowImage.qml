import QtQuick 2.8
import QtGraphicalEffects 1.0

Item {
    id: root

    signal clicked
    property string source

    implicitWidth: pic.width

    Component.onCompleted: {
        mouseArea.clicked.connect(clicked)
    }

    opacity: enabled ? 1 : 0.8

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
        source: root.source == "" ? "qrc:/no_pic"
                                  : "file:///"+root.source
    }

    OpacityMask {
        anchors.fill: pic
        source: pic
        maskSource: maskRec
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

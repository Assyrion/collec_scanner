import QtQuick 6.2
import Qt5Compat.GraphicalEffects

Item {
    id: root

    signal clicked

    property var imgData: null
    property url imgUrl

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
        source: root.imgUrl
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
        onClicked: (mouse) => {
            root.clicked()
        }
    }
}

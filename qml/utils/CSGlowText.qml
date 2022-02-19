import QtQuick 2.8
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property alias font: contentText.font
    property alias text: contentText.text

    width: contentText.implicitWidth
           + 10

    RectangularGlow {
        id: background
        width:
            contentText.paintedWidth
            + 10
        height:
            font.pointSize + 10
        anchors.verticalCenter:
            parent.verticalCenter
        color: "black"
        glowRadius: 20
        spread : 0.2
        opacity: 0.5
    }
    Text {
        id: contentText
        anchors.left: background.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.verticalCenter:
            background.verticalCenter
        elide: Text.ElideRight
        font.family: "Roboto"
        color: "white"
    }
}

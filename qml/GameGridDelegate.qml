import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects
import GameData 1.0
import "utils"

Item {
    id: root

    signal clicked

    // because connect function does not work anymore with Qt 6.5 ?
    Connections {
        target: mouseArea
        function onClicked() { clicked() }
    }

    Image {
        id: mainImg
        width: parent.width
        fillMode: Image.PreserveAspectFit
        source: imageManager ? imageManager.getFrontPic(tag)
                             : "qrc:/no_pic"
        cache: false
        mipmap: true
        smooth: true

        MouseArea {
            id: mouseArea
            anchors.fill: parent
        }
    }
}

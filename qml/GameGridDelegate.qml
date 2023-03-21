import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects
import GameData 1.0
import "utils"

Item {
    id: root
    signal clicked

    Component.onCompleted: {
        mainImgMa.clicked.connect(clicked)
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
            id: mainImgMa
            anchors.fill: parent
        }
    }
}

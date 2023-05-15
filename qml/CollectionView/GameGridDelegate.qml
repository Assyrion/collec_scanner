import QtQuick 6.2
import QtQuick.Controls 6.2

Item {
    id: root

    signal clicked

    implicitHeight: mainImg.height + 10

    Image {
        id: mainImg
        width: parent.width
        fillMode: Image.PreserveAspectFit
        source: imageManager.getFrontPic(tag)
        cache: false
        mipmap: true
        smooth: true

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: root.clicked()
        }
    }
}

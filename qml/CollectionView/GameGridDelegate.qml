import QtQuick 6.3
import QtQuick.Controls 6.3
import Qt5Compat.GraphicalEffects

Item {
    id: root

    signal clicked
    property string subfolderPic: platformName + "/" + model.tag

    Image {
        id: frontPicImg
        width: parent.width
        anchors.verticalCenter:
            parent.verticalCenter
        source: ("image://coverProvider/%1.front").arg(root.subfolderPic)
        fillMode: Image.PreserveAspectFit
        cache: false
        mipmap: true
        smooth: true

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: root.clicked()
        }
    }

    Colorize {
        visible: !model?.owned
        anchors.fill: frontPicImg
        source: frontPicImg
        saturation: 0
        lightness: 0.3
        hue: 0
    }

    Text {
        id: titleText
        width: frontPicImg.width - 10
        visible: !imageManager?.getFrontPic(root.subfolderPic).includes(model.tag)
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text : model?.title
        font.family: "Roboto"
        wrapMode: Text.WordWrap
        font.pointSize: 12
        opacity: model?.owned ? 1 : 0.4
        font.italic: !model?.owned
    }
}

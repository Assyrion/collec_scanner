import QtQuick 6.2
import QtQuick.Controls 6.2
import Qt5Compat.GraphicalEffects

Item {
    id: root

    signal clicked

    Connections {
        target: coverProcessingPopup
        function onAboutToHide() {
            mainImg.source =
                    imageManager.getFrontPic(tag)
        }
    }

    Image {
        id: mainImg
        width: parent.width
        anchors.verticalCenter:
            parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: imageManager?.getFrontPic(tag) ?? "qrc:/no_pic"
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
        anchors.fill: mainImg
        source: mainImg
        saturation: 0
        lightness: 0.6
        hue: 0
    }

    Text {
        visible: mainImg.source === Qt.url("qrc:/no_pic")
        width: mainImg.width - 10
        anchors.top : mainImg.top
        anchors.topMargin: 7
        anchors.horizontalCenter:
            mainImg.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text : model?.title
        font.family: "Roboto"
        wrapMode: Text.WordWrap
        font.pointSize: 12
        opacity: model?.owned ? 1 : 0.4
        font.italic: !model?.owned
    }
}

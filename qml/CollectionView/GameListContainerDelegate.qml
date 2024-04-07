import QtQuick 6.3
import QtQuick.Controls 6.3
import QtQuick.Layouts 6.3
import Qt5Compat.GraphicalEffects

import "../utils"

Item {
    id: root

    implicitHeight: bckgndRec.height + subgamesView.height
    state: "collapsed"

    property string rootTitle: model?.title ?? ""

    Component.onCompleted: {
        var idx = model.title.indexOf('(');
        if (idx !== -1) {
            rootTitle = model.title.slice(0, idx).trim()
        }
    }

    signal subGameClicked(int idx)

    Item {
        id: bckgndRec

        anchors.top: parent.top
        width: parent.width
        height: 80

        MouseArea {
            anchors.fill: parent
            property bool checked: true

            onClicked: {
                root.state = checked ? "expanded" : "collapsed"
                checked = !checked
            }
        }
    }

    RowLayout {
        id: picRow
        height: bckgndRec.height
        width: Math.min(bckgndRec.width - 12, children_width)
        anchors.right: parent.right
        anchors.rightMargin: 6
        spacing: 3
        clip: true

        property int children_width
        property int count: picRepeater.count
        onCountChanged: {
            var i, w = 0;
            for (i in children) {
                w += (children[i].implicitWidth + picRow.spacing)
            }
            children_width = w
        }

        Repeater {
            id: picRepeater
            model: subgamesView.model

            delegate: Image {
                property string subfolderPic: platformName + "/" + model.tag

                source: ("image://coverProvider/%1.front").arg(subfolderPic)
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                height: parent.height - 12
                Layout.preferredHeight: height
                Layout.preferredWidth: implicitWidth

                mipmap: true
                smooth: true

                Colorize {
                    visible: !owned
                    anchors.fill: parent
                    source: parent
                    saturation: 0
                    lightness: 0.3
                    hue: 0
                }
            }
        }
    }

    CSGlowText {
        id: titleText

        // width: bckgndRec.width
        anchors.verticalCenter:
            bckgndRec.verticalCenter
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: rootTitle
    }

    ListView {
        id: subgamesView
        width: parent.width
        anchors.top: bckgndRec.bottom
        interactive: false
        spacing: 5
        model: codeProxyModel

        property var codeProxyModel
        Component.onCompleted: {
            codeProxyModel = dbManager.currentProxyModel.getTitleFilterProxyModel(rootTitle)
        }

        delegate: GameListDelegate {
            width:  root.width - 10
            height: 50
            anchors.horizontalCenter: parent?.horizontalCenter

            onClicked: {
                var sourceIdx = subgamesView.codeProxyModel.mapIndexToSource(index)
                root.subGameClicked(sourceIdx)
            }
        }
        ScrollBar.vertical: ScrollBar {
            visible: false
        }
    }

    transitions: Transition {
        NumberAnimation {
            properties: "height,opacity"
            duration: 250
            easing.type: Easing.InOutQuad
        }
        AnchorAnimation {
            duration: 150
        }
    }

    states: [
        State {
            name: "expanded"
            PropertyChanges { target: subgamesView; height: (subgamesView.count * (50 + subgamesView.spacing)); opacity: 1 }
            PropertyChanges { target: picRow; opacity: 0 }
            AnchorChanges { target: titleText; anchors.left: undefined; anchors.horizontalCenter: root.horizontalCenter }
        },
        State {
            name: "collapsed"
            PropertyChanges { target: subgamesView; height: 0; opacity: 0 }
            PropertyChanges { target: picRow; opacity: 1 }
            AnchorChanges { target: titleText; anchors.left: root.left; anchors.horizontalCenter: undefined }
            PropertyChanges { target: titleText; width: root.width - 20; anchors.leftMargin: 10 }
        }
    ]

    Rectangle {
        id: borderRec

        anchors.top: parent.top
        width: parent.width
        height: root.implicitHeight

        color: "transparent"
        border.color: "burlywood"
        border.width: 1
        radius: 10
    }
}

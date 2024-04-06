import QtQuick 6.3
import QtQuick.Controls 6.3
import QtQuick.Layouts 6.3
import Qt5Compat.GraphicalEffects

import "../utils"

Item {
    id: root

    implicitHeight: bckgndRec.height + subgamesView.height

    property string rootTitle: model?.title ?? ""

    Component.onCompleted: {
        var idx = model.title.indexOf('(');
        if (idx !== -1) {
            rootTitle = model.title.slice(0, idx).trim()
        }
    }

    signal subGameClicked(int idx)

    Rectangle {
        id: bckgndRec

        anchors.top: parent.top
        width: parent.width
        height: 100

        color: "transparent"
        border.color: "white"
        border.width: 1
        radius: 10

        MouseArea {
            anchors.fill: parent
            property bool checked: true

            onClicked: {
                subgamesView.state = checked ? "expanded" : "collapsed"
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

        property var children_width
        property int count: picRepeater.count
        onCountChanged: {
            computeChildenWidth()
        }
        Component.onCompleted: {
            computeChildenWidth()
        }

        function computeChildenWidth() {
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
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter:
            bckgndRec.verticalCenter
        anchors.right: bckgndRec.right
        anchors.rightMargin: 10
        font.pointSize:
            Math.min(17, parent.width/3 + 1)
        font.family: "Roboto"
        text: rootTitle
    }

    ListView {
        id: subgamesView
        width: parent.width
        anchors.top: bckgndRec.bottom
        anchors.topMargin: 5
        interactive: false
        state: "collapsed"
        spacing: 5
        model: codeProxyModel

        property var codeProxyModel
        Component.onCompleted: {
            codeProxyModel = dbManager.currentProxyModel.getTitleFilterProxyModel(rootTitle)
        }

        delegate: GameListDelegate {
            width:  root.width - anchors.leftMargin
            height: 50
            anchors.left: parent?.left
            anchors.leftMargin: 50
            onClicked: {
                var sourceIdx = subgamesView.codeProxyModel.mapIndexToSource(index)
                root.subGameClicked(sourceIdx)
            }
        }
        ScrollBar.vertical: ScrollBar {
            visible: false
        }

        transitions: Transition {
            NumberAnimation {
                properties: "height,opacity"
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        states: [
            State {
                name: "expanded"
                PropertyChanges { target: subgamesView; height: (count * (50 + subgamesView.spacing)); opacity: 1 }
            },
            State {
                name: "collapsed"
                PropertyChanges { target: subgamesView; height: 0; opacity: 0 }
            }
        ]
    }
}

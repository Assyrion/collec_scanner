import QtQuick 2.8
import QtQuick.Controls 2.2
import GameData 1.0
import "utils"

Pane {
    id: root
    signal backToMenuRequired

    padding: 0
    ListView {
        id: listView
        model: sqlTableModel
        height: parent.height
        width: contentWidth
        flickableDirection:
            Flickable.HorizontalAndVerticalFlick
        spacing: 5
        delegate: Item {
            id: gameRow
            height: 50
            width: contentWidth
            readonly property int rowIdx : index
            Row {
                height: parent.height
                width: contentWidth

                RoundButton {
//                    padding: 0
                    height: parent.height
                    width : height
                    radius: 10
                    onClicked: {
                        var arr = [tag, title, platform, publisher,
                                   developer, release_date]
                        var game = GameDataMaker.createComplete(arr)
                        showGameData(game)
                    }
                }

                Repeater {
                    id: dataRepeater

                    model: ListModel {
                        id: dataModel
                        Component.onCompleted: {
                            dataModel.append({"name": title});
                            dataModel.append({"name": full_title});
                            dataModel.append({"name": platform});
                            dataModel.append({"name": publisher});
                            dataModel.append({"name": developer});
                            dataModel.append({"name": release_date});
                        }
                    }
                    delegate: TextField {
                        id: textField
                        text: textFieldMetrics.elidedText
                        height: parent.height
                        width: root.width/4
                        onEditingFinished: {
                            var modelIdx = sqlTableModel.index(gameRow.rowIdx, index+1)
                            sqlTableModel.setData(modelIdx, textField.text)
                        }

                        verticalAlignment:
                            TextField.AlignBottom
                        horizontalAlignment:
                            TextField.AlignLeft
                        leftPadding: 5
                        TextMetrics {
                            id: textFieldMetrics
                            text: name
                            elideWidth: textField.width-35
                            elide: Text.ElideRight
                        }
                        background: Rectangle {
                            color: "transparent"
                            border.color: gameRow.rowIdx%2 ? "#21be2b" : "red"
                        }
                    }
                }
            }
        }
        headerPositioning:
            ListView.OverlayHeader
        header: Row {
            height: 25
            width: parent.width
            Repeater {
                model: sqlTableModel.headers
                Label {
                    id: label
                    text: labelMetrics.elidedText
                    height: parent.height
                    width: root.width/4
                    verticalAlignment:
                        Label.AlignVCenter
                    horizontalAlignment:
                        Label.AlignLeft
                    leftPadding: 5
                    TextMetrics {
                        id: labelMetrics
                        text: modelData
                        elideWidth: label.width-20
                        elide: Text.ElideRight
                    }
                    background: Rectangle {
                        color: "transparent"
                        border.color: "white"
                    }
                }
            }
        }
    }

    function showGameData(game) {
        gameDataLoader.setSource("ViewGameData.qml",
                                 {"game": game})
    }

    Loader {
        id: gameDataLoader
        anchors.fill: parent
        Connections {
            target: gameDataLoader.item
            onClosed: {
                gameDataLoader.sourceComponent = undefined
            }
        }
    }
}

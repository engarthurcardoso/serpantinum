import QtQuick
import QtQuick.Layouts
import "../"
import "EmojiNav.js" as EmojiNav

// Emoji grid for the clipboard's emoji tab. Data comes from the launcher's EmojiSearch.
GridView {
    id: grid

    property var scaleFn: function(v) { return v; }
    signal emojiChosen(string emoji)

    clip: true
    model: emojiModel
    cellWidth: width / EmojiNav.COLUMNS
    cellHeight: grid.scaleFn(60)
    currentIndex: 0
    boundsBehavior: Flickable.StopAtBounds
    cacheBuffer: grid.scaleFn(400)
    highlightFollowsCurrentItem: false

    ListModel { id: emojiModel }

    property var emojiSearch: null

    function ensureSearch() {
        if (!emojiSearch) {
            let component = Qt.createComponent(Qt.resolvedUrl("../launcher/EmojiSearch.qml"));
            if (component.status === Component.Ready) {
                emojiSearch = component.createObject(grid);
            } else {
                console.warn("Failed to load emoji search:", component.errorString());
            }
        }
        return emojiSearch;
    }

    function filter(query) {
        let search = ensureSearch();
        let results = search ? search.search(query ? String(query).trim() : "", 150) : [];
        emojiModel.clear();
        for (let i = 0; i < results.length; i++) {
            emojiModel.append({ emoji: results[i].emoji, name: results[i].name });
        }
        grid.currentIndex = emojiModel.count > 0 ? 0 : -1;
        grid.positionViewAtBeginning();
    }

    function move(direction) {
        let next = EmojiNav.moveIndex(grid.currentIndex, direction, emojiModel.count, EmojiNav.COLUMNS);
        if (next >= 0) {
            grid.currentIndex = next;
            grid.positionViewAtIndex(next, GridView.Contain);
        }
    }

    function activateCurrent() {
        if (grid.currentIndex < 0 || grid.currentIndex >= emojiModel.count) return;
        grid.emojiChosen(emojiModel.get(grid.currentIndex).emoji);
    }

    delegate: Item {
        id: cell
        width: grid.cellWidth
        height: grid.cellHeight

        readonly property bool isSelected: index === grid.currentIndex

        Rectangle {
            anchors.fill: parent
            anchors.margins: grid.scaleFn(3)
            radius: Math.min(ThemeBackend.borderRadius, grid.scaleFn(10))
            color: cell.isSelected
                   ? ThemeBackend.mauve
                   : (cellMouse.containsMouse ? Qt.alpha(ThemeBackend.surface1, 0.7) : Qt.alpha(ThemeBackend.surface0, 0.45))

            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: grid.scaleFn(4)
                spacing: grid.scaleFn(1)

                Text {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: model.emoji
                    font.pixelSize: grid.scaleFn(22)
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                    text: model.name
                    font.family: ThemeBackend.fontFamily
                    font.pixelSize: grid.scaleFn(9)
                    font.weight: cell.isSelected ? Font.Bold : Font.Normal
                    color: cell.isSelected ? ThemeBackend.crust : ThemeBackend.subtext0
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 1
                }
            }
        }

        MouseArea {
            id: cellMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                grid.currentIndex = index;
                grid.emojiChosen(model.emoji);
            }
        }
    }
}

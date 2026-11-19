pragma Singleton
import QtQuick
import "../../"

ScreenToggleController {
    // Tab the clipboard opens on: "history" or "emoji"
    property string requestedTab: "history"
}

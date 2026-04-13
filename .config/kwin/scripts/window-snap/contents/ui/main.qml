import QtQuick
import org.kde.kwin

Item {
    readonly property int topBuffer: 70

    function getPrimaryScreen() {
        var screens = Workspace.screens
        if (!screens || screens.length === 0) return null
        var primary = screens[0]
        for (var i = 1; i < screens.length; i++) {
            if (screens[i].geometry.x < primary.geometry.x)
                primary = screens[i]
        }
        return primary
    }

    function getSecondaryScreen() {
        var screens = Workspace.screens
        if (!screens || screens.length < 2) return null
        var secondary = screens[0]
        for (var i = 1; i < screens.length; i++) {
            if (screens[i].geometry.x > secondary.geometry.x)
                secondary = screens[i]
        }
        return secondary
    }

    function snapToPrimary() {
        var client = Workspace.activeWindow
        if (!client) return
        var screen = getPrimaryScreen()
        if (!screen) return
        var geo = screen.geometry
        var w = Math.round(geo.width * 0.95)
        var h = Math.round(geo.height * 0.95)
        client.setMaximize(false, false)
        client.frameGeometry = Qt.rect(
            geo.x + Math.floor((geo.width - w) / 2),
            geo.y + Math.floor((geo.height - h) / 2),
            w,
            h
        )
    }

    function snapToSecondary(topFraction, heightFraction) {
        var client = Workspace.activeWindow
        if (!client) return
        var screen = getSecondaryScreen()
        if (!screen) return
        var geo = screen.geometry
        var usableY = geo.y + topBuffer
        var usableH = geo.height - topBuffer
        client.setMaximize(false, false)
        client.frameGeometry = Qt.rect(
            geo.x,
            usableY + Math.floor(usableH * topFraction),
            geo.width,
            Math.round(usableH * heightFraction)
        )
    }

    ShortcutHandler {
        name: "WindowSnap: Snap to Primary Center"
        text: "WindowSnap: Snap to Primary Center"
        sequence: "Meta+1"
        onActivated: snapToPrimary()
    }

    ShortcutHandler {
        name: "WindowSnap: Snap to Secondary Top"
        text: "WindowSnap: Snap to Secondary Top"
        sequence: "Meta+2"
        onActivated: snapToSecondary(0, 0.5)
    }

    ShortcutHandler {
        name: "WindowSnap: Snap to Secondary Bottom"
        text: "WindowSnap: Snap to Secondary Bottom"
        sequence: "Meta+3"
        onActivated: snapToSecondary(0.5, 0.5)
    }

    ShortcutHandler {
        name: "WindowSnap: Snap to Secondary Full"
        text: "WindowSnap: Snap to Secondary Full"
        sequence: "Meta+4"
        onActivated: snapToSecondary(0, 1.0)
    }
}

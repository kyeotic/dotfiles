function getSecondaryScreen() {
  for (var i = 0; i < workspace.screens.length; i++) {
    if (workspace.screens[i].name === 'DP-4') {
      return workspace.screens[i]
    }
  }
  return null
}

function snapTop() {
  const client = workspace.activeWindow
  const screen = getSecondaryScreen()
  if (!screen) return
  const geo = screen.geometry
  client.frameGeometry = Qt.rect(
    geo.x,
    geo.y,
    geo.width,
    Math.floor(geo.height / 2),
  )
}

function snapBottom() {
  const client = workspace.activeWindow
  const screen = getSecondaryScreen()
  if (!screen) return
  const geo = screen.geometry
  client.frameGeometry = Qt.rect(
    geo.x,
    geo.y + Math.floor(geo.height / 2),
    geo.width,
    Math.ceil(geo.height / 2),
  )
}

function snapFull() {
  const client = workspace.activeWindow
  const screen = getSecondaryScreen()
  if (!screen) return
  const geo = screen.geometry
  client.frameGeometry = Qt.rect(geo.x, geo.y, geo.width, geo.height)
}

registerShortcut('SnapSecondaryTop', 'Snap to Secondary Top', 'Meta+1', snapTop)
registerShortcut(
  'SnapSecondaryBottom',
  'Snap to Secondary Bottom',
  'Meta+2',
  snapBottom,
)
registerShortcut(
  'SnapSecondaryFull',
  'Snap to Secondary Full',
  'Meta+3',
  snapFull,
)

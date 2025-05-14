# Enter script code
import subprocess

def log(data):
    dialog.info_dialog("Debug", str(data))
    
class Geo:
    def __init__(self, geo):
        self.x = geo[0]
        self.y = geo[1]
        self.width = geo[2]
        self.height = geo[3]
        
def debug_window(win_id):
    result = subprocess.run(["xdotool", "getwindowgeometry", "--shell", win_id], capture_output=True, text=True)
    # log(result.stdout)
    size = {}
    for line in str(result.stdout).splitlines():
        key, value = line.split('=')
        size[key] = int(value)
    # log(size)
    # log([size['X'], size.['Y'], size.['WIDTH'], size.['HEIGHT']])
    log([size['X'], size['Y'], size['WIDTH'], size['HEIGHT']])

def move_window(win_id, geo):
    #log(win_id)
    resize = subprocess.run(["xdotool", "windowsize", win_id, str(geo.width), str(geo.height)], capture_output=True, text=True)
    move = subprocess.run(["xdotool", "windowmove", win_id, str(geo.x), str(geo.y)], capture_output=True, text=True)
    #log({resize: resize, move: move})
    
def get_window_id():
    return subprocess.check_output(["xdotool", "getactivewindow"]).decode().strip()
    
class ScreenPosition:
    def __init__(self, geo):
        self.geo = Geo(geo)
    
    def move_window(self):
        active = get_window_id()
        move_window(active, self.geo)
        #debug_window(active)
        
        
altHigh = ScreenPosition([2560, 106, 1440, 1120])
# [2560, 1227, 1438, 1333]
# [2560, 1227, 1437, 1335]
altLow = ScreenPosition([2560, 1227, 1440, 1335])
altFull = ScreenPosition([2560, 78, 1440, 2483])
mainFull = ScreenPosition([-7, 230, 2565, 1399])


# [2560, 78, 1440, 2483]

# WINDOW=73400327
# X=2561
# Y=106
# WIDTH=1436
# HEIGHT=1120
# SCREEN=0

# WINDOW=77594695
# X=2560
# Y=1225
# WIDTH=1438
# HEIGHT=1335
# SCREEN=0

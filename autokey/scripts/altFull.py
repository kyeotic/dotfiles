# Enter script code
#from autokey_lib import altHigh, altLow, altFull 
import os
from pathlib import Path
script_dir = Path(__file__).resolve().parent.resolve()

with open(os.path.join(script_dir, "autokey_lib.py"), 'r') as file:
    exec(file.read())
    
altFull.move_window()

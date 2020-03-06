local component = require("component")
local screen = component.screen

if screen.isPrecise() then
  print("Not supported screen")
endif
  
-- os.execute("rm /tmp/setup/base/"..i)

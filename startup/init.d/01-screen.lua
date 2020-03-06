local component = require("component")
local screen = component.screen


  local screenblockW, screenblockH = screen.getAspectRatio()

  if screenblockW == 2 and screenblockH == 1 then
    os.execute("resolution 160 35")
  end 


  

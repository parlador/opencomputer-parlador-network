local component = require("component")
local screen = component.screen


  local screenblockW, screenblockH = screen.getAspectRatio()

  if screenblockW == 2 and screenblockH == 1 then
    os.execute("resolution 160 35")
  end 
  if screenblockW == 2 and screenblockH == 2 then
    os.execute("resolution 100 50")
  end 

  

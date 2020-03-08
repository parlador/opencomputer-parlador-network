local component = require("component")
local gpu = component.gpu
local screen = component.screen

  local screenblockW, screenblockH = screen.getAspectRatio()

  if screenblockW == 2 and screenblockH == 1 then
    gpu.setresolution(160,35)
  end 
  if screenblockW == 2 and screenblockH == 2 then
    gpu.setresolution(100,50)
  end 

  

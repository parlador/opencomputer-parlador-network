local component = require("component")
local gpu = component.gpu
local screen = component.screen

local MaxW, MaxH = gpu.maxResolution()

  if MaxW ~= 160 or MaxH ~= 50 then
    print("Wrong Resolution, gpu tier3 or screen tier3 not detected, rebooting in 5 sec!")
    os.execute("sleep 5")
    os.execute("reboot")
  end

  local screenblockW, screenblockH = screen.getAspectRatio()

  if screenblockW == 2 and screenblockH == 1 then
    gpu.setResolution(160,35)
  end 
  if screenblockW == 2 and screenblockH == 2 then
    gpu.setResolution(100,50)
  end 

  

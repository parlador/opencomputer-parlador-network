local component = require("component")
local screen = component.screen

if screen.isPrecise() then
  local screenblockW, screenblockH = screen.getAspectRatio()
  if screenblockW == 2 and screenblockH == 1 then
    os.execute("resolution 160 35")
  end 
end
  
-- os.execute("rm /tmp/setup/base/"..i)


-- 1H 2W 160 35

-- diesel generator control

--conduit saturation:  (enderio_conduit_bundle)
--pwr_getMaxPowerInconduits
--pwr_getPowerInconduits


--enderio normal bank (activated_capbank)
--getCurrentStorage
--getMaximumStorage
--setOuputControlMode (IGNORE/""ON")

  
local GUI = require("GUI")
component = require("component")

BankAdresse = ""
ConduitAdresse = ""

for address, name in component.list("activated_capbank", false) do
  BankAdresse = address
end
for address, name in component.list("enderio_conduit_bundle", false) do
  ConduitAdresse = address
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult +0.5) / mult
end

function GetPourcentageBankPower()
    CurrentPower = component.invoke(BankAdresse, "getCurrentStorage")
    MaxPower = component.invoke(BankAdresse, "getMaximumStorage")
    return round((100 /MaxPower) * CurrentPower, 1)
end

function GetPourcentageConduitSaturate()
    CurrentPower = component.invoke(ConduitAdresse, "pwr_getPowerInconduits")
    MaxPower = component.invoke(ConduitAdresse, "pwr_getMaxPowerInconduits")
    return round((100 /MaxPower) * CurrentPower, 1)
end

function ProcessingGenerator()
    UpdateGUI()
    ControlGenerator()
end

function UpdateGUI()
  
  
end

function ControlGenerator()
  
  
end



--------------------------------------------------------------------------------
application = GUI.application()


application.eventHandler = function(application, object, eventname, ...)
    if     eventname == "touch" then
    elseif     eventname == "GUI" then
    elseif     eventname == "drag" then
    elseif     eventname == "drop" then
    elseif     eventname == "key_down" then
    elseif     eventname == "key_up" then
    elseif     eventname == nil then ProcessingGenerator()
    else                
        GUI.alert(eventname)
    end
   
end
 
--------------------------------------------------------------------------------


i = 1
application:draw(true)
application:start(1)

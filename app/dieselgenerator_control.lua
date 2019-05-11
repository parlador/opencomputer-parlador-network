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



--------------------------------------------------------------------------------
-- graph zone

 -- line1
application:addChild(GUI.panel(49, 2, 30, 10, 0x2D2D2D))
application:addChild(GUI.panel(49, 2, 30, 1, 0x1F4582))
--application:addChild(GUI.text(49, 2, 0xFFFFFF, "   FUEL TEMPERATURE       "))
chartTemperature = application:addChild(GUI.chart(49, 3, 30, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x5F63FE, 1, 1, "s", "C", true, {}))
application:addChild(GUI.panel(49, 12, 30, 1, 0x000000))
application:addChild(GUI.text(49, 12, 0x000000, "                                                  "))
table.insert(chartTemperature.values,1,{0, 0})


--line 2
application:addChild(GUI.panel(49, 13, 30, 10, 0x2D2D2D))
application:addChild(GUI.panel(49, 13, 30, 1, 0x1F4582))
--application:addChild(GUI.text(45, 20, 0xFFFFFF, "    FUEL REACTIVITE      "))
chartReact = application:addChild(GUI.chart(49, 14, 30, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x00FF91, 1, 1, "s", "%", true, {}))
application:addChild(GUI.panel(49, 23, 30, 1, 0x000000))
application:addChild(GUI.text(49, 23, 0x000000, "                                                  "))
table.insert(chartReact.values,1,{0, 0})


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

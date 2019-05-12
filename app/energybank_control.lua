--energybank_control


local GUI = require("GUI")
component = require("component")


BankAdresse = ""
for address, name in component.list("capbank", false) do
  BankAdresse = address
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
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

function DisableOutputBank()
   component.invoke(BankAdresse, "setOutputControlMode","ON")
end

function EnableOutputBank()
   component.invoke(BankAdresse, "setOutputControlMode","IGNORE")
end


function ProcessingBank()
    UpdateGUI()
    ControlBank()
end

function UpdateGUI()
  
    table.insert(chartConduit.values, {i, GetPourcentageConduitSaturate()})
    table.insert(chartBank.values, {i, GetPourcentageBankPower()})
  
    if tablelength(chartConduit.values) > 31 then
        table.remove(chartConduit.values, 1)
        table.insert(chartConduit.values,1,{i-30, 0})
        table.remove(chartConduit.values, 2)
 
    end
     if tablelength(chartBank.values) > 31 then
        table.remove(chartBank.values, 1)
        table.insert(chartBank.values,1,{i-30, 0})
        table.remove(chartBank.values, 2)
 
    end
  
    i = i + 1
    application:draw(true)
  
end

function ControlBank()
    if GetPourcentageConduitSaturate() < 85 then
      EnableOutputBank()
    else 
      DisableOutputBank()
    end
end



--------------------------------------------------------------------------------
application = GUI.application()



--------------------------------------------------------------------------------
-- graph zone

 -- line1
application:addChild(GUI.panel(39, 2, 40, 10, 0x2D2D2D))
application:addChild(GUI.panel(39, 2, 40, 1, 0x1F4582))
--application:addChild(GUI.text(39, 2, 0xFFFFFF, "   FUEL TEMPERATURE       "))
chartConduit = application:addChild(GUI.chart(39, 3, 40, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x5F63FE, 1, 1, "s", "C", true, {}))
application:addChild(GUI.panel(39, 12, 40, 1, 0x000000))
application:addChild(GUI.text(39, 12, 0x000000, "                                                  "))
table.insert(chartConduit.values,1,{0, 0})


--line 2
application:addChild(GUI.panel(39, 15, 40, 10, 0x2D2D2D))
application:addChild(GUI.panel(39, 15, 40, 1, 0x1F4582))
--application:addChild(GUI.text(45, 20, 0xFFFFFF, "    FUEL REACTIVITE      "))
chartBank = application:addChild(GUI.chart(39, 16, 40, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x00FF91, 1, 1, "s", "%", true, {}))
application:addChild(GUI.panel(39, 25, 40, 1, 0x000000))
application:addChild(GUI.text(39, 25, 0x000000, "                                                  "))
table.insert(chartBank.values,1,{0, 0})


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

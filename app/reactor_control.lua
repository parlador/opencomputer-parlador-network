local GUI = require("GUI")
component = require("component")
ReactorAdresse = ""
RodLevelLimit = 100
RodLevel = 100
TempLimit = 970
PowerTrigger = 95
SteamTrigger = 95
 
--------------------------------------------------------------------------------
 
for address, name in component.list("bigreactor", false) do
  ReactorAdresse = address
end
 
--------------------------------------------------------------------------------
 
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
 
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult +0.5) / mult
end
 
function ProcessingReactor()
    UpdateGUI()
    ControlReactor()
end
 
function UpdateGUI()
    table.insert(chartFuel.values, {i, GetPourcentageFuel()})
   
    table.insert(chartReact.values, {i, component.invoke(ReactorAdresse, "getFuelReactivity")})
 
    
    
 
    table.insert(chartTemperature.values, {i, component.invoke(ReactorAdresse, "getFuelTemperature")})
 
    ReactorTemp.text = round(component.invoke(ReactorAdresse, "getCasingTemperature"),1).." C"
    FuelTemp.text = round(component.invoke(ReactorAdresse, "getFuelTemperature"),1).." C"
    FuelReactivite.text = round(component.invoke(ReactorAdresse, "getFuelReactivity"),1).." %"
    FuelRate.text = round(component.invoke(ReactorAdresse, "getFuelConsumedLastTick"),2).." MB/T"
 
    FuelTank.value = round(GetPourcentageFuel(),0)
    WasteTank.value = round(GetPourcentageWaste(),0)
 
    if component.invoke(ReactorAdresse, "isActivelyCooled") == true then
        OutputTank.value = round(GetPourcentageHotFuel(),0)
        table.insert(chartPower.values, {i, GetPourcentageHotFuel()})
        OutputRate.text = round(component.invoke(ReactorAdresse, "getHotFluidProducedLastTick"),1).." MB/T"
        table.insert(chartPowerOuput.values, {i, component.invoke(ReactorAdresse, "getHotFluidProducedLastTick")})
    else
        OutputTank.value = round(GetPourcentagePower(),0)
        table.insert(chartPower.values, {i, GetPourcentagePower()})
        OutputRate.text = round(component.invoke(ReactorAdresse, "getEnergyProducedLastTick"),1).." RF/T"
        table.insert(chartPowerOuput.values, {i, component.invoke(ReactorAdresse, "getEnergyProducedLastTick")})
    end
 
    if tablelength(chartReact.values) > 60 then
        table.remove(chartReact.values, 1)
        table.insert(chartReact.values,1,{i-60, 0})
        table.remove(chartReact.values, 2)
 
    end
    if tablelength(chartFuel.values) > 61 then
        table.remove(chartFuel.values, 1)
        table.insert(chartFuel.values,1,{i-60, 0})
        table.remove(chartFuel.values, 2)
 
    end
    if tablelength(chartPower.values) > 61 then
        table.remove(chartPower.values, 1)
        table.insert(chartPower.values,1,{i-60, 0})
        table.remove(chartPower.values, 2)
       
    end
    if tablelength(chartPowerOuput.values) > 61 then
        table.remove(chartPowerOuput.values, 1)
        table.insert(chartPowerOuput.values,1,{i-60, 0})
        table.remove(chartPowerOuput.values, 2)
       
    end
    if tablelength(chartTemperature.values) > 60 then
        table.remove(chartTemperature.values, 1)
        table.insert(chartTemperature.values,1,{i-60, 0})
        table.remove(chartTemperature.values, 2)
 
    end
 
    i = i + 1
    application:draw(true)
 
end
 
function GetPourcentagePower()
    CurrentPower = component.invoke(ReactorAdresse, "getEnergyStored")
    MaxPower = 10000000
    return round((100 /MaxPower) * CurrentPower, 1)
end
function GetPourcentageFuel()
    CurrentFuel = component.invoke(ReactorAdresse, "getFuelAmount")
    MaxFuel = component.invoke(ReactorAdresse, "getFuelAmountMax")
    return round((100 /MaxFuel) * CurrentFuel, 1)
end
function GetPourcentageWaste()
    CurrentWaste = component.invoke(ReactorAdresse, "getWasteAmount")
    MaxFuel = component.invoke(ReactorAdresse, "getFuelAmountMax")
    return round((100 /MaxFuel) * CurrentWaste, 1)
end
function GetPourcentageHotFuel()
    CurrentHotFuel = component.invoke(ReactorAdresse, "getHotFluidAmount")
    MaxHotFluid = component.invoke(ReactorAdresse, "getHotFluidAmountMax")
    return round((100 /MaxHotFluid) * CurrentHotFuel, 1)
end
 
function ControlReactor()
    if switchButton.switch.state == true then
        if component.invoke(ReactorAdresse, "isActivelyCooled") == true then
            ReactorActiveCooling()
        else
            ReactorPassiveCooling()
        end
        ManageTemperatureAndRod()
    else
        component.invoke(ReactorAdresse, "setActive", false)
        ReactorStatus.text = "Disabled"
    end
end

function ReactorActiveCooling()
        if round(GetPourcentageHotFuel(),0) < SliderSteamTrigger.value then
                component.invoke(ReactorAdresse, "setActive", true)
                ReactorStatus.text = "Running"
        else
                component.invoke(ReactorAdresse, "setActive", false)
                ReactorStatus.text = "Standby"
        end
 
end

function ReactorPassiveCooling()
        if round(GetPourcentagePower(),0) < SliderPowerTrigger.value then
                component.invoke(ReactorAdresse, "setActive", true)
                ReactorStatus.text = "Running"
        else
                component.invoke(ReactorAdresse, "setActive", false)
                ReactorStatus.text = "Standby"
        end
 
end


function ManageTemperatureAndRod()
    fueltemp = round(component.invoke(ReactorAdresse, "getFuelTemperature"),0)
    targettemp = SliderTempLimit.value
    
     if fueltemp > targettemp then
            heatover = (fueltemp - targettemp)
            if (heatover*2) > 99 then
                SetAllRodLevel(100)
            elseif (heatover*2) < 1 then
                SetAllRodLevel(0)
            else
                SetAllRodLevel((heatover*2))
            end
    else
        SetAllRodLevel(0)
    end
end

function SetAllRodLevel(LevelSet)
   RodLevel = LevelSet
   RodLimit = SliderLevelLimit.value
   CurrentRodLevel.text = RodLimit
      if LevelSet > RodLimit then
          component.invoke(ReactorAdresse, "setAllControlRodLevels",RodLimit)
      else
          component.invoke(ReactorAdresse, "setAllControlRodLevels",LevelSet)
      end

end
 
--------------------------------------------------------------------------------
 
application = GUI.application()
application:addChild(GUI.panel(1, 1, application.width, application.height, 0x2D2D2D))
  
 
-- Add a regular button with switchMode state
 
switchButton =application:addChild(GUI.switchAndLabel(2, 3, 32, 8, 0x66DB80, 0x1D1D1D, 0xEEEEEE, 0x999999, "Reactor Enabled:", component.invoke(ReactorAdresse, "getActive")))
 
application:addChild(GUI.text(14, 1, 0xFFFFFF, "REACTOR CONTROL"))
 
application:addChild(GUI.text(2, 4, 0x999999, "Reactor Mode:"))
if component.invoke(ReactorAdresse, "isActivelyCooled") == true then
    ReactorMode = application:addChild(GUI.text(24, 4, 0x999999, "Active Cooling"))
else
    ReactorMode = application:addChild(GUI.text(24, 4, 0x999999, "Passive Cooling"))
end
 
application:addChild(GUI.text(2, 5, 0x999999, "Reactor Status:"))
ReactorStatus = application:addChild(GUI.text(24, 5, 0x999999, "????"))
 
application:addChild(GUI.text(2, 6, 0x999999, "Reactor Temperature:"))
ReactorTemp = application:addChild(GUI.text(24, 6, 0x999999, "0 C"))
 
application:addChild(GUI.text(2, 7, 0x999999, "Reactor Rod level:"))
CurrentRodLevel = application:addChild(GUI.text(24, 7, 0x999999, "100"))
 
application:addChild(GUI.text(2, 8, 0x999999, "Reactor Rod Limit:"))
SliderLevelLimit = application:addChild(GUI.slider(24, 8, 14, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 100, RodLevelLimit, false, ""))
 
application:addChild(GUI.text(2, 10, 0x999999, "Fuel Temperature:"))
FuelTemp = application:addChild(GUI.text(24, 10, 0x999999, "0 C"))
 
application:addChild(GUI.text(2, 11, 0x999999, "Fuel Temp. Limit:"))
SliderTempLimit = application:addChild(GUI.slider(24, 11, 14, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 70, 1870, TempLimit, false, ""))
 
application:addChild(GUI.text(2, 13, 0x999999, "Fuel Reactivite:"))
FuelReactivite = application:addChild(GUI.text(24, 13, 0x999999, "0 %"))
   
application:addChild(GUI.text(2, 14, 0x999999, "Fuel Consume Rate:"))
FuelRate = application:addChild(GUI.text(24, 14, 0x999999, "0 MB/T"))
 
application:addChild(GUI.text(2, 15, 0x999999, "Fuel Tank:"))
FuelTank = application:addChild(GUI.progressBar(24, 15, 14, 0xD2DE67, 0xEEEEEE, 0xEEEEEE, 0, true, false))
 
application:addChild(GUI.text(2, 16, 0x999999, "Waste Tank:"))
WasteTank = application:addChild(GUI.progressBar(24, 16, 14, 0x7900E2, 0xEEEEEE, 0xEEEEEE, 0, true, false))
 
if component.invoke(ReactorAdresse, "isActivelyCooled") == true then
    application:addChild(GUI.text(2, 17, 0x999999, "Steam Tank:"))
    application:addChild(GUI.text(2, 18, 0x999999, "Steam Tank Trigger:"))
    SliderSteamTrigger = application:addChild(GUI.slider(24, 18, 14, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 95, SteamTrigger, false, ""))
    application:addChild(GUI.text(2, 20, 0x999999, "Steam Produte Rate:"))
else
    application:addChild(GUI.text(2, 17, 0x999999, "Power Bank:"))
    application:addChild(GUI.text(2, 18, 0x999999, "Power Bank Trigger:"))
    SliderPowerTrigger = application:addChild(GUI.slider(24, 18, 14, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 95, PowerTrigger, false, ""))
    application:addChild(GUI.text(2, 20, 0x999999, "Power Produte Rate:"))
 
end
--OutputTank = application:addChild(GUI.text(24, 17, 0x999999, "0 %"))
OutputTank = application:addChild(GUI.progressBar(24, 17, 14, 0xA82B2B, 0xEEEEEE, 0xEEEEEE, 0, true, false))
OutputRate = application:addChild(GUI.text(24, 20, 0x999999, "0 /T"))
 
 
 
 
 
--------------------------------------------------------------------------------
 -- line1
chartTemperature = application:addChild(GUI.chart(58, 1, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x5F63FE, 1, 1, "s", "C", true, {}))
--application:addChild(GUI.text(45, 10, 0xFFFFFF, "   FUEL TEMPERATURE       "))
table.insert(chartTemperature.values,1,{0, 0})

chartFuel = application:addChild(GUI.chart(109, 1, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xD2DE67, 1, 1, "s", "%", true, {}))
--application:addChild(GUI.text(73, 10, 0xFFFFFF, "       FUEL TANK           "))
table.insert(chartFuel.values,1,{0, 0})
 
--line 2
chartReact = application:addChild(GUI.chart(58, 12, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x00FF91, 1, 1, "s", "%", true, {}))
--application:addChild(GUI.text(45, 20, 0xFFFFFF, "    FUEL REACTIVITE      "))
table.insert(chartReact.values,1,{0, 0})
 
-- line 33

chartPowerOuput = application:addChild(GUI.chart(58, 23, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xA82B2B, 1, 1, "s", "%", true, {}))
--application:addChild(GUI.text(73, 20, 0xFFFFFF, "      POWER BANK            "))
table.insert(chartPowerOuput.values,1,{0, 0})
 
chartPower = application:addChild(GUI.chart(109, 23, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xA82B2B, 1, 1, "s", "%", true, {}))
--application:addChild(GUI.text(73, 20, 0xFFFFFF, "      POWER BANK            "))
table.insert(chartPower.values,1,{0, 0})
 
application.eventHandler = function(application, object, eventname, ...)
    if     eventname == "touch" then
    elseif     eventname == "GUI" then
    elseif     eventname == "drag" then
    elseif     eventname == "drop" then
    elseif     eventname == "key_down" then
    elseif     eventname == "key_up" then
    elseif     eventname == nil then ProcessingReactor()
    else                
        GUI.alert(eventname)
    end
   
end
 
--------------------------------------------------------------------------------


i = 1
application:draw(true)
application:start(1)

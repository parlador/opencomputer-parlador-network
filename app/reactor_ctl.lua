local GUI = require("GUI")
component = require("component")
Reactorlist = {}
 
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

--------------------------------------------------------------------------------

function GetPourcentagePower(ReactorAdresse)
    CurrentPower = component.invoke(ReactorAdresse, "getEnergyStored")
    MaxPower = 10000000
    return round((100 /MaxPower) * CurrentPower, 1)
end
function GetPourcentageFuel(ReactorAdresse)
    CurrentFuel = component.invoke(ReactorAdresse, "getFuelAmount")
    MaxFuel = component.invoke(ReactorAdresse, "getFuelAmountMax")
    return round((100 /MaxFuel) * CurrentFuel, 1)
end
function GetPourcentageWaste(ReactorAdresse)
    CurrentWaste = component.invoke(ReactorAdresse, "getWasteAmount")
    MaxFuel = component.invoke(ReactorAdresse, "getFuelAmountMax")
    return round((100 /MaxFuel) * CurrentWaste, 1)
end
function GetPourcentageHotFuel(ReactorAdresse)
    CurrentHotFuel = component.invoke(ReactorAdresse, "getHotFluidAmount")
    MaxHotFluid = component.invoke(ReactorAdresse, "getHotFluidAmountMax")
    return round((100 /MaxHotFluid) * CurrentHotFuel, 1)
end
function GetActivelyCooled(ReactorAdresse)
    return component.invoke(ReactorAdresse, "isActivelyCooled")
end
function GetCasingTemperature(ReactorAdresse)
    return component.invoke(ReactorAdresse, "getCasingTemperature")
end
function GetFuelTemperature(ReactorAdresse)
    return component.invoke(ReactorAdresse, "getFuelTemperature")
end
function GetFuelReactivity(ReactorAdresse)
    return component.invoke(ReactorAdresse, "getFuelReactivity")
end
function GetFuelConsumedLastTick(ReactorAdresse)
    return component.invoke(ReactorAdresse, "getFuelConsumedLastTick")
end 
function GetReactorActiver(ReactorAdresse)
    return component.invoke(ReactorAdresse, "getActive")
end 

function GetSteamTrigger(ReactorAdresse)
    Reactorlist[]
end
function GetPowerTrigger(ReactorAdresse)
 
end
function GetTempLimit(ReactorAdresse)
 
end
function GetRodLevel(ReactorAdresse)
 
end
function GetRodLevelLimit(ReactorAdresse)
 
end

--------------------------------------------------------------------------------

function PollReactors()
      tmpReactorList  = {}
      idreactor = 1
      for address, name in component.list("bigreactor", false) do
        tmpReactorList[address]={Address=address,PourcentageHotFuel=GetPourcentageHotFuel(address),PourcentageWaste=GetPourcentageWaste(address),PourcentageFuel=GetPourcentageFuel(address),PourcentagePower=GetPourcentagePower(address),ActivelyCooled=GetActivelyCooled(address),CasingTemperature=GetCasingTemperature(address),FuelTemperature=GetFuelTemperature(address),FuelReactivity=GetFuelReactivity(address),FuelConsumedLastTick=GetFuelConsumedLastTick(address),ReactorMasterSwitch=true,RodLevelLimit=100,RodLevel=100,TempLimit=970,PowerTrigger=95,SteamTrigger=95,ReactorEnable=GetReactorActiver(address)}
        idreactor = 1
      end
  return tmpReactorList
end

--------------------------------------------------------------------------------

Reactorlist = PollReactors()


for i,line in pairs(Reactorlist) do
    print(line["Address"])
end

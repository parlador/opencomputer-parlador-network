local GUI = require("GUI")
component = require("component")
Reactorlist = {}
 
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
 
--------------------------------------------------------------------------------

function PollReactors()
      tmpReactorList  = {}
      idreactor = 1
      for address, name in component.list("bigreactor", false) do
        print(name.." : "..address)
        tmpReactorList[idreactor]={"Address"=address,"PourcentageHotFuel"=GetPourcentageHotFuel(address),"PourcentageWaste"=GetPourcentageWaste(address)."PourcentageFuel"=GetPourcentageFuel(address),"PourcentagePower"=GetPourcentagePower(address)}
        idreactor += 1
      end
  return tmpReactorList
end

Reactorlist = PollReactors()


for i,line in ipairs(Reactorlist) do
    print(line["addr"])
end

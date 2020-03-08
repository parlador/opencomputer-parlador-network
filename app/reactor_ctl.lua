local gui = require("GUI")
component = require("component")
filesystem = require("filesystem")
io = require("io")
serialization = require("serialization")
term = require("term")
modem = component.modem

Reactorlist = {}
RepoCfg = "/etc/Reactor/"


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

function CreateRepoCfg(repo)
   return filesystem.makeDirectory(repo)
end

function SaveCfg(repo,file,table)
  file = io.open(repo..file..".cfg","w")
  file:write(serialization.serialize(table))
  file:close()
end

function LoadCfg(repo,file)
  file = io.open(repo..file..".cfg","r")
  configtbl = serialization.unserialize(file:read("*a"))
  file:close()
   return
end

function ExistCfg(repo,file)
   return filesystem.exists(repo..file..".cfg")
end
 


function GlobalLoadCfg(repo)
   if ExistCfg(repo,"global") == false then
    CreateRepoCfg(repo)
    GlobalSaveCfg(repo,GlobalInitCfg())
   end
   return LoadCfg(repo,"global")
end

function GlobalSaveCfg(repo,config)
    return SaveCfg(repo,"global",config)
end

function GlobalInitCfg()
 term.clear()
 print(" - - - - - - - - - - - - - - - - - ")
 print("REACTOR CONTROL SETUP")
 print(" - - - - - - - - - - - - - - - - - ")
 print()
 print("Set the Group Name: ")
 GroupName = io.read()

 return {name=GroupName}
end


function ReactorLoadCfg(ReactorAdresse)
 
end

function ReactorSaveCfg(ReactorAdresse)
 
end

function ReactorInitCfg(ReactorAdresse)
 
end

function ReactorExistCfg(ReactorAdresse)
 
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
    if Reactorlist[ReactorAdresse] then
       return Reactorlist[ReactorAdresse]["SteamTrigger"]
    else
       return 95
    end
end
function GetPowerTrigger(ReactorAdresse)
    if Reactorlist[ReactorAdresse] then
       return Reactorlist[ReactorAdresse]["PowerTrigger"]
    else
       return 95
    end
end
function GetTempLimit(ReactorAdresse)
    if Reactorlist[ReactorAdresse] then
       return Reactorlist[ReactorAdresse]["TempLimit"]
    else
       return 975
    end
end
function GetRodLevel(ReactorAdresse)
    if Reactorlist[ReactorAdresse] then
       return Reactorlist[ReactorAdresse]["RodLevel"]
    else
       return 100
    end
end
function GetRodLevelLimit(ReactorAdresse)
    if Reactorlist[ReactorAdresse] then
       return Reactorlist[ReactorAdresse]["RodLevelLimit"]
    else
       return 100
    end
end

--------------------------------------------------------------------------------

function PollReactors()
      tmpReactorList  = {}
      idreactor = 1
      for address, name in component.list("bigreactor", false) do
        tmpReactorList[address]={Address=address,PourcentageHotFuel=GetPourcentageHotFuel(address),PourcentageWaste=GetPourcentageWaste(address),PourcentageFuel=GetPourcentageFuel(address),PourcentagePower=GetPourcentagePower(address),ActivelyCooled=GetActivelyCooled(address),CasingTemperature=GetCasingTemperature(address),FuelTemperature=GetFuelTemperature(address),FuelReactivity=GetFuelReactivity(address),FuelConsumedLastTick=GetFuelConsumedLastTick(address),ReactorMasterSwitch=true,RodLevelLimit=GetRodLevelLimit(),RodLevel=GetRodLevel(address),TempLimit=GetTempLimit(address),PowerTrigger=GetPowerTrigger(address),SteamTrigger=GetSteamTrigger(address),ReactorEnable=GetReactorActiver(address)}
        idreactor = 1
      end
  return tmpReactorList
end

--------------------------------------------------------------------------------

GlobalConfig = GlobalLoadCfg(RepoCfg)
Reactorlist = PollReactors()


for i,line in pairs(Reactorlist) do
    print(line["Address"])
end

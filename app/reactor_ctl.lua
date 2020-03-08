local gui = require("GUI")
component = require("component")
filesystem = require("filesystem")
io = require("io")
os = require("os")
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
   return configtbl 
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
 print("REACTOR CONTROL GLOBAL SETUP")
 print(" - - - - - - - - - - - - - - - - - ")
 print()
 print("Set the Group Name: ")
 GroupName = io.read()

 return {name=GroupName}
end

function ReactorLoadCfg(repo,ReactorAdresse)
 return LoadCfg(repo,ReactorAdresse)
end

function ReactorSaveCfg(repo,ReactorAdresse,config)
  return SaveCfg(repo,ReactorAdresse,config)
end

function ReactorInitCfg(repo,ReactorAdresse)
 term.clear()
 print(" - - - - - - - - - - - - - - - - - ")
 print("REACTOR "..ReactorAdresse.." SETUP")
 print(" - - - - - - - - - - - - - - - - - ")
 print()
 print("Set the Reactor Name: ")
 ReactorName = io.read()
  
 return {name=ReactorName,SteamTrigger=95,PowerTrigger=95,TempLimit=970,RodLevel=100,RodLevelLimit=100,MasterSwitch=true}
end

function AllReactorInit(repo)
  for address, name in component.list("bigreactor", false) do
    if ExistCfg(repo,address) == false then
      ReactorSaveCfg(repo,address,ReactorInitCfg(repo,address))
    end
  end
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

function GetSteamTrigger(ReactorAdresse,repo)
    if Reactorlist["ReactorAdresse"] then
       return Reactorlist[ReactorAdresse]["SteamTrigger"]
    else
       return ReactorLoadCfg(repo,ReactorAdresse)["SteamTrigger"]
    end
end
function GetPowerTrigger(ReactorAdresse,repo)
    if Reactorlist["ReactorAdresse"] then
       return Reactorlist[ReactorAdresse]["PowerTrigger"]
    else
       return ReactorLoadCfg(repo,ReactorAdresse)["PowerTrigger"]
    end
end
function GetTempLimit(ReactorAdresse,repo)
    if Reactorlist["ReactorAdresse"] then
       return Reactorlist[ReactorAdresse]["TempLimit"]
    else
       return ReactorLoadCfg(repo,ReactorAdresse)["TempLimit"]
    end
end
function GetRodLevel(ReactorAdresse,repo)
    if Reactorlist["ReactorAdresse"] then
       return Reactorlist[ReactorAdresse]["RodLevel"]
    else
       return ReactorLoadCfg(repo,ReactorAdresse)["RodLevel"]
    end
end
function GetRodLevelLimit(ReactorAdresse,repo)
    if Reactorlist["ReactorAdresse"] then
       return Reactorlist[ReactorAdresse]["RodLevelLimit"]
    else
       return ReactorLoadCfg(repo,ReactorAdresse)["RodLevelLimit"]
    end
end
function GetReactorName(ReactorAdresse,repo)
    if Reactorlist["GetReactorName"] then
       return Reactorlist[ReactorAdresse]["GetReactorName"]
    else
       return ReactorLoadCfg(repo,ReactorAdresse)["GetReactorName"]
    end
end
function GetMasterSwitch(ReactorAdresse,repo)
    if Reactorlist["MasterSwitch"] then
       return Reactorlist[ReactorAdresse]["MasterSwitch"]
    else
       return ReactorLoadCfg(repo,ReactorAdresse)["MasterSwitch"]
    end
end

--------------------------------------------------------------------------------

function PollReactors(repo)
      tmpReactorList  = {}
      idreactor = 1
      for address, name in component.list("bigreactor", false) do
        tmpReactorList[address]={Address=address,PourcentageHotFuel=GetPourcentageHotFuel(address),PourcentageWaste=GetPourcentageWaste(address),PourcentageFuel=GetPourcentageFuel(address),PourcentagePower=GetPourcentagePower(address),ActivelyCooled=GetActivelyCooled(address),CasingTemperature=GetCasingTemperature(address),FuelTemperature=GetFuelTemperature(address),FuelReactivity=GetFuelReactivity(address),FuelConsumedLastTick=GetFuelConsumedLastTick(address),ReactorMasterSwitch=GetMasterSwitch(address,repo),RodLevelLimit=GetRodLevelLimit(address,repo),RodLevel=GetRodLevel(address,repo),TempLimit=GetTempLimit(address,repo),PowerTrigger=GetPowerTrigger(address,repo),SteamTrigger=GetSteamTrigger(address,repo),ReactorEnable=GetReactorActiver(address),Name=GetReactorName(address,repo)}
        idreactor = idreactor + 1
      end
  return tmpReactorList
end

--------------------------------------------------------------------------------

function ProcessingReactor(repo)
  
end

--------------------------------------------------------------------------------

GlobalConfig = GlobalLoadCfg(RepoCfg)
AllReactorInit(RepoCfg)
Reactorlist = PollReactors(RepoCfg)


for i,line in pairs(Reactorlist) do
    print(line["Address"])
end

--------------------------------------------------------------------------------

application = gui.application()

ReactorLabel = {}
GuiReactorSectionStart = 1
for i,Reactor in pairs(Reactorlist) do
  
  application:addChild(gui.panel(1, GuiReactorSectionStart+1, 100, 17, 0x2D2D2D))
  application:addChild(gui.panel(1, GuiReactorSectionStart+1, 100, GuiReactorSectionStart, 0x1F4582))
  LabelName = application:addChild(gui.text(17, GuiReactorSectionStart+1, 0xFFFFFF, "REACTOR "..":"..Reactor["Address"]))
  ReactorLabel[Reactor["Address"]]={Name=LabelName}
  
  GuiReactorSectionStart = GuiReactorSectionStart + 17
end

application.eventHandler = function(application, object, eventname, ...)
    if eventname == "touch" or eventname == "GUI" or eventname == "drag" or eventname == "drop" or eventname == "key_down" or eventname == "key_up" or eventname == nil then
        Reactorlist = PollReactors(RepoCfg)
        ProcessingReactor()
    else                
        gui.alert(eventname)
    end
end
 
--------------------------------------------------------------------------------


application:draw(true)
application:start(1)

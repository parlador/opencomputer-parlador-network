local gui = require("GUI")
component = require("component")
filesystem = require("filesystem")
io = require("io")
os = require("os")
serialization = require("serialization")
term = require("term")
modem = component.modem

ReactorLabel = {}
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
  
 return {Name=ReactorName,SteamTrigger=95,PowerTrigger=95,TempLimit=970,RodLevel=100,RodLevelLimit=100,MasterSwitch=true}
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
    if Reactorlist["Name"] then
       return Reactorlist[ReactorAdresse]["Name"]
    else
       return ReactorLoadCfg(repo,ReactorAdresse)["Name"]
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


GuiReactorSectionStart = 1
for i,Reactor in pairs(Reactorlist) do
  
  --Base + title
  application:addChild(gui.panel(1, GuiReactorSectionStart+1, 160, 17, 0x2D2D2D))
  application:addChild(gui.panel(1, GuiReactorSectionStart+1, 160, GuiReactorSectionStart, 0x1F4582))
  ReactorLabel[Reactor["Address"]]={Name=application:addChild(gui.text(3, GuiReactorSectionStart+1, 0xFFFFFF, "REACTOR "..GlobalConfig["Name"]..":"..Reactor["Name"]))}
  
  -- Reactor Mode
  application:addChild(gui.text(2, GuiReactorSectionStart+3, 0x999999, "Reactor Mode:"))
  if Reactor["ActivelyCooled"] == true then
      ReactorLabel[Reactor["Address"]]={Mode=application:addChild(gui.text(24, GuiReactorSectionStart+3, 0x999999, "Active Cooling"))}
  else
      ReactorLabel[Reactor["Address"]]={Mode=application:addChild(gui.text(24, GuiReactorSectionStart+3, 0x999999, "Passive Cooling"))}
  end
  
  -- Reactor Status
  application:addChild(gui.text(2, GuiReactorSectionStart+4, 0x999999, "Reactor Status:"))
  ReactorLabel[Reactor["Address"]]={Status=application:addChild(gui.text(24, GuiReactorSectionStart+4, 0x999999, "????"))}
  
  -- Reactor Temperature
  application:addChild(gui.text(2, GuiReactorSectionStart+5, 0x999999, "Reactor Temperature:"))
  ReactorLabel[Reactor["Address"]]={ReactorTemperature=application:addChild(gui.text(24, GuiReactorSectionStart+5, 0x999999, "0 C"))}
  
  -- Rod Level
  application:addChild(gui.text(2, GuiReactorSectionStart+6, 0x999999, "Reactor Rod level:"))
  ReactorLabel[Reactor["Address"]]={CurrentRodLevel=application:addChild(gui.text(24, GuiReactorSectionStart+6, 0x999999, "100"))}
  
  -- Fuel Temperature
  application:addChild(gui.text(2, GuiReactorSectionStart+8, 0x999999, "Fuel Temperature:"))
  ReactorLabel[Reactor["Address"]]={FuelTemp=application:addChild(gui.text(24, GuiReactorSectionStart+8, 0x999999, "0 C"))}
  
  -- Fuel Reactivite
  application:addChild(gui.text(2, GuiReactorSectionStart+11, 0x999999, "Fuel Reactivite:"))
  ReactorLabel[Reactor["Address"]]={FuelReactivite=application:addChild(gui.text(24, GuiReactorSectionStart+11, 0x999999, "0 %"))}
  
  -- Fuel Consume Rate
  application:addChild(gui.text(2, GuiReactorSectionStart+12, 0x999999, "Fuel Consume Rate:"))
  ReactorLabel[Reactor["Address"]]={FuelRate=application:addChild(gui.text(24, GuiReactorSectionStart+12, 0x999999, "0 MB/T"))}
  
  -- Fuel Tank
  application:addChild(gui.text(2, GuiReactorSectionStart+13, 0x999999, "Fuel Tank:"))
  ReactorLabel[Reactor["Address"]]={FuelTank=application:addChild(gui.progressBar(24, GuiReactorSectionStart+13, 14, 0xD2DE67, 0xEEEEEE, 0xEEEEEE, 0, true, false))}
  
  -- Waste Tank
  application:addChild(gui.text(2, GuiReactorSectionStart+14, 0x999999, "Waste Tank:"))
  ReactorLabel[Reactor["Address"]]={WasteTank=application:addChild(gui.progressBar(24, GuiReactorSectionStart+14, 14, 0x7900E2, 0xEEEEEE, 0xEEEEEE, 0, true, false))}
  
  -- Steam or power tank/rate
  if Reactor["ActivelyCooled"] == true then
    application:addChild(gui.text(2, GuiReactorSectionStart+15, 0x999999, "Steam Tank:"))

    application:addChild(gui.text(2, GuiReactorSectionStart+16, 0x999999, "Steam Produte Rate:"))
  else
    application:addChild(gui.text(2, GuiReactorSectionStart+15, 0x999999, "Power Bank:"))

    application:addChild(gui.text(2, GuiReactorSectionStart+16, 0x999999, "Power Produte Rate:"))
  end
  
  -- Ouput tank/rate
  ReactorLabel[Reactor["Address"]]={OutputTank=application:addChild(gui.progressBar(24, GuiReactorSectionStart+15, 14, 0xA82B2B, 0xEEEEEE, 0xEEEEEE, 0, true, false))}
  ReactorLabel[Reactor["Address"]]={OutputRate=application:addChild(gui.text(24, GuiReactorSectionStart+16, 0x999999, "0 /T"))}
  
  
  -- control zone
  application:addChild(gui.panel(134, GuiReactorSectionStart+3, 26, 5, 0x2D2D2D))
  application:addChild(gui.panel(134, GuiReactorSectionStart+3, 26, 1, 0x6B1F82))
  application:addChild(gui.text(135, GuiReactorSectionStart+3, 0x999999, "     REACTOR CONTROL    "))
  ReactorLabel[Reactor["Address"]]={switchButton=application:addChild(gui.switch(135, GuiReactorSectionStart+5, 24, 0x66DB66, 0xDB6666, 0xEEEEEE, Reactor["ReactorEnable"]))}

  application:addChild(gui.panel(134, GuiReactorSectionStart+7, 26, 5, 0x2D2D2D))
  application:addChild(gui.panel(134, GuiReactorSectionStart+7, 26, 1, 0x6B1F82))
  application:addChild(gui.text(135, GuiReactorSectionStart+7, 0x999999, "   REACTOR ROD LIMIT    "))
  ReactorLabel[Reactor["Address"]]={SliderLevelLimit=application:addChild(gui.slider(135, GuiReactorSectionStart+8, 24, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 100, Reactor["RodLevelLimit"], false, ""))}


  application:addChild(gui.panel(134, GuiReactorSectionStart+10, 26, 5, 0x2D2D2D))
  application:addChild(gui.panel(134, GuiReactorSectionStart+10, 26, 1, 0x6B1F82))
  application:addChild(gui.text(135, GuiReactorSectionStart+10, 0x999999, " FUEL TEMPERATURE LIMIT "))
  ReactorLabel[Reactor["Address"]]={SliderTempLimit=application:addChild(gui.slider(135, GuiReactorSectionStart+11, 24, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 70, 1870, Reactor["TempLimit"], false, ""))}


  application:addChild(gui.panel(134, GuiReactorSectionStart+13, 26, 5, 0x2D2D2D))
  application:addChild(gui.panel(134, GuiReactorSectionStart+13, 26, 1, 0x6B1F82))
  if Reactor["ActivelyCooled"] == true then
      application:addChild(gui.text(135, GuiReactorSectionStart+13, 0x999999, "   STEAM TANK TRIGGER   "))
      ReactorLabel[Reactor["Address"]]={SliderSteamTrigger=application:addChild(gui.slider(135, GuiReactorSectionStart+14, 24, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 95, Reactor["SteamTrigger"], false, ""))}
  else
      application:addChild(gui.text(135, GuiReactorSectionStart+13, 0x999999, "   POWER BANK TRIGGER   "))
      ReactorLabel[Reactor["Address"]]={SliderPowerTrigger=application:addChild(gui.slider(135, GuiReactorSectionStart+14, 24, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 95, Reactor["PowerTrigger"], false, ""))}
  end
  
  -- line1
  application:addChild(gui.panel(57, 2, 50, 10, 0x2D2D2D))
  application:addChild(gui.panel(57, 2, 50, 1, 0x1F4582))
  --application:addChild(gui.text(57, 2, 0xFFFFFF, "   FUEL TEMPERATURE       "))
  ReactorLabel[Reactor["Address"]]={chartTemperature=application:addChild(gui.chart(57, 3, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x5F63FE, 1, 1, "s", "C", true, {}))}
  application:addChild(gui.panel(57, 12, 50, 1, 0x000000))
  application:addChild(gui.text(57, 12, 0x000000, "                                                  "))
  table.insert(ReactorLabel[Reactor["Address"]]["chartTemperature"].values,1,{0, 0})
  
  application:addChild(gui.panel(109, 2, 50, 10, 0x2D2D2D))
  application:addChild(gui.panel(109, 2, 50, 1, 0x1F4582))
  --application:addChild(GUI.text(109, 2, 0xFFFFFF, "       FUEL TANK           "))
  ReactorLabel[Reactor["Address"]]={chartFuel=application:addChild(gui.chart(109, 3, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xD2DE67, 1, 1, "s", "%", true, {}))}
  application:addChild(gui.panel(109, 12, 50, 1, 0x000000))
  application:addChild(gui.text(109, 12, 0x000000, "                                                  "))
  table.insert(ReactorLabel[Reactor["Address"]]["chartFuel"].values,1,{0, 0})
  
  --line 2
  application:addChild(gui.panel(57, 13, 50, 10, 0x2D2D2D))
  application:addChild(gui.panel(57, 13, 50, 1, 0x1F4582))
  --application:addChild(GUI.text(45, 20, 0xFFFFFF, "    FUEL REACTIVITE      "))
  chartReact = application:addChild(gui.chart(57, 14, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x00FF91, 1, 1, "s", "%", true, {}))
  application:addChild(gui.panel(57, 23, 50, 1, 0x000000))
  application:addChild(gui.text(57, 23, 0x000000, "                                                  "))
  table.insert(chartReact.values,1,{0, 0})

  application:addChild(gui.panel(109, 13, 50, 10, 0x2D2D2D))
  application:addChild(gui.panel(109, 13, 50, 1, 0x1F4582))
  --application:addChild(GUI.text(45, 20, 0xFFFFFF, "    FUEL REACTIVITE      "))
  chartRod = application:addChild(gui.chart(109, 14, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x00FF91, 1, 1, "s", "%", true, {}))
  application:addChild(gui.panel(109, 23, 50, 1, 0x000000))
  application:addChild(gui.text(109, 23, 0x000000, "                                                  "))
  table.insert(chartRod.values,1,{0, 0})

  -- line 3
  application:addChild(gui.panel(57, 24, 50, 10, 0x2D2D2D))
  application:addChild(gui.panel(57, 24, 50, 1, 0x1F4582))
  --application:addChild(GUI.text(73, 20, 0xFFFFFF, "      POWER BANK            "))
  chartPowerOuput = application:addChild(gui.chart(57, 25, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xA82B2B, 1, 1, "s", "RF", true, {}))
  table.insert(chartPowerOuput.values,1,{0, 0})

  application:addChild(gui.panel(109, 24, 50, 10, 0x2D2D2D))
  application:addChild(gui.panel(109, 24, 50, 1, 0x1F4582))
  --application:addChild(GUI.text(73, 20, 0xFFFFFF, "      POWER BANK            "))
  chartPower = application:addChild(gui.chart(109, 25, 50, 10, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xA82B2B, 1, 1, "s", "%", true, {}))
  table.insert(chartPower.values,1,{0, 0})
  
  
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

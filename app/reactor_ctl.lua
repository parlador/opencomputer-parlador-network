local gui = require("GUI")
component = require("component")
filesystem = require("filesystem")
io = require("io")
os = require("os")
serialization = require("serialization")
term = require("term")
modem = component.modem
chartcount = 1
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

function ManageReactor(Reactorlist,ReactorLabel)
  
   for i,Reactor in pairs(Reactorlist) do
   
    if ReactorLabel[Reactor["Address"]]["switchButton"].state == true then
        if Reactor["ActivelyCooled"] == true then
            ReactorActiveCooling(Reactor,ReactorLabel[Reactor["Address"]])
        else
            ReactorPassiveCooling(Reactor,ReactorLabel[Reactor["Address"]])
        end
        ManageTemperatureAndRod(Reactor,ReactorLabel[Reactor["Address"]])
    else
        component.invoke(Reactor["Address"], "setActive", false)
        ReactorLabel[Reactor["Address"]]["Status"].text = "Disabled"
    end
   
   end
    
end

function ReactorActiveCooling(Reactor,Label)
    if round(Reactor["PourcentageHotFuel"],0) < Label["SliderPowerTrigger"].value then
            component.invoke(Reactor["Address"], "setActive", true)
            Label["Status"].text = "Running"
    else
            component.invoke(Reactor["Address"], "setActive", false)
            Label["Status"].text = "Standby"
    end
end

function ReactorPassiveCooling(Reactor,Label)
    if round(Reactor["PourcentagePower"],0) < Label["SliderPowerTrigger"].value then
            component.invoke(Reactor["Address"], "setActive", true)
            Label["Status"].text = "Running"
    else
            component.invoke(Reactor["Address"], "setActive", false)
            Label["Status"].text = "Standby"
    end
end

function ManageTemperatureAndRod(Reactor,Label)
    fueltemp = round(Reactor["FuelTemperature"],0)
    targettemp = Label["SliderTempLimit"].value
    
     if fueltemp > targettemp then
            heatover = (fueltemp - targettemp)
            if (heatover*2) > 99 then
                SetAllRodLevel(100,Reactor,Label)
            elseif (heatover*2) < 1 then
                SetAllRodLevel(0,Reactor,Label)
            else
                SetAllRodLevel((heatover*2),Reactor,Label)
            end
    else
        SetAllRodLevel(0,Reactor,Label)
    end
end

function SetAllRodLevel(LevelSet,Reactor,Label)
   RodLimit = tonumber(Label["SliderLevelLimit"].value)
   
      if LevelSet > RodLimit then
          Label["CurrentRodLevel"].text = RodLimit
          RodLevel = RodLimit
          component.invoke(Reactor["Address"], "setAllControlRodLevels",RodLimit)
      else
          Label["CurrentRodLevel"].text = LevelSet
          RodLevel = LevelSet
          component.invoke(Reactor["Address"], "setAllControlRodLevels",LevelSet)
      end
end

function UpdateUI(Reactorlist,ReactorLabel)
  for i,Reactor in pairs(Reactorlist) do  
    table.insert(ReactorLabel[Reactor["Address"]]["chartFuel"].values, {chartcount, Reactor["PourcentageFuel"]})
   
    table.insert(ReactorLabel[Reactor["Address"]]["chartReact"].values, {chartcount, Reactor["FuelReactivity"]})
 
    table.insert(ReactorLabel[Reactor["Address"]]["chartRod"].values, {chartcount, Reactor["RodLevel"]})
    
 
    table.insert(ReactorLabel[Reactor["Address"]]["chartTemperature"].values, {chartcount, Reactor["FuelTemperature"]})
 
    ReactorLabel[Reactor["Address"]]["ReactorTemperature"].text = round(Reactor["CasingTemperature"],1).." C"
    ReactorLabel[Reactor["Address"]]["FuelTemp"].text = round(Reactor["FuelTemperature"],1).." C"
    ReactorLabel[Reactor["Address"]]["FuelReactivite"].text = round(Reactor["FuelReactivity"],1).." %"
    ReactorLabel[Reactor["Address"]]["FuelRate"].text = round(Reactor["FuelConsumedLastTick"],2).." MB/T"
 
    ReactorLabel[Reactor["Address"]]["FuelTank"].value = round(Reactor["PourcentageFuel"],0)
    ReactorLabel[Reactor["Address"]]["WasteTank"].value = round(Reactor["PourcentageWaste"],0)
 
    if Reactor["ActivelyCooled"] == true then
        ReactorLabel[Reactor["Address"]]["OutputTank"].value = round(Reactor["PourcentageHotFuel"],0)
        table.insert(ReactorLabel[Reactor["Address"]]["chartPower"].values, {chartcount, Reactor["PourcentageHotFuel"]})
        ReactorLabel[Reactor["Address"]]["OutputRate"].text = round(Reactor["HotFluidProducedLastTick"],1).." MB/T"
        table.insert(ReactorLabel[Reactor["chartPowerOuput"].values, {chartcount, Reactor["HotFluidProducedLastTick"]})
    else
        ReactorLabel[Reactor["Address"]]["OutputTank"].value = round(Reactor["PourcentagePower"],0)
        table.insert(ReactorLabel[Reactor["chartPower"].values, {chartcount, Reactor["PourcentagePower"]})
        ReactorLabel[Reactor["Address"]]["OutputRate"].text = round(Reactor["EnergyProducedLastTick"],1).." RF/T"
        table.insert(ReactorLabel[Reactor["chartPowerOuput"].values, {chartcount, Reactor["EnergyProducedLastTick"]})
    end
 
    if tablelength(ReactorLabel[Reactor["Address"]]["chartReact"].values) > 31 then
        table.remove(ReactorLabel[Reactor["Address"]]["chartReact"].values, 1)
        table.insert(ReactorLabel[Reactor["Address"]]["chartReact"].values,1,{chartcount-30, 0})
        table.remove(ReactorLabel[Reactor["Address"]]["chartReact"].values, 2)
 
    end
     if tablelength(ReactorLabel[Reactor["Address"]]["chartRod"].values) > 31 then
        table.remove(ReactorLabel[Reactor["Address"]]["chartRod"].values, 1)
        table.insert(ReactorLabel[Reactor["Address"]]["chartRod"].values,1,{chartcount-30, 0})
        table.remove(ReactorLabel[Reactor["Address"]]["chartRod"].values, 2)
 
    end
    if tablelength(ReactorLabel[Reactor["Address"]]["chartFuel"].values) > 31 then
        table.remove(ReactorLabel[Reactor["Address"]]["chartFuel"].values, 1)
        table.insert(ReactorLabel[Reactor["Address"]]["chartFuel"].values,1,{chartcount-30, 0})
        table.remove(ReactorLabel[Reactor["Address"]]["chartFuel"].values, 2)
 
    end
    if tablelength(ReactorLabel[Reactor["Address"]]["chartPower"].values) > 31 then
        table.remove(ReactorLabel[Reactor["Address"]]["chartPower"].values, 1)
        table.insert(ReactorLabel[Reactor["Address"]]["chartPower"].values,1,{chartcount-30, 0})
        table.remove(ReactorLabel[Reactor["Address"]]["chartPower"].values, 2)
       
    end
    if tablelength(ReactorLabel[Reactor["Address"]]["chartPowerOuput"].values) > 31 then
        table.remove(ReactorLabel[Reactor["Address"]]["chartPowerOuput"].values, 1)
        table.insert(ReactorLabel[Reactor["Address"]]["chartPowerOuput"].values,1,{chartcount-30, 0})
        table.remove(ReactorLabel[Reactor["Address"]]["chartPowerOuput"].values, 2)
       
    end
    if tablelength(ReactorLabel[Reactor["Address"]]["chartTemperature"].values) > 31 then
        table.remove(ReactorLabel[Reactor["Address"]]["chartTemperature"].values, 1)
        table.insert(ReactorLabel[Reactor["Address"]]["chartTemperature"].values,1,{chartcount-30, 0})
        table.remove(ReactorLabel[Reactor["Address"]]["chartTemperature"].values, 2)
 
    end
 end
    chartcount = chartcount + 1
    application:draw(true)
  
end 
  
function UpdateCfg(RepoCfg,ReactorLabel)

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


GuiReactorSectionStart = 0
for i,Reactor in pairs(Reactorlist) do
  
  --Base + title
  application:addChild(gui.panel(1, GuiReactorSectionStart+1, 40, 16, 0x2D2D2D))
  application:addChild(gui.panel(1, GuiReactorSectionStart+1, 40, 1, 0x1F4582))
  ReactorLabel[Reactor["Address"]]={Name=application:addChild(gui.text(3, GuiReactorSectionStart+1, 0xFFFFFF, "REACTOR "..GlobalConfig["Name"]..":"..Reactor["Name"].." INFORMATION"))}
  
  -- Reactor Mode
  application:addChild(gui.text(2, GuiReactorSectionStart+3, 0x999999, "Reactor Mode:"))
  if Reactor["ActivelyCooled"] == true then
      ReactorLabel[Reactor["Address"]]["Mode"]=application:addChild(gui.text(23, GuiReactorSectionStart+3, 0x999999, "Active Cooling"))
  else
      ReactorLabel[Reactor["Address"]]["Mode"]=application:addChild(gui.text(23, GuiReactorSectionStart+3, 0x999999, "Passive Cooling"))
  end
  
  -- Reactor Status
  application:addChild(gui.text(2, GuiReactorSectionStart+4, 0x999999, "Reactor Status:"))
  ReactorLabel[Reactor["Address"]]["Status"]=application:addChild(gui.text(23, GuiReactorSectionStart+4, 0x999999, "????"))
  
  -- Reactor Temperature
  application:addChild(gui.text(2, GuiReactorSectionStart+5, 0x999999, "Reactor Temperature:"))
  ReactorLabel[Reactor["Address"]]["ReactorTemperature"]=application:addChild(gui.text(23, GuiReactorSectionStart+5, 0x999999, "0 C"))
  
  -- Rod Level
  application:addChild(gui.text(2, GuiReactorSectionStart+6, 0x999999, "Reactor Rod level:"))
  ReactorLabel[Reactor["Address"]]["CurrentRodLevel"]=application:addChild(gui.text(23, GuiReactorSectionStart+6, 0x999999, "100"))
  
  -- Fuel Temperature
  application:addChild(gui.text(2, GuiReactorSectionStart+8, 0x999999, "Fuel Temperature:"))
  ReactorLabel[Reactor["Address"]]["FuelTemp"]=application:addChild(gui.text(23, GuiReactorSectionStart+8, 0x999999, "0 C"))
  
  -- Fuel Reactivite
  application:addChild(gui.text(2, GuiReactorSectionStart+9, 0x999999, "Fuel Reactivite:"))
  ReactorLabel[Reactor["Address"]]["FuelReactivite"]=application:addChild(gui.text(23, GuiReactorSectionStart+9, 0x999999, "0 %"))
  
  -- Fuel Consume Rate
  application:addChild(gui.text(2, GuiReactorSectionStart+10, 0x999999, "Fuel Consume Rate:"))
  ReactorLabel[Reactor["Address"]]["FuelRate"]=application:addChild(gui.text(23, GuiReactorSectionStart+10, 0x999999, "0 MB/T"))
  
  -- Fuel Tank
  application:addChild(gui.text(2, GuiReactorSectionStart+11, 0x999999, "Fuel Tank:"))
  ReactorLabel[Reactor["Address"]]["FuelTank"]=application:addChild(gui.progressBar(23, GuiReactorSectionStart+11, 14, 0xD2DE67, 0xEEEEEE, 0xEEEEEE, 0, true, false))
  
  -- Waste Tank
  application:addChild(gui.text(2, GuiReactorSectionStart+12, 0x999999, "Waste Tank:"))
  ReactorLabel[Reactor["Address"]]["WasteTank"]=application:addChild(gui.progressBar(23, GuiReactorSectionStart+12, 14, 0x7900E2, 0xEEEEEE, 0xEEEEEE, 0, true, false))
  
  -- Steam or power tank/rate
  if Reactor["ActivelyCooled"] == true then
    application:addChild(gui.text(2, GuiReactorSectionStart+14, 0x999999, "Steam Tank:"))

    application:addChild(gui.text(2, GuiReactorSectionStart+15, 0x999999, "Steam Produte Rate:"))
  else
    application:addChild(gui.text(2, GuiReactorSectionStart+14, 0x999999, "Power Bank:"))

    application:addChild(gui.text(2, GuiReactorSectionStart+15, 0x999999, "Power Produte Rate:"))
  end
  
  -- Ouput tank/rate
  ReactorLabel[Reactor["Address"]]["OutputTank"]=application:addChild(gui.progressBar(23, GuiReactorSectionStart+14, 14, 0xA82B2B, 0xEEEEEE, 0xEEEEEE, 0, true, false))
  ReactorLabel[Reactor["Address"]]["OutputRate"]=application:addChild(gui.text(23, GuiReactorSectionStart+15, 0x999999, "0 /T"))
  
  
  -- control zone
  application:addChild(gui.panel(135, GuiReactorSectionStart+1, 26, 5, 0x2D2D2D))
  application:addChild(gui.panel(135, GuiReactorSectionStart+1, 26, 1, 0x6B1F82))
  application:addChild(gui.text(136, GuiReactorSectionStart+1, 0xFFFFFF, "     REACTOR CONTROL    "))
  ReactorLabel[Reactor["Address"]]["switchButton"]=application:addChild(gui.switch(136, GuiReactorSectionStart+3, 24, 0x66DB66, 0xDB6666, 0xEEEEEE, Reactor["ReactorEnable"]))

  application:addChild(gui.panel(135, GuiReactorSectionStart+5, 26, 5, 0x2D2D2D))
  application:addChild(gui.panel(135, GuiReactorSectionStart+5, 26, 1, 0x6B1F82))
  application:addChild(gui.text(136, GuiReactorSectionStart+5, 0xFFFFFF, "   REACTOR ROD LIMIT    "))
  ReactorLabel[Reactor["Address"]]["SliderLevelLimit"]=application:addChild(gui.slider(136, GuiReactorSectionStart+6, 24, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 100, Reactor["RodLevelLimit"], false, ""))


  application:addChild(gui.panel(135, GuiReactorSectionStart+9, 26, 5, 0x2D2D2D))
  application:addChild(gui.panel(135, GuiReactorSectionStart+9, 26, 1, 0x6B1F82))
  application:addChild(gui.text(136, GuiReactorSectionStart+9, 0xFFFFFF, " FUEL TEMPERATURE LIMIT "))
  ReactorLabel[Reactor["Address"]]["SliderTempLimit"]=application:addChild(gui.slider(136, GuiReactorSectionStart+10, 24, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 70, 1870, Reactor["TempLimit"], false, ""))


  application:addChild(gui.panel(135, GuiReactorSectionStart+13, 26, 5, 0x2D2D2D))
  application:addChild(gui.panel(135, GuiReactorSectionStart+13, 26, 1, 0x6B1F82))
  if Reactor["ActivelyCooled"] == true then
      application:addChild(gui.text(136, GuiReactorSectionStart+13, 0xFFFFFF, "   STEAM TANK TRIGGER   "))
      ReactorLabel[Reactor["Address"]]["SliderSteamTrigger"]=application:addChild(gui.slider(136, GuiReactorSectionStart+14, 24, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 95, Reactor["SteamTrigger"], false, ""))
  else
      application:addChild(gui.text(136, GuiReactorSectionStart+13, 0xFFFFFF, "   POWER BANK TRIGGER   "))
      ReactorLabel[Reactor["Address"]]["SliderPowerTrigger"]=application:addChild(gui.slider(136, GuiReactorSectionStart+14, 24, 0x20E8DB, 0x0, 0xFFFFFF, 0x20E8DB, 5, 95, Reactor["PowerTrigger"], false, ""))
  end
  
  -- line1
  application:addChild(gui.panel(39, 1, 32, 9, 0x2D2D2D))
  application:addChild(gui.panel(39, 1, 32, 1, 0xCE9200))
  application:addChild(gui.text(39, 1, 0xFFFFFF, "      FUEL TEMPERATURE"))
  ReactorLabel[Reactor["Address"]]["chartTemperature"]=application:addChild(gui.chart(39, 2, 32, 8, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x5F63FE, 1, 1, "s", "C", true, {}))
  --application:addChild(gui.panel(57, 12, 33, 1, 0x000000))
  --application:addChild(gui.text(57, 12, 0x000000, "                                                  "))
  table.insert(ReactorLabel[Reactor["Address"]]["chartTemperature"].values,1,{0, 0})
  
  application:addChild(gui.panel(71, 1, 32, 9, 0x2D2D2D))
  application:addChild(gui.panel(71, 1, 32, 1, 0xCE9200))
  application:addChild(gui.text(71, 1, 0xFFFFFF, "      FUEL TANK"))
  ReactorLabel[Reactor["Address"]]["chartFuel"]=application:addChild(gui.chart(71, 2, 32, 8, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xD2DE67, 1, 1, "s", "%", true, {}))
  --application:addChild(gui.panel(109, 12, 50, 1, 0x000000))
  --application:addChild(gui.text(109, 12, 0x000000, "                                                  "))
  table.insert(ReactorLabel[Reactor["Address"]]["chartFuel"].values,1,{0, 0})
  
  
  application:addChild(gui.panel(103, 1, 32, 9, 0x2D2D2D))
  application:addChild(gui.panel(103, 1, 32, 1, 0xCE9200))
  application:addChild(gui.text(103, 1, 0xFFFFFF, "      FUEL REACTIVITE"))
  ReactorLabel[Reactor["Address"]]["chartReact"]=application:addChild(gui.chart(103, 2, 32, 8, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x00FF91, 1, 1, "s", "%", true, {}))
  --application:addChild(gui.panel(57, 23, 50, 1, 0x000000))
  --application:addChild(gui.text(57, 23, 0x000000, "                                                  "))
  table.insert(ReactorLabel[Reactor["Address"]]["chartReact"].values,1,{0, 0})

  --line 2
  application:addChild(gui.panel(39, 9, 32, 9, 0x2D2D2D))
  application:addChild(gui.panel(39, 9, 32, 1, 0xCE9200))
  application:addChild(gui.text(39, 9, 0xFFFFFF, "      ROD LEVEL"))
  ReactorLabel[Reactor["Address"]]["chartRod"]=application:addChild(gui.chart(39, 10, 32, 8, 0xEEEEEE, 0xAAAAAA, 0x888888, 0x00FF91, 1, 1, "s", "%", true, {}))
  --application:addChild(gui.panel(109, 23, 50, 1, 0x000000))
  --application:addChild(gui.text(109, 23, 0x000000, "                                                  "))
  table.insert(ReactorLabel[Reactor["Address"]]["chartRod"].values,1,{0, 0})

  application:addChild(gui.panel(71, 9, 32, 9, 0x2D2D2D))
  application:addChild(gui.panel(71, 9, 32, 1, 0xCE9200))
  application:addChild(gui.text(71, 9, 0xFFFFFF, "      POWER RATE"))
  ReactorLabel[Reactor["Address"]]["chartPowerOuput"]=application:addChild(gui.chart(71, 10, 32, 8, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xA82B2B, 1, 1, "s", "RF", true, {}))
  table.insert(ReactorLabel[Reactor["Address"]]["chartPowerOuput"].values,1,{0, 0})

  application:addChild(gui.panel(103, 9, 32, 9, 0x2D2D2D))
  application:addChild(gui.panel(103, 9, 32, 1, 0xCE9200))
  application:addChild(gui.text(103, 9, 0xFFFFFF, "      POWER BANK"))
  ReactorLabel[Reactor["Address"]]["chartPower"]=application:addChild(gui.chart(103, 10, 32, 8, 0xEEEEEE, 0xAAAAAA, 0x888888, 0xA82B2B, 1, 1, "s", "%", true, {}))
  table.insert(ReactorLabel[Reactor["Address"]]["chartPower"].values,1,{0, 0})
  
  application:addChild(gui.panel(1, 17, 160, 1, 0x000000))
  
  GuiReactorSectionStart = GuiReactorSectionStart + 16
end

application.eventHandler = function(application, object, eventname, ...)
    if eventname == "touch" or eventname == "GUI" or eventname == "drag" or eventname == "drop" or eventname == "key_down" or eventname == "key_up" or eventname == nil then
        Reactorlist = PollReactors(RepoCfg)
        UpdateUI(Reactorlist,ReactorLabel)
        UpdateCfg(RepoCfg,ReactorLabel)
        ManageReactor(Reactorlist,ReactorLabel)
    else                
        gui.alert(eventname)
    end
end
 
--------------------------------------------------------------------------------


application:draw(true)
application:start(1)

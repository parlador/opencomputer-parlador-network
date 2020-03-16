local gui = require("GUI")
component = require("component")
filesystem = require("filesystem")
io = require("io")
os = require("os")
serialization = require("serialization")
term = require("term")
modem = component.modem

RepoCfg = "/etc/ae2/"

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

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------

GlobalConfig = GlobalLoadCfg(RepoCfg)





--------------------------------------------------------------------------------


application.eventHandler = function(application, object, eventname, ...)
    if eventname == "touch" or eventname == "GUI" or eventname == "drag" or eventname == "drop" or eventname == "key_down" or eventname == "key_up" or eventname == nil then



    else                
        gui.alert(eventname)
    end
end
 
--------------------------------------------------------------------------------


application:draw(true)
application:start(1)
application = gui.application()

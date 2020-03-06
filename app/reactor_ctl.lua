local GUI = require("GUI")
component = require("component")
Reactorlist = {}
 
--------------------------------------------------------------------------------
 
for address, name in component.list("bigreactor", false) do
  print(name.." : "..address)
  Reactorlist[address]["addr"]=address
end



for i,line in ipairs(Reactorlist) do
    print(line["addr"])
end

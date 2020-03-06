local GUI = require("GUI")
component = require("component")

 
--------------------------------------------------------------------------------
 
for address, name in component.list("bigreactor", false) do
  print(name..." : "...address)
end

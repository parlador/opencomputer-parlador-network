function UpdateGUI()
    table.insert(chartFuel.values, {i, GetPourcentageFuel()})
   
    table.insert(chartReact.values, {i, component.invoke(ReactorAdresse, "getFuelReactivity")})
 
    table.insert(chartRod.values, {i, RodLevel})
    
 
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
 
    if tablelength(chartReact.values) > 31 then
        table.remove(chartReact.values, 1)
        table.insert(chartReact.values,1,{i-30, 0})
        table.remove(chartReact.values, 2)
 
    end
     if tablelength(chartRod.values) > 31 then
        table.remove(chartRod.values, 1)
        table.insert(chartRod.values,1,{i-30, 0})
        table.remove(chartRod.values, 2)
 
    end
    if tablelength(chartFuel.values) > 31 then
        table.remove(chartFuel.values, 1)
        table.insert(chartFuel.values,1,{i-30, 0})
        table.remove(chartFuel.values, 2)
 
    end
    if tablelength(chartPower.values) > 31 then
        table.remove(chartPower.values, 1)
        table.insert(chartPower.values,1,{i-30, 0})
        table.remove(chartPower.values, 2)
       
    end
    if tablelength(chartPowerOuput.values) > 31 then
        table.remove(chartPowerOuput.values, 1)
        table.insert(chartPowerOuput.values,1,{i-30, 0})
        table.remove(chartPowerOuput.values, 2)
       
    end
    if tablelength(chartTemperature.values) > 31 then
        table.remove(chartTemperature.values, 1)
        table.insert(chartTemperature.values,1,{i-30, 0})
        table.remove(chartTemperature.values, 2)
 
    end
 
    i = i + 1
    application:draw(true)
 
end

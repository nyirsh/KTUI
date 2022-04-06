diceTabR = {}
diceTabB = {}

local size = 1
local dice6Image = ''
local diceColor = Color(1.0,1.0,1.0)
local WantedDiceNumber=1
local killTeam = 0
local autoRoll2 = 0
local frame = 0
local menu = 1
local enableUI = 0
local tuto = 0
local isRolling = 0

function onLoad()
  self.registerCollisions(false)
  guid = self.getGUID();

  if Global.UI.getAttribute("diceUI", "id") == nil then
    local oldUI = Global.UI.getXml()
    if oldUI == nil then
			oldUI = ""
		end

    Global.UI.setXml(oldUI .. [[
    <Panel id="diceUI"
      allowDragging="true" restrictDraggingToParentBounds="false" returnToOriginalPositionWhenReleased="false"
      height="80" width="500" position="-290 -495 -20" rotation= "0 0 0" childAlignment="MiddleCenter" active="false">
        <HorizontalLayout id="panelID" childAlignment="MiddleCenter">
          <VerticalLayout>
            <GridLayout cellSize="60 40" childAlignment="MiddleCenter">
              <Button onClick="]]..guid..[[/spawnKill(1)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">1D</Text></Button>
              <Button onClick="]]..guid..[[/spawnKill(2)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">2D</Text></Button>
              <Button onClick="]]..guid..[[/spawnKill(3)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">3D</Text></Button>
            </GridLayout>
            <GridLayout cellSize="60 40" childAlignment="MiddleCenter">
              <Button onClick="]]..guid..[[/spawnKill(4)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">4D</Text></Button>
              <Button onClick="]]..guid..[[/spawnKill(5)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">5D</Text></Button>
              <Button onClick="]]..guid..[[/spawnKill(6)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">6D</Text></Button>
            </GridLayout>
          </VerticalLayout>
          <Button onClick="]]..guid..[[/roll()" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)" minWidth="80"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">ROLL</Text></Button>
          <VerticalLayout>
            <GridLayout cellSize="60 40" childAlignment="MiddleCenter">
              <Button onClick="]]..guid..[[/selectValueP(1)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">All</Text></Button>
              <Button onClick="]]..guid..[[/selectValueP(2)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">2+</Text></Button>
              <Button onClick="]]..guid..[[/selectValueP(3)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">3+</Text></Button>
            </GridLayout>
            <GridLayout cellSize="60 40" childAlignment="MiddleCenter">
              <Button onClick="]]..guid..[[/selectValueP(4)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">4+</Text></Button>
              <Button onClick="]]..guid..[[/selectValueP(5)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">5+</Text></Button>
              <Button onClick="]]..guid..[[/selectValueP(6)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">6+</Text></Button>
            </GridLayout>
          </VerticalLayout>
        </HorizontalLayout>
      </Panel>
      <Panel id="diceZoomUI"
        allowDragging="true" restrictDraggingToParentBounds="false" returnToOriginalPositionWhenReleased="false" active="false" height="280" width="100">
        <Button onClick="]]..guid..[[/zoom()" height="280" width="100" position="-900 -130 -20" rotation="0 0 0" childAlignment="MiddleCenter" colors="rgba(0.2,0.2,0.2,0.7)|rgba(0.2,0.2,0.2,0.9)|rgba(0.2,0.2,0.2,0.9)|rgba(0.2,0.2,0.2,0.9)"></Button>
        <Panel height="280" width="100" position="-900 -130 -20" rotation="0 0 0" childAlignment="MiddleCenter">
          <HorizontalLayout childAlignment="MiddleCenter">
            <VerticalLayout>
              <Text fontStyle="bold" fontSize="20" id="r1" color="#f94231">0</Text>
              <Text fontStyle="bold" fontSize="20" id="r2" color="#f94231">0</Text>
              <Text fontStyle="bold" fontSize="20" id="r3" color="#f94231">0</Text>
              <Text fontStyle="bold" fontSize="20" id="r4" color="#f94231">0</Text>
              <Text fontStyle="bold" fontSize="20" id="r5" color="#f94231">0</Text>
              <Text fontStyle="bold" fontSize="20" id="r6" color="#f94231">0</Text>
              <Text fontStyle="bold" fontSize="20" id="rA" color="#f94231">0</Text>
            </VerticalLayout>
            <VerticalLayout>
              <Button onClick="]]..guid..[[/selectValue(1)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="25" color="#CCCCCC">1</Text></Button>
              <Button onClick="]]..guid..[[/selectValue(2)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="25" color="#CCCCCC">2</Text></Button>
              <Button onClick="]]..guid..[[/selectValue(3)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="25" color="#CCCCCC">3</Text></Button>
              <Button onClick="]]..guid..[[/selectValue(4)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="25" color="#CCCCCC">4</Text></Button>
              <Button onClick="]]..guid..[[/selectValue(5)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="25" color="#CCCCCC">5</Text></Button>
              <Button onClick="]]..guid..[[/selectValue(6)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="25" color="#CCCCCC">6</Text></Button>
              <Button colors="rgba(0.78,0.78,0.78,0.0)|rgba(0.78,0.78,0.78,0.0)|rgba(0.78,0.78,0.78,0.0)|rgba(0.78,0.78,0.78,0.0)"><Text fontStyle="bold" fontSize="25" color="#CCCCCC">=</Text></Button>
            </VerticalLayout>
            <VerticalLayout>
              <Text fontStyle="bold" fontSize="20" id="b1" color="#55adf4">0</Text>
              <Text fontStyle="bold" fontSize="20" id="b2" color="#55adf4">0</Text>
              <Text fontStyle="bold" fontSize="20" id="b3" color="#55adf4">0</Text>
              <Text fontStyle="bold" fontSize="20" id="b4" color="#55adf4">0</Text>
              <Text fontStyle="bold" fontSize="20" id="b5" color="#55adf4">0</Text>
              <Text fontStyle="bold" fontSize="20" id="b6" color="#55adf4">0</Text>
              <Text fontStyle="bold" fontSize="20" id="bA" color="#55adf4">0</Text>
            </VerticalLayout>
          </HorizontalLayout>
        </Panel>
      </Panel>]])
  end
end

function askSpawn(args)
  zoom(args["player"])
  spawnKill(args["player"],args["number"],args["auto"])
end

function spawnKill(player,number,autoRoll)
  deleteDice(obj, player.color)

  for i=1, number, 1 do
    if dice6Image == '' then
      spawnParams = {
        type              = 'Die_6',
        position          = self.getPosition(),
        rotation          = {x=-90, y=0, z=0},
        scale             = {x=1+((size-1)*2), y=1+((size-1)*2), z=1+((size-1)*2)},
        sound             = true,
        snap_to_grid      = false,
        callback_function = function(obj) spawn_callback(obj,player.color,autoRoll,dice6Image,false,key) end
      }
    else
      spawnParams = {
        type              = 'Custom_Dice',
        position          = self.getPosition(),
        rotation          = {x=-90, y=0, z=0},
        scale             = {x=1+((size-1)*2), y=1+((size-1)*2), z=1+((size-1)*2)},
        sound             = true,
        snap_to_grid      = false,
        callback_function = function(obj) spawn_callback(obj,player.color,autoRoll,dice6Image,true,key) end
      }
    end
    spawnObject(spawnParams)
  end
end

function spawn_callback(obj,player,autoRoll,diceImage,custom,key)
  local newobj
  local timeToWait = 0.3
  if custom == true then
    params = {
      image = diceImage,
      type=1,
    }
    obj.setCustomObject(params)
    newobj = obj.reload()
    timeToWait = 0.5
  else
    newobj = obj
  end
  if player == "Red" then
    table.insert(diceTabR,newobj)
  end
  if player == "Blue" then
    table.insert(diceTabB,newobj)
  end
  Wait.condition(
    function()
      newobj.addToPlayerSelection(player)
      newobj.setColorTint(diceColor)
      if autoRoll2 == 1 or autoRoll == 1 then
          Wait.time(function() roll(Player[player]) end,timeToWait)
      end
    end
    ,
    function() -- Condition function
        return regroup(player)
    end)
end

function regroup(player)
  local buff = true
  local offset = 4.8
  if player=="Red" then
    offset = -offset
  end
  fixValue(player)
  getDiceNumber(player)

  for key,value in pairs(getGrid(getDiceNumber(player),-1,-1,2*size,offset)) do
    if player=="Red" then
      diceTabR[key].setRotation({x=diceTabR[key].getRotation().x,y=self.getRotation().y,z=diceTabR[key].getRotation().z})

      if diceTabR[key].setPositionSmooth(value, false, true) == false then
        buff = false
      end
    else
      diceTabB[key].setRotation({x=diceTabB[key].getRotation().x,y=self.getRotation().y,z=diceTabB[key].getRotation().z})

      if diceTabB[key].setPositionSmooth(value, false, true) == false then
        buff = false
      end
    end
  end
  return buff
end

function getGrid(number,offx,offy,space,offset)
  local grid = {}
  local counter = 0
  if number > 3 then
    counter = 1
  end
  if number > 0 then
    table.insert(grid, getPoint(-counter + offset,0))
  end
  if number > 1 then
    table.insert(grid, getPoint(-counter + offset,2))
  end
  if number > 2 then
    table.insert(grid, getPoint(-counter + offset,-2))
  end
  if number > 3 then
    table.insert(grid, getPoint(counter + offset,2))
  end
  if number > 4 then
    table.insert(grid, getPoint(counter + offset,0))
  end
  if number > 5 then
    table.insert(grid, getPoint(counter + offset,-2))
  end

  return grid
end

function getPoint(relativeX, relativeZ)
  local pos = Vector(self.getPosition().x,self.getPosition().y,self.getPosition().z)
  local rot = self.getRotation()
  local angleY = -math.rad(rot.y -90)
  local newX = (relativeX * math.cos(angleY) - relativeZ * math.sin(angleY)) + pos.x
  local newY = pos.y + 4
  local newZ = (relativeZ * math.cos(angleY) + relativeX * math.sin(angleY)) + pos.z
  local final = vector(newX, newY, newZ)
  return final
end

function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function fixValue(player)
  if player == "Red" then
    for key,value in pairs(diceTabR) do
      if value != nil then
        value.setValue(value.getValue())
      end
    end
  else
    for key,value in pairs(diceTabB) do
      if value != nil then
        value.setValue(value.getValue())
      end
    end
  end
end

function deleteDice(obj, player)
  if player == "Red" then
    for key,value in pairs(diceTabR) do
      if value != nil then
        destroyObject(value)
      end
    end
  else
    for key,value in pairs(diceTabB) do
      if value != nil then
        destroyObject(value)
      end
    end
  end
  getDiceNumber(player)
end

function getDiceNumber(player)
  local diceNumber = 0
  local diceTabTemp = {}
  if player == "Red" then
    for key,value in pairs(diceTabR) do
      if value != nil then
        diceNumber = diceNumber + 1
        table.insert(diceTabTemp,value)
      end
    end
    diceTabR = diceTabTemp
  else
    for key,value in pairs(diceTabB) do
      if value != nil then
        diceNumber = diceNumber + 1
        table.insert(diceTabTemp,value)
      end
    end
    diceTabB = diceTabTemp
  end
  return diceNumber
end

function setDiceValue()
  all = 0
  for i=1,6 do
    buff = 0
    for k,v in ipairs(diceTabR) do
      if v != nil and v.getValue() == i  then
        buff = buff + 1
      end
    end
    all = all + buff
    self.UI.setValue('r'..i,buff)
    Global.UI.setValue('r'..i,buff)
  end

  self.UI.setValue('rA',all)
  Global.UI.setValue('rA',all)

  all = 0
  for i=1,6 do
    buff = 0
    for k,v in ipairs(diceTabB) do
      if v != nil and v.getValue() == i  then
        buff = buff + 1
      end
    end
    all = all + buff
    self.UI.setValue('b'..i,buff)
    Global.UI.setValue('b'..i,buff)
  end

  self.UI.setValue('bA',all)
  Global.UI.setValue('bA',all)
end

function onUpdate()
  if frame > 20 then
    frame = 0
    setDiceValue()
  else
    frame = frame +1
  end
end

function roll(player)
  if getDiceNumber(player.color) != 0 then
    for key,value in pairs(Player[player.color].getSelectedObjects()) do
      value.roll()
      value.roll()
    end
  end
  if isRolling == 0 then
    isRolling = 1
    Wait.time(function() order(player.color) end, 2.2)
  end
end

function order(player)
  fixValue(player)

  for diceValue=1, 6, 1 do
    local diceIndex = 0
    local tabLength = 0
    local diceTabTemp = {}
    if player =="Red" then
      for key,value in pairs(diceTabR) do
        if diceTabR[key] != nil then
          if diceTabR[key].getRotationValue() == diceValue then
            table.insert(diceTabTemp, diceTabR[key])
            tabLength = tabLength + 1
          end
        end
      end
      local count = 0
      for key,value in pairs(diceTabTemp) do
        diceTabTemp[key].setRotation({x=diceTabTemp[key].getRotation().x,y=self.getRotation().y,z=diceTabTemp[key].getRotation().z})
        diceTabTemp[key].setPositionSmooth(getPoint(-count-2, (-diceValue*1.17)+4.66),false, true)
        count = count + 1.1
      end
    else
      for key,value in pairs(diceTabB) do
        if diceTabB[key] != nil then
          if diceTabB[key].getRotationValue() == diceValue then
            table.insert(diceTabTemp, diceTabB[key])
            tabLength = tabLength + 1
          end
        end
      end
      local count = 0
      for key,value in pairs(diceTabTemp) do
        diceTabTemp[key].setRotation({x=diceTabTemp[key].getRotation().x,y=self.getRotation().y,z=diceTabTemp[key].getRotation().z})
        diceTabTemp[key].setPositionSmooth(getPoint(count+2, (-diceValue*1.17)+4.66),false, true)
        count = count + 1.1
      end
    end
  end
  printresultsTable(player)
end

function selectValueP(player,valueDice)
  if destroyTimer == 1 then
    destroyTimer = 0
    destroyValueP(player.color,valueDice)
  else
    destroyTimer = 1
    Wait.time(timerDestroy,0.25)
    Player[player.color].clearSelectedObjects()
    if player.color == "Red" then
      for key,value in pairs(diceTabR) do
        if value != nil and value.getRotationValue() >= tonumber(valueDice) then
          value.addToPlayerSelection(player.color)
        end
      end
    else
      for key,value in pairs(diceTabB) do
        if value != nil and value.getRotationValue() >= tonumber(valueDice) then
          value.addToPlayerSelection(player.color)
        end
      end
    end
    getDiceNumber(player.color)
  end
end

function selectValue(player,valueDice)
  Player[player.color].clearSelectedObjects()
  if player.color == "Red" then
    for key,value in pairs(diceTabR) do
      if value != nil and value.getRotationValue() == tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  else
    for key,value in pairs(diceTabB) do
      if value != nil and value.getRotationValue() == tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  end
  getDiceNumber(player.color)
end

function destroyValueP(player,valueDice)
  if(valueDice == "1") then
    valueDice = "7"
  end

  if player == "Red" then
    for key,value in pairs(diceTabR) do
      if value != nil and value.getRotationValue() < tonumber(valueDice) then
        destroyObject(value)
      end
    end
  else
    for key,value in pairs(diceTabB) do
      if value != nil and value.getRotationValue() < tonumber(valueDice) then
        destroyObject(value)
      end
    end
  end
  getDiceNumber(player)
  selectAll(player)
end

function selectAll(player)
  Player[player].clearSelectedObjects()

  if player == "Red" then
    for key,value in pairs(diceTabR) do
      if value != nil then
        value.addToPlayerSelection(player)
      end
    end
  else
    for key,value in pairs(diceTabB) do
      if value != nil then
        value.addToPlayerSelection(player)
      end
    end
  end
  getDiceNumber(player)
end

destroyTimer = 0

function timerDestroy()
  destroyTimer = 0
end

function toggleMenu(player,value,id)
  if menu == 0 then
    menu = 1
    self.UI.show('menu')
  else
    menu = 0
    self.UI.hide('menu')
  end
end

function toggleUI(player)
  local color = player.color

  if color ~= "Blue" and color ~= "Red" then
    return
  end

  if enablePlayerUI == nil then
    enablePlayerUI = {
      Blue = false,
      Red = false
    }
  end

  if enablePlayerUI[color] == false then
    enablePlayerUI[color] = true
  else
    enablePlayerUI[color] = false
  end

  local visibility = ""
  if enablePlayerUI["Blue"] == true then
    visibility = "Blue"
  end

  if enablePlayerUI["Red"] == true then
    if visibility ~= "" then
      visibility = visibility.."|"
    end
    visibility = visibility.."Red"
  end

  if visibility == "" then
    UI.setAttribute('diceUI', 'active', 'false')
    UI.setAttribute('dicePrintUI', 'active', 'false')
    UI.setAttribute('diceZoomUI', 'active', 'false')
  else
    UI.setAttribute('diceUI', 'active', 'true')
    UI.setAttribute('dicePrintUI', 'active', 'true')
    UI.setAttribute('diceZoomUI', 'active', 'true')
  end

  UI.setAttribute('diceUI', 'visibility', visibility)
  UI.setAttribute('dicePrintUI', 'visibility', visibility)
  UI.setAttribute('diceZoomUI', 'visibility', visibility)
end

function toggleRoll()
  if autoRoll2 == 0 then
    autoRoll2 = 1
    self.UI.setAttribute('autoB', 'color', '#9cd310')
  else
    autoRoll2 = 0
    self.UI.setAttribute('autoB', 'color', '#cccccc')
  end
end

function toggleTuto()
  if tuto == 0 then
    tuto = 1
    self.UI.setAttribute('tuto', 'active', 'true')
    self.UI.setAttribute('tutoB', 'color', '#9cd310')
  else
    tuto = 0
    self.UI.setAttribute('tuto', 'active', 'false')
    self.UI.setAttribute('tutoB', 'color', '#cccccc')
  end
end

function zoom(player)
  local targetPos = Vector(0,0, 0)
  Player[player.color].lookAt(
    {
      position = self.getPosition(),
      pitch    = self.getRotation().x + 75,
      yaw      = self.getRotation().y + 270,
      distance = 20*size,
    })
end

function setDice(args)
  if args["player"] == "Red" then
    diceTabR = args["diceTabTemp"]
    for key,value in pairs(diceTabR) do
      diceTabR[key].setRotation({x=diceTabR[key].getRotation().x,y=self.getRotation().y,z=diceTabR[key].getRotation().z})
    end
  else
    diceTabB = args["diceTabTemp"]
    for key,value in pairs(diceTabB) do
      diceTabB[key].setRotation({x=diceTabB[key].getRotation().x,y=self.getRotation().y,z=diceTabB[key].getRotation().z})
    end
  end
  selectAll(args["player"])
end

function printresultsTable(playerColor)
  isRolling = 0
  result = ""
  local description = {'Ones.', 'Twos.', 'Threes.', 'Fours.', 'Fives.', 'Sixes.', 'Sevens.', 'Eights.', 'Nines.', 'Tens.', 'Elevens.', 'Twelves.', 'Thirteens.', 'Fourteens.', 'Fifteens.', 'Sixteens.', 'Seventeens', 'Eighteens.', 'Nineteens.', 'Twenties.'}
  local resultsTable = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  if playerColor == "Red" then
    for i=1,6,1 do
      for key,value in pairs(diceTabR) do
        if value.getValue() == i then
          resultsTable[i] = resultsTable[i]+1
        end
      end
      if resultsTable[i] != 0 then
        result = result .. " " .. resultsTable[i] .. " " .. description[i]
      end
    end
  else
    for i=1,6,1 do
      for key,value in pairs(diceTabB) do
        if value.getValue() == i then
          resultsTable[i] = resultsTable[i]+1
        end
      end
      if resultsTable[i] != 0 then
        result = result .. " " .. resultsTable[i] .. " " .. description[i]
      end
    end
  end

  local time = '[' .. os.date("%H") .. ':' .. os.date("%M") .. ':' .. os.date("%S") .. ' UTC] '
  if playerColor == nil then
    printToAll('\n*******************************************************\n' .. time .. '~UNKNOWN PLAYER~ rolls:\n' .. result, {1, 1, 1})
  else
    printToAll('\n*******************************************************\n' .. time .. Player[playerColor].steam_name .. ' rolls:\n' .. result, stringColorToRGB(playerColor))
  end

  for k,v in ipairs(resultsTable) do
	   resultsTable[k] = 0
   end
end

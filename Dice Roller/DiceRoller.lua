math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,7))+tonumber(tostring(os.clock()):reverse():sub(1,7)))

diceTabL = {}
diceTabR = {}

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
local isRolling = {}

function onLoad()
  leftColor = "Red"
  rightColor = "Blue"

  self.registerCollisions(false)

  Wait.frames(function()
    displayGlobalUI()
  end, 10)
end

function displayGlobalUI()
  guid = self.getGUID();

  if Global.UI.getAttribute("diceUI", "id") == nil then
    local oldUI = Global.UI.getXml()
    if oldUI == nil then
			oldUI = ""
		end

    Global.UI.setXml(oldUI .. [[
    <Panel id="diceUI"
      allowDragging="true" restrictDraggingToParentBounds="false" returnToOriginalPositionWhenReleased="false"
      height="80" width="500" position="653 -495 -20" rotation= "0 0 0" childAlignment="MiddleCenter" active="false">
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
              <Button onClick="]]..guid..[[/selectValueP(0)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="25" color="#CCCCCC">Low</Text></Button>
              <Button onClick="]]..guid..[[/selectValueP(1)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">1</Text></Button>
              <Button onClick="]]..guid..[[/selectValueP(2)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">2-</Text></Button>
            </GridLayout>
            <GridLayout cellSize="60 40" childAlignment="MiddleCenter">
              <Button onClick="]]..guid..[[/selectValueP(3)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">3-</Text></Button>
              <Button onClick="]]..guid..[[/selectValueP(4)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">4-</Text></Button>
              <Button onClick="]]..guid..[[/selectValueP(5)" colors="#282C34|#b50f00|#C8C8C8|rgba(0.78,0.78,0.78,0.5)"><Text fontStyle="bold" fontSize="30" color="#CCCCCC">5-</Text></Button>
            </GridLayout>
          </VerticalLayout>
        </HorizontalLayout>
      </Panel>
      <Panel id="diceZoomUI" color="rgba(0.2,0.2,0.2,0.7)" position="-900 0 -20" rotation="0 0 0"
        allowDragging="true" restrictDraggingToParentBounds="false" returnToOriginalPositionWhenReleased="false" active="true" height="280" width="100">
        <Panel height="280" width="100" childAlignment="MiddleCenter">
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

function getSideColor(side)
  if side == "Left" then
    return leftColor
  else
    return rightColor
  end
end

function isPlayerAllowed(player, func)
  --print(func)
  local retValue = player.color == leftColor or player.color == rightColor
  if retValue == false then
    player.broadcast("Hey ["..getColorHex(player.color).."]"..player.steam_name.."[-]! Only ["..getColorHex(leftColor).."]".. leftColor.."[-] and ["..getColorHex(rightColor).."]"..rightColor.."[-] players can use the roller!")
  end
  return retValue
end

function getColorHex(color)
  return Color.fromString(color):toHex()
end

function askSpawn(args)
  local player = args["player"]
  local number = args["number"]
  local auto = args["auto"]
  if isPlayerAllowed(player, 'askSpawn') == false then return end
  if isRolling[player.color] == 1 then return end
  spawnKill(player, number, auto)
end

function spawnKill(player, number, autoRoll)
  if isPlayerAllowed(player, 'spawnKill') == false then return end
  deleteDice(obj, player)

  for i=1, number, 1 do
    if dice6Image == '' then
      spawnParams = {
        type              = 'Die_6',
        position          = self.getPosition(),
        rotation          = {x=-90, y=0, z=0},
        scale             = {x=1+((size-1)*2), y=1+((size-1)*2), z=1+((size-1)*2)},
        sound             = true,
        snap_to_grid      = false,
        callback_function = function(obj) spawn_callback(obj,player,autoRoll,dice6Image,false,key) end
      }
    else
      spawnParams = {
        type              = 'Custom_Dice',
        position          = self.getPosition(),
        rotation          = {x=-90, y=0, z=0},
        scale             = {x=1+((size-1)*2), y=1+((size-1)*2), z=1+((size-1)*2)},
        sound             = true,
        snap_to_grid      = false,
        callback_function = function(obj) spawn_callback(obj,player,autoRoll,dice6Image,true,key) end
      }
    end
    spawnObject(spawnParams)
  end
end

function spawn_callback(obj,player,autoRoll,diceImage,custom,key)
  if isPlayerAllowed(player, 'spawn_callback') == false then return end
  local newobj
  local timeToWait = 0.3
  if custom == true then
    params = { image = diceImage, type=1, }
    obj.setCustomObject(params)
    newobj = obj.reload()
    timeToWait = 0.5
  else
    newobj = obj
  end
  if player.color == leftColor then
    table.insert(diceTabL,newobj)
  else
    table.insert(diceTabR,newobj)
  end

  Wait.condition(
    function()
      newobj.addToPlayerSelection(player.color)
      newobj.setColorTint(player.color)
      if autoRoll2 == 1 or autoRoll == 1 then
          Wait.time(function() roll(player) end,timeToWait)
      end
    end
    ,
    function() -- Condition function
        return regroup(player)
    end)
end

function regroup(player)
  if isPlayerAllowed(player, 'regroup') == false then return end
  local buff = true
  local offset = 4.8
  if player.color == leftColor then
    offset = -offset
  end
  fixValue(player)
  getDiceNumber(player)

  for key,value in pairs(getGrid(getDiceNumber(player),-1,-1,2*size,offset)) do
    if player.color == leftColor then
      diceTabL[key].setRotation({x=diceTabL[key].getRotation().x,y=self.getRotation().y,z=diceTabL[key].getRotation().z})
      if diceTabL[key].setPositionSmooth(value, false, true) == false then
        buff = false
      end
    else
      diceTabR[key].setRotation({x=diceTabR[key].getRotation().x,y=self.getRotation().y,z=diceTabR[key].getRotation().z})
      if diceTabR[key].setPositionSmooth(value, false, true) == false then
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
  if isPlayerAllowed(player, 'fixValue') == false then return end

  if player.color == leftColor then
    for key,value in pairs(diceTabL) do
      if value != nil then
        value.setValue(value.getValue())
      end
    end
  else
    for key,value in pairs(diceTabR) do
      if value != nil then
        value.setValue(value.getValue())
      end
    end
  end
end

function deleteDice(obj, player)
  if isPlayerAllowed(player, 'deleteDice') == false then return end

  if player.color == leftColor then
    for key,value in pairs(diceTabL) do
      if value != nil then
        destroyObject(value)
      end
    end
  else
    for key,value in pairs(diceTabR) do
      if value != nil then
        destroyObject(value)
      end
    end
  end
  getDiceNumber(player)
end

function getDiceNumber(player)
  if isPlayerAllowed(player, 'getDiceNumber') == false then return end

  local diceNumber = 0
  local diceTabTemp = {}
  if player.color == leftColor then
    for key,value in pairs(diceTabL) do
      if value != nil then
        diceNumber = diceNumber + 1
        table.insert(diceTabTemp,value)
      end
    end
    diceTabL = diceTabTemp
  else
    for key,value in pairs(diceTabR) do
      if value != nil then
        diceNumber = diceNumber + 1
        table.insert(diceTabTemp,value)
      end
    end
    diceTabR = diceTabTemp
  end
  return diceNumber
end

function setDiceValue()
  all = 0
  for i=1,6 do
    buff = 0
    for k,v in ipairs(diceTabL) do
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
    for k,v in ipairs(diceTabR) do
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
  if isPlayerAllowed(player, 'roll') == false then return end

  if getDiceNumber(player) != 0 then
    for key,value in pairs(player.getSelectedObjects()) do
      value.roll()
      value.roll()
    end
  end
  if isRolling[player.color] ~= 1 then
    isRolling[player.color] = 1
    Wait.time(function() order(player) end, 2.2)
  end
end

function order(player)
  if isPlayerAllowed(player, 'order') == false then return end
  fixValue(player)

  for diceValue=1, 6, 1 do
    local diceIndex = 0
    local tabLength = 0
    local diceTabTemp = {}
    local diceTabCurrent = {}

    if player.color == leftColor then
      diceTabCurrent = diceTabL
    else
      diceTabCurrent = diceTabR
    end
    log(diceTabCurrent)
    for key,value in pairs(diceTabCurrent) do
      if diceTabCurrent[key] != nil then
        if diceTabCurrent[key].getRotationValue() == diceValue then
          table.insert(diceTabTemp, diceTabCurrent[key])
          tabLength = tabLength + 1
        end
      end
    end

    local count = 0
    for key,value in pairs(diceTabTemp) do
      diceTabTemp[key].setRotation({x=diceTabTemp[key].getRotation().x,y=self.getRotation().y,z=diceTabTemp[key].getRotation().z})
      local p = -count- 2
      if player.color == rightColor then p = -p end
      diceTabTemp[key].setPositionSmooth(getPoint(p, (-diceValue*1.17)+4.66),false, true)
      count = count + 1.1
    end
  end

  printresultsTable(player)
end

function selectValueP(player,valueDice)
  if isPlayerAllowed(player, 'selectValueP') == false then return end

  if valueDice == "0" then
    print("lala")
    local lowestSoFar = 7
    local lowestItemSoFar = nil

    player.clearSelectedObjects()
    if player.color == leftColor then
      for key,value in pairs(diceTabL) do
        if value ~= nil and value.getRotationValue() < lowestSoFar then
          print("lala")
          lowestSoFar = value.getRotationValue()
          lowestItemSoFar = value
        end
      end
    else
      for key,value in pairs(diceTabR) do
        if value ~= nil and value.getRotationValue() < lowestSoFar then
          lowestSoFar = value.getRotationValue()
          lowestItemSoFar = value
        end
      end
    end

    if lowestItemSoFar ~= nil then
      lowestItemSoFar.addToPlayerSelection(player.color)
    end
    return
  end

  player.clearSelectedObjects()
  if player.color == leftColor then
    for key,value in pairs(diceTabL) do
      if value != nil and value.getRotationValue() <= tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  else
    for key,value in pairs(diceTabR) do
      if value != nil and value.getRotationValue() <= tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  end
  getDiceNumber(player)
end

function selectValue(player,valueDice)
  if isPlayerAllowed(player, 'selectValue') == false then return end
  player.clearSelectedObjects()

  if player.color == leftColor then
    for key,value in pairs(diceTabL) do
      if value ~= nil and value.getRotationValue() == tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  else
    for key,value in pairs(diceTabR) do
      if value ~= nil and value.getRotationValue() == tonumber(valueDice) then
        value.addToPlayerSelection(player.color)
      end
    end
  end
  getDiceNumber(player)
end

function destroyValueP(player,valueDice)
  if isPlayerAllowed(player, 'destroyValueP') == false then return end

  if(valueDice == "1") then
    valueDice = "7"
  end

  if player == leftColor then
    for key,value in pairs(diceTabL) do
      if value != nil and value.getRotationValue() < tonumber(valueDice) then
        destroyObject(value)
      end
    end
  else
    for key,value in pairs(diceTabR) do
      if value != nil and value.getRotationValue() < tonumber(valueDice) then
        destroyObject(value)
      end
    end
  end
  getDiceNumber(player)
  selectAll(player)
end

function selectAll(player)
  if isPlayerAllowed(player, 'selectAll') == false then return end
  player.clearSelectedObjects()

  if player == leftColor then
    for key,value in pairs(diceTabL) do
      if value != nil then
        value.addToPlayerSelection(player.color)
      end
    end
  else
    for key,value in pairs(diceTabR) do
      if value != nil then
        value.addToPlayerSelection(player.color)
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
  if isPlayerAllowed(player, 'toggleMenu') == false then return end

  if menu == 0 then
    menu = 1
    self.UI.show('menu')
  else
    menu = 0
    self.UI.hide('menu')
  end
end

function toggleUI(player)
  if isPlayerAllowed(player, 'toggleUI') == false then return end
  local side = "Left"
  if player.color == rightColor then
    side = "Right"
  end

  if enablePlayerUI == nil then
    enablePlayerUI = {
      Left = false,
      Right = false
    }
  end

  if enablePlayerUI[side] == false then
    enablePlayerUI[side] = true
  else
    enablePlayerUI[side] = false
  end

  local visibility = ""
  if enablePlayerUI["Left"] == true then
    visibility = leftColor
  end

  if enablePlayerUI["Right"] == true then
    if visibility ~= "" then
      visibility = visibility.."|"
    end
    visibility = visibility..rightColor
  end

  if visibility == "" then
    UI.setAttribute('diceUI', 'active', 'false')
    UI.setAttribute('dicePrintUI', 'active', 'false')
  else
    UI.setAttribute('diceUI', 'active', 'true')
    UI.setAttribute('dicePrintUI', 'active', 'true')
  end

  UI.setAttribute('diceUI', 'visibility', visibility)
  UI.setAttribute('dicePrintUI', 'visibility', visibility)
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
  player.lookAt(
    {
      position = self.getPosition(),
      pitch    = self.getRotation().x + 75,
      yaw      = self.getRotation().y + 270,
      distance = 20*size,
    })
end

function setDice(args)
  local player = args["player"]
  if isPlayerAllowed(player, 'toggleMenu') == false then return end

  if player.color == leftColor then
    diceTabL = args["diceTabTemp"]
    for key,value in pairs(diceTabL) do
      diceTabL[key].setRotation({x=diceTabL[key].getRotation().x,y=self.getRotation().y,z=diceTabL[key].getRotation().z})
    end
  else
    diceTabR = args["diceTabTemp"]
    for key,value in pairs(diceTabR) do
      diceTabR[key].setRotation({x=diceTabR[key].getRotation().x,y=self.getRotation().y,z=diceTabR[key].getRotation().z})
    end
  end
  selectAll(player)
end

function printresultsTable(player)
  isRolling[player.color] = 0

  local params = {
    resultTab = {},
    player_name = player.steam_name,
    color = player.color
  }

  if player.color == leftColor then
    params.resultTab = diceTabL
  else
    params.resultTab = diceTabR
  end

  announceResults(params)

end

function announceResults(params)
  local resultTab = params["resultTab"]
  local player_name = params["player_name"]
  local color = params["color"]

  local result = ""
  for i=1,6,1 do
    for key,value in pairs(resultTab) do
      local rolledValue = 0
      if type(value) == "number" then
        rolledValue = value
      else
        rolledValue = value.getValue()
      end

      if rolledValue == i then
        if result ~= "" then
          result = result .. ", "
        end
        result = result .. tostring(i)
      end
    end
  end

  local time = '[' .. os.date("%H") .. ':' .. os.date("%M") .. ':' .. os.date("%S") .. '] '
  local message = time .. " " .. player_name .. " rolls: " .. result
  broadcastToAll(message, stringColorToRGB(color))

end

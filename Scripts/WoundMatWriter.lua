-- HPBarWriter
--[[LUAStart
test = true
statuses = {
  Engage_ready = true,
  Engage_activated = false,
  Conceal_ready = false,
  Conceal_activated = false,
  Injured_red = false,
  Injured_blue = false,
  Plus_1_red = false,
  Plus_1_blue = false,
  Minus_1_red = false,
  Minus_1_blue = false,
  Crosshair_red = false,
  Crosshair_blue = false,
  Exclamation_red = false,
  Exclamation_blue = false }
statusesNames = { Conceal = 'Conceal_', Engage = 'Engage_', Injured = 'Injured_' }
statusesModifiers = { Ready = 'ready', Activated = 'activated', Red = 'red', Blue = 'blue' }
statesRotations = {
  Conceal_ready = 'Conceal_activated',
  Conceal_activated = 'Conceal_ready',
  Engage_ready = 'Engage_activated',
  Engage_activated = 'Engage_ready',
  Injured_red = 'Injured_blue',
  Injured_blue = 'Injured_red',
  Plus_1_red = 'Plus_1_blue',
  Minus_1_red = 'Minus_1_blue',
  Crosshair_red = 'Crosshair_blue',
  Exclamation_red = 'Exclamation_blue' }
health = { value = @hp, max = @hp }
options = {
    heightModifier = 300,
    showBarButtons = false,
    incrementBy = 30,
    rotation = 270,
    auto_injury = @auto_injury }

function onLoad(save_state)
  if save_state ~= "" then
    saved_data = JSON.decode(save_state)
    LoadData()
    LoadOptions()
    LoadStates()
  end
  local script = self.getLuaScript()
  local xml = script:sub(script:find("StartKTUIXML")+12, script:find("StopKTUIXML")-1)
  newScale = tonumber(string.format("%.2f", 1 / ((self.getScale().x + self.getScale().y + self.getScale().z) / 3)))
  xml = xml:gsub('id="panel" scale="1"', 'id="panel" scale="'..newScale..'"')
  self.UI.setXml(xml)
  self.addContextMenuItem("Engage", SetEngage)
  self.addContextMenuItem("Conceal", SetConceal)
  self.addContextMenuItem("Toggle Menu", ToggleMenu)
  self.addTag("KTUIMini")
  Wait.frames(KTUI_LoadUI, 10)
end

function KTUI_LoadUI()
  self.UI.setAttribute("panel", "position", "0 0 -" .. self.getBounds().size.y + (options.heightModifier * newScale))
  self.UI.setAttribute("progressBar", "percentage", health.value / health.max * 100)
  self.UI.setAttribute("hpText", "text", health.value .. "/" .. health.max)
  self.UI.setAttribute("increment", "text", options.incrementBy)
  for i,j in pairs(statuses) do
    if j == true then
      self.UI.setAttribute(i, "active", true)
    end
  end
  Wait.frames(function() self.UI.setAttribute("statePanel", "width", GetStatesCount() * 80) end, 1)
  if options.showBarButtons then
    self.UI.setAttribute("addSub", "active", true)
  end
  self.UI.setAttribute("addSub", "active", options.showBarButtons == true and "True" or "False")
  self.UI.setAttribute("panel", "rotation", options.rotation .. " 270 90")
end

-- This will check if a token is being collided with the model
function onCollisionEnter(a)
  if a.collision_object.hasTag('KTUIToken') then
    local newState = a.collision_object.getName()
    a.collision_object.destruct()
    if stringStartsWith(newState, statusesNames.Engage) or stringStartsWith(newState, statusesNames.Conceal) then
      RemoveState(statusesNames.Engage..statusesModifiers.Ready)
      RemoveState(statusesNames.Engage..statusesModifiers.Activated)
      RemoveState(statusesNames.Conceal..statusesModifiers.Ready)
      RemoveState(statusesNames.Conceal..statusesModifiers.Activated)
    end
    AddState(newState)
  end
end

-- Savestate Manager
function onSave()
  local save_state = JSON.encode({health = health, mana = mana, extra = extra, options = options, statuses = statuses})
  self.script_state = save_state
end

function LoadData()
  if saved_data.health then
    for heal,_ in pairs(health) do
      health[heal] = saved_data.health[heal]
    end
  end
end

function LoadStates()
  if saved_data.statuses then
    for stat,_ in pairs(statuses) do
      statuses[stat] = saved_data.statuses[stat]
    end
  end
end

function LoadOptions()
  if saved_data.options then
    for opt,_ in pairs(options) do
      options[opt] = saved_data.options[opt]
    end
  end

  -- For compatibility reasons, performs checks on some options defaults
  if options.auto_injury == nil then
    options.auto_injury = true
  end
end

-- UI Buttons Handlers
function ToggleHPButtons()
  options.showBarButtons = not options.showBarButtons;
  Wait.frames(function() self.UI.setAttribute("addSub", "active", options.showBarButtons) end, 1)
end

function ToggleAutoInjury()
  options.auto_injury = not options.auto_injury
  if options.auto_injury then
    print("Auto Injury: Enabled")
    ChangeHealth(0)
  else
    print("Auto Injury: Disabled")
    RemoveState(statusesNames.Injured..statusesModifiers.Red)
    RemoveState(statusesNames.Injured..statusesModifiers.Blue)
  end
end

function ChangeUIPosition(player, value, id)
  if id == "addHeight" then
    options.heightModifier = options.heightModifier + options.incrementBy
  elseif id == "subHeight" or id == "addHeight" then
    options.heightModifier = options.heightModifier - options.incrementBy
  elseif id == "addRotation" then
    options.rotation = options.rotation + options.incrementBy
  elseif id == "subRotation"then
    options.rotation = options.rotation - options.incrementBy
  end
  self.UI.setAttribute("panel", "position", "0 0 -" .. self.getBounds().size.y + (options.heightModifier * newScale))
  self.UI.setAttribute("panel", "rotation", options.rotation .. " 270 90")
end

function ChangeHealthValues(player, value, id)
  if id == "add" then
    ChangeHealth(1)
  elseif id == "sub" then
    ChangeHealth(-1)
  elseif id == "addMax" then
    health.max = health.max + 1
    ChangeHealth(0)
  elseif id == "subMax" then
    health.max = health.max - 1
    if health.max < 1 then health.max = 1 end
    ChangeHealth(0)
  end
  self.UI.setAttribute("progressBar", "percentage", health.value / health.max * 100)
  self.UI.setAttribute("hpText", "text", health.value .. "/" .. health.max)
  self.UI.setAttribute("hpText", "textColor", "#FFFFFF")
end

function OnIncrementEndEdit(player, value, id)
  options.incrementBy = value
end

-- Menu Handlers
function ToggleMenu()
  if string.lower(self.UI.getAttribute("editPanel", "active")) ~= "true" then
    self.UI.setAttribute("editPanel", "active", true)
  else
    self.UI.setAttribute("editPanel", "active", false)
  end
end

function SetEngage()
  AddState(statusesNames.Engage..statusesModifiers.Ready)
  RemoveState(statusesNames.Engage..statusesModifiers.Activated)
  RemoveState(statusesNames.Conceal..statusesModifiers.Ready)
  RemoveState(statusesNames.Conceal..statusesModifiers.Activated)
end

function SetConceal()
  RemoveState(statusesNames.Engage..statusesModifiers.Ready)
  RemoveState(statusesNames.Engage..statusesModifiers.Activated)
  AddState(statusesNames.Conceal..statusesModifiers.Ready)
  RemoveState(statusesNames.Conceal..statusesModifiers.Activated)
end

function KTUI_ReadyOperative() -- For possible integrations with any other UI
  if statuses[statusesNames.Engage..statusesModifiers.Activated] == true then
    SetEngage()
  else
    SetConceal()
  end
end

function KTUI_ResetScripts()
  broadcastToAll("Reloading KTUI")
  local r = 0
  for _, obj in ipairs(getAllObjects()) do
    if obj.hasTag('KTUIToken') or obj.hasTag('KTUIMini') then
      obj.reload()
      r = r+1
    end
  end
  broadcastToAll("Reloaded "..r.." items")
end

-- Handlers for the miniature states
function HandleStatesButtons(player, value, id)
  local state = id
  if statuses[state] == nil then
    return
  end
  RemoveState(state)
  if statesRotations[state] ~= nil then
    AddState(statesRotations[state])
  end
end

function HandleInjuredButtons(player, value, id)
  local state = id
  if statuses[state] == nil then
    return
  end
  RemoveState(state)
  if statesRotations[state] ~= nil then
    AddState(statesRotations[state])
  end
  if state == statusesNames.Injured..statusesModifiers.Blue and options.auto_injury == false then
    RemoveState(statesRotations[state])
  end
end

function AddState(state)
  if statuses[state] ~= nil and statuses[state] == false then
    statuses[state] = true
    self.UI.setAttribute(state, "active", true)
    Wait.frames(function() self.UI.setAttribute("statePanel", "width", GetStatesCount() * 80) end, 1)
  end
end

function RemoveState(state)
  if statuses[state] ~= nil and statuses[state] == true then
    statuses[state] = false
    self.UI.setAttribute(state, "active", false)
    Wait.frames(function() self.UI.setAttribute("statePanel", "width", GetStatesCount() * 80) end, 1)
  end
end

function GetStatesCount()
  local count = 0
  for i,j in pairs(statuses) do
    if string.lower(self.UI.getAttribute(i, "active")) == "true" then
      count = count + 1
    end
  end
  return count
end

-- Generic Functions
function ChangeHealth(difference)
  health.value = health.value + difference
  if health.value > health.max then
    health.value = health.max
  elseif health.value < 0 then
    health.value = 0
  end
  local half_health = math.floor(health.max / 2)
  if health.value >= half_health and options.auto_injury
    and (statuses[statusesNames.Injured..statusesModifiers.Red] == true
    or statuses[statusesNames.Injured..statusesModifiers.Blue] == true)
  then
    RemoveState(statusesNames.Injured..statusesModifiers.Red)
    RemoveState(statusesNames.Injured..statusesModifiers.Blue)
  elseif health.value < half_health and options.auto_injury
    and statuses[statusesNames.Injured..statusesModifiers.Red] == false
    and statuses[statusesNames.Injured..statusesModifiers.Blue] == false
  then
    AddState(statusesNames.Injured..statusesModifiers.Red)
  end
end

function stringStartsWith(s, start)
  return s:find("^"..start) ~= nil
end
LUAStop--lua]]


--[[XMLStart
<Defaults>
  <Button fontSize="30" fontStyle="Bold" textColor="#FFFFFF" color="#000000F0"/>
  <Text fontSize="30" fontStyle="Bold" color="#FFFFFF"/>
  <InputField fontSize="20" color="#000000F0" textColor="#FFFFFF" characterValidation="Integer"/>
  <Image minheight="400" />
</Defaults>

<Panel id="panel" scale="1" position="0 0 -220" rotation="90 270 90">
  <Panel id="ressourceBar" active="true" position="0 -1 0">
    <ProgressBar id="progressBar" visibility="" height="40" width="160" showPercentageText="false" color="#000000E0" percentage="100" fillImageColor="#710000"></ProgressBar>
    <Text id="hpText" visibility="" height="50" width="160" text="10/10" fontSize="30"></Text>
    <HorizontalLayout height="40" width="160">
       <Button id="btnShowHPArrows" text="" color="#00000000" onClick="ToggleHPButtons"></Button>
    </HorizontalLayout>
    <Panel id="addSub" visibility="" height="40" width="240" active="false">
      <HorizontalLayout spacing="160">
        <Button id="sub" text="-" color="#FFFFFF" textColor="#000000" fontSize="30" onClick="ChangeHealthValues"></Button>
        <Button id="add" text="+" color="#FFFFFF" textColor="#000000" fontSize="30" onClick="ChangeHealthValues"></Button>
      </HorizontalLayout>
    </Panel>
  </Panel>
  <Panel id="editPanel" height="240" width="320" position="0 250 0" active="False">
    <VerticalLayout>
      <HorizontalLayout minheight="80">
        <Button id="btnToggleAutoInjury" fontSize="30" text="Auto Injury" color="#000000F0" onClick="ToggleAutoInjury"></Button>
        <Button id="btnShowHPArrowsMenu" fontSize="30" text="HP Bar Buttons" color="#000000F0" onClick="ToggleHPButtons"></Button>
      </HorizontalLayout>
      <HorizontalLayout minheight="40">
        <Button id="subHeight" minwidth="40" text="◄" onClick="ChangeUIPosition"></Button>
        <Text minwidth="240">Height</Text>
        <Button id="addHeight" minwidth="40" text="►" onClick="ChangeUIPosition"></Button>
      </HorizontalLayout>
      <HorizontalLayout minheight="40">
        <Button id="subRotation" minwidth="40" text="◄" onClick="ChangeUIPosition"></Button>
        <Text minwidth="240">Rotation</Text>
        <Button id="addRotation" minwidth="40" text="►" onClick="ChangeUIPosition"></Button>
      </HorizontalLayout>
      <HorizontalLayout minheight="40">
        <Button id="subMax" minwidth="40" text="◄" onClick="ChangeHealthValues"></Button>
        <Text minwidth="240">Max HP</Text>
        <Button id="addMax" minwidth="40" text="►" onClick="ChangeHealthValues"></Button>
      </HorizontalLayout>
      <HorizontalLayout minheight="40">
        <Text fontSize="30">Increment by:</Text>
        <InputField id="increment" onEndEdit="OnIncrementEndEdit" minwidth="50" text="30"></InputField>
      </HorizontalLayout>
    </VerticalLayout>
  </Panel>
  <Panel id="statePanel" height="80" width="-5" position="0 70 0">
    <VerticalLayout>
      <HorizontalLayout spacing="5">
        <Button id="Engage_ready" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Engage_ready" preserveAspect="true"></Image></Button>
        <Button id="Engage_activated" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Engage_activated" preserveAspect="true"></Image></Button>
        <Button id="Conceal_ready" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Conceal_ready" preserveAspect="true"></Image></Button>
        <Button id="Conceal_activated" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Conceal_activated" preserveAspect="true"></Image></Button>
        <Button id="Injured_red" color="#FFFFFF00" active="false" onClick="HandleInjuredButtons"><Image image="Injured_red" preserveAspect="true"></Image></Button>
        <Button id="Injured_blue" color="#FFFFFF00" active="false" onClick="HandleInjuredButtons"><Image image="Injured_blue" preserveAspect="true"></Image></Button>
        <Button id="Plus_1_red" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Plus_1_red" preserveAspect="true"></Image></Button>
        <Button id="Plus_1_blue" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Plus_1_blue" preserveAspect="true"></Image></Button>
        <Button id="Minus_1_red" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Minus_1_red" preserveAspect="true"></Image></Button>
        <Button id="Minus_1_blue" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Minus_1_blue" preserveAspect="true"></Image></Button>
        <Button id="Crosshair_red" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Crosshair_red" preserveAspect="true"></Image></Button>
        <Button id="Crosshair_blue" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Crosshair_blue" preserveAspect="true"></Image></Button>
        <Button id="Exclamation_red" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Exclamation_red" preserveAspect="true"></Image></Button>
        <Button id="Exclamation_blue" color="#FFFFFF00" active="false" onClick="HandleStatesButtons"><Image image="Exclamation_blue" preserveAspect="true"></Image></Button>
      </HorizontalLayout>
    </VerticalLayout>
  </Panel>
</Panel>
XMLStop--xml]]

options = { auto_injury = true, hp = 10 }

function onLoad(save_state)
  self.UI.setAttribute("hp", "text", options.hp)
  self.UI.setAttribute("auto_injury", "text", options.auto_injury)
  self.UI.setAttribute("auto_injury", "value", "true")
  self.UI.setAttribute("auto_injury", "text", "✘")
  self.UI.setAttribute("auto_injury", "textColor", "#FFFFFF")
end

function KTUI_ResetScripts()
  broadcastToAll("Reloading KTUI")
  local r = 0
  for _, obj in ipairs(getAllObjects()) do
    if obj.hasTag('KTUIToken') or obj.hasTag('KTUIMini') then
      obj.reload()
      r = r+1
    end
  end
  broadcastToAll("Reloaded "..r.." items")
end

function toggleCheckBox(player, value, id)
  if self.UI.getAttribute(id, "value") == "false" then
    self.UI.setAttribute(id, "value", "true")
    self.UI.setAttribute(id, "text", "✘")
    options[id] = true
  else
    self.UI.setAttribute(id, "value", "false")
    self.UI.setAttribute(id, "text", "")
    options[id] = false
  end
  self.UI.setAttribute(id, "textColor", "#FFFFFF")
end

function ChangeOptionValue(player, value, id)
  options[id] = tonumber(value)
  self.UI.setAttribute(id, "text", value)
end

function onCollisionEnter(collision_info)
  local object = collision_info.collision_object
  if object.tag == "Figurine" then
    local script = self.getLuaScript()
    local xml = script:sub(script:find("XMLStart")+8, script:find("XMLStop")-1)
    local newScript = script:sub(script:find("LUAStart")+8, script:find("LUAStop")-1)
    newScript = "--[[StartKTUIXML\n" .. xml .. "StopKTUIXML--xml]]\n" .. newScript

    newScript = newScript:gsub("@hp", options.hp)
    if options.auto_injury then
      newScript = newScript:gsub("@auto_injury", "true")
    else
      newScript = newScript:gsub("@auto_injury", "false")
    end
    object.setLuaScript(newScript)
    object.addTag("KTUIMini")
  end
end
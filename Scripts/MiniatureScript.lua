state = {}

self.max_typed_number=99

ranges = {
  triangle={
    color=Color(0.10,0.10,0.09),
    range=1
  },
  circle={
    color=Color(1,1,1),
    range=2
  },
  square={
    color=Color(0,0.36,0.62),
    range=3
  },
  pentagon={
    color=Color(0.80,0.08,0.09),
    range=6
  }
}

triangle = "(1\")"
circle   = "(2\")"
square   = "(3\")"
pentagon = "(6\")"

function textColorXml( color, text )
  return string.format("<textcolor color=\"#%s\">%s</textcolor>", color, text)
end

function textColorMd( color, text )
  return string.format("[%s]%s[-]", color, text)
end

secrets = {
  "ktcnid-status-hiddenRole"
}

text_subs = {
  ["1&&"]   = textColorXml("000000", triangle),
  ["2&&"]   = textColorXml("ffffff", circle),
  ["3&&"]   = textColorXml("1E87FF", square),
  ["6&&"]   = textColorXml("DA1A18", pentagon),
  ["%(R%)"] = textColorXml("1E87FF", "R"),
  ["%(M%)"] = textColorXml("F4641D", "M")
}

md_subs = {
  ["1&&"]   = textColorMd("000000", triangle),
  ["2&&"]   = textColorMd("ffffff", circle),
  ["3&&"]   = textColorMd("1E87FF", square),
  ["6&&"]   = textColorMd("DA1A18", pentagon),
  ["%(R%)"] = textColorMd("1E87FF", "R"),
  ["%(M%)"] = textColorMd("F4641D", "M")
}

function secretVisibility()
  local p = getOwningPlayer()
  if p == nil then return "" end
  return table.concat( {"Jokers", p.color}, "|" )
end

function hideSecrets()
  local sv = secretVisibility()
  for i,v in ipairs(secrets) do
    self.UI.setAttribute(v, "visibility", sv)
  end
end

modelMeasureLineRadius = 0.05
base                   = {}
baseLineRadius         = 0.0125
baseLineHeight         = 0.2

rangeShown             = false
measureColor           = nil
measureRange           = 0

function onNumberTyped( pc, n )
  rangeShown = n > 0
  measureColor = Color.fromString(pc)
  measureRange = n

  scaleFactor = 1/self.getScale().x

  if lastRange == measureRange then
    sphereRange = getCircleVectorPoints(measureRange - modelMeasureLineRadius + 0.05, 0.125, 1)[1].x * 2 / scaleFactor
    Physics.cast({
          origin       = self.getPosition(),
          direction    = {0,1,0},
          type         = 2,
          size         = {sphereRange,sphereRange,sphereRange},
          max_distance = 0,
          debug        = true,
      })
  end
  lastRange = measureRange
  refreshVectors()
  Player[pc].broadcast(string.format("%d\"", measureRange))
end

function saveState()
  self.script_state = JSON.encode(state)
end

function loadState()
  state = JSON.decode(self.script_state)
end

function savePosition(p, r)
  local savePos = {
    position=p or self.getPosition(),
    rotation=r or self.getRotation()
  }
  state.savePos = savePos
  saveState()
  self.highlightOn(Color(0.19, 0.63, 0.87), 0.5)
end

function loadPosition()
  local sp = state.savePos
  if sp then
    self.setPositionSmooth(sp.position, false, true)
    self.setRotationSmooth(sp.rotation, false, true)
    self.highlightOn(Color(0.87, 0.43, 0.19), 0.5)
  end
end

-- Nyirsh: a bit redundant with the RefreshUI, maybe we can put these two together
function refreshWounds()

  local w = state.wounds
  local m = state.stats.W

  local uiwstring = function()
    if w == 0 then
      return textColorXml("DA1A18", "DEAD")
    end
    return string.format("%d/%d", w, m)
  end

  local namewstring = function()
    if w == 0 then
      return "{[DA1A18]DEAD[-]}"
    elseif w < m/2 then
      return string.format("{[9A1111]*[-]%d/%d[9A1111]*[-]}", w, m)
    end
    return string.format("{%d/%d}", w, m)
  end


  self.UI.setValue("ktcnid-status-wounds", uiwstring())
  local nname = self.getName()

  if string.find(nname, "%b{}") == nil then
    nname = "{} "..nname
  else
    nname = string.sub(nname, string.find(nname, "%b{}"), 100)
  end

  local norder = "[FF5500]"
  if state.ready == false then
    norder = "[999999]"
  end

  if state.order == "Conceal" then
    norder = norder.."C"
  else
    norder = norder.."E"
  end
  norder = norder.."[-] "

  self.setName(string.gsub(nname, "%b{}", norder..namewstring()))
end

function callback_attachment(player, value, id)
  local attachment = id:gsub("ktcnid[-]status[-]", "")
  local mustRefresh = false
  if state.attachments[attachment].active == false or state.attachments[attachment].removable == false then return end
  if state.attachments[attachment].stackable then
    local stackModifier = -1
    if value == "-1" then stackModifier = 1 end
    state.attachments[attachment].stack = state.attachments[attachment].stack + stackModifier
    if state.attachments[attachment].stack <= 0 then
      state.attachments[attachment].stack = 0
      state.attachments[attachment].active = false
    end
    mustRefresh = true
  else
    if value == "-2" then
      state.attachments[attachment].active = false
      mustRefresh = true
    end
  end

  if mustRefresh then
    saveState()
    refreshUI()
  end
end

function callback_secret(player, value, id)
  local attachment = id:gsub("ktcnid[-]status[-]", "")
  if value == "-1" then
    state.attachments[attachment].active = not state.attachments[attachment].active
  end
  saveState()
  refreshUI()
end

function callback_orders(player, value, id)
  if value == '-1' then
    if state.ready == nil or state.ready then
      state.ready = false
    else
      state.ready = true
    end
  else
    if state.order == "Engage" then
      state.order = "Conceal"
    else
      state.order = "Engage"
    end
  end
  refreshUI()
  refreshWounds()
end

function refreshUI()
  local sc = self.getScale()
  local scaleFactorX = 1/sc.x
  local scaleFactorY = 1/sc.y
  local scaleFactorZ = 1/sc.z

  local circOffset = function(d, a)
    local ra = math.rad(a)
    return string.format("%d %d", math.cos(ra)*d, math.sin(ra)*d)
  end

  local uid = 50
  local sv = secretVisibility()

  local off_injured = -35
  local off_order = 65
  if state.display_arrows then
    off_injured = -75
    off_order = 95
  end

  local p = getOwningPlayer()
  local wound_color = "red"
  if p ~= nil then
    if p.color ~= "Red" then
      wound_color = "blue"
    end
  end

  local position = "0 0 -"..tostring(state.uiHeight*100*scaleFactorZ)

  if state.isHorizontal == true then
    position = "0 -"..tostring(60*scaleFactorY).." -"..tostring(20*scaleFactorZ)
  end
  local xmlTable = [[<Defaults>
  <Image class="statusDisplay" hideAnimation="Shrink" showAnimation="Grow" preserveAspect="true" />
</Defaults>
<Panel position="]]..position..[[" width="100" height="100" rotation="0 0 ]]..(state.uiAngle or 0)..[[" scale="]]..scaleFactorX..[[ ]]..scaleFactorY..[[ ]]..scaleFactorZ..[[">

  <HorizontalLayout spacing="3" width="@totalSecret" height="20" offsetXY="-30 -10">
    --@EquipmentPlaceholder
    --@SecretsPlaceholder
  </HorizontalLayout>

	<Panel color="#808080" outline="#FF5500" outlineSize="2 2" width="80" height="25" offsetXY="]]..circOffset(40, 270)..[[">
    <Image id="ktcnid-status-injured" image="Wound_]]..wound_color..[[" width="30" height="30" rectAlignment="MiddleLeft" offsetXY="]]..off_injured..[[ 0" active="]]..tostring(isInjured())..[[" />
		<Button text="-" width="30" height="30" offsetXY="-65 0" onClick="damage" active="]]..tostring((state.display_arrows or false))..[[" />
		<Text id="ktcnid-status-wounds" text="]]..string.format("%d/%d", state.wounds or 0, state.stats.W or 0)..[[" resizeTextForBestFit="true" color="#ffffff" onClick="toggleArrows" />
		<Button text="+" width="30" height="30" offsetXY="65 0" onClick="heal" active="]]..tostring((state.display_arrows or false))..[[" />
    <Image id="ktcnid-status-order" image="]]..getCurrentOrder()..[[" rectAlignment="MiddleRight" width="55" height="55" offsetXY="]]..off_order..[[ 0" active="true" onClick="callback_orders" />
	</Panel>
  <HorizontalLayout spacing="3" width="@totalAtt" height="30" offsetXY="]]..circOffset(80, 270)..[[">
    --@AttachmentPlaceholder
  </HorizontalLayout>
</Panel>]]



  local hasRoles = next(state.roles) ~= nil
  local hiddenRoles = next(state.hiddenRoles) ~= nil
  local holding = state.holding
  local items = next(state.items) ~= nil

  xmlTable = xmlTable:gsub("@items", tostring(items))

  local totalAtt = 0
  local totalStack = 0
  local totalSecrets = 0

  local secretxmlAttachmentFormatted = "--@SecretsPlaceholder"
  for _,i in pairs(state.attachments) do
    if i.equipment == true and i.active == true then
      totalSecrets = totalSecrets + 1
      local xmlAttachmentFormatted = [[<Image id="ktcnid-status-]]..i.name..[[" image="]]..i.name..[[" width="30" height="30" preserveAspect="true"]]
      xmlAttachmentFormatted = xmlAttachmentFormatted..[[ active="true" onclick="callback_attachment" /> --@EquipmentPlaceholder]]
      xmlTable = xmlTable:gsub("--@EquipmentPlaceholder", xmlAttachmentFormatted)
    elseif i.secret == false then
      if i.active then
        totalAtt = totalAtt + 1
        local xmlAttachmentFormatted = [[<Image id="ktcnid-status-]]..i.name..[[" image="]]..i.name..[[" width="30" height="30" preserveAspect="true" ]]
        if i.removable then xmlAttachmentFormatted = xmlAttachmentFormatted..[[ onclick="callback_attachment" ]] end
        xmlAttachmentFormatted = xmlAttachmentFormatted..[[ active="true" /> --@AttachmentPlaceholder]]
        if i.stackable and (i.stack or 0) > 0 then
          totalStack = totalStack + 1
          xmlAttachmentFormatted = [[<Panel width="30" height="30"><Text id="ktcnid-status-stack-]]..i.name..[[" text="]]..i.stack..[[x" width="20" rectAlignment="Middle" color="#ffffff" /></Panel> ]]..xmlAttachmentFormatted
        end
        xmlTable = xmlTable:gsub("--@AttachmentPlaceholder", xmlAttachmentFormatted)
      end
    else
      totalSecrets = totalSecrets + 1
      local xmlAttachmentFormatted = [[<Image id="ktcnid-status-]]..i.name..[[" image="]]..i.name..[[" width="30" height="30" preserveAspect="true"]]
      if i.active then
        xmlAttachmentFormatted = xmlAttachmentFormatted..[[ visibility="]]..tostring(sv)..[[" color="#333333DD" ]]
      end
      xmlAttachmentFormatted = xmlAttachmentFormatted..[[ active="true" onclick="callback_secret" /> --@SecretsPlaceholder]]

      if i.active then
        secretxmlAttachmentFormatted = secretxmlAttachmentFormatted:gsub("--@SecretsPlaceholder", xmlAttachmentFormatted)
      else
        xmlTable = xmlTable:gsub("--@SecretsPlaceholder", xmlAttachmentFormatted)
      end
    end
  end
  --xmlTable = xmlTable:gsub("@items", "true")

  xmlTable = xmlTable:gsub("@totalAtt", tostring((totalAtt * 30) + (totalStack * 25)))
  xmlTable = xmlTable:gsub("@totalSecret", tostring((totalSecrets * 30)))
  xmlTable = xmlTable:gsub("--@SecretsPlaceholder", secretxmlAttachmentFormatted)


  self.UI.setXml(xmlTable)
  if state.wounds == 0 then
    Wait.frames(function() refreshWounds() end, 1)
  end
end

function createUI()
  local baseBundle = {
    {name="Engage_ready", url=[=[http://cloud-3.steamusercontent.com/ugc/1857172427760474363/695DDBC1E5EBD24801831E34F2C640B0B0DACF20/]=]},
    {name="Engage_activated", url=[=[http://cloud-3.steamusercontent.com/ugc/1857172427760474790/63E7C5132CFE12964FFAA74EE03535EA6FEE2637/]=]},
    {name="Conceal_ready", url=[=[http://cloud-3.steamusercontent.com/ugc/1857172427760474921/2051CBD8272374F262C88AC0DABF50BEAAB2C3BA/]=]},
    {name="Conceal_activated", url=[=[http://cloud-3.steamusercontent.com/ugc/1857172427760474857/9CE3B9494B93973E94B71E062558E88D83BEC6BC/]=]},
    {name="Wound_blue",   url=[=[http://cloud-3.steamusercontent.com/ugc/1857171492582455772/CFB7B4D001501AC54B4D0CC7FEE35AF679B73D34/]=]},
	  {name="Wound_red",   url=[=[http://cloud-3.steamusercontent.com/ugc/1857171826950614938/C515FF37C3D1D269533C1B5FDA675895F792BC15/]=]},
  }

  for _,i in pairs(state.attachments) do
    table.insert(baseBundle, {name=i.name, url=i.url})
  end
  self.UI.setCustomAssets(baseBundle)
end

function isInjured()
  return state.stats.W and state.wounds < state.stats.W / 2 or false
end

function notify(pc, message)
  if type(pc) == "userdata" then
    pc = pc.color
  end
  local owner = getOwningPlayer()
  if pc == owner.color then
    owner.broadcast(message)
  else
    owner.broadcast(string.format("%s: %s", Player[pc].name, message))
    Player[pc].broadcast(message)
  end
end

function toggleArrows()
  state.display_arrows = not state.display_arrows
  refreshUI()
end

function damage(pc)
  local si = isInjured()
  state.wounds = math.max(0, (state.wounds or 0) - 1)
  if not si and isInjured() then
    self.UI.show("ktcnid-status-injured")
  end
  saveState()
  refreshWounds()
  notify(pc, string.format("%s took damage", self.getName()))
end

function heal(pc)
  local si = isInjured()
  state.wounds = math.min((state.stats.W or 0), (state.wounds or 0) + 1)
  if si and not isInjured() then
    self.UI.hide("ktcnid-status-injured")
  end
  saveState()
  refreshWounds()
  notify(pc, string.format("%s recovered", self.getName()))
end

function kill(pc)
  state.wounds = 0
  saveState()
  refreshWounds()
  notify(pc, string.format("%s KO", self.getName()))
end

function updateStats(pc)
  if getOwningPlayer().color ~= pc then
    notify(pc, "Only the model's owner can update stats")
    return
  end
  notify(pc, "Updating stats from values in description")
  local statsub = {}
  local prevW = state.stats.W or 0
  local wounds = state.wounds or 0
  local desc = self.getDescription() or ""
  local innerUpdate = function(stat)
    local sstring = "%[84E680%]" .. stat .. "%[%-%]%s*%[ffffff%]%s*(%d+).*%[%-%]"
    for match in string.gmatch(desc, "%b[]") do
      local s = match:match(sstring)
      if s then
        local ss = state.stats[stat]
        table.insert(statsub, string.format("%s = %s", stat, s))
        if ss and ss == tonumber(s) then return false end
        state.stats[stat] = tonumber(s)

        -- notify(pc, string.format("%s set to %s", stat, s))
        return true
      end
    end
    table.insert(statsub, string.format("%s = [ff0000]X[-]", stat))
    return false
  end
  innerUpdate("M")
  innerUpdate("APL")
  innerUpdate("GA")
  innerUpdate("DF")
  innerUpdate("SV")
  if innerUpdate("W") then
    if wounds == prevW then
      state.wounds = state.stats.W or 0
    else
      state.wounds = min(state.stats.W or 0)
    end
    refreshWounds()
  end
  saveState()
  notify(pc, table.concat( statsub, ", "))
end

function onLoad(ls)
  loadState()
  state.display_arrows = false
  if state.attachments == nil then
    state.attachments = {}
  end

  self.addContextMenuItem("Engage", function(pc)  setEngage() end)
  self.addContextMenuItem("Conceal", function(pc)  setConceal() end)
  self.addContextMenuItem("Kill", kill)
  self.addContextMenuItem("Save place", function(pc) savePosition() end)
  self.addContextMenuItem("Load place", function(pc) loadPosition() end)
  self.addContextMenuItem("Update stats", updateStats)

  for i, w in ipairs(state.info.weapons) do
    local weaponName = string.sub(w.name,1,21):gsub("%(R%)", "[1E87FF]R[-]"):gsub("%(M%)", "[F4641D]M[-]")
  	if string.len(w.name) > 21 then
  		weaponName = weaponName.."..."
  	end

    self.addContextMenuItem(weaponName, function(pc) callback_Attack(i) end)
  end

  self.addContextMenuItem("Change UI position", function(pc) if state.isHorizontal ~= true then state.isHorizontal = true else state.isHorizontal = false end refreshUI() end)


  local taglist = {state.modelid, "Operative"}
  for _,category in pairs(state.info.categories) do
    table.insert(taglist, category)
  end
  self.setTags(taglist)
  self.addTag("KTUIMini")
  createUI()
  refreshUI()
  refreshVectors(true)
  Wait.frames(function() refreshWounds() end, 1)
end

function callback_Attack(i)
    local weaponName = state.info.weapons[i].name:gsub("%(R%)", "[1E87FF]R[-]"):gsub("%(M%)", "[F4641D]M[-]")
    local weaponAttacks = state.info.weapons[i].stats["A"]
    local weaponLimit = state.info.weapons[i].stats["WS/BS"]

	if isInjured() == true then
		weaponLimit = weaponLimit + 1
		print("Attacking with "..weaponName.." "..weaponAttacks.."D6 @ [FF0000]"..weaponLimit.."+[-]")
	else
		print("Attacking with "..weaponName.." "..weaponAttacks.."D6 @ "..weaponLimit)
	end
    local op = getOwningPlayer()
    local roller = nil
    if op == nil then
      return
    end

    for _, obj in ipairs(getAllObjects()) do
      if obj.hasTag("KTUIDiceRoller") then
        roller = obj
      end
    end

    if roller == nil then return end

    Wait.frames(function()
      Player[op.color].clearSelectedObjects()
      roller.call("askSpawn", { player = op, number = weaponAttacks, auto = 1})
    end, 5)
end


function setEngage()
  state.order = "Engage"
  state.ready = true
  refreshUI()
end

function setConceal()
  state.order = "Conceal"
  state.ready = true
  refreshUI()
end

function getCurrentOrder()
  local orderName = state.order or "Engage"
  if state.ready == nil or state.ready then
    return orderName.."_ready"
  else
    return orderName.."_activated"
  end
end

function onPickUp(pc)
  if rangeShown then
    refreshVectors(true)
  end
end

function tryRandomize(pc)
  rangeShown = not rangeShown
  measureColor = nil
  measureRange = 0
  refreshVectors()

  return false
end

function getOwningPlayer()
  for _, player in ipairs(Player.getPlayers()) do
    if player.steam_id == state.owner then
      return player
    end
  end
  return nil
end

function setOwningPlayer(newOwner)
	state.owner = newOwner
end

function onPlayerChangeColor(color)
  if color ~= "Grey" then
    local p = Player[color]
    if p.steam_id == state.owner then
      refreshVectors()
      hideSecrets()
    end
  end
end

function refreshVectors(norotate)
  local op = getOwningPlayer()
  local circ = {}
  local scaleFactor = 1/self.getScale().x

  local rotation = self.getRotation()

  local newLines = {
    {
      points = getCircleVectorPoints(0 - baseLineRadius, baseLineHeight),
      color = op and Color.fromString(op.color) or {0.5, 0.5, 0.5},
      thickness = baseLineRadius*2*scaleFactor
    }
  }

  if rangeShown then
    if measureRange > 0 then
      table.insert(newLines,{
        points=getCircleVectorPoints(measureRange - modelMeasureLineRadius + 0.05, 0.125),
        color = measureColor,
        thickness = modelMeasureLineRadius*2*scaleFactor,
        rotation = (norotate and {0, 0, 0} or {-rotation.x, 0, -rotation.z})
      })
    else
      for _,r in pairs(ranges) do
        local range = r.range
        table.insert(newLines,{
          points=getCircleVectorPoints(range - modelMeasureLineRadius + 0.05, 0.125),
          color = r.color,
          thickness = modelMeasureLineRadius*2*scaleFactor,
          rotation = (norotate and {0, 0, 0} or {-rotation.x, 0, -rotation.z})
        })
      end
    end
  end

  self.setVectorLines(newLines)
end

function getCircleVectorPoints(radius, height, segments)
    local bounds = self.getBoundsNormalized()
    local result = {}
    local scaleFactorX = 1/self.getScale().x
    local scaleFactorY = 1/self.getScale().y
    local scaleFactorZ = 1/self.getScale().z
    local steps = segments or 64
    local degrees,sin,cos,toRads = 360/steps, math.sin, math.cos, math.rad
    local modelBase = state.base

    local mtoi = 0.0393701
    local baseX = modelBase.x * 0.5 * mtoi
    local baseZ = modelBase.z * 0.5 * mtoi

    for i = 0,steps do
        table.insert(result,{
            x = cos(toRads(degrees*i))*((radius+baseX)*scaleFactorX),
            z = sin(toRads(degrees*i))*((radius+baseZ)*scaleFactorZ),
            y = height*scaleFactorY
        })
    end

    return result
end

function doAutoSize()
  local nx = state.base.x
  local nz = state.base.z
  local bounds = self.getBoundsNormalized()
  if bounds.size.x == 0 or bounds.size.y == 0 then
      local r = self.getRotation()
      self.setRotation(Vector(0,0,0))
      bounds = self.getBounds()
      self.setRotation(r)
  end
  local scale = self.getScale()
  local xi = nx / 25.4
  local zi = nz / 25.4
  local xs = (xi / bounds.size.x) * scale.x
  local zs = (zi / bounds.size.z) * scale.z

  self.setScale(Vector(xs, (xs + zs) / 2, zs))
  refreshVectors()
end

function setBaseSize( x, z )
  state.base = {x=x, z=z}
  -- state.uiHeight=((x + z)/25)
  saveState()
  refreshVectors()
  refreshUI()
end

function addRole( role, hidden )
  local rg = hidden and state.hiddenRoles or state.roles
  local empty = next(rg) == nil
  table.insert(rg, role)
  if empty then
    self.UI.show(hidden and "ktcnid-status-hiddenRole" or "ktcnid-status-role")
  end
  saveState()
end

function removeRole( role )
  local rri = function( rg, id )
    local nr = {}
    for i,v in ipairs(rg) do
      if v ~= role then table.insert(nr, v) end
    end
    rg = nr
    if next(rg) == nil then
      self.UI.hide(id)
    end
  end
  rri(state.roles, "ktcnid-status-role")
  rri(state.hiddenRoles, "ktcnid-status-hiddenRole")
end

function revealRole( role )
  removeRole(role)
  addRole(role, false)
end

isColliding = false
function onCollisionEnter(a)
  if isColliding == true then
    return
  end

  if a.collision_object.getLock() == true then
    return
  end

  isColliding = true

  local mustRefresh = false
  if a.collision_object.hasTag("KTUITokenOrder") then
    local newState = a.collision_object.getDescription()
    a.collision_object.destruct()
    if newState:startswith("Engage") then state.order = "Engage" else state.order = "Conceal" end
    if newState:endswith("ready") then state.ready = true else state.ready = false end
    mustRefresh = true
  elseif a.collision_object.hasTag("KTUITokenSimple") or a.collision_object.hasTag("KTUITokenEquipment") then
    local newState = a.collision_object.getDescription()
    local imageUrl = a.collision_object.getCustomObject().image
    local stackable = a.collision_object.getCustomObject().stackable
    local equipment = a.collision_object.hasTag("KTUITokenEquipment")
    local removable = true
    a.collision_object.destruct()

    if equipment == true then
      stackable = false
      removable = false
    end

    -- If the token is new to the miniature, it adds it to the list of tokens
    if state.attachments[newState] == nil then
      state.attachments[newState] = { name = newState, url = imageUrl, removable = removable, stackable = stackable, secret = false, equipment = equipment, active = true, stack = 1 }
      saveState()
      createUI()
      refreshUI()
    else
      if state.attachments[newState].url ~= imageUrl then
        state.attachments[newState].url = imageUrl
        saveState()
        createUI()
        refreshUI()
      end

      if state.attachments[newState].active == false then
        state.attachments[newState].active = true
        state.attachments[newState].stack = 1
      else
        state.attachments[newState].stack = state.attachments[newState].stack + 1
      end
    end
    mustRefresh = true
  elseif a.collision_object.hasTag("KTUITokenAdvanced") then
    -- The idea is to have the token script itself giving more advanced information on its behaviour
    local newStateClass = a.collision_object.call('KTUI_GetTokenFace')
    a.collision_object.destruct()
    local newState = newStateClass.name
    local imageUrl = newStateClass.url
    local removable = newStateClass.removable
    local stackable = newStateClass.stackable
    local secret = newStateClass.secret
    local equipment = newStateClass.equipment

    if secret == true then
      removable = false
      stackable = false
      equipment = false
    end
    if equipment == true then
      stackable = false
    end

    -- If the token is new to the miniature, it adds it to the list of tokens
    if state.attachments[newState] == nil then
      state.attachments[newState] = { name = newState, url = imageUrl, removable = removable, stackable = stackable, secret = secret, equipment = equipment, active = true, stack = 0 }
      saveState()
      createUI()
      refreshUI()
      mustRefresh = true
    else
      if state.attachments[newState].url ~= imageUrl then
        state.attachments[newState].url = imageUrl
        saveState()
        createUI()
        refreshUI()
        mustRefresh = true
      end

      if state.attachments[newState].active == false then
        state.attachments[newState].active = true
      end
    end
    mustRefresh = true
  end

  if mustRefresh then
    saveState()
    refreshUI()
    Wait.frames(function() isColliding = false self.reload() end, 30)
  end
  Wait.frames(function() isColliding = false end, 40)
end


function KTUI_ReadyOperative()
  state.ready = true
  refreshUI()
end

function KTUI_CleanOperative()
  state.attachments = {}
  refreshUI()
end


function comCheckOwner(t)
  return t[1] == state.owner
end

function comBaseSize()
  return state.base
end

function comSetBase(t)
  setBaseSize(t.x, t.z)
end

function comAutoSize()
  doAutoSize()
  refreshUI()
end

function comSavePosition( t )
  savePosition(t.position, t.rotation)
end

function comLoadPosition()
  loadPosition()
end

function comAddRole( t )
  addRole(t.role, t.hidden)
end

function comRemoveRole( t )
  removeRole(t.role)
end

function comRevealRole( t )
  revealRole(t.role)
end

function comSetUIAngle( t )
  state.uiAngle = t.uiAngle
  saveState()
  refreshUI()
end

string.startswith = function(self, str)
    return self:find('^' .. str) ~= nil
end
string.endswith = function(self, str)
    return self:find(str .. "$") ~= nil
end

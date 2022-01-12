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
  refreshVectors(true)
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
  end

  self.setName(string.gsub(nname, "%b{}", namewstring()))
end

function callback_attachment(player, value, id)
  local attachment = id:gsub("ktcnid[-]status[-]", "")
  local mustRefresh = false
  if state.attachments[attachment].active == false or state.attachments[attachment].removable == false then return end
  if state.attachments[attachment].stackable then
    state.attachments[attachment].stack = state.attachments[attachment].stack - 1
    if state.attachments[attachment].stack <= 0 then
      state.attachments[attachment].stack = 0
      state.attachments[attachment].active = false
    end
    mustRefresh = true
  else
    state.attachments[attachment].active = false
    mustRefresh = true

  end

  if mustRefresh then
    saveState()
    refreshUI()
  end
end

function callback_secret(player, value, id)
  local attachment = id:gsub("ktcnid[-]status[-]", "")
  state.attachments[attachment].active = not state.attachments[attachment].active
  saveState()
  refreshUI()
end

function callback_orders(player, value, id)
  if state.ready == nil or state.ready then
    state.ready = false
  else
    state.ready = true
  end
  refreshUI()
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
  local off_order = 50
  if state.display_arrows then
    off_injured = -65
    off_order = 80
  end

  local xmlTable = [[<Defaults>
  <Image class="statusDisplay" hideAnimation="Shrink" showAnimation="Grow" preserveAspect="true" />
</Defaults>
<Panel position="0 0 -]]..tostring(state.uiHeight*100*scaleFactorZ)..[[" width="100" height="100" rotation="0 0 ]]..(state.uiAngle or 0)..[[" scale="]]..scaleFactorX..[[ ]]..scaleFactorY..[[ ]]..scaleFactorZ..[[">

  <HorizontalLayout spacing="3" width="@totalSecret" height="20" offsetXY="-20 -10">
    --@SecretsPlaceholder
  </HorizontalLayout>

	<Panel color="#808080" outline="#FF5500" outlineSize="2 2" width="80" height="25" offsetXY="]]..circOffset(40, 270)..[[">
    <Image id="ktcnid-status-injured" image="wound" width="30" height="30" rectAlignment="MiddleLeft" offsetXY="]]..off_injured..[[ 0" active="]]..tostring(isInjured())..[[" />
		<Button text="-" width="30" height="30" offsetXY="-65 0" onClick="damage" active="]]..tostring((state.display_arrows or false))..[[" />
		<Text id="ktcnid-status-wounds" text="]]..string.format("%d/%d", state.wounds, state.stats.W)..[[" resizeTextForBestFit="true" color="#ffffff" onClick="toggleArrows" />
		<Button text="+" width="30" height="30" offsetXY="65 0" onClick="heal" active="]]..tostring((state.display_arrows or false))..[[" />
    <Image id="ktcnid-status-order" image="]]..getCurrentOrder()..[[" rectAlignment="MiddleRight" width="40" height="40" offsetXY="]]..off_order..[[ 0" active="true" onClick="callback_orders" />
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
    if i.secret == false then
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
      local xmlAttachmentFormatted = [[<Image id="ktcnid-status-]]..i.name..[[" image="]]..i.name..[[" width="20" height="20" preserveAspect="true"]]
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

  xmlTable = xmlTable:gsub("@totalAtt", tostring((totalAtt * 30) + (totalStack * 20)))
  xmlTable = xmlTable:gsub("@totalSecret", tostring((totalSecrets * 20)))
  xmlTable = xmlTable:gsub("--@SecretsPlaceholder", secretxmlAttachmentFormatted)


  self.UI.setXml(xmlTable)
  if state.wounds == 0 then
    Wait.frames(function() refreshWounds() end, 1)
  end
end

function createUI()
  local baseBundle = {
    {name="Engage_ready", url=[=[http://cloud-3.steamusercontent.com/ugc/1857171492582455191/E8DBB48F334D7D7C12849DBB70EA45C488693916/]=]},
    {name="Engage_activated", url=[=[http://cloud-3.steamusercontent.com/ugc/1857171492582455274/A6A8C7DC303776C8AA8BD08B210E48A61A703EC2/]=]},
    {name="Conceal_ready", url=[=[http://cloud-3.steamusercontent.com/ugc/1857171492582455444/B011F9E34A1AED8C44731C11DA4C3F794124E0C3/]=]},
    {name="Conceal_activated", url=[=[http://cloud-3.steamusercontent.com/ugc/1857171492582455368/B47A139555B45E42588B19225F86F2B9461D50A0/]=]},
    {name="wound",   url=[=[http://cloud-3.steamusercontent.com/ugc/1857171826950614938/C515FF37C3D1D269533C1B5FDA675895F792BC15/]=]},
  }

  for _,i in pairs(state.attachments) do
    table.insert(baseBundle, {name=i.name, url=i.url})
  end
  self.UI.setCustomAssets(baseBundle)
end

function isInjured()
  return state.wounds < state.stats.W / 2
end

function toggleArrows()
  state.display_arrows = not state.display_arrows
  refreshUI()
end

function damage(pc)
  local si = isInjured()
  state.wounds = math.max(0, state.wounds - 1)
  if not si and isInjured() then
    self.UI.show("ktcnid-status-injured")
  end
  saveState()
  refreshWounds()
end

function heal(pc)
  local si = isInjured()
  state.wounds = math.min(state.stats.W, state.wounds + 1)
  if si and not isInjured() then
    self.UI.hide("ktcnid-status-injured")
  end
  saveState()
  refreshWounds()
end

function onLoad(ls)
  loadState()
  state.display_arrows = false
  if state.attachments == nil then
    state.attachments = {}
  end

  self.addContextMenuItem("Engage", function(pc)  setEngage() end)
  self.addContextMenuItem("Conceal", function(pc)  setConceal() end)

  self.addContextMenuItem("Save place", function(pc) savePosition() end)
  self.addContextMenuItem("Load place", function(pc) loadPosition() end)

  local taglist = {state.modelid, "Operative"}
  for _,category in pairs(state.info.categories) do
    table.insert(taglist, category)
  end
  self.setTags(taglist)
  self.addTag("KTUIMini")
  createUI()
  refreshUI()
  refreshVectors()
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
  isColliding = true

  local mustRefresh = false
  if a.collision_object.hasTag("KTUITokenOrder") then
    local newState = a.collision_object.getDescription()
    a.collision_object.destruct()
    if newState:startswith("Engage") then state.order = "Engage" else state.order = "Conceal" end
    if newState:endswith("ready") then state.ready = true else state.ready = false end
    mustRefresh = true
  elseif a.collision_object.hasTag("KTUITokenSimple") then
    local newState = a.collision_object.getDescription()
    local imageUrl = a.collision_object.getCustomObject().image
    local stackable = a.collision_object.getCustomObject().stackable
    a.collision_object.destruct()
    -- If the token is new to the miniature, it adds it to the list of tokens
    if state.attachments[newState] == nil then
      state.attachments[newState] = { name = newState, url = imageUrl, removable = true, stackable = stackable, secret = false, active = true, stack = 0 }
      saveState()
      createUI()
    else
      if state.attachments[newState].url ~= imageUrl then
        state.attachments[newState].url = imageUrl
        saveState()
        createUI()
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

    if secret == true then
      removable = false
      stackable = false
    end
    -- If the token is new to the miniature, it adds it to the list of tokens
    if state.attachments[newState] == nil then
      state.attachments[newState] = { name = newState, url = imageUrl, removable = removable, stackable = stackable, secret = secret, active = true, stack = 0 }
      saveState()
      createUI()
    else
      if state.attachments[newState].url ~= imageUrl then
        state.attachments[newState].url = imageUrl
        saveState()
        createUI()
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
  end
  Wait.frames(function() isColliding = false end, 60)
end


function KTUI_ReadyOperative() -- For possible integrations with any other UI
  state.ready = true
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
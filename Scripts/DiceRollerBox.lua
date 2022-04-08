--Based off: https://steamcommunity.com/sharedfiles/filedetails/?id=726800282
--Link for this mod: https://steamcommunity.com/sharedfiles/filedetails/?id=959360907

--Initialize Global Variables and pRNG Seed
math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,7))+tonumber(tostring(os.clock()):reverse():sub(1,7)))
ver = 'BCB-2018-12-16'

lastHolder = {}
customFace = {4, 6, 8, 10, 12, 20}
diceGuidFaces = {}
sortedKeys = {}
resultsTable = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

--Determine the person who put the dice in the box.
function onObjectPickedUp(playerColor, obj)
	lastHolder[obj] = playerColor
end

--Reset the person holding the dice when no dice are held.
function onObjectDestroyed(obj)
	lastHolder[obj] = nil
end

--Reset description on load if empty.
function onLoad(save_state)
	if self.getDescription() == '' then
		setDefaultState()
	end
end

--Returns description on game save.
function onSave()
	return self.getDescription()
end

--Reset description on drop if empty.
function onDropped(player_color)
	if self.getDescription() == '' then
		setDefaultState()
	end
end

--Sets default description.
function setDefaultState()
	self.setDescription(JSON.encode_pretty({Results = 'no', SmoothDice = 'no', Rows = 'yes', SortNoRows = 'asc', Step = 1, Version = ver}))
end

--Creates a table and sorts the dice guids by value.
function sortByVal(t, type)
	local keys = {}
	for key in pairs(t) do
		table.insert(keys, key)
	end
	if type == 'asc' then
		table.sort(keys, function(a, b) return t[a] < t[b] end)
	elseif type == 'desc' then
		table.sort(keys, function(a, b) return t[a] > t[b] end)
	end
	return keys
end

--Checks the item dropped in the bag has a guid.
function hasGuid(t, g)
	for k, v in ipairs(t) do
		if v.guid == g then return true end
	end

	return false
end
--Runs when non-dice is put into bag
function onObjectEnterContainer(container, obj)
    if container == self and obj.tag ~= "Dice" then
        local pos = self.getPosition()
        local f = self.getTransformRight()
        self.takeObject({
            position          = {pos.x+20,pos.y+50,pos.z+20},
            smooth            = false,
        })
        return
    end
end
--Runs when an object is dropped in bag.
function onCollisionEnter(collision_info)
	playerColor = lastHolder[collision_info.collision_object]
	if collision_info.collision_object.getGUID() == nil then return end
	diceGuidFaces = {}
	sortedKeys = {}

--Save number of faces on dice
	for k, v in ipairs(getAllObjects()) do
		if v.tag == 'Dice' then
			objType = tostring(v)
			faces = tonumber(string.match(objType, 'Die_(%d+).*'))
			if faces == nil then
				faces = tonumber(customFace[v.getCustomObject().type + 1])
			end
		diceGuidFaces[v.getGUID()] = faces
		table.insert(sortedKeys, v.getGUID())
		end
	end

--[[Benchmarking code
if resetclock ~= 1 then
clockstart = os.clock()
resetclock = 1
end--]]

--Creates a timer to take the dice out and position them.
	Wait.time(|| takeDiceOut(), 0.3)
end

--Function to take the dice out of the bag and position them.
function takeDiceOut(tab)
	local data = JSON.decode(self.getDescription())
	if data == nil then
		setDefaultState()
		data = JSON.decode(self.getDescription())
		printToAll('Warning - invalid description. Restored default configuration.', {0.8, 0.5, 0})
	end

	if data.Step < 1 then
		setDefaultState()
		data = JSON.decode(self.getDescription())
		printToAll('Warning - "step" can\'t be lower than 1. Restored default configuration.', {0.8, 0.5, 0})
	end

	diceGuids = {}
	for k, v in pairs(self.getObjects()) do
		faces = diceGuidFaces[v.guid]
		r = math.random(faces)
		diceGuids[v.guid] = r
	end

	local objs = self.getObjects()
	local position = getObjectFromGUID("8afa65").getPosition()
	rotation = getObjectFromGUID("8afa65").getRotation()
	sortedKeys = sortByVal(diceGuids, data.SortNoRows)
	Rows = {}
	n = 1
	diceTab = {}
	count =0
	diceValue =1

	for _, key in pairs(sortedKeys) do
		if diceGuids[key] == math.floor(diceGuids[key]) then
			resultsTable[diceGuids[key]] = resultsTable[diceGuids[key]] + 1
		end

	if hasGuid(objs, key) then
		if Rows[diceGuids[key]] == nil then
			Rows[diceGuids[key]] = 0
		end
		Rows[diceGuids[key]] = Rows[diceGuids[key]] + 1
		params = {}
		params.guid = key

		if diceValue != diceGuids[key] then

			diceValue = diceGuids[key]
			count =0
		end
		params.position = getPoint(-count-2, (-diceGuids[key]*1.17)+4.66)
		count = count +1


		params.callback = 'setValueCallback'
		params.params = {diceGuids[key]}
		params.smooth = false
		if data.SmoothDice == 'yes' then params.smooth = true end
			obj = self.takeObject(params)
			table.insert(diceTab,obj)
			getObjectFromGUID("8afa65").call("setDice",{ diceTabTemp = diceTab, player = "Red" })

			n = n + 1
		end

	end
	printresultsTable()
--[[Benchmarking code
	clockend = os.clock()
	resetclock=0
	print('Runtime: ' .. clockend-clockstart .. ' seconds.')--]]
end

function getPoint(relativeX, relativeZ)

  local pos = Vector(getObjectFromGUID("8afa65").getPosition().x,getObjectFromGUID("8afa65").getPosition().y,getObjectFromGUID("8afa65").getPosition().z)
  local rot = getObjectFromGUID("8afa65").getRotation()
  local angleY = -math.rad(rot.y -90)
  local newX = (relativeX * math.cos(angleY) - relativeZ * math.sin(angleY)) + pos.x
  local newY = pos.y + 4
  local newZ = (relativeZ * math.cos(angleY) + relativeX * math.sin(angleY)) + pos.z
  local final = vector(newX, newY, newZ)
  return final
end

--Function to count resultsTable for printing.
function sum(t)
	local sum = 0
	for k, v in pairs(t) do
		sum = sum + v
	end

	return sum
end

--Prints resultsTable.
function printresultsTable()
	local data = JSON.decode(self.getDescription())
	if sum(resultsTable) > 0 and data.Results == 'yes' then
		local description = {'Ones.', 'Twos.', 'Threes.', 'Fours.', 'Fives.', 'Sixes.', 'Sevens.', 'Eights.', 'Nines.', 'Tens.', 'Elevens.', 'Twelves.', 'Thirteens.', 'Fourteens.', 'Fifteens.', 'Sixteens.', 'Seventeens', 'Eighteens.', 'Nineteens.', 'Twenties.'}
		local msg = ''
		for dieFace, numRolled in ipairs(resultsTable) do
			if numRolled > 0 then
				msg = msg .. numRolled .. ' ' .. description[dieFace] .. ' '
			end
		end

		local message = ""
	  local time = '[' .. os.date("%H") .. ':' .. os.date("%M") .. ':' .. os.date("%S") .. ' UTC] '
	  if playerColor == nil then
	    message = '\n*******************************************************\n' .. time .. '~UNKNOWN PLAYER~ rolls:\n' .. result
	    printToAll(message, {1, 1, 1})
	  else
	    message = '\n*******************************************************\n' .. time .. Player[playerColor].steam_name .. ' rolls:\n' .. result
	    printToAll(message, stringColorToRGB(playerColor))
	  end
	  broadcastToAll(message)
	end

	for k,v in ipairs(resultsTable) do
		resultsTable[k] = 0
	end
end

--Sets the value of the physical dice object and reorients them if needed.
function setValueCallback(obj, tab)
	local isSquare = false
	if (rotation.y < 2) or (88 < rotation.y and rotation.y < 92) or (178 < rotation.y and rotation.y < 182) or (268 < rotation.y and rotation.y < 272) or (rotation.y > 358) then isSquare = true end
	function insidef()
		obj.setValue(tab[1])
		local isThisABloodyCustomDie = obj.getCustomObject()
		local reorientAllDice = false
		if obj.tag == 'Dice' then
			objType = tostring(obj)
			callFaces = tonumber(string.match(objType, 'Die_(%d+).*'))
			if callFaces == nil then callFaces = tonumber(customFace[obj.getCustomObject().type + 1]) end
			diceGuidFaces[obj.getGUID()] = callFaces
		end

		if isSquare then
			if isThisABloodyCustomDie.image ~= nil and callFaces == 6 then
				waitFrames(35)
				local r = obj.getRotation()
				local rot =  getObjectFromGUID("8afa65").getRotation()
				obj.setRotation({r.x, rot.y + 180, r.z})
			end
		else

			if callFaces == 6 then
				waitFrames(35)
				local rot =  getObjectFromGUID("8afa65").getRotation()
				local r = obj.getRotation()
				obj.setRotation({r.x, rot.y + 180, r.z})
			end
		end

		return 1
	end

	startLuaCoroutine(self, 'insidef')
end

--Coroutine to wait to allow for custom dice positional data to be altered.
function waitFrames(frames)
	while frames > 0 do
		coroutine.yield(0)
		frames = frames - 1
	end
end


--Function to print table contents.
--[[
function printTable(tempTable)
	for k, v in pairs(tempTable) do
		print('key = ' .. k)
		print('value =' .. v)
	end
end
--]]

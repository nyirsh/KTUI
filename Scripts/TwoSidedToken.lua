token_name = "Conceal"
face_up_modifier = "_ready"
face_down_modifier = "_activated"
face_up_limit = 180
face_coordinate = "x"

face_current_state = token_name..face_up_modifier
debug = true

function onLoad()
  debug = false -- Change it to false before publishing
  KTUI_CalculateTokenFace(false)
end

function onRotate(spin, flip, player_color, old_spin, old_flip)
    local rot_value = flip
    local old_rot_value = old_flip

    if face_coordinate == "y" then
      rot_value = spin
      old_rot_value = old_spin
      if debug then print("Spin") end
    end

    rot_value = tonumber(string.format("%.2f", rot_value))
    old_rot_value = tonumber(string.format("%.2f", old_rot_value))
    if (rot_value > face_up_limit and old_rot_value <= face_up_limit)
      or (rot_value < face_up_limit and old_rot_value >= face_up_limit) then
      KTUI_CalculateTokenFace(true)
    end
end

function onPickUp()
    KTUI_CalculateTokenFace(false)
end

function onCollisionEnter(info)
    KTUI_CalculateTokenFace(false)
end

function KTUI_CalculateTokenFace(flipped)
  rot = self.getRotation()
  rotC = 360

  if face_coordinate == "x" then
    rotC = rot.x
  elseif face_coordinate == "y" then
    rotC = rot.y
  else
    rotC = rot.z
  end

  if (rotC >= face_up_limit and not flipped)
    or (rotC <= face_up_limit and flipped)
  then
    face_current_state = token_name..face_up_modifier

  else
    face_current_state = token_name..face_down_modifier
  end

  if debug then
    print(KTUI_GetTokenFace())
  end
end


function KTUI_GetTokenFace()
  return face_current_state
end

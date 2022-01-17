face_up_settings = { name = "Token_faceup", url = "https://example.com/Token_faceup.png", removable = true, stackable = false, secret = false, equipment = false }
face_down_settings = { name = "Token_faceup", url = "https://example.com/Token_faceup.png", removable = true, stackable = false, secret = false, equipment = false }
is_face_up = true
face_coordinate = "x" -- Change this to either x, y or z accordingly to the model flip axis
face_up_limit = 180 -- Change this to modify the rotational value of the above selected coordinate after which the token will be considered facing down


function onLoad()
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
    is_face_up = true

  else
    is_face_up = false
  end
end


function KTUI_GetTokenFace()
  if is_face_up then
    return face_up_settings
  else
    return face_down_settings
  end
end
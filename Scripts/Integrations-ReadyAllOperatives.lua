function KTUI_ReadyAllOperatives()
  for _, obj in ipairs(getAllObjects()) do
    if obj.hasTag('KTUIMini') then
      obj.call('KTUI_ReadyOperative')
    end
  end
end

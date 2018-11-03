local hasTabs = function(win)
  print("checking", win, timestamp())

  local parent = axuiWindowElement(win):attributeValue('AXParent')
  if not parent then
    print("no parent")
    return false
  end

  local children = parent:attributeValue('AXChildren')
  if #children < 1 then
    print("no children")
    return false
  end

  local tabGroup = children[1]:elementSearch({ role = "AXTabGroup" })
  if #tabGroup < 1 then
    print("no tab group")
    return false
  end

  print(timestamp())

  return true
end

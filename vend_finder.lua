-- Created by NIXEL
-- my github https://github.com/ValdazGT
-- contact me on whatsapp wa.me/6288279119895

addCategory("Nixel", "Verified")
local ui = UserInterface.new("Vend Finder", "Verified")
ui:addTooltip("Vend Finder", "Gunakan Find untuk mendapatkan koordinat x dan y, lalu gunakan FindPath untuk langsung teleport ke lokasi tersebut.", "Verified", true)
ui:addLabel("Pick Item") 
ui:addItemPicker("Select Item", "Dirt", "2", "findid") 
ui:addButton("Find", "finder") 
ui:addButton("FindPath", "fpath")

local vendfindui = ui:generateJSON() 
addIntoModule(vendfindui, "Nixel") 

local vdi = UserInterface.new("Vend Input", "Verified")
vdi:addTooltip("On Wrench", "Jika wrench diarahkan ke vending machine,\nmaka item akan dimasukkan ke vending.", "Verified", true) 
local dialog = vdi:addDialog("Vend Settings", "Settings", {}) 
vdi:addChildInputInt(dialog.menu, "Vend Pos X", "0", "Pos X", "Enter number", "Verified", "posxvend")
vdi:addChildInputInt(dialog.menu, "Vend Pos Y", "0", "Pos Y", "Enter number", "Verified", "posyvend")
vdi:addChildButton(dialog.menu, "Get Current Pos", "vendcurrent") 
vdi:addChildInputString(dialog.menu, "World Name", "", "World name", "Enter world name", "Verified", "worldvend")
vdi:addChildButton(dialog.menu, "Get Current World", "vendworldcurrent") 

local dialog1 = vdi:addDialog("Item Settings", "Settings", {})
vdi:addChildInputInt(dialog1.menu, "Item Pos X", "0", "Pos X", "Enter number", "Verified", "posxitem")
vdi:addChildInputInt(dialog1.menu, "Item Pos Y", "0", "Pos Y", "Enter number", "Verified", "posyitem")
vdi:addChildButton(dialog1.menu, "Get Current Pos", "itemcurrent") 
vdi:addChildInputString(dialog1.menu, "World Name", "", "World name", "Enter world name", "Verified", "worlditem")
vdi:addChildButton(dialog1.menu, "Get Current World", "itemworldcurrent") 

vdi:addToggle("WORLD 2 WORLD", "w2w") 
vdi:addToggle("On Wrench", "onwrench") 
vdi:addSlider("Delay", 1000, 5000, 2000, false, "inpdelay") 
vdi:addToggleButton("Auto Input", false, "power_inp")

local vendinputui = vdi:generateJSON() 
addIntoModule(vendinputui, "Nixel") 

local isInput = false

function spr(type, value, tileX, tileY)
    SendPacketRaw(false, {
        type = type,
        value = value,
        px = tileX,
        py = tileY,
        x = GetLocal().posX,
        y = GetLocal().posY
    })
end

runCoroutine(function() 
while isInput do
local delay = getValue(1, "inpdelay")
local vendpos = { x = getValue(1, "posxvend"), y = getValue(1, "posyvend") }
local itempos = { x = getValue(1, "posxitem"), y = getValue(1, "posyitem") }
local isW2W = getValue(0, "w2w") 
local vendworld = getValue(2, "worldvend") 
local itemworld = getValue(2, "worlditem") 
if isW2W then
growtopia.warpTo(itemworld)
Sleep(delay) 
end
FindPath(itempos.x, itempos.y) 
Sleep(delay) 
if isW2W then
growtopia.warpTo(vendworld) 
Sleep(delay) 
end
FindPath(vendpos.x, vendpos.y) 
Sleep(delay) 
spr(3, 32, vendpos.x, vendpos.y) 
SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|".. vendpos.x .. "|\ntiley|" .. vendpos.y "|\nbuttonClicked|addstock\n\nsetprice|0\nchk_peritem|0\nchk_perlock|1") 
if not isInput then
growtopia.notify("Wait...") 
end
coroutine.yield()
end
end) 

function vendfind(item_id)
  for _, tile in pairs(GetTiles()) do
    if tile.fg == 2978 or tile.fg == 9268 then
      local ext = tile.extra
      if ext.owner ~= 0
        and ext.lastupdate ~= 0
        and tonumber(ext.lastupdate) == item_id
      then
        return { x = tile.x, y = tile.y }
      end
    end
  end

  return nil
end

addHook(function(type, name, value)
local player = GetLocal() 
local pos = { x = player.posX // 32, y = player.posY // 32 }
if name == "power_inp" then
isInput = value
end
if name == "vendcurrent" then
editValue("posxvend", pos.x) 
editValue("posyvend", pos.y) 
elseif name == "itemcurrent" then
editValue("posxitem", pos.x) 
editValue("posyitem", pos.y) 
end

if name == "vendworldcurrent" then
local world = GetWorldName() 
editValue("worldvend", world) 
elseif name == "itemworldcurrent" then
local world = GetWorldName() 
editValue("worlditem", world) 
end
  if name == "finder" or name == "fpath" then
    local item_id = tonumber(getValue(1, "findid"))
    local vendfinder = vendfind(item_id)

    if not vendfinder then
      growtopia.notify("Not found.")
      return
    end

    if name == "finder" then
      growtopia.notify(
        "Found: x: " .. vendfinder.x .. ", y: " .. vendfinder.y
      )
    elseif name == "fpath" then
      growtopia.notify("Found.")
      FindPath(vendfinder.x, vendfinder.y)
    end
  end

end, "onValue") 

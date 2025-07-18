HouseHotbar = {}
local saved
local LAM = LibAddonMenu2
local panelName = "HouseHotbarPanel"

local KNOWN_DUMMY_HOUSES = {
  81,   -- Mara's Kiss Public House
  83,   -- The Ebony Flask Inn Room
  84,   -- Flaming Nix Deluxe Garret
  85,   -- Sisters of the Sands Inn Room
  87,   -- The Rosy Lion
  93,   -- The Golden Gryphon Garret
  94,   -- Saint Delyn Penthouse
  95,   -- Sugar Bowl Suite
  96,   -- Moonmirth House
  97,   -- Barbed Hook Private Room
}

local function SuggestDummyHouse()
  for _, id in ipairs(KNOWN_DUMMY_HOUSES) do
    local unlocked = select(4, GetCollectibleInfo(id))
    if not unlocked then
      return id
    end
  end
  return nil -- fallback if user owns all
end

-- Travel to a house slot (1-7)
function HouseHotbar_Travel(slot)
    local collectibleId = saved.slots[slot]
    if collectibleId and IsCollectibleUnlocked(collectibleId) then
        JumpToCollectibleHouse(collectibleId)
    else
        d("Slot " .. slot .. " is unassigned or the house is not unlocked.")
    end
end

-- Return to original location using a dum house
function HouseHotbar_ReturnToOriginal()
    local dumId = saved.returnHouseId
    if not dumId then
        d("No unowned house set for return travel.")
        return
    end

    if IsCollectibleUnlocked(dumId) then
        d("Your jumpback house is owned! This won't work.")
        return
    end

    d("Teleporting to unowned house to return to original location...")
    JumpToCollectibleHouse(dumId)

    -- Wait for zone change then leave the house
    EVENT_MANAGER:RegisterForEvent("HouseHotbar", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent("HouseHotbar", EVENT_PLAYER_ACTIVATED)
        d("Leaving house to return to original location...")
        RequestJumpToHouseLeave()
    end)
end

-- Addon init
local function OnAddOnLoaded(_, addonName)
    if addonName ~= "HouseHotbar" then return end
    EVENT_MANAGER:UnregisterForEvent("HouseHotbar", EVENT_ADD_ON_LOADED)

    if not HouseHotbar.saved.returnHouseId then
      local suggested = SuggestDummyHouse()
      if suggested then
        HouseHotbar.saved.returnHouseId = suggested
        d(string.format("House Hotbar: Auto-selected '%s' as dummy house.", GetCollectibleInfo(suggested)))
      else
        d("House Hotbar: No unowned dummy house available. Please set one manually.")
      end
    end

    saved = ZO_SavedVars:New("HouseHotbar_Saved", 1, nil, {
        slots = {},
        returnHouseId = nil
    })

    EVENT_MANAGER:RegisterForEvent("HouseHotbar", EVENT_PLAYER_ACTIVATED, function()
    if not HouseHotbar._isReturning then return end

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local currentCollectible = GetCurrentZoneHouseId()
    local expected = HouseHotbar.saved.returnHouseId

    if currentCollectible == expected then
        -- Exit the house immediately
        HouseHotbar._isReturning = false
        d("[HouseHotbar] Returning to original location...")
        JumpToHouse(HOUSE_EXIT_LOCATION)
    end
    end)



    -- Create default slots
    for i = 1, 7 do
        if saved.slots[i] == nil then
            saved.slots[i] = nil
        end
    end

    HouseHotbar.CreateSettingsMenu()

    HouseHotbar.saved = saved

    HouseHotbar.saved = ZO_SavedVars:New("HouseHotbarSaved", 1, nil, {
      houseAssignments = {},       -- [1] to [7] = collectibleId
      returnHouseId = nil,
    })
end

local function GetHouseDropdownChoices()
    local choices, values = {}, {}
    for i = 1, GetTotalCollectibleHouses() do
        local id = GetCollectibleHouseId(i)
        local name, _, icon, unlocked = GetCollectibleInfo(id)
        if unlocked then
            table.insert(choices, name)
            table.insert(values, id)
        end
    end
    return choices, values
end

local function GetDumHouseChoices()
    local choices, values = {}, {}
    for _, id in ipairs(HouseHotbar.KNOWN_DUMMY_HOUSES) do
        local name, _, _, unlocked = GetCollectibleInfo(id)
        local label = name .. (unlocked and " (Owned)" or " (Unowned)")
        table.insert(choices, label)
        table.insert(values, id)
    end
    return choices, values
end

function HouseHotbar.CreateSettingsMenu()
    local panel = {
        type = "panel",
        name = "House Hotbar",
        displayName = "House Hotbar",
        author = "Sara Jarjoura",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    local options = {}

    -- House slot dropdowns
    for i = 1, 7 do
        table.insert(options, {
            type = "dropdown",
            name = string.format("House Slot %d", i),
            tooltip = "Choose a house to assign to this slot.",
            choices = function()
                local names = {}
                for i = 1, GetTotalCollectibleHouses() do
                    local id = GetCollectibleHouseId(i)
                    local name, _, _, unlocked = GetCollectibleInfo(id)
                    if unlocked then table.insert(names, name) end
                end
                return names
            end,
            getFunc = function()
                local id = HouseHotbar.saved.slots[i]
                if not id then return "Unassigned" end
                local name = GetCollectibleInfo(id)
                return name or "Unknown"
            end,
            setFunc = function(choice)
                for j = 1, GetTotalCollectibleHouses() do
                    local id = GetCollectibleHouseId(j)
                    local name, _, _, unlocked = GetCollectibleInfo(id)
                    if unlocked and name == choice then
                        HouseHotbar.saved.slots[i] = id
                        break
                    end
                end
            end,
        })
    end

-- Dummy house picker
    table.insert(options, {
        type = "dropdown",
        name = "Unowned House for Return Function",
        tooltip = "Choose a house you do not own that will return you to your last location.",
        choices = function()
            return GetDumHouseChoices()
        end,
        getFunc = function()
            local id = HouseHotbar.saved.returnHouseId
            if not id then return "Unassigned" end
            local name = GetCollectibleInfo(id)
            return name or "Unknown"
        end,
        setFunc = function(choice)
            for _, id in ipairs(HouseHotbar.KNOWN_DUMMY_HOUSES) do
                local name = GetCollectibleInfo(id)
                if name == choice or choice:find(name, 1, true) then
                    HouseHotbar.saved.returnHouseId = id
                    break
                end
            end
        end,
    })

    LAM:RegisterAddonPanel(panelName, panel)
    LAM:RegisterOptionControls(panelName, options)
    PopulateHouseDropdowns()
end

local function PopulateHouseDropdowns()
    local houseChoices, houseValues = {}, {}

    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSING) do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_HOUSING, i)
        if collectibleId and collectibleId ~= 0 then
            local name, _, _, unlocked = GetCollectibleInfo(collectibleId)
            table.insert(houseChoices, name .. (unlocked and "" or " (Locked)"))
            table.insert(houseValues, collectibleId)
        end
    end

    -- Assign to each dropdown
    for i = 1, 7 do
        local control = _G["HouseHotbarSlot" .. i .. "Dropdown"]
        if control then
            control.data.choices = houseChoices
            control.data.choicesValues = houseValues
        end
    end

    local returnControl = _G["HouseHotbarReturnDropdown"]
    if returnControl then
        returnControl.data.choices = houseChoices
        returnControl.data.choicesValues = houseValues
    end
end


local menuOpen = false

function HouseHotbar.OpenRadialMenu()
    if menuOpen then return end
    menuOpen = true
    HouseRadialMenu:SetHidden(false)
    ZO_RadialMenu:Clear()

    local function teleportToCollectible(id)
        if IsCollectibleUnlocked(id) then
            UseCollectible(id)
        else
            d("House is not unlocked.")
        end
    end

    -- Add 7 house slots
    for i = 1, 7 do
        local id = HouseHotbar.saved.slots[i]
        if id then
            local name, _, icon = GetCollectibleInfo(id)
            ZO_RadialMenu:AddEntry(name, icon, function()
                teleportToCollectible(id)
            end)
        end
    end

    -- Add return slot (dummy house)
    local returnId = HouseHotbar.saved.returnHouseId
    if returnId then
        ZO_RadialMenu:AddEntry("Return", "/esoui/art/icons/house_icon_placeholder.dds", function()
            HouseHotbar._isReturning = true
            UseCollectible(MyHouseHotbar.saved.returnHouseId)
        end)
    end

    ZO_RadialMenu:Show(HouseRadialMenuMenu)
end

function HouseHotbar.CloseRadialMenu()
    menuOpen = false
    ZO_RadialMenu:Hide()
    HouseRadialMenu:SetHidden(true)
end


EVENT_MANAGER:RegisterForEvent("HouseHotbar", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

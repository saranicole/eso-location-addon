--Name Space
HouseHotkey = {}
local HH = HouseHotkey

--Basic Info
HH.Name = "HouseHotkey"
HH.Author = "@thisbeaurielle"
HH.Version = "1.0.0"

--Setting
HH.Default = {
  CV = false,
  Command = {
    [HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {},
    [HOTBAR_CATEGORY_ALLY_WHEEL] = {},
    [HOTBAR_CATEGORY_MEMENTO_WHEEL] = {},
    [HOTBAR_CATEGORY_TOOL_WHEEL] = {},
    [HOTBAR_CATEGORY_EMOTE_WHEEL] = {},
  },
}

--[[ Structure

  [HOTBAR_CATEGORY_XX] = {
    [EntryIndex] = {
      name = "",
      icon = "",
      house = "",
      exterior = "",
    },
    ...
  }
  
--]]

--When Loaded
local function OnAddOnLoaded(eventCode, addonName)
  if addonName ~= HH.Name then return end
	EVENT_MANAGER:UnregisterForEvent(HH.Name, EVENT_ADD_ON_LOADED)
  
  --Get Account/Character Setting
  HH.AV = ZO_SavedVars:NewAccountWide("HouseHotkey_Vars", 1, nil, HH.Default, GetWorldName())
  HH.CV = ZO_SavedVars:NewCharacterIdSettings("HouseHotkey_Vars", 1, nil, HH.Default, GetWorldName())
  HH.SwitchSV()
  
  --Hook Wheels
  HH.HookWheel()

end

local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent("HouseHotkey_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    local currentSearchState = HOUSE_TOURS_SEARCH_MANAGER:GetSearchState(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
    if currentSearchState ~= ZO_HOUSE_TOURS_SEARCH_STATES.COMPLETE then
        HOUSE_TOURS_SEARCH_MANAGER:ExecuteSearch(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
    end
    zo_callLater(HH.BuildMenu, 3000)
end

--Account/Character Setting
function HH.SwitchSV()
  if HH.CV.CV then
    HH.SV = HH.CV
  else
    HH.SV = HH.AV
  end
end

function HH.HookWheel()
  if IsInGamepadPreferredMode() then
      --GamePad Part
      local Old = UTILITY_WHEEL_GAMEPAD.menu.AddEntry
      UTILITY_WHEEL_GAMEPAD.menu.AddEntry = function(Self, name, inactiveIcon, activeIcon, callback, data)
        local Category = UTILITY_WHEEL_GAMEPAD:GetHotbarCategory()
        local Index = tonumber(data.slotNum)
        local New = HH.SV.Command[Category][Index]
        if New then
          Old(Self, New.name, New.icon, New.icon, function() HH.Execute(New.house, New.exterior, New.houseOwner) end, {name = New.name, slotNum = Index})
        else
          Old(Self, name, inactiveIcon, activeIcon, callback, data)
        end
      end
  else
    --PC Part
    local Old = UTILITY_WHEEL_KEYBOARD.menu.AddEntry
    UTILITY_WHEEL_KEYBOARD.menu.AddEntry = function(Self, name, inactiveIcon, activeIcon, callback, data)
      local Category = UTILITY_WHEEL_KEYBOARD:GetHotbarCategory()
      local Index = tonumber(data.slotNum)
      local New = HH.SV.Command[Category][Index]
      if New then
        Old(Self, New.name, New.icon, New.icon, function() HH.Execute(New.house, New.exterior, New.houseOwner) end, {name = New.name, slotNum = Index})
      else
        Old(Self, name, inactiveIcon, activeIcon, callback, data)
      end
    end
  end
end

-- /script HouseHotkey.Execute()
function HH.Execute(Text, Exterior, HouseOwner)
  if HouseOwner ~= "self" then
    JumpToSpecificHouse(HouseOwner, Text)
  else
    RequestJumpToHouse(Text, Exterior)
  end
end

--Icon
HH.IconList = {
  "/esoui/art/crafting/alchemy_tabicon_reagent_up.dds",
  "/esoui/art/crafting/alchemy_tabicon_solvent_up.dds",
  "/esoui/art/crafting/blueprints_tabicon_up.dds",
  "/esoui/art/crafting/designs_tabicon_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_aspect_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_essence_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_potency_up.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_designs.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_fillet.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_improve.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_refine.dds",
  "/esoui/art/crafting/gamepad/gp_jewelry_tabicon_icon.dds",
  "/esoui/art/crafting/gamepad/gp_reconstruct_tabicon.dds",
  "/esoui/art/crafting/jewelryset_tabicon_icon_up.dds",
  "/esoui/art/crafting/patterns_tabicon_up.dds",
  "/esoui/art/crafting/provisioner_indexicon_fish_up.dds",
  "/esoui/art/crafting/provisioner_indexicon_furnishings_up.dds",
  "/esoui/art/crafting/retrait_tabicon_up.dds",
  "/esoui/art/crafting/smithing_tabicon_armorset_up.dds",
  "/esoui/art/crafting/smithing_tabicon_weaponset_up.dds",
  "/esoui/art/writadvisor/advisor_tabicon_equip_up.dds",
  "/esoui/art/writadvisor/advisor_tabicon_quests_up.dds",
  "/esoui/art/companion/keyboard/category_u30_companions_up.dds",
  "/esoui/art/collections/collections_categoryicon_unlocked_up.dds",
  "/esoui/art/collections/collections_tabicon_housing_up.dds",
  "/esoui/art/companion/keyboard/companion_character_up.dds",
  "/esoui/art/companion/keyboard/companion_skills_up.dds",
  "/esoui/art/companion/keyboard/companion_overview_up.dds",
  "/esoui/art/guildfinder/keyboard/guildbrowser_guildlist_additionalfilters_up.dds",
  "/esoui/art/help/help_tabicon_cs_up.dds",
  "/esoui/art/help/help_tabicon_tutorial_up.dds",
  "/esoui/art/lfg/lfg_any_up_64.dds",
  "/esoui/art/lfg/lfg_tank_up_64.dds",
  "/esoui/art/lfg/lfg_dps_up_64.dds",
  "/esoui/art/lfg/lfg_healer_up_64.dds",
  "/esoui/art/lfg/lfg_indexicon_alliancewar_up.dds",
  "/esoui/art/lfg/lfg_indexicon_trial_up.dds",
  "/esoui/art/lfg/lfg_indexicon_zonestories_up.dds",
  "/esoui/art/lfg/lfg_tabicon_grouptools_up.dds",
  "/esoui/art/mail/mail_tabicon_inbox_up.dds",
  "/esoui/art/market/keyboard/tabicon_crownstore_up.dds",
  "/esoui/art/market/keyboard/tabicon_daily_up.dds",
  "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_rawplating_up.dds",
  "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds",
  "/esoui/art/vendor/vendor_tabicon_fence_up.dds",
}

function HH.GetHouseDropdownChoices()
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({ ZO_CollectibleCategoryData.IsHousingCategory }, { ZO_CollectibleData.IsUnlocked })
    local ownedHouseItems = {}
    local counter = 0
    -- Owned houses
    for index, entry in ipairs(collectibleData) do
        if (entry:IsHouse()) then
            local referenceId = entry:GetReferenceId()
            if (not entry:IsLocked()) then
              local houseEntry = {
                name = entry:GetFormattedName(), data = referenceId, owner = "self"
              }
              ownedHouseItems[index] = houseEntry
              counter = counter + 1
            end
        end
    end

    --Favorite Houses
    local favoriteHouses = {}
    favoriteHouses = HOUSE_TOURS_SEARCH_MANAGER:GetSearchResults(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
    for index, entry in ipairs(favoriteHouses) do
      local houseEntry = {
        name = "[FAV] "..entry:GetHouseName(), data = entry:GetHouseId(), owner = entry:GetOwnerDisplayName()
      }
      ownedHouseItems[counter + index] = houseEntry
    end
  return ownedHouseItems
end

function HH.Part(Index)
  local Positons = {"1 - N    ", "2 - NW", "3 - W   ", "4 - SW", "5 - S    ", "6 - SE  ", "7 - E    ", "8 - NE "}
  local Order = {4, 3, 2, 1, 8, 7, 6, 5}
  local StringList = {SI_HOTBARCATEGORY10, SI_HOTBARCATEGORY11, SI_HOTBARCATEGORY12, SI_HOTBARCATEGORY13, SI_HOTBARCATEGORY14}
  local Tep = GetString(StringList[Index - 9]).."\r\n  "
  if HH.SV.Command[Index] then

    for k, v in ipairs(Order) do
      local Content = HH.SV.Command[Index][v]
      local owner = " "
      if Content then
        local InOrOut = HH.Lang.HOUSE_INSIDE
        if Content.exterior then
          InOrOut = HH.Lang.HOUSE_OUTSIDE
        end
        if Content.houseOwner ~= "self" then
          owner = Content.houseOwner
          InOrOut = HH.Lang.HOUSE_INSIDE_ONLY
        else
          owner = " "
        end
        Tep = Tep..Positons[k].."  |t16:16:"..tostring(Content.icon).."|t  "..Content.name.." |c778899( "..Content.houseName.." )|  "..InOrOut.."|  "..owner.."|r\r\n  "
      end
    end
  end

  return Tep.."\r\n"
end

--Menu Part

if not LibHarvensAddonSettings then
    d("LibHarvensAddonSettings is required!")
    return
end

local LAM = LibHarvensAddonSettings

function HH.BuildMenu()

  local houseItems = HH.GetHouseDropdownChoices()

  local panel = LAM:AddAddon(HH.Name, {
    allowDefaults = true,  -- Show "Reset to Defaults" button
    allowRefresh = false    -- Enable automatic control updates
  })

  local configuredHeadline = panel:AddSetting {
    type = LAM.ST_SECTION,
    label = HH.Lang.WHEEL_DESC,
  }

  local configuredLabel = panel:AddSetting {
		type = LAM.ST_LABEL,
    label = function()
      return table.concat({
        HH.Part(HOTBAR_CATEGORY_QUICKSLOT_WHEEL),
        HH.Part(HOTBAR_CATEGORY_ALLY_WHEEL),
        HH.Part(HOTBAR_CATEGORY_MEMENTO_WHEEL),
        HH.Part(HOTBAR_CATEGORY_TOOL_WHEEL),
        HH.Part(HOTBAR_CATEGORY_EMOTE_WHEEL)
      })
    end
  }
  
  --Option Part
  local Category, CategoryName, EntryIndex, EntryIndexName, Icon, IconName, Name, House, HouseName, HouseId, HouseOwner
  local Category2, CategoryName2, EntryIndex2, EntryIndexName2
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = HH.Lang.CHARACTER_SETTING,
    getFunction = function() return HH.CV.CV end,
    setFunction = function(var)
      HH.CV.CV = var
      HH.SwitchSV()
    end
  }
  --Create QuickSlot
  panel:AddSetting {
    type = LAM.ST_SECTION,
    label = HH.Lang.CREATE_QUICKSLOT,
  }
  --Category
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_CATEGORY,
    items = {
      { name = GetString(SI_HOTBARCATEGORY10), data = HOTBAR_CATEGORY_QUICKSLOT_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY13), data = HOTBAR_CATEGORY_ALLY_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY12), data = HOTBAR_CATEGORY_MEMENTO_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY14), data = HOTBAR_CATEGORY_TOOL_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY11), data = HOTBAR_CATEGORY_EMOTE_WHEEL},
    },
    getFunction = function() return CategoryName or GetString(SI_HOTBARCATEGORY10) end,
    setFunction = function(var, itemName, itemData)
      CategoryName = itemName
      Category = tonumber(itemData.data)
    end,
    default = GetString(SI_HOTBARCATEGORY10),
  }
  --Index
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_SLOT,
    items = {
      { name = "1 - N", data = 4 },
      { name = "2 - NW", data = 3 },
      { name = "3 - W", data = 2 },
      { name = "4 - SW", data = 1 },
      { name = "5 - S", data = 8 },
      { name = "6 - SE", data = 7 },
      { name = "7 - E", data = 6 },
      { name = "8 - NE", data = 5 },
    },
    getFunction = function() return EntryIndexName or "1 - N" end,
    setFunction = function(var, itemName, itemData)
      EntryIndexName = itemName
      EntryIndex = tonumber(itemData.data)
    end,
    default = "1 - N",
  }
  --Icon Select
  panel:AddSetting {
    type = LAM.ST_ICONPICKER,
    label = HH.Lang.WHEEL_ICON,
    items = HH.IconList,
    getFunction = function() return Icon  end,
    setFunction = function(var, iconIndex, iconPath)
      IconName = iconPath
      Icon = iconIndex
      end,
    default = 1,
  }
  --Name
  panel:AddSetting {
    type = LAM.ST_EDIT,
    label = HH.Lang.WHEEL_NAME,
    getFunction = function() return Name or "" end,
    setFunction = function(text) Name = text end,
    default = ""
  }
  --House Choice
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.HOUSE,
    items = houseItems,
    getFunction = function()
      return HouseName or ""
    end,
    setFunction = function(control, itemName, itemData)
      HouseName = itemName
      HouseId = itemData.data
      HouseOwner = itemData.owner
    end,
    default = ""
  }
  --Jump to Interior or Exterior
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = HH.Lang.HOUSE_EXTERIOR,
    getFunction = function() return UseExterior or false end,
    setFunction = function(var)
      UseExterior = var
    end,
    default = false,
  }
  --Apply
  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = HH.Lang.WHEEL_APPLY,
    buttonText = HH.Lang.WHEEL_APPLY,
    clickHandler  = function()
      HH.SV.Command[Category or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex or 4] = {
        ["name"] = Name or "",
        ["icon"] = IconName,
        ["house"] = tonumber(HouseId),
        ["exterior"] = UseExterior or false,
        ["houseName"] = HouseName or "",
        ["houseOwner"] = HouseOwner or "self",
      }
      panel:UpdateControls()
    end
  }
  --Status
  panel:AddSetting {
    type = LAM.ST_SECTION,
    label = HH.Lang.WHEEL_EDIT,
  }
  --Category
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_CATEGORY,
    items = {
      { name = GetString(SI_HOTBARCATEGORY10), data = HOTBAR_CATEGORY_QUICKSLOT_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY13), data = HOTBAR_CATEGORY_ALLY_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY12), data = HOTBAR_CATEGORY_MEMENTO_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY14), data = HOTBAR_CATEGORY_TOOL_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY11), data = HOTBAR_CATEGORY_EMOTE_WHEEL},
    },
    getFunction = function() return CategoryName2 or GetString(SI_HOTBARCATEGORY10) end,
    setFunction = function(var, itemName, itemData)
      CategoryName2 = itemName
      Category2 = tonumber(itemData.data)
    end,
    default = GetString(SI_HOTBARCATEGORY10),
  }
  --Index
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_SLOT,
    items = {
      { name = "1 - N", data = 4 },
      { name = "2 - NW", data = 3 },
      { name = "3 - W", data = 2 },
      { name = "4 - SW", data = 1 },
      { name = "5 - S", data = 8 },
      { name = "6 - SE", data = 7 },
      { name = "7 - E", data = 6 },
      { name = "8 - NE", data = 5 },
    },
    getFunction = function() return EntryIndexName2 or "1 - N" end,
    setFunction = function(var, itemName, itemData)
      EntryIndexName2 = itemName
      EntryIndex2 = tonumber(itemData.data)
      end,
    default = "1 - N",
  }
  --Empty
  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = HH.Lang.WHEEL_EMPTY,
    buttonText = HH.Lang.WHEEL_EMPTY,
    clickHandler = function()
      HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {}
      panel:UpdateControls()
    end,
  }
  --Delete
  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = HH.Lang.WHEEL_DELETE,
    buttonText = HH.Lang.WHEEL_DELETE,
    clickHandler = function()
      HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex2 or 4] = nil
      panel:UpdateControls()
    end,
  }
end

-- Start Here
EVENT_MANAGER:RegisterForEvent(HH.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("HouseHotkey_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

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
  }
}

HH.HouseData = {
  ownedHouses = {},
  ownedHouseItems = {},
  totalOwnedHouses = 0,
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

  --Populate Houses
  HH.GetHouseDropdownChoices()

  --Menu
  HH.BuildMenu()

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
  --PC Part
  local Old = UTILITY_WHEEL_KEYBOARD.menu.AddEntry
  UTILITY_WHEEL_KEYBOARD.menu.AddEntry = function(Self, name, inactiveIcon, activeIcon, callback, data)
    local Category = UTILITY_WHEEL_KEYBOARD:GetHotbarCategory()
    local Index = data.slotNum
    local New = HH.SV.Command[Category][Index]
    if New then
      Old(Self, New.name, New.icon, New.icon, function() HH.Execute(New.house, New.exterior) end, {name = New.name, slotNum = Index})
    else
      Old(Self, name, inactiveIcon, activeIcon, callback, data)
    end
  end
  --GamePad Part
  UTILITY_WHEEL_GAMEPAD.menu.AddEntry = function(Self, name, inactiveIcon, activeIcon, callback, data)
    local Category = UTILITY_WHEEL_GAMEPAD:GetHotbarCategory()
    local Index = data.slotNum
    local New = HH.SV.Command[Category][Index]
    if New then
      Old(Self, New.name, New.icon, New.icon, function() HH.Execute(New.house, New.exterior) end, {name = New.name, slotNum = Index})
    else
      Old(Self, name, inactiveIcon, activeIcon, callback, data)
    end
  end
end

-- /script HouseHotkey.Execute()
function HH.Execute(Text, Exterior)
  RequestJumpToHouse(Text, Exterior)
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

function HH.Icon2Text(Table)
  local Tep = {}
  for i = 1, #Table do
    Tep[i] = { name = "|t32:32:"..Table[i].."|t", value = Table[i] }
  end
  return Tep
end

function HH.GetHouseDropdownChoices()
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({ ZO_CollectibleCategoryData.IsHousingCategory }, { ZO_CollectibleData.IsUnlocked })
    local ownedHouseCounter = 0

    for _, entry in ipairs(collectibleData) do
        if (entry:IsHouse()) then
            local referenceId = entry:GetReferenceId()
            if (not entry:IsLocked()) then
              local houseEntry = {
                name = entry:GetFormattedName(), value = referenceId
              }
              HH.HouseData.ownedHouses[tostring(referenceId)] = houseEntry.name
              table.insert(HH.HouseData.ownedHouseItems, houseEntry)
              ownedHouseCounter = ownedHouseCounter + 1
            end
        end
    end
    HH.HouseData.totalOwnedHouses = ownedHouseCounter
end

--Menu Part

if not LibHarvensAddonSettings then
    d("LibHarvensAddonSettings is required!")
    return
end

local LAM = LibHarvensAddonSettings
function HH.BuildMenu()

  local panel = LAM:AddAddon(HH.Name, {
    allowDefaults = true,  -- Show "Reset to Defaults" button
    allowRefresh = true    -- Enable automatic control updates
  })
  
  --Option Part
  local Category, EntryIndex, Icon, IconCustom, Name, House, Status
  local Category2, EntryIndex2
  local options = {
    {
    type = LAM.ST_CHECKBOX,
    label = HH.Lang.CHARACTER_SETTING,
    getFunction = function() return HH.CV.CV end,
    setFunction = function(var)
      HH.CV.CV = var
      HH.SwitchSV()
    end
    },
    --Create QuickSlot
    {
    type = LAM.ST_SECTION,
    label = HH.Lang.CREATE_QUICKSLOT,
    },
    --Category
    {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_CATEGORY,
    items = {
      { name = GetString(SI_HOTBARCATEGORY10), value = HOTBAR_CATEGORY_QUICKSLOT_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY13), value = HOTBAR_CATEGORY_ALLY_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY12), value = HOTBAR_CATEGORY_MEMENTO_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY14), value = HOTBAR_CATEGORY_TOOL_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY11), value = HOTBAR_CATEGORY_EMOTE_WHEEL},
    },
    getFunction = function() return Category or HOTBAR_CATEGORY_QUICKSLOT_WHEEL end,
    setFunction = function(var) Category = var end,
    width = "half",
    },
    --Index
    {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_SLOT,
    items = {
      { name = "1 - N", value = 4 },
      { name = "2 - NW", value = 3 },
      { name = "3 - W", value = 2 },
      { name = "4 - SW", value = 1 },
      { name = "5 - S", value = 8 },
      { name = "6 - SE", value = 7 },
      { name = "7 - E", value = 6 },
      { name = "8 - NE", value = 5 },
    }
    getFunction = function() return EntryIndex or 4 end,
    setFunction = function(var) EntryIndex = var end,
    },
    --Icon Select
    {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_ICON,
    items = HH.Icon2Text(HH.IconList),
    getFunction = function() return Icon or HH.IconList[1] end,
    setFunction = function(var) Icon = var end,
    },
    --Icon Custom
    {
    type = LAM.ST_EDIT,
    label = HH.Lang.WHEEL_ICON_CUSTOM,
    tooltip = HH.Lang.WHEEL_ICON_CUSTOM_TOOLTIP,
    getFunction = function() return IconCustom or "" end,
    setFunction = function(text) IconCustom = text end,
    },
    --Name
    {
    type = LAM.ST_EDIT,
    name = HH.Lang.WHEEL_NAME,
    getFunction = function() return Name or "" end,
    setFunction = function(text) Name = text end,
    },
    --House Choice
    {
    type = LAM.ST_DROPDOWN,
    name = "House",
    items = HH.HouseData.ownedHouseItems,
    getFunction = function() return House or "" end,
    setFunction = function(var) House = var end,
    },
    --Jump to Interior or Exterior
    {
    type = LAM.ST_CHECKBOX,
    label = "Jump to Outside of House",
    getFunction = function() return UseExterior or false end,
    setFunction = function(var)
      UseExterior = var
    end,
    },
    --Apply
    {
    type = LAM.ST_BUTTON,
    label = HH.Lang.WHEEL_APPLY,
    buttonText = HH.Lang.WHEEL_APPLY,
    clickHandler  = function()
      if not Name or Name == "" then
        Status = HH.Lang.STATUS_NO_NAME
      else
        local Tex
        if IconCustom and IconCustom ~= "" then
          Tex = IconCustom
        else
          if Icon and Icon ~= "" then
            Tex = Icon
          else
            Tex = HH.IconList[1]
          end
        end
        HH.SV.Command[Category or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex or 4] = {
          ["name"] = Name or "",
          ["icon"] = Tex,
          ["house"] = House or "",
          ["exterior"] = UseExterior or false,
          ["houseName"] = HH.HouseData.ownedHouses[tostring(House)] or "",
        }
        Icon, IconCustom, Name, House, UseExterior = nil, nil, nil, nil, nil
        Status = HH.Lang.STATUS_ADDED
      end
    end,
    },
    --Status
    {
		type = LAM.ST_LABEL,
		label = function() return Status or " " end,
    tooltip  = HH.Lang.WHEEL_INFO
    },
    {
    type = LAM.ST_SECTION,
    label = HH.Lang.WHEEL_DESC,
    },
    {
    --Description
		type = LAM.ST_LABEL,
    label = function()
      local Positons = {"1 - N    ", "2 - NW", "3 - W   ", "4 - SW", "5 - S    ", "6 - SE  ", "7 - E    ", "8 - NE "}
      local Order = {4, 3, 2, 1, 8, 7, 6, 5}
      local Part = function(Index)
        local StringList = {SI_HOTBARCATEGORY10, SI_HOTBARCATEGORY11, SI_HOTBARCATEGORY12, SI_HOTBARCATEGORY13, SI_HOTBARCATEGORY14}
        local Tep = GetString(StringList[Index - 9]).."\r\n  "
        if HH.SV.Command[Index] then

          for k, v in ipairs(Order) do
            local Content = HH.SV.Command[Index][v]
            if Content then
              Tep = Tep..Positons[k].."  |t16:16:"..Content.icon.."|t  "..Content.name.." |c778899( "..Content.houseName.." )|r\r\n  "
            end
          end
        end

        return Tep.."\r\n"
      end
      return table.concat({
        Part(HOTBAR_CATEGORY_QUICKSLOT_WHEEL), 
        Part(HOTBAR_CATEGORY_ALLY_WHEEL), 
        Part(HOTBAR_CATEGORY_MEMENTO_WHEEL), 
        Part(HOTBAR_CATEGORY_TOOL_WHEEL), 
        Part(HOTBAR_CATEGORY_EMOTE_WHEEL)
      })
    end,
    },
    {
    type = LAM.ST_SECTION,
    label = HH.Lang.WHEEL_EDIT,
    },
    --Category
    {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_CATEGORY,
    items = {
      { name = GetString(SI_HOTBARCATEGORY10), value = HOTBAR_CATEGORY_QUICKSLOT_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY13), value = HOTBAR_CATEGORY_ALLY_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY12), value = HOTBAR_CATEGORY_MEMENTO_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY14), value = HOTBAR_CATEGORY_TOOL_WHEEL},
      { name = GetString(SI_HOTBARCATEGORY11), value = HOTBAR_CATEGORY_EMOTE_WHEEL},
    },
    getFunction = function() return Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL end,
    setFunction = function(var) Category2 = var end,
    },
    --Index
    {
    type = LAM.ST_DROPDOWN,
    label = HH.Lang.WHEEL_SLOT,
    items = {
      { name = "1 - N", value = 4 },
      { name = "2 - NW", value = 3 },
      { name = "3 - W", value = 2 },
      { name = "4 - SW", value = 1 },
      { name = "5 - S", value = 8 },
      { name = "6 - SE", value = 7 },
      { name = "7 - E", value = 6 },
      { name = "8 - NE", value = 5 },
    }
    getFunction = function() return EntryIndex2 or 4 end,
    setFunction = function(var) EntryIndex2 = var end,
    },
    --Empty
    {
    type = LAM.ST_BUTTON,
    label = HH.Lang.WHEEL_EMPTY,
    buttonText = HH.Lang.WHEEL_EMPTY,
    clickHandler = function()
      HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {}
    end,
    },
    --Delete
    {
    type = LAM.ST_BUTTON,
    label = HH.Lang.WHEEL_DELETE,
    buttonText = HH.Lang.WHEEL_DELETE,
    clickHandler = function()
      HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex2 or 4] = nil
    end,
    },
  }
  local controls = panel:AddSettings(options)
end

-- Start Here
EVENT_MANAGER:RegisterForEvent(HH.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

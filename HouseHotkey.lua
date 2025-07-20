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
  ownedHouseNames = {},
  ownedHouseIds = {},
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
    Tep[i] = "|t32:32:"..Table[i].."|t"
  end
  return Tep
end

function HH.GetHouseDropdownChoices()
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects()
    local ownedHouseCounter = 0

    for _, entry in ipairs(collectibleData) do
        if (entry:IsHouse()) then
            local referenceId = entry:GetReferenceId()
            if (not entry:IsLocked()) then
              local houseEntry = {
                  icon = entry:GetIcon(),
                  id = referenceId,
                  location = entry:GetFormattedHouseLocation(),
                  name = entry:GetFormattedName(),
                  owned = not entry:IsLocked(),
                  primary = entry:IsPrimaryResidence(),
              }
              HH.HouseData.ownedHouses[tostring(referenceId)] = houseEntry.name
              table.insert(HH.HouseData.ownedHouseNames, houseEntry.name)
              table.insert(HH.HouseData.ownedHouseIds, houseEntry.id)
              ownedHouseCounter = ownedHouseCounter + 1
            end
        end
    end
    HH.HouseData.totalOwnedHouses = ownedHouseCounter
end

--Menu Part
local LAM = LibAddonMenu2
function HH.BuildMenu()
  --Panel Part
  local panelData = {
    type = "panel",
    name = HH.Name,
    displayName = HH.Name,
    author = HH.Author,
    version = HH.Version,
    registerForRefresh = true,
	}
	LAM:RegisterAddonPanel(HH.Name.."_Options", panelData)
  
  --Option Part
  local Category, EntryIndex, Icon, IconCustom, Name, House, Status
  local Category2, EntryIndex2
  local options = {
    {
    type = "checkbox",
    name = HH.Lang.CHARACTER_SETTING,
    getFunc = function() return HH.CV.CV end,
    setFunc = function(var)
      HH.CV.CV = var
      HH.SwitchSV()
    end,
    width = "full",
    },
    --Create QuickSlot
    {
    type = "header",
    name = HH.Lang.CREATE_QUICKSLOT,
    },
    --Category
    {
    type = "dropdown",
    name = HH.Lang.WHEEL_CATEGORY,
    choices = {
      GetString(SI_HOTBARCATEGORY10),
      GetString(SI_HOTBARCATEGORY13),
      GetString(SI_HOTBARCATEGORY12),
      GetString(SI_HOTBARCATEGORY14),
      GetString(SI_HOTBARCATEGORY11),
    },
    choicesValues = {
      HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
      HOTBAR_CATEGORY_ALLY_WHEEL,
      HOTBAR_CATEGORY_MEMENTO_WHEEL,
      HOTBAR_CATEGORY_TOOL_WHEEL,
      HOTBAR_CATEGORY_EMOTE_WHEEL,
    },
    getFunc = function() return Category or HOTBAR_CATEGORY_QUICKSLOT_WHEEL end,
    setFunc = function(var) Category = var end,
    width = "half",
    },
    --Index
    {
    type = "dropdown",
    name = HH.Lang.WHEEL_SLOT,
    choices = {"1 - N", "2 - NW", "3 - W", "4 - SW", "5 - S", "6 - SE", "7 - E", "8 - NE"},
    choicesValues = {4, 3, 2, 1, 8, 7, 6, 5},
    getFunc = function() return EntryIndex or 4 end,
    setFunc = function(var) EntryIndex = var end,
    width = "half",
    },
    --Icon Select
    {
    type = "dropdown",
    name = HH.Lang.WHEEL_ICON,
    choices = HH.Icon2Text(HH.IconList),
    choicesValues = HH.IconList,
    getFunc = function() return Icon or HH.IconList[1] end,
    setFunc = function(var) Icon = var end,
    scrollable = true,
    width = "half",
    },
    --Icon Custom
    {
    type = "editbox",
    name = HH.Lang.WHEEL_ICON_CUSTOM,
    tooltip = HH.Lang.WHEEL_ICON_CUSTOM_TOOLTIP,
    getFunc = function() return IconCustom or "" end,
    setFunc = function(text) IconCustom = text end,
    isMultiline = false,
    width = "half",
    },
    --Name
    {
    type = "editbox",
    name = HH.Lang.WHEEL_NAME,
    getFunc = function() return Name or "" end,
    setFunc = function(text) Name = text end,
    isMultiline = false,
    width = "full",
    },
    --House Choice
    {
    type = "dropdown",
    name = "House",
    choices = HH.HouseData.ownedHouseNames,
    choicesValues = HH.HouseData.ownedHouseIds,
    getFunc = function() return House or "" end,
    setFunc = function(var) House = var end,
    width = "full",
    },
    --Jump to Interior or Exterior
    {
    type = "checkbox",
    name = "Jump to Outside of House",
    getFunc = function() return UseExterior or false end,
    setFunc = function(var)
      UseExterior = var
    end,
    width = "half",
    },
    --Apply
    {
    type = "button",
    name = HH.Lang.WHEEL_APPLY,
    func = function()
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
    width = "half",
    },
    --Status
    {
		type = "description",
		title = function() return Status or " " end,
    text = HH.Lang.WHEEL_INFO
    },
    {
    type = "header",
    name = HH.Lang.WHEEL_DESC,
    },
    {
    --Description
		type = "description",
    text = function()
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
    type = "header",
    name = HH.Lang.WHEEL_EDIT,
    },
    --Category
    {
    type = "dropdown",
    name = HH.Lang.WHEEL_CATEGORY,
    choices = {
      GetString(SI_HOTBARCATEGORY10),
      GetString(SI_HOTBARCATEGORY13),
      GetString(SI_HOTBARCATEGORY12),
      GetString(SI_HOTBARCATEGORY14),
      GetString(SI_HOTBARCATEGORY11),
    },
    choicesValues = {
      HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
      HOTBAR_CATEGORY_ALLY_WHEEL,
      HOTBAR_CATEGORY_MEMENTO_WHEEL,
      HOTBAR_CATEGORY_TOOL_WHEEL,
      HOTBAR_CATEGORY_EMOTE_WHEEL,
    },
    getFunc = function() return Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL end,
    setFunc = function(var) Category2 = var end,
    width = "half",
    },
    --Index
    {
    type = "dropdown",
    name = HH.Lang.WHEEL_SLOT,
    choices = {"1 - N", "2 - NW", "3 - W", "4 - SW", "5 - S", "6 - SE", "7 - E", "8 - NE"},
    choicesValues = {4, 3, 2, 1, 8, 7, 6, 5},
    getFunc = function() return EntryIndex2 or 4 end,
    setFunc = function(var) EntryIndex2 = var end,
    width = "half",
    },
    --Empty
    {
    type = "button",
    name = HH.Lang.WHEEL_EMPTY,
    func = function()
      HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {}
    end,
    width = "half",
    },
    --Delete
    {
    type = "button",
    name = HH.Lang.WHEEL_DELETE,
    func = function()
      HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex2 or 4] = nil
    end,
    width = "half",
    },
  }
  LAM:RegisterOptionControls(HH.Name.."_Options", options)
end

-- Start Here
EVENT_MANAGER:RegisterForEvent(HH.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

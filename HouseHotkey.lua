HouseWheel = {}

local function CreateRadialMenu()
    local wheel = WINDOW_MANAGER:CreateControl("HouseWheelControl", GuiRoot, CT_CONTROL)
    wheel:SetAnchor(CENTER)
    wheel:SetDimensions(512, 512)

    HouseWheel.radialMenu = ZO_RadialMenu:New(wheel, "DefaultRadialMenu")
    HouseWheel.radialMenu:SetSpacing(10)
    HouseWheel.radialMenu:SetSelectedEntryAnimation("RadialMenuSelection")

    HouseWheel.radialMenu:SetOnSelectionChanged(function(entry)
        if entry and entry.callback then
            entry.callback()
        end
    end)
end

local function PopulateWheel()
    HouseWheel.radialMenu:Clear()

    local numHouses = GetTotalCollectibleHouses()
    local count = 0

    for i = 1, numHouses do
        local collectibleId = GetCollectibleHouseId(i)
        local name, _, icon, unlocked = GetCollectibleInfo(collectibleId)

        if unlocked then
            count = count + 1

            HouseWheel.radialMenu:AddEntry(
                name,
                icon,
                icon,
                icon,
                function()
                    d("Traveling to " .. name)
                    JumpToCollectibleHouse(collectibleId)
                end
            )
        end

        if count >= 8 then break end -- Limit to 8 for demo
    end

    HouseWheel.radialMenu:Show()
end

function HouseWheel_Toggle()
    if not HouseWheel.radialMenu then
        CreateRadialMenu()
    end

    if HouseWheel.radialMenu:IsShown() then
        HouseWheel.radialMenu:Hide()
    else
        PopulateWheel()
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "HouseWheel" then return end

    EVENT_MANAGER:UnregisterForEvent("HouseWheel", EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/housewheel"] = HouseWheel_Toggle
end

EVENT_MANAGER:RegisterForEvent("HouseWheel", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

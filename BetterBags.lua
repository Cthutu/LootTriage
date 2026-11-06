local _, ns = ...

local entries = {}
local hookedRows = {}
local items
local backpackKind

local function GetSlot(entry)
    local item = entry.item
    if not entry.active or item.blank or item.released or item.staticData or item.isVirtual then return end
    if item.kind ~= backpackKind then return end
    local data = item.GetItemData and item:GetItemData()
    if not data or data.isItemEmpty then return end
    local bag, slot = data.bagid, data.slotid
    if not bag or bag < 0 or bag > ns.LAST_ANY_BAG or not slot or slot < 1 then return end
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if not info or not data.itemInfo or info.itemID ~= data.itemInfo.itemID then return end
    return bag, slot, data
end

local function ClearEntry(entry)
    entry.active = false
    local overlay = ns.overlays[entry.visual]
    if overlay then
        overlay:Hide()
        overlay.entry = nil
    end
    ns.QueueRebuild()
end

local function Track(_, item, visual)
    if not item or not item.button or not visual then return end
    local entry = entries[item]
    if not entry then
        entry = { item = item, click = item.button, visual = visual }
        entries[item] = entry
        item.button:HookScript("OnShow", ns.QueueRebuild)
        item.button:HookScript("OnHide", ns.QueueRebuild)
    end
    entry.visual = visual
    entry.active = true
    ns.betterBagsButtons[item.button] = entry
    ns.betterBagsButtons[visual] = entry
    ns.tooltipButtons[item.button] = visual
    ns.tooltipButtons[visual] = visual
    ns.QueueRebuild()
end

local function TrackRow(_, row)
    local item = row.button
    local entry = entries[item]
    if not entry then return end
    entry.click = row.rowButton
    ns.betterBagsButtons[row.rowButton] = entry
    ns.tooltipButtons[row.rowButton] = entry.visual
    ns.tooltipButtons[row.frame] = entry.visual
    if not hookedRows[row.rowButton] then
        hookedRows[row.rowButton] = true
        row.rowButton:HookScript("OnShow", ns.QueueRebuild)
        row.rowButton:HookScript("OnHide", ns.QueueRebuild)
    end
    ns.QueueRebuild()
end

local function SelectHighlight(entry, bag, slot, data)
    entry.highlightKey = ns.SlotKey(bag, slot)
    entry.combined = (data.stackedCount or 0) > (data.itemInfo.currentItemCount or 0)
    if not entry.combined or not items or not items.GetAllSlotInfo then return end
    local all = items:GetAllSlotInfo()
    local info = all and all[entry.item.kind]
    if not info or not info.stacks or not info.visibleItemsBySlotKey then return end
    local stack = info.stacks:GetStackInfo(data.itemHash)
    if not stack or stack.rootItem ~= data.slotkey then return end
    local rank = ns.rankBySlot[entry.highlightKey]
    for slotkey in pairs(stack.slotkeys) do
        local child = info.itemsBySlotKey[slotkey]
        if child and not child.isItemEmpty and not info.visibleItemsBySlotKey[slotkey]
                and child.bagid and child.bagid >= 0 and child.bagid <= ns.LAST_ANY_BAG and child.slotid then
            local key = ns.SlotKey(child.bagid, child.slotid)
            local childRank = ns.rankBySlot[key]
            local candidate = ns.entryBySlot[key]
            if childRank and candidate and candidate.itemID == data.itemInfo.itemID and (not rank or childRank < rank) then
                entry.highlightKey, rank = key, childRank
            end
        end
    end
end

local function ForEachButton(callback)
    for _, entry in pairs(entries) do
        if entry.visual:IsVisible() and entry.click:IsVisible() then
            local bag, slot, data = GetSlot(entry)
            if bag then
                SelectHighlight(entry, bag, slot, data)
                callback(entry.visual, bag, slot, entry)
            end
        end
    end
end

local function BagsOpen()
    for _, entry in pairs(entries) do
        if entry.active and entry.click:IsVisible() and GetSlot(entry) then return true end
    end
    return false
end

function ns.InitBetterBags()
    local ace = LibStub and LibStub("AceAddon-3.0", true)
    local addon = ace and ace:GetAddon("BetterBags", true)
    if not addon then return end
    local events = addon:GetModule("Events", true)
    local frames = addon:GetModule("ItemFrame", true)
    local constants = addon:GetModule("Constants", true)
    if not events or not frames or not constants or not constants.BAG_KIND then return end
    backpackKind = constants.BAG_KIND.BACKPACK
    items = addon:GetModule("Items", true)
    ns.GetBetterBagsSlot = GetSlot
    ns.ForEachBetterBagsButton = ForEachButton
    ns.BetterBagsOpen = BagsOpen
    events:RegisterMessage("item/NewButton", Track)
    events:RegisterMessage("item/Updated", Track)
    events:RegisterMessage("item/UpdatedRow", TrackRow)
    events:RegisterMessage("item/Clearing", function(_, item)
        if entries[item] then ClearEntry(entries[item]) end
    end)
    events:RegisterMessage("bag/Rendered", ns.QueueRebuild)
    events:RegisterMessage("bags/OpenClose", ns.QueueRebuild)
    for _, item in pairs(frames.buttonsBySlotkey or {}) do
        if item._decoration then Track(nil, item, item._decoration) end
    end
end

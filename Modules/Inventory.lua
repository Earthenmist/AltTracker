local AltTracker = AltTracker
local Mod = AltTracker:NewModule("Inventory", "AceEvent-3.0")

function Mod:OnEnable()
  self:RegisterEvent("BAG_UPDATE_DELAYED", "RefreshBags")
  self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", "RefreshBank")
  self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED", "RefreshReagents")
  self:RegisterEvent("PLAYER_MONEY", "RefreshMoney")
  self:RegisterEvent("PLAYER_LOGIN", function() self:RefreshBags(); self:RefreshMoney() end)
end

function Mod:RefreshMoney()
  local store = AltTracker:GetCharStore()
  store.inventory = store.inventory or {}
  store.inventory.gold = GetMoney()
end

function Mod:RefreshBags()
  local store = AltTracker:GetCharStore()
  store.inventory = store.inventory or {}
  store.inventory.bags = {}
  for bag = 0, NUM_BAG_SLOTS do
    store.inventory.bags[bag] = {}
    local num = C_Container.GetContainerNumSlots(bag)
    for slot = 1, num do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info then
        store.inventory.bags[bag][slot] = { itemID = info.itemID, count = info.stackCount }
      end
    end
  end
end

function Mod:RefreshBank()
  -- Requires bank open to enumerate; store when available
  local store = AltTracker:GetCharStore()
  store.inventory = store.inventory or {}
  store.inventory.bank = store.inventory.bank or {}
  for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
    store.inventory.bank[bag] = {}
    local num = C_Container.GetContainerNumSlots(bag)
    for slot = 1, num do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info then
        store.inventory.bank[bag][slot] = { itemID = info.itemID, count = info.stackCount }
      end
    end
  end
end

function Mod:RefreshReagents()
  local store = AltTracker:GetCharStore()
  store.inventory = store.inventory or {}
  store.inventory.reagentbank = {}
  local bag = REAGENTBANK_CONTAINER
  local num = C_Container.GetContainerNumSlots(bag)
  for slot = 1, num do
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info then
      store.inventory.reagentbank[slot] = { itemID = info.itemID, count = info.stackCount }
    end
  end
end

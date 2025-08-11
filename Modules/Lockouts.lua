local AltTracker = AltTracker
local Mod = AltTracker:NewModule("Lockouts", "AceEvent-3.0")

function Mod:OnEnable()
  self:RegisterEvent("UPDATE_INSTANCE_INFO", "Refresh")
  self:RegisterEvent("PLAYER_LOGIN", function() RequestRaidInfo(); self:Refresh() end)
end

function Mod:Refresh()
  local store = AltTracker:GetCharStore()
  store.lockouts = store.lockouts or { raid = {}, mythicplus = {} }

  -- Raids/Dungeons lockouts
  RequestRaidInfo()
  local num = GetNumSavedInstances()
  for i = 1, num do
    local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid = GetSavedInstanceInfo(i)
    if isRaid then
      store.lockouts.raid[id] = { name = name, reset = reset, difficulty = difficulty, locked = locked, extended = extended, instance = instanceIDMostSig }
    end
  end

  -- Mythic+ weekly tracking (simple placeholder)
  if C_MythicPlus then
    local weekly = C_MythicPlus.GetOwnedKeystoneLevel and C_MythicPlus.GetOwnedKeystoneLevel() or 0
    local best = C_MythicPlus.GetWeeklyBestLevel and C_MythicPlus.GetWeeklyBestLevel() or 0
    store.lockouts.mythicplus.weeklyKeystone = weekly
    store.lockouts.mythicplus.weeklyBest = best
  end
end

local AltTracker = AltTracker
local Mod = AltTracker:NewModule("Reputation", "AceEvent-3.0")

function Mod:OnEnable()
  self:RegisterEvent("UPDATE_FACTION", "Refresh")
  self:RegisterEvent("PLAYER_LOGIN", "Refresh")
end

function Mod:Refresh()
  local store = AltTracker:GetCharStore()
  store.reputations = store.reputations or {}

  local factions = C_Reputation.GetNumFactions and C_Reputation.GetNumFactions() or 0
  -- Modern API: iterate factions via C_Reputation (The War Within updates may change this; adapt as needed)
  for i = 1, factions do
    local info = C_Reputation.GetFactionDataByIndex and C_Reputation.GetFactionDataByIndex(i) or nil
    if info and info.factionID then
      store.reputations[info.factionID] = {
        name = info.name,
        standing = info.standing or info.reaction,
        renown = info.renownLevel,
        isParagon = info.isParagon,
      }
    end
  end
end

local AltTracker = AltTracker
---@class AltTrackerModule : AceAddonModule
local Mod = AltTracker:NewModule("Template", "AceEvent-3.0")

function Mod:OnEnable()
  -- register events needed for this module
  self:RegisterEvent("PLAYER_LOGIN", "Refresh")
end

function Mod:OnDisable()
  -- cleanup if needed
end

function Mod:Refresh(reason)
  -- gather and store data
  local store = AltTracker:GetCharStore()
  store.template = store.template or {}
  store.template.lastUpdated = time()
end

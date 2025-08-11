local AddonName = ...

---@class AltTrackerNS
local AltTracker = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceEvent-3.0", "AceConsole-3.0")
_G[AddonName] = AltTracker

AltTracker.VERSION = "0.1.0"
AltTracker.ADDON_PREFIX = "ALTTRK"

-- Default DB schema (account + per-character)
AltTracker.defaults = {
  profile = {
    enabledModules = {
      CharacterOverview = true,
      Currency = true,
      Reputation = false,
      Quests = true,
      Inventory = false,
      Professions = true,
      Lockouts = true,
      Achievements = false,
    },
    minimap = { hide = false },
  },
  global = {
    -- cross-character persistent data
    chars = { -- [realmName][charName] = characterData
    },
    lastSchemaVersion = 1,
  },
  char = {
    -- character-scoped transient or settings
  }
}

-- Central registry for modules to declare what they capture
AltTracker.DataModel = {
  -- This is the structure we aim to persist per character
  -- Fill incrementally; modules write into their sections.
  schemaVersion = 1,
  character = {
    name = nil, classID = nil, raceID = nil, faction = nil, level = nil,
    ilvl = nil, covenant = nil, location = nil,
  },
  currencies = {},       -- [currencyID] = { quantity=..., weeklyMax=..., discovered=true }
  reputations = {},      -- [factionID] = { standing=..., paragon=..., renown=... }
  quests = {
    dailies = {}, weeklies = {}, campaign = {},
  },
  inventory = {
    bags = {}, bank = {}, reagentbank = {}, gold = 0,
  },
  professions = {},      -- [skillLineID] = { level=..., max=..., cooldowns = {...} }
  lockouts = {           -- raids/mythic+
    raid = {}, mythicplus = {},
  },
  achievements = {
    mounts = {}, pets = {}, toys = {},
  },
}

function AltTracker:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("AltTrackerDB", self.defaults, true)
  self:RegisterChatCommand("alttracker", "SlashHandler")
  self:RegisterChatCommand("at", "SlashHandler")
end

function AltTracker:OnEnable()
  -- LDB/Minimap
  if LibStub("LibDataBroker-1.1", true) then
    self:EnableMinimap()
  end

  -- Load modules based on profile setting
  for name, mod in self:IterateModules() do
    local enabled = self.db.profile.enabledModules[name] ~= false
    if enabled and not mod:IsEnabled() then mod:Enable() end
    if not enabled and mod:IsEnabled() then mod:Disable() end
  end

  -- Initial scan after login splash
  self:ScheduleTimer(function() self:FullRescan("LOGIN") end, 2)
end

function AltTracker:SlashHandler(input)
  input = (input or ""):lower()
  if input == "config" or input == "options" then
    self:OpenConfig()
  else
    self:ToggleMainFrame()
  end
end

-- Central rescan trigger that asks modules to refresh
function AltTracker:FullRescan(reason)
  for name, mod in self:IterateModules() do
    if mod.Refresh then pcall(mod.Refresh, mod, reason) end
  end
end

-- Write helper: ensure storage for this char
function AltTracker:GetCharStore()
  local realm = GetRealmName()
  local name = UnitName("player")
  self.db.global.chars[realm] = self.db.global.chars[realm] or {}
  self.db.global.chars[realm][name] = self.db.global.chars[realm][name] or {}
  return self.db.global.chars[realm][name]
end

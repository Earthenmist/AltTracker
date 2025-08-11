local AltTracker = AltTracker
local Mod = AltTracker:NewModule("CharacterOverview", "AceEvent-3.0")

local function GetFaction()
  local _, faction = UnitFactionGroup("player")
  return faction
end

function Mod:OnEnable()
  self:RegisterEvent("PLAYER_LOGIN", "Refresh")
  self:RegisterEvent("PLAYER_LEVEL_UP", "Refresh")
  self:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE", "Refresh")
  self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Refresh")
end

function Mod:Refresh()
  local store = AltTracker:GetCharStore()
  store.character = store.character or {}

  local name = UnitName("player")
  local _, classENG, classID = UnitClass("player")
  local _, raceENG, raceID = UnitRace("player")
  local level = UnitLevel("player")
  local ilvl = C_PaperDollInfo.GetInspectItemLevel("player") or select(2, GetAverageItemLevel())
  local loc = C_Map.GetBestMapForUnit("player")

  store.character.name = name
  store.character.classID = classID
  store.character.raceID = raceID
  store.character.faction = GetFaction()
  store.character.level = level
  store.character.ilvl = math.floor((ilvl or 0) + 0.5)
  store.character.location = loc
end

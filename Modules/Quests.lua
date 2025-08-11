local AltTracker = AltTracker
local Mod = AltTracker:NewModule("Quests", "AceEvent-3.0")

function Mod:OnEnable()
  self:RegisterEvent("QUEST_LOG_UPDATE", "Refresh")
  self:RegisterEvent("PLAYER_LOGIN", "Refresh")
end

local function IsWeekly(questID)
  local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
  return tagInfo and tagInfo.tagID == Enum.QuestTag.Weekly
end

local function IsDaily(questID)
  local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
  return tagInfo and tagInfo.tagID == Enum.QuestTag.Daily
end

function Mod:Refresh()
  local store = AltTracker:GetCharStore()
  store.quests = store.quests or { dailies = {}, weeklies = {}, campaign = {} }

  wipe(store.quests.dailies)
  wipe(store.quests.weeklies)

  local quests = C_QuestLog.GetAllCompletedQuestIDs and C_QuestLog.GetAllCompletedQuestIDs() or {}
  store.quests.completedCount = quests and #quests or 0

  local numEntries = C_QuestLog.GetNumQuestLogEntries()
  for i = 1, numEntries do
    local info = C_QuestLog.GetInfo(i)
    if info and info.questID and not info.isHeader then
      if IsWeekly(info.questID) then
        store.quests.weeklies[info.questID] = true
      elseif IsDaily(info.questID) then
        store.quests.dailies[info.questID] = true
      end
    end
  end
end

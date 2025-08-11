local AltTracker = AltTracker
local Mod = AltTracker:NewModule("Professions", "AceEvent-3.0")

function Mod:OnEnable()
  self:RegisterEvent("SKILL_LINES_CHANGED", "Refresh")
  self:RegisterEvent("TRADE_SKILL_LIST_UPDATE", "Refresh")
  self:RegisterEvent("PLAYER_LOGIN", "Refresh")
end

function Mod:Refresh()
  local store = AltTracker:GetCharStore()
  store.professions = {}

  if not C_ProfSpecs or not C_TradeSkillUI then return end

  local profs = C_TradeSkillUI.GetAllProfessionTradeSkillLines() or {}
  for _, skillLineID in ipairs(profs) do
    local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
    if info then
      store.professions[skillLineID] = {
        name = info.professionName,
        level = info.skillLevel,
        max = info.maxSkillLevel,
      }
    end
  end

  -- Cooldowns example
  if C_TradeSkillUI.GetAllRecipeIDs then
    for _, skillLineID in ipairs(profs) do
      local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs(skillLineID) or {}
      for _, recipeID in ipairs(recipeIDs) do
        local cd = C_TradeSkillUI.GetRecipeCooldown(recipeID)
        if cd and cd > 0 then
          store.professions[skillLineID].cooldowns = store.professions[skillLineID].cooldowns or {}
          store.professions[skillLineID].cooldowns[recipeID] = time() + cd
        end
      end
    end
  end
end

local AltTracker = AltTracker
local Mod = AltTracker:NewModule("Currency", "AceEvent-3.0")

function Mod:OnEnable()
  self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "Refresh")
  self:RegisterEvent("PLAYER_LOGIN", "Refresh")
end

function Mod:Refresh()
  local store = AltTracker:GetCharStore()
  store.currencies = store.currencies or {}

  local ids = C_CurrencyInfo.GetCurrencyIDs()
  if not ids then return end
  for _, currencyID in ipairs(ids) do
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if info and info.discovered then
      store.currencies[currencyID] = {
        quantity = info.quantity,
        maxQuantity = info.maxQuantity,
        weeklyMax = info.maxWeeklyQuantity,
        totalEarned = info.totalEarned,
        discovered = info.discovered,
        name = info.name,
      }
    end
  end
end

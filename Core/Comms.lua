local AltTracker = AltTracker

local prefix = AltTracker.ADDON_PREFIX
C_ChatInfo.RegisterAddonMessagePrefix(prefix)

function AltTracker:Broadcast(payloadTbl)
  local data = LibStub("AceSerializer-3.0", true) and LibStub("AceSerializer-3.0"):Serialize(payloadTbl) or C_Serialization.Serialize(payloadTbl)
  C_ChatInfo.SendAddonMessage(prefix, data, IsInGuild() and "GUILD" or "WHISPER", UnitName("player"))
end

function AltTracker:OnCommReceived(prefixIn, text, channel, sender)
  if prefixIn ~= prefix or sender == UnitName("player") then return end
  local ok, data
  if LibStub("AceSerializer-3.0", true) then
    ok, data = LibStub("AceSerializer-3.0"):Deserialize(text)
  else
    ok, data = pcall(C_Serialization.Deserialize, text)
  end
  if not ok then return end
  -- Route to modules if they register interest
  for name, mod in self:IterateModules() do
    if mod.OnAltTrackerMessage then self:SafeCall(mod.OnAltTrackerMessage, mod, data, sender, channel) end
  end
end

AltTracker:RegisterEvent("CHAT_MSG_ADDON", function(_, _, prefixIn, text, channel, sender)
  AltTracker:OnCommReceived(prefixIn, text, channel, sender)
end)

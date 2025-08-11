local AltTracker = AltTracker

function AltTracker:SafeCall(fn, ...)
  if type(fn) == "function" then
    local ok, err = pcall(fn, ...)
    if not ok and C_AddOns.IsAddOnLoaded("!BugGrabber") then
      -- Let BugGrabber capture, or print minimal info
      self:Print("Error:", err)
    end
  end
end

function AltTracker:TableAssign(dst, src)
  for k,v in pairs(src) do dst[k] = v end
  return dst
end

-- Throttle utility for spammy events
local lastByKey = {}
function AltTracker:Throttle(key, seconds)
  local t = GetTime()
  if (lastByKey[key] or 0) + seconds <= t then
    lastByKey[key] = t; return true
  end
  return false
end

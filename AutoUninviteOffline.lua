local frame = CreateFrame("Frame")
local addonEnabled = false
local checkInterval = 5 -- Seconds between checks
local lastCheck = GetTime()

-- Event registration
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")

-- OnUpdate handler
frame:SetScript("OnUpdate", function(self)
	if not addonEnabled then return end

	local now = GetTime()
	if (now - lastCheck) >= checkInterval then
		CheckOfflineMembers()
		lastCheck = now
	end
end)

function CheckOfflineMembers()
	local inParty = GetNumPartyMembers() > 0
	if not (inParty or IsPartyLeader() == 1) then return end

	for i = 1, GetNumPartyMembers() do
		local unit = "party" .. i
		if UnitExists(unit) then
			local name = UnitName(unit)
			local online = UnitIsConnected(unit)

			if not online then
				UninviteByName(name)
				print(name .. " uninvited (offline).")
			end
		end
	end
end

-- Slash command
SLASH_AUTOUNINVITE1 = "/auo"
SlashCmdList["AUTOUNINVITE"] = function()
	addonEnabled = not addonEnabled
	print("Auto Uninvite Offline: " .. (addonEnabled and "Enabled" or "Disabled"))
end

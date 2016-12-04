local L = LibStub("AceLocale-3.0"):GetLocale("IceHUD", false)
-- changed to inherit from the TargetInvuln bar since the only difference is the unit and the default placement
-- helps keep changes in one place and we don't have to duplicate the Invuln spell tables and they don't have to be globals
local PlayerInvuln = IceCore_CreateClass(TargetInvuln)

-- Constructor --
function PlayerInvuln.prototype:init()
	PlayerInvuln.super.prototype.init(self, "PlayerInvuln", "player")
end

-- 'Public' methods -----------------------------------------------------------

-- OVERRIDE
function PlayerInvuln.prototype:GetDefaultSettings()
	local settings = PlayerInvuln.super.prototype.GetDefaultSettings(self)

	settings["enabled"] = true
	settings["side"] = IceCore.Side.Left
	--settings["offset"] = 0
-- Custom
	--settings["myTagVersion"] = 3
	settings["offset"] = 3
	--settings["updatedReverseInverse"] = true

	return settings
end

-- 'Protected' methods --------------------------------------------------------

-- Load us up
IceHUD.PlayerInvuln = PlayerInvuln:new()
--
-- Inherits IceCastBar
--
local L = LibStub("AceLocale-3.0"):GetLocale("IceHUD", false)
local FocusCast = IceCore_CreateClass(IceCastBar)

-- Constructor --
function FocusCast.prototype:init()
	FocusCast.super.prototype.init(self, "FocusCast")

	self.unit = "focus"
end


-- 'Public' methods -----------------------------------------------------------

-- OVERRIDE
function FocusCast.prototype:GetDefaultSettings()
	local settings = FocusCast.super.prototype.GetDefaultSettings(self)

	settings["enabled"] = true
	settings["side"] = IceCore.Side.Right
	--settings["offset"] = -2
	settings["scale"] = 0.7
	settings["flashInstants"] = "Never"
	settings["flashFailures"] = "Never"
	settings["shouldAnimate"] = false
	settings["hideAnimationSettings"] = true
	settings["usesDogTagStrings"] = false
	--settings["barVerticalOffset"] = 35
-- Custom
	settings["offset"] = -1
	settings["displayAuraIcon"] = true
	settings["barVerticalOffset"] = 60
	settings["auraIconXOffset"] = 8
	settings["auraIconYOffset"] = -2

	return settings
end


-- OVERRIDE
function FocusCast.prototype:Enable(core)
	FocusCast.super.prototype.Enable(self, core)

	self:RegisterEvent("PLAYER_FOCUS_CHANGED", "FocusChanged")
end


function FocusCast.prototype:FocusChanged(event, unit)
	if not (UnitExists(self.unit)) then
		self:StopBar()
		return
	end

	local spell = UnitCastingInfo(self.unit)
	if (spell) then
		self:StartBar(IceCastBar.Actions.Cast)
		return
	end

	local channel = UnitChannelInfo(self.unit)
	if (channel) then
		self:StartBar(IceCastBar.Actions.Channel)
		return
	end

	self:StopBar()
end


function FocusCast.prototype:GetOptions()
	local opts = FocusCast.super.prototype.GetOptions(self)

	opts["barVisible"] = {
		type = 'toggle',
		name = L["Bar visible"],
		desc = L["Toggle bar visibility"],
		get = function()
			return self.moduleSettings.barVisible['bar']
		end,
		set = function(info, v)
			self.moduleSettings.barVisible['bar'] = v
			if v then
				self.barFrame:Show()
			else
				self.barFrame:Hide()
			end
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 28
	}

	opts["bgVisible"] = {
		type = 'toggle',
		name = L["Bar background visible"],
		desc = L["Toggle bar background visibility"],
		get = function()
			return self.moduleSettings.barVisible['bg']
		end,
		set = function(info, v)
			self.moduleSettings.barVisible['bg'] = v
			if v then
				self.frame.bg:Show()
			else
				self.frame.bg:Hide()
			end
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 29
	}

	return opts
end

-------------------------------------------------------------------------------


-- Load us up
IceHUD.FocusCast = FocusCast:new()

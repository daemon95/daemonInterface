local L = LibStub("AceLocale-3.0"):GetLocale("IceHUD", false)
IceTargetManaCast = IceCore_CreateClass(IceOmniBar)
IceTargetManaCast.prototype.registerEvents = true
IceTargetHealth.prototype.color = nil
IceTargetManaCast.prototype.determineColor = true


-- Constructor --
function IceTargetManaCast.prototype:init(moduleName, unit)
	if not moduleName or not unit then
		IceTargetManaCast.super.prototype.init(self, "TargetManaCast", "target")
	else
		IceTargetManaCast.super.prototype.init(self, moduleName, unit)
	end

	self:SetDefaultColor("TargetMana", 52, 64, 221)
	self:SetDefaultColor("TargetRage", 235, 44, 26)
	self:SetDefaultColor("TargetEnergy", 228, 242, 31)
	self:SetDefaultColor("TargetFocus", 242, 149, 98)
	self:SetDefaultColor("TargetRunicPower", 52, 64, 221)
end

-- Settings --
function IceTargetManaCast.prototype:GetDefaultSettings()
	local settings = IceTargetManaCast.super.prototype.GetDefaultSettings(self)

	settings["side"] = IceCore.Side.Right
	--settings["offset"] = 2
	settings["upperText"] = "[PercentMP:Round]"
	settings["lowerText"] = "[MP:PowerColor:Bracket]"
	settings["onlyShowMana"] = false
-- Custom
	--settings["myTagVersion"] = 3
	settings["offset"] = -1
	--settings["lockUpperTextAlpha"] = false
	--settings["lockLowerTextAlpha"] = false
	--settings["updatedReverseInverse"] = true

	return settings
end


function IceTargetManaCast.prototype:Enable(core)
	IceTargetManaCast.super.prototype.Enable(self, core)

	if self.registerEvents then
		if IceHUD.WowVer >= 40000 then
			self:RegisterEvent("UNIT_POWER", "UpdateEvent")
			self:RegisterEvent("UNIT_MAXPOWER", "UpdateEvent")
		else
			self:RegisterEvent("UNIT_MAXMANA", "UpdateEvent")
			self:RegisterEvent("UNIT_MAXRAGE", "UpdateEvent")
			self:RegisterEvent("UNIT_MAXENERGY", "UpdateEvent")
			self:RegisterEvent("UNIT_MAXFOCUS", "UpdateEvent")

			self:RegisterEvent("UNIT_MANA", "UpdateEvent")
			self:RegisterEvent("UNIT_RAGE", "UpdateEvent")
			self:RegisterEvent("UNIT_ENERGY", "UpdateEvent")
			self:RegisterEvent("UNIT_FOCUS", "UpdateEvent")

			-- DK rune stuff
			if IceHUD.WowVer >= 30000 then
				self:RegisterEvent("UNIT_RUNIC_POWER", "UpdateEvent")
				self:RegisterEvent("UNIT_MAXRUNIC_POWER", "UpdateEvent")
			end
		end
		self:RegisterEvent("UNIT_AURA", "UpdateEvent")
		self:RegisterEvent("UNIT_FLAGS", "UpdateEvent")
	end

	self:Update(self.unit)
end


function IceTargetManaCast.prototype:UpdateEvent(event, unit)
	self:Update(unit)
end

function IceTargetManaCast.prototype:Update(unit)
	IceTargetManaCast.super.prototype.Update(self)
	if (unit and (unit ~= self.unit)) then
		return
	end

	if ((not UnitExists(self.unit)) or (self.maxMana == 0)) then
		self:Show(false)
		return
	else
		self:Show(true)
	end

	local manaType = UnitPowerType(self.unit)

	if self.moduleSettings.onlyShowMana and manaType ~= 0 then
		self:Show(false)
		return
	end

	if self.determineColor then
		self.color = "TargetMana"

		if (self.moduleSettings.scaleManaColor) then
			self.color = "ScaledManaColor"
		end

		if (manaType == 1) then
			self.color = "TargetRage"
		elseif (manaType == 2) then
			self.color = "TargetFocus"
		elseif (manaType == 3) then
			self.color = "TargetEnergy"
		elseif (manaType == 6) then
			self.color = "TargetRunicPower"
		end

		if (self.tapped) then
			self.color = "Tapped"
		end
	end

	self:UpdateBar(self.manaPercentage, self.color)

	if not IceHUD.IceCore:ShouldUseDogTags() then
		self:SetBottomText1(math.floor(self.manaPercentage * 100))
		self:SetBottomText2(self:GetFormattedText(self.mana, self.maxMana), color)
	end
end


-- OVERRIDE
function IceTargetManaCast.prototype:GetOptions()
	local opts = IceTargetManaCast.super.prototype.GetOptions(self)

	opts["scaleManaColor"] = {
		type = "toggle",
		name = L["Color bar by mana %"],
		desc = L["Colors the mana bar from MaxManaColor to MinManaColor based on current mana %"],
		get = function()
			return self.moduleSettings.scaleManaColor
		end,
		set = function(info, value)
			self.moduleSettings.scaleManaColor = value
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 51
	}

	opts["onlyShowMana"] = {
		type = 'toggle',
		name = L["Only show if target uses mana"],
		desc = L["Will only show this bar if the target uses mana (as opposed to rage, energy, runic power, etc.)"],
		width = 'double',
		get = function()
			return self.moduleSettings.onlyShowMana
		end,
		set = function(info, v)
			self.moduleSettings.onlyShowMana = v
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end
	}

	return opts
end


-- Load us up
IceHUD.TargetMana = IceTargetManaCast:new()

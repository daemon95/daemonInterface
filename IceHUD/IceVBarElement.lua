local L = LibStub("AceLocale-3.0"):GetLocale("IceHUD", false)
local DogTag = nil

IceVBarElement = IceCore_CreateClass(IceElement)

IceVBarElement.BarTextureWidth = 128

--IceVBarElement.prototype.barFrame = nil

IceVBarElement.prototype.CurrLerpTime = 0
IceVBarElement.prototype.LastScale = 1
IceVBarElement.prototype.DesiredScale = 1
IceVBarElement.prototype.CurrScale = 1
IceVBarElement.prototype.LastScaleX = 1
IceVBarElement.prototype.DesiredScaleX = 1
IceVBarElement.prototype.CurrScaleX = 1

IceVBarElement.prototype.ExtraScale = 1 -- Extra bar scale
IceVBarElement.prototype.ExtraReverse = false -- Extra bar reverted
IceVBarElement.prototype.ExtraInverse = false -- Extra bar inverse

IceVBarElement.prototype.Markers = {}
IceVBarElement.prototype.IsBarElement = true -- cheating to avoid crawling up the 'super' references looking for this class. see IceCore.lua

local lastMarkerPosConfig = 50
local lastMarkerColorConfig = {
	r = 1,
	g = 0,
	b = 0,
	a = 1
}
local lastMarkerHeightConfig = 6
local lastEditMarkerConfig = 1

------------------------------------------------------------------------
--         Name:  IceVBarElement.prototype:init
--      Purpose:  Constructor
--  Description:  Constructs (sub)classes
--   Parameters:  name - Name of the (sub)class (string)
--                ... - The rest arguments to be passed (variable)
--      Returns:  None
------------------------------------------------------------------------

function IceVBarElement.prototype:init(name, ...)
	IceVBarElement.super.prototype.init(self, name, ...)
end



-- 'Public' methods -----------------------------------------------------------

-- OVERRIDE
function IceVBarElement.prototype:Enable()
	IceVBarElement.super.prototype.Enable(self)

	if IceHUD.IceCore:ShouldUseDogTags() then
		DogTag = LibStub("LibDogTag-3.0", true)
		if DogTag then
			LibStub("LibDogTag-Unit-3.0", true)
		end
	end

	if self.moduleSettings.myTagVersion < IceHUD.CurrTagVersion then
		local origDefaults = self:GetDefaultSettings()

		self.moduleSettings.upperText = origDefaults["upperText"]
		self.moduleSettings.lowerText = origDefaults["lowerText"]
		self.moduleSettings.myTagVersion = IceHUD.CurrTagVersion
	end

	-- fixup for the new 'invert' option
	if not self.moduleSettings.updatedReverseInverse then
		self.moduleSettings.updatedReverseInverse = true

		if self.moduleSettings.reverse then
			self.moduleSettings.reverse = false
			self.moduleSettings.inverse = true

--			self:SetBarFramePoints()
		end
	end

	self:RegisterFontStrings()
end

function IceVBarElement.prototype:Disable(core)
	IceVBarElement.super.prototype.Disable(self, core)

	self.frame:SetScript("OnUpdate", nil)
end


function IceVBarElement.prototype:RegisterFontStrings()
	if DogTag ~= nil and self.moduleSettings ~= nil and self.moduleSettings.usesDogTagStrings then
		if self.frame.bottomUpperText and self.moduleSettings.upperText then
			DogTag:AddFontString(self.frame.bottomUpperText, self.frame, self.moduleSettings.upperText, "Unit", { unit = self.unit })
		end
		if self.frame.bottomLowerText and self.moduleSettings.lowerText then
			DogTag:AddFontString(self.frame.bottomLowerText, self.frame, self.moduleSettings.lowerText, "Unit", {unit = self.unit })
		end
	end
end


-- OVERRIDE
------------------------------------------------------------------------
--         Name:  GetDefaultSettings
--      Purpose:  Set up class-specific parameters
--  Description:  Append default values of class-specific parameters
--                to the global configuration set
--   Parameters:  -
--      Returns:  Set of class-specific parameters
------------------------------------------------------------------------

function IceVBarElement.prototype:GetDefaultSettings()
	local settings = IceVBarElement.super.prototype.GetDefaultSettings(self)

	settings["side"] = IceCore.Side.Left
	settings["offset"] = 1
--	settings["scale"] = 1
	settings["inverse"] = false
	settings["reverse"] = false
	settings["barFontSize"] = 12
	settings["lockUpperTextAlpha"] = false
	settings["lockLowerTextAlpha"] = false
	settings["textVisible"] = { upper = true, lower = true }
	settings["upperText"] = ''
	settings["lowerText"] = ''
	settings["textVerticalOffset"] = -1
	settings["textHorizontalOffset"] = 0
	settings["shouldAnimate"] = true
	settings["desiredLerpTime"] = 0.2
	settings["barVisible"] = {
                bg = true,
                bar = true,
                xBg = true,
                xBar = true
        }
	settings["myTagVersion"] = 2
	settings["widthModifier"] = 0
	settings["usesDogTagStrings"] = true
	settings["barVerticalOffset"] = 0
	settings["barHorizontalOffset"] = 0
        -- ValV: Extra Bar parameters
	--settings["xBarEnabled"] = false
	settings["xBarScale"] = 0.65
	settings["xBarDirection"] = "NONE"
	settings["xBarVerticalOffset"] = 0
	settings["xBarHorizontalOffset"] = -48
        -- End Extra Bar parameters
	settings["forceJustifyText"] = "NONE"
	settings["shouldUseOverride"] = false
	settings["rotateBar"] = false
	settings["markers"] = {}

	return settings
end


-- OVERRIDE
function IceVBarElement.prototype:GetOptions()
	local opts = IceVBarElement.super.prototype.GetOptions(self)

	opts["headerLookAndFeel"] = {
		type = 'header',
		name = L["Look and Feel"],
		order = 29.9
	}
	opts["side"] =
	{
		type = 'select',
		name = L["Side"],
		desc = L["Side of the HUD where the bar appears"],
		get = function(info)
			if (self.moduleSettings.side == IceCore.Side.Right) then
				return 2
			else
				return 1
			end
		end,
		set = function(info, value)
			if (value == 2) then
				self.moduleSettings.side = IceCore.Side.Right
			else
				self.moduleSettings.side = IceCore.Side.Left
			end
			self:Redraw()
		end,
		values = { "Left", "Right" },
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 30
	}

	opts["offset"] =
	{
		type = 'range',
		name = L["Offset"],
		desc = L["Offset of the bar"],
		min = -10,
		max = 15,
		step = 1,
		get = function()
			return self.moduleSettings.offset
		end,
		set = function(info, value)
			self.moduleSettings.offset = value
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 30.01
	}

	opts["scale"] =
	{
		type = 'range',
		name = L["Scale"],
		desc = L["Scale of the bar"],
		min = 0.1,
		max = 2,
		step = 0.05,
		isPercent = true,
		get = function()
			return self.moduleSettings.scale
		end,
		set = function(info, value)
			self.moduleSettings.scale = value
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 30.02
	}

	opts["inverse"] =
	{
		type = 'toggle',
		name = L["Invert bar"],
		desc = L["Controls which direction the bar fills up. With this checked, the bar will fill opposite from normal (e.g. for health: 0% at the top, 100% at the bottom)."],
		get = function()
			return self.moduleSettings.inverse
		end,
		set = function(info, value)
			self.moduleSettings.inverse = value
--			self:SetBarFramePoints()
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 30.03
	}

	opts["reverse"] =
	{
		type = 'toggle',
		name = L["Reverse direction"],
		desc = L["Controls what it means for the bar to be filled. A normal bar will grow larger as the value grows from 0% to 100%. A reversed bar will shrink as the value grows from 0% to 100%."],
		get = function()
			return self.moduleSettings.reverse
		end,
		set = function(info, value)
			self.moduleSettings.reverse = value
--			self:SetBarFramePoints()
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 30.04
	}

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
	if not self.moduleSettings.hideAnimationSettings then
		opts["headerAnimation"] = {
			type = 'header',
			name = L["Animation Settings"],
			order = 110
		}
		opts["shouldAnimate"] =
		{
			type = 'toggle',
			name = L["Animate changes"],
			desc = L["Whether or not to animate the bar falloffs/gains"],
			get = function()
				return self.moduleSettings.shouldAnimate
			end,
			set = function(info, value)
				self.moduleSettings.shouldAnimate = value
				self:Redraw()
			end,
			disabled = function()
				return not self.moduleSettings.enabled
			end,
			order = 111
		}

		opts["desiredLerpTime"] =
		{
			type = 'range',
			name = L["Animation Duration"],
			desc = L["How long the animation should take to play"],
			min = 0,
			max = 2,
			step = 0.05,
			get = function()
				return self.moduleSettings.desiredLerpTime
			end,
			set = function(info, value)
				self.moduleSettings.desiredLerpTime = value
			end,
			disabled = function()
				return not self.moduleSettings.enabled or not self.moduleSettings.shouldAnimate
			end,
			order = 112
		}
	end

	opts["widthModifier"] =
	{
		type = 'range',
		name = L["Bar width modifier"],
		desc = L["Make this bar wider or thinner than others"],
		min = -80,
		max = 80,
		step = 1,
		get = function()
			return self.moduleSettings.widthModifier
		end,
		set = function(info, v)
			self.moduleSettings.widthModifier = v
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 30.05
	}

	opts["barVerticalOffset"] =
	{
		type='range',
		name = L["Bar vertical offset"],
		desc = L["Adjust the vertical placement of this bar"],
		min = -400,
		max = 600,
		step = 1,
		get = function()
			return self.moduleSettings.barVerticalOffset
		end,
		set = function(info, v)
			self.moduleSettings.barVerticalOffset = v
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 30.06
	}

	opts["barHorizontalAdjust"] =
	{
		type='range',
		name = L["Bar horizontal adjust"],
		desc = L["This is a per-pixel horizontal adjustment. You should probably use the 'offset' setting above as it is designed to snap bars together. This may be used in the case of a horizontal bar needing to be positioned outside the normal bar locations."],
		min = -400,
		max = 600,
		step = 1,
		get = function()
			return self.moduleSettings.barHorizontalOffset
		end,
		set = function(info, v)
			self.moduleSettings.barHorizontalOffset = v
			self:Redraw()
		end,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		order = 30.06
	}

	opts["shouldUseOverride"] =
	{
		type = 'toggle',
		name = L["Override global texture"],
		desc = L["This will override the global bar texture setting for this bar with the one specified below."],
		get = function()
			return self.moduleSettings.shouldUseOverride
		end,
		set = function(info, value)
			self.moduleSettings.shouldUseOverride = value
			IceHUD:NotifyOptionsChange()

			self:NotifyBarOverrideChanged()
			self:Redraw()
		end,
		disabled = function()
			return not self:IsEnabled()
		end,
		order = 30.07
	}

	opts["barTextureOverride"] =
	{
		type = 'select',
		name = L["Bar Texture Override"],
		desc = L["This will override the global bar texture setting for this bar."],
		get = function(info)
			return IceHUD:GetSelectValue(info, self.moduleSettings.barTextureOverride)
		end,
		set = function(info, value)
			self.moduleSettings.barTextureOverride = info.option.values[value]
			self:NotifyBarOverrideChanged()
			self:Redraw()
		end,
		disabled = function()
			return not self:IsEnabled() or not self.moduleSettings.shouldUseOverride
		end,
		values = IceHUD.validBarList,
		order = 30.08
	}

	opts["barRotate"] =
	{
		type = 'toggle',
		name = L["Rotate 90 degrees"],
		desc = L["This will rotate this module by 90 degrees to give a horizontal orientation.\n\nWARNING: This feature is brand new and a bit rough around the edges. You will need to greatly adjust the vertical and horizontal offset of this bar plus move the text around in order for it to look correct.\n\nAnd I mean greatly."],
		get = function(info)
			return self.moduleSettings.rotateBar
		end,
		set = function(info, v)
			self.moduleSettings.rotateBar = v
			if v then
				self:RotateHorizontal()
			else
				self:ResetRotation()
			end
		end,
		disabled = function()
			return not self:IsEnabled()
		end,
		order = 30.09
	}

	opts["textSettings"] =
	{
		type = 'group',
		name = "|c"..self.configColor..L["Text Settings"].."|r",
		desc = L["Settings related to texts"],
		order = 32,
		disabled = function()
			return not self.moduleSettings.enabled
		end,
		args = {
			fontsize = {
				type = 'range',
				name = L["Bar Font Size"],
				desc = L["Bar Font Size"],
				get = function()
					return self.moduleSettings.barFontSize
				end,
				set = function(info, v)
					self.moduleSettings.barFontSize = v
					self:Redraw()
				end,
				min = 8,
				max = 20,
				step = 1,
				order = 11
			},

			lockUpperFontAlpha = {
				type = "toggle",
				name = L["Lock Upper Text Alpha"],
				desc = L["Locks upper text alpha to 100%"],
				get = function()
					return self.moduleSettings.lockUpperTextAlpha
				end,
				set = function(info, v)
					self.moduleSettings.lockUpperTextAlpha = v
					self:Redraw()
				end,
				order = 13
			},

			lockLowerFontAlpha = {
				type = "toggle",
				name = L["Lock Lower Text Alpha"],
				desc = L["Locks lower text alpha to 100%"],
				get = function()
					return self.moduleSettings.lockLowerTextAlpha
				end,
				set = function(info, v)
					self.moduleSettings.lockLowerTextAlpha = v
					self:Redraw()
				end,
				order = 13.1
			},

			upperTextVisible = {
				type = 'toggle',
				name = L["Upper text visible"],
				desc = L["Toggle upper text visibility"],
				get = function()
					return self.moduleSettings.textVisible['upper']
				end,
				set = function(info, v)
					self.moduleSettings.textVisible['upper'] = v
					self:Redraw()
				end,
				order = 14
			},

			lowerTextVisible = {
				type = 'toggle',
				name = L["Lower text visible"],
				desc = L["Toggle lower text visibility"],
				get = function()
					return self.moduleSettings.textVisible['lower']
				end,
				set = function(info, v)
					self.moduleSettings.textVisible['lower'] = v
					self:Redraw()
				end,
				order = 15
			},

			upperTextString = {
				type = 'input',
				name = L["Upper Text"],
				desc = L["The upper text to display under this bar (accepts LibDogTag formatting)\n\nSee http://www.wowace.com/wiki/LibDogTag-2.0/ or type /dogtag for tag info.\n\nRemember to press ENTER after filling out this box or it will not save."],
				hidden = function()
					return DogTag == nil or not self.moduleSettings.usesDogTagStrings
				end,
				get = function()
					return self.moduleSettings.upperText
				end,
				set = function(info, v)
					if DogTag ~= nil and v ~= '' and v ~= nil then
						v = DogTag:CleanCode(v)
					end

					self.moduleSettings.upperText = v
					self:RegisterFontStrings()
					self:Redraw()
				end,
				multiline = true,
				usage = "<upper text to display>"
			},

			lowerTextString = {
				type = 'input',
				name = L["Lower Text"],
				desc = L["The lower text to display under this bar (accepts LibDogTag formatting)\n\nSee http://www.wowace.com/wiki/LibDogTag-2.0/ or type /dogtag for tag info.\n\nRemember to press ENTER after filling out this box or it will not save."],
				hidden = function()
					return DogTag == nil or not self.moduleSettings.usesDogTagStrings
				end,
				get = function()
					return self.moduleSettings.lowerText
				end,
				set = function(info, v)
					if DogTag ~= nil and v ~= '' and v ~= nil then
						v = DogTag:CleanCode(v)
					end

					self.moduleSettings.lowerText = v
					self:RegisterFontStrings()
					self:Redraw()
				end,
				multiline = true,
				usage = "<lower text to display>"
			},

			forceJustifyText = {
				type = 'select',
				name = L["Force Text Justification"],
				desc = L["This sets the alignment for the text on this bar"],
				get = function(info)
					return self.moduleSettings.forceJustifyText
				end,
				set = function(info, value)
					self.moduleSettings.forceJustifyText = value
					self:Redraw()
				end,
				values = { NONE = "None", LEFT = "Left", RIGHT = "Right" },
				disabled = function()
					return not self.moduleSettings.enabled
				end,
			},

			textVerticalOffset = {
				type = 'range',
				name = L["Text Vertical Offset"],
				desc = L["Offset of the text from the bar vertically (negative is farther below)"],
				min = -450,
				max = 350,
				step = 1,
				get = function()
					return self.moduleSettings.textVerticalOffset
				end,
				set = function(info, v)
					self.moduleSettings.textVerticalOffset = v
					self:Redraw()
				end,
				disabled = function()
					return not self.moduleSettings.enabled
				end
			},

			textHorizontalOffset = {
				type = 'range',
				name = L["Text Horizontal Offset"],
				desc = L["Offset of the text from the bar horizontally"],
				min = -350,
				max = 350,
				step = 1,
				get = function()
					return self.moduleSettings.textHorizontalOffset
				end,
				set = function(info, v)
					self.moduleSettings.textHorizontalOffset = v
					self:Redraw()
				end,
				disabled = function()
					return not self.moduleSettings.enabled
				end
			}
		}
	}
	if not self.moduleSettings.bHideMarkerSettings then
		opts["markerSettings"] =
		{
			type = 'group',
			name = "|c"..self.configColor..L["Marker Settings"].."|r",
			desc = L["Create or remove markers at various points along the bar here"],
			order = 32,
			disabled = function()
				return not self.moduleSettings.enabled
			end,
			args = {
				markerPos = {
					type = "range",
					min = 0,
					max = 100,
					step = 1,
					name = L["Position (percent)"],
					desc = L["This specifies at what point along the bar this marker should be displayed. Remember to press ENTER when you are done typing.\n\nExample: if you wanted a marker at 40 energy and you have 100 total energy, then this would be 40. If you want it at 40 energy and you have 120 total energy, then this would be 33."],
					get = function()
						return lastMarkerPosConfig
					end,
					set = function(info, v)
						lastMarkerPosConfig = math.floor(v)
					end,
					order = 20,
				},
				markerColor = {
					type = "color",
					name = L["Color"],
					desc = L["The color this marker should be."],
					width = "half",
					get = function()
						return lastMarkerColorConfig.r, lastMarkerColorConfig.g, lastMarkerColorConfig.b, lastMarkerColorConfig.a
					end,
					set = function(info, r, g, b, a)
						lastMarkerColorConfig = {r=r, g=g, b=b, a=a}
					end,
					order = 30,
				},
				markerHeight = {
					type = "range",
					min = 1,
					step = 1,
					max = self.settings.barHeight,
					name = L["Height"],
					desc = L["The height of the marker on the bar."],
					get = function()
						return lastMarkerHeightConfig
					end,
					set = function(info, v)
						lastMarkerHeightConfig = v
					end,
					order = 40,
				},
				createMarker = {
					type = "execute",
					name = L["Create marker"],
					desc = L["Creates a new marker with the chosen settings."],
					width = "full",
					func = function()
						self:AddNewMarker(lastMarkerPosConfig / 100, lastMarkerColorConfig, lastMarkerHeightConfig)
					end,
					order = 10,
				},
				listMarkers = {
					type = "select",
					name = L["Edit Marker"],
					desc = L["Choose a marker to edit. This will place the marker's settings in the fields above here."],
					values = function()
						local retval = {}
						if self.moduleSettings.markers then
							for i=1, #self.moduleSettings.markers do
								retval[i] = ((self.moduleSettings.markers[i].position + 0.5) * 100) .. "%"
							end
						end
						return retval
					end,
					get = function(info)
						return lastEditMarkerConfig
					end,
					set = function(info, v)
						lastEditMarkerConfig = v
						lastMarkerPosConfig = (self.moduleSettings.markers[v].position + 0.5) * 100
						local color = self.moduleSettings.markers[v].color
						lastMarkerColorConfig = {r=color.r, g=color.g, b=color.b, a=color.a}
						lastMarkerHeightConfig = self.moduleSettings.markers[v].height
					end,
					order = 50,
				},
				editMarker = {
					type = "execute",
					name = L["Update"],
					desc = L["This will update the marker selected in the 'edit marker' box with the values specified."],
					func = function()
						if self.moduleSettings.markers and lastEditMarkerConfig <= #self.moduleSettings.markers then
							self:EditMarker(lastEditMarkerConfig, lastMarkerPosConfig / 100, lastMarkerColorConfig, lastMarkerHeightConfig)
						end
					end,
					order = 60,
				},
				deleteMarker = {
					type = "execute",
					name = L["Remove"],
					desc = L["This will remove the marker selected in the 'edit marker' box. This action is irreversible."],
					func = function()
						if self.moduleSettings.markers and lastEditMarkerConfig <= #self.moduleSettings.markers then
							self:RemoveMarker(lastEditMarkerConfig)
						end
					end,
					order = 70,
				},
			}
		}
	end
	return opts
end

--[[  -- BlockCommentNo_6 --
function IceVBarElement.prototype:SetBarFramePoints()
	self.barFrame:ClearAllPoints()
	if (self.moduleSettings.inverse) then
		self.barFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT")
	else
		self.barFrame:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT")
	end
end
--]]  -- BlockCommentNo_6 --


-- OVERRIDE
function IceVBarElement.prototype:Redraw()
	IceVBarElement.super.prototype.Redraw(self)

	if (not self.moduleSettings.enabled) then
		return
	end

	self.alpha = self.settings.alphaooc
	self:CreateFrame()

	self.frame:SetAlpha(self.alpha)
end



function IceVBarElement.prototype:SetPosition(side, offset)
	IceVBarElement.prototype.side = side
	IceVBarElement.prototype.offset = offset
end


-- 'Protected' methods --------------------------------------------------------

-- OVERRIDE
function IceVBarElement.prototype:CreateFrame()
	-- don't call overridden method
	self.alpha = self.settings.alphaooc

	-- Create backgrounds
	self:CreateBackground()
	-- Create Extra background
	-- TODO: make it conditional
	self:CreateXBackground()
	-- Create bars
	self:CreateBar()
	-- TODO: make it conditional
	self:CreateXBar()
	-- Configure bars
	self:SetScale(self.CurrScale, true)
	self:SetXScale(self.ExtraScale, true)
	self:UpdateBar(1, "undef")

	self:CreateTexts()
	if #self.Markers == 0 then
		self:LoadMarkers()
	else
		for i=1, #self.Markers do
			self:UpdateMarker(i)
		end
	end

	self.frame:SetScale(self.moduleSettings.scale)
	-- Never register the OnUpdate for the mirror bar since it's handled internally
	-- in addition, do not register OnUpdate if predictedPower is set and this is the player mana or target mana bar
	if not string.find(self.elementName, "MirrorBar")
		and ((IceHUD.WowVer < 30000 or not GetCVarBool("predictedPower")) or (not string.find(self.elementName, "PlayerMana")))
		and not self.moduleSettings.isCustomBar and self:RegisterOnUpdate() then
		self.frame:SetScript("OnUpdate", function() self:MyOnUpdate() end)
	end

	if self.moduleSettings.rotateBar then
		self:RotateHorizontal()
	end
end

function IceVBarElement.prototype:RegisterOnUpdate()
	return true
end


-- Creates background for the bar
------------------------------------------------------------------------
--         Name:  CreateBackground
--      Purpose:  Create Main Background frame for the bar instance
--  Description:  This method will create static frame with texture
--                for the Main bar background
--   Parameters:  -
--      Returns:  None
------------------------------------------------------------------------

function IceVBarElement.prototype:CreateBackground()
	if not (self.frame) then
		self.frame = CreateFrame("Frame", "IceHUD_" .. self.elementName, self.parent)
	end

	self.frame:SetFrameStrata("BACKGROUND")
	self.frame:SetWidth(self.settings.barWidth + (self.moduleSettings.widthModifier or 0))
	self.frame:SetHeight(self.settings.barHeight)

	-- Create new empty background texture (if one does not exist)
	if not (self.frame.bg) then
		self.frame.bg = self.frame:CreateTexture(nil, "BACKGROUND")
	end

	-- Configure the texture
	self.frame.bg:SetTexture(IceElement.TexturePath .. self:GetMyBarTexture() .. "BG")
	self.frame.bg:SetBlendMode(self.settings.barBgBlendMode)

	self.frame.bg:ClearAllPoints()
--	self.frame.bg:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT")
--	self.frame.bg:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT")
	self.frame.bg:SetAllPoints(self.frame)
	self.frame.bg:SetHeight(self.settings.barHeight)

	if (self.moduleSettings.side == IceCore.Side.Left) then
		self.frame.bg:SetTexCoord(1, 0, 0, 1)
	else
		self.frame.bg:SetTexCoord(0, 1, 0, 1)
	end

	self.frame.bg:SetVertexColor(self:GetColor("undef", self.settings.alphabg))

	local ownPoint = "LEFT"
	if (self.moduleSettings.side == ownPoint) then
		ownPoint = "RIGHT"
	end

	-- ofxx = (bar width) + (extra space in between the bars)
	local offx = (self.settings.barProportion * self.settings.barWidth * self.moduleSettings.offset)
		+ (self.moduleSettings.offset * self.settings.barSpace)
	if (self.moduleSettings.side == IceCore.Side.Left) then
		offx = -offx --* -1
	end
	offx = offx + (self.moduleSettings.barHorizontalOffset or 0)

	self.frame:ClearAllPoints()
	self.frame:SetPoint("BOTTOM" .. ownPoint, self.parent, "BOTTOM" .. self.moduleSettings.side, offx, self.moduleSettings.barVerticalOffset)
end

--
-- X-BACKGROUND
--
function IceVBarElement.prototype:CreateXBackground()
	if not (self.xFrame) then
		self.xFrame = CreateFrame("Frame", nil, self.frame)
	end

	-- Positioning
	self.xFrame:SetFrameStrata("BACKGROUND")
	self.xFrame:SetWidth(self.settings.barWidth * self.moduleSettings.xBarScale + (self.moduleSettings.widthModifier or 0) * self.moduleSettings.xBarScale)
	self.xFrame:SetHeight(self.settings.barHeight * self.moduleSettings.xBarScale)

	-- Create new empty background texture (if one does not exist)
	if not (self.xFrame.bg) then
		self.xFrame.bg = self.frame:CreateTexture(nil, "BACKGROUND")
	end

	-- Configure the texture
	self.xFrame.bg:SetTexture(IceElement.TexturePath .. self:GetMyBarTexture() .. "BG")
	self.xFrame.bg:SetBlendMode(self.settings.barBgBlendMode)
	-- Set up positioning
	self.xFrame.bg:ClearAllPoints()
	-- Anchor background texture to the frame edges automatically adjusts size
	self.xFrame.bg:SetAllPoints(self.xFrame)
	self.xFrame.bg:SetHeight(self.settings.barHeight * self.moduleSettings.xBarScale)
	-- Orient the texture
	local xPos = 1
	if (self.moduleSettings.side == IceCore.Side.Left) then
		if (self.moduleSettings.xBarDirection == IceCore.Side.Right) then
			-- Set only if direction explicitly opposite the side
			self.xFrame.bg:SetTexCoord(0, 1, 0, 1)
		else
			self.xFrame.bg:SetTexCoord(1, 0, 0, 1)
		end
		xPos = -xPos
	else
		if (self.moduleSettings.xBarDirection == IceCore.Side.Left) then
			-- Set only if direction explicitly opposite the side
			self.xFrame.bg:SetTexCoord(1, 0, 0, 1)
		else
			self.xFrame.bg:SetTexCoord(0, 1, 0, 1)
		end
	end

	self.xFrame.bg:SetVertexColor(self:GetColor("undef", self.settings.alphabg))

	-- Anchor this frame to the Main background frame
	self.xFrame:ClearAllPoints()
	self.xFrame:SetPoint("CENTER", self.frame, "CENTER", self.moduleSettings.xBarHorizontalOffset * xPos, self.moduleSettings.xBarVerticalOffset)
end


------------------------------------------------------------------------
--         Name:  CreateBar
--      Purpose:  Create actual bar
--  Description:  {+DESCRIPTION+}
--   Parameters:  -
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function IceVBarElement.prototype:CreateBar()
	if not (self.barFrame) then
		self.barFrame = CreateFrame("Frame", nil, self.frame)
	end

	-- Set up geometry of the bar
	self.barFrame:SetFrameStrata("LOW")
	self.barFrame:ClearAllPoints()
	-- Anchor normal and inverted
	if (self.moduleSettings.inverse) then
		self.barFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT")
	else
		self.barFrame:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT")
	end
	self.barFrame:SetWidth(self.settings.barWidth + (self.moduleSettings.widthModifier or 0))
	self.barFrame:SetHeight(self.settings.barHeight)

	-- Create new empty bar texture (if one does not exist)
	if not (self.barFrame.bar) then
		self.barFrame.bar = self.barFrame:CreateTexture(nil, "LOW")
	end

	-- Configure the bar texture
	self.barFrame.bar:SetTexture(IceElement.TexturePath .. self:GetMyBarTexture())
	self.barFrame.bar:SetBlendMode(self.settings.barBlendMode)
	self.barFrame.bar:SetAllPoints(self.barFrame)
end

--
-- X-BAR
--
function IceVBarElement.prototype:CreateXBar()
	-- Create the bar if one does not exist
	if not (self.xBarFrame) then
		self.xBarFrame = CreateFrame("Frame", nil, self.xFrame)
	end

	-- Set up geometry of the bar
	self.xBarFrame:SetFrameStrata("LOW")
	self.xBarFrame:ClearAllPoints()
	-- Anchor normal and inverted
	if (self.moduleSettings.inverse) then
		self.xBarFrame:SetPoint("TOPLEFT", self.xFrame, "TOPLEFT")
	else
		self.xBarFrame:SetPoint("BOTTOMLEFT", self.xFrame, "BOTTOMLEFT")
	end
	self.xBarFrame:SetWidth(self.settings.barWidth * self.moduleSettings.xBarScale + (self.moduleSettings.widthModifier or 0) * self.moduleSettings.xBarScale)
	self.xBarFrame:SetHeight(self.settings.barHeight * self.moduleSettings.xBarScale)

	-- Create new empty bar texture (if one does not exist)
        if not (self.xBarFrame.bar) then
		self.xBarFrame.bar = self.xBarFrame:CreateTexture(nil, "LOW")
	end

	-- Configure the bar texture
	self.xBarFrame.bar:SetTexture(IceElement.TexturePath .. self:GetMyBarTexture())
	self.xBarFrame.bar:SetBlendMode(self.settings.barBlendMode)
	self.xBarFrame.bar:SetAllPoints(self.xBarFrame)
end


function IceVBarElement.prototype:GetMyBarTexture()
	if self.moduleSettings.shouldUseOverride and self.moduleSettings.barTextureOverride then
		return self.moduleSettings.barTextureOverride
	else
		return self.settings.barTexture
	end
end


function IceVBarElement.prototype:CreateTexts()
	self.frame.bottomUpperText = self:FontFactory(self.moduleSettings.barFontSize, nil, self.frame.bottomUpperText)
	self.frame.bottomLowerText = self:FontFactory(self.moduleSettings.barFontSize, nil, self.frame.bottomLowerText)

-- Parnic - commented these out so that they conform to whatever width the string is set to
--	self.frame.bottomUpperText:SetWidth(80)
--	self.frame.bottomLowerText:SetWidth(120)

	self.frame.bottomUpperText:SetHeight(14)
	self.frame.bottomLowerText:SetHeight(14)

	local ownPoint = self.moduleSettings.side
	if (self.moduleSettings.offset > 1) then
		ownPoint = self:Flip(ownPoint)
	end

	local justify = "RIGHT"
	if ((self.moduleSettings.side == "LEFT" and self.moduleSettings.offset <= 1) or
		(self.moduleSettings.side == "RIGHT" and self.moduleSettings.offset > 1))
	then
		justify = "LEFT"
	end

	if self.moduleSettings.forceJustifyText and self.moduleSettings.forceJustifyText ~= "NONE" then
		ownPoint = self.moduleSettings.forceJustifyText
		justify = self.moduleSettings.forceJustifyText
	end

	self.frame.bottomUpperText:SetJustifyH(justify)
	self.frame.bottomLowerText:SetJustifyH(justify)


	local parentPoint = self:Flip(self.moduleSettings.side)


	local offx = 0
	-- Adjust offset for bars where text is aligned to the outer side
	if (self.moduleSettings.offset <= 1) then
		offx = self.settings.barProportion * self.settings.barWidth - offx
	end


	if (self.moduleSettings.side == IceCore.Side.Left) then
		offx = offx * -1
	end

	self.frame.bottomUpperText:ClearAllPoints()
	self.frame.bottomLowerText:ClearAllPoints()

	if self.moduleSettings.textHorizontalOffset ~= nil then
		offx = offx + self.moduleSettings.textHorizontalOffset
	end

	local offy = 0
	if self.moduleSettings.textVerticalOffset ~= nil then
		offy = self.moduleSettings.textVerticalOffset
	end

	self.frame.bottomUpperText:SetPoint("TOP"..ownPoint , self.frame, "BOTTOM"..parentPoint, offx, offy)
	self.frame.bottomLowerText:SetPoint("TOP"..ownPoint , self.frame, "BOTTOM"..parentPoint, offx, offy - 14)

	if (self.moduleSettings.textVisible["upper"]) then
		self.frame.bottomUpperText:Show()
	else
		self.frame.bottomUpperText:Hide()
	end

	if (self.moduleSettings.textVisible["lower"]) then
		self.frame.bottomLowerText:Show()
	else
		self.frame.bottomLowerText:Hide()
	end
end


function IceVBarElement.prototype:Flip(side)
	if (side == IceCore.Side.Left) then
		return IceCore.Side.Right
	else
		return IceCore.Side.Left
	end
end


------------------------------------------------------------------------
--         Name:  SetScale
--      Purpose:  Scale bar frames
--  Description:  This method will scale the size of the frames while
--                their textures' size will remain the same. Both Main
--                and Extra bar frames will be updated on event for
--                the Main
--   Parameters:  inScale - {+DESCRIPTION+} ({+TYPE+})
--                force - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  None
------------------------------------------------------------------------

function IceVBarElement.prototype:SetScale(inScale, force)
	local oldScale = self.CurrScale
	local min_y, max_y

	-- TODO: Find out what is the 'Lerping'
	-- Use Clamp() method to restrict value boundaries [0..1]
	self.CurrScale = IceHUD:Clamp(self:LerpScale(inScale), 0, 1)

	-- If scale changed or one need to be changed anyways
	if force or oldScale ~= self.CurrScale then
		local scale = self.CurrScale
		-- Reverse bar grow
		if (self.moduleSettings.reverse) then
			scale = 1 - scale
		end
		-- Inverted upwards bottom
		if (self.moduleSettings.inverse) then
			min_y = 0
			max_y = scale
		else
			min_y = 1 - scale
			max_y = 1
		end
		if (self.moduleSettings.side == IceCore.Side.Left) then
			self.barFrame.bar:SetTexCoord(1, 0, min_y, max_y) -- Main
		else
			self.barFrame.bar:SetTexCoord(0, 1, min_y, max_y) -- Main
		end

		self.barFrame:SetHeight(self.settings.barHeight * scale) -- Main

--[[  -- BlockCommentNo_7 --
		if scale == 0 then
			self.barFrame.bar:Hide()
		else
			self.barFrame.bar:Show()
		end
--]]  -- BlockCommentNo_7 --
	end
end

function IceVBarElement.prototype:SetXScale(inScale, force)
	local oldScale = self.ExtraScale
	local xMin_y, xMax_y

	-- Find out what is the 'Lerping'
	-- Use Clamp() method to restrict value boundaries [0..1]
	self.ExtraScale = IceHUD:Clamp(self:LerpScale(inScale), 0, 1)

	-- If scale changed or one need to be changed anyways
	if force or oldScale ~= self.ExtraScale then
		local xScale = self.ExtraScale
		-- TODO: confirm absence in 'moduleSettings'
		-- Reverse bar grow
		if (self.ExtraReverse) then
			xScale = 1 - xScale
		end
		-- Inverted upwards bottom
		if (self.ExtraInverse) then
			xMin_y = 0
			xMax_y = xScale
		else
			xMin_y = 1 - xScale
			xMax_y = 1
		end
		if (self.moduleSettings.side == IceCore.Side.Left) then
			if (self.moduleSettings.xBarDirection == IceCore.Side.Right) then
				-- Set only if direction explicitly opposite the side
				self.xBarFrame.bar:SetTexCoord(0, 1, xMin_y, xMax_y) -- Extra
			else
				self.xBarFrame.bar:SetTexCoord(1, 0, xMin_y, xMax_y) -- Extra
			end
		else
--			self.xBarFrame.bar:SetTexCoord(0, 1, xMin_y, xMax_y) -- Extra
			if (self.moduleSettings.xBarDirection == IceCore.Side.Left) then
				-- Set only if direction explicitly opposite the side
				self.xBarFrame.bar:SetTexCoord(1, 0, xMin_y, xMax_y) -- Extra
			else
				self.xBarFrame.bar:SetTexCoord(0, 1, xMin_y, xMax_y) -- Extra
			end
		end

		self.xBarFrame:SetHeight(self.settings.barHeight * xScale * self.moduleSettings.xBarScale) -- Extra

--[[  -- BlockCommentNo_7 --
		if xScale == 0 then
			self.xBarFrame.bar:Hide()
		else
			self.xBarFrame.bar:Show()
		end
--]]  -- BlockCommentNo_7 --
	end
end


------------------------------------------------------------------------
--         Name:  LerpScale
--      Purpose:  Add jitter to the scale changes
--  Description:  {+DESCRIPTION+}
--   Parameters:  scale - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function IceVBarElement.prototype:LerpScale(scale)
	if not self.moduleSettings.shouldAnimate then
		return scale
	end

	if self.CurrLerpTime < self.moduleSettings.desiredLerpTime then
		self.CurrLerpTime = self.CurrLerpTime + (1 / GetFramerate());
	end

	if self.CurrLerpTime > self.moduleSettings.desiredLerpTime then
		self.CurrLerpTime = self.moduleSettings.desiredLerpTime
	end

	if self.CurrLerpTime < self.moduleSettings.desiredLerpTime then
		return self.LastScale + ((self.DesiredScale - self.LastScale) * (self.CurrLerpTime / self.moduleSettings.desiredLerpTime))
	else
		return scale
	end
end


------------------------------------------------------------------------
--         Name:  UpdateBar
--      Purpose:  Update bar state
--  Description:  This method will update drawing of the bars and cast
--                scale changes on them
--                TODO: migrate to UpdateBars() method
--   Parameters:  scale - {+DESCRIPTION+} ({+TYPE+})
--                color - {+DESCRIPTION+} ({+TYPE+})
--                alpha - {+DESCRIPTION+} ({+TYPE+})
--      Returns:  {+RETURNS+}
------------------------------------------------------------------------

function IceVBarElement.prototype:UpdateBar(scale, color, alpha)
	alpha = alpha or 1
	self.frame:SetAlpha(alpha)

	local r, g, b = self.settings.backgroundColor.r, self.settings.backgroundColor.g, self.settings.backgroundColor.b
	if (self.settings.backgroundToggle) then
		r, g, b = self:GetColor(color)
	end

	if (self.combat) then
		self.alpha = self.settings.alphaic
		self.backgroundAlpha = self.settings.alphaicbg
	elseif (self.target) then
		self.alpha = self.settings.alphaTarget
		self.backgroundAlpha = self.settings.alphaTargetbg
	elseif (self:UseTargetAlpha(scale)) then
		self.alpha = self.settings.alphaNotFull
		self.backgroundAlpha = self.settings.alphaNotFullbg
	else
		self.alpha = self.settings.alphaooc
		self.backgroundAlpha = self.settings.alphaoocbg
	end

	-- post-process override for the bar alpha to be 1 (ignoring BG alpha for now)
	if self.moduleSettings.alwaysFullAlpha then
		self.alpha = 1
	end

	-- ValV: This fargment does the main trick
	-- Colour all the bars and backgrounds
	self.frame.bg:SetVertexColor(r, g, b, self.backgroundAlpha)
	self.xFrame.bg:SetVertexColor(r, g, b, self.backgroundAlpha)
	self.barFrame.bar:SetVertexColor(self:GetColor(color))
	self.xBarFrame.bar:SetVertexColor(self:GetColor(color))
	-- Colour all the markers
	if self.moduleSettings.markers then
		for i=1, #self.Markers do
			local color = self.moduleSettings.markers[i].color
			self.Markers[i].bar:SetVertexColor(color.r, color.g, color.b, self.alpha)
		end
	end

	if self.DesiredScale ~= scale then
		self.DesiredScale = scale
		self.CurrLerpTime = 0
		self.LastScale = self.CurrScale
	end

	self:SetScale(self.DesiredScale)
	self:SetXScale(self.ExtraScale)

	if not self.moduleSettings.barVisible['bg'] then
		self.frame.bg:Hide()
	else
		self.frame.bg:Show()
	end

	if not self.moduleSettings.barVisible['xBg'] then
		self.xFrame.bg:Hide()
	else
		self.xFrame.bg:Show()
	end

	if not self.moduleSettings.barVisible['bar'] then
		self.barFrame:Hide()
	else
		self.barFrame:Show()
	end

	if not self.moduleSettings.barVisible['xBar'] then
		self.xBarFrame.bar:Hide()
	else
		self.xBarFrame.bar:Show()
	end

	if DogTag ~= nil and self.moduleSettings.usesDogTagStrings then
		DogTag:UpdateAllForFrame(self.frame)
	end

	self:SetTextAlpha()
end


function IceVBarElement.prototype:UpdateBars(scale, color, alpha, scaleX, colorX, alphaX)
	alpha, alphaX = alpha or 1, alphaX or 1
	self.frame:SetAlpha(alpha)
	self.xFrame:SetAlpha(alphaX)

	local r, g, b = self.settings.backgroundColor.r, self.settings.backgroundColor.g, self.settings.backgroundColor.b
	if (self.settings.backgroundToggle) then
		r, g, b = self:GetColor(color)
	end

	if (self.combat) then
		self.alpha = self.settings.alphaic
		self.backgroundAlpha = self.settings.alphaicbg
	elseif (self.target) then
		self.alpha = self.settings.alphaTarget
		self.backgroundAlpha = self.settings.alphaTargetbg
	elseif (self:UseTargetAlpha(scale)) then
		self.alpha = self.settings.alphaNotFull
		self.backgroundAlpha = self.settings.alphaNotFullbg
	else
		self.alpha = self.settings.alphaooc
		self.backgroundAlpha = self.settings.alphaoocbg
	end

	-- post-process override for the bar alpha to be 1 (ignoring BG alpha for now)
	if self.moduleSettings.alwaysFullAlpha then
		self.alpha = 1
	end

	-- ValV: This fargment does the main trick
	-- Colour all the bars and backgrounds
	self.frame.bg:SetVertexColor(r, g, b, self.backgroundAlpha)
	self.xFrame.bg:SetVertexColor(r, g, b, self.backgroundAlpha)
	self.barFrame.bar:SetVertexColor(self:GetColor(color))
	self.xBarFrame.bar:SetVertexColor(self:GetColor(color))
	-- Colour all the markers
	if self.moduleSettings.markers then
		for i=1, #self.Markers do
			local color = self.moduleSettings.markers[i].color
			self.Markers[i].bar:SetVertexColor(color.r, color.g, color.b, self.alpha)
		end
	end

	if self.DesiredScale ~= scale then
		self.DesiredScale = scale
		self.CurrLerpTime = 0
		self.LastScale = self.CurrScale
	end

	self:SetScale(self.DesiredScale)
	self:SetXScale(self.ExtraScale)

	if not self.moduleSettings.barVisible['bg'] then
		self.frame.bg:Hide()
	else
		self.frame.bg:Show()
	end

	if not self.moduleSettings.barVisible['xBg'] then
		self.xFrame.bg:Hide()
	else
		self.xFrame.bg:Show()
	end

	if not self.moduleSettings.barVisible['bar'] then
		self.barFrame:Hide()
	else
		self.barFrame:Show()
	end

	if not self.moduleSettings.barVisible['xBar'] then
		self.xBarFrame.bar:Hide()
	else
		self.xBarFrame.bar:Show()
	end

	if DogTag ~= nil and self.moduleSettings.usesDogTagStrings then
		DogTag:UpdateAllForFrame(self.frame)
	end

	self:SetTextAlpha()
end


function IceVBarElement.prototype:UseTargetAlpha(scale)
	return (scale and (scale < 1))
end


-- Bottom line 1
function IceVBarElement.prototype:SetBottomText1(text, color)
	if not (self.moduleSettings.textVisible["upper"]) then
		return
	end

	if not (color) then
		color = "Text"
	end

	local alpha = self.alpha

	if (self.alpha > 0) then
		-- boost text alpha a bit to make it easier to see
		alpha = self.alpha + 0.1

		if (alpha > 1) then
			alpha = 1
		end
	end

	if (self.moduleSettings.lockUpperTextAlpha and (self.alpha > 0)) then
		alpha = 1
	end

	self.frame.bottomUpperText:SetText(text)
	self.frame.bottomUpperText:SetWidth(0)
end


-- Bottom line 2
function IceVBarElement.prototype:SetBottomText2(text, color, alpha)
	if not (self.moduleSettings.textVisible["lower"]) then
		return
	end

	if not (color) then
		color = "Text"
	end
	if not (alpha) then
		-- boost text alpha a bit to make it easier to see
		if (self.alpha > 0) then
			alpha = self.alpha + 0.1

			if (alpha > 1) then
				alpha = 1
			end
		end
	end

	if (self.moduleSettings.lockLowerTextAlpha and (self.alpha > 0)) then
		alpha = 1
	end

	self.frame.bottomLowerText:SetTextColor(self:GetColor(color, alpha))
	self.frame.bottomLowerText:SetText(text)
	self.frame.bottomLowerText:SetWidth(0)
end


function IceVBarElement.prototype:SetTextAlpha()
	if self.frame.bottomUpperText then
		self.frame.bottomUpperText:SetAlpha(self.moduleSettings.lockUpperTextAlpha and 1 or math.min(self.alpha > 0 and self.alpha + 0.1 or 0, 1))
	end
	if self.frame.bottomLowerText then
		self.frame.bottomLowerText:SetAlpha(self.moduleSettings.lockLowerTextAlpha and 1 or math.min(self.alpha > 0 and self.alpha + 0.1 or 0, 1))
	end
end


function IceVBarElement.prototype:GetFormattedText(value1, value2)
	local color = "ffcccccc"

	local bLeft = ""
	local bRight = ""

	if (self.moduleSettings.brackets) then
		bLeft = "["
		bRight = "]"
	end


	if not (value2) then
		return string.format("|c%s%s|r%s|c%s%s|r", color, bLeft, value1, color, bRight)
	end
	return string.format("|c%s%s|r%s|c%s/|r%s|c%s%s|r", color, bLeft, value1, color, value2, color, bRight)
end

function IceVBarElement.prototype:SetScaledColor(colorVar, percent, maxColor, minColor)
	colorVar.r = ((maxColor.r - minColor.r) * percent) + minColor.r
	colorVar.g = ((maxColor.g - minColor.g) * percent) + minColor.g
	colorVar.b = ((maxColor.b - minColor.b) * percent) + minColor.b
end

-- To be overridden
function IceVBarElement.prototype:Update()
end

function IceVBarElement.prototype:MyOnUpdate()
	self:SetScale(self.DesiredScale)
end

function IceVBarElement.prototype:RotateHorizontal()
	self:RotateFrame(self.frame)
	self:RotateFrame(self.barFrame)
	for i=1, #self.Markers do
		self.Markers[i]:Hide()
	end
end

function IceVBarElement.prototype:ResetRotation()
	if self.frame.anim then
		self.frame.anim:Stop()
	end
	if self.barFrame.anim then
		self.barFrame.anim:Stop()
	end
	for i=1, #self.Markers do
		self.Markers[i]:Show()
	end
end

function IceVBarElement.prototype:RotateFrame(frame)
	if not frame then
		return
	end

	if frame.anim == nil then
		local grp = frame:CreateAnimationGroup()
		local rot = grp:CreateAnimation("Rotation")
		rot:SetStartDelay(0)
		rot:SetEndDelay(5)
		rot:SetOrder(1)
		rot:SetDuration(0.001)
		rot:SetDegrees(-90)
		grp.rot = rot
		frame.anim = grp
	end

	local anchorPoint
	if self.moduleSettings.inverse then
		anchorPoint = "TOPLEFT"
	else
		anchorPoint = "BOTTOMLEFT"
	end

	frame.anim.rot:SetOrigin(anchorPoint, 0, 0)
	frame.anim.rot:SetScript("OnUpdate", function(anim) if anim:GetProgress() >= 1 then anim:Pause() anim:SetScript("OnUpdate", nil) end end)
	frame.anim:Play()
end

function IceVBarElement.prototype:NotifyBarOverrideChanged()
	for i=1, #self.Markers do
		self.Markers[i].bar:SetTexture(IceElement.TexturePath .. self:GetMyBarTexture())
	end
end

function IceVBarElement.prototype:AddNewMarker(inPosition, inColor, inHeight)
	if not self.moduleSettings.markers then
		self.moduleSettings.markers = {}
	end

	local idx = #self.moduleSettings.markers + 1
	self.moduleSettings.markers[idx] = {
		position = inPosition - 0.5, -- acceptable range is -0.5 to +0.5
		color = {r=inColor.r, g=inColor.g, b=inColor.b, a=1},
		height = inHeight,
	}
	self:CreateMarker(idx)
end

function IceVBarElement.prototype:EditMarker(idx, inPosition, inColor, inHeight)
	assert(idx > 0 and #self.Markers >= idx and self.Markers[idx] and self.Markers[idx].bar and #self.moduleSettings.markers >= idx,
		"Bad marker passed to EditMarker. idx="..idx..", #Markers="..#self.Markers..", #settings.markers="..#self.moduleSettings.markers)
	self.moduleSettings.markers[idx] = {
		position = inPosition - 0.5, -- acceptable range is -0.5 to +0.5
		color = {r=inColor.r, g=inColor.g, b=inColor.b, a=1},
		height = inHeight,
	}
	self:CreateMarker(idx)
end

function IceVBarElement.prototype:RemoveMarker(idx)
	assert(idx > 0 and #self.Markers >= idx and self.Markers[idx] and self.Markers[idx].bar and #self.moduleSettings.markers >= idx,
		"Bad marker passed to RemoveMarker. idx="..idx..", #Markers="..#self.Markers..", #settings.markers="..#self.moduleSettings.markers)
	self.Markers[idx]:Hide()
	table.remove(self.Markers, idx)
	table.remove(self.moduleSettings.markers, idx)
end

function IceVBarElement.prototype:CreateMarker(idx)
	if self.Markers[idx] ~= nil then
		self.Markers[idx]:Hide()
		self.Markers[idx].bar = nil
		self.Markers[idx] = nil
	end

	self.Markers[idx] = CreateFrame("Frame", nil, self.barFrame)
	local marker = self.Markers[idx]

	marker:SetFrameStrata("LOW")
	marker:ClearAllPoints()

	marker.bar = marker:CreateTexture(nil, "LOW")
	marker.bar:SetTexture(IceElement.TexturePath .. self:GetMyBarTexture())
	marker.bar:SetAllPoints(marker)
	local color = self.moduleSettings.markers[idx].color
	marker.bar:SetVertexColor(color.r, color.g, color.b, color.a)

	self:UpdateMarker(idx)
	self:PositionMarker(idx, self.moduleSettings.markers[idx].position)
end

function IceVBarElement.prototype:UpdateMarker(idx)
	assert(idx > 0 and #self.Markers >= idx and self.Markers[idx] and self.Markers[idx].bar and #self.moduleSettings.markers >= idx,
		"Bad marker passed to UpdateMarker. idx="..idx..", #Markers="..#self.Markers..", #settings.markers="..#self.moduleSettings.markers)
	self.Markers[idx]:SetWidth(self.settings.barWidth + (self.moduleSettings.widthModifier or 0))
	self.Markers[idx]:SetHeight(self.moduleSettings.markers[idx].height)
end

function IceVBarElement.prototype:PositionMarker(idx, pos)
	assert(idx > 0 and #self.Markers >= idx and self.Markers[idx] and self.Markers[idx].bar and #self.moduleSettings.markers >= idx,
		"Bad marker passed to PositionMarker. idx="..idx..", #Markers="..#self.Markers..", #settings.markers="..#self.moduleSettings.markers)
	if self.moduleSettings.inverse then
		pos = pos * -1
	end
	local coordPos = 0.5 + pos
	local adjustedBarHeight = self.settings.barHeight - (self.moduleSettings.markers[idx].height)
	local heightScale = (self.moduleSettings.markers[idx].height / self.settings.barHeight) / 2

	local min_y = 1-coordPos-heightScale
	local max_y = 1-coordPos+heightScale

	if self.moduleSettings.side == IceCore.Side.Left then
		self.Markers[idx].bar:SetTexCoord(1, 0, min_y, max_y)
	else
		self.Markers[idx].bar:SetTexCoord(0, 1, min_y, max_y)
	end

	self.Markers[idx].bar:Show()
	self.Markers[idx]:SetPoint("CENTER", self.frame, "CENTER", 0, (self.settings.barHeight * pos))
end

function IceVBarElement.prototype:LoadMarkers()
	self.Markers = {}

	if not self.moduleSettings.markers then
		return
	end

	for i=1, #self.moduleSettings.markers do
		self:CreateMarker(i)
	end
end

-- Lokale Kopie für mehr speed
local VUHDO_DEBUFF_TYPE_NONE = 0;
local VUHDO_DEBUFF_TYPE_POISON = 1;
local VUHDO_DEBUFF_TYPE_DISEASE = 2;
local VUHDO_DEBUFF_TYPE_MAGIC = 3;
local VUHDO_DEBUFF_TYPE_CURSE = 4;
local VUHDO_DEBUFF_TYPE_CUSTOM = 6;
local VUHDO_DEBUFF_TYPE_MISSING_BUFF = 7;


local VUHDO_CUSTOM_DEBUFF_LIST = { };
local VUHDO_UNIT_CUSTOM_DEBUFFS = { };
local VUHDO_LAST_UNIT_DEBUFFS = { };
local VUHDO_CHOSEN_DEBUFF_INFO = { };
local VUHDO_DEBUFF_ABILITIES = { };
local VUHDO_UNIT_DEBUFF_SCHOOLS = { };
local VUHDO_PLAYER_ABILITIES = { };



local VUHDO_IGNORE_DEBUFFS_BY_CLASS = { };
local VUHDO_IGNORE_DEBUFFS_NO_HARM = { };
local VUHDO_IGNORE_DEBUFFS_MOVEMENT = { };
local VUHDO_IGNORE_DEBUFFS_DURATION = { };



--
local VUHDO_DEBUFF_TYPES = {
  ["Magic"] = VUHDO_DEBUFF_TYPE_MAGIC,
  ["Disease"] = VUHDO_DEBUFF_TYPE_DISEASE,
  ["Poison"] = VUHDO_DEBUFF_TYPE_POISON,
  ["Curse"] = VUHDO_DEBUFF_TYPE_CURSE
};




VUHDO_DEBUFF_BLACKLIST = {
	[GetSpellInfo(69127)] = true, -- Chill of the Throne (st„ndiger debuff)
	[GetSpellInfo(57724)] = true, -- Sated
	[GetSpellInfo(71328)] = true  -- Dungeon Cooldown
}



local VUHDO_CUSTOM_BUFF_BLACKLIST = {
	[GetSpellInfo(67847)] = true -- Expose Weakness ist ein Boss-Debuff und gleichzeitig ein Jäger-Buff
}



local VUHDO_INIT_UNIT_DEBUFF_SCHOOLS = {
	[VUHDO_DEBUFF_TYPE_POISON] = { },
	[VUHDO_DEBUFF_TYPE_DISEASE] = { },
	[VUHDO_DEBUFF_TYPE_MAGIC] = { },
	[VUHDO_DEBUFF_TYPE_CURSE] = { },
};


local VUHDO_NEXT_SOUND_TIME = 0;

-- BURST CACHE ---------------------------------------------------

local VUHDO_CONFIG;
local VUHDO_RAID;
local VUHDO_PANEL_SETUP;

local VUHDO_isInFight;
local VUHDO_shouldScanUnit;
local VUHDO_DEBUFF_BLACKLIST = { };

local UnitDebuff = UnitDebuff;
local UnitBuff = UnitBuff;
local table = table;
local GetTime = GetTime;
local PlaySoundFile = PlaySoundFile;

local sIsRemoveableOnly;
local sIsUseDebuffIcon;
local sIsMiBuColorsInFight;
local sStdDebuffSound;

function VUHDO_debuffsInitBurst()
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];
	VUHDO_DEBUFF_BLACKLIST = VUHDO_GLOBAL["VUHDO_DEBUFF_BLACKLIST"];

	VUHDO_isInFight = VUHDO_GLOBAL["VUHDO_isInFight"];
	VUHDO_shouldScanUnit = VUHDO_GLOBAL["VUHDO_shouldScanUnit"];

	sIsRemoveableOnly = VUHDO_CONFIG["DETECT_DEBUFFS_REMOVABLE_ONLY"];
	sIsUseDebuffIcon = VUHDO_PANEL_SETUP["BAR_COLORS"].useDebuffIcon;
	sIsMiBuColorsInFight = VUHDO_BUFF_SETTINGS["CONFIG"]["BAR_COLORS_IN_FIGHT"];
	sStdDebuffSound = VUHDO_CONFIG["SOUND_DEBUFF"];
	sAllDebuffSettings = VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"];
end

----------------------------------------------------



--
local tEmptyChosen = { nil, 0, 0, 0 };
function VUHDO_getChosenDebuffInfo(aUnit)
	return VUHDO_CHOSEN_DEBUFF_INFO[aUnit] or tEmptyChosen;
end



local tName, tIcon, tType;
local tChosen;
local tDebuff;
local tAbility;
local tDebuffType;



--
local tCopies = { };
local tIndex = 0;
local function VUHDO_copyColorRevolving()
	tIndex = tIndex + 1;
	if (tIndex > 40) then
		tIndex = 1;
	end
	if (tCopies[tIndex] == nil) then
		tCopies[tIndex] = { };
	else
		table.wipe(tCopies[tIndex]);
	end

	return tCopies[tIndex];
end



--
local function VUHDO_formColor(aColor)
	if (aColor.useText) then
		aColor["TR"] = aColor["TR"] or 0;
		aColor["TG"] = aColor["TG"] or 0;
		aColor["TB"] = aColor["TB"] or 0;
	end
	if (aColor["useBackground"]) then
		aColor["R"] = aColor["R"] or 0;
		aColor["G"] = aColor["G"] or 0;
		aColor["B"] = aColor["B"] or 0;
	end

	aColor["TO"] = aColor["TO"] or 1;
	aColor["O"] = aColor["O"] or 1;

	return aColor;
end



--
local function VUHDO_copyColorTo(aSource, aDest)
	aDest["R"], aDest["G"], aDest["B"] = aSource["R"], aSource["G"], aSource["B"];
	aDest["TR"], aDest["TG"], aDest["TB"] = aSource["TR"], aSource["TG"], aSource["TB"];
	aDest["O"], aDest["TO"] = aSource["O"], aSource["TO"];
	aDest["useText"], aDest["useBackground"], aDest["useOpacity"] = aSource["useText"], aSource["useBackground"], aSource["useOpacity"];
	return aDest;
end



--
local tSourceColor;
local tDebuffSettings;
local function _VUHDO_getDebuffColor(anInfo, aNewColor)

	if (anInfo["charmed"]) then
		return VUHDO_copyColorTo(VUHDO_PANEL_SETUP["BAR_COLORS"]["CHARMED"], aNewColor);
	elseif (anInfo["mibucateg"] == nil and (anInfo["debuff"] == VUHDO_DEBUFF_TYPE_NONE or anInfo["debuff"] == nil)) then
	  return aNewColor;
	end

	tDebuffSettings = sAllDebuffSettings[anInfo["debuffName"]];

	if (anInfo["debuff"] ~= nil and anInfo["debuff"] ~= VUHDO_DEBUFF_TYPE_CUSTOM and VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF" .. anInfo["debuff"]] ~= nil) then
		return VUHDO_copyColorTo(VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF" .. anInfo["debuff"]], aNewColor);
	elseif (anInfo["debuff"] == VUHDO_DEBUFF_TYPE_CUSTOM and tDebuffSettings ~= nil
		and tDebuffSettings["isColor"] and tDebuffSettings["color"] ~= nil) then
		tSourceColor = tDebuffSettings["color"];

		if (VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF6"]["useBackground"]) then
			aNewColor["useBackground"] = true;
			aNewColor["R"], aNewColor["G"], aNewColor["B"], aNewColor["O"]
				= tSourceColor["R"], tSourceColor["G"], tSourceColor["B"], tSourceColor["O"];
		end

		if (VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF6"]["useText"]) then
			aNewColor["useText"] = true;
			aNewColor["TR"], aNewColor["TG"], aNewColor["TB"], aNewColor["TO"]
				= tSourceColor["TR"], tSourceColor["TG"], tSourceColor["TB"], tSourceColor["TO"];
		end

		return aNewColor;
	end

  if (anInfo["mibucateg"] == nil or VUHDO_BUFF_SETTINGS[anInfo["mibucateg"]] == nil) then
    return aNewColor;
  end

	tSourceColor = VUHDO_BUFF_SETTINGS[anInfo["mibucateg"]]["missingColor"];
	if (VUHDO_BUFF_SETTINGS["CONFIG"]["BAR_COLORS_TEXT"]) then
		aNewColor["useText"] = true;
		aNewColor["TR"], aNewColor["TG"], aNewColor["TB"], aNewColor["TO"]
			= tSourceColor["TR"], tSourceColor["TG"], tSourceColor["TB"], tSourceColor["TO"];
	end

	if (VUHDO_BUFF_SETTINGS["CONFIG"]["BAR_COLORS_BACKGROUND"]) then
		aNewColor["useBackground"] = true;
		aNewColor["R"], aNewColor["G"], aNewColor["B"], aNewColor["O"]
			= tSourceColor["R"], tSourceColor["G"], tSourceColor["B"], tSourceColor["O"];
	end

	return aNewColor;
end



--
local tColor;
function VUHDO_getDebuffColor(anInfo)
	return VUHDO_formColor(_VUHDO_getDebuffColor(anInfo, VUHDO_copyColorRevolving()));
end



--
local tEmpty = { };
local function VUHDO_isDebuffRelevant(aDebuffName, aClass)
	return not VUHDO_IGNORE_DEBUFFS_NO_HARM[aDebuffName]
		and not VUHDO_IGNORE_DEBUFFS_MOVEMENT[aDebuffName]
		and not VUHDO_IGNORE_DEBUFFS_DURATION[aDebuffName]
		and not (VUHDO_IGNORE_DEBUFFS_BY_CLASS[aClass or ""] or tEmpty)[aDebuffName];
end



--
local tSetColor, tSetIcon;
local tIconsSet = { };
local tExpiry, tStacks;
local tDebuffInfo;
local tHasPlayed;
local tInfo;
local tDebuffName, tSoundDebuff;
local tSound;
local tIsStandardDebuff;
local tNow;
local tDuration;
local tChosenInfo;
local tCnt;
local tRemaining;
local tSchool, tAllSchools;
local tEmptyCustomDebuf = { };
function VUHDO_determineDebuff(aUnit, aClassName)
	tInfo = VUHDO_RAID[aUnit];
	if (tInfo == nil) then
		return VUHDO_DEBUFF_TYPE_NONE, "";
	elseif (VUHDO_CONFIG_SHOW_RAID) then
		return tInfo.debuff, tInfo.debuffName;
	end

	if (VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit] == nil) then
		VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit] = { };
	end

	if (VUHDO_CHOSEN_DEBUFF_INFO[aUnit] == nil) then
		VUHDO_CHOSEN_DEBUFF_INFO[aUnit] = { nil, 0, 0, 0 };
		tChosenInfo = VUHDO_CHOSEN_DEBUFF_INFO[aUnit];
	else
		tChosenInfo = VUHDO_CHOSEN_DEBUFF_INFO[aUnit];
		tChosenInfo[1], tChosenInfo[2], tChosenInfo[3], tChosenInfo[4] = nil, nil, 0, 0;
	end

	if (VUHDO_UNIT_DEBUFF_SCHOOLS[aUnit] == nil) then
		VUHDO_UNIT_DEBUFF_SCHOOLS[aUnit] = {
			[VUHDO_DEBUFF_TYPE_POISON] = { }, [VUHDO_DEBUFF_TYPE_DISEASE] = { }, [VUHDO_DEBUFF_TYPE_MAGIC] = { }, [VUHDO_DEBUFF_TYPE_CURSE] = { }
		};
		tAllSchools = VUHDO_UNIT_DEBUFF_SCHOOLS[aUnit];
	else
		tAllSchools = VUHDO_UNIT_DEBUFF_SCHOOLS[aUnit];
		tAllSchools[1][2], tAllSchools[2][2], tAllSchools[3][2], tAllSchools[4][2] = nil, nil, nil, nil;
	end

	if (tInfo.missbuff ~= nil	and (not VUHDO_isInFight() or sIsMiBuColorsInFight)) then
		tChosen = 7; --VUHDO_DEBUFF_TYPE_MISSING_BUFF
	else
		tChosen = 0; --VUHDO_DEBUFF_TYPE_NONE;
	end

	tDebuffName = "";
	table.wipe(tIconsSet);

	if (VUHDO_shouldScanUnit(aUnit)) then
		tSoundDebuff = nil;
		tIsStandardDebuff = false;
		tNow = GetTime();

		for tCnt = 1, 255 do
			tName, _, tIcon, tStacks, tType, tDuration, tExpiry = UnitDebuff(aUnit, tCnt, false);

			if (tIcon == nil) then
				break;
			end

			-- Custom Debuff?
			if ((VUHDO_CUSTOM_DEBUFF_LIST[tName] or tEmptyCustomDebuf)[1]) then
				tChosen = 6; --VUHDO_DEBUFF_TYPE_CUSTOM
				tDebuffName = tName;
				tSoundDebuff = tName;
			end

			if (tStacks == nil) then
				tStacks = 0;
			end

			if ((VUHDO_CUSTOM_DEBUFF_LIST[tName] or tEmptyCustomDebuf)[2]) then
				tIconsSet[tName] = { tIcon, tExpiry, tStacks, true };
				tSoundDebuff = tName;
			end

	  	tDebuff = VUHDO_DEBUFF_TYPES[tType];
			tAbility = VUHDO_PLAYER_ABILITIES[tDebuff];

      if ((not sIsRemoveableOnly or tAbility ~= nil) and tChosen ~= 6) then --VUHDO_DEBUFF_TYPE_CUSTOM
  			if (sIsUseDebuffIcon and not VUHDO_DEBUFF_BLACKLIST[tName]) then
  				tIconsSet[tName] = { tIcon, tExpiry, tStacks, false };
  				tIsStandardDebuff = true;
  			end

  			if (tDebuff ~= nil) then
  				tRemaining = floor(tExpiry - tNow);
  				tSchool = tAllSchools[tDebuff];
  				if ((tSchool[2] or 0) < tRemaining) then
  					tSchool[1], tSchool[2], tSchool[3], tSchool[4] = tIcon, tRemaining, tStacks, tDuration;
  				end

  				if (VUHDO_isDebuffRelevant(tName, aClassName)) then
  					if (tAbility ~= nil or tChosen == 0) then --VUHDO_DEBUFF_TYPE_NONE
  						tChosen = tDebuff;
  						tChosenInfo[1], tChosenInfo[2], tChosenInfo[3], tChosenInfo[4] = tIcon, tRemaining, tStacks, tDuration;
  					end
  				end
  			end
  		end
		end

		for tCnt = 1, 255 do
			tName, _, tIcon, tStacks, _, _, tExpiry = UnitBuff(aUnit, tCnt);

			if (tIcon == nil) then
				break;
			end

			if (VUHDO_CUSTOM_BUFF_BLACKLIST[tName] == nil) then
				tSetColor, tSetIcon = (VUHDO_CUSTOM_DEBUFF_LIST[tName] or tEmptyCustomDebuf)[1], (VUHDO_CUSTOM_DEBUFF_LIST[tName] or tEmptyCustomDebuf)[2];
			else
				tSetColor, tSetIcon = false, false;
			end

			if (tSetColor) then
				tChosen = 6; --VUHDO_DEBUFF_TYPE_CUSTOM
				tDebuffName = tName;
				tSoundDebuff = tName;
			end

			if (tStacks == nil) then
				tStacks = 0;
			end

			if (tSetIcon) then
				tIconsSet[tName] = { tIcon, tExpiry, tStacks, true };
				tSoundDebuff = tName;
			end
		end

		tHasPlayed = false;
		-- Gained new custom debuff?
		for tName, tDebuffInfo in pairs(tIconsSet) do
			if (VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName] == nil) then
				VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName] = { tDebuffInfo[2], tDebuffInfo[3] };
				VUHDO_addDebuffIcon(aUnit, tDebuffInfo[1], tName, tDebuffInfo[2], tDebuffInfo[3], tDebuffInfo[4]);

				if (not VUHDO_IS_CONFIG and VUHDO_MAY_DEBUFF_ANIM) then
					if (tSoundDebuff ~= nil and sAllDebuffSettings[tSoundDebuff] ~= nil) then
						tSound = sAllDebuffSettings[tSoundDebuff].SOUND;
						if (tSound ~= nil
							and strlen(tSound) > 0
							and tNow > VUHDO_NEXT_SOUND_TIME) then

							PlaySoundFile(tSound);
							tHasPlayed = true;
							VUHDO_NEXT_SOUND_TIME = tNow + 2;
						end
					elseif (VUHDO_CONFIG["CUSTOM_DEBUFF"].SOUND ~= nil
						and tNow > VUHDO_NEXT_SOUND_TIME
						and tSoundDebuff ~= nil) then

						PlaySoundFile(VUHDO_CONFIG["CUSTOM_DEBUFF"].SOUND);
						tHasPlayed = true;
						VUHDO_NEXT_SOUND_TIME = tNow + 2;
					end

				end
			-- update number of stacks?
			elseif(VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName][1] ~= tDebuffInfo[2]

				or VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName][2] ~= tDebuffInfo[3]) then
				table.wipe(VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName]);
				VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName] = { tDebuffInfo[2], tDebuffInfo[3] };
				VUHDO_updateDebuffIcon(aUnit, tDebuffInfo[1], tName, tDebuffInfo[2], tDebuffInfo[3]);
			end
		end

		-- Play Sound?
		if (sStdDebuffSound ~= nil
			and (tChosen ~= 0 or tIsStandardDebuff)
			and tChosen ~= 6 and tChosen ~= 7 -- VUHDO_DEBUFF_TYPE_CUSTOM || VUHDO_DEBUFF_TYPE_MISSING_BUFF
			and not tHasPlayed
			and VUHDO_LAST_UNIT_DEBUFFS[aUnit] ~= tChosen
			and tInfo.range
			and tNow > VUHDO_NEXT_SOUND_TIME) then

				PlaySoundFile(sStdDebuffSound);
				VUHDO_NEXT_SOUND_TIME = tNow + 2;
		end
	end -- shouldScanUnit

	-- Lost old custom debuff?
	for tName, _ in pairs(VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit]) do
		if (tIconsSet[tName] == nil) then
			table.wipe(VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName]);
			VUHDO_UNIT_CUSTOM_DEBUFFS[aUnit][tName] = nil;
			VUHDO_removeDebuffIcon(aUnit, tName);
		end
	end

	if (tInfo["range"]) then
		VUHDO_LAST_UNIT_DEBUFFS[aUnit] = tChosen;
	end

	return tChosen, tDebuffName;
end

local VUHDO_determineDebuff = VUHDO_determineDebuff;



--
local tUnit, tInfo;
function VUHDO_updateAllCustomDebuffs(anIsEnableAnim)
	table.wipe(VUHDO_UNIT_CUSTOM_DEBUFFS);
	VUHDO_MAY_DEBUFF_ANIM = false;
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		VUHDO_removeAllDebuffIcons(tUnit);
		tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(tUnit, tInfo["class"]);
	end
	VUHDO_MAY_DEBUFF_ANIM = anIsEnableAnim;
end



-- Remove debuffing abilities individually not known to the player
local tDebuffName;
local tClass;
function VUHDO_initDebuffs()
	table.wipe(VUHDO_DEBUFF_ABILITIES);
	VUHDO_DEBUFF_ABILITIES = VUHDO_deepCopyTable(VUHDO_INIT_DEBUFF_ABILITIES);
	_, tClass = UnitClass("player");

	for tDebuffType, tAbility in pairs(VUHDO_DEBUFF_ABILITIES[tClass] or { }) do
		if (not VUHDO_isSpellKnown(tAbility)) then
			VUHDO_DEBUFF_ABILITIES[tClass][tDebuffType] = nil;
		end
	end

  VUHDO_PLAYER_ABILITIES = VUHDO_DEBUFF_ABILITIES[tClass];

	table.wipe(VUHDO_CUSTOM_DEBUFF_LIST);
	if (VUHDO_CONFIG == nil) then
		VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	end
	for _, tDebuffName in pairs(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"]) do
		VUHDO_CUSTOM_DEBUFF_LIST[tDebuffName] = {
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tDebuffName].isColor,
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tDebuffName].isIcon
		};
	end


	if (VUHDO_CONFIG["DETECT_DEBUFFS_IGNORE_NO_HARM"]) then
		VUHDO_IGNORE_DEBUFFS_BY_CLASS = VUHDO_deepCopyTable(VUHDO_INIT_IGNORE_DEBUFFS_BY_CLASS);
		VUHDO_IGNORE_DEBUFFS_NO_HARM = VUHDO_deepCopyTable(VUHDO_INIT_IGNORE_DEBUFFS_NO_HARM);
	else
		VUHDO_IGNORE_DEBUFFS_BY_CLASS = {};
		VUHDO_IGNORE_DEBUFFS_NO_HARM = {};
	end

	if (VUHDO_CONFIG["DETECT_DEBUFFS_IGNORE_MOVEMENT"]) then
		VUHDO_IGNORE_DEBUFFS_MOVEMENT = VUHDO_deepCopyTable(VUHDO_INIT_IGNORE_DEBUFFS_MOVEMENT);
	else
		VUHDO_IGNORE_DEBUFFS_MOVEMENT = {};
	end

	if (VUHDO_CONFIG["DETECT_DEBUFFS_IGNORE_DURATION"]) then
		VUHDO_IGNORE_DEBUFFS_DURATION = VUHDO_deepCopyTable(VUHDO_INIT_IGNORE_DEBUFFS_DURATION);
	else
		VUHDO_IGNORE_DEBUFFS_DURATION = {};
	end

end



--
function VUHDO_getDebuffAbilities(aClass)
	return VUHDO_DEBUFF_ABILITIES[aClass];
end



--
local tEmptySchoolInfo = { };
function VUHDO_getUnitDebuffSchoolInfos(aUnit, aDebuffSchool)
	return (VUHDO_UNIT_DEBUFF_SCHOOLS[aUnit] or VUHDO_INIT_UNIT_DEBUFF_SCHOOLS)[aDebuffSchool] or tEmptySchoolInfo;
end


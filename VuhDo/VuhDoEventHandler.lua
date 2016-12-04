
VUHDO_INTERNAL_TOGGLES = { };
local VUHDO_INTERNAL_TOGGLES = VUHDO_INTERNAL_TOGGLES;

local VUHDO_DEBUFF_ANIMATION = 0;

local VUHDO_EVENT_COUNT = 0;
local VUHDO_LAST_TIME_NO_EVENT = GetTime();

-- BURST CACHE ---------------------------------------------------

local VUHDO_RAID;
local VUHDO_PANEL_SETUP;
VUHDO_RELOAD_UI_IS_LNF= false;

local VUHDO_parseAddonMessage;
local VUHDO_spellcastStop;
local VUHDO_spellcastFailed;
local VUHDO_spellcastSucceeded;
local VUHDO_spellcastSent;
local VUHDO_parseCombatLogEvent;
local VUHDO_updateAllOutRaidTargetButtons;
local VUHDO_updateAllRaidTargetIndices;


local VUHDO_updateHealth;
local VUHDO_updateManaBars;
local VUHDO_updateTargetBars;
local VUHDO_updateAllRaidBars;
local VUHDO_updateHealthBarsFor;
local VUHDO_updateAllHoTs;
local VUHDO_updateAllCyclicBouquets;
local VUHDO_updateAllDebuffIcons;
local VUHDO_updateAllClusters;
local VUHDO_clearObsoleteInc;
local VUHDO_updateBouquetsForEvent;

local GetTime = GetTime;
local CheckInteractDistance = CheckInteractDistance;
local UnitInRange = UnitInRange;
local IsSpellInRange = IsSpellInRange;
local UnitDetailedThreatSituation = UnitDetailedThreatSituation;
local UnitIsCharmed = UnitIsCharmed;
local UnitCanAttack = UnitCanAttack;
local UnitName = UnitName;
local UnitIsEnemy = UnitIsEnemy;
local GetSpellCooldown = GetSpellCooldown;
--local HasFullControl = HasFullControl;

local VuhDoGcdStatusBar;

local function VUHDO_eventHandlerInitBurst()
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];

	VUHDO_updateHealth = VUHDO_GLOBAL["VUHDO_updateHealth"];
	VUHDO_updateManaBars = VUHDO_GLOBAL["VUHDO_updateManaBars"];
	VUHDO_updateTargetBars = VUHDO_GLOBAL["VUHDO_updateTargetBars"];
	VUHDO_updateAllRaidBars = VUHDO_GLOBAL["VUHDO_updateAllRaidBars"];
	VUHDO_updateAllOutRaidTargetButtons = VUHDO_GLOBAL["VUHDO_updateAllOutRaidTargetButtons"];
	VUHDO_parseAddonMessage = VUHDO_GLOBAL["VUHDO_parseAddonMessage"];
	VUHDO_spellcastStop = VUHDO_GLOBAL["VUHDO_spellcastStop"];
	VUHDO_spellcastFailed = VUHDO_GLOBAL["VUHDO_spellcastFailed"];
	VUHDO_spellcastSucceeded = VUHDO_GLOBAL["VUHDO_spellcastSucceeded"];
	VUHDO_spellcastSent = VUHDO_GLOBAL["VUHDO_spellcastSent"];
	VUHDO_parseCombatLogEvent = VUHDO_GLOBAL["VUHDO_parseCombatLogEvent"];
	VUHDO_updateHealthBarsFor = VUHDO_GLOBAL["VUHDO_updateHealthBarsFor"];
	VUHDO_updateAllHoTs = VUHDO_GLOBAL["VUHDO_updateAllHoTs"];
	VUHDO_updateAllCyclicBouquets = VUHDO_GLOBAL["VUHDO_updateAllCyclicBouquets"];
	VUHDO_updateAllDebuffIcons = VUHDO_GLOBAL["VUHDO_updateAllDebuffIcons"];
	VUHDO_clearObsoleteInc = VUHDO_GLOBAL["VUHDO_clearObsoleteInc"];
	VUHDO_updateAllRaidTargetIndices = VUHDO_GLOBAL["VUHDO_updateAllRaidTargetIndices"];
	VUHDO_updateAllClusters = VUHDO_GLOBAL["VUHDO_updateAllClusters"];
	VUHDO_updateBouquetsForEvent = VUHDO_GLOBAL["VUHDO_updateBouquetsForEvent"];
	VuhDoGcdStatusBar = VUHDO_GLOBAL["VuhDoGcdStatusBar"];
end

----------------------------------------------------

local VUHDO_VARIABLES_LOADED = false;

local VUHDO_UPDATE_RANGE_TIMER = 1;
VUHDO_REFRESH_DRAG_DELAY = 0.05;
local VUHDO_REFRESH_DRAG_TIMER = VUHDO_REFRESH_DRAG_DELAY;
local VUHDO_CUSTOMIZE_TIMER = 0;
local VUHDO_IS_RELOAD_BUFFS = false;
local VUHDO_LOST_CONTROL = false;
local VUHDO_RELOAD_AFTER_BATTLE = false;
local VUHDO_RELOAD_UI_TIMER = 0;
local VUHDO_RELOAD_PANEL_TIMER = 0;
local VUHDO_RELOAD_PANEL_NUM = nil;
VUHDO_RELOAD_LAG_DELAY = 3.1;
local VUHDO_RELOAD_LAG_TIMER = VUHDO_RELOAD_LAG_DELAY * 2;
VUHDO_RELOAD_ZONES_DELAY = 3.5;
local VUHDO_RELOAD_ZONES_TIMER = 2.4;
local VUHDO_UPDATE_CLUSTERS_TIMER = 0;

local VUHDO_REFRESH_INSPECT_DELAY = 2.1;
local VUHDO_REFRESH_INSPECT_TIMER = VUHDO_REFRESH_INSPECT_DELAY;


local VUHDO_REFRESH_TOOLTIP_DELAY = 2.3;
local VUHDO_REFRESH_TOOLTIP_TIMER = VUHDO_REFRESH_TOOLTIP_DELAY;

local VUHDO_UPDATE_AGGRO_TIMER = 0;

local VUHDO_UPDATE_CHARMED_DELAY = 0.2;
local VUHDO_UPDATE_CHARMED_TIMER = VUHDO_UPDATE_CHARMED_DELAY;

local VUHDO_UPDATE_HOTS_DELAY = 0.25;
local VUHDO_UPDATE_HOTS_TIMER = VUHDO_UPDATE_HOTS_DELAY;

local VUHDO_REFRESH_TARGETS_DELAY = 0.51;
local VUHDO_REFRESH_TARGETS_TIMER = VUHDO_REFRESH_TARGETS_DELAY;
local VUHDO_GCD_UPDATE = false;


local tUnit, tInfo;


VUHDO_CONFIG = nil;
VUHDO_PANEL_SETUP = nil;
VUHDO_SPELL_ASSIGNMENTS = nil;
VUHDO_SPELLS_KEYBOARD = nil;
VUHDO_SPELL_CONFIG = nil;

VUHDO_IS_RELOADING = false;
VUHDO_FONTS = { };
VUHDO_STATUS_BARS = { };
VUHDO_SOUNDS = { };
VUHDO_BORDERS = { };
VUHDO_LAST_AUTO_ARRANG = nil;

local VUHDO_RELOAD_RAID_DELAY = 2.3; -- Seconds to wait before reloading raid after "PARTY_MEMBERS_CHANGED" etc.
local VUHDO_RELOAD_RAID_DELAY_QUICK = 0.3; -- Seconds to wait before reloading raid quickly after raid changed in fight etc.
local VUHDO_RELOAD_RAID_TIMER = 0;

VUHDO_MAINTANK_NAMES = { };
VUHDO_RESSING_NAMES = { };
local VUHDO_FIRST_RELOAD_UI = false;


--
function VUHDO_isVariablesLoaded()
	return VUHDO_VARIABLES_LOADED;
end



--
function VUHDO_setTooltipDelay(aSecs)
	VUHDO_REFRESH_TOOLTIP_DELAY = aSecs;
end



--
local VUHDO_INSTANCE = nil;
function VUHDO_OnLoad(anInstance)
	VUHDO_INSTANCE = anInstance;
	anInstance:RegisterEvent("VARIABLES_LOADED");
	anInstance:RegisterEvent("PLAYER_ENTERING_WORLD");
	anInstance:RegisterEvent("UNIT_HEALTH");
	anInstance:RegisterEvent("UNIT_MAXHEALTH");
	anInstance:RegisterEvent("UNIT_AURA");
	anInstance:RegisterEvent("UNIT_TARGET");

	anInstance:RegisterEvent("PLAYER_REGEN_ENABLED");
	anInstance:RegisterEvent("RAID_ROSTER_UPDATE");
	anInstance:RegisterEvent("PARTY_MEMBERS_CHANGED");
	anInstance:RegisterEvent("UNIT_PET");
	anInstance:RegisterEvent("UNIT_ENTERED_VEHICLE");
	anInstance:RegisterEvent("UNIT_EXITED_VEHICLE");
	anInstance:RegisterEvent("UNIT_EXITING_VEHICLE");
	anInstance:RegisterEvent("CHAT_MSG_ADDON");
	anInstance:RegisterEvent("RAID_TARGET_UPDATE");
	anInstance:RegisterEvent("LEARNED_SPELL_IN_TAB");
	anInstance:RegisterEvent("PLAYER_FLAGS_CHANGED");

	anInstance:RegisterEvent("UNIT_DISPLAYPOWER");

	anInstance:RegisterEvent("UNIT_MAXMANA");
	anInstance:RegisterEvent("UNIT_MAXENERGY");
	anInstance:RegisterEvent("UNIT_MAXRAGE");
	anInstance:RegisterEvent("UNIT_MAXRUNIC_POWER");

	anInstance:RegisterEvent("UNIT_MANA");
	anInstance:RegisterEvent("UNIT_ENERGY");
	anInstance:RegisterEvent("UNIT_RAGE");
	anInstance:RegisterEvent("UNIT_RUNIC_POWER");

	anInstance:RegisterEvent("UNIT_SPELLCAST_STOP");
	anInstance:RegisterEvent("UNIT_SPELLCAST_FAILED");
	anInstance:RegisterEvent("UNIT_SPELLCAST_SENT");
	anInstance:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	anInstance:RegisterEvent("PARTY_MEMBER_ENABLE");
	anInstance:RegisterEvent("PARTY_MEMBER_DISABLE");
	anInstance:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	anInstance:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	anInstance:RegisterEvent("UPDATE_BINDINGS");
	anInstance:RegisterEvent("PLAYER_TARGET_CHANGED");
	anInstance:RegisterEvent("PLAYER_FOCUS_CHANGED");

	anInstance:RegisterEvent("READY_CHECK");
	anInstance:RegisterEvent("READY_CHECK_CONFIRM");
	anInstance:RegisterEvent("READY_CHECK_FINISHED");
	anInstance:RegisterEvent("CVAR_UPDATE");
	anInstance:RegisterEvent("INSPECT_TALENT_READY");

	anInstance:RegisterEvent("MODIFIER_STATE_CHANGED");

	SLASH_VUHDO1 = "/vuhdo";
	SLASH_VUHDO2 = "/vd";
	SlashCmdList["VUHDO"] = function(aMessage)
		VUHDO_slashCmd(aMessage);
	end

	VUHDO_Msg("VuhDo |cffffe566['vu:du:]|r v".. VUHDO_VERSION .. ". by Iza(ak)@Gilneas, dedicated to Vuh (use /vd)");
end



--
function VUHDO_initBuffs()
	VUHDO_initBuffsFromSpellBook();
	VUHDO_reloadBuffPanel();
	VUHDO_resetHotBuffCache();
end



--
function VUHDO_initTooltipTimer()
	VUHDO_REFRESH_TOOLTIP_TIMER = VUHDO_REFRESH_TOOLTIP_DELAY;
end



--
-- 3 = Tanking, all others less 100%
-- 2 = Tanking, others > 100%
-- 1 = Not Tanking, more than 100%
-- 0 = Not Tanking, less than 100%
local tInfo, tIsAggroed;
local function VUHDO_updateThreat(aUnit)
	if (not VUHDO_VARIABLES_LOADED or VUHDO_RAID == nil) then
		return;
	end

	tInfo = VUHDO_RAID[aUnit];
	if (tInfo ~= nil) then
		tInfo.threat = UnitThreatSituation(aUnit);
		VUHDO_updateBouquetsForEvent(aUnit, VUHDO_UPDATE_THREAT_LEVEL);

		tIsAggroed = VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO] and (tInfo["threat"] or 0) >= 2;

		if (tIsAggroed ~= tInfo.aggro) then
			tInfo.aggro = tIsAggroed;
			VUHDO_updateHealthBarsFor(aUnit, VUHDO_UPDATE_AGGRO);
		end
	end
end



--
function VUHDO_initAllBurstCaches()
	VUHDO_toolboxInitBurst();
  VUHDO_guiToolboxInitBurst();
	VUHDO_vuhdoInitBurst();
	VUHDO_spellEventHandlerInitBurst();
	VUHDO_macroFactoryInitBurst();
	VUHDO_keySetupInitBurst();
	VUHDO_combatLogInitBurst();
	VUHDO_eventHandlerInitBurst();
	VUHDO_customHealthInitBurst();
	VUHDO_customManaInitBurst();
	VUHDO_customTargetInitBurst();
	VUHDO_customClustersInitBurst();
	VUHDO_panelInitBurst();
	VUHDO_panelRefreshInitBurst();
	VUHDO_roleCheckerInitBurst();
	VUHDO_sizeCalculatorInitBurst();
	VUHDO_customHotsInitBurst();
	VUHDO_customDebuffIconsInitBurst();
	VUHDO_debuffsInitBurst();
	VUHDO_healCommAdapterInitBurst();
	VUHDO_buffWatchInitBurst();
	VUHDO_clusterBuilderInitBurst();
	VUHDO_bouquetValidatorsInitBurst();
	VUHDO_bouquetsInitBurst();
	VUHDO_actionEventHandlerInitBurst();
end



--
local function VUHDO_initOptions()
	if (VuhDoNewOptionsTabbedFrame ~= nil) then
		VUHDO_initHotComboModels();
		VUHDO_initHotBarComboModels();
		VUHDO_initDebuffIgnoreComboModel();
		VUHDO_initBouquetComboModel();
		VUHDO_initBouquetSlotsComboModel();
		VUHDO_initProfileTableModels();
		VUHDO_bouquetsUpdateDefaultColors();
	end
end



--
local tName, tExistIndex;
local function VUHDO_loadDefaultProfile()
	if (VUHDO_CONFIG == nil) then
		return;
	end

	tName = VUHDO_CONFIG["CURRENT_PROFILE"];
	if (tName ~= nil and tName ~= "") then

		tExistIndex = VUHDO_getProfileNamed(tName);
		if (tExistIndex ~= nil) then
			VUHDO_loadProfileNoInit(tName);
		end
	end
end



--
local tLevel = 0;
local function VUHDO_init()
	if (tLevel == 0 or VUHDO_VARIABLES_LOADED) then
		tLevel = 1;
		return;
	end

	if (VUHDO_RAID == nil) then
		VUHDO_RAID = { };
	end

	VUHDO_initFastCache();
	VUHDO_loadDefaultProfile(); -- 1. Diese Reihenfolge scheint wichtig zu sein, erzeugt
	VUHDO_loadVariables(); -- 2. umgekehrt undefiniertes Verhalten (VUHDO_CONFIG ist nil etc.)
	VUHDO_initAllBurstCaches();
	VUHDO_VARIABLES_LOADED = true;

	VUHDO_initPanelModels();
	VUHDO_initFromSpellbook();
	VUHDO_initBuffs();
	VUHDO_initDebuffs();
	VUHDO_clearUndefinedModelEntries();
	VUHDO_reloadUI();
	VUHDO_getAutoProfile();
	VUHDO_setLhcEnabled();
	VUHDO_setShieldCommEnabled();
	VUHDO_initCliqueSupport(false);
	if (VuhDoNewOptionsTabbedFrame ~= nil) then
		VuhDoNewOptionsTabbedFrame:ClearAllPoints();
		VuhDoNewOptionsTabbedFrame:SetPoint("CENTER",  "UIParent", "CENTER",  0,  0);
	end

	VUHDO_registerAllBouquets();
	VUHDO_initSharedMedia();
	VUHDO_initFuBar();
	VUHDO_initHideBlizzFrames();
	if (not VUHDO_isInFight()) then
		VUHDO_initKeyboardMacros();
	end
	VUHDO_timeReloadUI(3);
end



--VUHDO_EVENT_TIMES = { };
--
local tUnit;
local tEmptyRaid = { };
function VUHDO_OnEvent(anInstance, anEvent, anArg1, anArg2, anArg3, anArg4, _, anArg6, _, _, anArg9, anArg10, _, anArg12)

--	if (VUHDO_EVENT_TIMES["all"] == nil) then
--		VUHDO_EVENT_TIMES["all"] = 0;
--	end
--	if (VUHDO_EVENT_TIMES[anEvent] == nil) then
--		VUHDO_EVENT_TIMES[anEvent] = { 0, 0, 0, 0, 0, 0 };
--	end
--	local tDuration = GetTime();

	VUHDO_EVENT_COUNT = VUHDO_EVENT_COUNT + 1;

	if ("COMBAT_LOG_EVENT_UNFILTERED" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_parseCombatLogEvent(anArg2, anArg6, anArg9, anArg10, anArg12);
		end
	elseif ("UNIT_AURA" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateHealth(anArg1, 4); -- VUHDO_UPDATE_DEBUFF
		end
	elseif ("UNIT_HEALTH" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateHealth(anArg1, 2); -- VUHDO_UPDATE_HEALTH
		end
	elseif ("UNIT_SPELLCAST_SUCCEEDED" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_spellcastSucceeded(anArg1, anArg2);
		end
	elseif ("UNIT_THREAT_SITUATION_UPDATE" == anEvent) then
		VUHDO_updateThreat(anArg1);
	elseif ("UNIT_MANA" == anEvent
		or "UNIT_ENERGY" == anEvent
		or "UNIT_RAGE" == anEvent
		or "UNIT_RUNIC_POWER" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateManaBars(anArg1, 1);
		end
	elseif ("UNIT_MAXHEALTH" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateHealth(anArg1, VUHDO_UPDATE_HEALTH_MAX);
		end
	elseif ("UNIT_TARGET" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_updateTargetBars(anArg1);
		end
	elseif ("UNIT_DISPLAYPOWER" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateManaBars(anArg1, 3);
		end
	elseif ("UNIT_MAXMANA" == anEvent
		or "UNIT_MAXENERGY" == anEvent
		or "UNIT_MAXRAGE" == anEvent
		or "UNIT_MAXRUNIC_POWER" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateManaBars(anArg1, 2);
		end

	elseif ("UNIT_PET" == anEvent) then
		if (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] or not VUHDO_isInFight()) then
			VUHDO_REMOVE_HOTS = false;
			VUHDO_normalRaidReload();
		end

	elseif ("UNIT_ENTERED_VEHICLE" == anEvent
		or "UNIT_EXITED_VEHICLE" == anEvent
		or "UNIT_EXITING_VEHICLE" == anEvent ) then
		VUHDO_REMOVE_HOTS = false;
		VUHDO_normalRaidReload();
	elseif ("RAID_TARGET_UPDATE" == anEvent) then
		VUHDO_CUSTOMIZE_TIMER = 0.1;
	elseif ("PLAYER_REGEN_ENABLED" == anEvent) then
		if (not VUHDO_isReloadPending()) then
			VUHDO_quickRaidReload();
		end
	elseif ("UNIT_SPELLCAST_STOP" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_spellcastStop(anArg1);
		end
	elseif ("UNIT_SPELLCAST_FAILED" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_spellcastFailed(anArg1);
		end
	elseif ("UNIT_SPELLCAST_SENT" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_spellcastSent(anArg1, anArg2, anArg3, anArg4);
		end
	elseif ("PARTY_MEMBERS_CHANGED" == anEvent
			 or "RAID_ROSTER_UPDATE" == anEvent) then
		if (VUHDO_FIRST_RELOAD_UI) then
			VUHDO_normalRaidReload(true);
		end
	elseif ("PLAYER_FOCUS_CHANGED" == anEvent) then
		VUHDO_quickRaidReload();
	elseif ("PARTY_MEMBER_ENABLE" == anEvent
			 or "PARTY_MEMBER_DISABLE" == anEvent) then
		VUHDO_CUSTOMIZE_TIMER = 0.2;
	elseif ("PLAYER_FLAGS_CHANGED" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateHealth(anArg1, VUHDO_UPDATE_AFK);
			VUHDO_updateBouquetsForEvent(anArg1, VUHDO_UPDATE_AFK);
		end
	elseif ("PLAYER_ENTERING_WORLD" == anEvent) then
		VUHDO_init();

	elseif ("LEARNED_SPELL_IN_TAB" == anEvent) then
		VUHDO_initFromSpellbook();
		VUHDO_registerAllBouquets();
		VUHDO_initBuffs();
		VUHDO_initDebuffs();

	elseif ("VARIABLES_LOADED" == anEvent) then
		VUHDO_init();

	elseif ("UPDATE_BINDINGS" == anEvent) then
		if (not VUHDO_isInFight() and VUHDO_VARIABLES_LOADED) then
			VUHDO_initKeyboardMacros();
		end
	elseif ("PLAYER_TARGET_CHANGED" == anEvent) then
		VUHDO_updatePlayerTarget();
	elseif ("CHAT_MSG_ADDON" == anEvent) then
		VUHDO_parseAddonMessage(anArg1, anArg2, anArg3, anArg4);
	elseif ("READY_CHECK" == anEvent) then
		if (VUHDO_RAID ~= nil) then
			local tRank, _ = VUHDO_getPlayerRank();
			if (tRank >= 1) then
				VUHDO_readyStartCheck(anArg1, anArg2);
			end
		end
	elseif ("READY_CHECK_CONFIRM" == anEvent) then
		if (VUHDO_RAID ~= nil) then
			local tRank, _ = VUHDO_getPlayerRank();
			if (tRank >= 1) then
				VUHDO_readyCheckConfirm(anArg1, anArg2);
			end
		end
	elseif ("READY_CHECK_FINISHED" == anEvent) then
		if (VUHDO_RAID ~= nil) then
			local tRank, _ = VUHDO_getPlayerRank();
			if (tRank >= 1) then
				VUHDO_readyCheckEnds();
			end
		end
	elseif("CVAR_UPDATE" == anEvent) then
		VUHDO_IS_SFX_ENABLED = tonumber(GetCVar("Sound_EnableSFX")) == 1;
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_reloadUI();
		end
	elseif("INSPECT_TALENT_READY" == anEvent) then
		VUHDO_inspectLockRole();
	elseif("MODIFIER_STATE_CHANGED" == anEvent) then
		if (VuhDoTooltip:IsShown()) then
			VUHDO_updateTooltip();
		end
	else
		VUHDO_Msg("Error: Unexpected event: " .. anEvent, 1, 0.4, 0.4);
	end

	VUHDO_EVENT_COUNT = VUHDO_EVENT_COUNT - 1;

	if (VUHDO_EVENT_COUNT < 0) then
		VUHDO_EVENT_COUNT = 0;
	end

	if (VUHDO_EVENT_COUNT == 0) then
		VUHDO_LAST_TIME_NO_EVENT = GetTime();
	end

--	tDuration = GetTime() - tDuration;
--	if (tDuration > VUHDO_EVENT_TIMES[anEvent][1]) then
--		VUHDO_EVENT_TIMES[anEvent][1] = tDuration;
--	end
--	VUHDO_EVENT_TIMES[anEvent][2] = VUHDO_EVENT_TIMES[anEvent][2] + tDuration;
--	VUHDO_EVENT_TIMES[anEvent][3] = VUHDO_EVENT_TIMES[anEvent][3] + 1;
--	VUHDO_EVENT_TIMES["all"] = VUHDO_EVENT_TIMES["all"] + tDuration;
end



--
function VUHDO_slashCmd(aCommand)
	local tParsedTexts = VUHDO_textParse(aCommand);
	local tCommandWord = strlower(tParsedTexts[1]);

	if (strfind(tCommandWord, "opt")) then
		if (VuhDoNewOptionsTabbedFrame ~= nil) then
			if (VUHDO_isInFight() and not VuhDoNewOptionsTabbedFrame:IsShown()) then
				VUHDO_Msg("Leave fight first!", 1, 0.4, 0.4);
			else
				VUHDO_toggleMenu(VuhDoNewOptionsTabbedFrame);
			end
		else
			VUHDO_Msg(VUHDO_I18N_OPTIONS_NOT_LOADED, 1, 0.4, 0.4);
		end
	elseif (tCommandWord == "load" and tParsedTexts[2] ~= nil) then
		local tTokens = VUHDO_splitString(tParsedTexts[2], ",");

		if (#tTokens >= 2 and strlen(strtrim(tTokens[2])) > 0) then
			local tName = strtrim(tTokens[2]);
			if (VUHDO_SPELL_LAYOUTS[tName] ~= nil) then
				VUHDO_activateLayout(tName);
			else
				VUHDO_Msg(VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 .. tName .. VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2, 1, 0.4, 0.4);
			end
		end
		if (#tTokens >= 1 and strlen(strtrim(tTokens[1])) > 0) then
			VUHDO_loadProfile(strtrim(tTokens[1]));
		end
	elseif (strfind(tCommandWord, "res")) then
		local tPanelNum;
		for tPanelNum = 1, VUHDO_MAX_PANELS do
			VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] = nil;
		end
		VUHDO_BUFF_SETTINGS["CONFIG"]["POSITION"] = {
			["x"] = 100,
			["y"] = -100,
			["point"] = "TOPLEFT",
			["relativePoint"] = "TOPLEFT",
		};
		VUHDO_loadDefaultPanelSetup();
		VUHDO_reloadUI();
		VUHDO_Msg(VUHDO_I18N_PANELS_RESET);

	elseif (tCommandWord == "lock") then
		VUHDO_CONFIG["LOCK_PANELS"] = not VUHDO_CONFIG["LOCK_PANELS"];
		local tMessage = VUHDO_I18N_LOCK_PANELS_PRE;
		if (VUHDO_CONFIG["LOCK_PANELS"]) then
			tMessage = tMessage .. VUHDO_I18N_LOCK_PANELS_LOCKED;
		else
			tMessage = tMessage .. VUHDO_I18N_LOCK_PANELS_UNLOCKED;
		end
		VUHDO_Msg(tMessage);
		VUHDO_saveCurrentProfile();

	elseif (tCommandWord == "show") then
		VUHDO_CONFIG["SHOW_PANELS"] = true;
		VUHDO_redrawAllPanels();
		VUHDO_Msg(VUHDO_I18N_PANELS_SHOWN);
		VUHDO_saveCurrentProfile();

	elseif (tCommandWord == "hide") then
		VUHDO_CONFIG["SHOW_PANELS"] = false;
		VUHDO_redrawAllPanels();
		VUHDO_Msg(VUHDO_I18N_PANELS_HIDDEN);
		VUHDO_saveCurrentProfile();

	elseif (tCommandWord == "toggle") then
		VUHDO_CONFIG["SHOW_PANELS"] = not VUHDO_CONFIG["SHOW_PANELS"];
		if (VUHDO_CONFIG["SHOW_PANELS"]) then
			VUHDO_Msg(VUHDO_I18N_PANELS_SHOWN);
		else
			VUHDO_Msg(VUHDO_I18N_PANELS_HIDDEN);
		end
		VUHDO_redrawAllPanels();
		VUHDO_saveCurrentProfile();

	elseif (strfind(tCommandWord, "cast") or strfind(tCommandWord, "mt")) then
		VUHDO_ctraBroadCastMaintanks();
		VUHDO_Msg(VUHDO_I18N_MTS_BROADCASTED);

	elseif (tCommandWord == "pron") then
		SetCVar("scriptProfile", "1");
		ReloadUI();
	elseif (tCommandWord == "proff") then
		SetCVar("scriptProfile", "0");
		ReloadUI();
--	elseif (strfind(tCommandWord, "fupro")) then
--		local tData, tFName;
--		table.wipe(FunctionProfiler_Settings["watched"]);
--		for tFName, tData in pairs(VUHDO_GLOBAL) do
--			if (strsub(tFName, 1, 5) == "VUHDO") then
--				if (type(tData) == "function") then
--					table.insert(FunctionProfiler_Settings["watched"], tFName);
--				end
--			elseif(strsub(tFName, 1, 4) == "t") then
--				VUHDO_Msg("Emerging local variable " .. tFName);
--			end
--		end
--	elseif (strfind(tCommandWord, "chkvars")) then
--		for tFName, tData in pairs(VUHDO_GLOBAL) do
--			if(strsub(tFName, 1, 1) == "t") then
--				VUHDO_Msg("Emerging local variable " .. tFName);
--			end
--		end

	elseif (strfind(tCommandWord, "mm")
		or strfind(tCommandWord, "map")) then

		VUHDO_CONFIG["SHOW_MINIMAP"] = not VUHDO_CONFIG["SHOW_MINIMAP"];
		VUHDO_initShowMinimap();
		local tMessage = VUHDO_I18N_MM_ICON;
		if (VUHDO_CONFIG["SHOW_MINIMAP"]) then
			tMessage = tMessage .. VUHDO_I18N_CHAT_SHOWN;
		else
			tMessage = tMessage .. VUHDO_I18N_CHAT_HIDDEN;
		end

		VUHDO_Msg(tMessage);
		VUHDO_saveCurrentProfile();

	elseif (tCommandWord == "ui") then
	  VUHDO_reloadUI();
	elseif (tCommandWord == "rui") then
	  VUHDO_refreshUI();
	elseif (strfind(tCommandWord, "role")) then
		VUHDO_Msg("Player roles have been reset.");
		VUHDO_resetTalentScan();
		VUHDO_reloadUI();
	elseif (strfind(tCommandWord, "cluster")) then
		VUHDO_Msg("Map dimensions for cluster builder have been reset.");
		table.wipe(VUHDO_STORED_ZONES);
	--elseif (strfind(tCommandWord, "debug")) then
		--VUHDO_DEBUG_AUTO_ARRANG = tonumber(tParsedTexts[2]);
	elseif (strfind(tCommandWord, "bench")) then
		--VUHDO_sendPallyPowerRequest();
	  --elseif (strfind(tCommandWord, "test")) then
		--VUHDO_EVENT_TIMES = { };
--		local tCnt;
		VUHDO_initProfiler();
		for tCnt = 1, 1000 do
			VUHDO_refreshUI();
		end
		VUHDO_seeProfiler();
	elseif (aCommand == "?"
		or strfind(tCommandWord, "help")
		or aCommand == "") then
		local tLines = VUHDO_splitString(VUHDO_I18N_COMMAND_LIST, "§");
		local tCurLine;
		for _, tCurLine in ipairs(tLines) do
			VUHDO_MsgC(tCurLine);
		end
	else
		VUHDO_Msg(VUHDO_I18N_BAD_COMMAND, 1, 0.4, 0.4);
	end
end



--
function VUHDO_updateGlobalToggles()
	if (VUHDO_INSTANCE == nil) then
		return;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_THREAT_LEVEL) or VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_AGGRO)) then
		VUHDO_INSTANCE:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	else
		VUHDO_INSTANCE:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	end



	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_THREAT_PERC)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] = false;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_AGGRO)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO] = false;
	end

	if (not VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] and not VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO]) then
		VUHDO_UPDATE_AGGRO_TIMER = -1;
	else
		VUHDO_UPDATE_AGGRO_TIMER = 1;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_RANGE)) then
		VUHDO_UPDATE_RANGE_TIMER = 1;
	else
		VUHDO_UPDATE_RANGE_TIMER = -1;
	end



	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_NUM_CLUSTER)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER] = false;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_MOUSEOVER_CLUSTER)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER] = false;
	end

	if (not VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER] and not VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER]) then
		VUHDO_UPDATE_CLUSTERS_TIMER = -1;
	else
		VUHDO_UPDATE_CLUSTERS_TIMER = 1;
	end
	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_MOUSEOVER)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER] = false;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_MOUSEOVER_GROUP)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_GROUP] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_GROUP] = false;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_MANA)) then
		VUHDO_INSTANCE:RegisterEvent("UNIT_DISPLAYPOWER");
		VUHDO_INSTANCE:RegisterEvent("UNIT_MAXMANA");
		VUHDO_INSTANCE:RegisterEvent("UNIT_MANA");

		if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_OTHER_POWERS)) then
			VUHDO_INSTANCE:RegisterEvent("UNIT_MAXENERGY");
			VUHDO_INSTANCE:RegisterEvent("UNIT_MAXRAGE");
			VUHDO_INSTANCE:RegisterEvent("UNIT_MAXRUNIC_POWER");

			VUHDO_INSTANCE:RegisterEvent("UNIT_ENERGY");
			VUHDO_INSTANCE:RegisterEvent("UNIT_RAGE");
			VUHDO_INSTANCE:RegisterEvent("UNIT_RUNIC_POWER");
		else
			VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXENERGY");
			VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXRAGE");
			VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXRUNIC_POWER");

			VUHDO_INSTANCE:UnregisterEvent("UNIT_ENERGY");
			VUHDO_INSTANCE:UnregisterEvent("UNIT_RAGE");
			VUHDO_INSTANCE:UnregisterEvent("UNIT_RUNIC_POWER");
		end

	else
		VUHDO_INSTANCE:UnregisterEvent("UNIT_DISPLAYPOWER");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXMANA");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_MANA");

		VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXENERGY");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXRAGE");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXRUNIC_POWER");

		VUHDO_INSTANCE:UnregisterEvent("UNIT_ENERGY");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_RAGE");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_RUNIC_POWER");
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_UNIT_TARGET)) then
		VUHDO_INSTANCE:RegisterEvent("UNIT_TARGET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_UNIT_TARGET] = true;
		VUHDO_REFRESH_TARGETS_TIMER = 1;
	else
		VUHDO_INSTANCE:UnregisterEvent("UNIT_TARGET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_UNIT_TARGET] = false;
		VUHDO_REFRESH_TARGETS_TIMER = -1;
	end

	if (VUHDO_CONFIG["IS_SCAN_TALENTS"]) then
		VUHDO_REFRESH_INSPECT_TIMER = 1;
	else
		VUHDO_REFRESH_INSPECT_TIMER = -1;
	end

	if (VUHDO_isModelConfigured(VUHDO_ID_PETS)) then
		--VUHDO_INSTANCE:RegisterEvent("UNIT_PET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] = true;
	else
		--VUHDO_INSTANCE:UnregisterEvent("UNIT_PET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] = false;
	end

	if (VUHDO_isModelConfigured(VUHDO_ID_PRIVATE_TANKS) and not VUHDO_CONFIG["OMIT_TARGET"]) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET] = false;
	end
end



--
function VUHDO_loadVariables()
	_, VUHDO_PLAYER_CLASS = UnitClass("player");
	VUHDO_PLAYER_NAME = UnitName("player");

	VUHDO_loadSpellArray();
	VUHDO_loadDefaultPanelSetup();
	VUHDO_initBuffSettings();
	VUHDO_loadDefaultConfig();
	VUHDO_initMinimap();
	VUHDO_loadDefaultBouquets();
	VUHDO_importSkinsArrangements();
	VUHDO_initClassColors();

	VUHDO_lnfPatchFont(VuhDoOptionsTooltipText, "Text");
end



--
local tOldAggro = { };
local tOldThreat = { };
local tTarget;
local tAggroUnit;
local tIsDetectAggro;
local tThreatPerc;
local tIsHealerMode, tIsThreatPerc, tIsAggro;

function VUHDO_updateAllAggro()
	tIsHealerMode = not VUHDO_CONFIG["THREAT"]["IS_TANK_MODE"];
	tIsThreatPerc = VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC];
	tIsAggro = VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO];

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tOldAggro[tUnit] = tInfo.aggro;
		tOldThreat[tUnit] = tInfo.threatPerc;
		tInfo.aggro = false;
		tInfo.threatPerc = 0;
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (tInfo.connected and not tInfo.dead) then
			if (tIsAggro and (tInfo.threat or 0) >= 2) then
				tInfo.aggro = true;
			end
			tTarget = tInfo.targetUnit;
			if (UnitIsEnemy(tUnit, tTarget)) then
				if (tIsThreatPerc) then
					_, _, tThreatPerc = UnitDetailedThreatSituation(tUnit, tTarget);
					tInfo.threatPerc = tThreatPerc or 0;
				end

				tAggroUnit = VUHDO_RAID_NAMES[UnitName(tTarget .. "target")];

				if (tAggroUnit ~= nil) then
					if (tIsThreatPerc) then
						_, _, tThreatPerc = UnitDetailedThreatSituation(tAggroUnit, tTarget);
						VUHDO_RAID[tAggroUnit].threatPerc = tThreatPerc or 0;
					end

					if (tIsHealerMode and tIsAggro) then
						VUHDO_RAID[tAggroUnit].aggro = true;
					end
				end
			end
		else
			tInfo.aggro = false;
		end
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (tInfo.aggro ~= tOldAggro[tUnit]) then
			VUHDO_updateHealthBarsFor(tUnit, VUHDO_UPDATE_AGGRO);
		end

		if (tInfo.threatPerc ~= tOldThreat[tUnit]) then
			VUHDO_updateBouquetsForEvent(tUnit, VUHDO_UPDATE_THREAT_PERC);
		end
	end
end
local VUHDO_updateAllAggro = VUHDO_updateAllAggro;



--
function VUHDO_normalRaidReload(anIsReloadBuffs)
	if (VUHDO_isConfigPanelShowing()) then
		return;
	end
	VUHDO_RELOAD_RAID_TIMER = VUHDO_RELOAD_RAID_DELAY;
	if (anIsReloadBuffs ~= nil) then
		VUHDO_IS_RELOAD_BUFFS = true;
	end
end



--
function VUHDO_quickRaidReload()
	VUHDO_RELOAD_RAID_TIMER = VUHDO_RELOAD_RAID_DELAY_QUICK;
end



--
function VUHDO_lateRaidReload()
	if (not VUHDO_isReloadPending()) then
		VUHDO_RELOAD_RAID_TIMER = 5;
	end
end


--
function VUHDO_isReloadPending()
	return VUHDO_RELOAD_RAID_TIMER > 0
		or VUHDO_RELOAD_UI_TIMER > 0
		or VUHDO_IS_RELOADING;
end



--
function VUHDO_timeReloadUI(someSecs, anIsLnf)
	VUHDO_RELOAD_UI_TIMER = someSecs;
	VUHDO_RELOAD_UI_IS_LNF = anIsLnf;
end



--
function VUHDO_timeRedrawPanel(aPanelNum, someSecs)
	VUHDO_RELOAD_PANEL_NUM = aPanelNum;
	VUHDO_RELOAD_PANEL_TIMER = someSecs;
end



--
function VUHDO_setDebuffAnimation(aTimeSecs)
	VUHDO_DEBUFF_ANIMATION = aTimeSecs;
end



--
function VUHDO_initGcd()
	VUHDO_GCD_UPDATE = true;
end


--
local tNow;
local tInRange;
local tSpellName;
local tTimeDelta = 0;
local tAutoArrangement;
local tUnit, tInfo;
local tGcdStart, tGcdDuration, tRemain;
local tHotDebuffToggle = 1;
local tZoneToggle = 1;
VUHDO_emptyUnit = { };
local tRangeSpell, tIsRangeKnown;
function VUHDO_OnUpdate(anInstance, aTimeDelta)

	-- Update custom debuff animation with every tick
	if (VUHDO_DEBUFF_ANIMATION > 0) then
		VUHDO_updateAllDebuffIcons();
		VUHDO_DEBUFF_ANIMATION = VUHDO_DEBUFF_ANIMATION - aTimeDelta;
	end

	tNow = GetTime();

	-- Update GCD-Bar
	if (VUHDO_GCD_UPDATE and VUHDO_GCD_SPELLS[VUHDO_PLAYER_CLASS] ~= nil) then
		tGcdStart, tGcdDuration, _ = GetSpellCooldown(VUHDO_GCD_SPELLS[VUHDO_PLAYER_CLASS]);
		if (tGcdDuration == 0 or tGcdDuration == nil) then
			VuhDoGcdStatusBar:SetValue(0);
			VUHDO_GCD_UPDATE = false;
		else
			VuhDoGcdStatusBar:SetValue(100 * (tGcdDuration - (tNow - tGcdStart)) / tGcdDuration);
		end
	end

	-- In all other cases 0.05 (50 msec) sec tick should be sufficient
	if (tTimeDelta < 0.05) then
		tTimeDelta = tTimeDelta + aTimeDelta;
		return;
	else
		aTimeDelta = aTimeDelta + tTimeDelta;
		tTimeDelta = 0;
	end


	if (VUHDO_EVENT_COUNT > 0) then
		if (VUHDO_LAST_TIME_NO_EVENT + 3 < tNow) then
			VUHDO_LAST_TIME_NO_EVENT = tNow;
			VUHDO_EVENT_COUNT = 0;
		end

		return;
	end

	-- reload UI?
	if (VUHDO_RELOAD_UI_TIMER > 0) then
		VUHDO_RELOAD_UI_TIMER = VUHDO_RELOAD_UI_TIMER - aTimeDelta;
		if (VUHDO_RELOAD_UI_TIMER <= 0) then
			if (VUHDO_IS_RELOADING or VUHDO_isInFight()) then
				VUHDO_RELOAD_UI_TIMER = VUHDO_RELOAD_RAID_DELAY_QUICK;
			else
				if (VUHDO_RELOAD_UI_IS_LNF) then
					VUHDO_lnfReloadUI();
				else
					VUHDO_reloadUI();
				end
				VUHDO_initOptions();
				VUHDO_FIRST_RELOAD_UI = true;
			end
		end
	end

	-- redraw single panel?
	if (VUHDO_RELOAD_PANEL_TIMER > 0) then
		VUHDO_RELOAD_PANEL_TIMER = VUHDO_RELOAD_PANEL_TIMER - aTimeDelta;
		if (VUHDO_RELOAD_PANEL_TIMER <= 0) then
			if (VUHDO_IS_RELOADING or VUHDO_isInFight()) then
				VUHDO_RELOAD_PANEL_TIMER = VUHDO_RELOAD_RAID_DELAY_QUICK;
			else
				VUHDO_PROHIBIT_REPOS = true;
				VUHDO_initAllBurstCaches();
				VUHDO_redrawPanel(VUHDO_RELOAD_PANEL_NUM);
				VUHDO_updateAllPanelBars(VUHDO_RELOAD_PANEL_NUM);
				VUHDO_buildGenericHealthBarBouquet();
				collectgarbage('collect');
				VUHDO_registerAllBouquets();
				VUHDO_initAllEventBouquets();
				VUHDO_PROHIBIT_REPOS = false;
			end
		end
	end

	------------------------- below only if vars loaded
	if (not VUHDO_VARIABLES_LOADED) then
		return;
	end

	-- reload after battle
	if (VUHDO_RELOAD_AFTER_BATTLE and not VUHDO_isInFight()) then
		VUHDO_RELOAD_AFTER_BATTLE = false;

		if (VUHDO_RELOAD_RAID_TIMER <= 0) then
			VUHDO_quickRaidReload();
			if (VUHDO_IS_RELOAD_BUFFS) then
				VUHDO_reloadBuffPanel();
				VUHDO_IS_RELOAD_BUFFS = false;
			end
		end
	end

	-- Reload raid roster?
	if (VUHDO_RELOAD_RAID_TIMER > 0) then
		VUHDO_RELOAD_RAID_TIMER = VUHDO_RELOAD_RAID_TIMER - aTimeDelta;
		if (VUHDO_RELOAD_RAID_TIMER <= 0 and not VUHDO_isConfigPanelShowing()) then
			if (VUHDO_IS_RELOADING) then
				VUHDO_quickRaidReload();
			else
				VUHDO_rebuildTargets();

				if (VUHDO_isInFight()) then
					VUHDO_RELOAD_AFTER_BATTLE = true;

					VUHDO_IS_RELOADING = true;
					VUHDO_updateAllRaidBars();
					VUHDO_initAllEventBouquets();

					VUHDO_refreshRaidMembers();
					--VUHDO_reloadRaidMembers();

					VUHDO_updateAllRaidBars();
					VUHDO_initAllEventBouquets();
					VUHDO_IS_RELOADING = false;

				else
					VUHDO_refreshUI();
					if (VUHDO_IS_RELOAD_BUFFS) then
						VUHDO_reloadBuffPanel();
						VUHDO_IS_RELOAD_BUFFS = false;
					end
				end
			end
		end
	end

	-- refresh HoTs, cyclic bouquets and customs debuffs?
	if (VUHDO_UPDATE_HOTS_TIMER > 0) then
		VUHDO_UPDATE_HOTS_TIMER = VUHDO_UPDATE_HOTS_TIMER - aTimeDelta;
		if (VUHDO_UPDATE_HOTS_TIMER <= 0) then

			if (tHotDebuffToggle == 1) then
				VUHDO_updateAllHoTs();
			elseif (tHotDebuffToggle == 2) then
				VUHDO_updateAllCyclicBouquets();
			else
				if (VUHDO_DEBUFF_ANIMATION <= 0) then
					VUHDO_updateAllDebuffIcons();
				end
			end

			-- Reload after player gained control
			if (tHotDebuffToggle == 3) then
				if (not HasFullControl()) then
					VUHDO_LOST_CONTROL = true;
				else
					if (VUHDO_LOST_CONTROL) then
						if (VUHDO_RELOAD_RAID_TIMER <= 0) then
							VUHDO_CUSTOMIZE_TIMER = VUHDO_RELOAD_RAID_DELAY_QUICK;
						end
						VUHDO_LOST_CONTROL = false;
					end
				end
			end

			tHotDebuffToggle = tHotDebuffToggle + 1;
			if (tHotDebuffToggle > 3) then
				tHotDebuffToggle = 1;
			end

			VUHDO_UPDATE_HOTS_TIMER = VUHDO_CONFIG["UPDATE_HOTS_MS"] * 0.00033;
		end
	end

	-- track dragged panel coords
	if (VUHDO_DRAG_PANEL ~= nil) then
		VUHDO_REFRESH_DRAG_TIMER = VUHDO_REFRESH_DRAG_TIMER - aTimeDelta;
		if (VUHDO_REFRESH_DRAG_TIMER <= 0) then
			VUHDO_REFRESH_DRAG_TIMER = VUHDO_REFRESH_DRAG_DELAY;
			VUHDO_refreshDragTarget(VUHDO_DRAG_PANEL);
		end
	end

	-- Set Button colors without repositioning
	if (VUHDO_CUSTOMIZE_TIMER > 0) then
		VUHDO_CUSTOMIZE_TIMER = VUHDO_CUSTOMIZE_TIMER - aTimeDelta;
		if (VUHDO_CUSTOMIZE_TIMER <= 0) then
			VUHDO_updateAllRaidTargetIndices();
			VUHDO_updateAllRaidBars();
			VUHDO_initAllEventBouquets();
		end
	end

	-- Refresh Tooltip, clear obsolete incoming heals
	if (VUHDO_REFRESH_TOOLTIP_TIMER > 0) then
		VUHDO_REFRESH_TOOLTIP_TIMER = VUHDO_REFRESH_TOOLTIP_TIMER - aTimeDelta;
		if (VUHDO_REFRESH_TOOLTIP_TIMER <= 0) then
			VUHDO_REFRESH_TOOLTIP_TIMER = VUHDO_REFRESH_TOOLTIP_DELAY;
			if (VuhDoTooltip:IsShown()) then
				VUHDO_updateTooltip();
			end

			VUHDO_clearObsoleteInc();
		end
	end

	-- automatic profiles
	if (VUHDO_RELOAD_LAG_TIMER > 0) then
		VUHDO_RELOAD_LAG_TIMER = VUHDO_RELOAD_LAG_TIMER - aTimeDelta;
		if (VUHDO_RELOAD_LAG_TIMER <= 0) then

			-- Auto profiles
			if (not VUHDO_isInFight()) then
				if (VUHDO_LAST_AUTO_ARRANG == nil) then
					VUHDO_LAST_AUTO_ARRANG = VUHDO_getAutoProfile();
				else
					tAutoArrangement, tTrigger = VUHDO_getAutoProfile();
					if (tAutoArrangement ~= nil and VUHDO_LAST_AUTO_ARRANG ~= tAutoArrangement and not VUHDO_IS_CONFIG) then
						VUHDO_Msg(VUHDO_I18N_AUTO_ARRANG_1 .. tTrigger .. VUHDO_I18N_AUTO_ARRANG_2 .. "|cffffffff" .. tAutoArrangement .. "|r\"");

						VUHDO_loadProfile(tAutoArrangement);
						VUHDO_LAST_AUTO_ARRANG = tAutoArrangement;
					end
				end
			end

			VUHDO_RELOAD_LAG_TIMER = VUHDO_RELOAD_LAG_DELAY;
		end
	end


	-- Unit Zones
	if (VUHDO_RELOAD_ZONES_TIMER > 0) then
		VUHDO_RELOAD_ZONES_TIMER = VUHDO_RELOAD_ZONES_TIMER - aTimeDelta;
		if (VUHDO_RELOAD_ZONES_TIMER <= 0) then

			-- Unit Zones
			for tUnit, tInfo in pairs(VUHDO_RAID) do
				if (tZoneToggle == 1) then
					tInfo["baseRange"] = UnitInRange(tUnit);
				elseif (tZoneToggle == 2) then
					tInfo["visible"] = UnitIsVisible(tUnit); -- Reihenfolge beachten
				else
					tInfo["zone"], tInfo["map"] = VUHDO_getUnitZoneName(tUnit); -- ^^
				end
			end

			tZoneToggle = tZoneToggle + 1;
			if (tZoneToggle > 3) then
				tZoneToggle = 1;
			end

			VUHDO_RELOAD_ZONES_TIMER = VUHDO_RELOAD_ZONES_DELAY * 0.33;
		end
	end



	-- Refresh Buff Watch
	if (VUHDO_REFRESH_BUFFS_TIMER > 0) then
		VUHDO_REFRESH_BUFFS_TIMER = VUHDO_REFRESH_BUFFS_TIMER - aTimeDelta;
		if (VUHDO_REFRESH_BUFFS_TIMER <= 0) then
			VUHDO_updateBuffPanel();
			VUHDO_REFRESH_BUFFS_TIMER = VUHDO_BUFF_SETTINGS["CONFIG"]["REFRESH_SECS"];
		end
	end

	-- Refresh Inspect, check timeout
	if (VUHDO_NEXT_INSPECT_UNIT ~= nil and tNow > VUHDO_NEXT_INSPECT_TIME_OUT) then
		VUHDO_setRoleUndefined(VUHDO_NEXT_INSPECT_UNIT);
		VUHDO_NEXT_INSPECT_UNIT = nil;
	end

	-- Refresh targets not in raid
	if (VUHDO_REFRESH_TARGETS_TIMER > 0) then
		VUHDO_REFRESH_TARGETS_TIMER = VUHDO_REFRESH_TARGETS_TIMER - aTimeDelta;
		if (VUHDO_REFRESH_TARGETS_TIMER <= 0) then
			VUHDO_updateAllOutRaidTargetButtons();
			VUHDO_REFRESH_TARGETS_TIMER = VUHDO_REFRESH_TARGETS_DELAY;
		end
	end

	-----------------------------------------------------------------------------------------

	if (VUHDO_CONFIG_SHOW_RAID) then
		return;
	end

	-- refresh aggro?
	if (VUHDO_UPDATE_AGGRO_TIMER > 0) then
		VUHDO_UPDATE_AGGRO_TIMER = VUHDO_UPDATE_AGGRO_TIMER - aTimeDelta;
		if (VUHDO_UPDATE_AGGRO_TIMER <= 0) then
			VUHDO_updateAllAggro();
			VUHDO_UPDATE_AGGRO_TIMER = VUHDO_CONFIG["THREAT"]["AGGRO_REFRESH_MS"] * 0.001;
		end
	end

	-- refresh range?
	if (VUHDO_UPDATE_RANGE_TIMER > 0) then
		VUHDO_UPDATE_RANGE_TIMER = VUHDO_UPDATE_RANGE_TIMER - aTimeDelta;
		if (VUHDO_UPDATE_RANGE_TIMER <= 0) then
			if (VUHDO_CONFIG.RANGE_PESSIMISTIC) then
				for tUnit, tInfo in pairs(VUHDO_RAID) do
					tInRange = tInfo["connected"] and ((VUHDO_RAID[tUnit] or VUHDO_emptyUnit).baseRange
										or "player" == tUnit or ((tUnit == "focus" or tUnit == "target") and CheckInteractDistance(tUnit, 1)));

					if (tInfo["range"] ~= tInRange) then
						tInfo["range"] = tInRange;
						VUHDO_updateHealthBarsFor(tUnit, 5); -- VUHDO_UPDATE_RANGE
					end

					tInRange = UnitIsCharmed(tUnit) and UnitCanAttack("player", tUnit) and not tInfo["dead"];
					if (tInfo["charmed"] ~= tInRange) then
						tInfo["charmed"] = tInRange;
						VUHDO_updateHealthBarsFor(tUnit, 4); -- VUHDO_UPDATE_DEBUFF
					end
				end
			else
				tRangeSpell = VUHDO_CONFIG["RANGE_SPELL"] or "*foo*";
				tIsRangeKnown = GetSpellInfo(tRangeSpell) ~= nil;
				for tUnit, tInfo in pairs(VUHDO_RAID) do
					tInRange = tInfo["connected"] and (((VUHDO_RAID[tUnit] or VUHDO_emptyUnit).baseRange or (tIsRangeKnown and 1 == IsSpellInRange(tRangeSpell, tUnit)))
									 or "player" == tUnit or ((tUnit == "focus" or tUnit == "target") and CheckInteractDistance(tUnit, 1)));

					if (tInfo["range"] ~= tInRange) then
						tInfo["range"] = tInRange;
						VUHDO_updateHealthBarsFor(tUnit, 5); -- VUHDO_UPDATE_RANGE
					end

					tInRange = UnitIsCharmed(tUnit) and UnitCanAttack("player", tUnit) and not tInfo["dead"];
					if (tInfo["charmed"] ~= tInRange) then
						tInfo["charmed"] = tInRange;
						VUHDO_updateHealthBarsFor(tUnit, 4); -- VUHDO_UPDATE_DEBUFF
					end
				end
			end

			VUHDO_UPDATE_RANGE_TIMER = VUHDO_CONFIG.RANGE_CHECK_DELAY * 0.001;
		end
	end

	-- Refresh Inspect, set new unit if no server request pending
	if (VUHDO_REFRESH_INSPECT_TIMER > 0 and VUHDO_NEXT_INSPECT_UNIT == nil and not VUHDO_isInFight()) then
		VUHDO_REFRESH_INSPECT_TIMER = VUHDO_REFRESH_INSPECT_TIMER - aTimeDelta;
		if (VUHDO_REFRESH_INSPECT_TIMER <= 0) then
			VUHDO_tryInspectNext();
			VUHDO_REFRESH_INSPECT_TIMER = VUHDO_REFRESH_INSPECT_DELAY;
		end
	end

	-- Refresh Clusters
	if (VUHDO_UPDATE_CLUSTERS_TIMER > 0) then
		VUHDO_UPDATE_CLUSTERS_TIMER = VUHDO_UPDATE_CLUSTERS_TIMER - aTimeDelta;
		if (VUHDO_UPDATE_CLUSTERS_TIMER <= 0) then
			VUHDO_updateAllClusters();
			VUHDO_UPDATE_CLUSTERS_TIMER = VUHDO_CONFIG["CLUSTER"].REFRESH * 0.001;
		end
	end
end

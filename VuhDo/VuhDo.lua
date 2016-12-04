VUHDO_IN_COMBAT_RELOG = false;


VUHDO_RAID = { };
local VUHDO_RAID;

VUHDO_RAID_NAMES = { };
local VUHDO_RAID_NAMES = VUHDO_RAID_NAMES;

VUHDO_GROUPS = { };
local VUHDO_GROUPS = VUHDO_GROUPS;

VUHDO_RAID_GUIDS = { };
local VUHDO_RAID_GUIDS = VUHDO_RAID_GUIDS;

VUHDO_RAID_GUID_NAMES = { };
local VUHDO_RAID_GUID_NAMES = VUHDO_RAID_GUID_NAMES;

VUHDO_EMERGENCIES = { };
local VUHDO_EMERGENCIES = VUHDO_EMERGENCIES;

VUHDO_CLUSTER_BASE_RAID = { };
local VUHDO_CLUSTER_BASE_RAID = VUHDO_CLUSTER_BASE_RAID;

VUHDO_PLAYER_TARGETS = { };

VUHDO_BUFF_GROUPS = { };


local VUHDO_IS_SUSPICIOUS_ROSTER = false;

local VUHDO_RAID_SORTED = { };
local VUHDO_MAINTANKS = { };
local VUHDO_IS_RESURRECTING = false;
local VUHDO_INTERNAL_TOGGLES = { };


VUHDO_PLAYER_CLASS = nil;
VUHDO_PLAYER_NAME = nil;
VUHDO_PLAYER_RAID_ID = nil;
VUHDO_PLAYER_GROUP = nil;

VUHDO_GLOBAL = getfenv();

-- BURST CACHE ---------------------------------------------------
local VUHDO_getUnitIds;
local VUHDO_getUnitNo;
local VUHDO_isInRange;
local VUHDO_determineDebuff;
local VUHDO_getUnitGroup;
local VUHDO_getPetUnit;
local VUHDO_tableUniqueAdd;
local VUHDO_getTargetUnit;
local VUHDO_updateHealthBarsFor;
local VUHDO_trimInspected;
local VUHDO_CONFIG;
local VUHDO_getPlayerRaidUnit;
local VUHDO_getModelType;
local VUHDO_isConfigDemoUsers;
local VUHDO_updateBouquetsForEvent;
local VUHDO_resetClusterCoordDeltas;
local VUHDO_getUnitZoneName;
local VUHDO_getUnitButtons;

local GetRaidTargetIndex = GetRaidTargetIndex;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitExists = UnitExists;
local UnitHealth = UnitHealth;
local UnitHealthMax = UnitHealthMax;
local string = string;
local UnitIsAFK = UnitIsAFK;
local UnitIsConnected = UnitIsConnected;
local UnitIsCharmed = UnitIsCharmed;
local UnitCanAttack = UnitCanAttack;
local GetNumRaidMembers = GetNumRaidMembers;
local GetNumPartyMembers = GetNumPartyMembers;
local UnitName = UnitName;
local UnitMana = UnitMana;
local UnitManaMax = UnitManaMax;
local UnitThreatSituation = UnitThreatSituation;
local UnitClass = UnitClass;
local UnitPowerType = UnitPowerType;
local UnitInVehicle = UnitInVehicle;
local UnitHasVehicleUI = UnitHasVehicleUI;
local UnitGroupRolesAssigned = UnitGroupRolesAssigned;
local GetRaidRosterInfo = GetRaidRosterInfo;
local table = table;
local UnitGUID = UnitGUID;
local tinsert = tinsert;
local tremove = tremove;
local strfind = strfind;
local gsub = gsub;
--local VUHDO_PANEL_MODELS;
local VUHDO_determineRole;
local VUHDO_getUnitHealthPercent;

function VUHDO_vuhdoInitBurst()
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_getUnitIds = VUHDO_GLOBAL["VUHDO_getUnitIds"];
	VUHDO_getUnitNo = VUHDO_GLOBAL["VUHDO_getUnitNo"];
	VUHDO_isInRange = VUHDO_GLOBAL["VUHDO_isInRange"];
	VUHDO_determineDebuff = VUHDO_GLOBAL["VUHDO_determineDebuff"];
	VUHDO_getUnitGroup = VUHDO_GLOBAL["VUHDO_getUnitGroup"];
	VUHDO_getPetUnit = VUHDO_GLOBAL["VUHDO_getPetUnit"];
	VUHDO_updateHealthBarsFor = VUHDO_GLOBAL["VUHDO_updateHealthBarsFor"];
	VUHDO_tableUniqueAdd = VUHDO_GLOBAL["VUHDO_tableUniqueAdd"];
	VUHDO_trimInspected = VUHDO_GLOBAL["VUHDO_trimInspected"];
	VUHDO_getTargetUnit = VUHDO_GLOBAL["VUHDO_getTargetUnit"];
	VUHDO_getModelType = VUHDO_GLOBAL["VUHDO_getModelType"];
	VUHDO_getUnitButtons = VUHDO_GLOBAL["VUHDO_getUnitButtons"];

	VUHDO_getPlayerRaidUnit = VUHDO_GLOBAL["VUHDO_getPlayerRaidUnit"];
	--VUHDO_PANEL_MODELS = VUHDO_GLOBAL["VUHDO_PANEL_MODELS"];
	VUHDO_determineRole = VUHDO_GLOBAL["VUHDO_determineRole"];
	VUHDO_getUnitHealthPercent = VUHDO_GLOBAL["VUHDO_getUnitHealthPercent"];
	VUHDO_isConfigDemoUsers = VUHDO_GLOBAL["VUHDO_isConfigDemoUsers"];
	VUHDO_updateBouquetsForEvent = VUHDO_GLOBAL["VUHDO_updateBouquetsForEvent"];
	VUHDO_resetClusterCoordDeltas = VUHDO_GLOBAL["VUHDO_resetClusterCoordDeltas"];
	VUHDO_getUnitZoneName = VUHDO_GLOBAL["VUHDO_getUnitZoneName"];
	VUHDO_INTERNAL_TOGGLES = VUHDO_GLOBAL["VUHDO_INTERNAL_TOGGLES"];
end

----------------------------------------------------



--
local tUnit, tInfo;
local function VUHDO_updateAllRaidNames()
	table.wipe(VUHDO_RAID_NAMES);

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (tUnit ~= "focus" and tUnit ~= "target") then
			-- ensure not to overwrite a player name with a pet's identical name
			if (VUHDO_RAID_NAMES[tInfo["name"]] == nil or not tInfo["isPet"]) then
				VUHDO_RAID_NAMES[tInfo["name"]] = tUnit;
			end
		end
	end
end



--
local tInfo;
local function VUHDO_isValidEmergency(aUnit)
	tInfo = VUHDO_RAID[aUnit];

	return
		not tInfo["isPet"]
		and tInfo["range"]
		and not tInfo["dead"]
		and tInfo["connected"]
		and not tInfo["charmed"];
end



--
local tUnit;
local tIndex;
local function VUHDO_setTopEmergencies(aMaxAnz)
	table.wipe(VUHDO_EMERGENCIES);
	for tIndex, tUnit in ipairs(VUHDO_RAID_SORTED) do
		VUHDO_EMERGENCIES[tUnit] = tIndex;
		if (tIndex == aMaxAnz) then
			break;
		end
	end
end



--
local tInfoA, tInfoB;
local VUHDO_EMERGENCY_SORTERS = {
	[VUHDO_MODE_EMERGENCY_MOST_MISSING]
		= function(aUnit, anotherUnit)
				tInfoA = VUHDO_RAID[aUnit];
				tInfoB = VUHDO_RAID[anotherUnit];

				return (tInfoA["healthmax"] - tInfoA["health"]
							> tInfoB["healthmax"] - tInfoB["health"]);
			end,

	[VUHDO_MODE_EMERGENCY_PERC]
		= function(aUnit, anotherUnit)
				tInfoA = VUHDO_RAID[aUnit];
				tInfoB = VUHDO_RAID[anotherUnit];

					return (tInfoA["health"] / tInfoA["healthmax"]
								< tInfoB["health"] / tInfoB["healthmax"]);
			end,

	[VUHDO_MODE_EMERGENCY_LEAST_LEFT]
		= function(aUnit, anotherUnit)
				return VUHDO_RAID[aUnit]["health"] < VUHDO_RAID[anotherUnit]["health"];
			end,
}



--
local tUnit, tInfo;
local tTrigger;
local function VUHDO_sortEmergencies()
	table.wipe(VUHDO_RAID_SORTED);
	tTrigger = VUHDO_CONFIG["EMERGENCY_TRIGGER"];

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (VUHDO_getUnitHealthPercent(tInfo) < tTrigger and VUHDO_isValidEmergency(tUnit)) then
			tinsert(VUHDO_RAID_SORTED, tUnit);
		end
	end

	table.sort(VUHDO_RAID_SORTED,	VUHDO_EMERGENCY_SORTERS[VUHDO_CONFIG["MODE"]]);
	VUHDO_setTopEmergencies(VUHDO_CONFIG["MAX_EMERGENCIES"]);
end



-- Avoid reordering sorting by max-health if someone dies or gets offline
local function VUHDO_getUnitSortMaxHp(aUnit)
	if (VUHDO_RAID[aUnit] ~= nil and VUHDO_RAID[aUnit]["sortMaxHp"] ~= nil and VUHDO_isInFight()) then
		return VUHDO_RAID[aUnit]["sortMaxHp"];
	else
		return VUHDO_RAID[aUnit]["healthmax"];
	end
end



--
local VUHDO_UNIT_AFK_DC = { };
local tIsAfk;
local tIsConnected;
local function VUHDO_updateAfkDc(aUnit)
	tIsAfk = UnitIsAFK(aUnit);
	tIsConnected = UnitIsConnected(aUnit);
	if (tIsAfk or not tIsConnected) then
		if (VUHDO_UNIT_AFK_DC[aUnit] == nil) then
			VUHDO_UNIT_AFK_DC[aUnit] = GetTime();
		end
	else
		VUHDO_UNIT_AFK_DC[aUnit] = nil;
	end

	return tIsAfk, tIsConnected, VUHDO_RAID[aUnit] ~= nil and tIsConnected ~= VUHDO_RAID[aUnit].connected;
end



--
function VUHDO_getAfkDcTime(aUnit)
	return VUHDO_UNIT_AFK_DC[aUnit];
end



--
local tOwner;
function VUHDO_getOwner(aUnit, anIsPet)
	if (anIsPet) then
		tOwner = gsub(aUnit, "pet", "");
		if ("" == tOwner) then
			return "player";
		else
			return tOwner;
		end
	else
		return nil;
	end
end
local VUHDO_getOwner = VUHDO_getOwner;



--
local function VUHDO_isUnitCharmed(aUnit)
	return UnitIsCharmed(aUnit) and UnitCanAttack("player", aUnit);
end



-- Sets a Member info into raid array
local tUnitId;
local tIsPet;
local tClassName;
local tPowerType;
local tIsAfk, tIsConnected;
local tLocalClass;
local tIsDead;
local tClassId;
local tInfo;
local tNewHealth;
local tName, tRealm;
local tIsDcChange;
local function VUHDO_setHealth(aUnit, aMode)

	tInfo = VUHDO_RAID[aUnit];

	if (4 == aMode and tInfo ~= nil) then -- VUHDO_UPDATE_DEBUFF
		tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(aUnit, tInfo.class);
		return;
	end

	tUnitId, _, _ = VUHDO_getUnitIds();
	tIsPet = strfind(aUnit, "pet", 1, true) ~= nil;

	if (strfind(aUnit, tUnitId, 1, true) ~= nil
			or tIsPet
			or aUnit == "player"
			or aUnit == "focus"
			or aUnit == "target") then

		tIsDead = UnitIsDeadOrGhost(aUnit);
		if (tIsDead) then
			VUHDO_removeAllDebuffIcons(aUnit);
			VUHDO_removeHots(aUnit);
		end

		if (VUHDO_UPDATE_ALL == aMode) then
			tLocalClass, tClassName = UnitClass(aUnit);
			tPowerType = UnitPowerType(aUnit);
			tIsAfk, tIsConnected, _ = VUHDO_updateAfkDc(aUnit);

			if (VUHDO_RAID[aUnit] == nil) then
				VUHDO_RAID[aUnit] = { };
			end
			tInfo = VUHDO_RAID[aUnit];
			tInfo["ownerUnit"] = VUHDO_getOwner(aUnit, tIsPet);

			if (tIsPet and tClassId ~= nil) then
				if (VUHDO_USER_CLASS_COLORS.petClassColor and VUHDO_RAID[tInfo["ownerUnit"]] ~= nil) then
					tClassId = VUHDO_RAID[tInfo["ownerUnit"]]["classId"] or VUHDO_ID_PETS;
				else
					tClassId = VUHDO_ID_PETS;
				end
			else
				tClassId = VUHDO_CLASS_IDS[tClassName];
			end

			tName, tRealm = UnitName(aUnit);
			tInfo["healthmax"] = UnitHealthMax(aUnit);
			tInfo["health"] = UnitHealth(aUnit);
			tInfo["name"] = tName;
			tInfo["number"] = VUHDO_getUnitNo(aUnit);
			tInfo["unit"] = aUnit;
			tInfo["class"] = tClassName;
			tInfo["range"] = VUHDO_isInRange(aUnit);
			tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(aUnit, tClassName);
			tInfo["isPet"] = tIsPet;
			tInfo["powertype"] = tonumber(tPowerType);
			tInfo["power"] = UnitMana(aUnit);
			tInfo["powermax"] = UnitManaMax(aUnit);
			tInfo["charmed"] = VUHDO_isUnitCharmed(aUnit);
			tInfo["aggro"] = false;
			tInfo["group"] = VUHDO_getUnitGroup(aUnit, tIsPet);
			tInfo["dead"] = tIsDead;
			tInfo["afk"] = tIsAfk;
			tInfo["connected"] = tIsConnected;
			tInfo["threat"] = UnitThreatSituation(aUnit);
			tInfo["threatPerc"] = 0;
			tInfo["isVehicle"] = UnitInVehicle(aUnit) and UnitHasVehicleUI(aUnit);
			tInfo["className"] = tLocalClass or "";
			tInfo["petUnit"] = VUHDO_getPetUnit(aUnit);
			tInfo["targetUnit"] = VUHDO_getTargetUnit(aUnit);
			tInfo["classId"] = tClassId;
			tInfo["sortMaxHp"] = VUHDO_getUnitSortMaxHp(aUnit);
			tInfo["role"] = VUHDO_determineRole(aUnit);

			if (tRealm ~= nil and strlen(tRealm) > 0) then
				tInfo["fullName"] = tName .. "-" .. tRealm;
			else
				tInfo["fullName"] = tName;
			end
			tInfo["raidIcon"] = GetRaidTargetIndex(aUnit);
			tInfo["visible"] = UnitIsVisible(aUnit); -- Reihenfolge beachten
			tInfo["zone"], tInfo["map"] = VUHDO_getUnitZoneName(aUnit); -- ^^
			tInfo["baseRange"] = UnitInRange(aUnit);
			--tInfo["missbuff"] = nil;
			--tInfo["mibucateg"] = nil;
			--tInfo["mibuvariants"] = nil;

			if (aUnit ~= "focus" and aUnit ~= "target") then
				if (not tIsPet and tInfo["fullName"] == tName and VUHDO_RAID_NAMES[tName] ~= nil) then
					VUHDO_IS_SUSPICIOUS_ROSTER = true;
				end

				-- ensure not to overwrite a player name with a pet's identical name
				if (VUHDO_RAID_NAMES[tName] == nil or not tIsPet) then
					VUHDO_RAID_NAMES[tName] = aUnit;
				end
			end

		elseif (tInfo ~= nil) then
			tIsAfk, tInfo["connected"], tIsDcChange = VUHDO_updateAfkDc(aUnit);

			if (tIsDcChange) then
				VUHDO_updateBouquetsForEvent(aUnit, VUHDO_UPDATE_DC);
			end

			if(VUHDO_UPDATE_HEALTH == aMode) then
				tNewHealth = UnitHealth(aUnit);
				if (not tIsDead) then
					tInfo["lifeLossPerc"] = tNewHealth / tInfo.health;
				end

				tInfo.health = tNewHealth;

				if (tInfo.dead ~= tIsDead) then
					if (tInfo.dead and not tIsDead) then
						tInfo.healthmax = UnitHealthMax(aUnit);
					end
					tInfo.dead = tIsDead;
					VUHDO_updateHealthBarsFor(aUnit, VUHDO_UPDATE_ALIVE);
					VUHDO_updateBouquetsForEvent(aUnit, VUHDO_UPDATE_ALIVE);
				end
			elseif(VUHDO_UPDATE_HEALTH_MAX == aMode) then
				tInfo.dead = tIsDead;
				tInfo.healthmax = UnitHealthMax(aUnit);
				tInfo.sortMaxHp = VUHDO_getUnitSortMaxHp(aUnit);
			elseif(VUHDO_UPDATE_AFK == aMode) then
				tInfo.afk = tIsAfk;
			end
		end
	end
end



--
local function VUHDO_setHealthSafe(aUnit, aMode)
	if (UnitExists(aUnit)) then
		VUHDO_setHealth(aUnit, aMode);
	end
end



-- Callback for UNIT_HEALTH / UNIT_MAXHEALTH events
local tUnit;
local tOwner;
local tIsPet;
function VUHDO_updateHealth(aUnit, aMode)
	tIsPet = VUHDO_RAID[aUnit]["isPet"];

	if (not tIsPet or VUHDO_INTERNAL_TOGGLES[26]) then -- VUHDO_UPDATE_PETS  -- Enth„lt nur Pets als eigene Balken, vehicles werden ber owner dargestellt s.unten
		VUHDO_setHealth(aUnit, aMode);
		VUHDO_updateHealthBarsFor(aUnit, aMode);
	end

	if (tIsPet) then
		tOwner = VUHDO_RAID[aUnit].ownerUnit;
		if (tOwner ~= nil and VUHDO_RAID[tOwner].isVehicle) then
			VUHDO_setHealth(tOwner, aMode);
			VUHDO_updateHealthBarsFor(tOwner, aMode);
		end
	end

	if (1 ~= VUHDO_CONFIG["MODE"] -- VUHDO_MODE_NEUTRAL
		and (VUHDO_UPDATE_HEALTH == aMode or VUHDO_UPDATE_HEALTH_MAX == aMode)) then
		-- Remove old emergencies
		VUHDO_FORCE_RESET = true;
		for tUnit, _ in pairs(VUHDO_EMERGENCIES) do
			VUHDO_updateHealthBarsFor(tUnit, VUHDO_UPDATE_EMERGENCY);
		end
		VUHDO_sortEmergencies();
		-- Set new Emergencies
		VUHDO_FORCE_RESET = false;
		for tUnit, _ in pairs(VUHDO_EMERGENCIES) do
			VUHDO_updateHealthBarsFor(tUnit, VUHDO_UPDATE_EMERGENCY);
		end
	end
end



--
local tUnit, tInfo, tIcon;
function VUHDO_updateAllRaidTargetIndices()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tIcon = GetRaidTargetIndex(tUnit);
		if (tInfo["raidIcon"] ~= tIcon) then
			tInfo["raidIcon"] = tIcon;
			VUHDO_updateBouquetsForEvent(tUnit, VUHDO_UPDATE_RAID_TARGET);
		end
	end
end



-- Add to groups 1-8
local tOwnGroup;
local function VUHDO_addUnitToGroup(aUnit, aGroupNum)
	if (aUnit == "player" and VUHDO_CONFIG["OMIT_SELF"]) then
		return;
	end

	tOwnGroup = VUHDO_PLAYER_GROUP;
	if (not VUHDO_CONFIG["OMIT_OWN_GROUP"] or aGroupNum ~= tOwnGroup) then
		if (VUHDO_GROUPS[aGroupNum] == nil) then
			VUHDO_GROUPS[aGroupNum] = { };
		end
		tinsert(VUHDO_GROUPS[aGroupNum], aUnit);
	end

	if (tOwnGroup == aGroupNum) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_GROUP_OWN], aUnit);
	end
end



--
local function VUHDO_addUnitToClass(aUnit, aClassId)
	if (aClassId == nil) then
		return;
	end

	if (aUnit == "player" and VUHDO_CONFIG["OMIT_SELF"]) then
		return;
	end

	tinsert(VUHDO_GROUPS[aClassId], aUnit);
	tinsert(VUHDO_BUFF_GROUPS[VUHDO_ID_CLASSES[aClassId] or "WARRIOR"], aUnit);
end



--
local tCnt, tModel;
function VUHDO_isModelConfigured(aModelId)
	for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
		if (VUHDO_PANEL_MODELS[tCnt] ~= nil) then
			for _, tModel in ipairs(VUHDO_PANEL_MODELS[tCnt]) do
				if (aModelId == tModel) then
					return true;
				end
			end
		end
	end

  return false;
end
local VUHDO_isModelConfigured = VUHDO_isModelConfigured;



--
local tModelId, tAllUnits, tIndex, tUnit;
local function VUHDO_removeUnitFromAllModelsBut(aUnit, aModelId)

	if (not VUHDO_isModelConfigured(aModelId)) then
		return;
	end

	for tModelId, tAllUnits in pairs(VUHDO_GROUPS) do
		if (tModelId ~= VUHDO_ID_MAINTANKS
			and tModelId ~= VUHDO_ID_PRIVATE_TANKS
			and tModelId ~= VUHDO_ID_MAIN_ASSISTS) then
			for tIndex, tUnit in ipairs(tAllUnits) do
				if (tUnit == aUnit) then
					tremove(tAllUnits, tIndex);
				end
			end
		end
	end
end



--
local function VUHDO_removeFromAllMainGroups()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (VUHDO_CONFIG["OMIT_MAIN_TANKS"] and VUHDO_isUnitInModel(tUnit, VUHDO_ID_MAINTANKS)) then
			VUHDO_removeUnitFromAllModelsBut(tUnit, VUHDO_ID_MAINTANKS);
		elseif (VUHDO_CONFIG["OMIT_PLAYER_TARGETS"] and VUHDO_isUnitInModel(tUnit, VUHDO_ID_PRIVATE_TANKS)) then
			VUHDO_removeUnitFromAllModelsBut(tUnit, VUHDO_ID_PRIVATE_TANKS);
		elseif (VUHDO_CONFIG["OMIT_MAIN_ASSIST"] and VUHDO_isUnitInModel(tUnit, VUHDO_ID_MAIN_ASSISTS)) then
			VUHDO_removeUnitFromAllModelsBut(tUnit, VUHDO_ID_MAIN_ASSISTS);
		end
	end
end



--
local tRole, tIsTank;
local function VUHDO_addUnitToSpecial(aUnit)
	tIsTank, _, _ = UnitGroupRolesAssigned(aUnit);
	if (tIsTank and VUHDO_CONFIG["OMIT_DFT_MTS"]) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_MAINTANKS], aUnit);
	end

	if (GetNumRaidMembers() == 0) then
		return;
	end
	_, _, _, _, _, _, _, _, _, tRole, _ = GetRaidRosterInfo(VUHDO_RAID[aUnit]["number"]);

	-- MTs
	if ("MAINTANK" == tRole and not tIsTank) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_MAINTANKS], aUnit);
	-- Main Assist
	elseif ("MAINASSIST" == tRole) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_MAIN_ASSISTS], aUnit);
	end
end



--
local tCnt;
local tUnit;
local function VUHDO_addUnitToCtraMainTanks()
	for tCnt = 1, VUHDO_MAX_MTS do
		tUnit = VUHDO_MAINTANKS[tCnt];
		if (tUnit ~= nil) then
			VUHDO_tableUniqueAdd(VUHDO_GROUPS[VUHDO_ID_MAINTANKS], tUnit);
		end
	end
end



--
local tUnit, tName;
local function VUHDO_addUnitToPrivateTanks()
	if (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET]) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_PRIVATE_TANKS], "target");
	end

	if (not VUHDO_CONFIG["OMIT_FOCUS"]) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_PRIVATE_TANKS], "focus");
	end

	for tName, _ in pairs(VUHDO_PLAYER_TARGETS) do
		tUnit = VUHDO_RAID_NAMES[tName];
		if (tUnit ~= nil) then
			VUHDO_tableUniqueAdd(VUHDO_GROUPS[VUHDO_ID_PRIVATE_TANKS], tUnit);
		else
			VUHDO_PLAYER_TARGETS[tName] = nil;
		end
	end
end



--
local tOwner;
local function VUHDO_addUnitToPets(aPetUnit)
	tOwner = VUHDO_RAID[aPetUnit]["ownerUnit"];

	if (tOwner ~= nil and VUHDO_RAID[tOwner] == nil) then
		return; -- May happen in early raid reloads
	end

	if (tOwner == nil or not VUHDO_RAID[tOwner]["isVehicle"]) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_PETS], aPetUnit);
	end
end



--
local tRole;
local function VUHDO_addUnitToRole(aUnit)
	if (aUnit == "player" and VUHDO_CONFIG["OMIT_SELF"]) then
		return;
	end

	tRole = VUHDO_RAID[aUnit]["role"];

	if (tRole ~= nil) then
		tinsert(VUHDO_GROUPS[tRole], aUnit);

		if(tRole == VUHDO_ID_RANGED_HEAL or tRole == VUHDO_ID_RANGED_DAMAGE) then
			tinsert(VUHDO_GROUPS[VUHDO_ID_RANGED], aUnit);
		elseif(tRole == VUHDO_ID_MELEE_DAMAGE or tRole == VUHDO_ID_MELEE_TANK) then
			tinsert(VUHDO_GROUPS[VUHDO_ID_MELEE], aUnit);
		end
	end
end



--
local tPetUnit;
local function VUHDO_addUnitToVehicles(aUnit)
	tPetUnit = VUHDO_RAID[aUnit].petUnit;
	if (tPetUnit ~= nil) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_VEHICLES], tPetUnit);
	end
end



-- Get an empty array for each group
local tType, tTypeMembers, tMember;
local function VUHDO_initGroupArrays()
	table.wipe(VUHDO_GROUPS);
	table.wipe(VUHDO_BUFF_GROUPS);

	for tType, tTypeMembers in pairs(VUHDO_ID_TYPE_MEMBERS) do
		for _, tMember in pairs(tTypeMembers) do
			VUHDO_GROUPS[tMember] = { };
		end
	end

	VUHDO_BUFF_GROUPS["WARRIOR"] = {};
	VUHDO_BUFF_GROUPS["ROGUE"] = {};
	VUHDO_BUFF_GROUPS["HUNTER"] = {};
	VUHDO_BUFF_GROUPS["PALADIN"] = {};
	VUHDO_BUFF_GROUPS["MAGE"] = {};
	VUHDO_BUFF_GROUPS["WARLOCK"] = {};
	VUHDO_BUFF_GROUPS["SHAMAN"] = {};
	VUHDO_BUFF_GROUPS["DRUID"] = {};
	VUHDO_BUFF_GROUPS["PRIEST"] = {};
	VUHDO_BUFF_GROUPS["DEATHKNIGHT"] = {};
end



--
local tUnit, tInfo;
local function VUHDO_updateGroupArrays()
	VUHDO_initGroupArrays();

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if ("focus" == tUnit or "target" == tUnit) then
			--VUHDO_addUnitToSpecial(tUnit);
		elseif (not tInfo.isPet) then
			VUHDO_addUnitToGroup(tUnit, tInfo.group);
			VUHDO_addUnitToClass(tUnit, tInfo.classId);
			VUHDO_addUnitToVehicles(tUnit);
			VUHDO_addUnitToSpecial(tUnit);
		else
			VUHDO_addUnitToPets(tUnit);
		end
	end
	tinsert(VUHDO_GROUPS[VUHDO_ID_SELF], "player");

	VUHDO_addUnitToCtraMainTanks();
	VUHDO_addUnitToPrivateTanks();

	-- Need MTs for role estimation
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if ("focus" ~= tUnit and "target" ~= tUnit and not tInfo.isPet) then
			VUHDO_addUnitToRole(tUnit);
		end
	end
	VUHDO_removeFromAllMainGroups();
	VUHDO_initDynamicPanelModels();
end



--
local tGroup;
local tUnit;
local function VUHDO_isInSpecialGroup(aUnit, aModelId)
	tGroup = VUHDO_GROUPS[aModelId];
	if (tGroup ~= nil) then
		for _, tUnit in pairs(tGroup) do
			if (aUnit == tUnit) then
				return true;
			end
		end
	end

	return false;
end



--
local tModelType, tModelId, tSpecialModels;
function VUHDO_isUnitInModel(aUnit, aModelId)

	tModelType = VUHDO_getModelType(aModelId);

	if (VUHDO_ID_TYPE_GROUP == tModelType) then
		return aModelId == VUHDO_RAID[aUnit].group;
	elseif(VUHDO_ID_TYPE_CLASS == tModelType) then
		return aModelId == VUHDO_RAID[aUnit].classId;
	elseif(VUHDO_ID_VEHICLES == tModelType) then
		return strfind(aUnit, "PET", 1, true);
	else -- VUHDO_ID_TYPE_SPECIAL
		tSpecialModels = VUHDO_ID_TYPE_MEMBERS[VUHDO_ID_TYPE_SPECIAL];
		for _, tModelId in pairs(tSpecialModels) do
			if (tModelId == aModelId and VUHDO_isInSpecialGroup(aUnit, aModelId)) then
				return true;
			end
		end

		return false;
	end
end
local VUHDO_isUnitInModel = VUHDO_isUnitInModel;



--
local tModelId;
local function VUHDO_isUnitInPanel(aPanelNum, aUnit)
	for _, tModelId in pairs(VUHDO_PANEL_MODELS[aPanelNum]) do
		if (VUHDO_isUnitInModel(aUnit, tModelId)) then
			return true;
		end
	end

	return false;
end



--
local tIndex, tModelId;
function VUHDO_getPanelUnitFirstModel(aPanelNum, aUnit)
	for tIndex, tModelId in ipairs(VUHDO_PANEL_MODELS[aPanelNum]) do
		if (VUHDO_isUnitInModel(aUnit, tModelId)) then
			return tIndex;
		end
	end

	return 9999;
end



--
local tPanelModels;
local tModel;
local function VUHDO_isModelInPanel(aPanelNum, aModelId)
	tPanelModels = VUHDO_PANEL_MODELS[aPanelNum];
	for _, tModel in pairs(tPanelModels) do
		if (aModelId == tModel) then
			return true;
		end
	end

	return false;
end



-- Uniquely buffer all units defined in a panel
local tPanelUnits = { };
local tPanelNum;
local tHasVehicles;
local tVehicleUnit;
local tUnit;
local function VUHDO_updateAllPanelUnits()

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		table.wipe(VUHDO_PANEL_UNITS[tPanelNum]);

		if (VUHDO_PANEL_MODELS[tPanelNum] ~= nil) then
			tHasVehicles = VUHDO_isModelInPanel(tPanelNum, VUHDO_ID_VEHICLES);
			table.wipe(tPanelUnits);
			for tUnit, _ in pairs(VUHDO_RAID) do
				if (VUHDO_isUnitInPanel(tPanelNum, tUnit)) then
					tPanelUnits[tUnit] = tUnit;
				end

				if (tHasVehicles and not VUHDO_RAID[tUnit].isPet) then
					tVehicleUnit =	VUHDO_RAID[tUnit].petUnit;
					if (tVehicleUnit ~= nil) then -- e.g. "focus", "target"
						tPanelUnits[tVehicleUnit] = tVehicleUnit;
					end
				end
			end

			for tIndex, tUnit in pairs(tPanelUnits) do
				tinsert(VUHDO_PANEL_UNITS[tPanelNum], tUnit);
			end
		end
	end
end



--
local tGuid, tUnit, tInfo;
local function VUHDO_updateAllGuids()
	table.wipe(VUHDO_RAID_GUIDS);
	table.wipe(VUHDO_RAID_GUID_NAMES);
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tGuid = UnitGUID(tUnit);
		if (tGuid ~= nil) then
			VUHDO_RAID_GUIDS[tGuid] = tUnit;
			VUHDO_RAID_GUID_NAMES[tGuid] = tInfo.name;
		end
	end
end



--
local tCnt, tName;
local function VUHDO_convertMainTanks()
	-- Discard deprecated
	for tCnt = 1, VUHDO_MAX_MTS do
		tName = VUHDO_MAINTANK_NAMES[tCnt];
		if (tName ~= nil and VUHDO_RAID_NAMES[tName] == nil) then
			VUHDO_MAINTANK_NAMES[tCnt] = nil;
		end
	end

	-- Convert to units instead of names
	table.wipe(VUHDO_MAINTANKS);
	for tCnt, tName in pairs(VUHDO_MAINTANK_NAMES) do
		VUHDO_MAINTANKS[tCnt] = VUHDO_RAID_NAMES[tName];
	end
end



--
local tUnit, tInfo;
local function VUHDO_createIndexedUnits()
	table.wipe(VUHDO_CLUSTER_BASE_RAID);
	VUHDO_resetClusterCoordDeltas();

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (not tInfo["isPet"] -- won't work for pets
				and "focus" ~= tUnit and "target" ~= tUnit) then

			tinsert(VUHDO_CLUSTER_BASE_RAID, tInfo);
		end
	end
end



--
-- Reload all raid members into the raid array e.g. in case of raid roster change

function VUHDO_reloadRaidMembers()
	local i;
	local tPlayer, tPet;
	local tMaxMembers;
	local tUnit, tPetUnit;

	VUHDO_IS_SUSPICIOUS_ROSTER = false;

	if (not UnitExists("player")) then
		VUHDO_IN_COMBAT_RELOG = true;
		VUHDO_updateAllRaidNames();
		-- Do nothing raid roster is not known yet
	elseif (VUHDO_isConfigDemoUsers()) then
		VUHDO_demoSetupResetUsers();
		VUHDO_reloadRaidDemoUsers();
		VUHDO_updateAllRaidNames();
	else
		VUHDO_PLAYER_RAID_ID = VUHDO_getPlayerRaidUnit();
		VUHDO_IN_COMBAT_RELOG = false;
		tUnit, tPetUnit = VUHDO_getUnitIds();

		if ("raid" == tUnit) then
			tMaxMembers = 40;
		elseif ("party" == tUnit) then
			tMaxMembers = 5;
		else
			tMaxMembers = 0;
		end

		table.wipe(VUHDO_RAID);
		table.wipe(VUHDO_RAID_NAMES);

		if (tMaxMembers > 0) then
			for i = 1, tMaxMembers do
				tPlayer = tUnit .. i;
				if (UnitExists(tPlayer) and tPlayer ~= VUHDO_PLAYER_RAID_ID) then
					VUHDO_setHealth(tPlayer, VUHDO_UPDATE_ALL);

					tPet = tPetUnit .. i;
					VUHDO_setHealthSafe(tPet, VUHDO_UPDATE_ALL);
				end
			end

		end

		VUHDO_setHealthSafe("player", VUHDO_UPDATE_ALL);
		VUHDO_setHealthSafe("pet", VUHDO_UPDATE_ALL);
		VUHDO_setHealthSafe("focus", VUHDO_UPDATE_ALL);

		if (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET]) then
			VUHDO_setHealthSafe("target", VUHDO_UPDATE_ALL);
		end
	end

	VUHDO_PLAYER_GROUP = VUHDO_getUnitGroup(VUHDO_PLAYER_RAID_ID, false);

	VUHDO_trimInspected();
	VUHDO_convertMainTanks();
	VUHDO_updateGroupArrays();
	VUHDO_updateAllPanelUnits();
	VUHDO_updateAllGuids();
	VUHDO_updateBuffRaidGroup();
	VUHDO_updateBuffPanel();
	VUHDO_sortEmergencies();
	VUHDO_createIndexedUnits();

	if (VUHDO_IS_SUSPICIOUS_ROSTER) then
		VUHDO_normalRaidReload();
	end
end



--
local i;
local tPlayer, tPet;
local tMaxMembers;
local tUnit, tPetUnit;
local tInfo;
local tIsDcChange;
local tName, tRealm;
function VUHDO_refreshRaidMembers()
	VUHDO_IS_SUSPICIOUS_ROSTER = false;

	if (not UnitExists("player")) then
		VUHDO_IN_COMBAT_RELOG = true;
		VUHDO_updateAllRaidNames();
		-- Do nothing raid roster is not known yet
	elseif (VUHDO_isConfigDemoUsers()) then
		VUHDO_reloadRaidDemoUsers();
		VUHDO_updateAllRaidNames();
	else
		VUHDO_PLAYER_RAID_ID = VUHDO_getPlayerRaidUnit();
		VUHDO_IN_COMBAT_RELOG = false;
		tUnit, tPetUnit = VUHDO_getUnitIds();

		if ("raid" == tUnit) then
			tMaxMembers = 40;
		elseif ("party" == tUnit) then
			tMaxMembers = 5;
		else
			tMaxMembers = 0;
		end

		table.wipe(VUHDO_RAID_NAMES); -- für VUHDO_SUSPICIOUS_RAID_ROSTER

    if (not VUHDO_isInFight()) then
  		for tPlayer, _ in pairs(VUHDO_RAID) do
  			if (not UnitExists(tPlayer)
  			  or tPlayer == VUHDO_PLAYER_RAID_ID -- bei raid roster wechsel kann unsere raid id vorher wem anders geh”rt haben
  				or (not strfind(tPlayer, tUnit, 1, true) and not strfind(tPlayer, tPetUnit, 1, true))) then -- Falls Gruppe<->Raid
  				VUHDO_RAID[tPlayer] = nil;
  			end
  		end
  	end

		if (tMaxMembers > 0) then
			for i = 1, tMaxMembers do
				tPlayer = tUnit .. i;
				if (UnitExists(tPlayer) and tPlayer ~= VUHDO_PLAYER_RAID_ID) then
					tInfo = VUHDO_RAID[tPlayer];
					if (tInfo == nil or VUHDO_RAID_GUIDS[UnitGUID(tPlayer)] ~= tPlayer) then
						VUHDO_setHealth(tPlayer, VUHDO_UPDATE_ALL);
					else
						tInfo["group"] = VUHDO_getUnitGroup(tPlayer, false);
						tInfo["isVehicle"] = UnitInVehicle(tPlayer) and UnitHasVehicleUI(tPlayer);
						tInfo["role"] = VUHDO_determineRole(tPlayer); -- weil talent-scanner nach und nach arbeitet
      			tInfo["afk"], tInfo["connected"], tIsDcChange = VUHDO_updateAfkDc(tPlayer);
						tInfo["range"] = VUHDO_isInRange(tPlayer);

      			tName, tRealm = UnitName(tPlayer);
						tInfo["name"] = tName;
						if (tRealm ~= nil and strlen(tRealm) > 0) then
							tInfo["fullName"] = tName .. "-" .. tRealm;
						else
							tInfo["fullName"] = tName;
							if (VUHDO_RAID_NAMES[tName] ~= nil) then
								VUHDO_IS_SUSPICIOUS_ROSTER = true;
							end
						end
						VUHDO_RAID_NAMES[tName] = tPlayer;

      			if (tIsDcChange) then
      				VUHDO_updateBouquetsForEvent(tPlayer, VUHDO_UPDATE_DC);
      			end
					end

					tPet = tPetUnit .. i;
					VUHDO_setHealthSafe(tPet, VUHDO_UPDATE_ALL);
				end
			end

		end
		VUHDO_setHealthSafe("player", VUHDO_UPDATE_ALL);
		VUHDO_setHealthSafe("pet", VUHDO_UPDATE_ALL);
		VUHDO_setHealthSafe("focus", VUHDO_UPDATE_ALL);
		if (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET]) then
			VUHDO_setHealthSafe("target", VUHDO_UPDATE_ALL);
    end

	end
	VUHDO_PLAYER_GROUP = VUHDO_getUnitGroup(VUHDO_PLAYER_RAID_ID, false);

	VUHDO_updateAllRaidNames();
	VUHDO_trimInspected();
	VUHDO_convertMainTanks();
	VUHDO_updateGroupArrays();
	VUHDO_updateAllPanelUnits();
	VUHDO_updateAllGuids();
	VUHDO_updateBuffRaidGroup();
	VUHDO_sortEmergencies();
	VUHDO_createIndexedUnits();

	if (VUHDO_IS_SUSPICIOUS_ROSTER) then
		VUHDO_lateRaidReload();
	end
end



--
local VUHDO_CURR_PLAYER_TARGET = nil;
local tTargetUnit, tUnit;
local tOldTarget;
local tInfo;
local tEmptyInfo = { };
function VUHDO_updatePlayerTarget()
	tTargetUnit = nil;
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (UnitIsUnit("target", tUnit) and tUnit ~= "focus" and tUnit ~= "target") then
			if (tInfo.isPet and (VUHDO_RAID[tInfo.ownerUnit] or tEmptyInfo).isVehicle) then
				tTargetUnit = tInfo.ownerUnit;
			else
				tTargetUnit = tUnit;
			end
		end
	end
	tOldTarget = VUHDO_CURR_PLAYER_TARGET;
	VUHDO_CURR_PLAYER_TARGET = tTargetUnit; -- Wg. callback erst umkopieren
	VUHDO_updateBouquetsForEvent(tOldTarget, VUHDO_UPDATE_TARGET);
	VUHDO_updateBouquetsForEvent(tTargetUnit, VUHDO_UPDATE_TARGET);

	if (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET]) then
		if (UnitExists("target")) then
			VUHDO_setHealth("target", VUHDO_UPDATE_ALL);
		else
			VUHDO_removeHots("target");
			VUHDO_removeAllDebuffIcons("target");
			VUHDO_updateTargetBars("target");
			VUHDO_RAID["target"] = nil;
		end

	  VUHDO_updateHealthBarsFor("target", VUHDO_UPDATE_ALL);
		VUHDO_REMOVE_HOTS = false;
	  VUHDO_updateAllRaidBars();
		VUHDO_initAllEventBouquets();
	end
end



--
local tAllButtons, tButton, tBorder;
function VUHDO_barBorderBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact)
	tAllButtons =  VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			tBorder = VUHDO_getPlayerTargetFrame(tButton);
			if (aColor ~= nil) then
				tBorder:SetFrameLevel(tButton:GetFrameLevel() + (anImpact or 0));
				tBorder:SetBackdropBorderColor(aColor.R, aColor.G, aColor.B, aColor.O);
				tBorder:Show();
			else
				tBorder:Hide();
			end
		end
	end
end



--
function VUHDO_getCurrentPlayerTarget()
	return VUHDO_CURR_PLAYER_TARGET;
end

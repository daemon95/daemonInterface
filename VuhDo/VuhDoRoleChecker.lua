
VUHDO_MANUAL_ROLES = { };
local VUHDO_FIX_ROLES = { };
local VUHDO_INSPECTED_ROLES = { };
local VUHDO_INSPECT_TIMEOUT = 5;

local tPoints1, tPoints2, tPoints3, tRank;
VUHDO_NEXT_INSPECT_UNIT = nil;
VUHDO_NEXT_INSPECT_TIME_OUT = nil;



--------------------------------------------------------------
local table = table;
local CheckInteractDistance = CheckInteractDistance;
local UnitIsUnit = UnitIsUnit;
local NotifyInspect = NotifyInspect;
local GetActiveTalentGroup = GetActiveTalentGroup;
local GetTalentTabInfo = GetTalentTabInfo;
local ClearInspectPlayer = ClearInspectPlayer;
local UnitBuff = UnitBuff;

local VUHDO_MANUAL_ROLES;
local VUHDO_RAID_NAMES;
local VUHDO_RAID;
local sIsRolesConfigured;

function VUHDO_roleCheckerInitBurst()
	VUHDO_MANUAL_ROLES = VUHDO_GLOBAL["VUHDO_MANUAL_ROLES"];
	VUHDO_RAID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_NAMES"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	sIsRolesConfigured =
		VUHDO_isModelConfigured(VUHDO_ID_MELEE_TANK)
		or VUHDO_isModelConfigured(VUHDO_ID_MELEE_DAMAGE)
		or VUHDO_isModelConfigured(VUHDO_ID_RANGED_DAMAGE)
		or VUHDO_isModelConfigured(VUHDO_ID_RANGED_HEAL)
		or VUHDO_isModelConfigured(VUHDO_ID_MELEE)
		or VUHDO_isModelConfigured(VUHDO_ID_RANGED);
end
--------------------------------------------------------------



-- Reset if spec changed or slash command
function VUHDO_resetTalentScan(aUnit)
	if (aUnit == nil) then
		table.wipe(VUHDO_INSPECTED_ROLES);
		table.wipe(VUHDO_FIX_ROLES);
	else
		if (VUHDO_PLAYER_RAID_ID == aUnit) then
			aUnit = "player";
		end

		local tInfo = VUHDO_RAID[aUnit];
		if (tInfo ~= nil) then
			VUHDO_INSPECTED_ROLES[tInfo.name] = nil;
			VUHDO_FIX_ROLES[tInfo.name] = nil;
		end
	end
end



--
local tName;
function VUHDO_trimInspected()
	for tName, _ in pairs(VUHDO_INSPECTED_ROLES) do
		if (VUHDO_RAID_NAMES[tName] == nil) then
			VUHDO_INSPECTED_ROLES[tName] = nil;
			VUHDO_FIX_ROLES[tName] = nil;
		end
	end
end



-- If timeout after talen tree server request
function VUHDO_setRoleUndefined(aUnit)
	local tInfo = VUHDO_RAID[aUnit];
	if (tInfo ~= nil) then
		VUHDO_INSPECTED_ROLES[tInfo.name] = nil;
	end
end



--
local tInfo;
local tClass;
local function VUHDO_shouldBeInspected(aUnit)
	if ("focus" == aUnit or "target" == aUnit) then
		return false;
	end

	tInfo = VUHDO_RAID[aUnit];
	if (tInfo.isPet or not tInfo.connected) then
		return false;
	end

	tClass = tInfo.classId;
	if (VUHDO_ID_ROGUES == tClass
		or VUHDO_ID_HUNTERS == tClass
		or VUHDO_ID_MAGES == tClass
		or VUHDO_ID_WARLOCKS == tClass
		or VUHDO_ID_DEATH_KNIGHT == tClass) then
		return false;
	end

	if (VUHDO_INSPECTED_ROLES[tInfo.name] ~= nil) then
		return false;
	end

	if (not CheckInteractDistance(aUnit, 1)) then
		return false;
	end

	return true;
end



--
local tUnit;
function VUHDO_tryInspectNext()
	for tUnit, _ in pairs(VUHDO_RAID) do
		if (VUHDO_shouldBeInspected(tUnit)) then
			VUHDO_NEXT_INSPECT_TIME_OUT = GetTime() + VUHDO_INSPECT_TIMEOUT;
			VUHDO_NEXT_INSPECT_UNIT = tUnit;
			if ("player" == tUnit) then
				VUHDO_inspectLockRole();
			else
				NotifyInspect(tUnit);
			end

			return;
		end
	end
end



--
local tIcon1, tIcon2, tIcon3;
local tActiveTree;
local tIsInspect;
local tInfo;
function VUHDO_inspectLockRole()
	tInfo = VUHDO_RAID[VUHDO_NEXT_INSPECT_UNIT];

	if (tInfo == nil) then
		VUHDO_NEXT_INSPECT_UNIT = nil;
		return;
	end

	tIsInspect = "player" ~= tInfo.unit;

	tActiveTree = GetActiveTalentGroup(tIsInspect);
	_, tIcon1, tPoints1, _ = GetTalentTabInfo(1, tIsInspect, false, tActiveTree);
	_, tIcon2, tPoints2, _ = GetTalentTabInfo(2, tIsInspect, false, tActiveTree);
	_, tIcon3, tPoints3, _ = GetTalentTabInfo(3, tIsInspect, false, tActiveTree);

	if (VUHDO_ID_PRIESTS == tInfo.classId) then
		-- 1 = Disc, 2 = Holy, 3 = Shadow
		if (tPoints1 > tPoints3
		or tPoints2 > tPoints3)	 then
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_RANGED_HEAL;
		else
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_RANGED_DAMAGE;
		end

	elseif (VUHDO_ID_WARRIORS == tInfo.classId) then
		-- Waffen, Furor, Schutz
		if (tPoints1 > tPoints3
		or tPoints2 > tPoints3)	 then
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_MELEE_DAMAGE;
		else
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_MELEE_TANK;
		end

	elseif (VUHDO_ID_DRUIDS == tInfo.classId) then
		-- 1 = Gleichgewicht, 2 = Wilder Kampf, 3 = Wiederherstellung
		if (tPoints1 > tPoints2 and tPoints1 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_RANGED_DAMAGE;
		elseif(tPoints3 > tPoints2) then
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_RANGED_HEAL;
		else
			-- "Natürliche Reaktion" geskillt => Wahrsch. Tank?
			_, _, _, _, tRank, _, _, _ = GetTalentInfo(2, 16, tIsInspect, false, tActiveTree);
			if (tRank > 0) then
				VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_MELEE_TANK;
			else
				VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_MELEE_DAMAGE;
			end
		end

	elseif (VUHDO_ID_PALADINS == tInfo.classId) then
		-- 1 = Heilig, 2 = Schutz, 3 = Vergeltung
		if (tPoints1 > tPoints2 and tPoints1 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_RANGED_HEAL;
		elseif (tPoints2 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_MELEE_TANK;
		else
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_MELEE_DAMAGE;
		end

	elseif (VUHDO_ID_SHAMANS == tInfo.classId) then
	  -- 1 = Elementar, 2 = Verstärker, 3 = Wiederherstellung
		if (tPoints1 > tPoints2 and tPoints1 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_RANGED_DAMAGE;
		elseif (tPoints2 > tPoints3) then
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_MELEE_DAMAGE;
		else
			VUHDO_INSPECTED_ROLES[tInfo.name] = VUHDO_ID_RANGED_HEAL;
		end
	end

	ClearInspectPlayer();
	VUHDO_NEXT_INSPECT_UNIT = nil;
	if (sIsRolesConfigured) then
		VUHDO_normalRaidReload();
	else
		VUHDO_refreshRaidMembers();
		--VUHDO_reloadRaidMembers();
	end
end



--
local tName;
local tInfo;
local tDefense;
local tPowerType;
local tBuffExist;
local tFixRole;
local tIntellect, tStrength, tAgility;
function VUHDO_determineRole(aUnit)
	tInfo = VUHDO_RAID[aUnit];

	if (tInfo == nil or tInfo.isPet) then
		return nil, nil;
	end

	if (VUHDO_ID_ROGUES == tInfo.classId) then
		return VUHDO_ID_MELEE_DAMAGE;
	elseif (VUHDO_ID_HUNTERS == tInfo.classId) then
		return VUHDO_ID_RANGED_DAMAGE;
	elseif (VUHDO_ID_MAGES == tInfo.classId) then
		return VUHDO_ID_RANGED_DAMAGE;
	elseif (VUHDO_ID_WARLOCKS == tInfo.classId) then
		return VUHDO_ID_RANGED_DAMAGE;
	end

	tFixRole = VUHDO_MANUAL_ROLES[tInfo.name];
	if (tFixRole ~= nil) then
		return tFixRole;
	end

 	if (VUHDO_isUnitInModel(aUnit, VUHDO_ID_MAINTANKS)) then
		return VUHDO_ID_MELEE_TANK;
 	end

	tName = tInfo.name;
	if (VUHDO_INSPECTED_ROLES[tName] ~= nil) then
		return VUHDO_INSPECTED_ROLES[tName];
	end

	if (VUHDO_FIX_ROLES[tName] ~= nil) then
		return VUHDO_FIX_ROLES[tName];
	end


	if (VUHDO_ID_DEATH_KNIGHT == tInfo.classId) then
		_, _, tBuffExist = UnitBuff(aUnit, VUHDO_SPELL_ID_BUFF_FROST_PRESENCE);
		if (tBuffExist) then
			VUHDO_FIX_ROLES[tInfo.name] = VUHDO_ID_MELEE_TANK;
			return VUHDO_ID_MELEE_TANK;
		else
			VUHDO_FIX_ROLES[tInfo.name] = VUHDO_ID_MELEE_DAMAGE;
			return VUHDO_ID_MELEE_DAMAGE;
		end

	elseif (VUHDO_ID_PRIESTS == tInfo.classId) then
		_, _, tBuffExist = UnitBuff(aUnit, VUHDO_SPELL_ID_SHADOWFORM);
		if (tBuffExist) then
			VUHDO_FIX_ROLES[tInfo.name] = VUHDO_ID_RANGED_DAMAGE;
			return VUHDO_ID_RANGED_DAMAGE;
		else
			return VUHDO_ID_RANGED_HEAL;
		end

	elseif (VUHDO_ID_WARRIORS == tInfo.classId) then
		_, tDefense = UnitDefense(aUnit);
		tDefense = tDefense / UnitLevel(aUnit);

		if (tDefense > 2 or VUHDO_isUnitInModel(aUnit, VUHDO_ID_MAINTANKS)) then
			return VUHDO_ID_MELEE_TANK;
		else
			return VUHDO_ID_MELEE_DAMAGE;
		end

	elseif (VUHDO_ID_DRUIDS == tInfo.classId) then
		tPowerType = UnitPowerType(aUnit);
		if (VUHDO_UNIT_POWER_MANA == tPowerType) then
			_, _, tBuffExist = UnitBuff(aUnit, VUHDO_SPELL_ID_MOONKIN_FORM);
			if (tBuffExist) then
				VUHDO_FIX_ROLES[tInfo.name] = VUHDO_ID_RANGED_DAMAGE;
				return VUHDO_ID_RANGED_DAMAGE;
			else
				_, _, tBuffExist = UnitBuff(aUnit, VUHDO_SPELL_ID_TREE_OF_LIFE);
				if (tBuffExist) then
					VUHDO_FIX_ROLES[tInfo.name] = VUHDO_ID_RANGED_HEAL;
				end

				return VUHDO_ID_RANGED_HEAL;
			end
		elseif (VUHDO_UNIT_POWER_RAGE == tPowerType) then
			VUHDO_FIX_ROLES[tInfo.name] = VUHDO_ID_MELEE_TANK;
			return VUHDO_ID_MELEE_TANK;
		elseif (VUHDO_UNIT_POWER_ENERGY == tPowerType) then
			VUHDO_FIX_ROLES[tInfo.name] = VUHDO_ID_MELEE_DAMAGE;
			return VUHDO_ID_MELEE_DAMAGE;
		end

	elseif (VUHDO_ID_PALADINS == tInfo.classId) then
		_, tDefense = UnitDefense(aUnit);
		tDefense = tDefense / UnitLevel(aUnit);

		if (tDefense > 2) then
			return VUHDO_ID_MELEE_TANK;
		else
			tIntellect = UnitStat(aUnit, 4);
			tStrength = UnitStat(aUnit, 1);

			if (tIntellect > tStrength) then
				return VUHDO_ID_RANGED_HEAL;
			else
				return VUHDO_ID_MELEE_DAMAGE;
			end
		end

	elseif (VUHDO_ID_SHAMANS == tInfo.classId) then
		tIntellect = UnitStat(aUnit, 4);
		tAgility = UnitStat(aUnit, 2);

		if (tAgility > tIntellect) then
			return VUHDO_ID_MELEE_DAMAGE;
		else
			return VUHDO_ID_RANGED_HEAL; -- Can't tell, assume its a healer
		end
	end

	return nil;
end

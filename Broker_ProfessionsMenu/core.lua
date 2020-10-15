------------------------------------------------------------------------------
-- Broker_ProfessionsMenu                                                   --
-- Author: Yargoro@Arathor-EU												--
-- Former Author: Sanori/Pathur                                             --
------------------------------------------------------------------------------
local _,ADDON = nil,select(2,...)				--Includes all functions and variables

ADDON = LibStub("AceAddon-3.0"):NewAddon(ADDON,ADDON.name,"AceEvent-3.0","AceTimer-3.0", "AceBucket-3.0")--,"AceHook-3.0")

--<< Include libs >>--
ADDON.L = LibStub("AceLocale-3.0"):GetLocale(ADDON.name)
ADDON.dropdown = LibStub:GetLibrary('LibDewdrop-3.0')		--Dropdownmenu
ADDON.LDB = LibStub:GetLibrary("LibDataBroker-1.1")			--Data Broker
ADDON.TipHooker = LibStub:GetLibrary("LibTipHooker-1.1")	--Tooltip mod
ADDON.libst = LibStub:GetLibrary("ScrollingTable")			--include lib
ADDON.processable = LibStub:GetLibrary("LibProcessable");	--Processable
ADDON.QTip = LibStub:GetLibrary("LibQTip-1.0")				--QTip
ADDON.LibToast = LibStub:GetLibrary("LibToast-1.0")			--Toast

local L = ADDON.L	--addon localization
local C = ADDON.C	--addon common
local D = ADDON.D	--addon debug

--<< Init variables and constants >>--
ADDON.quicklauncher = {}									--Quick Launcher

ADDON.sharedcds = {}										--shared cds
ADDON.LongCDs = {}											--long cds

ADDON.updaterframe = CreateFrame("Frame", nil, UIParent)
ADDON.updaterframe.scanning = false
ADDON.updaterframe:Hide()

ADDON.ignoredquickprofessions = {[7620] = 7620}




BPMAutoloot=nil		
BPMUseAfterCast = nil
										--Global Variable for Auto Loot Script
local my = UnitName("player")								--player name

local colorWhite =  "|cffffffff"
local colorBlack =  "|cff000000"
local colorGreen =  "|cff00ff00"
local colorYellow = "|cffffff00"
local colorOrange = "|cffffd100"

ADDON.classIcons =
{
	DEATHKNIGHT = "Interface\\Icons\\Spell_Deathknight_ClassIcon",
	DRUID = "Interface\\Icons\\INV_Misc_MonsterClaw_04",
	WARLOCK = "Interface\\Icons\\Spell_Nature_FaerieFire",
	HUNTER = "Interface\\Icons\\INV_Weapon_Bow_07",
	MAGE = "Interface\\Icons\\INV_Staff_13",
	PRIEST = "Interface\\Icons\\INV_Staff_30",
	WARRIOR = "Interface\\Icons\\INV_Sword_27",
	SHAMAN = "Interface\\Icons\\Spell_Nature_BloodLust",
	PALADIN = "Interface\\AddOns\\addon\\UI-CharacterCreate-Classes_Paladin",
	ROGUE = "Interface\\AddOns\\addon\\UI-CharacterCreate-Classes_Rogue",
}

ADDON.dropdown.fontsizes = {"8","12","14","16","18","22","36"}

ADDON.pendigRecipes = {}


--<< Translate profession id to the id of rank one (for save purposes) >>---------
ADDON.profidtable={	--format {id of rank 1,rank11,other ids[elixir master, etc.]}   ->   return "id of rank 1", "max skill"
	{2259 ,3101 ,3464 ,11611,28596,51304,80731,105206,156606,195095,264211,		28677,28675,28672}, 	-- Alchemy
	{2018 ,3100 ,3538 ,9785 ,29844,51300,76666,110396,158737,195097,264434		},						-- Blacksmithing
	{7411 ,7412 ,7413 ,13920,28029,51313,74258,110400,158716,195096,			13262},             	-- Enchanting
	{4036 ,4037 ,4038 ,12656,30350,51306,82774,110403,158739,195112,264475,		49383,20219,20222}, 	-- Engineering
	{2366 ,2368 ,3570 ,11993,28695,50300,74519,110413,158745,195114,			2383,193290},       	-- Herbalism (Find Herbs,Herbalism Skills)
	{45357,45358,45359,45360,45361,45363,86008,110417,158748,195115,			51005},             	-- Inscription
	{25229,25230,28894,28895,28897,51311,73318,110420,158750,195116,			31252,265811,264548},	-- Jewelcrafting (Prospecting,Zandalari-jewelcrafting,Kul-tiran-jewelcrafting
	{2108 ,3104 ,3811 ,10662,32549,51302,81199,110423,158752,195119				},						-- Leatherworking
	{2575 ,2576 ,3564 ,10248,29354,50310,74517,102161,158754,195122,			2656,2580},  			-- Mining and Mining Skills
	{8613 ,8617 ,8618 ,10768,32678,50305,74522,102216,158756,195125,			194174},            	-- Skinning and Skinning Skills
	{3908 ,3909 ,3910 ,12180,26790,51309,75156,110426,158758,195126,			59390},             	-- Tailoring
	{78670,88961,89718,89719,89720,89721,89722,110393,158762,195127,278910,		80451},             	-- Archaeology
	{2550 ,3102 ,3413 ,18260,33359,51296,88053,104381,158765,195128,			818},               	-- Cooking
	{3273 ,3274 ,7924 ,10846,27028,45542,74559,110406,158741,195113				},                  	-- First Aid
	{7620,7731,7732,18248,33095,51294,88868,110410,131474,131476,131490,158743,210829},		-- Fishing
--	{53428}																					-- Runeforging
}

--lookup table to convert tradeskill skillId to professionId (rank 1)
local SkillIdToProfIdtable =
{
	[171] = 2259,  --"Alchemy",
	[164] = 2018,  --"Blacksmithing",
	[333] = 7411,  --"Enchanting",
	[202] = 4036,  --"Engineering",
	[182] = 2366,  --"Herbalism",
	[773] = 45357, --"Inscription",
	[755] = 25229, --"Jewelcrafting",
	[165] = 2108,  --"Leatherworking",
	[186] = 2575,  --"Mining",
	[393] = 8613,  --"Skinning",
	[197] = 3908,  --"Tailoring",
	[185] = 2550,  --"Cooking",
	[129] = 3273,  --"First Aid"
	[356] = 7620,  --"Fishing" 
	[794] = 78670, --"Archaeology", own frame not tradeskill frame link id == zero
--	[960] = 53428, -- RuneForging
}

--<< Key short cuts >>--
ADDON.keys = {														--Keys
	{['Key']='left',       ['Button']=L.leftclick},
	{['Key']='shiftleft',  ['Button']=L.leftclick,  ['Mod']=L.shift},
	{['Key']='altleft',    ['Button']=L.leftclick,  ['Mod']=L.alt},
	{['Key']='ctrlleft',   ['Button']=L.leftclick,  ['Mod']=L.ctrl},
	{['Key']='right',      ['Button']=L.rightclick},
	{['Key']='shiftright', ['Button']=L.rightclick, ['Mod']=L.shift},
	{['Key']='altright',   ['Button']=L.rightclick, ['Mod']=L.alt},
	{['Key']='ctrlright',  ['Button']=L.rightclick, ['Mod']=L.ctrl},
}

function ADDON:KeyDownIndex(button)							--Index der gedrückten Tastenkombination
	local shift = IsShiftKeyDown();
	local ctrl  = IsControlKeyDown();
	local alt   = IsAltKeyDown();
	if (button=='LeftButton' and not shift and not ctrl and not alt) then return 1 end
	if (button=='LeftButton' and shift and not ctrl and not alt) then return 2 end
	if (button=='LeftButton' and not shift and not ctrl and alt) then return 3 end
	if (button=='LeftButton' and not shift and ctrl and not alt) then return 4 end
	if (button=='RightButton' and not shift and not ctrl and not alt) then return 5 end
	if (button=='RightButton' and shift and not ctrl and not alt) then return 6 end
	if (button=='RightButton' and not shift and not ctrl and alt) then return 7 end
	if (button=='RightButton' and not shift and ctrl and not alt) then return 8 end
end

local function split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- Remove key k (and its value) from table t. Return a new (modified) table.
function table.removeKey(t, k)
	local i = 0
	local keys, values = {},{}
	for k,v in pairs(t) do
		i = i + 1
		keys[i] = k
		values[i] = v
	end
 
	while i>0 do
		if keys[i] == k then
			table.remove(keys, i)
			table.remove(values, i)
			break
		end
		i = i - 1
	end
 
	local a = {}
	for i = 1,#keys do
		a[keys[i]] = values[i]
	end
 
	return a
end

function table.getkey( t, value )
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end

--<< Table alphabetical sort function >>----------------------------------------
local function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0                                    --iterator variable
		local iter = function ()                       --iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

--<< Count of table elements >>-------------------------------------------------
local function tcount(tab)
	local n = #tab
	if (n == 0) then
		for _ in pairs(tab) do
			n = n + 1
		end
	end
	return n
end


--------------------------------------------------------------------------------
-- Addon                                                                     --
--------------------------------------------------------------------------------

-- Blizzard Trade Skill fixes (legion changes) 
local function GetTradeSkillLine()
    -- local tradeskillName, currentLevel, maxLevel = GetTradeSkillLine();
    local id, tradeskillName, currentLevel, maxLevel = C_TradeSkillUI.GetTradeSkillLine()
    if tradeskillName ~= nil then
        return tradeskillName, currentLevel, maxLevel
    else
        return 'UNKNOWN', 0, 0
    end
end

local function IsNPCCrafting()
    return C_TradeSkillUI.IsNPCCrafting()
end

local function GetNumTradeSkills()
    return #C_TradeSkillUI.GetAllRecipeIDs() 	--GetFilteredRecipeIDs()
end

local function IsDataSourceChanging()
	return C_TradeSkillUI.IsDataSourceChanging()
end

local function IsTradeSkillReady()
	return C_TradeSkillUI.IsTradeSkillReady()
end

local function IsTradeSkillLinked()
    return C_TradeSkillUI.IsTradeSkillLinked()
end

local function IsTradeSkillGuild()
    return C_TradeSkillUI.IsTradeSkillGuild()
end

local function IsRecipeFavorite(id)
    return C_TradeSkillUI.IsRecipeFavorite(id)
end

local function TradeSkillOnlyShowMakeable()
    return C_TradeSkillUI.SetOnlyShowMakeableRecipes(not C_TradeSkillUI.GetOnlyShowMakeableRecipes())
end

local function TradeSkillOnlyShowSkillUps()
    return C_TradeSkillUI.SetOnlyShowSkillUpRecipes(not C_TradeSkillUI.GetOnlyShowSkillUpRecipes())
end

local function TradeSkillSetFilter(subclass, slot, subName, slotName, subclassCategory)
	C_TradeSkillUI.ClearInventorySlotFilter()
	C_TradeSkillUI.ClearRecipeCategoryFilter()

    if categoryID or subCategoryID then
        C_TradeSkillUI.SetRecipeCategoryFilter(subclass, subclassCategory);
    end
    
    if inventorySlotIndex then
        C_TradeSkillUI.SetInventorySlotFilter(slot, true, true)
    end
end

local function SetTradeSkillItemNameFilter(text)
    C_TradeSkillUI.SetRecipeItemNameFilter(text)
end

local function GetTradeSkillListLink()
    return C_TradeSkillUI.GetTradeSkillListLink()
end

local function GetTradeSkillItemLink(index)
    return C_TradeSkillUI.GetRecipeItemLink(index)
end

local function GetTradeSkillRecipeLink(index)
    return C_TradeSkillUI.GetRecipeLink(index)
end

local function GetTradeSkillInfo(index)
    local info = C_TradeSkillUI.GetRecipeInfo(index)
    -- skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps, indentLevel, showProgressBar, currentRank, maxRank, startingRank
    if info then
        return info.name, info.difficulty, info.numAvailable, false, info.alternateVerb, info.numSkillUps, info.numIndents, false, nil, nil, nil
    end
end

local function GetTradeSkillCooldown(index)
    return C_TradeSkillUI.GetRecipeCooldown(index)
end

local function GetTradeSkillSelectionIndex()
	if not TradeSkillFrame then return 0 end 
	return TradeSkillFrame.RecipeList.selectedRecipeID or 0
end

local function GetFirstTradeSkill()
    local recipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()
    for i, recipeID in ipairs(recipeIDs) do
        return recipeID
    end
end

local function GetTradeSkillNumMade(skillIndex)
    return C_TradeSkillUI.GetRecipeNumItemsProduced(skillIndex)
end

local function GetTradeSkillIcon(skillIndex)
    return C_TradeSkillUI.GetRecipeInfo(skillIndex).icon
end

local function GetTradeSkillDescription(skillIndex)
    return C_TradeSkillUI.GetRecipeDescription(skillIndex)
end

local function GetTradeSkillTools(skillIndex)
    return C_TradeSkillUI.GetRecipeTools(skillIndex)
end

local function GetTradeSkillReagentInfo(skillIndex, i)
    return C_TradeSkillUI.GetRecipeReagentInfo(skillIndex, i)
end

local function GetTradeSkillReagentItemLink(skillIndex, i)
    return C_TradeSkillUI.GetRecipeReagentItemLink(skillIndex, i)
end

--------------------------------------------------------------------------------

ADDON.updaterframe:SetScript("OnUpdate", function(self, elapsed)
	--D:Debug("OnUpdate:")
	if  (IsTradeSkillReady() and not IsDataSourceChanging()) then	--IsDataSourceChanging() is IMPORTANT
		ADDON:ScanTradeSkillFrame()
		ADDON.updaterframe.scanning = false
		self:Hide()
		--D:Debug("OnUpdate HIDE:")
	end
end)

function ADDON:OnInitialize()
	D:Debug("OnInitialize:")

--	self:RegisterEvent("PLAYER_REGEN_ENABLED","OnRegenEnable")
--	self:RegisterEvent("PLAYER_REGEN_DISABLED","OnRegenDisable")
--	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_NAME_UPDATE")
--	self:RegisterBucketEvent("TRADE_SKILL_UPDATE",1)
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("TRADE_SKILL_LIST_UPDATE");

--	self:RegisterEvent("TRAINER_SHOW")
--	self:RegisterEvent("TRAINER_UPDATE")
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_FINISHED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_FINISHED")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterBucketEvent("BAG_UPDATE",0.5)

	--Default values
	if (Broker_ProfessionsMenu == nil) then Broker_ProfessionsMenu = {} end

	Broker_ProfessionsMenu["%TrainerDB%"] = nil
	
	--Copy saves to internal var
	self.save = Broker_ProfessionsMenu[GetRealmName()] or {}

	--default save values
	local defaultsave = 
	{						
		config =
		{
			bothFactions = true,			--show booth fanction in line menu = bool
			menufontsize = "14",			--menu font size = string
			showlastprofinldb = true,
			tooltip =
			{
				showcds = true,
				showcrosscds = true,
				showskills = true,
				showbuttons = true,
				ShowAllTooltips = true,
				ShowIfYouCanCraftThisInItemTooltips = true,
				showexpansionranks = true,
				showexpansionname = true,
			},
		},
		lastprofession = 0,					--last opened profession = number
		cds = {},
		tradeskills = 
		{
			-- --format now
			-- profID =
			-- {
			-- 	data = 
			-- 	{
			-- 		rank = string
			-- 		maxRank = string
			-- 		expansionRanks = 
			-- 		{
			-- 			{
			-- 				name = string,
			-- 				rank = string,
			-- 				maxRank = string,
			-- 			},
			-- 			{
			-- 			...
			-- 			},
			-- 		},
			-- 	},
			-- 	items =
			-- 	{
			-- 		[id] 
			-- 	}
		},
		quicklauncher = {},
		quicklaunch =
		{
			left = 0,
			shiftleft = 0,
			altleft = 0,
			ctrlleft = 0,
			right = "menu",
			shiftright = "fav",
			altright = 0,
			ctrlright = 0,
		},
		favorites = {},
		faction = "",
		class = "",
		ignores = {}, 
        versions = 
        {
            tradeskills = 0,
        }, 
	}

    local versionConvertTable =
    {
        tradeskills =
        {
            -- [0] = function(oldData) --0 to 1
            --         return {"A"}
            --     end,
            -- [1] = function(oldData) --1 to 2
            --         return {"B"}
            --     end,
        },
    }

	--creates a new save table
	local function newsave(tbl, default)
		if (tbl==nil) then return default end		--if tbl is empty, then return default table/value
		if (next(default)==nil) then return tbl end	--if default is empty, then return tbl
		local result = {}
		for k,v in pairs(default) do
			if (tbl[k]==nil or type(v)=='table') then
				result[k] = newsave(tbl[k], v)	--recursive
			else
				result[k] = tbl[k]
			end
		end
		return result
	end

	--update versions 
	local function updateVersions(currentSave,defaultSave,convertTable)
		if not currentSave then 
			D:Debug("updateVersions save is nil")
			return
		end
		D:Debug("checking version..")
        for leaf,latestVersion in pairs(defaultSave.versions) do
            local currentVersion = currentSave.versions and currentSave.versions[leaf] or -1
            local currentData = currentSave[leaf]
            if currentData then
                if currentVersion == -1 then  --drop leaf
                    currentSave[leaf] = C.tableCopy(defaultSave[leaf])
					D:Debug("drop data")
                elseif currentVersion ~= latestVersion then --convert leaf
                    repeat
                        if convertTable[leaf][currentVersion] then
                            currentData = convertTable[leaf][currentVersion](currentData)   --convert one version to another up to latest
							D:Debug("convert data "..currentVersion)
                        end
                        currentVersion = currentVersion + 1  
                    until currentVersion == latestVersion
                    currentSave[leaf] = currentData
                    currentSave.versions[leaf] = latestVersion
                end
			end
		end
    end

--	D:Debug(ADDON.save[my])

	self.save[my] = newsave(self.save[my], defaultsave)

	updateVersions(self.save[my], defaultsave, versionConvertTable)

--	ADDON:tprint(ADDON.save[my])
 	-- SLASH_BROKER_PROFESSIONSMENU1 = "/waitforbpcast";
    -- SlashCmdList["BROKER_PROFESSIONSMENU"] =
	-- function(msg)
	-- 	D:Debug("waitforbpcast called")
	--     while(BPMWaitforcast) do
	-- 	D:Debug("wait fopr cast"),
	-- 	end
	-- end 	
end
	
function ADDON:PLAYER_LOGIN()
	D:Debug("PLAYER_LOGIN")

	if ADDON.debug then
		D:Debug("Addon:"..self.version.." WoW Version:"..select(1, GetBuildInfo()).. " WoW TOC:"..select(4, GetBuildInfo()))
	end

	--Init LibDataBroker
	self:InitLDB()
	
	self.dropdown:SetFontSize(ADDON.save[my].config.menufontsize)

	self.LibToast:Register("TradeSkillToast", function(toast, arg1,arg2)
		toast:SetTitle(colorGreen..L["coodownexpired"])
		toast:SetText(colorYellow..arg1)
		toast:SetIconTexture(arg2) 
--		toast:MakePersistent()
	end)

	--removed old invalidated launhers and Create new Launchers
	local input = ADDON.save[my].quicklauncher
	for k,_ in pairs(input) do
		local profid = ADDON:TransProfID(k)
		if not ADDON:IsProfessionAvailable(profid) then 
			ADDON.save[my].quicklauncher = table.removeKey(ADDON.save[my].quicklauncher,k)
			D:Debug("removed invalid quicklauncher:"..ADDON:GetProfName(profid))
		end
	end

	for k,_ in pairs(ADDON.save[my].quicklauncher) do
		ADDON.quicklauncher[k]=ADDON:newlauncher(k)
	end

	--Modifying Atlasloot Recept Tooltips
	if AtlasLootTooltip then
		AtlasLootTooltip:HookScript("OnTooltipSetSpell", function(self, ...)
			ADDON:modifytooltip(self,select(3,self:GetSpell()))
		end)
	end

	--save players faction and class
	ADDON.save[my].faction = UnitFactionGroup("player")
	ADDON.save[my].class = select(2,UnitClass("player"))

	--removed zero cds
	for k,v in pairsByKeys(ADDON.save[my].cds) do
		if v <= 0 then
			ADDON.save[my].cds[k] = nil
		end
	end

	--removed empty favorites

	for profid,favs in pairs(ADDON.save[my].favorites) do
		if tcount(favs) == 0 then
			ADDON.save[my].favorites[profid] = nil
		end
	end

	--removed deleted professions

	for profid,_ in pairs(ADDON.save[my].tradeskills) do
		if not ADDON:IsProfessionAvailable(profid) then
			ADDON.save[my].tradeskills[profid] = nil
			D:Debug("Delete profession:"..ADDON:GetProfName(profid))
		end
	end

	self:ScanNonProfessions()
end

function ADDON:PLAYER_LOGOUT()
	D:Debug("PLAYER_LOGOUT")
	Broker_ProfessionsMenu[GetRealmName()] = ADDON.save
end

function ADDON:PLAYER_REGEN_DISABLED()
	D:Debug("PLAYER_REGEN_DISABLED")
end

function ADDON:TRADE_SKILL_SHOW()
	D:Debug("TRADE_SKILL_SHOW")
	self:StartScanning()
end

function ADDON:TRADE_SKILL_NAME_UPDATE()
	D:Debug("TRADE_SKILL_NAME_UPDATE")
end

function ADDON:TRADE_SKILL_LIST_UPDATE()
	D:Debug("TRADE_SKILL_LIST_UPDATE")

	if ADDON:GetCurrentTradeSkillProfID() ~= ADDON.save[my].lastprofession then
		ADDON:StartScanning()
	else
		local idx = GetTradeSkillSelectionIndex()
		if (idx > 0 and not ADDON.updaterframe.scanning and C_TradeSkillUI.GetRecipeInfo(idx)) then 
			ADDON:ScanRecipe(idx)
		end
	end
end

function ADDON:TRADE_SKILL_CLOSE()
 	D:Debug("TRADE_SKILL_CLOSE")
	ADDON:StopScanning()
end

function ADDON:TRADE_SKILL_UPDATE()
	D:Debug("TRADE_SKILL_UPDATE")
end

function ADDON:UNIT_SPELLCAST_START(_,unitID,_,spellID)	--Autoloot and Dropdownmenu Refresh
	D:Debug("UNIT_SPELLCAST_START:%s,%s",unitID,spellID)
--	if unitID == "player" then
--		undercast = true
--	end 
end

function ADDON:UNIT_SPELLCAST_SUCCEEDED(_,unitID,_,spellID)	--Autoloot and Dropdownmenu Refresh
	D:Debug("UNIT_SPELLCAST_SUCCEEDED:%s,%s",unitID,spellID)
	if unitID == "player" then
--		D:Debug("last profid:%u"..ADDON.save[my].lastprofession) --.." IsProfession:"..tostring(ADDON:IsProfession(spellID)).." ProfID:"..ADDON:GetProfID(ADDON.save[my].lastprofession).."spellID:"..ADDON:TransProfID(ADDON:GetProfID(spellID)))
		--D:Debug("scan:"..ADDON:GetProfID(spell))

	-- Archaeology is non profession and not opening trade skill frame,scan after user open Archaeology frame
	local profId,skillId = self:TransProfID(spellID)
	if profId and skillId and skillId == 794 then --"Archaeology
		D:Debug("Archaeology is casted")
		ADDON.save[my].lastprofession = profId
		self:ScanNonProfessions()
		self:RefreshLDBData()
	end

--[[

	if (ADDON.save[my].lastprofession ~=nil) then
		if (ADDON:IsProfession(spell)) then
			D:Debug("Profession trying to switch to:"..spell)
			if (ADDON.save[my].lastprofession ~= ADDON:TransProfID(ADDON:GetProfID(spell))) then
				ADDON:StartScanning()
			end
		elseif (spellID and not ADDON.updaterframe.scanning) then
			ADDON.pendigRecipes[spellID] = true
		end
	end
]]
	    if BPMAutoloot then
			SetCVar('AutoLootDefault', 1)
		end

		if (BPMUseAfterCast) then
			for b,i in pairs(BPMUseAfterCast) do
				UseContainerItem(b,i)
			end
		end 
		BPMUseAfterCast = nil
	end
end

function ADDON:UNIT_SPELLCAST_FINISHED(arg1,arg2,arg3)
	D:Debug("UNIT_SPELLCAST_FINISHED"..tostring(arg1)..tostring(arg2))
	if arg1=="player" then
		if BPMAutoloot then
			BPMAutoloot=nil
			SetCVar('AutoLootDefault', 0)
		end
		BPMUseAfterCast = nil
	end
end

function ADDON:LOOT_CLOSED()
	D:Debug("LOOT_CLOSED")
	if BPMAutoloot then
		BPMAutoloot=nil
		SetCVar('AutoLootDefault', 0)
	end
end

function ADDON:BAG_UPDATE()
	D:Debug("BAG_UPDATE")
	if ADDON.dropdown:IsOpen(ADDON.dropdown.parent) then ADDON.dropdown:Refresh(2) end

	for spellID,_ in pairs(ADDON.pendigRecipes) do
		ADDON:ScanRecipe(spellID)
	end

	ADDON:ScanNonProfessions()
end

--------------------------------------------------------------------------------
-- Modifying Tooltips                                                         --
--------------------------------------------------------------------------------

function ADDON:modifytooltip(tooltip,id,isitem)
	if not id or not tooltip or not ADDON.save[my].config.tooltip.ShowIfYouCanCraftThisInItemTooltips then return end
	local chars,prof
	for k,v in pairs(ADDON.save) do
		if v.faction==UnitFactionGroup("player") or ADDON.save[my].config.bothFactions then
			if v.craftableitems then
				for kk,vv in pairs(v.craftableitems) do
					local found
					if isitem then --Get ID of Henchant
						found = strfind(vv,"|%d+,"..id.."|") -- |ECHANT,ITEM|
					else
						found = strfind(vv,"|"..id..",%d+|")
					end
					if found then
						prof = GetSpellInfo(kk)
						if ADDON.save[my].config.bothFactions and v.faction=="Horde" then
							if not chars then chars=k.." ("..FACTION_HORDE..")" else chars=chars..", "..k.." ("..FACTION_HORDE..")" end
						elseif ADDON.save[my].config.bothFactions and v.faction=="Alliance" then
							if not chars then chars=k.." ("..FACTION_ALLIANCE..")" else chars=chars..", "..k.." ("..FACTION_ALLIANCE..")" end
						else
							if not chars then chars=k else chars=chars..", "..k end
						end
					end
				end
			end
		end
	end
	if prof then
		tooltip:AddLine(' ')
		tooltip:AddLine(prof..": "..chars,1,0.60,0)
		tooltip:Show()
	end
end

--Modifying Item Tooltips

ADDON.TipHooker:Hook(function(self,...)
	local itemid = strmatch(select(2,self:GetItem()),"|Hitem:(%d+):")
	ADDON:modifytooltip(self,itemid,true)
end, "item")
--Modifying Enchant Recept Tooltips
hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(self, ...)
	local arg1,_ = ...
	if select(1,strfind(arg1,"enchant:")) then
		local id=strmatch(arg1,"enchant:(%d+)")
		ADDON:modifytooltip(self,id)
	end
end)

-------------------------------------------------------------------------------
-- Broker Functions                                                        --
--------------------------------------------------------------------------------

function ADDON:InitLDB()
	ADDON.dataobj = ADDON.LDB:NewDataObject(ADDON.name,
	{
		type = "data source",
		icon = "Interface\\Icons\\Trade_BlackSmithing",
		text = L["professions"],
		label = L["professions"],
		OnEnter = function(self)
			ADDON:Broker_OnEnter(self)
		end,
		OnLeave = function(self)
			ADDON:Broker_OnLeave(self)
		end,
		OnClick = function(frame,button)
			ADDON:Broker_OnClick(frame,button)
		end,
	})
	--D:Debug("Create LDB:"..tostring(ADDON.dataobj))

	self:RefreshLDBData()
end

function ADDON:RefreshLDBData()
	--D:Debug("SetLDBData:"..tostring(ADDON.dataobj))
	if (ADDON.save[my].config.showlastprofinldb == true and ADDON.save[my].lastprofession > 0) then
		ADDON.dataobj.icon = tostring(select(3, GetSpellInfo(ADDON.save[my].lastprofession)))
		ADDON.dataobj.text = self:GetProfName(ADDON.save[my].lastprofession) -- select(1, GetSpellInfo())
	end
end

function ADDON:Broker_OnEnter(brokerframe)
	--D:Debug("Broker_OnEnter")
	if InCombatLockdown() then return end
	if (ADDON.dropdown:IsOpen(brokerframe)) then return end
	ADDON:CreateTooltip()
	ADDON.tooltip:Clear()
	ADDON.tooltip:SmartAnchorTo(brokerframe)
	ADDON.tooltip:SetAutoHideDelay(0.1, brokerframe)
	ADDON:ShowTooltip()
end

function ADDON:Broker_OnLeave(brokerframe)
	--D:Debug("Broker_OnLeave")
end

function ADDON:Broker_OnClick(brokerframe,button)
	D:Debug("Broker_OnClick:")
	if InCombatLockdown() then return end

--	D:Debug("KeyDownIndex:"..self:KeyDownIndex(button))
--	D:tprint(ADDON.save[my].quicklaunch)

	local key = ADDON.keys[self:KeyDownIndex(button)]
--	D:tprint(key)
	if not key then return end
	local id = ADDON.save[my].quicklaunch[key.Key]
--	D:Debug("id:"..tostring(id))

	--left button pressed
	if (id==-1 and ADDON.save[my].lastprofession > 0) then
		D:Debug("Broker_OnClick: ShowOrToggleTradeSkillFrame")
		ADDON:ShowOrToggleTradeSkillFrame(ADDON.save[my].lastprofession)
	elseif (id=='menu') then
		D:Debug("Broker_OnClick: OpenMenu")
		ADDON.DestroyTooltip()
		ADDON.dropdown:Open(brokerframe,'children', function(level, value) ADDON.dropdown:ShowMenu(level,value,self) end)
		--ADDON.dropdown:SmartAnchorTo(brokerframe)
	elseif (id=='fav') then
		D:Debug("Broker_OnClick: OpenFavorites")
		ADDON:DestroyTooltip()
	 	ADDON.dropdown:Open(brokerframe, 'children', function() ADDON.dropdown:ShowFavorites(self) end)
		--ADDON.dropdown:SmartAnchorTo(brokerframe)
	elseif (id>0 and ADDON.save[my].lastprofession ~= id) then
		D:Debug("Broker_OnClick: ShowTradeSkillFrame")
		ADDON:ShowTradeSkillFrame(id)
	end
end

--<< Launchers >>---------------------------------------------------------------
function ADDON:newlauncher(profID)
	local profname = ADDON:GetProfName(profID)
	D:Debug("newlauncher:".. profID..profname)
--	local profname,_,icon = GetSpellInfo(profID)
	if (not profname or not ADDON:IsProfessionAvailable(profID) or ADDON.ignoredquickprofessions[profID]) then return nil end
	local icon = ADDON:GetProfIcon(profname)
	local launcher = {}
	launcher.dataobj = ADDON.LDB:NewDataObject(profname, {
		type = "launcher",
		label = profname,
		icon = icon,
		OnClick = function(frame,button)
			ADDON:ShowOrToggleTradeSkillFrame(profID)
		end,
	})

	return launcher
end
--------------------------------------------------------------------------------
-- ToolTip Functions                                                                  --
--------------------------------------------------------------------------------

--(All credit for this func goes to Tekkub and his picoGuild!)
function ADDON:GetTipAnchor(frame)                   --although used with dropdownmenu
	local x, y = frame:GetCenter()
	if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
	local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
	local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
	return vhalf..hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP')..hhalf
end

function ADDON:GetTipAnchor2(frame)
	local x, y = frame:GetCenter()
	local hhalf = (x > UIParent:GetWidth() / 2) and 'RIGHT' or (x < UIParent:GetWidth() / 2) and 'LEFT' or ''
	local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
	return vhalf..hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP')..(hhalf == 'RIGHT' and 'LEFT' or 'Right')
end

local function DecimalToHex(r,g,b)
    return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

function ADDON:CreateTooltip()
	--D:Debug("CreateTooltip")
	local tooltip = ADDON.QTip:Acquire(ADDON.name.."Tooltip", 2, "LEFT", "RIGHT")
	ADDON.tooltip = tooltip
end

function ADDON:DestroyTooltip()
	--D:Debug("DestroyTooltip")
	if ADDON.tooltip then
		ADDON.QTip:Release(ADDON.tooltip)
		ADDON.tooltip = nil
	end
end

local function GetClassColor(class)
	local classcolor = RAID_CLASS_COLORS[class]
	return DecimalToHex(classcolor.r,classcolor.g,classcolor.b)
end

local rankColor =
{
	[0]	= { r = 0.00, g = 1.00, b = 0.00},
	[1]	= { r = 1.00, g = 0.50, b = 0.25},
	[2]	= { r = 1.00, g = 0.18, b = 0.00},
}

function ADDON:GetRankColor(rank,maxrank)
	local rc = rankColor[0]
	if (rank ~= "nil" and maxrank ~= "nil") then
		local diff = tonumber(tonumber(maxrank) - tonumber(rank))
		if diff > 100 then
			rc = rankColor[2]
		elseif (diff > 0) then
			rc = rankColor[1]
		end
	end
	return DecimalToHex(rc.r,rc.g,rc.b)
end

--Main Tooltip
function ADDON:ShowTooltip()
	--D:Debug("ShowTooltip")

	ADDON.tooltip:Clear()
	ADDON.tooltip:AddHeader(ADDON.name)
	ADDON.tooltip:AddSeparator()
	ADDON.tooltip:AddLine(colorYellow..L["professions"])

	if ADDON.save[my].config.tooltip.showskills then

		local pfo = ADDON.ProfSortOptions
		local opts = ADDON.ProfSortOptions:new(pfo.Alphabetical)
		
		if ADDON.save[my].config.tooltip.showexpansionranks then
			opts:add(ADDON.ProfSortOptions.IncludeExpansionRanks)
		end

		if ADDON.save[my].config.tooltip.showexpansionname then
			opts:add(ADDON.ProfSortOptions.IncludeExpansionName)
		end

		local profs = ADDON:GetSortedProfessions(opts)

		for _,profData in pairs(profs) do
			local rankcolor = self:GetRankColor(profData.rank,profData.maxRank)
			local clickable = true --not ADDON.ignoredquickprofessions[profid] and true or false
			local line = ADDON.tooltip:AddLine("|T"..profData.icon..":16:16:0:0|t "..profData.name,rankcolor..profData.rank..colorWhite.."/"..colorYellow..profData.maxRank)
			if (clickable) then
				ADDON.tooltip:SetLineScript(line,"OnMouseUp",function(var) ADDON:ShowOrToggleTradeSkillFrame(profData.profId) end)
			end
			if profData.expansionRanks then
				for _,rankData in pairs(profData.expansionRanks) do	
					--name = categoryData.name,
					--rank = categoryData.skillLineCurrentLevel,
					--maxRank = categoryData.skillLineMaxLevel,
					local rankcolor = self:GetRankColor(rankData.rank,rankData.maxRank)
--					ADDON.tooltip:AddLine(rankData.name,rankcolor..rankData.rank..colorWhite.."/"..colorYellow..rankData.maxRank,"notClickable", true)
--					ADDON.tooltip:AddLine('text',"|cffffd100"..rankData.name.."|r","notClickable", true)
					ADDON.tooltip:AddLine(" " .. colorYellow..rankData.name,rankcolor..rankData.rank..colorWhite.."/"..colorYellow..rankData.maxRank)
				end
			end
		end
		--Pick Look
		local name,_,icon,_ = GetSpellInfo(1804)
		if GetSpellBookItemInfo(name) then
			ADDON.tooltip:AddSeparator()
			ADDON.tooltip:AddLine("|T"..icon..":16:16:0:0|t "..name,UnitLevel("player")*5)
		end
	end

	--Cooldowns
	if (ADDON.save[my].config.tooltip.showcds == true) then
		ADDON.tooltip:AddSeparator()

		local jj = nil
		local duration = 0

		ADDON.tooltip:AddLine(" ")
		ADDON.tooltip:AddLine(colorYellow..L["cds"])
		for k,v in pairsByKeys(ADDON.save[my].cds) do
			duration = difftime(v,time())
			if duration>0 then
				jj=true
				ADDON.tooltip:AddLine("|cff00ff00"..k.."|r",SecondsToTime(duration))
			end
		end

		local scannedrealms = {}

		if ADDON.save[my].config.tooltip.showcrosscds then
			for _,value in pairsByKeys(Broker_ProfessionsMenu) do
				table.insert(scannedrealms,value)
			end
		else
			table.insert(scannedrealms,ADDON.save)
		end

		for i=1,#scannedrealms do
			for k,v in pairsByKeys(scannedrealms[i]) do
				if  k~=my and v.cds~=nil and (ADDON.save[my].config.bothFactions or v.faction==UnitFactionGroup("player")) then
					for kk,vv in pairsByKeys(v.cds) do
						duration = difftime(vv,time())
						if duration>0 then
							jj=true
							ADDON.tooltip:AddLine(GetClassColor(v.class).."["..k.."] |cff00ff00"..kk,SecondsToTime(duration))
						end
					end
				end
			end
		end
		if not jj then ADDON.tooltip:AddLine(colorGreen..L["nocds"]) end
	end

	--Infos
	if (ADDON.save[my].config.tooltip.showbuttons == true) then
		ADDON.tooltip:AddSeparator()
		local line
		for _,key in pairs(ADDON.keys) do
			local text
			local id = ADDON.save[my].quicklaunch[key.Key]
			if (id=='menu') then
				text = L["openmenu"]
			elseif (id=='fav') then
				text = L["favorites"]
			elseif (id>0) then
				text = GetSpellInfo(id)
			end
			if (text and key.Mod) then
				line = ADDON.tooltip:AddLine(colorYellow..key.Mod..' + '..key.Button, "|cffffffff"..text.."|r")
			elseif (text) then
				line = ADDON.tooltip:AddLine(colorYellow..key.Button, "|cffffffff"..text.."|r")
			end
		end
	end
	ADDON.tooltip:Show()
end

--------------------------------------------------------------------------------
-- Tradeskill methods
--------------------------------------------------------------------------------

function ADDON:GetSortedProfessions(sortOptions)
	
	local result = {}
	
	--Ignorelist
	local ignore = {}

	--Additional
	local characterSpecific = 
	{
		[53428] = UnitClass("player"),	--Rune Forging (Death Knigth)
		[1804]  = UnitClass("player"),	--Pick Look (Rogue)
	}

	local additionalprof = 
	{
		-- [755] = --jewelcrafting
		-- {
		-- 	[225902]=UnitClass("player"),		--mass-prospect-leystone
		-- 	[225904]=UnitClass("player"),		--mass-prospect-felslate
		-- }
	}

	--ADDON.tprint(sortOptions)
	local profDatas = {}

	for _,index in pairs({GetProfessions()}) do
		local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillID, 
				skillModifier, specializationIndex,specializationOffset,ename = GetProfessionInfo(index)

		local spellName = name

		if ename and sortOptions:is(ADDON.ProfSortOptions.IncludeExpansionName) then	--extended with (expansion) name
			name = name .. " (" .. ename .. ")" 
		end
		
		result[name] = {}				
		
		--gather profession information
		profDatas[name] = 
		{
			name = name,
			spellName = spellName,
			profId = SkillIdToProfIdtable[skillID],
			icon = icon,
			rank = tostring(skillLevel),
			maxRank = tostring(maxSkillLevel),
		}
		
		if sortOptions:is(ADDON.ProfSortOptions.IncludeSpells) then
			--iterate skill spells and insert to child if correct
			for i=1, numAbilities do
				if (not IsPassiveSpell(spelloffset+i, BOOKTYPE_PROFESSION)) then
					local subname,_ = GetSpellBookItemName(spelloffset+i, BOOKTYPE_PROFESSION)
					if subname ~= name then --skip main name again
						result[name][subname] = GetSpellBookItemTexture(spelloffset+i, BOOKTYPE_PROFESSION)
					end
				end
			end
		end
	end

	if sortOptions:is(ADDON.ProfSortOptions.Alphabetical) then
	
		--sort result Alphabeticaly
		local newResult = {}
		for name,data in pairsByKeys(result) do
			local profData = profDatas[name]

			if sortOptions:is(ADDON.ProfSortOptions.IncludeSpells) then
				profData.spells = {}
				for subname,icon in pairsByKeys(data) do	
					profData.spells[subname] = icon
				end
			end
			table.insert(newResult,profData)
		end
		result = newResult
	end

	if sortOptions:is(ADDON.ProfSortOptions.IncludeExpansionRanks) then

		local save = ADDON.save[my]

		for _,profData in pairs(result) do
			--D:Debug("exprank check:"..tostring(profData.name))
			local profId = profData.profId
			--D:Debug("exprank id:"..tostring(profId))
			if save.tradeskills[profId] and save.tradeskills[profId].data and save.tradeskills[profId].data.expansionRanks then
				--D:Debug("exprank found:"..tostring(profId))
				profData.expansionRanks = save.tradeskills[profId].data.expansionRanks
			end
		end
	end

--    Alphabetical                = 1,
--    PrimarySecondary            = 2,
--    Unsorted                    = 4,
--    IncludeCharacterSpecific    = 8,
--    IncludeExpansionRanks       = 16,

--[[
	local icon = ADDON.updaterframe:CreateTexture(nil,"TOPLEFT"); -- create texture as child of myframe
	icon:SetPoint("TOPLEFT",ADDON.updaterframe, "TOPLEFT", 5,-5)
	icon:SetSize(16,16)
	icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"); -- this is the image containing all class icons
	
	-- setup portrait texture
	local _, class = UnitClass("player");
	--icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
	local x1, x2, y1, y2 = unpack(CLASS_ICON_TCOORDS[strupper(class)]);
	local height = y2 - y1;
	y1 = y1 + 0.25 * height;
	y2 = y2 - 0.25 * height;
	icon:SetTexCoord(x1, x2, y1, y2);
	
	--]]				

	if sortOptions:is(ADDON.ProfSortOptions.IncludeCharacterSpecific) then

		for id,title in pairs(characterSpecific) do
			local name,_,icon,_ = GetSpellInfo(id)
			if GetSpellBookItemInfo(name) then

				--D:Debug(tostring(icon))
				table.insert(result,
				{
					name = title,
					spellName = name,
					icon = ADDON.classIcons[select(2,UnitClass("player"))],
					spells = { [name] = tostring(icon) },
				})
			end
		end
	end

	--ADDON:tprint(result)
	return result
end

function ADDON:GetFilteredProfs()
	local result={}
	--Ignorelist
	local ignoreproflist = ADDON.ignoredquickprofessions

	--Professions
	for _,index in pairs({GetProfessions()}) do
		if index then
			local name, texture, rank, maxRank, numSpells, spelloffset, skillID = GetProfessionInfo(index)
			local id = ADDON:TransProfID(ADDON:GetProfID(name))
			if (id and not ignoreproflist[id]) then
				result[name] = texture
			end
		end
	end

	return result
end

--<< GetSpellId >>--------------------------------------------------------------
function ADDON:GetSpellID(spell)
	if not spell then return end
	local link,_ = GetSpellLink(spell)
	if not link then return end
	return tonumber(link:match("|Hspell:(%d+)|h"));	
end

function ADDON:GetProfIcon(profname)
	for _,index in pairs({GetProfessions()}) do
		if index then
			local name, texture = GetProfessionInfo(index)
			if (name == profname) then return texture end
		end
	end
	return nil
end

function ADDON:GetProfessionRanks(profid)
	local skillid = table.getkey(SkillIdToProfIdtable,self:TransProfID(profid))
	for _,index in pairs({GetProfessions()}) do
		if index then
			local _,_,rank,maxRank, _, _,skid = GetProfessionInfo(index)
			if (skid == skillid) then return rank,maxRank end
		end
	end
	return nil,nil
end

function ADDON:GetProfSkillLine(profname)
	for _,index in pairs({GetProfessions()}) do
		if index then
			local name, texture, rank, maxRank, numSpells, spelloffset, skillLine = GetProfessionInfo(index)
--			D:Debug("name:"..name..","..skillLine)
			if (name == profname) then return skillLine end
		end
	end
	return nil
end


local LocalizedSkills =
{
	[GetSpellInfo(184251)]	= GetSpellInfo(193290), -- LOCALIZED_HERBALISM -> LOCALIZED_HERBALISM_SKILLS
	[GetSpellInfo(32606)]	= GetSpellInfo(2656),	-- LOCALIZED_MINING LOCALIZED_MINING_SKILLS
	[GetSpellInfo(8617)]	= GetSpellInfo(194174), -- LOCALIZED_SKINNING LOCALIZED_SKINNING_SKILLS
	[GetSpellInfo(7620)]	= GetSpellInfo(271990), -- LOCALIZED_fishing LOCALIZED_SKINNING_SKILLS
}

function ADDON:GetSpellCastName(spellName)
	--the spell name is a skill cast to it
	--D:Debug(spellname)
	return LocalizedSkills[spellName] or spellName
end

local DisplayedSkills =
{
	[GetSpellInfo(2366)]	= GetSpellInfo(184251), -- LOCALIZED_HERB_GATHERING -> LOCALIZED_HERBALISM
}

function ADDON:GetSpellDisplayName(spellName)
	--the spell name is a skill cast to it
	--D:Debug(spellname)
	return DisplayedSkills[spellName] or spellName
end

function ADDON:GetProfName(profID)
--	if not profid then return nil end
--	local name = GetSpellInfo(profid)
--	return name
-- 	for _,index in pairs({GetProfessions()}) do
-- --name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset,	skillLine, skillModifier, specializationIndex,specializationOffset,expansionname
-- 		local name,_,_,_,_,_,pskillID,_,_,_,eName = GetProfessionInfo(index)
-- 		if (skillID == pskillID) then 
-- 			return name ,eName --eName and (name .. " (" .. eName .. ")") or name
-- 		end
-- 	end
	local profid,skillid = self:TransProfID(profID)
	if profid and skillid then
		local name = GetSpellInfo(profid)
		return self:GetSpellDisplayName(name)
	else
		--fallback to get name from system 
		local name = GetSpellInfo(profID)
		return name
	end
	return nil
 end

function ADDON:GetProfID(profname)
	if not profname then return nil end
	profname = ADDON:GetSpellCastName(profname)
	local name, _, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(profname)
	return self:TransProfID(spellID)
end

--[[
	
	function ADDON:IsProfession(profName)
		if (profName == "Mining Skills") then profName = "Mining" end
		if (profName == "Herbalism Skills") then profName = "Herbalism" end
		if (profName == "Skinning Skills") then profName = "Skinning" end
		for _,index in pairs({GetProfessions()}) do
			if index then
				local name = GetProfessionInfo(index)
				--D:Debug("pf:"..name..":"..spellID)
				if (name == profName) then return true end
			end
		end
		return false
	end
--]]

function ADDON:IsProfessionAvailable(profId)
	local profid,skillid = self:TransProfID(profId)
	if profid and skillid then
		--D:Debug("IsProfessionAvailable:"..profid..":"..skillid)
		for _,index in pairs({GetProfessions()}) do
			local skillId = select(7,GetProfessionInfo(index))
			--D:Debug("IsProfessionAvailable:"..skillId)
			if (skillid == skillId) then
				return true
			end
		end
	end
	return false
end

function ADDON:GetProfSkillID(profid)	--profid is numeric speel link not working on not HTrade skills this handles all
	if not profid then return end
	return table.getkey(SkillIdToProfIdtable,self:TransProfID(profid))
end

function ADDON:GetCurrentTradeSkillProfID()
--	local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier, parentSkillLineID, parentSkillLineName =  C_TradeSkillUI.GetTradeSkillLine();
    local parentSkillLineID = select(6,C_TradeSkillUI.GetTradeSkillLine())
	if not parentSkillLineID then return nil end
	local profID = SkillIdToProfIdtable[parentSkillLineID]
--	D:Debug("profID:"..profID)
	return profID
end

function ADDON:GetCurrentTradeSkillID()
	local skillLineID = select(6,C_TradeSkillUI.GetTradeSkillLine())
	return skillLineID
end
	
function ADDON:TransProfID(profid)
	if not profid then return end
	for _,v in pairs(ADDON.profidtable) do
		for _,vv in pairs(v) do
			if (vv==profid) then
				return v[1], table.getkey(SkillIdToProfIdtable,v[1])
			end
		end
	end
	return nil, nil
end

function ADDON:StartScanning() 
	D:Debug("StartScanning")
	ADDON.updaterframe.scanning = true
	ADDON.updaterframe:Show()
end

function ADDON:StopScanning() 
	ADDON.updaterframe.scanning = false
	ADDON.updaterframe:Hide()
end

--<< TradeSkillFrame: Scan for cooldowns end recipes >>-------------------------

function ADDON:ScanTradeSkillFrame()
	--	due to blizzard implementation TradeSkills infos not get under TRADE_SKILL_SHOW-event only later got valid information  
	--  i create a dummy frame and wait for ready
	
	local currentProfId = self:GetCurrentTradeSkillProfID()	--get current profession id (only work when trade skill window is opened)

	if not IsTradeSkillLinked() and not IsTradeSkillGuild() and currentProfId then
		
		local profID,skillID = self:TransProfID(currentProfId)	--translate to rank 1

		D:Debug("ScanTradeSkillFrame:profID:"..profID.." skillID:"..skillID)

		ADDON.save[my].lastprofession = profID;		--last profession update

		self:ScanProfession(profID,true,true)
		self:RefreshLDBData()
	end
end

function ADDON:ScanProfession(profID,clearDB,scanTradeSkill)

	if not self:IsProfessionAvailable(profID) then
		return
	end

	local save = ADDON.save[my]

	local profName = self:GetProfName(profID)
	local rank, maxRank = self:GetProfessionRanks(profID)
	local expansionRanks = {}

	if clearDB then

		save.favorites[profID] = {}
		save.tradeskills[profID] = 
		{
			items = {},
		}
	end 

	save.tradeskills[profID].data =
	{
		rank = tostring(rank),
		maxRank = tostring(maxRank),
		expansionRanks = expansionRanks,
	}

	if scanTradeSkill then
		
		D:Debug("Scan TradeSkill:"..profName.." recipes:"..tostring(GetNumTradeSkills()));

		local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs();
		for _,recipeID in ipairs(recipeIDs) do
			self:ScanRecipe(recipeID)
		end

		local categories = { C_TradeSkillUI.GetCategories() };
		for _, categoryID in ipairs(categories) do
			local categoryData = C_TradeSkillUI.GetCategoryInfo(categoryID);
			if categoryData.hasProgressBar and categoryData.skillLineMaxLevel > 0 and profName ~= categoryData.name then
				local rankInfo = 
				{
					name = categoryData.name,
					rank = categoryData.skillLineCurrentLevel,
					maxRank = categoryData.skillLineMaxLevel,
				}
				table.insert(expansionRanks,rankInfo)
				D:Debug("Scan TradeSkill Category:"..categoryData.name)
			end
		end
	end
end
	
function ADDON:ScanNonProfessions()

	D:Debug("ScanNonProfessions...");

--scaning Fishing

	local profid = 7620	--fishing

	ADDON.save[my].tradeskills[profid] = nil 

	for _,index in pairs({GetProfessions()}) do
		if index then
			local _,_,rank,maxRank, _, _,skid = GetProfessionInfo(index)
			if (skid == 356) then
				local rank, maxRank = ADDON:GetProfessionRanks(profid)
				D:Debug("Scanning Fishing:"..rank.."/"..maxRank) 

				ADDON.save[my].tradeskills[profid] = {} 
				
				ADDON.save[my].tradeskills[profid]["data"] =
				{
					["rank"] = tostring(rank),
					["maxRank"] = tostring(maxRank),
				}

				ADDON.save[my].tradeskills[profid]["items"] = {}
				break
			end
		end
	end

--[53428]=UnitClass("player"),	--Rune Forging

--[1804]=UnitClass("player"),		--Pick Look

	profid = 1804

	ADDON.save[my].tradeskills[profid] = nil 

	if GetSpellBookItemInfo(GetSpellInfo(profid)) then	
		D:Debug("scanning Pick Look:"..UnitLevel("player") * 5) 
	
		ADDON.save[my].tradeskills[profid] = {}

		ADDON.save[my].tradeskills[profid]["data"] =
		{
			["rank"] = tostring(UnitLevel("player") * 5),
			["maxRank"] = tostring(110* 5),
		}

		ADDON.save[my].tradeskills[profid]["items"] = {}

	end

-- Archaelogy

	profid = 78670 

	ADDON.save[my].tradeskills[profid] = nil 

	if ADDON:IsProfessionAvailable(profid) then
		ADDON.save[my].favorites[profid] = nil
		ADDON.save[my].tradeskills[profid] = {} 
		
		local rank, maxRank = ADDON:GetProfessionRanks(profid)
		D:Debug("scanning Archaelogy:"..rank.."/"..maxRank) 
		
		ADDON.save[my].tradeskills[profid]["data"] =
		{
			["rank"] = tostring(rank),
			["maxRank"] = tostring(maxRank),
		}

		ADDON.save[my].tradeskills[profid]["items"] = {}
	end
end

function ADDON:ScanRecipe(id)
	
	local function GetDailySkillResetTime()
		--D:Debug("GetDailySkillResetTime")
		local resettime = GetQuestResetTime()
		  if not resettime or resettime <= 0 or resettime > 24*3600+30 then -- can also be wrong near reset in an instance
			return nil
		  end
		return time() + resettime  
	end

	if not IsTradeSkillLinked() and not IsTradeSkillGuild() and ADDON:GetCurrentTradeSkillProfID() then
		local name,skilltype = GetTradeSkillInfo(id)
		if (name == nil) then return end
		if ( skillType ~= "header" and skillType ~= "subheader" ) then
			--D:Debug("Scan recipe:"..name);
			local enchant=GetTradeSkillRecipeLink(id)
			local item=GetTradeSkillItemLink(id)
			local favorite = IsRecipeFavorite(id)
			local icon = GetTradeSkillIcon(id) 
			--D:Debug("item:"..item.." enchant:"..enchant)
			local cd,daily = GetTradeSkillCooldown(id)
			if cd and daily and not ADDON.LongCDs[id] then -- daily flag incorrectly set for some multi-day cds (Northrend Alchemy Research)
				cd = GetDailySkillResetTime()
			elseif cd then
				cd = time() + cd  -- on cd
			else
				cd = 0 -- off cd or no cd
			end
			
			if cd > 0 then
				if (ADDON.sharedcds[name]) then
					D:Debug("Recipe on shared Cd:"..name)
					name = ADDON.sharedcds[name]
				else
					D:Debug("Recipe on Cd:"..name)
				end 
				ADDON.save[my].cds[name] = cd
			elseif (ADDON.save[my].cds[name]) then
				D:Debug("Recipe Cd ellapsed:"..ADDON.save[my].cds[name])
				ADDON.save[my].cds[name] = nil	--display toast window
				ADDON.LibToast:Spawn("TradeSkillToast",name,icon)
			end
			if type(enchant)=="string" then
				enchant = strmatch(enchant,"|Henchant:(%d+)")
				if type(item)=="string" then
					item=strmatch(item,"|Hitem:(%d+):")
					if not item then item="0" end
				else
					item="0"
				end
				local profid = ADDON.save[my].lastprofession
				if (favorite) then
					--D:Debug("recipe favorite:"..profid..","..tostring(id))
					ADDON.save[my].favorites[profid][id] = favorite and icon or nil 
				end
	--			local _, _, icon = GetSpellInfo(id) 
	--			D:Debug("enchant:"..enchant.."item:"..item);
				--D:Debug("profid"..tostring(profid))
				if (enchant) then
					local storeddata = 
					{
						 ["item"] = item,
						 ["icon"] = tostring(icon),
					}

					ADDON.save[my].tradeskills[profid]["items"][id] = storeddata
				else
					ADDON.save[my].tradeskills[profid]["items"][id] = nil				
				end
			end
		end
	end
end

--<< Quicktradeskill scan function >>-------------------------------------------
-- List of all aviable quick trade skills and their localized name (for scanning of the tooltip)
local skills = 
{
	[GetSpellInfo(1804)]  = ITEM_OPENABLE,				--lock pick
	[GetSpellInfo(13262)] = ITEM_DISENCHANT_ANY_SKILL,	--disenchant
	[GetSpellInfo(51005)] = ITEM_MILLABLE,				--milling
	[GetSpellInfo(31252)] = ITEM_PROSPECTABLE,			--prospecting
}
-- Scanfuntion
function ADDON:scanBagForQuickTradeSkillItems(skillname, onlyAviableCheck)
	if (not (skillname and skills[skillname])) then return false end
	if (onlyAviableCheck) then return true end
	local result={}
	for i=0, NUM_BAG_SLOTS do
		for j=1, GetContainerNumSlots(i) do
			local itemid = GetContainerItemID(i,j)
			if itemid then
				local texture, itemCount, _, quality, _ = GetContainerItemInfo(i, j)
				local itemName,_,_,_,itemMinLevel,itemType,itemSubType = GetItemInfo(itemid)
				local profid = nil
				-- if itemName == nil then 
				-- 	D:Debug(itemid)
				-- end
				-- Check
				local add = false
				local useaftercast = false 
				if (skills[skillname]==ITEM_MILLABLE and ADDON.processable:IsMillable(itemid) and itemCount>=5) then
					add = true
					profid = 2366  --"Herbalism",
				elseif (skills[skillname]==ITEM_PROSPECTABLE and ADDON.processable:IsProspectable(itemid) and itemCount>=5) then
					add = true
					profid = 25229 --"Jewelcrafting",
				elseif (skills[skillname]==ITEM_DISENCHANT_ANY_SKILL and ADDON.processable:IsDisenchantable(itemid)) then
					add = true
					profid = 7411  --"Enchanting",
				elseif (skills[skillname]==ITEM_OPENABLE and ADDON.processable:IsOpenable(itemid)) then
					add = true
					useaftercast = true
				end
				if (add and profid and ADDON.save[my].ignores[profid] and ADDON.save[my].ignores[profid][itemid]) then
					add = false
				end
				-- Create Entry
				if (add and itemName) then
					if (itemCount>1) then itemCount = " ("..itemCount..")" else itemCount="" end
					--D:Debug("n:"..itemName.."i:"..i.."j:"..j)
					result[quality.."-"..itemName.."-"..i.."-"..j] = {
						name="|c"..select(4,GetItemQualityColor(quality))..itemName..itemCount.."|r",
						icon=tostring(texture),--Legion not real number menu only allowed string
						action={
							["type1"]="macro",
							["macrotext"]= not useaftercast and ("/script if(GetCVar('AutoLootDefault')=='0') then BPMAutoloot=true end\n/cast "..skillname.."\n/use "..i.." "..j)
							or ("/script if(GetCVar('AutoLootDefault')=='0') then BPMAutoloot=true end BPMUseAfterCast = {["..i.."] = "..j.."}\n/cast "..skillname.."\n/use "..i.." "..j)
						},
						tooltip=function()
							self = GameTooltip:GetOwner()
							GameTooltip:SetOwner(self, "ANCHOR_NONE")
							GameTooltip:ClearAllPoints()
							GameTooltip:SetPoint(ADDON:GetTipAnchor2(self))
							GameTooltip:SetBagItem(i,j)
							GameTooltip:AddLine(" ")
							GameTooltip:AddLine(L["leftclick"]..": "..skillname..L["autoloot"].."\n"..L["ctrl"].."+"..L["leftclick"]..": "..L["additemtoignorelist"],0,1,0)
						end,
						func = function()
							if IsControlKeyDown() and profid then
				 				--D:Debug(itemid..itemName)
								if not ADDON.save[my].ignores[profid] then
									ADDON.save[my].ignores[profid] = {}
								end
								ADDON.save[my].ignores[profid][itemid] = true;
							end
						end,
					}
				end
			end
		end
	end
	return result
end

local massSkills = 
{
	[GetSpellInfo(13262)] = ITEM_DISENCHANT_ANY_SKILL,	--disenchant
	[GetSpellInfo(51005)] = ITEM_MILLABLE,				--milling
	[GetSpellInfo(31252)] = 							--prospecting
	{
		[GetSpellInfo(225902)] = 123918, 		--mass-prospect-leystone
		[GetSpellInfo(225904)] = 123919,		--mass-prospect-felslate
		[GetSpellInfo(247761)] = 151564,		--Mass Prospect Empyrium
	}
}

-- Scanfuntion
function ADDON:scanBagForMassTradeSkillItems(skillname)
	D:Debug("scanBagForMassTradeSkillItems:"..skillname)
	if not massSkills[skillname] then return nil end
	local result = nil
	local itemid =  123918
	local itemCount = GetItemCount(itemid)
	local itemName,_,_,_,_,_,_,_,_,texture,_ = GetItemInfo(itemid)
	
	if (itemName and itemCount >= 20) then
		result =
		{
			func = function()
				D:Debug("Craft mass recipe:"..itemid)
				if (ADDON:ShowTradeSkillFrame(25229)) then 
--					_G.TradeSkillFrame:SelectRecipe(itemid)
					C_TradeSkillUI.SetRecipeRepeatCount(itemid,1)
					C_TradeSkillUI.CraftRecipe(itemid,1)
				end
				
			end,
			itemid = itemid,
			icon = tostring(texture),--Legion not real number menu only allowed string
			tooltip = function()
				self = GameTooltip:GetOwner()
				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint(ADDON:GetTipAnchor2(self))
				GameTooltip:SetBagItem(i,j)
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["leftclick"]..": "..skillname..L["autoloot"],0,1,0)
			end,
		}
	end
	return result
end

-- View professions of other chars
function ADDON:OpenAltProfFrame(value, profid)
	if (profid == 78670 or profid == 7620 or profid == 1804) then return end	--archeology,fishing,picklock not opening frame
	if not ADDON.AltProfFrame then -- Call only once
		ADDON.AltProfFrame = {}
		ADDON.AltProfFrame.frame = CreateFrame("FRAME")
		ADDON.AltProfFrame.frame:SetFrameStrata("MEDIUM")
		ADDON.AltProfFrame.frame:SetWidth(300)
		ADDON.AltProfFrame.frame:SetHeight(306)
		ADDON.AltProfFrame.frame:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
			tile = true, tileSize = 16, edgeSize = 16, 
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		ADDON.AltProfFrame.frame:SetBackdropColor(0,0,0,1)
		ADDON.AltProfFrame.frame:SetPoint("TOPLEFT",15,-130)
		ADDON.AltProfFrame.frame:EnableMouse(true)
		
		ADDON.AltProfFrame.frame:SetScript("OnMouseDown", function(self, button)
			if button=="LeftButton" then
				self:StartMoving()
			end
		end)
		ADDON.AltProfFrame.frame:SetScript("OnMouseUp", function(self, button)
			if button=="LeftButton" then
				self:StopMovingOrSizing()
				self:SetUserPlaced(false)
			end
		end)
		ADDON.AltProfFrame.frame:SetMovable(true)
		
		-- Close Button
		ADDON.AltProfFrame.button = CreateFrame("Button",nil,ADDON.AltProfFrame.frame,"UIPanelCloseButton")
		--ADDON.AltProfFrame.button:SetFrameStrata(ADDON.AltProfFrame.frame:GetFrameStrata())
		ADDON.AltProfFrame.button:SetPoint("TOPRIGHT", ADDON.AltProfFrame.frame, "TOPRIGHT")
		
		-- Title Class Icon
		ADDON.AltProfFrame.titleicon = ADDON.AltProfFrame.frame:CreateTexture(nil,"TOPLEFT"); -- create texture as child of myframe
		ADDON.AltProfFrame.titleicon:SetPoint("TOPLEFT",ADDON.AltProfFrame.frame, "TOPLEFT", 5,-5)
		ADDON.AltProfFrame.titleicon:SetSize(16,16)
		ADDON.AltProfFrame.titleicon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"); -- this is the image containing all class icons

		-- Title
		ADDON.AltProfFrame.title = ADDON.AltProfFrame.frame:CreateFontString(nil, "ARTWORK")
		ADDON.AltProfFrame.title:SetFontObject(GameFontNormal)
		ADDON.AltProfFrame.title:SetPoint("TOPLEFT", ADDON.AltProfFrame.frame, "TOPLEFT", 22,-7)

		ADDON.AltProfFrame.prof = ADDON.AltProfFrame.frame:CreateFontString(nil, "ARTWORK")
		ADDON.AltProfFrame.prof:SetFontObject(GameFontNormal)
		ADDON.AltProfFrame.prof:SetPoint("TOPLEFT", ADDON.AltProfFrame.frame, "TOPLEFT", 5,-22)
		
		-- Search bar
		ADDON.AltProfFrame.search = CreateFrame("EditBox",nil,ADDON.AltProfFrame.frame,"InputBoxTemplate")
		ADDON.AltProfFrame.search:SetPoint("TOPLEFT",ADDON.AltProfFrame.prof,"BOTTOMLEFT",5,-3)
		ADDON.AltProfFrame.search:SetWidth(285)
		ADDON.AltProfFrame.search:SetHeight(20)
		ADDON.AltProfFrame.search:SetFontObject("ChatFontSmall")
		ADDON.AltProfFrame.search:SetAutoFocus(false)
		ADDON.AltProfFrame.search:SetScript("OnTextChanged", function(self)
			local text = self:GetText()
			if text==nil or text=="" then
				ADDON.AltProfFrame.ScrollFrame:SetFilter(function(self, row) return true end)
			else
				ADDON.AltProfFrame.ScrollFrame:SetFilter(function(self, row)
					if strfind(strlower(row.cols[2].value), strlower(text)) then
						return true
					end
					return false
				end)
			end
		end)
		ADDON.AltProfFrame.search:SetScript("OnEnterPressed", EditBox_ClearFocus)
		ADDON.AltProfFrame.search:SetScript("OnEscapePressed", EditBox_ClearFocus)
		ADDON.AltProfFrame.search:SetScript("OnEditFocusLost", EditBox_ClearHighlight)
		ADDON.AltProfFrame.search:SetScript("OnEditFocusGained", EditBox_HighlightText)
		--ADDON.AltProfFrame.search:SetTextInsets(16, 0, 0, 0);
		
		ADDON.AltProfFrame.ScrollFrame = ADDON.libst:CreateST({
			{
				["width"] = 20,			--icon
				["align"] = "center",
			},
			{
				["width"]=241,				--name
				["align"]="left",
				["sort"] = "desc",
			},
		},13,18,{["r"] = 0,["g"] = 0.2,["b"] = 1.0,["a"] = 0.3},ADDON.AltProfFrame.frame)
		ADDON.AltProfFrame.ScrollFrame.frame:Hide()
		ADDON.AltProfFrame.ScrollFrame.frame:SetPoint("TOPLEFT",ADDON.AltProfFrame.search,"BOTTOMLEFT",-7,-3)		
		
		ADDON.AltProfFrame.ScrollFrame:RegisterEvents({
			["OnShow"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
				if (not row) then
					cellFrame:Hide()	--hide title line
				end
			end,
			["OnEnter"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
				if not data or not row or not data[realrow] or not data[realrow]["cols"][2]["id"] then return end
				GameTooltip:SetOwner(ADDON.AltProfFrame.frame, "ANCHOR_NONE")
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("TOPLEFT",ADDON.AltProfFrame.frame,"BOTTOMLEFT",0,0)
				GameTooltip:SetSpellByID(data[realrow]["cols"][2]["id"])
				--GameTooltip:AddLine(data[realrow]["cols"][1]["value"])
				--GameTooltip:AddTexture(data[realrow]["cols"][1]["value"])
				--GameTooltip:AddLine(" ")
				--GameTooltip:AddLine("Click: Link in chat")
				GameTooltip:Show()
			end,
			["OnLeave"] = function()
				GameTooltip:Hide()
			end,
			["OnClick"] = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button, ...)
				if not data or not row or not data[realrow] or not data[realrow]["cols"][2]["id"] then return true end
				local link = GetSpellLink(data[realrow]["cols"][2]["id"])
				if (not ChatEdit_InsertLink(link) ) then
					ChatFrame1EditBox:Show()
					ChatEdit_InsertLink(link)
				end
				return true
			end,
		})
	end
	ADDON.AltProfFrame.ScrollFrame.frame:Show()
	
	local data = split(value,"|");
	local realmname = data[1]
	local charname = data[2]
	local prof, _, proficon = GetSpellInfo(profid)
	if prof then
		local coords = CLASS_ICON_TCOORDS[Broker_ProfessionsMenu[realmname][charname].class]
		ADDON.AltProfFrame.titleicon:SetTexCoord(unpack(coords)); -- cut out the region with our class icon according to coords
		ADDON.AltProfFrame.title:SetText(charname)

		ADDON.AltProfFrame.prof:SetText("|T"..proficon..":0:0:0:0|t|cffffffff"..prof.."|r")
		
		local table = {}
		
		for id,data in pairs(Broker_ProfessionsMenu[realmname][charname].tradeskills[profid]["items"]) do
			local name = GetSpellInfo(id)
			local icon = data.icon
			if name and name~="" then
				if icon and icon~="" then
					icon = "|T"..icon..":0:0:0:0|t"
				else
					icon = ""
				end
				tinsert(table,{
					["cols"] = {
						{
							["value"] = icon,
						},
						{
							["value"] = name,
							["id"] = id,
							["color"] = {r=1.0,g=0.81,b=0},
						},
					},
				})
			end
		end
		ADDON.AltProfFrame.ScrollFrame:SetData(table)
		ADDON.AltProfFrame.frame:Show()
	end
end

function ADDON:ShowOrToggleTradeSkillFrame(profID)
	D:Debug("ShowOrToggleTradeSkillFrame"..profID)
	if (not IsAddOnLoaded("Blizzard_TradeSkillUI")) then LoadAddOn("Blizzard_TradeSkillUI") end
	
	profID = self:TransProfID(profID)	--translate to rank 1

	if (profID == 78670) then 			--handle Archaeology
		ADDON:ToggleArchaeologyFrame()
		return
	end

	if not self:IsProfessionAvailable(profID) then --profession dropped exit
		return
	end

	local requestedTradeSkillID = self:GetProfSkillID(profID)	--requested skillId 
	local currentTradeSkillID = self:GetCurrentTradeSkillID()	--current opened skillId or nil if not opened

	D:Debug("requestedTradeSkillID:"..requestedTradeSkillID.." currentTradeSkillID:"..(currentTradeSkillID or "nil"))

	if currentTradeSkillID == nil or currentTradeSkillID ~= requestedTradeSkillID then
		-- if IsAddOnLoaded("Blizzard_ArchaeologyUI") and ArchaeologyFrame:IsShown() then 
		-- 	HideUIPanel(ArchaeologyFrame) 
		-- end
		C_TradeSkillUI.OpenTradeSkill(requestedTradeSkillID)
	elseif (TradeSkillFrame:IsVisible()) then 
		C_TradeSkillUI.CloseTradeSkill() 
	end
end

function ADDON:CloseTradeSkill(profID)
	if (not IsAddOnLoaded("Blizzard_TradeSkillUI")) then LoadAddOn("Blizzard_TradeSkillUI") end
	if (TradeSkillFrame:IsVisible()) then 
		C_TradeSkillUI.CloseTradeSkill() 
	end
end

function ADDON:ShowTradeSkillFrame(profID)
	if (not IsAddOnLoaded("Blizzard_TradeSkillUI")) then LoadAddOn("Blizzard_TradeSkillUI") end
	D:Debug("ShowTradeSkillFrame:"..profID)
	if (TradeSkillFrame:IsVisible()) then 
		C_TradeSkillUI.CloseTradeSkill() 
	end
	return C_TradeSkillUI.OpenTradeSkill(ADDON:GetProfSkillID(profID))
end

function ADDON:ToggleArchaeologyFrame()
	if (not IsAddOnLoaded("Blizzard_ArchaeologyUI")) then LoadAddOn("Blizzard_ArchaeologyUI") end
	D:Debug("ToggleArchaeologyFrame:")
	if (ArchaeologyFrame:IsShown()) then 
		HideUIPanel(ArchaeologyFrame) 
	else 
		if (IsAddOnLoaded("Blizzard_TradeSkillUI") and TradeSkillFrame:IsVisible()) then 
			C_TradeSkillUI.CloseTradeSkill() 
		end
		ShowUIPanel(ArchaeologyFrame)
	end
end

--------------------------------------------------------------------------------
-- Dropdownmenu                                                               --
--------------------------------------------------------------------------------
local ADDON = select(2,...)                                 --Includes all functions and variables

local L = ADDON.L	--addon localization
local C = ADDON.C	--addon common
local D = ADDON.D	--addon debug

local my = UnitName("player")--player name

local colorWhite =  "|cffffffff"
local colorBlack =  "|cff000000"
local colorGreen =  "|cff00ff00"
local colorYellow = "|cffffff00"
local colorOrange = "|cffffd100"

local function stringstarts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end

local function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
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

function ADDON.dropdown:ShowMenu(level, value, owner)
	local info = {}
	if not level then return end
	--<<LEVEL 1>>--
	if level == 1 then
		local pfo = ADDON.ProfSortOptions
		local opts = ADDON.ProfSortOptions:new(pfo.Alphabetical,pfo.IncludeCharacterSpecific,pfo.IncludeSpells)
		local profs = ADDON:GetSortedProfessions(opts)
		
		for _,profData in pairs(profs) do
			--D:tprint(profData)
			--display main professions name in yellow color				
			--ADDON.dropdown:AddSpell("|cffffd100"..name.."|r", ADDON:GetSpellCastName(name), ADDON:GetProfIcon(name), true)
			self:AddSpell(colorOrange..profData.name.."|r",ADDON:GetSpellCastName(profData.spellName),profData.icon,true)
			
			--iterate professions spells and display it
			for spellName,icon in pairs(profData.spells) do	
				self:AddSpell("  |T"..icon..":16:16:0:0|t "..spellName,spellName, nil, true)	--display profession spell name and icon 
				if (ADDON:scanBagForQuickTradeSkillItems(spellName, true)) then	--if quicktradeskills items available display arrow
					self:AddArrow("  |T"..icon..":16:16:0:0|t |cffff0000"..spellName.."|r","quicktradeskill".."|".. spellName) --to level 2
				end
				local v = false -- ADDON:scanBagForMassTradeSkillItems(spellName)
				if v then
					--ADDON.dropdown:AddLine("  |T"..icon..":16:16:0:0|t "..spellName)
					--ADDON.dropdown:AddLine('text',spellName,'icon',v.icon,'func',v.func,'secure',v.action,'tooltipFunc',function(self) v.tooltip(self) end)							
--							ADDON.dropdown:AddLine('text',"  |T"..icon..":16:16:0:0|t "..spellName,'func',v.func,'tooltipFunc',function(self) v.tooltip(self) end)
					self:AddLine('text',v.name,'icon',v.icon,'func',v.func,'tooltipFunc',function(self) v.tooltip(self) end)
				end
			end
-- 			--if tradeskill scanned expansionRanks available for displaying
-- 			if profData.expansionRanks then
-- 				for _,rankData in pairs(profData.expansionRanks) do	
-- 					--name = categoryData.name,
-- 					--rank = categoryData.skillLineCurrentLevel,
-- 					--maxRank = categoryData.skillLineMaxLevel,
					
-- 					ADDON.dropdown:AddLine('text',"|cffffd100"..rankData.name.."|r","notClickable", true)
-- --					ADDON.dropdown:AddLine('text',rankData.name)
-- 				end
-- 			end
		end
		
		ADDON.dropdown:AddLine()
		ADDON.dropdown:AddArrow("|cffffd100"..L["favorites"].."|r","favorites","Interface\\AddOns\\Broker_ProfessionsMenu\\icons\\fav.tga")
		ADDON.dropdown:AddArrow("|cff00ff00"..L["otherchar"].."|r","otherchar")  --list other chars proofessions submenus
		-- ADDON.dropdown:AddFunc("Test",function() ADDON:OpenAltProfFrame("Sanori", 2259) end)
		ADDON.dropdown:AddLine()
		ADDON.dropdown:AddArrow(L["settings"],"config")
	--<<LEVEL 2>>--
	elseif level == 2 then
		--Settingsmenu
		if value == "config" then
			ADDON.dropdown:AddTitle("Broker_ProfessionsMenu")
			ADDON.dropdown:AddTitle("|cff707070"..ADDON.version.."|r")
			ADDON.dropdown:AddLine()
			ADDON.dropdown:AddArrow(L["quicklaunch"],"quicklaunch")
			ADDON.dropdown:AddArrow(L["quicklauncher"],"quicklauncher")
			ADDON.dropdown:AddArrow(L["tooltips"],"tooltip")
			ADDON.dropdown:AddArrow(L["menufontsize"],"menufontsize") --dropdown font size
			ADDON.dropdown:AddArrow(L["ignores"],"ignores")
			ADDON.dropdown:AddToggle(L["bothfactions"], ADDON.save[my].config.bothFactions, function(var) ADDON.save[my].config.bothFactions=var end)
			ADDON.dropdown:AddToggle(L["showlastprofinldb"], ADDON.save[my].config.showlastprofinldb, function(var) ADDON.save[my].config.showlastprofinldb=var end)
			ADDON.dropdown:AddLine()
			--Reset CDs
			info.func = function()
				ADDON.save[my].cds={}
				for k,v in pairs(ADDON.save) do
					if v.faction==UnitFactionGroup("player") then
						ADDON.save[k].cds={}
					end
 				end 
				GameTooltip:Hide()
				ADDON.dropdown:Close(1)
			end
			ADDON.dropdown:AddFunc(L["resetcds"], info.func, "Interface\\Icons\\Ability_Rogue_FeignDeath", true)
		elseif value == "otherchar" then	--list other realms to level 3
			for realmname,_ in pairsByKeys(Broker_ProfessionsMenu) do
				ADDON.dropdown:AddArrow(realmname,"otherchars|"..realmname)
			end
		elseif value == "favorites" then	--list vavorites
			ADDON.dropdown:ShowFavorites(owner)
		elseif stringstarts(value,"quicktradeskill") then	-- quicktradeskills bag scanning and display millable/prospectable/disench items
			local quick = ADDON:scanBagForQuickTradeSkillItems(value)
			if (quick) then
				local nomats=true
				for _,v in pairsByKeys(quick) do
					--D:Debug("pairsByKeys:"..tostring(v))
					nomats=nil
					ADDON.dropdown:AddLine('text',v.name,'icon',v.icon,'func',v.func,'secure',v.action,'tooltipFunc',function(self) v.tooltip(self) end)
				end
				if nomats then ADDON.dropdown:AddTitle(L.nomats) end
			end
		end
	--<<LEVEL 3>>--
	elseif level == 3 then
		--default professions
		if value == "quicklaunch" then
			ADDON.dropdown:AddArrow("|cffffd100"..L["leftclick"].."|r","config|left")
			ADDON.dropdown:AddArrow("  + "..L["shift"],"config|shiftleft")
			ADDON.dropdown:AddArrow("  + "..L["alt"],"config|altleft")
			ADDON.dropdown:AddArrow("  + "..L["ctrl"],"config|ctrlleft")
			ADDON.dropdown:AddArrow("|cffffd100"..L["rightclick"].."|r","config|right")
			ADDON.dropdown:AddArrow("  + "..L["shift"],"config|shiftright")
			ADDON.dropdown:AddArrow("  + "..L["alt"],"config|altright")
			ADDON.dropdown:AddArrow("  + "..L["ctrl"],"config|ctrlright")
		--quicklauncher
		elseif value == "quicklauncher" then

			local opts = ADDON.ProfSortOptions:new(ADDON.ProfSortOptions.Alphabetical)
			local profs = ADDON:GetSortedProfessions(opts)
			
			for _,profData in pairs(profs) do
				local profId = profData.profId
				local func = function(checked)
					D:Debug("quicklauncher func:%s",profId)
					if (checked) then
			 			D:Debug("quicklauncher click checked:%s",profId)
						ADDON.save[my].quicklauncher[profId] = true
						if (not ADDON.quicklauncher[profId]) then ADDON.quicklauncher[profId] = ADDON:newlauncher(profId,profData.icon) end
					else
						D:Debug("quicklauncher click UNchecked:%s",profId)
						ADDON.save[my].quicklauncher[profId] = nil
						print("|cffffd100Broker_ProfessionsMenu:|r","|cffff0000"..L["relog"].."|r")
					end
				end
				ADDON.dropdown:AddToggle("|T"..profData.icon..":16:16:0:0|t "..profData.name,ADDON.save[my].quicklauncher[profId], func)
			end

			-- for name,icon in pairsByKeys(ADDON:GetFilteredProfs()) do
 			-- 	local id = ADDON:TransProfID(ADDON:GetProfID(name))
			-- 	if (id) then
			-- 		--D:Debug("id:"..id)
			-- 		local func = function(checked)
			-- 			if (checked) then
			-- 				ADDON.save[my].quicklauncher[id] = true
			-- 				if (not ADDON.quicklauncher[id]) then ADDON.quicklauncher[id]=ADDON:newlauncher(id,icon) end
			-- 			else
			-- 				ADDON.save[my].quicklauncher[id]=nil
			-- 				print("|cffffd100Broker_ProfessionsMenu:|r","|cffff0000"..L["relog"].."|r")
			-- 			end
			-- 		end
			-- 		ADDON.dropdown:AddToggle("|T"..icon..":16:16:0:0|t "..name,ADDON.save[my].quicklauncher[id], func)
			-- 	end
			-- end
		--Tooltips
		elseif value == "tooltip" then
			--Craftable By in item tooltips
			ADDON.dropdown:AddToggle(L["ShowIfYouCanCraftThisInItemTooltips"],ADDON.save[my].config.tooltip.ShowIfYouCanCraftThisInItemTooltips,function(var) ADDON.save[my].config.tooltip.ShowIfYouCanCraftThisInItemTooltips=var end)
			--ShowAllTooltips
			ADDON.dropdown:AddToggle(L["ShowAllTooltips"],ADDON.save[my].config.tooltip.ShowAllTooltips,function(var) ADDON.save[my].config.tooltip.ShowAllTooltips=var end)
			--showskills
			ADDON.dropdown:AddToggle(L["professions"],ADDON.save[my].config.tooltip.showskills,function(var) ADDON.save[my].config.tooltip.showskills=var end)
			--showcds
			ADDON.dropdown:AddToggle(L["showcds"],ADDON.save[my].config.tooltip.showcds,function(var) ADDON.save[my].config.tooltip.showcds=var end)
			--showcrosscds
			ADDON.dropdown:AddToggle(L["showcrosscds"],ADDON.save[my].config.tooltip.showcrosscds,function(var) ADDON.save[my].config.tooltip.showcrosscds=var end)
			--showbuttons
			ADDON.dropdown:AddToggle(L["showbuttons"],ADDON.save[my].config.tooltip.showbuttons,function(var) ADDON.save[my].config.tooltip.showbuttons=var end)
			--tooltip_showexpansionranks
			ADDON.dropdown:AddToggle(L["tooltip_showexpansionranks"],ADDON.save[my].config.tooltip.showexpansionranks,function(var) ADDON.save[my].config.tooltip.showexpansionranks=var end)
			--tooltip_showexpansionname
			ADDON.dropdown:AddToggle(L["tooltip_showexpansionname"],ADDON.save[my].config.tooltip.showexpansionname,function(var) ADDON.save[my].config.tooltip.showexpansionname=var end)
		elseif value == "menufontsize" then
			local setfontsize = function(var)
				ADDON.save[my].config.menufontsize=var
				ADDON.dropdown:SetFontSize(var)
			end
			local fontsizes = ADDON.dropdown.fontsizes
			for i=1,#fontsizes do
				ADDON.dropdown:AddRadio(fontsizes[i],ADDON.save[my].config.menufontsize,function(var) setfontsize(fontsizes[i]) end)
			end
		elseif value == "ignores" then
			for k,_ in pairs(ADDON.save[my].ignores) do	--k prof v item id
				local profname,_,proficon = GetSpellInfo(k)
				ADDON.dropdown:AddArrow(profname,"ignore".."|"..tostring(k),proficon)
			end
		elseif stringstarts(value,"otherchars") then
			local realmname = split(value,"|")[2];
			for k,v in pairsByKeys(Broker_ProfessionsMenu[realmname]) do
				if (k and k~=my and v.tradeskills and tcount(v.tradeskills) > 0 and (ADDON.save[my].config.bothfactions or UnitFactionGroup("player")==v.faction)) then
					if (v.class) then
					 	local coords = CLASS_ICON_TCOORDS[v.class]
					 	ADDON.dropdown:AddArrow(k,realmname.."|"..k,"Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",nil,nil,
							'iconCoordLeft', coords[1],
							'iconCoordRight', coords[2],
							'iconCoordTop', coords[3],
							'iconCoordBottom', coords[4])
					else
						ADDON.dropdown:AddArrow(k,realmname.."|"..k)
					end
				end
			end
			ADDON.dropdown:AddLine()
			ADDON.dropdown:AddFunc(L["delrealm"], function() Broker_ProfessionsMenu[realmname] = nil end, "Interface\\Icons\\Ability_Rogue_FeignDeath", true)
		end
	--<<LEVEL 4>>--
	elseif level == 4 then
		if stringstarts(value,"ignore") then
			local profid = tonumber(split(value,"|")[2])
			if (profid) then
				local tooltip = function()
					local frame = GameTooltip:GetOwner()
					GameTooltip:SetOwner(frame, "ANCHOR_NONE")
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint(ADDON:GetTipAnchor(frame))
					GameTooltip:ClearLines()
					GameTooltip:AddLine(L["deleteignoreditemtooltip"])
				end
				for k,_ in pairs(ADDON.save[my].ignores[profid]) do
					local itemname,_,_,_,_,_,_,_,_,itemicon,_ = GetItemInfo(k) 
					local func = function()
						ADDON.save[my].ignores[profid][k] = nil
						if tcount(ADDON.save[my].ignores[profid]) == 0 then
							ADDON.save[my].ignores[profid] = nil
						end
					end
					ADDON.dropdown:AddFunc(itemname,func,itemicon,true,tooltip)
				end
			end
		elseif stringstarts(value,"config") then
			value = split(value,"|")[2];
			-- Check, if Menu is min. one time selected
			local disabled = true;
			for k,v in pairs(ADDON.save[my].quicklaunch) do	-- Menu must be asigned min. one times
				if (v=="menu" and k~=value) then
					disabled=false
					break
				end
			end
			-- No Profession
			if (ADDON.save[my].quicklaunch[value] == 0) then info.checked = true else info.checked = nil end
			info.func = function(var) ADDON.save[my].quicklaunch[value] = 0 end
			ADDON.dropdown:AddToggle("---", info.checked, info.func, nil, "disabled", disabled)
			ADDON.dropdown:AddLine()
			-- Open Last Profession Window
			if (ADDON.save[my].quicklaunch[value] == -1) then info.checked = true else info.checked = nil end
			info.func = function(var) ADDON.save[my].quicklaunch[value] = -1 end
			ADDON.dropdown:AddToggle(L['openLastProfessionWindow'], info.checked, info.func, nil, "disabled", disabled)
			-- Menu
			if (ADDON.save[my].quicklaunch[value] == "menu") then info.checked = true else info.checked = nil end
			info.func = function(var) ADDON.save[my].quicklaunch[value] = "menu" end
			ADDON.dropdown:AddToggle(L["openmenu"], info.checked, info.func, nil, "disabled", disabled)
			-- Favorites
			if (ADDON.save[my].quicklaunch[value] == "fav") then info.checked = true else info.checked = nil end
			info.func = function(var) ADDON.save[my].quicklaunch[value] = "fav" end
			ADDON.dropdown:AddToggle(L["showfavorites"], info.checked, info.func, nil, "disabled", disabled)
			-- Select Profession
			ADDON.dropdown:AddLine()

			local opts = ADDON.ProfSortOptions:new(ADDON.ProfSortOptions.Alphabetical)
			local profs = ADDON:GetSortedProfessions(opts)
			
			for _,profData in pairs(profs) do
				info.func = function() ADDON.save[my].quicklaunch[value] = profData.profId end
				if ADDON.save[my].quicklaunch[value] == profData.profId then info.checked = true else info.checked = nil end
				ADDON.dropdown:AddToggle("|T"..profData.icon..":18:18:0:0|t "..profData.name, info.checked, info.func, nil, "disabled", disabled)
			end
			-- for k,icon in pairsByKeys(ADDON:GetFilteredProfs()) do
			-- 	info.func = function() ADDON.save[my].quicklaunch[value] = ADDON:GetProfID(k) end
			-- 	if ADDON.save[my].quicklaunch[value] == ADDON:GetProfID(k) then info.checked = true else info.checked = nil end
			-- 	ADDON.dropdown:AddToggle("|T"..icon..":18:18:0:0|t "..k, info.checked, info.func, nil, "disabled", disabled)
			-- end
		else
		--list professions from an other char
			local data = split(value,"|");
			local realmname = data[1]
			local charname = data[2]
			local sortedprofs = {}
			for pid,_profdata in pairs(Broker_ProfessionsMenu[realmname][charname].tradeskills) do
				sortedprofs[GetSpellInfo(pid)] = { id = pid,profdata = _profdata}
			end
			--D:tprint(sortedprofs)
			for _,record in pairsByKeys(sortedprofs) do
				local id = record.id
				local profdata = record.profdata
				local name, _, icon = GetSpellInfo(id)
				local rank = profdata.data.rank
				local maxRank = profdata.data.maxRank
				name = ADDON:GetSpellDisplayName(name)
				if rank ~= "nil" and maxRank ~= "nil" then
					local rankcolor = ADDON:GetRankColor(rank,maxRank)
					ADDON.dropdown:AddFunc(name.." ("..rankcolor..rank..colorWhite.."/"..colorYellow..maxRank..colorWhite..")",function() ADDON:OpenAltProfFrame(value,id) end,tostring(icon))
				else
					ADDON.dropdown:AddFunc(name,function() ADDON:OpenAltProfFrame(value,id) end,tostring(icon))
				end
			end
			ADDON.dropdown:AddLine()
			info.tooltipFunc = function()
				local frame = GameTooltip:GetOwner()
				GameTooltip:SetOwner(frame, "ANCHOR_NONE")
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint(ADDON:GetTipAnchor2(frame))
				GameTooltip:ClearLines()
				GameTooltip:AddLine(L["deletechartooltip"])
			end
			ADDON.dropdown:AddFunc(DELETE,function() ADDON.save[value].tradeskills = {} end,"Interface\\Icons\\Ability_Rogue_FeignDeath",true,info.tooltipFunc)
		end
	end
end --function()

function ADDON.dropdown:ShowFavorites(owner)
	D:Debug("dropdown:ShowFavorites")
	local first=true
	for profid,v in pairsByKeys(ADDON.save[my].favorites) do
		local profname,_,proficon = GetSpellInfo(profid)
		D:Debug(profname)
		--		if not first then ADDON.dropdown:AddLine() end
		first=nil
		if (tcount(v) ~= 0) then
			ADDON.dropdown:AddTitle("|T"..proficon..":16:16:0:0|t "..profname)
		end
		local table = {}
		for recipeid,icon in pairs(v) do
			local name,_ = GetSpellInfo(recipeid)
			table[name] = {
				id = recipeid,
				icon = tostring(icon),
				tooltip=function()
					local frame = GameTooltip:GetOwner()
					GameTooltip:SetOwner(frame, "ANCHOR_NONE")
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint(ADDON:GetTipAnchor2(frame))
					GameTooltip:ClearLines()
					GameTooltip:SetHyperlink("|cffffffff|Henchant:"..tostring(recipeid).."|h["..name.."]|h|r")
					GameTooltip:AddLine(' ')
					--Cooldowns
					local duration=ADDON.save[my].cds[name]
					if duration then
						duration = difftime(duration,time())
						if duration > 0 then
							GameTooltip:AddDoubleLine(COOLDOWN_REMAINING,SecondsToTime(duration),1,0,0,1,0,0)
							GameTooltip:AddLine(' ')
						end
					end
					GameTooltip:AddDoubleLine(L["leftclick"],"|cffffffff"..CREATE_PROFESSION.."|r")
--						GameTooltip:AddDoubleLine(L["shift"].." + "..L["leftclick"],"|cffffffff"..CREATE_ALL.."|r")
					GameTooltip:AddDoubleLine(L["alt"].." + "..L["leftclick"],"|cffffffff"..DELETE.."|r")
				end,
				func = function()
					if IsAltKeyDown() then --Delete Favorite
						ADDON.save[my].favorites[profid][recipeid] = nil
						C_TradeSkillUI.SetRecipeFavorite(recipeid,false)
					else --Craft Item
						D:Debug("CraftRecipe")
						local numMade = IsShiftKeyDown() and C_TradeSkillUI.GetRecipeNumItemsProduced(recipeid) or 1
						if (ADDON:ShowTradeSkillFrame(profid)) then 
							_G.TradeSkillFrame:SelectRecipe(recipeid);
							--C_TradeSkillUI.SetRecipeRepeatCount(vv.id,numMade)
							C_TradeSkillUI.CraftRecipe(recipeid,numMade)
						end
					end
				end,
			}
		end
		
		for kk,vv in pairsByKeys(table) do
			ADDON.dropdown:AddFunc("   |T"..vv.icon..":16:16:0:0|t "..kk,vv.func,nil,nil,vv.tooltip)
		end
	end
	if first then ADDON.dropdown:AddTitle(L["nofavorites"]) end
end

--dropdown wrapper functions

--create a group 
function ADDON.dropdown:AddRadio(name,var,func,tooltipfunc, ...)
	local checked = false
 	if name == var then checked=true end
	ADDON.dropdown:AddLine('text',name,'func',func,'isRadio','true','checked',checked,'tooltipFunc',tooltipfunc,...)
end

--create a toggle (use func(var) to save you var)
function ADDON.dropdown:AddToggle(name, var, func, tooltipfunc, ...)
	local lfunc = function()
		var = not var
		if func then func(var) end
	end
	local checked = false
 	if var then checked=true end
 	if not tooltipfunc then tooltipfunc=function() return end end
	ADDON.dropdown:AddLine('text',name,'func',lfunc,'checked',checked,'tooltipFunc',tooltipfunc,...)
end

--create a button
function ADDON.dropdown:AddFunc(name, func, icon, closewhenclicked, tooltipfunc, ...)
	if closewhenclicked==nil then closewhenclicked=false end
	if not tooltipfunc then tooltipfunc=function() return end end
	ADDON.dropdown:AddLine('text',name,'icon',icon,'func',func,'tooltipFunc',tooltipfunc,'closeWhenClicked',closewhenclicked,...)
end

--create clickable spell button
function ADDON.dropdown:AddSpell(name, spell, icon, closewhenclicked, tooltipfunc, ...)
	if closewhenclicked==nil then closewhenclicked=false end
	if not tooltipfunc then tooltipfunc=function() return end end
	ADDON.dropdown:AddLine('text',name,'icon',icon,'secure',{type1='spell',spell=spell},'tooltipFunc',tooltipfunc,'closeWhenClicked',closewhenclicked,...)
end

--create a submenu
function ADDON.dropdown:AddArrow(name, value, icon, tooltipfunc, func, ...)
	if not tooltipfunc then tooltipfunc=function() return end end
	ADDON.dropdown:AddLine('hasArrow',true,'text',name,'icon',icon,'value',value,'tooltipFunc',tooltipfunc,...)
end

--add title line
function ADDON.dropdown:AddTitle(name, icon, ...)
	ADDON.dropdown:AddLine('isTitle',true,'text',name,'icon',icon,...)
end

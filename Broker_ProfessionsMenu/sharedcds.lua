--------------------------------------------------------------------------------
--Shared CDs (can also be used to rename cds)
--------------------------------------------------------------------------------
local ADDON = select(2,...)                                 --Includes all functions and variables

local SharedCDs = {
	
	--<Alchemy>--

		--Legion 
	-- [188800] = ADDON.L["legion_alchemy"],--Wild Transmutation
	-- [188801] = ADDON.L["legion_alchemy"],--Wild Transmutation
	-- [188802] = ADDON.L["legion_alchemy"],--Wild Transmutation
	[213257] = ADDON.L["legion_alchemy"],--Transmute: Blood of Sargeras
	[213256] = ADDON.L["legion_alchemy"],--Transmute: Meat to Pet
	[213252] = ADDON.L["legion_alchemy"],--Transmute: Cloth to Herbs
	[213249] = ADDON.L["legion_alchemy"],--Transmute: Cloth to Skins
	[213254] = ADDON.L["legion_alchemy"],--Transmute: Fish to Gems
	[213255] = ADDON.L["legion_alchemy"],--Transmute: Meat to Pants
	[213248] = ADDON.L["legion_alchemy"],--Transmute: Ore to Cloth
	[213251] = ADDON.L["legion_alchemy"],--Transmute: Ore to Herbs
	[213253] = ADDON.L["legion_alchemy"],--Transmute: Skins to Herbs
	[213250] = ADDON.L["legion_alchemy"],--Transmute: Skins to Ore

		--WoD
	-- [175880] = true,	-- Secrets of Draenor
	-- [156587] = true,	-- Alchemical Catalyst (4)
	-- [168042] = true,	-- Alchemical Catalyst (10), 3 charges w/ 24hr recharge
	[181643] = ADDON.L["transmute"], --Transmute: Savage Blood

		--MOP
	[114780] = ADDON.L["transmute"], --Transmute: Living Steel

		--Cata
	[80244] = ADDON.L["transmute"], --Transmute: Pyrium Bar
	[78866] = ADDON.L["transmute"], --Transmute: Living Elements

		--WotLk
	[66658] = ADDON.L["transmute"], --Transmute: Ametrine
	[66659] = ADDON.L["transmute"], --Transmute: Cardinal Ruby
	[66660] = ADDON.L["transmute"], --Transmute: King's Amber
	[66662] = ADDON.L["transmute"], --Transmute: Dreadstone
	[66663] = ADDON.L["transmute"], --Transmute: Majestic Zircon
	[66664] = ADDON.L["transmute"], --Transmute: Eye of Zul
	[53777] = ADDON.L["transmute"],-- Transmute: Eternal Air to Earth
	[53776] = ADDON.L["transmute"],-- Transmute: Eternal Air to Water
	[53781] = ADDON.L["transmute"], --Transmute: Eternal Earth to Air
	[53782] = ADDON.L["transmute"],-- Transmute: Eternal Earth to Shadow
	[53775] = ADDON.L["transmute"],-- Transmute: Eternal Fire to Life
	[53774] = ADDON.L["transmute"],-- Transmute: Eternal Fire to Water
	[53773] = ADDON.L["transmute"],-- Transmute: Eternal Life to Fire
	[53771] = ADDON.L["transmute"],-- Transmute: Eternal Life to Shadow
	[54020] = ADDON.L["transmute"],-- Transmute: Eternal Might
	[53779] = ADDON.L["transmute"],-- Transmute: Eternal Shadow to Earth
    [53780] = ADDON.L["transmute"],-- Transmute: Eternal Shadow to Life
	[53783] = ADDON.L["transmute"],-- Transmute: Eternal Water to Air
	[53784] = ADDON.L["transmute"],-- Transmute: Eternal Water to Fire

		--BC
	[28566] = ADDON.L["transmute"],-- Transmute: Primal Air to Fire
	[28585] = ADDON.L["transmute"], --Transmute: Primal Earth to Life
	[28567] = ADDON.L["transmute"],-- Transmute: Primal Earth to Water
	[28568] = ADDON.L["transmute"],-- Transmute: Primal Fire to Earth
	[28583] = ADDON.L["transmute"],-- Transmute: Primal Fire to Mana
	[28584] = ADDON.L["transmute"],-- Transmute: Primal Life to Earth
	[28582] = ADDON.L["transmute"],-- Transmute: Primal Mana to Fire
	[28580] = ADDON.L["transmute"],-- Transmute: Primal Shadow to Water
	[28569] = ADDON.L["transmute"],-- Transmute: Primal Water to Air
	[28581] = ADDON.L["transmute"],-- Transmute: Primal Water to Shadow

		--Classic 
	[11479] = ADDON.L["transmute"],--Transmute: Iron to Gold
	[11480] = ADDON.L["transmute"],--Transmute: Mithril to Truesilver
	[17559] = ADDON.L["transmute"],-- Transmute: Air to Fire
	[17566] = ADDON.L["transmute"],-- Transmute: Earth to Life
	[17561] = ADDON.L["transmute"],-- Transmute: Earth to Water
	[17560] = ADDON.L["transmute"],-- Transmute: Fire to Earth
	[17565] = ADDON.L["transmute"],-- Transmute: Life to Earth
	[17563] = ADDON.L["transmute"],-- Transmute: Undeath to Water	
	[17562] = ADDON.L["transmute"],-- Transmute: Water to Air
	[17564] = ADDON.L["transmute"],-- Transmute: Water to Undeath
			
	--<Enchanting>--

	[28027] = ADDON.L["sphere"],-- Prismatic Sphere (2-day shared, 5.2.0 verified)
	[28028] = ADDON.L["sphere"],-- Void Sphere (2-day shared, 5.2.0 verified)
--	[116499] = true, 	-- Sha Crystal
--	[177043] = true,	-- Secrets of Draenor
--	[169092] = true,	-- Temporal Crystal

	--<Jewelcrafting>>--

		--WoD
	--[176087] = ADDON.L["draenor_jewelcrafting"],-- Secrets of Draenor Jewelcrafting (not shared)
	--[170700] = ADDON.L["draenor_jewelcrafting"],-- Taladite Crystal (not shared)
	--[140050] = ADDON.L["draenor_jewelcrafting"],-- Serpent's Heart (not shared)

		--MOP
	[131691] = ADDON.L["pandaria_research"],-- Imperial Amethyst/Facets of Research
	[131686] = ADDON.L["pandaria_research"],-- Primordial Ruby/Facets of Research
	[131593] = ADDON.L["pandaria_research"],-- River's Heart/Facets of Research
	[131695] = ADDON.L["pandaria_research"],-- Sun's Radiance/Facets of Research
	[131690] = ADDON.L["pandaria_research"],-- Vermilion Onyx/Facets of Research
	[131688] = ADDON.L["pandaria_research"],-- Wild Jade/Facets of Research

	[47280] = ADDON.L["pandaria_research"], -- Brilliant Glass, still has a cd (5.2.0 verified)
	--[62242] = true, 	-- Icy Prism, cd removed (5.2.0 verified)
	[73478] = ADDON.L["pandaria_research"],-- Fire Prism, still has a cd (5.2.0 verified)

	--<Tailoring>--
	-- [143011] = true,-- Celestial Cloth
	-- [125557] = true,-- Imperial Silk
	-- [176058] = true,-- Secrets of Draenor
	-- [168835] = true,-- Hexweave Cloth
	-- [18560] = true,	-- Mooncloth, cd removed (5.2.0 verified, tooltip is wrong)

	--<Inscription>--
	-- [61288] = true, 	-- Minor Inscription Research
	-- [61177] = true, 	-- Northrend Inscription Research
	-- [86654] = true, 	-- Horde Forged Documents
	-- [89244] = true, 	-- Alliance Forged Documents
	-- [112996] = true, -- Scroll of Wisdom
	-- [169081] = true,	-- War Paints
	-- [177045] = true,	-- Secrets of Draenor
	-- [176513] = true,	-- Draenor Merchant Order

	--<Blacksmithing>--
	-- [138646] = true, 	-- Lightning Steel Ingot
	-- [143255] = true,	-- Balanced Trillium Ingot
	-- [171690] = true,	-- Truesteel Ingot
	-- [176090] = true,	-- Secrets of Draenor

	--<Leatherworking>--
	[140040] = ADDON.L["magnificence"], -- Magnificence of Leather
	[140041] = ADDON.L["magnificence"],	-- Magnificence of Scales
	-- [142976] = true,	-- Hardened Magnificent Hide
	-- [171391] = true,	-- Burnished Leather
	-- [176089] = true,	-- Secrets of Draenor

	--<Engineering>--
	-- [139176] = true,	-- Stabilized Lightning Source
	-- [169080] = true, 	-- Gearspring Parts
	-- [177054] = true,	-- Secrets of Draenor
}

ADDON.LongCDs = {

	--<Alchemy>--
	[60893] = 3, -- Northrend Alchemy Research: 3 days

	--<Tailoring>--
	[56005] = 7, 		-- Glacial Bag (5.2.0 verified)
		-- Dreamcloth
	[75141] = 7, 		-- Dream of Skywall
	[75145] = 7, 		-- Dream of Ragnaros
	[75144] = 7, 		-- Dream of Hyjal
	[75142] = 7,	 	-- Dream of Deepholm
	[75146] = 7, 		-- Dream of Azshara
}

for id, name in pairs(SharedCDs) do
	if GetSpellInfo(id) then 			--check if spell exists
		ADDON.sharedcds[GetSpellInfo(id)] = name
	end
end

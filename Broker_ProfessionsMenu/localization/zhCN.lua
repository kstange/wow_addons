local ADDON = select(2,...)                                 --Includes all functions and variables

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON.name, "zhCN", false, ADDON.debug)
if not L then return end

L["additemtoignorelist"] = "添加物品到忽略列表"
L["addtofav"] = "添加到收藏夹"
L["alt"] = "ALT"
L["autoloot"] = " (+ 自动拾取)"
L["bothfactions"] = "显示两边阵营专业技能和冷却"
L["cds"] = "冷却状态"
L["coodownexpired"] = "冷却完成"
L["ctrl"] = "CTRL"
L["databaseempty"] = "空数据库"
L["deletechartooltip"] = "|cffff0000注意:|r 清除本角色所有设置!"
L["deleteignoreditemtooltip"] = "从忽略列表删除"
L["delrealm"] = "删除阵营所有角色"
L["draenor_jewelcrafting"] = "德拉诺珠宝加工"
L["favorites"] = "收藏夹"
L["filter"] = "隐藏专业技能"
L["ignores"] = "已忽略物品"
L["infight"] = "你在战斗中!"
L["knowallrecipes"] = "|cffffcf00所有配方都已学会|r"
L["leftclick"] = "左键点击"
--[[Translation missing --]]
--[[ L["legion_alchemy"] = "Legion Transmutation"--]] 
L["linktome"] = "发送到自身"
L["linktoother"] = "发送到聊天框"
--[[Translation missing --]]
--[[ L["magnificence"] = "Magnificence"--]] 
L["menufontsize"] = "菜单字体大小"
L["nocds"] = "准备就绪"
--[[Translation missing --]]
--[[ L["nofavorites"] = "No Favorites"--]] 
L["nomats"] = "没有足够的材料"
L["openLastProfessionWindow"] = "打开最后一次打开过的专业技能窗口"
L["openmenu"] = "打开选项菜单"
L["otherchar"] = "其他角色"
--[[Translation missing --]]
--[[ L["pandaria_research"] = "Pandaria research"--]] 
L["professions"] = "专业技能"
L["quicklaunch"] = "快速启动"
L["quicklauncher"] = "独立显示于信息条"
L["relog"] = "需要重载插件!"
L["removefromfav"] = "从收藏夹移除"
L["resetcds"] = "重置冷却"
L["rightclick"] = "右键点击"
L["settings"] = "设置"
L["shift"] = "Shift"
L["ShowAllTooltips"] = "显示所有鼠标提示"
L["showbuttons"] = "按键说明"
L["showcds"] = "冷却状态"
L["showcrosscds"] = "显示跨阵营的冷却"
L["showfavorites"] = "显示收藏夹"
L["ShowIfYouCanCraftThisInItemTooltips"] = "如果你能制造,则显示于物品提示中"
L["showlastprofinldb"] = "信息条显示为最后打开的专业"
--[[Translation missing --]]
--[[ L["sphere"] = "Sphere"--]] 
--[[Translation missing --]]
--[[ L["tooltip_showexpansionname"] = "Show Expansion Name"--]] 
--[[Translation missing --]]
--[[ L["tooltip_showexpansionranks"] = "Show Expansion Ranks"--]] 
L["tooltips"] = "鼠标提示"
L["transmute"] = "炼金术: 转化"


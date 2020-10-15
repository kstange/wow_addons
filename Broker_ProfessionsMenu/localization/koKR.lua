local ADDON = select(2,...)                                 --Includes all functions and variables

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON.name, "koKR", false, ADDON.debug)
if not L then return end

L["additemtoignorelist"] = "무시리스트에 아이템 추가"
L["addtofav"] = "즐겨찾기에 추가"
L["alt"] = "ALT"
L["autoloot"] = " (+ 자동 획득)"
L["bothfactions"] = "양진영 모두 전문기술 및 재사용 대기시간 표시"
L["cds"] = "재사용 대기시간"
L["coodownexpired"] = "재사용 대기시간 초기화!"
L["ctrl"] = "CTRL"
L["databaseempty"] = "자료 없음"
L["deletechartooltip"] = "|cffff0000주의:|r 현재 캐릭터의 모든 설정이 초기화됩니다!"
L["deleteignoreditemtooltip"] = "무시리스트에서 삭제"
L["delrealm"] = "서버의 모든 캐릭터 삭제!"
L["draenor_jewelcrafting"] = "드레노어 보석세공"
L["favorites"] = "즐겨찾기"
L["filter"] = "전문기술 숨김"
L["ignores"] = "무시된 아이템"
L["infight"] = "현재 전투중!"
L["knowallrecipes"] = "|cffffcf00모든 제조법을 배웠습니다.|r"
L["leftclick"] = "왼쪽 클릭"
L["legion_alchemy"] = "군단 연금술"
L["linktome"] = "내 캐릭터에 링크 표시"
L["linktoother"] = "대화창으로 링크 표시"
--[[Translation missing --]]
--[[ L["magnificence"] = "Magnificence"--]] 
L["menufontsize"] = "메뉴 글꼴 크기"
L["nocds"] = "모두 준비 완료"
L["nofavorites"] = "관심없음"
--[[Translation missing --]]
--[[ L["nomats"] = "No Mats"--]] 
L["openLastProfessionWindow"] = "최근에 사용했던 전문기술 창을 엽니다."
L["openmenu"] = "메뉴 열기"
L["otherchar"] = "다른 캐릭터"
L["pandaria_research"] = "판다리아 연구"
L["professions"] = "전문기술"
L["quicklaunch"] = "단축키 설정"
L["quicklauncher"] = "별도의 빠른연결 만들기"
L["relog"] = "게임을 재접속 하세요!"
L["removefromfav"] = "즐겨찾기에서 삭제"
L["resetcds"] = "재사용 대기시간 초기화"
L["rightclick"] = "오른쪽 클릭"
L["settings"] = "설정"
L["shift"] = "Shift"
L["ShowAllTooltips"] = "모든 툴팁 표시"
L["showbuttons"] = "버튼"
L["showcds"] = "재사용 대기시간"
L["showcrosscds"] = "다른 서버 재사용 대기시간 표시"
L["showfavorites"] = "즐겨찾기 표시"
L["ShowIfYouCanCraftThisInItemTooltips"] = "제작이 가능한 아이템인 경우 툴팁에 표시"
L["showlastprofinldb"] = "브로커에 최근 사용한 전문기술 표시"
--[[Translation missing --]]
--[[ L["sphere"] = "Sphere"--]] 
--[[Translation missing --]]
--[[ L["tooltip_showexpansionname"] = "Show Expansion Name"--]] 
--[[Translation missing --]]
--[[ L["tooltip_showexpansionranks"] = "Show Expansion Ranks"--]] 
L["tooltips"] = "툴팁"
L["transmute"] = "변환식"


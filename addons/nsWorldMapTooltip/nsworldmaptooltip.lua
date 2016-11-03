-- nsWorldMapTooltip v1.0.0 By Nasiko
-- Refer: @TreeOfSaviorTW/data/ui.ipf/uiscp/tooltip_worldmap.lua 世界地圖的提示

local isLoaded = false;

local function SetupHook(newFunction, hookedFunctionName)
	local storeOldFunc = hookedFunctionName .. "_OLD";
	if _G[storeOldFunc] == nil then
		_G[storeOldFunc] = _G[hookedFunctionName];
		_G[hookedFunctionName] = newFunction;
	else
		_G[hookedFunctionName] = newFunction;
	end
end

local function NS_SCR_GET_ZONE_FACTION_OBJECT(zoneClassName, factionList, monRankList, respawnTime)
    local zoneGentype = 'GenType_'..zoneClassName;
    local classCount = GetClassCount(zoneGentype);
    local factionList = SCR_STRING_CUT(factionList);
    local monRankList = SCR_STRING_CUT(monRankList);
    local i;
    local monList = {};
    for i = 0 , classCount -1 do
        local gentypeIES = GetClassByIndex(zoneGentype, i);
        if gentypeIES ~= nil and table.find(factionList, gentypeIES.Faction) > 0 and gentypeIES.MaxPop > 0 then
            if respawnTime == nil or gentypeIES.RespawnTime <= respawnTime then
                local monIES = GetClass('Monster', gentypeIES.ClassType);
                if monIES ~= nil then
                    local rankFlag = 'YES';
                    if #monRankList > 0 and GetPropType(monIES,'MonRank') ~= nil and table.find(monRankList,monIES.MonRank) == 0 then
                        rankFlag = 'NO';
                    end
                    if rankFlag == 'YES' then
                        local flag = false;
                        if #monList > 0 then
                            for j = 1, #monList do
                                if monList[j][1] == gentypeIES.ClassType then
                                    monList[j][2] = monList[j][2] + gentypeIES.MaxPop;
                                    flag = true;
                                    break
                                end
                            end
                        end
                        if flag == false then
                            monList[#monList + 1] = {};
                            monList[#monList][1] = gentypeIES.ClassType;
                            monList[#monList][2] = gentypeIES.MaxPop;
                            monList[#monList][3] = monIES.MonRank;
                            monList[#monList][4] = monIES.Level;-- + gentypeIES.Lv;
                        end
                    end
                end
            end
        end
    end
    
    return monList
end

function WORLDMAP_TOOLTIP_POSSIBLE_QUESTLIST_HOOKED(frame, mapName, numarg, ctrlSet, drawCls)
    local questClsList, questCnt = GetClassList('QuestProgressCheck');	
	local subX = 15
	local subY = 55
	local viewCount = 1
	local pc = GetMyPCObject();
    for index = 0, questCnt-1 do
    	local questIES = GetClassByIndexFromList(questClsList, index);
    	if questIES.StartMap == drawCls.ClassName and questIES.PossibleUI_Notify ~= 'NO' and questIES.QuestMode == 'MAIN' and questIES.Level ~= 9999 and questIES.Lvup ~= -9999 and questIES.QuestStartMode ~= 'NPCENTER_HIDE' then
    		local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
    		if result == 'POSSIBLE' then
    		    local picture = ctrlSet:CreateOrGetControl('picture', "questListBoxIcon"..viewCount, subX, subY + (viewCount - 1)*20, 20, 20);
                tolua.cast(picture, "ui::CPicture");
                picture:SetImage(GET_QUESTINFOSET_ICON_BY_STATE_MODE(result, questIES));
                picture:SetEnableStretch(1);
        		local questListBox = ctrlSet:CreateControl('richtext', "questListBox"..viewCount, subX + 20, subY + (viewCount - 1)*20, 20, 100);
                questListBox:SetText('{@st70_m}'..questIES.Name..'{/}');
                viewCount = viewCount + 1
            end
    	end
    end
    for index = 0, questCnt-1 do
    	local questIES = GetClassByIndexFromList(questClsList, index);
    	if questIES.StartMap == drawCls.ClassName and questIES.PossibleUI_Notify ~= 'NO' and questIES.QuestMode ~= 'MAIN' and questIES.Level ~= 9999 and questIES.Lvup ~= -9999 and questIES.QuestStartMode ~= 'NPCENTER_HIDE' then
    		local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName)
    		if result == 'POSSIBLE' then
    		    local picture = ctrlSet:CreateOrGetControl('picture', "questListBoxIcon"..viewCount, subX, subY + (viewCount - 1)*20, 20, 20);
                tolua.cast(picture, "ui::CPicture");
                picture:SetImage(GET_QUESTINFOSET_ICON_BY_STATE_MODE(result, questIES));
                picture:SetEnableStretch(1);
        		local questListBox = ctrlSet:CreateControl('richtext', "questListBox"..viewCount, subX + 20, subY + (viewCount - 1)*20, 20, 100);
        		if questIES.QuestMode == 'SUB' then
                    questListBox:SetText('{@st70_s}'..questIES.Name);
                elseif questIES.QuestMode == 'REPEAT' then
                    questListBox:SetText('{@st70_d}'..questIES.Name);
                else
                    questListBox:SetText('{@st70_s}'..questIES.Name);
                end
                viewCount = viewCount + 1
            end
    	end
    end
	
	-- 一般/特殊/菁英/BOSS
	local MonList = NS_SCR_GET_ZONE_FACTION_OBJECT(drawCls.ClassName, "Monster", "Normal/Special/Elite/Boss", 120000);

	for key, value in pairs(MonList) do
		local MonClassType = value[1];
		local MonMaxPop = value[2];
		local MonRank = value[3];
		local MonLv = value[4];
		
		local monCls = GetClass("Monster", MonClassType);
		
		local picture = ctrlSet:CreateOrGetControl('picture', "questListBoxIcon"..viewCount, subX, subY + (viewCount - 1)*20, 20, 20);
		tolua.cast(picture, "ui::CPicture");
		picture:SetImage(GET_MON_ILLUST(monCls));
        picture:SetEnableStretch(1);
		local questListBox = ctrlSet:CreateControl('richtext', "questListBox"..viewCount, subX + 20, subY + (viewCount - 1)*20, 20, 100);
		if MonRank == "Boss" then
			questListBox:SetText('{@st70_s}{#FF2D2D}[BOSS]Lv.' .. MonLv .. " " .. monCls.Name .. "(" .. MonMaxPop .. ")");
		elseif  MonRank == "Special" then
			questListBox:SetText('{@st70_s}{#2894FF}[特殊]Lv.' .. MonLv .. " " .. monCls.Name .. "(" .. MonMaxPop .. ")");
		elseif  MonRank == "Elite" then
			questListBox:SetText('{@st70_s}{#FF8000}[菁英]Lv.' .. MonLv .. " " .. monCls.Name .. "(" .. MonMaxPop .. ")");
		else
			questListBox:SetText('{@st70_s}{#FFFFFF}[一般]Lv.' .. MonLv .. " " .. monCls.Name .. "(" .. MonMaxPop .. ")");
		end
		viewCount = viewCount + 1;
	end
end

function NSWORLDMAPTOOLTIP_ON_INIT(addon, frame)
	if not isLoaded then
		-- 複寫 tooltip_worldmap.lua 的 WORLDMAP_TOOLTIP_POSSIBLE_QUESTLIST 方法
		SetupHook(WORLDMAP_TOOLTIP_POSSIBLE_QUESTLIST_HOOKED, "WORLDMAP_TOOLTIP_POSSIBLE_QUESTLIST");
		isLoaded = true;
	end
end

local addonName = "SkillSpendItem";
local verText = "1.0.2";
local verSettings = 1;
local autherName = "NASIKO";
local addonNameLower = string.lower(addonName);
local SettingFileName = "setting.json";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];

Me.Loaded = false;
Me.DebugMode = false;
Me.SettingFilePathName = string.format("../addons/%s/%s", addonNameLower, SettingFileName);

Me.HoockedOrigProc = Me.HoockedOrigProc or {};
Me.SpendItemTable = {};
Me.SpendItemCount = 0;
Me.SkillList = {};
Me.ItemCraftList = {};

-- 侍從(Squire)
Me.SkillList[1011] = {};
Me.SkillList[1011][10703] = { ClassName = "Squire_Repair", SpendItem = "misc_repairkit_1"}; -- 維修(Repair)
Me.SkillList[1011][10709] = { ClassName = "Squire_EquipmentTouchUp", SpendItem = "misc_whetstone"}; -- 整修裝備(Equipment Maintenance)
Me.SkillList[1011][10705] = { ClassName = "Squire_Camp", SpendItem = "misc_campkit"}; -- 設置營地(Base Camp)
Me.SkillList[1011][10706] = { ClassName = "Squire_FoodTable", SpendItem = "misc_campkit"}; -- 設置餐台(Food Table)


Me.ItemCraftList[1011] = {};
Me.ItemCraftList[1011][1] = { TargetItem = "misc_campkit",	Items = {}, Cnt = 10 };
Me.ItemCraftList[1011][1].Items[1] = { ClassName = "food_020", Cnt = 0 }; -- 松茸
Me.ItemCraftList[1011][1].Items[2] = { ClassName = "food_035", Cnt = 0 }; -- 牛奶
Me.ItemCraftList[1011][1].Items[3] = { ClassName = "food_041", Cnt = 0 }; -- 烤肉專用肉
Me.ItemCraftList[1011][1].Items[4] = { ClassName = "food_034", Cnt = 0 }; -- 萵苣
Me.ItemCraftList[1011][1].Items[5] = { ClassName = "food_038", Cnt = 0 }; -- 葡萄
Me.ItemCraftList[1011][1].Items[6] = { ClassName = "food_033", Cnt = 0 }; -- 麵包
Me.ItemCraftList[1011][1].Items[7] = { ClassName = "food_040", Cnt = 0 }; -- 蔥

-- 鍊金(Alchemist)
Me.SkillList[2005] = {};
Me.SkillList[2005][21003] = { ClassName = "Alchemist_Roasting", SpendItem = "misc_catalyst_1"}; -- 寶石烘培(Gem Roasting)
Me.SkillList[2005][21007] = { ClassName = "Alchemist_ItemAwakening", SpendItem = "misc_wakepowder"}; -- 道具覺醒(Item Awakening)

Me.ItemCraftList[2005] = {};
Me.ItemCraftList[2005][1] = { TargetItem = "Drug_Alche_HP",	Items = {}, Cnt = 5 };
Me.ItemCraftList[2005][1].Items[1] = { ClassName = "misc_flask", Cnt = 1 };
Me.ItemCraftList[2005][1].Items[2] = { ClassName = "food_002", Cnt = 2 };
Me.ItemCraftList[2005][1].Items[3] = { ClassName = "food_014", Cnt = 2 };

Me.ItemCraftList[2005][2] = { TargetItem = "Drug_Alche_SP",	Items = {}, Cnt = 5 };
Me.ItemCraftList[2005][2].Items[1] = { ClassName = "misc_flask", Cnt = 1 };
Me.ItemCraftList[2005][2].Items[2] = { ClassName = "food_001", Cnt = 3 };
Me.ItemCraftList[2005][2].Items[3] = { ClassName = "food_004", Cnt = 1 };

-- 附魔(Enchanter)
Me.ItemCraftList[2018] = {};
Me.ItemCraftList[2018][1] = { TargetItem = "Use_item_enchantBomb",	Items = {}, Cnt = 1 };
Me.ItemCraftList[2018][1].Items[1] = { ClassName = "misc_EnchantedPowder", Cnt = 10 };

-- 造箭(Fletcher)
Me.ItemCraftList[3011] = {};
Me.ItemCraftList[3011][1] = { TargetItem = "arrow_01",	Items = {}, Cnt = 100 };
Me.ItemCraftList[3011][1].Items[1] = { ClassName = "wood_01", Cnt = 20 };

Me.ItemCraftList[3011][2] = { TargetItem = "arrow_02",	Items = {}, Cnt = 100 };
Me.ItemCraftList[3011][2].Items[1] = { ClassName = "wood_02", Cnt = 20 };

Me.ItemCraftList[3011][3] = { TargetItem = "arrow_03",	Items = {}, Cnt = 100 };
Me.ItemCraftList[3011][3].Items[1] = { ClassName = "wood_03", Cnt = 20 };

Me.ItemCraftList[3011][4] = { TargetItem = "arrow_04",	Items = {}, Cnt = 100 };
Me.ItemCraftList[3011][4].Items[1] = { ClassName = "wood_04", Cnt = 20 };

Me.ItemCraftList[3011][5] = { TargetItem = "arrow_05",	Items = {}, Cnt = 100 };
Me.ItemCraftList[3011][5].Items[1] = { ClassName = "wood_01", Cnt = 20 };
Me.ItemCraftList[3011][5].Items[2] = { ClassName = "misc_gunpowder", Cnt = 10 };

Me.ItemCraftList[3011][6] = { TargetItem = "arrow_06",	Items = {}, Cnt = 100 };
Me.ItemCraftList[3011][6].Items[1] = { ClassName = "wood_02", Cnt = 20 };
Me.ItemCraftList[3011][6].Items[2] = { ClassName = "misc_0116", Cnt = 10 };

-- 鑑定師(Appraiser)
Me.SkillList[3013] = {};
Me.SkillList[3013][31501] = { ClassName = "Appraiser_Apprise", SpendItem = "misc_0507"}; -- 鑑定(Apprise)

-- 邪靈祭司(Bokor)
Me.SkillList[4004] = {};
Me.SkillList[4004][40304] = { ClassName = "Bokor_Zombify", SpendItem = "Zombie_Capsule"}; -- 製造殭屍(Zombify)

-- 寬恕(Pardoner)
Me.ItemCraftList[4010] = {};
Me.ItemCraftList[4010][1] = { TargetItem = "Dispeller_1",	Items = {}, Cnt = 1 };
Me.ItemCraftList[4010][1].Items[1] = { ClassName = "misc_parchment", Cnt = 2 };

Me.ItemCraftList[4010][2] = { TargetItem = "Antimagic_1",	Items = {}, Cnt = 1 };
Me.ItemCraftList[4010][2].Items[1] = { ClassName = "misc_parchment", Cnt = 2 };

-- 巫女(Miko)
Me.ItemCraftList[4018] = {};
Me.ItemCraftList[4018][1] = { TargetItem = "Bujeok_1",	Items = {}, Cnt = 1 };
Me.ItemCraftList[4018][1].Items[1] = { ClassName = "misc_parchment", Cnt = 5 };

local acutil = require('acutil');

Me.Settings = {
	-- 版本(存檔格式的版本)
	version = verSettings,
	-- 是否顯示
	show = 1,
	-- Normal = 正常, Min = 縮小
	size = "Normal",
	-- 視窗位置x座標
	xPos = 1560,
	-- 視窗位置y座標
	yPos = 300,
	-- Landscape橫, Portrait直
	displaymode = "Landscape",
	-- 是否顯示製作物品
	itemcraft = 1,
};

local Nasiko = {
	Log = function(self, Message, Mode) 
		
		if Message == nil then return end
		if Mode == nil and (not Me.DebugMode) then return end

		local header = "";
		if Mode == nil then 
			header = string.format("{#EDEDED}[{#FF9696}Debug{#EDEDED}][{#FF9696}%s{#EDEDED}]", addonName); 
		else
			header = string.format("{#EDEDED}[{#ADADFF}%s{#EDEDED}]", Mode); 
		end
		
		CHAT_SYSTEM(string.format("%s%s{nl}", header, Message));
	end
};

function Me.GetSkillSpendItem()
	local cid = info.GetCID(session.GetMyHandle());
	local pcSession = session.GetSessionByCID(cid);
	local pcJobInfo = pcSession.pcJobInfo;
	local skillList = pcSession.skillList;
	local cnt = pcJobInfo:GetJobCount();
	local pc = GetPCObjectByCID(cid);
	
	local jobList, jobCnt  = GetClassList("Job");
	local streeList, streeCnt  = GetClassList("SkillTree");
	
	Me.SpendItemTable = {};
	Me.SpendItemCount = 0;
	
	--Nasiko:Log("##############################");
	
	for i = 0, cnt -1 do
		local jobID = pcJobInfo:GetJobByIndex(i);
		if jobID == -1 then
			break;
		end
		
		local jobInfo = GetClassByTypeFromList(jobList, jobID);
		local index = 1;
		local jobName = jobInfo.ClassName;
		
		while 1 do
			local name = jobName .. "_" ..index;
			local cls = GetClassByNameFromList(streeList, name);
			if cls == nil then
				break;
			end
			
			local maxLv = GET_SKILLTREE_MAXLV(pc, jobName, cls);
			
			if 0 < maxLv then
				local skl = skillList:GetSkillByName(cls.SkillName)
				if skl ~= nil then
					objSkill = GetIES(skl:GetObject());	
					if objSkill.SpendItem ~= nil and objSkill.SpendItem ~= "" and objSkill.SpendItem ~= "None" and objSkill.SpendItem ~= "Vis" then
						local SpendItemInfo = GetClass("Item", objSkill.SpendItem);
						if SpendItemInfo ~= nil then
							if Me.SpendItemTable[SpendItemInfo.ClassID] == nil then
								--Nasiko:Log(string.format("SkillName:%s, SpendItem:%s[%s]", objSkill.Name, SpendItemInfo.Name, SpendItemInfo.ClassID));
								Me.SpendItemTable[SpendItemInfo.ClassID] = {};
								Me.SpendItemTable[SpendItemInfo.ClassID].ClassID = SpendItemInfo.ClassID;
								Me.SpendItemTable[SpendItemInfo.ClassID].ClassName = SpendItemInfo.ClassName;
								Me.SpendItemTable[SpendItemInfo.ClassID].Name = SpendItemInfo.Name;
								Me.SpendItemTable[SpendItemInfo.ClassID].Icon = SpendItemInfo.Icon;
								Me.SpendItemCount = Me.SpendItemCount + 1;
							end
						end
					end
					
					if Me.SkillList[jobID] then
						if Me.SkillList[jobID][objSkill.ClassID] then
							local SpendItemInfo = GetClass("Item", Me.SkillList[jobID][objSkill.ClassID].SpendItem);
							if SpendItemInfo ~= nil then
							if Me.SpendItemTable[SpendItemInfo.ClassID] == nil then
								--Nasiko:Log(string.format("SkillName:%s, SpendItem:%s[%s]", objSkill.Name, SpendItemInfo.Name, SpendItemInfo.ClassID));
								Me.SpendItemTable[SpendItemInfo.ClassID] = {};
								Me.SpendItemTable[SpendItemInfo.ClassID].ClassID = SpendItemInfo.ClassID;
								Me.SpendItemTable[SpendItemInfo.ClassID].ClassName = SpendItemInfo.ClassName;
								Me.SpendItemTable[SpendItemInfo.ClassID].Name = SpendItemInfo.Name;
								Me.SpendItemTable[SpendItemInfo.ClassID].Icon = SpendItemInfo.Icon;
								Me.SpendItemCount = Me.SpendItemCount + 1;
							end
						end
						end
					end
				end
			end
			index = index + 1;
		end
		
		if Me.ItemCraftList[jobID] and Me.Settings.itemcraft == 1 then
			for k, v in pairs(Me.ItemCraftList[jobID]) do
				local SpendItemInfo = GetClass("Item", v.TargetItem);
				if SpendItemInfo ~= nil then
					if jobID ~= 3011 or (jobID == 3011 and Me.SpendItemTable[SpendItemInfo.ClassID] ~= nil) then
						if Me.SpendItemTable[SpendItemInfo.ClassID] == nil then
							--Nasiko:Log(string.format("ItemCraft:%s[%s]", SpendItemInfo.Name, SpendItemInfo.ClassID));
							Me.SpendItemTable[SpendItemInfo.ClassID] = {};
							Me.SpendItemTable[SpendItemInfo.ClassID].ClassID = SpendItemInfo.ClassID;
							Me.SpendItemTable[SpendItemInfo.ClassID].ClassName = SpendItemInfo.ClassName;
							Me.SpendItemTable[SpendItemInfo.ClassID].Name = SpendItemInfo.Name;
							Me.SpendItemTable[SpendItemInfo.ClassID].Icon = SpendItemInfo.Icon;
							Me.SpendItemCount = Me.SpendItemCount + 1;
						end
					
						if Me.SpendItemTable[SpendItemInfo.ClassID].Items == nil then
							local itemsCnt = 0;
							Me.SpendItemTable[SpendItemInfo.ClassID].Items = {};
							for subk, subv in pairs(v.Items) do
								local subSpendItemInfo = GetClass("Item", subv.ClassName);
								if subSpendItemInfo ~= nil then
									if Me.SpendItemTable[SpendItemInfo.ClassID].Items[subSpendItemInfo.ClassID] == nil then
										--Nasiko:Log(string.format("ItemCraft:%s[%s]", subSpendItemInfo.Name, subSpendItemInfo.ClassID));
										Me.SpendItemTable[SpendItemInfo.ClassID].Items[subSpendItemInfo.ClassID] = {};
										Me.SpendItemTable[SpendItemInfo.ClassID].Items[subSpendItemInfo.ClassID].ClassID = subSpendItemInfo.ClassID;
										Me.SpendItemTable[SpendItemInfo.ClassID].Items[subSpendItemInfo.ClassID].ClassName = subSpendItemInfo.ClassName;
										Me.SpendItemTable[SpendItemInfo.ClassID].Items[subSpendItemInfo.ClassID].Name = subSpendItemInfo.Name;
										Me.SpendItemTable[SpendItemInfo.ClassID].Items[subSpendItemInfo.ClassID].Icon = subSpendItemInfo.Icon;
										Me.SpendItemCount = Me.SpendItemCount + 1;
									end
									itemsCnt = itemsCnt + 1;
								end
							end
							Me.SpendItemTable[SpendItemInfo.ClassID].ItemsCnt = itemsCnt;
						end
					end
				end
			end
		end
	end
	
	--Nasiko:Log("##############################");
end

function Me.GetTextColorByCount(count)
    local color = (count < 100) and 'FF4500';
    color = (count < 50) and 'FF0000' or color
    return color or 'FFFFFF'
end

function Me.InitialFrame()
	local w = 50;
	local h = 50;
	local padding = 10;
	local cnt = 0;
	
	local soltWitch = w - 4;
	local soltHeight = h - 4;
	local fontsize = 16;
	local maxColumn = 8;
	local rowCnt = 1;

	local xPos;	
	local yPos;
	
	rowCnt = math.ceil(Me.SpendItemCount / maxColumn);
	
	if rowCnt > 1 then
		maxColumn = math.ceil(Me.SpendItemCount / rowCnt);
	else
		maxColumn = Me.SpendItemCount;
	end
	
	-- Clear 
	Me.frame:RemoveAllChild();
	
	Me.frame:Resize((w * maxColumn + padding * 2 - 4), (h * rowCnt + padding * 2 - 4));
	Me.frame:SetPos(Me.Settings.xPos, Me.Settings.yPos);
	
	-- Check
	if Me.Settings.show == 0 then
		return;
	end
	if Me.SpendItemCount == 0 then
		Me.frame:ShowWindow(0);
		return;
	end
	
	local nowRow = 0;
	
	for k, v in pairs(Me.SpendItemTable) do
		--Nasiko:Log(v.ClassID);
		--Nasiko:Log(v.ClassName);
		--Nasiko:Log(v.Name);
		
		xPos = w * cnt + padding;
		yPos = h * nowRow + padding;
		
		local baseSlot = Me.frame:CreateOrGetControl("slot", "slot"..v.ClassID, xPos, yPos, soltWitch, soltHeight);
		tolua.cast(baseSlot, 'ui::CSlot');
		baseSlot:SetSkinName('slot');
		baseSlot:SetTextTooltip(v.Name);
		baseSlot:EnableHitTest(1);
		baseSlot:SetGravity(ui.LEFT, ui.TOP);
		
		local icon = baseSlot:CreateOrGetControl("picture", "icon"..v.ClassID, 1, 1, (soltWitch - 2), (soltHeight - 2));
		tolua.cast(icon, 'ui::CPicture');
		icon:SetImage(v.Icon);
		icon:EnableHitTest(0);
		icon:SetEnableStretch(1);
		
		local itemCnt = 0;
		local itemObj = session.GetInvItemByName(v.ClassName);
		
		if itemObj ~= nil then
			itemCnt = itemObj.count;
		end
		
		local text = baseSlot:CreateOrGetControl("richtext", "txt"..v.ClassID, 0, 0, soltWitch, 20);
		tolua.cast(text, 'ui::CRichText');
		text:SetText(string.format("{#%s}{s%d}{ol}%d{/}{/}", Me.GetTextColorByCount(itemCnt), fontsize, itemCnt));
		text:SetGravity(ui.RIGHT, ui.BOTTOM);
		text:EnableHitTest(0);
		
		cnt = cnt + 1;
		if cnt == maxColumn then
			cnt = 0;
			nowRow = nowRow + 1;
		end
		
		if v.Items ~= nil then
			for subk, subv in pairs(v.Items) do
				--Nasiko:Log(subv.ClassID);
				--Nasiko:Log(subv.ClassName);
				--Nasiko:Log(subv.Name);
				
				xPos = w * cnt + padding;
				yPos = h * nowRow + padding;
				
				baseSlot = Me.frame:CreateOrGetControl("slot", "slot"..v.ClassID..subv.ClassID, xPos, yPos, soltWitch, soltHeight);
				tolua.cast(baseSlot, 'ui::CSlot');
				baseSlot:SetSkinName('slot');
				baseSlot:SetTextTooltip(subv.Name);
				baseSlot:EnableHitTest(1);
				baseSlot:SetGravity(ui.LEFT, ui.TOP);
		
				icon = baseSlot:CreateOrGetControl("picture", "icon"..v.ClassID..subv.ClassID, 1, 1, (soltWitch - 2), (soltHeight - 2));
				tolua.cast(icon, 'ui::CPicture');
				icon:SetImage(subv.Icon);
				icon:EnableHitTest(0);
				icon:SetEnableStretch(1);
				
				itemCnt = 0;
				itemObj = session.GetInvItemByName(subv.ClassName);
		
				if itemObj ~= nil then
					itemCnt = itemObj.count;
				end
		
				text = baseSlot:CreateOrGetControl("richtext", "txt"..v.ClassID..subv.ClassID, 0, 0, soltWitch, 20);
				tolua.cast(text, 'ui::CRichText');
				text:SetText(string.format("{#%s}{s%d}{ol}%d{/}{/}", Me.GetTextColorByCount(itemCnt), fontsize, itemCnt));
				text:SetGravity(ui.RIGHT, ui.BOTTOM);
				text:EnableHitTest(0);
				
				cnt = cnt + 1;
				if cnt == maxColumn then
					cnt = 0;
					nowRow = nowRow + 1;
				end
			end
		end
	end
end

function Me.UpdateFrame()
	
	--Nasiko:Log("UpdateFrame");
	
	if Me.SpendItemCount == 0 then
		return;
	end
	
	local fontsize = 16;
	
	for k, v in pairs(Me.SpendItemTable) do
		--Nasiko:Log(v.ClassID);
		--Nasiko:Log(v.ClassName);
		--Nasiko:Log(v.Name);
		
		local text = GET_CHILD_RECURSIVELY(Me.frame, "txt"..v.ClassID, "ui::CRichText");
			
		if text then
			local itemCnt = 0;
			local itemObj = session.GetInvItemByName(v.ClassName);
		
			if itemObj ~= nil then
				itemCnt = itemObj.count;
			end
			text:SetText(string.format("{#%s}{s%d}{ol}%d{/}{/}", Me.GetTextColorByCount(itemCnt), fontsize, itemCnt));
		end
		
		if v.Items ~= nil then			
			for subk, subv in pairs(v.Items) do
				--Nasiko:Log(subv.ClassID);
				--Nasiko:Log(subv.ClassName);
				--Nasiko:Log(subv.Name);
				
				text = nil;
				text = GET_CHILD_RECURSIVELY(Me.frame, "txt"..v.ClassID..subv.ClassID, "ui::CRichText");
				
				if text then
					local itemCnt = 0;
					local itemObj = session.GetInvItemByName(subv.ClassName);
		
					if itemObj ~= nil then
						itemCnt = itemObj.count;
					end
					text:SetText(string.format("{#%s}{s%d}{ol}%d{/}{/}", Me.GetTextColorByCount(itemCnt), fontsize, itemCnt));
				end
			end
		end
	end
end

local function LoadSetting()
	local resultObj, resultError = acutil.loadJSON(Me.SettingFilePathName);
	if resultError then
		acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
		Nasiko:Log('Default settings loaded.', addonName);
	else
		if resultObj.version ~= nil and resultObj.version == verSettings then 
			Me.Settings = resultObj;
			Nasiko:Log('Settings loaded!', addonName);
		else
			acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
			Nasiko:Log('Settings Version Update!!', addonName);
		end
	end
end

function SKILLSPENDITEM_ON_INIT(addon, frame)
	Me.frame = frame;
	
	frame:SetEventScript(ui.LBUTTONUP, "NASIKO_DPSCOUNT_END_DRAG");
	
	addon:RegisterMsg('GAME_START_3SEC', 'NASIKO_SKILLSPENDITEM_ON_GAME_START_3SEC');
	addon:RegisterMsg('INV_ITEM_ADD', 'NASIKO_SKILLSPENDITEM_ON_UPDATE');
    addon:RegisterMsg('INV_ITEM_CHANGE_COUNT', 'NASIKO_SKILLSPENDITEM_ON_UPDATE');
    addon:RegisterMsg("INV_ITEM_REMOVE","NASIKO_SKILLSPENDITEM_ON_UPDATE");
	
	acutil.slashCommand("/spend", NASIKO_SKILLSPENDITEM_COMMAND);
end

function NASIKO_DPSCOUNT_END_DRAG(addon, frame)
	Me.Settings.xPos = Me.frame:GetX();
	Me.Settings.yPos = Me.frame:GetY();
	acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
end

function NASIKO_SKILLSPENDITEM_ON_GAME_START_3SEC()

	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	
	Me.GetSkillSpendItem();

	Me.frame:ShowWindow(Me.Settings.show);
	Me.frame:SetPos(Me.Settings.xPos, Me.Settings.yPos);
	
	Me.InitialFrame();
end

function NASIKO_SKILLSPENDITEM_ON_UPDATE()
	--Nasiko:Log("NASIKO_SKILLSPENDITEM_ON_UPDATE");
	Me.UpdateFrame();
end

function NASIKO_SKILLSPENDITEM_COMMAND(command)
	local cmd = table.remove(command,1)
    if cmd == 'itemcraft' and #command > 0 then
        local arg = string.lower(table.remove(command, 1));
        if arg == "on" then
			Me.Settings.itemcraft = 1;
			acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
			Me.GetSkillSpendItem();
			Me.InitialFrame();
			Nasiko:Log('SpendItem list update!!', addonName);
			return;
		elseif arg == "off" then
			Me.Settings.itemcraft = 0;
			acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
			Me.GetSkillSpendItem();
			Me.InitialFrame();
			Nasiko:Log('SpendItem list update!!', addonName);
			return;
		end
    end
	
	local CommandHelpText = "";
	CommandHelpText = CommandHelpText..string.format("{#CCCCCC}Help for %s commands.{/}", addonName);
	CommandHelpText = CommandHelpText.."{nl}{#CCCCCC}Commands available:{/}";
	CommandHelpText = CommandHelpText.. string.format("{nl}{#CCCCCC}%s{/} {#AAAA66}%s{/}%s:{nl}　　%s", "/spend", "itemcraft", string.format(" {#BB9933}%s{/} ", "[on/off]"), "Display item of craft.");
	CommandHelpText = CommandHelpText .. "{/}";
	
	Nasiko:Log(CommandHelpText, "Help")
end

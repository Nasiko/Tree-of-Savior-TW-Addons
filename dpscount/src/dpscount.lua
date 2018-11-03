local addonName = "DpsCount";
local verText = "0.9.0";
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
Me.GroupBoxName = "chatgbox_TOTAL"; -- 擷取所有訊息
Me.Index = 0; -- 訊息游標
Me.IsCount = false; --是否在統計中
Me.IsReset = false; --是否觸發Reset
Me.TotalDamage = 0; --總傷害
Me.StartTime = Me.StartTime or nil; -- 統計起始時間(秒數)
Me.LastTime = Me.LastTime or nil; -- 最後更新時間(秒數)
Me.TotalTime = 0;
Me.ResetSecond = 60; -- 最大閒置時間(秒數)

local acutil = require('acutil');

Me.Settings = {
	-- 版本(存檔格式的版本)
	version = verSettings,
	-- 是否顯示
	show = 1,
	-- Normal = 正常, Minimum = 縮小
	size = "Normal",
	-- 最大閒置秒數
	resetSecond = 60,
	-- 視窗位置x座標
	xPos = 300,
	-- 視窗位置y座標
	yPos = 400,
	-- 是否運行
	enabled = 1
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
	end,
	
	DecimalFormat = function(self, amount)
		local formatted = amount
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
				break;
			end
		end
		return formatted
	end,
	
	GetTimeText = function(self, value, length)
		length = length or 1;
		local tmpValue = value;
		local strResult, strSplitter = "", " ";
		local index = 1;
		if value >= 3600 * 24 then
			if strResult ~= "" then strResult = strResult .. strSplitter end
			strResult = strResult .. string.format("%d%s", math.floor(tmpValue / 3600 / 24), "day");
			index = index + 1;
		end
		if index > length then return strResult end
		tmpValue = (tmpValue % (24 * 3600));
		if value >= 3600 then
			if strResult ~= "" then strResult = strResult .. strSplitter end
			strResult = strResult .. string.format("%d%s", math.floor(tmpValue / 3600), "hour");
			index = index + 1;
		end
		if index > length then return strResult end
		tmpValue = tmpValue % 3600;
		if value >= 60 then
			if strResult ~= "" then strResult = strResult .. strSplitter end
			strResult = strResult .. string.format("%d%s", math.floor(tmpValue / 60), "min.");
			index = index + 1;
		end
		if index > length then return strResult end
		tmpValue = tmpValue % 60;
		if strResult ~= "" then strResult = strResult .. strSplitter end
		strResult = strResult .. string.format("%d%s", math.ceil(tmpValue), "sec.");
		return strResult;
	end
};

function Me.InitialFrame()
	
	local fontsize = 16;
	
	--Nasiko:Log("Me.InitialFrame");
	-- Clear 
	Me.frame:RemoveAllChild();
	
	if Me.Settings.size == "Normal" then
		Me.frame:Resize(400, 60);
		Me.frame:SetSkinName("chat_window");
	else
		fontsize = 14;
		Me.frame:Resize(240, 36);
		Me.frame:SetSkinName("none");
	end
	
	local text = Me.frame:CreateOrGetControl("richtext", "DPSCOUNT_ON_TITLE", 10, 10, 120, 20);
	tolua.cast(text, 'ui::CRichText');
	text:SetText(string.format("{@st48}{s%d}DPS Count", fontsize));
	text:SetGravity(ui.LEFT, ui.TOP);
	
	--Nasiko:Log("Create DPSCOUNT_ON_TITLE");
	
	if Me.Settings.size == "Normal" then
		local msgText = Me.frame:CreateOrGetControl("richtext", "DPSCOUNT_ON_MSG", 10, 30, 280, 20);
		tolua.cast(msgText, 'ui::CRichText');
		msgText:SetGravity(ui.LEFT, ui.TOP);
	end
	
	--Nasiko:Log("Create DPSCOUNT_ON_MSG");
end

function Me.UpdateFrame()

	local fontsize = 16;
	
	--Nasiko:Log("Me.UpdateFrame");
	if Me.Settings.size ~= "Normal" then
		fontsize = 14;
	end
	
	local text = GET_CHILD_RECURSIVELY(Me.frame, "DPSCOUNT_ON_TITLE", "ui::CRichText");
	
	if text then
		local dps = 0;
		
		if Me.TotalTime == 0 then
			text:SetText(string.format('{@st48}{s%d}DPS Count', fontsize));
		else
			Me.TotalTime = math.floor(os.clock() - Me.StartTime);
			
			if Me.Settings.size == "Normal" then
				text:SetText(string.format('{@st48}{s%d}DPS Count ({#FFFF33}%s{#FFFFFF} elapsed.)', fontsize, Nasiko:GetTimeText(Me.TotalTime, 2)));
			else
				if Me.TotalTime >= 1 then
					dps = math.floor(Me.TotalDamage / Me.TotalTime);
					text:SetText(string.format('{@st48}{s%d}DPS %s ({#FFFF33}%s{#FFFFFF})', fontsize, Nasiko:DecimalFormat(dps), Nasiko:GetTimeText(Me.TotalTime, 2)));
				else
					text:SetText(string.format('{@st48}{s%d}DPS %s ({#FFFF33}%s{#FFFFFF})', fontsize, "-", Nasiko:GetTimeText(Me.TotalTime, 2)));
				end
			end
			
			-- 閒置檢查
			local resetTime = math.floor(os.clock() - Me.LastTime);
			if resetTime >= Me.ResetSecond then
				Me.IsReset = true;
			end
		end		
		
		--Nasiko:Log("Create DPSCOUNT_ON_TITLE");
		if Me.Settings.size == "Normal" then
			local msgText = GET_CHILD_RECURSIVELY(Me.frame, "DPSCOUNT_ON_MSG", "ui::CRichText");
	
			if msgText then
				if Me.TotalTime >= 1 then
					dps = math.floor(Me.TotalDamage / Me.TotalTime);
					msgText:SetText(string.format('{@st48}{s%d}DPS: %s Total Damage: %s', fontsize, Nasiko:DecimalFormat(dps), Nasiko:DecimalFormat(Me.TotalDamage)));
				else
					msgText:SetText(string.format('{@st48}{s%d}DPS: %s Total Damage: %s', fontsize, "--", "--"));
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

function DPSCOUNT_ON_INIT(addon, frame)
	Me.frame = frame;
	
	frame:SetEventScript(ui.LBUTTONUP, "NASIKO_DPSCOUNT_ON_DRAG");
	
	addon:RegisterMsg('GAME_START_3SEC', 'NASIKO_DPSCOUNT_ON_GAME_START_3SEC');
	addon:RegisterMsg('FPS_UPDATE', 'NASIKO_DPSCOUNT_ON_MSG');
	
	acutil.slashCommand("/dps", NASIKO_DPSCOUNT_COMMAND);
end

function NASIKO_DPSCOUNT_ON_DRAG(addon, frame)
	Me.Settings.xPos = Me.frame:GetX();
	Me.Settings.yPos = Me.frame:GetY();
	acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
end

function NASIKO_DPSCOUNT_ON_GAME_START_3SEC()
	
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	else
		Me.IsReset = true;
	end

	Me.frame:ShowWindow(Me.Settings.show);
	Me.frame:SetPos(Me.Settings.xPos, Me.Settings.yPos);
	
	Me.InitialFrame();
end

--chatgbox_TOTAL
function NASIKO_DPSCOUNT_ON_MSG(frame, msg, argStr, argNum)
	local size = session.ui.GetMsgInfoSize(Me.GroupBoxName);
	
	if Me.IsCount then
		return 1;
	else
		Me.IsCount = true;
	end
	
	for i = Me.Index, size - 1 do
		
		if Me.IsReset then
			Me.IsReset = false;
			Me.TotalDamage = 0;
			Me.StartTime = nil;
			Me.LastTime = nil;
			Me.TotalTime = 0;
			Me.Index = i;
			Me.UpdateFrame();
			Me.IsCount = false;
			return 1;
		end
	
		local clusterinfo = session.ui.GetChatMsgInfo(Me.GroupBoxName, i);
		if clusterinfo == nil then
			break;
		end
		
		if Me.Settings.enabled == 1 then
			local msgType = clusterinfo:GetMsgType();
		
			if msgType == "Battle" then
				local tempMsg = clusterinfo:GetMsg();
				local isGiveDamage = string.find(tempMsg, "$GiveDamage");
			
				if isGiveDamage ~= nil then
					tempMsg = string.sub(tempMsg, 1);
					local damage = nil;
					local amountIndex = string.find(tempMsg, "$AMOUNT");
					--CHAT_SYSTEM(amountIndex);
				
					local startIndex = amountIndex + 10;
					local endIndex = string.find(tempMsg, "#@!") - 1;
					--CHAT_SYSTEM(string.format("start: %s end: %s", startIndex, endIndex));
				
					if startIndex <= endIndex then
						damage = string.sub(tempMsg, startIndex, endIndex);
					end

					if damage ~= nil then		
						damage = string.gsub(damage, '%p', '');
						--CHAT_SYSTEM(damage);
					
						local d = tonumber(damage);
					
						if d == nil then d = 0 end;
					
						--CHAT_SYSTEM(d);
					
						if Me.StartTime == nil then
							Me.StartTime = os.clock();
						end
					
						--CHAT_SYSTEM(Me.StartTime);
					
						if Me.LastTime == nil then
							Me.LastTime = os.clock();
						end
					
						local resetTime = math.floor(os.clock() - Me.LastTime);
						--CHAT_SYSTEM(resetTime);
					
						-- 閒置太久
						if resetTime >= Me.ResetSecond then
							Me.TotalDamage = 0;
							Me.StartTime = os.clock();
						end
					
						Me.LastTime = os.clock();
					
						--CHAT_SYSTEM(Me.LastTime);
					
						Me.TotalDamage = Me.TotalDamage + d;
						--CHAT_SYSTEM(Me.TotalDamage);
						
						Me.TotalTime = math.floor(Me.LastTime - Me.StartTime);
					end
				end
			end
		end
	end
	
	Me.Index = size;
	if Me.Settings.enabled == 1 then
		Me.UpdateFrame();
	end
	Me.IsCount = false;
end

function NASIKO_DPSCOUNT_COMMAND(command)
	local cmd = "";
	
	if #command > 0 then 		
		cmd = string.lower(table.remove(command, 1));
	end
	
	if cmd == "reset" then
		Me.IsReset = true;
		Me.TotalDamage = 0;
		Me.StartTime = nil;
		Me.LastTime = nil;
		Me.TotalTime = 0;
		Me.UpdateFrame();
		return;
	end
	
	if cmd == "min" then
		Me.Settings.size = "Minimum";
		acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
		Me.InitialFrame();
		Me.UpdateFrame();
		Nasiko:Log('Windows Minimum!', addonName);
		return;
	end
	
	if cmd == "normal" then
		Me.Settings.size = "Normal";
		acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
		Me.InitialFrame();
		Me.UpdateFrame();
		Nasiko:Log('Windows Normal!', addonName);
		return;
	end
	
	if cmd == "on" then
		Me.Settings.enabled = 1;
		acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
		Nasiko:Log('Enabled!', addonName);
		return;
	end
	
	if cmd == "off" then
		Me.Settings.enabled = 0;
		acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
		Me.IsReset = true;
		Me.TotalDamage = 0;
		Me.StartTime = nil;
		Me.LastTime = nil;
		Me.TotalTime = 0;
		Me.UpdateFrame();
		Nasiko:Log('Disabled!', addonName);
		return;
	end
	
	local CommandHelpText = "";
	CommandHelpText = CommandHelpText..string.format("{#CCCCCC}Help for %s commands.{/}", addonName);
	CommandHelpText = CommandHelpText.."{nl}{#CCCCCC}Commands available:{/}";
	CommandHelpText = CommandHelpText.. string.format("{nl}{#CCCCCC}%s{/} {#AAAA66}%s{/}%s:{nl}　　%s", "/dps", "reset", "", "Reset DPS Count.");
	CommandHelpText = CommandHelpText.. string.format("{nl}{#CCCCCC}%s{/} {#AAAA66}%s{/}%s:{nl}　　%s", "/dps", "min", "", "DPS Count Windows Minimum.");
	CommandHelpText = CommandHelpText.. string.format("{nl}{#CCCCCC}%s{/} {#AAAA66}%s{/}%s:{nl}　　%s", "/dps", "normal", "", "DPS Count Windows Normal.");
	CommandHelpText = CommandHelpText.. string.format("{nl}{#CCCCCC}%s{/} {#AAAA66}%s{/}%s:{nl}　　%s", "/dps", "on", "", "DPS Count Enabled.");
	CommandHelpText = CommandHelpText.. string.format("{nl}{#CCCCCC}%s{/} {#AAAA66}%s{/}%s:{nl}　　%s", "/dps", "off", "", "DPS Count Disabled.");
	CommandHelpText = CommandHelpText .. "{/}";
	
	Nasiko:Log(CommandHelpText, "Help")
end

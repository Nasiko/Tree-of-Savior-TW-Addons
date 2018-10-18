local addonName = "DpsCount";
local verText = "0.2.0";
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
Me.TotalDamage = 0; --總傷害
Me.StartTime = Me.StartTime or nil; -- 統計起始時間(秒數)
Me.LastTime = Me.LastTime or nil; -- 最後更新時間(秒數)
Me.ResetSecond = 60; -- 最大閒置時間(秒數)

local acutil = require('acutil');

Me.Settings = {
	-- 版本(存檔格式的版本)
	version = verSettings,
	-- 是否顯示
	show = 1,
	-- Normal = 正常, Min = 縮小
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
			header = string.format("[Debug][%s]", addonName); 
		else
			header = string.format("[%s][%s]", Mode, addonName); 
		end
		
		CHAT_SYSTEM(header..Message);
	end
};

local function LoadSetting()
	local resultObj, resultError = acutil.loadJSON(Me.SettingFilePathName);
	if resultError then
		acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
		Nasiko:Log('Default settings loaded.', 'info');
	else
		if resultObj.version ~= nil and resultObj.version == verSettings then 
			Me.Settings = resultObj;
			Nasiko:Log('Settings loaded!', 'info');
		else
			acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
			Nasiko:Log('Settings Version Update!!', 'info');
		end
	end
end

local function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

local function GetTimeText(value, length)
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

function DPSCOUNT_ON_INIT(addon, frame)
	Me.frame = frame;
	
	frame:SetEventScript(ui.LBUTTONUP, "NASIKO_DPSCOUNT_END_DRAG");
	
	addon:RegisterMsg('GAME_START_3SEC', 'NASIKO_DPSCOUNT_ON_GAME_START_3SEC');
	addon:RegisterMsg('FPS_UPDATE', 'NASIKO_DPSCOUNT_ON_MSG');
end

function NASIKO_DPSCOUNT_END_DRAG(addon, frame)
	Me.Settings.xPos = Me.frame:GetX();
	Me.Settings.yPos = Me.frame:GetY();
	acutil.saveJSON(Me.SettingFilePathName, Me.Settings);
end

function NASIKO_DPSCOUNT_ON_GAME_START_3SEC()
	
	if not Me.Loaded then
		Me.Loaded = true;
		LoadSetting();
	end
	
	Me.IsCount = false;
	Me.TotalDamage = 0;
	Me.StartTime = nil;
	Me.LastTime = nil;

	Me.frame:ShowWindow(Me.Settings.show);
	Me.frame:SetPos(Me.Settings.xPos, Me.Settings.yPos);
	
	local text = Me.frame:CreateOrGetControl("richtext", "DPSCOUNT_ON_TITLE", 10, 10, 120, 20);
	tolua.cast(text, 'ui::CRichText');
	text:SetText("{@st48}{s16}DPS Count");
	text:SetGravity(ui.LEFT, ui.TOP);
end

--chatgbox_TOTAL
function NASIKO_DPSCOUNT_ON_MSG(frame, msg, argStr, argNum)
	
	local frame = ui.GetFrame(addonNameLower);
	local size = session.ui.GetMsgInfoSize(Me.GroupBoxName);
	
	if Me.IsCount then
		return 1;
	else
		Me.IsCount = true;
	end
	
	for i = Me.Index, size - 1 do
		local clusterinfo = session.ui.GetChatMsgInfo(Me.GroupBoxName, i);
		if clusterinfo == nil then
			break;
		end
		
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
					
					local totalTime = math.floor(Me.LastTime - Me.StartTime);
					local dps = 0;
					
					if totalTime >= 1 then
						dps = math.floor(Me.TotalDamage / totalTime);
					end
					
					--CHAT_SYSTEM(totalTime);

					local text = frame:CreateOrGetControl("richtext", "DPSCOUNT_ON_MSG", 10, 30, 280, 20);
					tolua.cast(text, 'ui::CRichText');
					text:SetText(string.format('{@st48}{s16}DPS: %s Total Damage: %s', comma_value(dps), comma_value(Me.TotalDamage)));
					text:SetGravity(ui.LEFT, ui.TOP);
					
					--CHAT_SYSTEM(GetTimeText(totalTime));
					
					local titleText = frame:CreateOrGetControl("richtext", "DPSCOUNT_ON_TITLE", 10, 10, 280, 20);
					tolua.cast(titleText, 'ui::CRichText');
					titleText:SetText(string.format('{@st48}{s16}DPS Count ({#FFFF33}%s{#FFFFFF} elapsed.)', GetTimeText(totalTime, 2)));
					titleText:SetGravity(ui.LEFT, ui.TOP);
					
				end

			end
		end
	end
	
	Me.Index = size;
	Me.IsCount = false;
end

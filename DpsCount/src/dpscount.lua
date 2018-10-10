local addonName = "DpsCount";
local verText = "0.1.0";
local autherName = "NASIKO";
local addonNameLower = string.lower(addonName);
local SettingFileName = "setting.json";

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];

Me.isLoaded = false;
Me.HoockedOrigProc = Me.HoockedOrigProc or {};
Me.Index = 0;
Me.IsCount = false;
Me.TotalDamage = 0;
Me.StartTime = Me.StartTime or nil;
Me.LastTime = Me.LastTime or nil;
Me.ResetSecond = 60;

function DPSCOUNT_ON_INIT(addon, frame)
	frame:ShowWindow(1);
	frame:ShowTitleBar(1);
    frame:ShowTitleBarFrame(1);
	frame:SetPos(300, 200);
	
	addon:RegisterMsg('FPS_UPDATE', 'NASIKO_DPSCOUNT_ON_MSG');
	
	if not Me.isLoaded  then
		Me.isLoaded  = true;
	end
end

--chatgbox_TOTAL
function NASIKO_DPSCOUNT_ON_MSG(frame, msg, argStr, argNum)
	
	local frame = ui.GetFrame(addonNameLower);
	local groupboxname = "chatgbox_TOTAL";
	local size = session.ui.GetMsgInfoSize(groupboxname);
	
	if Me.IsCount then
		return 1;
	else
		Me.IsCount = true;
	end
	
	for i = Me.Index, size - 1 do
		local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i);
		if clusterinfo == nil then
			break;
		end
		
		local msgType = clusterinfo:GetMsgType();
		
		if msgType == "Battle" then
			local tempMsg = clusterinfo:GetMsg();
			local isGiveDamage = string.find(tempMsg, "$GiveDamage");
			
			if isGiveDamage ~= nil then
				tempMsg = string.sub(tempMsg, 1);
				local amountIndex = string.find(tempMsg, "$AMOUNT");
				--CHAT_SYSTEM(amountIndex);
				
				local startIndex = amountIndex + 10;
				local endIndex = string.find(tempMsg, "#@!") - 1;
				--CHAT_SYSTEM(string.format("start: %s end: %s", startIndex, endIndex));
				
				local damage = string.gsub(string.sub(tempMsg, startIndex, endIndex), '%p', '');
				
				if damage ~= nil then
				
					--CHAT_SYSTEM(damage);
					
					local d = tonumber(damage);
					
					CHAT_SYSTEM(d);
					
					if Me.StartTime == nil then
						Me.StartTime = os.clock();
					end
					
					--CHAT_SYSTEM(Me.StartTime);
					
					if Me.LastTime == nil then
						Me.LastTime = os.clock();
					end
					
					
					Me.LastTime = os.clock();
					CHAT_SYSTEM(Me.LastTime);
					
					Me.TotalDamage = Me.TotalDamage + d;
					--CHAT_SYSTEM(Me.TotalDamage);
					
					local totalTime = math.floor(Me.LastTime - Me.StartTime);
					local dps = 0;
					
					if totalTime >= 30 then
						dps = math.floor(Me.TotalDamage / totalTime);
					end
					
					CHAT_SYSTEM(totalTime);

					local text = frame:CreateOrGetControl("richtext", "DPSCOUNT_ON_MSG", 10, 10, 280, 40);
					tolua.cast(text, 'ui::CRichText');
					text:SetText(string.format('DPS: %d Total: %d', dps, Me.TotalDamage));
					text:SetGravity(ui.LEFT, ui.TOP);
					
				end

			end
		end
	end
	
	Me.Index = size;
	Me.IsCount = false;
end

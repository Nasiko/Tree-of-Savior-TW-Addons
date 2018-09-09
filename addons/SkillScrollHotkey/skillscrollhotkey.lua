-- nsSkillScrollIcon v1.0.0 By Nasiko
-- Refer: @TreeOfSaviorTW/data/addon.ipf/quickslotnexpbar/quickslotnexpbar.lua 快捷設定
-- 技能卷軸放到快捷鍵時會自動顯示技能的圖示

local isLoaded = false;

-- 複寫原有功能
local function SetupHook(newFunction, hookedFunctionName)
	local storeOldFunc = hookedFunctionName .. "_OLD";
	if _G[storeOldFunc] == nil then
		_G[storeOldFunc] = _G[hookedFunctionName];
		_G[hookedFunctionName] = newFunction;
	else
		_G[hookedFunctionName] = newFunction;
	end
end

function SET_QUICK_SLOT_HOOKED(slot, category, type, iesID, makeLog, sendSavePacket)
    local icon 	= CreateIcon(slot);
	local imageName = "";

	if category == 'Action' then
		icon:SetColorTone("FFFFFFFF");
		icon:ClearText();
	elseif category == 'Skill' then
		local skl = session.GetSkill(type);
		if IS_NEED_CLEAR_SLOT(skl, type) == true then			
			slot:ClearIcon();
			QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
			return;
		end
		imageName = 'icon_' .. GetClassString('Skill', type, 'Icon');
		icon:SetOnCoolTimeUpdateScp('ICON_UPDATE_SKILL_COOLDOWN');
		icon:SetEnableUpdateScp('ICON_UPDATE_SKILL_ENABLE');
		icon:SetColorTone("FFFFFFFF");
		icon:ClearText();
		quickslot.OnSetSkillIcon(slot, type);
	elseif category == 'Item' then
		local itemIES = GetClassByType('Item', type);
		if itemIES ~= nil then			
			imageName = itemIES.Icon;
			
			local invenItemInfo = nil

			if iesID == "" then
				invenItemInfo = session.GetInvItemByType(type);
			else
				invenItemInfo = session.GetInvItemByGuid(iesID);
			end

			local skill_scroll = 910001;
			if invenItemInfo == nil then
				if skill_scroll ~= type then
					invenItemInfo = session.GetInvItemByType(type);
				end
			end

			if invenItemInfo ~= nil and invenItemInfo.type == math.floor(type) then
				itemIES = GetIES(invenItemInfo:GetObject());
				imageName = GET_ITEM_ICON_IMAGE(itemIES);
				local result = CHECK_EQUIPABLE(itemIES.ClassID);
				icon:SetEnable(1);
				icon:SetEnableUpdateScp('None');
				if result == 'OK' then
					icon:SetColorTone("FFFFFFFF");
				else
					icon:SetColorTone("FFFF0000");
				end

				if itemIES.MaxStack > 0 or itemIES.GroupName == "Material" then
					if itemIES.MaxStack > 1 then -- 개수는 스택형 아이템만 표시해주자
						if skill_scroll == type then
							icon:SetText("卷"..invenItemInfo.count, 'quickiconfont', 'right', 'bottom', -2, 1);
						else
							icon:SetText(invenItemInfo.count, 'quickiconfont', 'right', 'bottom', -2, 1);
						end
					else
					  icon:SetText(nil, 'quickiconfont', 'right', 'bottom', -2, 1);
					end
					icon:SetColorTone("FFFFFFFF");
				end

				tolua.cast(icon, "ui::CIcon");
				local iconInfo = icon:GetInfo();
				iconInfo.count = invenItemInfo.count;

				if skill_scroll == type then
					--CHAT_SYSTEM("IS_SCROLL YES");
					--CHAT_SYSTEM("SkillType:"..itemIES.SkillType);
					--直接換成技能圖示
					imageName = 'icon_' .. GetClassString('Skill', itemIES.SkillType, 'Icon');
					icon:SetUserValue("IS_SCROLL","YES");
				else
					icon:SetUserValue("IS_SCROLL","NO");
				end

			else
				imageName = GET_ITEM_ICON_IMAGE(itemIES);
				icon:SetColorTone("FFFF0000");
				icon:SetText(0, 'quickiconfont', 'right', 'bottom', -2, 1);
			end

			ICON_SET_ITEM_COOLDOWN_OBJ(icon, itemIES);
		end
	end

	if imageName ~= "" then
		if iesID == nil then
			iesID = ""
		end
		
		local category = category;
		local type = type;

		if category == 'Item' then
			icon:SetTooltipType('wholeitem');
			
			local invItem = nil

			if iesID == '0' then
				invItem = session.GetInvItemByType(type);
			elseif iesID == "" then
				invItem = session.GetInvItemByType(type);
			else
				invItem = session.GetInvItemByGuid(iesID);
			end

			if invItem ~= nil and invItem.type == type then
				iesID = invItem:GetIESID();
			end

			if invItem ~= nil then
				icon:Set(imageName, 'Item', invItem.type, invItem.invIndex, invItem:GetIESID(), invItem.count);
				ICON_SET_INVENTORY_TOOLTIP(icon, invItem, "quickslot", GetIES(invItem:GetObject()));
			else
				icon:Set(imageName, category, type, 0, iesID);
				icon:SetTooltipNumArg(type);
				icon:SetTooltipIESID(iesID);
			end
		else
			if category == 'Skill' then
				icon:SetTooltipType('skill');
				local skl = session.GetSkill(type);
				if skl ~= nil then
					iesID = skl:GetIESID();
				end
			end
		
			icon:Set(imageName, category, type, 0, iesID);
			icon:SetTooltipNumArg(type);
			icon:SetTooltipIESID(iesID);		
		end

		local isLockState = quickslot.GetLockState();
		if isLockState == 1 then
			slot:EnableDrag(0);
		else
			slot:EnableDrag(1);
		end

		INIT_QUICKSLOT_SLOT(slot, icon);
		local sendPacket = 1;
		if false == sendSavePacket then
			sendPacket = 0;
		end

		quickslot.SetInfo(slot:GetSlotIndex(), category, type, iesID);

		icon:SetDumpArgNum(slot:GetSlotIndex());
	else
		slot:EnableDrag(0);
	end

	if category == 'Skill' then
		SET_QUICKSLOT_OVERHEAT(slot);
		SET_QUICKSLOT_TOOLSKILL(slot);
	end
end

function GetObjByIcon(icon)
    local info = icon:GetInfo()
    local IESID = info:GetIESID()
    return GetObjectByGuid(IESID) ,IESID,info
end

function SKILLSCROLLHOTKEY_ON_INIT(addon, frame)
	if not isLoaded then
		-- 複寫 quickslotnexpbar.lua 的 SET_QUICK_SLOT 方法
		SetupHook(SET_QUICK_SLOT_HOOKED, "SET_QUICK_SLOT");
		isLoaded = true;
	end
end

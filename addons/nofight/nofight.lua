--Refer: @TreeOfSaviorTW/data/ui.ipf/uiscp/community.lua

local acutil = require("acutil");

function NOFIGHT_ON_INIT(addon, frame)
	--取代 community.lua 的 ASKED_FRIENDLY_FIGHT
	acutil.setupHook(ASKED_FRIENDLY_FIGHT_HOOKED, "ASKED_FRIENDLY_FIGHT");
end

function ASKED_FRIENDLY_FIGHT_HOOKED(handle, familyName)
	-- 忽略請求，不做任何回應，並且通知使用者
	CHAT_SYSTEM("{@st41}您已經忽略了" .. familyName .. "的" .. ScpArgMsg("RequestFriendlyFight"));
	
end

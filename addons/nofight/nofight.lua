--Refer: @TreeOfSaviorTW/data/ui.ipf/uiscp/community.lua

local acutil = require("acutil");

function NOFIGHT_ON_INIT(addon, frame)
	acutil.setupHook(ASKED_FRIENDLY_FIGHT_HOOKED, "ASKED_FRIENDLY_FIGHT");
end

function ASKED_FRIENDLY_FIGHT_HOOKED(handle, familyName)
  CHAT_SYSTEM("{@st41}您已經無視了" .. familyName .. "的" .. ScpArgMsg("RequestFriendlyFight"));
end

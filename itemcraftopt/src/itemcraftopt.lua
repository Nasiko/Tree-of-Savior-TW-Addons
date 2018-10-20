-- ItemCraft Optimization v1.0.0 By Nasiko
-- https://github.com/Nasiko/Tree-of-Savior-TW-Addons/itemcraftopt
-- Refer: @TreeOfSaviorTW/data/ui.ipf/uiscp/lib_slot.lua 快捷鍵觸發
-- Refer: @TreeOfSaviorTW/data/addon.ipf/itemcraft/itemCraft.lua 物品製作
-- Refer: @TreeOfSaviorTW/data/ui.ipf/uixml/controlset.xml UI設定檔

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

function SET_ITEM_CRAFT_UINAME_HOOKED(uiName)
	g_itemCraftFrameName = uiName;

	g_craftRecipe = "craftRecipe";
	g_craftRecipe_detail_item = "craftRecipe_detail_item";
	g_craftRecipe_detail_memo = "craftRecipe_detail_memo";
	g_craftRecipe_makeBtn = "craftRecipe_makeBtn";
	g_craftRecipe_upDown =  "craftRecipe_numupdown";

	if uiName == "itemcraft_alchemist" then
		g_craftRecipe = g_craftRecipe .. "_alchemist";
		g_craftRecipe_detail_item = g_craftRecipe_detail_item;
		g_craftRecipe_detail_memo = g_craftRecipe_detail_memo .. "_alchemist";
		g_craftRecipe_makeBtn = g_craftRecipe_makeBtn .. "_alchemist";
	elseif	uiName == "itemcraft_fletching"	then
		g_craftRecipe = g_craftRecipe .. "_alchemist";
		g_craftRecipe_detail_item = g_craftRecipe_detail_item;
		g_craftRecipe_detail_memo = g_craftRecipe_detail_memo .. "_alchemist";
		g_craftRecipe_makeBtn = g_craftRecipe_makeBtn .. "_alchemist";
	end

end

function ITEMCRAFTOPT_ON_INIT(addon, frame)
	if not isLoaded then
		-- 複寫 itemCraft.lua 的 SET_ITEM_CRAFT_UINAME 方法
		SetupHook(SET_ITEM_CRAFT_UINAME_HOOKED, "SET_ITEM_CRAFT_UINAME");
		isLoaded = true;
	end
end

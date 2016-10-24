--Refer: @TreeOfSaviorTW/data/ui.ipf/uiscp/lib_slot.lua 快捷鍵觸發
--Refer: @TreeOfSaviorTW/data/addon.ipf/itemcraft/itemCraft.lua 物品製作
--Refer: @TreeOfSaviorTW/data/ui.ipf/uixml/controlset.xml UI設定檔

function NSITEMCRAFT_ON_INIT(addon, frame)
	local acutil = require("acutil");

	-- 使用者觸發 CREATE_CRAFT_ARTICLE > 針對清單觸發 CRAFT_INSERT_CRAFT
	-- 先透過 CRAFT_CREATE_TREE_PAGE 建立樹狀圖，然後依賴樹狀圖回來的index，觸發 CRAFT_UPDATE_PAGE
	-- 在每個物件清單上埋下滑鼠左鍵點擊事件觸發 CRAFT_RECIPE_FOCUS
	-- 又會觸發 CRAFT_CRAFT_SET_DETAIL 準備去隱藏或者繪製UI
	-- 最後觸發 CRAFT_MAKE_DETAIL_REQITEMS 開始畫美麗的UI....
	-- 但是在 CRAFT_MAKE_DETAIL_REQITEMS 並沒有分支.... 
	-- 檢查到最後原來是 CRAFT_MAKE_DETAIL_REQITEMS 繪製的時候所套用的 xml 不同
	-- 最後返璞歸真.... 修改 xml 初始化設定
	-- 把原本要指向 craftRecipe_detail_item_alchemist 的 xml 指向 craftRecipe_detail_item 即可

	SetupHook(SET_ITEM_CRAFT_UINAME_HOOKED, "SET_ITEM_CRAFT_UINAME")
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

--自定義
local function SetupHook(newFunction, hookedFunctionName)
	local storeOldFunc = hookedFunctionName .. "_OLD";
	if _G[storeOldFunc] == nil then
		_G[storeOldFunc] = _G[hookedFunctionName];
		_G[hookedFunctionName] = newFunction;
	else
		_G[hookedFunctionName] = newFunction;
	end
end

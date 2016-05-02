-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

BotSettings = { }
BotSettings.Visible = false

BotSettings.InventoryComboSelectedIndex = 0
BotSettings.InventorySelectedIndex = 0
BotSettings.InventoryName = { }

BotSettings.WarehouseComboSelectedIndex = 0
BotSettings.WarehouseSelectedIndex = 0
BotSettings.WarehouseName = { }

BotSettings.BaitComboBoxItems = { }
BotSettings.BaitComboBoxSelected = 0

-----------------------------------------------------------------------------
-- BotSettings Functions
-----------------------------------------------------------------------------

function BotSettings.DrawBotSettings()
	local valueChanged = false

	if BotSettings.Visible then
		_, BotSettings.Visible = ImGui.Begin("Bot Settings", BotSettings.Visible, ImVec2(400, 400), -1.0)

		BotSettings.UpdateInventoryList()

		if ImGui.Button("Save settings", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
			Bot.SaveSettings()
			print("[" .. os.date(Bot.UsedTimezone) .. "] Settings saved")
			BotSettings.Visible = false
		end
		ImGui.SameLine()
		if ImGui.Button("Load settings", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.LoadSettings()
			print("[" .. os.date(Bot.UsedTimezone) .. "] Settings loaded")
			BotSettings.Visible = false
		end
		ImGui.Spacing()

		if ImGui.CollapsingHeader("Bait", "id_gui_fish_bait", true, false) then
			BotSettings.UpdateBaitComboBox()

			if not table.find(BotSettings.BaitComboBoxItems, Bot.Settings.ConsumablesSettings.Consumables[1].Name) then
				table.insert(BotSettings.BaitComboBoxItems, Bot.Settings.ConsumablesSettings.Consumables[1].Name)
			end

			ImGui.Text("Bait")
			ImGui.SameLine()
			valueChanged, BotSettings.BaitComboBoxSelected = ImGui.Combo("##id_guid_fish_bait_to_use", table.findIndex(BotSettings.BaitComboBoxItems, Bot.Settings.ConsumablesSettings.Consumables[1].Name), BotSettings.BaitComboBoxItems)
			if valueChanged then
				Bot.Settings.ConsumablesSettings.Consumables[1].Name = BotSettings.BaitComboBoxItems[BotSettings.BaitComboBoxSelected]
				print("[" .. os.date(Bot.UsedTimezone) .. "] Bait selected: " .. Bot.Settings.ConsumablesSettings.Consumables[1].Name)
			end

			ImGui.Text("Mins Lasts for")
			ImGui.SameLine()
			_, Bot.Settings.ConsumablesSettings.Consumables[1].ConditionValue = ImGui.SliderInt("##id_guid_fish_bait_lasts", tonumber(Bot.Settings.ConsumablesSettings.Consumables[1].ConditionValue), 1, 120)
		end

		if ImGui.CollapsingHeader("Looting", "id_gui_looting", true, false) then
			_, Bot.Settings.LootSettings.LootWhite = ImGui.Checkbox("##id_guid_looting_loot_white", Bot.Settings.LootSettings.LootWhite)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(1,1,1,1), "Loot White")

			_, Bot.Settings.LootSettings.LootGreen = ImGui.Checkbox("##id_guid_looting_loot_green", Bot.Settings.LootSettings.LootGreen)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(0.20,1,0.20,1), "Loot Green")

			_, Bot.Settings.LootSettings.LootBlue = ImGui.Checkbox("##id_guid_looting_loot_blue", Bot.Settings.LootSettings.LootBlue)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(0.40,0.60,1,1), "Loot Blue")

			_, Bot.Settings.LootSettings.LootGold = ImGui.Checkbox("##id_guid_looting_loot_gold", Bot.Settings.LootSettings.LootGold)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(1,0.80,0.20,1), "Loot Gold")

			_, Bot.Settings.LootSettings.LootOrange = ImGui.Checkbox("##id_guid_looting_loot_orange", Bot.Settings.LootSettings.LootOrange)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(1,0.40,0.20,1), "Loot Orange")

			_, Bot.Settings.LootSettings.LootShards = ImGui.Checkbox("##id_guid_looting_loot_shard", Bot.Settings.LootSettings.LootShards)
			ImGui.SameLine()
			ImGui.Text("Loot Shards")

			-- _, Bot.Settings.LootSettings.LootEggs = ImGui.Checkbox("##id_guid_looting_loot_eggs", Bot.Settings.LootSettings.LootEggs)
			-- ImGui.SameLine()
			-- ImGui.Text("Loot Eggs")

			_, Bot.Settings.LootSettings.LootKeys = ImGui.Checkbox("##id_guid_looting_loot_keys", Bot.Settings.LootSettings.LootKeys)
			ImGui.SameLine()
			ImGui.Text("Loot Keys")
		end

		if ImGui.CollapsingHeader("Inventory Management", "id_gui_inv_manage", true, false) then
			_, Bot.Settings.DeleteUsedRods = ImGui.Checkbox("##id_guid_inv_manage_autodelete_broken_rods", Bot.Settings.DeleteUsedRods)
			ImGui.SameLine()
			ImGui.Text("Auto delete broken (Steel) Fishing Rods")

			ImGui.Text("Always delete these items")
			valueChanged, BotSettings.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_inv_manage_inventory_combo_select", BotSettings.InventoryComboSelectedIndex, BotSettings.InventoryName)
			if valueChanged then
				local inventoryName = BotSettings.InventoryName[BotSettings.InventoryComboSelectedIndex]

				if not table.find(Bot.Settings.InventoryDeleteSettings.DeleteItems, inventoryName) then
					table.insert(Bot.Settings.InventoryDeleteSettings.DeleteItems, inventoryName)
				end

				BotSettings.InventoryComboSelectedIndex = 0
			end

			_, BotSettings.InventorySelectedIndex = ImGui.ListBox("##id_guid_inv_manage_delete", BotSettings.InventorySelectedIndex,Bot.Settings.InventoryDeleteSettings.DeleteItems, 5)
			if ImGui.Button("Remove Item##id_guid_inv_manage_delete_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				if BotSettings.InventorySelectedIndex > 0 and BotSettings.InventorySelectedIndex <= table.length(Bot.Settings.InventoryDeleteSettings.DeleteItems) then
					table.remove(Bot.Settings.InventoryDeleteSettings.DeleteItems, BotSettings.InventorySelectedIndex)
					BotSettings.InventorySelectedIndex = 0
				end
			end
		end

		if ImGui.CollapsingHeader("Vendor selling", "id_gui_vendor_sell", true, false) then
			_, Bot.Settings.VendorSettings.VendorOnInventoryFull = ImGui.Checkbox("##id_guid_vendor_sell_full_inventory", Bot.Settings.VendorSettings.VendorOnInventoryFull)
			ImGui.SameLine()
			ImGui.Text("Go to Vendor when inventory is full")

			_, Bot.Settings.VendorSettings.VendorOnWeight = ImGui.Checkbox("##id_guid_vendor_sell_weight", Bot.Settings.VendorSettings.VendorOnWeight)
			ImGui.SameLine()
			ImGui.Text("Sell to Vendor when you are too heavy")

			_, Bot.Settings.VendorSettings.VendorWhite = ImGui.Checkbox("##id_guid_vendor_sell_white", Bot.Settings.VendorSettings.VendorWhite)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(1,1,1,1), "Sell white")

			_, Bot.Settings.VendorSettings.VendorGreen = ImGui.Checkbox("##id_guid_vendor_sell_green", Bot.Settings.VendorSettings.VendorGreen)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(0.20,1,0.20,1), "Sell green")

			_, Bot.Settings.VendorSettings.VendorBlue = ImGui.Checkbox("##id_guid_vendor_sell_blue", Bot.Settings.VendorSettings.VendorBlue)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(0.40,0.60,1,1), "Sell blue")

			ImGui.Spacing()

			ImGui.Text("Items ignored")
			valueChanged, BotSettings.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_vendor_ignore_items", BotSettings.InventoryComboSelectedIndex, BotSettings.InventoryName)
			if valueChanged then
				local inventoryName = BotSettings.InventoryName[BotSettings.InventoryComboSelectedIndex]
				if not table.find(Bot.Settings.VendorSettings.IgnoreItemsNamed, inventoryName) then
					table.insert(Bot.Settings.VendorSettings.IgnoreItemsNamed, inventoryName)
				end

				BotSettings.InventoryComboSelectedIndex = 0
			end

			_, BotSettings.InventorySelectedIndex = ImGui.ListBox("##id_guid_vendor_neversell", BotSettings.InventorySelectedIndex, Bot.Settings.VendorSettings.IgnoreItemsNamed, 5)
			if ImGui.Button("Remove Item##id_guid_vendor_neversell_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				if BotSettings.InventorySelectedIndex > 0 and BotSettings.InventorySelectedIndex <= table.length(Bot.Settings.VendorSettings.IgnoreItemsNamed) then
					table.remove(Bot.Settings.VendorSettings.IgnoreItemsNamed, BotSettings.InventorySelectedIndex)
					BotSettings.InventorySelectedIndex = 0
				end
			end
		end

		if ImGui.CollapsingHeader("Vendor buying", "id_gui_vendor_buy", true, false) then
			ImGui.Text("Select item")
			ImGui.SameLine()
			valueChanged, BotSettings.InventoryComboSelectedIndex = ImGui.Combo("##id_guid_vendor_buy_combo_select", BotSettings.InventoryComboSelectedIndex, BotSettings.InventoryName)
			if valueChanged then
				local inventoryName = BotSettings.InventoryName[BotSettings.InventoryComboSelectedIndex]
				local found = false

				for key, value in pairs(Bot.VendorState.Settings.BuyItems) do
					if value.Name == inventoryName then
						found = true
					end
				end

				if found == false then
					table.insert(Bot.VendorState.Settings.BuyItems, { Name = inventoryName, BuyAt = 0, BuyMax = 1 })
				end

				BotSettings.InventoryComboSelectedIndex = 0
			end

			ImGui.Columns(3)
			ImGui.Text("Name")
			ImGui.NextColumn()
			ImGui.Text("Buy at")
			ImGui.NextColumn()
			ImGui.Text("Total")
			ImGui.NextColumn()

			local vbCount = table.length(Bot.VendorState.Settings.BuyItems)
			for key = 1,vbCount do
				local value = Bot.VendorState.Settings.BuyItems[key]
				local erase = false

				if ImGui.SmallButton("x##id_guid_vendor_buy_del_items" .. key) then
					erase = true
				end

				ImGui.SameLine()

				if value ~= nil then
					ImGui.Text(value.Name)
					ImGui.NextColumn()

					valueChanged, Bot.VendorState.Settings.BuyItems[key].BuyAt = ImGui.InputFloat("Min##id_guid_vendor_buy_min_items" .. key, Bot.VendorState.Settings.BuyItems[key].BuyAt, 1,10,0,0)
					if valueChanged then
						if Bot.VendorState.Settings.BuyItems[key].BuyAt < 0 then
							Bot.VendorState.Settings.BuyItems[key].BuyAt = 0
						end

						if Bot.VendorState.Settings.BuyItems[key].BuyAt > 250 then
							Bot.VendorState.Settings.BuyItems[key].BuyAt = 250
						end
					end

					ImGui.NextColumn()

					valueChanged, Bot.VendorState.Settings.BuyItems[key].BuyMax = ImGui.InputFloat("Max##id_guid_vendor_buy_max_items" .. key, Bot.VendorState.Settings.BuyItems[key].BuyMax, 1,10,0,0)
					if valueChanged then
						if Bot.VendorState.Settings.BuyItems[key].BuyMax < 1 then
							Bot.VendorState.Settings.BuyItems[key].BuyMax = 1
						end

						if Bot.VendorState.Settings.BuyItems[key].BuyMax > 500 then
							Bot.VendorState.Settings.BuyItems[key].BuyMax = 500
						end
					end
					ImGui.NextColumn()

					if erase then
						table.remove(Bot.VendorState.Settings.BuyItems,key)
						vbCount = vbCount -1
					end
				end
			end
			ImGui.Columns(1)
		end

		if ImGui.CollapsingHeader("Warehouse", "id_gui_warehouse", true, false) then
			_, Bot.Settings.WarehouseSettings.DepositAfterVendor = ImGui.Checkbox("##id_guid_warehouse_after_vendor", Bot.Settings.WarehouseSettings.DepositAfterVendor)
			ImGui.SameLine()
			ImGui.Text("Deposit after Vendor")

			_, Bot.Settings.WarehouseSettings.DepositAfterTradeManager = ImGui.Checkbox("##id_guid_warehouse_after_trader", Bot.Settings.WarehouseSettings.DepositAfterTradeManager)
			ImGui.SameLine()
			ImGui.Text("Deposit after Trader")

			_, Bot.Settings.WarehouseSettings.DepositAfterRepair = ImGui.Checkbox("##id_guid_warehouse_repair_after_trader", Bot.Settings.WarehouseSettings.DepositAfterRepair)
			ImGui.SameLine()
			ImGui.Text("Deposit after Repair")

			_, Bot.Settings.WarehouseSettings.DepositMoney = ImGui.Checkbox("##id_guid_warehouse_deposit_money", Bot.Settings.WarehouseSettings.DepositMoney)
			ImGui.SameLine()
			ImGui.Text("Deposit money")

			ImGui.Spacing()

			ImGui.Text("Money to keep")
			ImGui.SameLine()
			_, Bot.Settings.WarehouseSettings.MoneyToKeep = ImGui.SliderInt("##id_gui_warehouse_keep_money", Bot.Settings.WarehouseSettings.MoneyToKeep, 0, 1000000)

			_, Bot.Settings.WarehouseSettings.DepositItems = ImGui.Checkbox("##id_guid_warehouse_deposit_items", Bot.Settings.WarehouseSettings.DepositItems)
			ImGui.SameLine()
			ImGui.Text("Deposit items")

			ImGui.Spacing()

			ImGui.Text("Never deposit these items")
			valueChanged, BotSettings.WarehouseComboSelectedIndex = ImGui.Combo("##id_guid_warehouse_inventory_combo_select", BotSettings.WarehouseComboSelectedIndex, BotSettings.InventoryName)
			if valueChanged then
				local inventoryName = BotSettings.InventoryName[BotSettings.WarehouseComboSelectedIndex]

				if not table.find(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, inventoryName) then
					table.insert(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, inventoryName)
				end

				BotSettings.WarehouseComboSelectedIndex = 0
			end

			_, BotSettings.WarehouseSelectedIndex = ImGui.ListBox("##id_guid_warehouse_neverdeposit", BotSettings.WarehouseSelectedIndex, Bot.Settings.WarehouseSettings.IgnoreItemsNamed, 5)
			if ImGui.Button("Remove Item##id_guid_warehouse_neverdeposit_remove", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				if BotSettings.WarehouseSelectedIndex > 0 and BotSettings.WarehouseSelectedIndex <= table.length(Bot.Settings.WarehouseSettings.IgnoreItemsNamed) then
					table.remove(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, BotSettings.WarehouseSelectedIndex)
					BotSettings.WarehouseSelectedIndex = 0
				end
			end
		end

		if ImGui.CollapsingHeader("Repair", "id_gui_repair", true, false) then
			_, Bot.Settings.RepairSettings.RepairAfterTrader = ImGui.Checkbox("##id_guid_repair_aftertrader", Bot.Settings.RepairSettings.RepairAfterTrader)
			ImGui.SameLine()
			ImGui.Text("Repair after Warehouse")
			_, Bot.Settings.RepairSettings.RepairAfterWarehouse = ImGui.Checkbox("##id_guid_repair_afterwarehouse", Bot.Settings.RepairSettings.RepairAfterWarehouse)
			ImGui.SameLine()
			ImGui.Text("Repair after Trader")
		end

		if ImGui.CollapsingHeader("Trade Manager", "id_gui_trademanager", true, false) then
			_, Bot.Settings.TradeManagerSettings.TradeManagerOnInventoryFull = ImGui.Checkbox("##id_guid_trademanager_full_inventory", Bot.Settings.TradeManagerSettings.TradeManagerOnInventoryFull)
			ImGui.SameLine()
			ImGui.Text("Sell at Trader when inventory is full")
		end

		if ImGui.CollapsingHeader("Advanced Settings", "id_gui_adv_settings", true, false) then
			if ImGui.CollapsingHeader("Be very careful with options below", "id_gui_adv_settings_fish_aloneboat", true, false) then
				_, Bot.Settings.PlayerRun = ImGui.Checkbox("##id_guid_adv_settings_fish_alone_boat_sprint", Bot.Settings.PlayerRun)
				ImGui.SameLine()
				ImGui.Text("Sprint when moving instead of walking")
				_, Bot.Settings.HookFishHandleGameSettings.UseOldAnimations = ImGui.Checkbox("##id_guid_adv_settings_fish_alone_boat_old_animations", Bot.Settings.HookFishHandleGameSettings.UseOldAnimations)
				ImGui.SameLine()
				ImGui.Text("Use old animations when fishing")
				_, Bot.Settings.OnBoat = ImGui.Checkbox("##id_guid_adv_settings_fish_alone_boat_onboat", Bot.Settings.OnBoat)
				ImGui.SameLine()
				ImGui.Text("Stop fishing when the inventory is full")
				_, Bot.Settings.HookFishHandleGameSettings.NoDelay = ImGui.Checkbox("##id_guid_adv_settings_fish_alone_boat_nodelay", Bot.Settings.HookFishHandleGameSettings.NoDelay)
				ImGui.SameLine()
				ImGui.Text("Disable delay when fish bite")
				_, Bot.Settings.StartFishingSettings.MaxEnergyCheat = ImGui.Checkbox("##id_guid_adv_settings_fish_alone_hook_fast_game", Bot.Settings.StartFishingSettings.MaxEnergyCheat)
				ImGui.SameLine()
				ImGui.Text("Max Energy Cast (uses no energy)")
			end

			if ImGui.CollapsingHeader("Debug", "id_adv_settings_debug", true, false) then
				_, Bot.Settings.PrintConsoleState = ImGui.Checkbox("##id_guid_adv_settings_printconsolestate", Bot.Settings.PrintConsoleState)
				ImGui.SameLine()
				ImGui.Text("Print bot state on console")
				ImGui.SameLine()
				_, Bot.EnableDebug = ImGui.Checkbox("##id_guid_adv_settings_debug_enable", Bot.EnableDebug)
				ImGui.SameLine()
				ImGui.Text("Enable Debug")

				if Bot.EnableDebug then
					if ImGui.CollapsingHeader("Debug options", "id_guid_adv_settings_debug_enable_options", true, false) then
						_, Bot.EnableDebugMainWindow = ImGui.Checkbox("##id_guid_adv_settings_debug_enable_options_enable_mainwindow", Bot.EnableDebugMainWindow)
						ImGui.SameLine()
						ImGui.Text("Enable Main Window Debug")

						ImGui.SameLine()

						_, Bot.EnableDebugRadar = ImGui.Checkbox("##id_guid_adv_settings_debug_enable_options_enable_radar", Bot.EnableDebugRadar)
						ImGui.SameLine()
						ImGui.Text("Enable Radar Debug")

						_, Bot.EnableDebugInventory = ImGui.Checkbox("##id_guid_adv_settings_debug_enable_options_enable_inventory", Bot.EnableDebugInventory)
						ImGui.SameLine()
						ImGui.Text("Enable Inventory Debug")
					end
				end
			end
		end

		ImGui.End()
	end
end

function BotSettings.UpdateInventoryList()
	local selfPlayer = GetSelfPlayer()

	if selfPlayer then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if not table.find(BotSettings.InventoryName, v.ItemEnchantStaticStatus.Name) then
				table.insert(BotSettings.InventoryName, v.ItemEnchantStaticStatus.Name)
			end
		end
	end
end

function BotSettings.UpdateBaitComboBox()
	local selfPlayer = GetSelfPlayer()
	BotSettings.BaitComboBoxItems = { "None" }

	if selfPlayer then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if v.ItemEnchantStaticStatus.Type == 2 then
				if not table.find(BotSettings.BaitComboBoxItems, v.ItemEnchantStaticStatus.Name) then
					table.insert(BotSettings.BaitComboBoxItems, v.ItemEnchantStaticStatus.Name)
				end
			end
		end
	end
end

function BotSettings.OnDrawGuiCallback()
	BotSettings.DrawBotSettings()
end
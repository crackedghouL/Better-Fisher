-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

AdvancedSettings = {}
AdvancedSettings.Visible = false

-----------------------------------------------------------------------------
-- AdvancedSettings Functions
-----------------------------------------------------------------------------

function AdvancedSettings.DrawAdvancedSettings()
	if AdvancedSettings.Visible then
		_, AdvancedSettings.Visible = ImGui.Begin("Advanced Settings", AdvancedSettings.Visible, ImVec2(350, 400), -1.0, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoResize)

		if ImGui.Button("Save settings", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
			Bot.SaveSettings()
			print("Settings saved")
		end
		ImGui.SameLine()
		if ImGui.Button("Load settings", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.LoadSettings()
			print("Settings loaded")
		end

		ImGui.Columns(1)
		ImGui.Spacing()

		if ImGui.CollapsingHeader("Delays", "id_gui_delays_option", true, false) then
			if ImGui.TreeNode("Hooking") then
				_, Bot.Settings.HookFishStateSettings.UseRandomSeconds = ImGui.Checkbox("##id_guid_delays_option_use_random_seconds", Bot.Settings.HookFishStateSettings.UseRandomSeconds)
				ImGui.SameLine()
				ImGui.Text("Enable wait random seconds")
				if Bot.Settings.HookFishStateSettings.UseRandomSeconds then
					ImGui.Text("When fish hook, the bot wait random seconds from " .. Bot.Settings.HookFishStateSettings.HookMinSeconds .. " and " .. Bot.Settings.HookFishStateSettings.HookMaxSeconds)
					_, Bot.Settings.HookFishStateSettings.HookMinSeconds = ImGui.SliderInt("Min seconds##id_guid_delays_option_min_seconds", Bot.Settings.HookFishStateSettings.HookMinSeconds, 1, Bot.Settings.HookFishStateSettings.HookMaxSeconds)
					_, Bot.Settings.HookFishStateSettings.HookMaxSeconds = ImGui.SliderInt("Max seconds##id_guid_delays_option_max_seconds", Bot.Settings.HookFishStateSettings.HookMaxSeconds, Bot.Settings.HookFishStateSettings.HookMinSeconds, 170)
				end
				ImGui.Text("% of \"perfect hook\"")
				_, Bot.Settings.HookFishStateSettings.HookMinSeconds = ImGui.SliderInt("%##id_guid_delays_option_min_seconds", Bot.Settings.HookFishStateSettings.PerfectPerc, 1, 99)
				ImGui.TreePop()
			end
		end

		if ImGui.CollapsingHeader("Distance", "id_gui_distance_option", true, false) then
			if Bot.Settings.StartFishingSettings.FishingMethod == StartFishingState.SETTINGS_ON_NORMAL_FISHING then
				_, Bot.Settings.PlayerRun = ImGui.Checkbox("##id_guid_distance_option_fish_alone_boat_sprint", Bot.Settings.PlayerRun)
				ImGui.SameLine()
				ImGui.Text("Sprint when moving instead of walking")
			end
			_, Bot.Settings.UseAutorun = ImGui.Checkbox("##id_guid_distance_option_fish_alone_boat_use_autorun", Bot.Settings.UseAutorun)
			ImGui.SameLine()
			ImGui.Text("Use autorun to a certain distance of destination")
			_, Bot.Settings.UseAutorunDistance = ImGui.SliderInt("Distance##id_guid_distance_option_use_autorun_until_distance", Bot.Settings.UseAutorunDistance, 500, 4000)
			_, Bot.Settings.FishingSpotRadius = ImGui.SliderInt("Fish Spot Radius##id_guid_distance_option_fishing_spot_radius", Bot.Settings.FishingSpotRadius, 100, 1000)
		end

		if ImGui.CollapsingHeader("Anti report", "id_gui_anti_report_option", true, false) then
			_, Bot.Settings.StopWhenPeopleNearby = ImGui.Checkbox("##id_guid_adv_option_stop_bot_when_someone_nearby", Bot.Settings.StopWhenPeopleNearby)
			ImGui.SameLine()
			ImGui.Text("Stop bot when someone is nearby")
			if Bot.Settings.StopWhenPeopleNearby then
				_, Bot.Settings.StopWhenPeopleNearbyDistance = ImGui.SliderInt("Distance##id_guid_anti_report_option_stop_bot_when_someone_nearby_distance", Bot.Settings.StopWhenPeopleNearbyDistance, 50, 10000)
			end
			_, Bot.Settings.PauseWhenPeopleNearby = ImGui.Checkbox("##id_guid_anti_report_option_pause_bot_when_someone_nearby", Bot.Settings.PauseWhenPeopleNearby)
			ImGui.SameLine()
			ImGui.Text("Enable pause when someone is nearby")
			if Bot.Settings.PauseWhenPeopleNearby then
				_, Bot.Settings.PauseWhenPeopleNearbySeconds = ImGui.SliderInt("Seconds##id_guid_anti_report_option_stop_bot_when_someone_nearby_seconds", Bot.Settings.PauseWhenPeopleNearbySeconds, 30, 3600)
			end
		end

		if ImGui.CollapsingHeader("Cheats", "id_gui_cheats_option", true, false) then
			_, Bot.Settings.HookFishHandleGameSettings.NoDelay = ImGui.Checkbox("##id_guid_adv_option_nodelay", Bot.Settings.HookFishHandleGameSettings.NoDelay)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(1,0,0,1), "Disable delay when fish bite")
			_, Bot.Settings.StartFishingSettings.UseMaxEnergy = ImGui.Checkbox("##id_guid_adv_option_hook_fast_game", Bot.Settings.StartFishingSettings.UseMaxEnergy)
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(1,0,0,1), "Max Energy Cast (uses no energy)")
		end

		if ImGui.CollapsingHeader("Debug", "id_gui_debug_option", true, false) then
			_, Bot.Settings.PrintConsoleState = ImGui.Checkbox("##id_guid_debug_option_printconsolestate", Bot.Settings.PrintConsoleState)
			ImGui.SameLine()
			ImGui.Text("Print bot state on console")
			_, Bot.EnableDebug = ImGui.Checkbox("##id_guid_debug_option_debug_enable", Bot.EnableDebug)
			ImGui.SameLine()
			ImGui.Text("Enable Debug")

			if Bot.EnableDebug then
				if ImGui.TreeNode("Debug") then
					_, Bot.EnableDebugMainWindow = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_mainwindow", Bot.EnableDebugMainWindow)
					ImGui.SameLine()
					ImGui.Text("Enable Main Window Debug")
					_, Bot.EnableDebugInventory = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_inventory", Bot.EnableDebugInventory)
					ImGui.SameLine()
					ImGui.Text("Enable Inventory Debug")
					_, Bot.EnableDebugDeathState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_deathstate", Bot.EnableDebugDeathState)
					ImGui.SameLine()
					ImGui.Text("Enable DeathState Debug")
					_, Bot.EnableDebugEquipFishignRodState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_equipfishingrodstate", Bot.EnableDebugEquipFishignRodState)
					ImGui.SameLine()
					ImGui.Text("Enable EquipFishignRodState Debug")
					_, Bot.EnableDebugEquipFloatState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_equipfloatstate", Bot.EnableDebugEquipFloatState)
					ImGui.SameLine()
					ImGui.Text("Enable EquipFloatState Debug")
					_, Bot.EnableDebugHookFishState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_hookfishstate", Bot.EnableDebugHookFishState)
					ImGui.SameLine()
					ImGui.Text("Enable HookFishState Debug")
					_, Bot.EnableDebugHookHandleGameState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_hookhandlegamestate", Bot.EnableDebugHookHandleGameState)
					ImGui.SameLine()
					ImGui.Text("Enable HookHandleGameState Debug")
					_, Bot.EnableDebugInventoryDeleteState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_inventorydeletestate", Bot.EnableDebugInventoryDeleteState)
					ImGui.SameLine()
					ImGui.Text("Enable InventoryDeleteState Debug")
					_, Bot.EnableDebugLootState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_lootstate", Bot.EnableDebugLootState)
					ImGui.SameLine()
					ImGui.Text("Enable LootState Debug")
					_, Bot.EnableDebugRepairState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_repairstate", Bot.EnableDebugRepairState)
					ImGui.SameLine()
					ImGui.Text("Enable RepairState Debug")
					_, Bot.EnableDebugStartFishingState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_startfishingstate", Bot.EnableDebugStartFishingState)
					ImGui.SameLine()
					ImGui.Text("Enable StartFishingState Debug")
					_, Bot.EnableDebugTradeManagerState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_trademanagerstate", Bot.EnableDebugTradeManagerState)
					ImGui.SameLine()
					ImGui.Text("Enable TradeManagerState Debug")
					_, Bot.EnableDebugVendorState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_vendorstate", Bot.EnableDebugVendorState)
					ImGui.SameLine()
					ImGui.Text("Enable VendorState Debug")
					_, Bot.EnableDebugWarehouseState = ImGui.Checkbox("##id_guid_debug_option_debug_options_enable_warehousestate", Bot.EnableDebugWarehouseState)
					ImGui.SameLine()
					ImGui.Text("Enable WarehouseState Debug")
				end
			end
		end
		ImGui.End()
	end
end

function AdvancedSettings.OnDrawGuiCallback()
	AdvancedSettings.DrawAdvancedSettings()
end
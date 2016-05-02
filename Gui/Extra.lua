-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

ExtraWindow = { }
ExtraWindow.Visible = false

-----------------------------------------------------------------------------
-- ExtraWindow Functions
-----------------------------------------------------------------------------

function ExtraWindow.DrawExtraWindow()
	if ExtraWindow.Visible then
		_, ExtraWindow.Visible = ImGui.Begin("Extra", ExtraWindow.Visible, ImVec2(350, 145), -1.0)

		ImGui.Columns(2)
		ImGui.Separator()
		if ImGui.Button("Radar", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Radar.Visible = true
		end
		ImGui.Spacing()
		if ImGui.Button("Inventory", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			InventoryList.Visible = true
		end
		ImGui.Spacing()
		if ImGui.Button("Consumables", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			LibConsumableWindow.Visible = true
		end
		ImGui.Spacing()
		if ImGui.Button("Loot stats", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Stats.Visible = true
		end

		ImGui.NextColumn()
		if ImGui.Button("Go to warehouse", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.WarehouseState.Forced = true
			Bot.WarehouseState.ManualForced = true
			print("[" .. os.date(Bot.UsedTimezone) .. "] Go to warehouse")
		end
		ImGui.Spacing()
		if ImGui.Button("Go to trader", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.TradeManagerState.Forced = true
			print("[" .. os.date(Bot.UsedTimezone) .. "] Go to trade manager")
		end
		ImGui.Spacing()
		if ImGui.Button("Go to vendor", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.VendorState.Forced = true
			print("[" .. os.date(Bot.UsedTimezone) .. "] Go to vendor")
		end
		ImGui.Spacing()
		if ImGui.Button("Go repair", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.RepairState.Forced = true
			print("[" .. os.date(Bot.UsedTimezone) .. "] Go repair")
		end

		ImGui.Columns(1)
		ImGui.Separator()
		ImGui.End()
	end
end

function ExtraWindow.OnDrawGuiCallback()
	ExtraWindow.DrawExtraWindow()
end
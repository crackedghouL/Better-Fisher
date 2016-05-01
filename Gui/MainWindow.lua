-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

MainWindow = { }

MainWindow.Popupconfirm = false
MainWindow.ConfirmPopup = false

-----------------------------------------------------------------------------
-- MainWindow Functions
-----------------------------------------------------------------------------

function MainWindow.DrawMainWindow()
	local _, shouldDisplay = ImGui.Begin("Better Fisher v0.8c BETA", true, ImVec2(350, 115), -1.0)

	if shouldDisplay then
		local selfPlayer = GetSelfPlayer()

		if ImGui.BeginPopup("Confirm") then
			ImGui.TextColored(ImVec4(1,0.20,0.20,1) ,"WARNING!")
			ImGui.Text("By default all \"Fishing Rods\" and \"Steel Fishing Rods\",\nwill be deleted on 0 durability because they can't be repaired.")
			ImGui.Spacing()
			if ImGui.Button("Continue##btn_ok_start_bot", ImVec2(ImGui.GetContentRegionAvailWidth() / 3, 20)) then
				Bot.Start()
				ImGui.CloseCurrentPopup()
			end
			ImGui.SameLine()
			if ImGui.Button("Disable it##btn_change_option_start_bot", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
				Bot.Settings.DeleteUsedRods = false
				ImGui.CloseCurrentPopup()
			end
			ImGui.SameLine()
			if ImGui.Button("Cancel##btn_cancel_start_bot", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				ImGui.CloseCurrentPopup()
			end
			ImGui.EndPopup()
		end

		ImGui.Columns(2)
		ImGui.Separator()
		ImGui.Text("State:")
		ImGui.SameLine()
		if not Bot.EnableDebugMainWindow then
			if Bot.Running and Bot.Fsm.CurrentState then
				ImGui.TextColored(ImVec4(0.20,1,0.20,1), "Running")
			elseif selfPlayer.Inventory.FreeSlots == 0 then
				ImGui.TextColored(ImVec4(1,0.20,0.20,1), "Inv. Full")
			else
				ImGui.TextColored(ImVec4(1,0.20,0.20,1), "Stopped")
			end
		else
			ImGui.Text(selfPlayer.CurrentActionName)
		end

		ImGui.NextColumn()

		ImGui.Text("Inv. slots left:")
		ImGui.SameLine()
		if selfPlayer.Inventory.FreeSlots > 25 then
			ImGui.TextColored(ImVec4(0.20,1,0.20,1), selfPlayer.Inventory.FreeSlots) -- green
		elseif selfPlayer.Inventory.FreeSlots >= 10 and selfPlayer.Inventory.FreeSlots <= 25 then
			ImGui.TextColored(ImVec4(1,0.80,0.20,1), selfPlayer.Inventory.FreeSlots) -- yellow
		elseif selfPlayer.Inventory.FreeSlots >= 5 and selfPlayer.Inventory.FreeSlots < 10 then
			ImGui.TextColored(ImVec4(1,0.40,0.20,1), selfPlayer.Inventory.FreeSlots) -- orange
		elseif selfPlayer.Inventory.FreeSlots ~= 0 and selfPlayer.Inventory.FreeSlots < 5 then
			ImGui.TextColored(ImVec4(1,0.20,0.20,1), selfPlayer.Inventory.FreeSlots) -- red
		else
			ImGui.Text(selfPlayer.Inventory.FreeSlots)
		end

		ImGui.Columns(1)
		ImGui.Separator()
		ImGui.Spacing()

		ImGui.Columns(1)
		if not Bot.Running then
			if ImGui.Button("Start##btn_start_bot", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
				if Bot.Settings.DeleteUsedRods == true then
					ImGui.OpenPopup("Confirm")
				else
					Bot.Start()
				end
			end
			ImGui.SameLine()
			if ImGui.Button("Profile editor", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				ProfileEditor.Visible = true
			end
		else
			if ImGui.Button("Stop##btn_stop_bot", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
				Bot.Stop()
			end
		end

		ImGui.Columns(1)
		ImGui.Spacing()

		ImGui.Columns(1)
		if ImGui.Button("Bot Settings", ImVec2(ImGui.GetContentRegionAvailWidth() / 2, 20)) then
			BotSettings.Visible = true
		end
		ImGui.SameLine()
		if ImGui.Button("Extra", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			ExtraWindow.Visible = true
		end

		ImGui.End()
	end
end

function MainWindow.OnDrawGuiCallback()
	MainWindow.DrawMainWindow()
end
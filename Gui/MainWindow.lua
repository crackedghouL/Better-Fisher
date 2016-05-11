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
	local _, shouldDisplay = ImGui.Begin("Better Fisher v0.9 BETA", true, ImVec2(320, 105), -1.0, ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoResize)

	if shouldDisplay then
		local selfPlayer = GetSelfPlayer()

		if h == nil then
			h = 0
			m = 0
			s = 0
		end

		if Bot.Running then
			t = math.ceil((Bot.Stats.TotalSession + Pyx.System.TickCount - Bot.Stats.SessionStart) / 1000)
			s = t % 60
			m = math.floor(t / 60) % 60
			h = math.floor(t / (60 * 60))
		end

		if ImGui.BeginMenuBar() then
			if ImGui.BeginMenu("Settings") then
				if ImGui.MenuItem("Start/Stop", "ALT+S") then
					if not Bot.Running then
						if Bot.Settings.DeleteUsedRods == true then
							ConfirmWindow.Visible = true
						else
							Bot.Start()
						end
					else
						Bot.Stop()
					end
				end
				ImGui.Separator()
				if ImGui.MenuItem("Open Profile Editor", "ALT+P", ProfileEditor.Visible) then
					if ProfileEditor.Visible == false then
						ProfileEditor.Visible = true
					elseif ProfileEditor.Visible == true then
						ProfileEditor.Visible = false
					end
				end
				if ImGui.MenuItem("Open Bot Settings", "ALT+O", BotSettings.Visible) then
					if BotSettings.Visible == false then
						BotSettings.Visible = true
					elseif BotSettings.Visible == true then
						BotSettings.Visible = false
					end
				end
				ImGui.EndMenu()
			end
			if ImGui.BeginMenu("Extra") then
				if ImGui.MenuItem("Radar", "ALT+R", Radar.Visible) then
					if Radar.Visible == false then
						Radar.Visible = true
					elseif Radar.Visible == true then
						Radar.Visible = false
					end
				end
				if ImGui.MenuItem("Inventory", "ALT+B", InventoryList.Visible) then
					if InventoryList.Visible == false then
						InventoryList.Visible = true
					elseif InventoryList.Visible == true then
						InventoryList.Visible = false
					end
				end
				if ImGui.MenuItem("Consumables", "ALT+C", LibConsumableWindow.Visible) then
					if LibConsumableWindow.Visible == false then
						LibConsumableWindow.Visible = true
					elseif LibConsumableWindow.Visible == true then
						LibConsumableWindow.Visible = false
					end
				end
				if ImGui.MenuItem("Loot stats", "ALT+L",Stats.Visible) then
					if Stats.Visible == false then
						Stats.Visible = true
					elseif Stats.Visible == true then
						Stats.Visible = false
					end
				end
				ImGui.EndMenu()
			end
			if ImGui.BeginMenu("Force") then
				if ImGui.MenuItem("Go to Warehouse", "ALT+W") then
					if Bot.Running then
						Bot.WarehouseState.ManualForced = true
						print("[" .. os.date(Bot.UsedTimezone) .. "] Go to Warehouse")
					else
						print("[" .. os.date(Bot.UsedTimezone) .. "] Start the Script first!")
					end
				end
				if ImGui.MenuItem("Go to Trader", "ALT+T") then
					if Bot.Running then
						Bot.TradeManagerState.ManualForced = true
						print("[" .. os.date(Bot.UsedTimezone) .. "] Go to Trader")
					else
						print("[" .. os.date(Bot.UsedTimezone) .. "] Start the Script first!")
					end
				end
				if ImGui.MenuItem("Go to Vendor", "ALT+V") then
					if Bot.Running then
						Bot.VendorState.ManualForced = true
						print("[" .. os.date(Bot.UsedTimezone) .. "] Go to Vendor")
					else
						print("[" .. os.date(Bot.UsedTimezone) .. "] Start the Script first!")
					end
				end
				if ImGui.MenuItem("Go Repair", "ALT+G") then
					if Bot.Running then
						Bot.RepairState.ManualForced = true
						print("[" .. os.date(Bot.UsedTimezone) .. "] Go Repair")
					else
						print("[" .. os.date(Bot.UsedTimezone) .. "] Start the Script first!")
					end
				end
				ImGui.EndMenu()
			end
			if ImGui.BeginMenu("Info") then
				if ImGui.MenuItem("Aboud BF", "") then 
					print("[" .. os.date(Bot.UsedTimezone) .. "] ####################################") 
					print("[" .. os.date(Bot.UsedTimezone) .. "] #  Made with love by spearmint <3  #") 
					print("[" .. os.date(Bot.UsedTimezone) .. "] #     Thanks to: gklt, Akafist,    #") 
					print("[" .. os.date(Bot.UsedTimezone) .. "] #  tyty123, borek24 and MrUnreal.  #")
					print("[" .. os.date(Bot.UsedTimezone) .. "] #~Fishing is love, fishing is life~#")
					print("[" .. os.date(Bot.UsedTimezone) .. "] ####################################") 
				end
				ImGui.EndMenu()
			end
			ImGui.EndMenuBar()
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

		ImGui.Columns(2)
		ImGui.Text("Time " .. string.format("%02.f:%02.f:%02.f", h, m, s))
		ImGui.NextColumn()
		ImGui.Text("Loots: " .. string.format("%i", Bot.Stats.Loots))

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.End()
	end
end

function MainWindow.OnDrawGuiCallback()
	MainWindow.DrawMainWindow()
end
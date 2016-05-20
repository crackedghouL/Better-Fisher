-----------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------

MainWindow = {}

MainWindow.Popupconfirm = false
MainWindow.ConfirmPopup = false

-----------------------------------------------------------------------------
-- MainWindow Functions
-----------------------------------------------------------------------------

function MainWindow.DrawMainWindow()
	local _, shouldDisplay = ImGui.Begin("Better Fisher v0.9b BETA", true, ImVec2(320, 105), -1.0, ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoResize)

	if shouldDisplay then
		local selfPlayer = GetSelfPlayer()

		if Bot.Hours == nil then
			Bot.Hours = 0
			Bot.Minutes = 0
			Bot.Seconds = 0
		end

		if ImGui.BeginMenuBar() then
			if ImGui.BeginMenu("Settings") then
				if ImGui.MenuItem("Start/Stop", "ALT+S") then
					if not Bot.Running then
						if Bot.Settings.DeleteUsedRods then
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
					if not ProfileEditor.Visible then
						ProfileEditor.Visible = true
					elseif ProfileEditor.Visible then
						ProfileEditor.Visible = false
					end
				end
				if ImGui.MenuItem("Open Bot Settings", "ALT+O", BotSettings.Visible) then
					if not BotSettings.Visible then
						BotSettings.Visible = true
					elseif BotSettings.Visible then
						BotSettings.Visible = false
					end
				end
				ImGui.EndMenu()
			end
			if ImGui.BeginMenu("Extra") then
				if ImGui.MenuItem("Inventory", "ALT+B", InventoryList.Visible) then
					if not InventoryList.Visible then
						InventoryList.Visible = true
					elseif InventoryList.Visible then
						InventoryList.Visible = false
					end
				end
				if ImGui.MenuItem("Consumables", "ALT+C", LibConsumableWindow.Visible) then
					if not LibConsumableWindow.Visible then
						LibConsumableWindow.Visible = true
					elseif LibConsumableWindow.Visible then
						LibConsumableWindow.Visible = false
					end
				end
				if ImGui.MenuItem("Loot stats", "ALT+L",Stats.Visible) then
					if not Stats.Visible then
						Stats.Visible = true
					elseif Stats.Visible then
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
					local motto = {
						'   ~Fishing is love, fishing is life~   ',
						' ~So Long, and Thanks for All the Fish~ ',
						'     ~The whole world is my hotspot~    ',
						'  ~The power of fish makes us infinite~ '
					}

					print("[" .. os.date(Bot.UsedTimezone) .. "] ##########################################")
					print("[" .. os.date(Bot.UsedTimezone) .. "] #     Made with love by spearmint <3     #")
					print("[" .. os.date(Bot.UsedTimezone) .. "] #   Thanks to: gklt, Akafist, tyty123    #")
					print("[" .. os.date(Bot.UsedTimezone) .. "] #   pat, Pookie, borek24 and MrUnreal.   #")
					print("[" .. os.date(Bot.UsedTimezone) .. "] #" .. motto[math.random(#motto)] .. "#")
					print("[" .. os.date(Bot.UsedTimezone) .. "] ##########################################")
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
			if Bot.Running and Bot.FSM.CurrentState then
				ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Running")
			elseif selfPlayer.Inventory.FreeSlots == 0 then
				ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Inv. Full")
			else
				ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Stopped")
			end
		else
			ImGui.Text(selfPlayer.CurrentActionName)
		end

		ImGui.NextColumn()

		ImGui.Text("Inv. slots left:")
		ImGui.SameLine()
		if selfPlayer.Inventory.FreeSlots > 25 then
			ImGui.TextColored(ImVec4(0.2,1,0.2,1), selfPlayer.Inventory.FreeSlots) -- green
		elseif selfPlayer.Inventory.FreeSlots >= 10 and selfPlayer.Inventory.FreeSlots <= 25 then
			ImGui.TextColored(ImVec4(1,0.8,0.2,1), selfPlayer.Inventory.FreeSlots) -- yellow
		elseif selfPlayer.Inventory.FreeSlots >= 5 and selfPlayer.Inventory.FreeSlots < 10 then
			ImGui.TextColored(ImVec4(1,0.4,0.2,1), selfPlayer.Inventory.FreeSlots) -- orange
		elseif selfPlayer.Inventory.FreeSlots ~= 0 and selfPlayer.Inventory.FreeSlots < 5 then
			ImGui.TextColored(ImVec4(1,0.2,0.2,1), selfPlayer.Inventory.FreeSlots) -- red
		else
			ImGui.Text(selfPlayer.Inventory.FreeSlots)
		end

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.Columns(2)
		ImGui.Text("Time " .. string.format("%02.f:%02.f:%02.f", Bot.Hours, Bot.Minutes, Bot.Seconds))
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
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
	local _, shouldDisplay = ImGui.Begin(Bot.Version, true, ImVec2(265, 150), -1.0, ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoResize)

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
				if ImGui.MenuItem("Pause", "ALT+P") then
					if Bot.Running then
						if not Bot.Paused and Bot.PausedManual then
							Bot.PausedManual = false
						else
							Bot.PausedManual = true
						end
					else
						print("Start the Script first!")
					end
				end
				ImGui.Separator()
				if ImGui.MenuItem("Open Profile Editor", "ALT+E", ProfileEditor.Visible) then
					if not ProfileEditor.Visible then
						ProfileEditor.Visible = true
					elseif ProfileEditor.Visible then
						ProfileEditor.Visible = false
					end
				end
				if ImGui.MenuItem("Open Settings", "ALT+O", BotSettings.Visible) then
					if not BotSettings.Visible then
						BotSettings.Visible = true
					elseif BotSettings.Visible then
						BotSettings.Visible = false
					end
				end
				if ImGui.MenuItem("Open Advanced Settings", "ALT+D", AdvancedSettings.Visible) then
					if not AdvancedSettings.Visible then
						AdvancedSettings.Visible = true
					elseif AdvancedSettings.Visible then
						AdvancedSettings.Visible = false
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
				if ImGui.MenuItem("Stats", "ALT+L",Stats.Visible) then
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
					if Bot.Running and (not Bot.Paused or not Bot.PausedManual) then
						Bot.WarehouseState.ManualForced = true
						if Bot.EnableDebug and Bot.EnableDebugMainWindow then
							print("Go to Warehouse")
						end
					elseif not Bot.Paused and Bot.PausedManual then
						print("Unpause the bot first!")
					else
						print("Start the Script first!")
					end
				end
				if ImGui.MenuItem("Go to Trader", "ALT+T") then
					if Bot.Running and (not Bot.Paused or not Bot.PausedManual) then
						Bot.TradeManagerState.ManualForced = true
						if Bot.EnableDebug and Bot.EnableDebugMainWindow then
							print("Go to Trader")
						end
					elseif not Bot.Paused and Bot.PausedManual then
						print("Unpause the bot first!")
					else
						print("Start the Script first!")
					end
				end
				if ImGui.MenuItem("Go to Vendor", "ALT+V") then
					if Bot.Running and (not Bot.Paused or not Bot.PausedManual) then
						Bot.VendorState.ManualForced = true
						if Bot.EnableDebug and Bot.EnableDebugMainWindow then
							print("Go to Vendor")
						end
					elseif not Bot.Paused and Bot.PausedManual then
						print("Unpause the bot first!")
					else
						print("Start the Script first!")
					end
				end
				if ImGui.MenuItem("Go Repair", "ALT+R") then
					if Bot.Running and (not Bot.Paused or not Bot.PausedManual) then
						Bot.RepairState.ManualForced = true
						if Bot.EnableDebug and Bot.EnableDebugMainWindow then
							print("Go Repair")
						end
					elseif not Bot.Paused and Bot.PausedManual then
						print("Unpause the bot first!")
					else
						print("Start the Script first!")
					end
				end
				ImGui.EndMenu()
			end
			if ImGui.BeginMenu("Info") then
				if ImGui.MenuItem("Aboud BF", "") then
					local motto = {
						' ~~~~Fishing is love, fishing is life~~~ ',
						' ~So Long, and Thanks for All the Fish~ ',
						'~~~The whole world is my hotspot~~~',
						' ~The power of fish makes us infinite~ ',
						' ~~I only fish on days that end in "Y"~~ ',
						' ~~~Born to fish ... Forced to work~~~ '
					}
					print("*******************************************")
					print("***** Made with love by spearmint <3 ****")
					print("*** Thanks: gklt, Akafist, tyty123, naski ***")
					print("** pat, Pookie, borek24, MrUnreal, Edan **")
					print("***** Triplany and all the community *****")
					print("*" .. motto[math.random(#motto)] .. "*")
					print("*******************************************")
				end
				if ImGui.MenuItem("Check for update", "") then
					if Bot.IsDev then
						os.execute("start https://github.com/miracle091/Better-Fisher/tree/develop")
					else
						os.execute("start https://github.com/miracle091/Better-Fisher/releases")
					end
				end
				ImGui.EndMenu()
			end
			ImGui.EndMenuBar()
		end

		ImGui.Columns(2)
		ImGui.Separator()
		ImGui.Text("State:")
		ImGui.SameLine()
		if not Bot.EnableDebug and not Bot.EnableDebugMainWindow then
			if Bot.Running then
				if (not Bot.WasRunning and Bot.Paused) or ((Bot.Paused or Bot.PausedManual) and Bot.LoopCounter > 0) then
					ImGui.TextColored(ImVec4(1,0.8,0.2,1), "Paused") -- yellow
				else
					ImGui.TextColored(ImVec4(0.2,1,0.2,1), "Running") -- green
				end
			else
				ImGui.TextColored(ImVec4(1,0.2,0.2,1), "Stopped") -- red
			end
		else
			if Bot.CheckIfLoggedIn() then
				ImGui.Text(selfPlayer.CurrentActionName)
			else
				ImGui.Text("N/A")
			end
		end

		ImGui.NextColumn()

		ImGui.Text("Inv. slots left:")
		ImGui.SameLine()
		if Bot.CheckIfLoggedIn() then
			if selfPlayer.Inventory.FreeSlots > 20 then
				ImGui.TextColored(ImVec4(0.2,1,0.2,1), selfPlayer.Inventory.FreeSlots) -- green
			elseif selfPlayer.Inventory.FreeSlots >= 10 and selfPlayer.Inventory.FreeSlots <= 20 then
				ImGui.TextColored(ImVec4(1,0.8,0.2,1), selfPlayer.Inventory.FreeSlots) -- yellow
			elseif selfPlayer.Inventory.FreeSlots >= 5 and selfPlayer.Inventory.FreeSlots < 10 then
				ImGui.TextColored(ImVec4(1,0.4,0.2,1), selfPlayer.Inventory.FreeSlots) -- orange
			elseif selfPlayer.Inventory.FreeSlots ~= 0 and selfPlayer.Inventory.FreeSlots < 5 then
				ImGui.TextColored(ImVec4(1,0.2,0.2,1), selfPlayer.Inventory.FreeSlots) -- red
			else
				ImGui.Text(selfPlayer.Inventory.FreeSlots)
			end
		else
			ImGui.Text("N/A")
		end

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.Columns(2)
		if (not Bot.WasRunning and Bot.Paused) or ((Bot.Paused or Bot.PausedManual) and Bot.LoopCounter > 0) then
			ImGui.Text("Time:")
			ImGui.SameLine()
			ImGui.TextColored(ImVec4(1,0.8,0.2,1), string.format("%02.f:%02.f:%02.f", Bot.Hours, Bot.Minutes, Bot.Seconds)) -- yellow
		else
			ImGui.Text(string.format("Time:  %02.f:%02.f:%02.f", Bot.Hours, Bot.Minutes, Bot.Seconds))
		end
		ImGui.NextColumn()
		ImGui.Text("Loots: " .. string.format("%i", Bot.Stats.Loots))

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.Columns(1)
		ImGui.Text("Fishing Level: " ..  Bot.FishingLevel .. " (" .. string.format("%.2f", Bot.FishingPercentExp) .. "%%)")

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.End()
	end
end

function MainWindow.OnDrawGuiCallback()
	MainWindow.DrawMainWindow()
end
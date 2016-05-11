---------------------------------------------
-- Variables
---------------------------------------------

Stats = { }
Stats.Visible = false

SilverInitial = GetSelfPlayer().Inventory.Money
SilverGained = 0

---------------------------------------------
-- Stats Functions
---------------------------------------------

function Stats.DrawStats()
	if Stats.Visible then
		_, Stats.Visible = ImGui.Begin("Loot Stats", Stats.Visible, ImVec2(350, 200), -1.0)

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

		if Bot.Stats.Loots > 0 then
			statsWhites = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[0] or 0, (Bot.Stats.LootQuality[0] or 0) / Bot.Stats.Loots * 100)
			statsGreens = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[1] or 0, (Bot.Stats.LootQuality[1] or 0) / Bot.Stats.Loots * 100)
			statsBlues = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[2] or 0, (Bot.Stats.LootQuality[2] or 0) / Bot.Stats.Loots * 100)
			statsGolds = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[3] or 0, (Bot.Stats.LootQuality[3] or 0) / Bot.Stats.Loots * 100)
			statsOranges = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[4] or 0, (Bot.Stats.LootQuality[4] or 0) / Bot.Stats.Loots * 100)
			statsFishes = string.format("%i - %.02f%%%%", Bot.Stats.Fishes, Bot.Stats.Fishes / Bot.Stats.Loots * 100)
			statsTrashes = string.format("%i - %.02f%%%%", Bot.Stats.Trashes, Bot.Stats.Trashes / Bot.Stats.Loots * 100)
			statsKeys = string.format("%i - %.02f%%%%", Bot.Stats.Keys, Bot.Stats.Keys / Bot.Stats.Loots * 100)
			statsShards = string.format("%i - %.02f%%%%", Bot.Stats.Shards, Bot.Stats.Shards / Bot.Stats.Loots * 100)
		else
			statsWhites = "0 - 0.00%%"
			statsGreens = "0 - 0.00%%"
			statsBlues = "0 - 0.00%%"
			statsGolds = "0 - 0.00%%"
			statsOranges = "0 - 0.00%%"
			statsFishes = "0 - 0.00%%"
			statsTrashes = "0 - 0.00%%"
			statsKeys = "0 - 0.00%%"
			statsShards = "0 - 0.00%%"
		end

		ImGui.Columns(3)
		ImGui.Text("Time " .. string.format("%02.f:%02.f:%02.f", h, m, s))
		ImGui.NextColumn()
		ImGui.Text("Loots: " .. string.format("%i", Bot.Stats.Loots))
		ImGui.NextColumn()
		ImGui.Text("Avg.: " .. Bot.Stats.AverageLootTime .. "s")

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.Columns(1)
		ImGui.Text("Silver Gained: " .. Bot.comma_value(Bot.Stats.SilverGained))

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.Columns(2)
		ImGui.Text("Fishs: " .. statsFishes)
		ImGui.NextColumn()
		ImGui.Text("Trashes: " .. statsTrashes)

		ImGui.Columns(1)
		ImGui.Separator()

		if Bot.Settings.LootSettings.LootKeys == true or Bot.Settings.LootSettings.LootShards == true then
			ImGui.Columns(2)
			if Bot.Settings.LootSettings.LootKeys == true then
				ImGui.Text("Keys: " .. statsKeys)
			end
			ImGui.NextColumn()
			if Bot.Settings.LootSettings.LootShards == true then
				ImGui.Text("Shards: " .. statsShards)
			end

			ImGui.Columns(1)
			ImGui.Separator()
		end

		ImGui.Columns(1)
		if ImGui.CollapsingHeader("Fish quality", "id_gui_loot_quality", true, false) then
			if Bot.Settings.LootSettings.LootWhite == true or Bot.Settings.LootSettings.LootGreen == true then
				ImGui.Columns(2)
				if Bot.Settings.LootSettings.LootWhite == true then
					ImGui.Text("Whites: " .. statsWhites)
				end
				ImGui.NextColumn()
				if Bot.Settings.LootSettings.LootGreen == true then
					ImGui.Text("Greens: " .. statsGreens)
				end

				ImGui.Columns(1)
				ImGui.Separator()
			end

			if Bot.Settings.LootSettings.LootBlue == true or Bot.Settings.LootSettings.LootGold == true then
				ImGui.Columns(2)
				if Bot.Settings.LootSettings.LootBlue == true then
					ImGui.Text("Blues: " .. statsBlues)
				end
				ImGui.NextColumn()
				if Bot.Settings.LootSettings.LootGold == true then
					ImGui.Text("Golds: " .. statsGolds)
				end

				ImGui.Columns(1)
				ImGui.Separator()
			end

			if Bot.Settings.LootSettings.LootOrange == true then
				ImGui.Columns(1)
				ImGui.Text("Oranges: " .. statsOranges)

				ImGui.Columns(1)
				ImGui.Separator()
			end
		end

		ImGui.Columns(1)
		ImGui.Spacing()

		-- if ImGui.Button("Reset Stats##id_guid_reset_stats", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
		-- 	Bot.ResetStats()
		-- end

		ImGui.End()
	end
end

function Stats.OnDrawGuiCallback()
	Stats.DrawStats()
end
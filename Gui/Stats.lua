---------------------------------------------
-- Variables
---------------------------------------------

Stats = {}
Stats.Visible = false

SilverInitial = GetSelfPlayer().Inventory.Money
SilverGained = 0

---------------------------------------------
-- Stats Functions
---------------------------------------------

function Stats.DrawStats()
	if Stats.Visible then
		_, Stats.Visible = ImGui.Begin("Loot Stats", Stats.Visible, ImVec2(350, 220), -1.0)

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
			statsEggs = string.format("%i - %.02f%%%%", Bot.Stats.Eggs, Bot.Stats.Eggs / Bot.Stats.Loots * 100)
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
			statsEggs = "0 - 0.00%%"
		end

		ImGui.Columns(3)
		ImGui.Text("Time " .. string.format("%02.f:%02.f:%02.f", Bot.Hours, Bot.Minutes, Bot.Seconds))
		ImGui.NextColumn()
		ImGui.Text("Loots: " .. string.format("%i", Bot.Stats.Loots))
		ImGui.NextColumn()
		ImGui.Text("Avg: " .. Bot.Stats.AverageLootTime .. "s")

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.Columns(1)
		ImGui.Text("Silver Gained: " .. Bot.FormatMoney(Bot.Stats.SilverGained))

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.Columns(2)
		ImGui.Text("Fishes: " .. statsFishes)
		ImGui.NextColumn()
		ImGui.Text("Trashes: " .. statsTrashes)

		ImGui.Columns(1)
		ImGui.Separator()

		if Bot.Settings.LootSettings.LootKeys or Bot.Settings.LootSettings.LootShards then
			ImGui.Columns(2)
			if Bot.Settings.LootSettings.LootKeys then
				ImGui.Text("Keys: " .. statsKeys)
			end
			ImGui.NextColumn()
			if Bot.Settings.LootSettings.LootShards then
				ImGui.Text("Shards: " .. statsShards)
			end

			ImGui.Columns(1)
			ImGui.Separator()
		end

		ImGui.Columns(1)
		if ImGui.CollapsingHeader("Fish quality", "id_gui_loot_quality", true, false) then
			if Bot.Settings.LootSettings.LootWhite or Bot.Settings.LootSettings.LootGreen then
				ImGui.Columns(2)
				if Bot.Settings.LootSettings.LootWhite then
					ImGui.Text("Whites: " .. statsWhites)
				end
				ImGui.NextColumn()
				if Bot.Settings.LootSettings.LootGreen then
					ImGui.Text("Greens: " .. statsGreens)
				end

				ImGui.Columns(1)
				ImGui.Separator()
			end

			if Bot.Settings.LootSettings.LootBlue or Bot.Settings.LootSettings.LootGold then
				ImGui.Columns(2)
				if Bot.Settings.LootSettings.LootBlue then
					ImGui.Text("Blues: " .. statsBlues)
				end
				ImGui.NextColumn()
				if Bot.Settings.LootSettings.LootGold then
					ImGui.Text("Golds: " .. statsGolds)
				end

				ImGui.Columns(1)
				ImGui.Separator()
			end

			if Bot.Settings.LootSettings.LootOrange then
				ImGui.Columns(1)
				ImGui.Text("Oranges: " .. statsOranges)

				ImGui.Columns(1)
				ImGui.Separator()
			end
		end

		ImGui.Columns(1)
		ImGui.Spacing()

		if ImGui.Button("Reset Stats##id_guid_reset_stats", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.ResetStats()
		end

		ImGui.End()
	end
end

function Stats.OnDrawGuiCallback()
	Stats.DrawStats()
end
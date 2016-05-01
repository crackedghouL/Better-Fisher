---------------------------------------------
-- Variables
---------------------------------------------

Stats = { }
Stats.Visible = false

---------------------------------------------
-- Stats Functions
---------------------------------------------

function Stats.DrawStats()
	if Stats.Visible then
		_, Stats.Visible = ImGui.Begin("Loot Stats", Stats.Visible, ImVec2(350, 220), -1.0)

		-- if Bot.Running then
			-- t = Bot.FishingTime
			-- s = math.fmod(t, 60)
			-- m = math.fmod(t, 60 * 60) / 60
			-- h = math.floor(t / 60 / 60)
		-- end

		if Bot.Stats.Loots > 0 then
			statsWhites = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[0] or 0, (Bot.Stats.LootQuality[0] or 0) / Bot.Stats.Loots * 100)
			statsGreens = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[1] or 0, (Bot.Stats.LootQuality[1] or 0) / Bot.Stats.Loots * 100)
			statsBlues = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[2] or 0, (Bot.Stats.LootQuality[2] or 0) / Bot.Stats.Loots * 100)
			statsGolds = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[3] or 0, (Bot.Stats.LootQuality[3] or 0) / Bot.Stats.Loots * 100)
			statsOranges = string.format("%i - %.02f%%%%", Bot.Stats.LootQuality[4] or 0, (Bot.Stats.LootQuality[4] or 0) / Bot.Stats.Loots * 100)
			statsFishes = string.format("%i - %.02f%%%%", Bot.Stats.Fishes, Bot.Stats.Fishes / Bot.Stats.Loots * 100)
			statsTrashs = string.format("%i - %.02f%%%%", Bot.Stats.Trashs, Bot.Stats.Trashs / Bot.Stats.Loots * 100)
			statsKeys = string.format("%i - %.02f%%%%", Bot.Stats.Keys, Bot.Stats.Keys / Bot.Stats.Loots * 100)
			statsShards = string.format("%i - %.02f%%%%", Bot.Stats.Shards, Bot.Stats.Shards / Bot.Stats.Loots * 100)
		else
			statsWhites = "0 - 0.00%%"
			statsGreens = "0 - 0.00%%"
			statsBlues = "0 - 0.00%%"
			statsGolds = "0 - 0.00%%"
			statsOranges = "0 - 0.00%%"
			statsFishes = "0 - 0.00%%"
			statsTrashs = "0 - 0.00%%"
			statsKeys = "0 - 0.00%%"
			statsShards = "0 - 0.00%%"
		end

		ImGui.Columns(1) -- 2
		ImGui.Text("Loot Taken: " .. string.format("%i", Bot.Stats.Loots))
		-- ImGui.NextColumn()
		-- if Bot.Running then
		-- 	if s ~= 0 then
		-- 		if h > 0 then
		-- 			ImGui.Text("Fishing Time: " .. string.format("%.f:%02.f:%02.f", h, m, s))
		-- 		else
		-- 			ImGui.Text("Fishing Time: " .. string.format("%.f:%02.f", m, s))
		-- 		end
		-- 	end
		-- else
		-- 	ImGui.Text("Fishing Time: 0:00")
		-- end

		ImGui.Columns(1)
		ImGui.Separator()

		ImGui.Columns(2)
		ImGui.Text("Fishs: " .. statsFishes)
		ImGui.NextColumn()
		ImGui.Text("Trashs: " .. statsTrashs)

		ImGui.Columns(1)
		ImGui.Separator()

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

		ImGui.Columns(1)
		if ImGui.CollapsingHeader("Fish quality", "id_gui_loot_quality", true, false) then
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

			ImGui.Columns(1)
			if Bot.Settings.LootSettings.LootOrange == true then
				ImGui.Text("Oranges: " .. statsOranges)
			end

			ImGui.Columns(1)
			ImGui.Separator()
		end

		if ImGui.Button("Reset Stats##id_guid_reset_stats", ImVec2(ImGui.GetContentRegionAvailWidth(), 20)) then
			Bot.ResetStats()
		end

		ImGui.End()
	end
end

function Stats.OnDrawGuiCallback()
	Stats.DrawStats()
end
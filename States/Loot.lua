LootState = {}
LootState.__index = LootState
LootState.Name = "Loot"

setmetatable(LootState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function LootState.new()
	local self = setmetatable({}, LootState)
	self.Settings = {
		LootWhite = true,
		LootGreen = false,
		LootBlue = false,
		LootGold = false,
		LootOrange = false,
		LootShards = false,
		LootKeys = false,
		LootEggs = false
	}
	self.state = 0
	return self
end

function LootState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		local selfPlayer = GetSelfPlayer()

		if not selfPlayer.IsAlive then
			return false
		end

		if not Bot.Settings.InvFullStop and selfPlayer.Inventory.FreeSlots <= 3 then
			return false
		end

		return Looting.IsLooting and selfPlayer.CurrentActionName == "WAIT"
	else
		return false
	end
end

function LootState:Run()
	local numLoots = Looting.ItemCount
	local x = tostring(numLoots)
	local FishGameTime = 0
	Bot.Stats.Loots = Bot.Stats.Loots + 1
	self.state = 0

	if Bot.EnableDebug and Bot.EnableDebugLootState then
		print("Item to loot: " .. numLoots)
	end

	-- if numLoots ~= 0 then
		for i = 0, numLoots -1, x do
			local lootItem = Looting.GetItemByIndex(i)
			local lootItemName = lootItem.ItemEnchantStaticStatus.Name
			local lootItemType = nil
			local lootItemQuality = nil

			if string.find(lootItemName, "Moray") then -- Fix because some names contains weird characters
				lootItemName = "Moray"
			elseif string.find(lootItemName, "Salmon") then
				lootItemName = "Salmon"
			elseif string.find(lootItemName, "Bass") then
				lootItemName = "Bass"
			end

			if Bot.EnableDebug and Bot.EnableDebugLootState then
				print(i)
				print("Trying to loot: " .. numLoots .. "x " .. lootItemName)
			end

			if 	not self.Settings.LootWhite and not self.Settings.LootGreen and
				not self.Settings.LootBlue and not self.Settings.LootGold and
				not self.Settings.LootOrange and not self.Settings.LootShards and
				not self.Settings.LootKeys and not self.Settings.LootEggs
			then
				lootItemType = "Trash"
				Bot.Stats.Trashes = Bot.Stats.Trashes + 1
				self.state = 7
			end

			if lootItem then
				self.state = 1
			end

			if self.state == 1 then -- 1 = quality of the loot
				if lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_WHITE then
					lootItemQuality = "White"
					self.state = 2
				elseif lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GREEN then
					lootItemQuality = "Green"
					self.state = 2
				elseif lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_BLUE then
					lootItemQuality = "Blue"
					self.state = 2
				elseif lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GOLD then
					lootItemQuality = "Gold"
					self.state = 2
				elseif lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_ORANGE then
					lootItemQuality = "Orange"
					self.state = 2
				end
			end

			if self.state == 2 then -- 2 = understand what type of the loot is
				if lootItem.ItemEnchantStaticStatus.Classify == 16 and lootItem.ItemEnchantStaticStatus.IsTradeAble then
					lootItemType = "Fish"
					self.state = 3
				elseif 	lootItem.ItemEnchantStaticStatus.ItemId == 40218 or -- ancient relic crystal shard
						lootItem.ItemEnchantStaticStatus.ItemId == 4997 or  -- hard black crystal shard
						lootItem.ItemEnchantStaticStatus.ItemId == 4998     -- sharp black crystal shard
				then
					lootItemType = "Shard"
					self.state = 4
				elseif 	lootItem.ItemEnchantStaticStatus.ItemId == 44165 or -- silver key
						lootItem.ItemEnchantStaticStatus.ItemId == 44166 or -- bronze key
						lootItem.ItemEnchantStaticStatus.ItemId == 44164    -- gold key
				then
					lootItemType = "Key"
					self.state = 5
				elseif	lootItem.ItemEnchantStaticStatus.ItemId == 16195 or -- black spirit egg
						lootItem.ItemEnchantStaticStatus.ItemId == 16192 or -- egg with star pattern
						lootItem.ItemEnchantStaticStatus.ItemId == 16191 or -- life egg
						lootItem.ItemEnchantStaticStatus.ItemId == 16194 or -- rainbow egg
						lootItem.ItemEnchantStaticStatus.ItemId == 16193 	-- raindrop egg
				then
					lootItemType = "Egg"
					self.state = 6
				elseif	not self.Settings.LootWhite and not self.Settings.LootGreen and not self.Settings.LootBlue and not self.Settings.LootGold and
						not self.Settings.LootOrange and not self.Settings.LootShards and not self.Settings.LootKeys and not self.Settings.LootEggs
				then
					lootItemType = "Trash"
					self.state = 7
				else
					lootItemType = "Trash"
					self.state = 7
				end
			end

			if self.state == 3 then -- 3 = check for fishes
				if lootItemType == "Fish" then
					Bot.Stats.Fishes = Bot.Stats.Fishes + 1

					if lootItemQuality == "White" then
						Bot.Stats.LootQuality[0] = (Bot.Stats.LootQuality[0] or 0) + 1
						if self.Settings.LootWhite then
							self.state = 8
						elseif not self.Settings.LootWhite then
							self.state = 9
						end
					end

					if lootItemQuality == "Green" then
						Bot.Stats.LootQuality[1] = (Bot.Stats.LootQuality[1] or 0) + 1
						if self.Settings.LootGreen then
							self.state = 8
						elseif not self.Settings.LootGreen then
							self.state = 9
						end
					end

					if lootItemQuality == "Blue" then
						Bot.Stats.LootQuality[2] = (Bot.Stats.LootQuality[2] or 0) + 1
						if self.Settings.LootBlue then
							self.state = 8
						elseif not self.Settings.LootBlue then
							self.state = 9
						end
					end

					if lootItemQuality == "Gold" then
						Bot.Stats.LootQuality[3] = (Bot.Stats.LootQuality[3] or 0) + 1
						if self.Settings.LootGold then
							self.state = 8
						elseif not self.Settings.LootGold then
							self.state = 9
						end
					end

					if lootItemQuality == "Orange" then
						Bot.Stats.LootQuality[4] = (Bot.Stats.LootQuality[4] or 0) + 1
						if self.Settings.LootOrange then
							self.state = 8
						elseif not self.Settings.LootOrange then
							self.state = 9
						end
					end
				end
			end

			if self.state == 4 then -- 4 = check for shards
				if lootItemType == "Shard" then
					Bot.Stats.Shards = Bot.Stats.Shards + 1
					if self.Settings.LootShards then
						self.state = 8
					elseif self.Settings.LootShards then
						self.state = 9
					end
				end
			end

			if self.state == 5 then -- 5 = check for keys
				if lootItemType == "Key" then
					Bot.Stats.Keys = Bot.Stats.Keys + 1
					if self.Settings.LootKeys then
						self.state = 8
					elseif self.Settings.LootKeys then
						self.state = 9
					end
				end
			end

			if self.state == 6 then -- 6 = check for eggs
				if lootItemType == "Egg" then
					Bot.Stats.Eggs = Bot.Stats.Eggs + 1
					if self.Settings.LootEggs then
						self.state = 8
					elseif self.Settings.LootEggs then
						self.state = 9
					end
				end
			end

			if self.state == 7 then -- 7 = check for trashes
				if lootItemType == "Trash" then
					Bot.Stats.Trashes = Bot.Stats.Trashes + 1
					self.state = 9
				end
			end

			if Bot.Stats.LastLootTick ~= 0 then
				Bot.Stats.LootTimeCount = Bot.Stats.LootTimeCount + 1
				FishGameTime = Pyx.Win32.GetTickCount() - Bot.Stats.LastLootTick
				Bot.Stats.TotalLootTime = Bot.Stats.TotalLootTime + FishGameTime
				FishGameTime = math.ceil(FishGameTime / 1000)
				Bot.Stats.AverageLootTime = math.ceil((Bot.Stats.TotalLootTime / Bot.Stats.LootTimeCount) / 1000)
			end

			if self.state == 8 then -- 8 = loot the item
				print("Looted: " .. lootItemName .. " [" .. lootItemType .. "] (" .. lootItemQuality .. ")")
				Looting.Take(i)
			end

			if self.state == 9 then -- 9 = don't loot the item
				print("Not looted: " .. lootItemName .. " [" .. lootItemType .. "] (" .. lootItemQuality .. ")")
			end
		end
	--end
	Looting.Close()
end
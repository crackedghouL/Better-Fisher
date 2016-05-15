LootState = { }
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

	self.LootingState = 0
	self.LastHookFishTickCount = 0
	return self
end

function LootState:Reset()
	self.LootingState = 0
	self.LastHookFishTickCount = 0
end

function LootState:NeedToRun()
	local selfPlayer = GetSelfPlayer()

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	if Bot.Settings.InvFullStop == false and selfPlayer.Inventory.FreeSlots <= 3 then -- beacuse with 0 is impossible to sell at trade manager
		return false
	end

	return Looting.IsLooting and selfPlayer.CurrentActionName == "WAIT"
end

function LootState:Run()
	Bot.Stats.Loots = Bot.Stats.Loots + 1

	local numLoots = Looting.ItemCount
	local x = tostring(numLoots)
	self.LootingState = 0 -- 0 = nothing

	if Bot.EnableDebug then
		print("[" .. os.date(Bot.UsedTimezone) .. "] Item to loot: " .. numLoots)
	end

	-- if numLoots ~= 0 then
		for i = 0, numLoots -1, x do -- for i = 0, numLoots -1 do
			local lootItem = Looting.GetItemByIndex(i)
			local lootItemName = lootItem.ItemEnchantStaticStatus.Name
			if string.find(lootItemName,"Moray") then -- Fix because some names contains weird characters
				lootItemName = "Moray"
			end
			local lootItemType = "Trash"
			local lootItemQuality = nil

			if Bot.EnableDebug then
				print(i)
				print("[" .. os.date(Bot.UsedTimezone) .. "] Trying to loot: " .. numLoots .. "x " .. lootItemName)
			end

			if lootItem then
				self.LootingState = 1
			end

			if self.LootingState == 1 then -- 1 = quality of the loot
				if lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_WHITE then
					lootItemQuality = "White"
					self.LootingState = 2
				elseif lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GREEN then
					lootItemQuality = "Green"
					self.LootingState = 2
				elseif lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_BLUE then
					lootItemQuality = "Blue"
					self.LootingState = 2
				elseif lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GOLD then
					lootItemQuality = "Gold"
					self.LootingState = 2
				elseif lootItem.ItemEnchantStaticStatus.Grade == ITEM_GRADE_ORANGE then
					lootItemQuality = "Orange"
					self.LootingState = 2
				end
			end

			if self.LootingState == 2 then -- 2 = understand type and classify of the loot
				if lootItem.ItemEnchantStaticStatus.Classify == 16 and lootItem.ItemEnchantStaticStatus.IsTradeAble then
					lootItemType = "Fish"
					self.LootingState = 3
				elseif lootItem.ItemEnchantStaticStatus.Type == 2 and lootItem.ItemEnchantStaticStatus.Classify == 0 then
					self.LootingState = 3
				elseif lootItem.ItemEnchantStaticStatus.Type == 0 and lootItem.ItemEnchantStaticStatus.Classify == 0 then
					self.LootingState = 3
				end
			end

			if self.LootingState == 3 then -- 3 = check for settings
				if self.Settings.LootShards then
					if 	lootItem.ItemEnchantStaticStatus.ItemId == 40218 or -- ancient relic crystal shard
						lootItem.ItemEnchantStaticStatus.ItemId == 4997 or  -- hard black crystal shard
						lootItem.ItemEnchantStaticStatus.ItemId == 4998     -- sharp black crystal shard
					then
						lootItemType = "Shard"
						Bot.Stats.Shards = Bot.Stats.Shards + 1
						self.LootingState = 4
					end
				end

				if self.Settings.LootKeys then
					if 	lootItem.ItemEnchantStaticStatus.ItemId == 44165 or -- silver key
						lootItem.ItemEnchantStaticStatus.ItemId == 44166 or -- bronze key
						lootItem.ItemEnchantStaticStatus.ItemId == 44164    -- gold key
					then
						lootItemType = "Key"
						Bot.Stats.Keys = Bot.Stats.Keys + 1
						self.LootingState = 4
					end
				end

				if self.Settings.LootEggs then
					if 	lootItem.ItemEnchantStaticStatus.ItemId == 16195 or -- black spirit egg
						lootItem.ItemEnchantStaticStatus.ItemId == 16192 or -- egg with star pattern
						lootItem.ItemEnchantStaticStatus.ItemId == 16191 or -- life egg
						lootItem.ItemEnchantStaticStatus.ItemId == 16194 or -- rainbow egg
						lootItem.ItemEnchantStaticStatus.ItemId == 16193 	-- raindrop egg
					then
						lootItemType = "Egg"
						Bot.Stats.Trashes = Bot.Stats.Trashes + 1
						self.LootingState = 4
					end
				end

				if lootItemType == "Fish" then
					if self.Settings.LootWhite and lootItemQuality == "White" then
						Bot.Stats.LootQuality[0] = (Bot.Stats.LootQuality[0] or 0) + 1
						Bot.Stats.Fishes = Bot.Stats.Fishes + 1
						self.LootingState = 4
					elseif not self.Settings.LootWhite and lootItemQuality == "White" then
						self.LootingState = 5
					end

					if self.Settings.LootGreen and lootItemQuality == "Green" then
						Bot.Stats.LootQuality[1] = (Bot.Stats.LootQuality[1] or 0) + 1
						Bot.Stats.Fishes = Bot.Stats.Fishes + 1
						self.LootingState = 4
					elseif not self.Settings.LootGreen and lootItemQuality == "Green" then
						self.LootingState = 5
					end

					if self.Settings.LootBlue and lootItemQuality == "Blue" then
						Bot.Stats.LootQuality[2] = (Bot.Stats.LootQuality[2] or 0) + 1
						Bot.Stats.Fishes = Bot.Stats.Fishes + 1
						self.LootingState = 4
					elseif not self.Settings.LootBlue and lootItemQuality == "Blue" then
						self.LootingState = 5
					end

					if self.Settings.LootGold and lootItemQuality == "Gold" then
						Bot.Stats.LootQuality[3] = (Bot.Stats.LootQuality[3] or 0) + 1
						Bot.Stats.Fishes = Bot.Stats.Fishes + 1
						self.LootingState = 4
					elseif not self.Settings.LootGold and lootItemQuality == "Gold" then
						self.LootingState = 5
					end

					if self.Settings.LootOrange and lootItemQuality == "Orange" then
						Bot.Stats.LootQuality[4] = (Bot.Stats.LootQuality[4] or 0) + 1
						Bot.Stats.Fishes = Bot.Stats.Fishes + 1
						self.LootingState = 4
					elseif not self.Settings.LootOrange and lootItemQuality == "Orange" then
						self.LootingState = 5
					end
				end

				if lootItemType == "Trash" then
					Bot.Stats.Trashes = Bot.Stats.Trashes + 1
					self.LootingState = 5
				end

				if 	not self.Settings.LootWhite and not self.Settings.LootGreen and
					not self.Settings.LootBlue and not self.Settings.LootGold and
					not self.Settings.LootOrange and not self.Settings.LootShards and
					not self.Settings.LootKeys and not self.Settings.LootEggs
				then
					Bot.Stats.Trashes = Bot.Stats.Trashes + 1
					self.LootingState = 5
				end
			end

			local FishGameTime = "- "
			if Bot.Stats.LastLootTick ~= 0 then
				Bot.Stats.LootTimeCount = Bot.Stats.LootTimeCount + 1
				FishGameTime = Pyx.System.TickCount - Bot.Stats.LastLootTick
				Bot.Stats.TotalLootTime = Bot.Stats.TotalLootTime + FishGameTime
				FishGameTime = math.ceil(FishGameTime / 1000)
				Bot.Stats.AverageLootTime = math.ceil((Bot.Stats.TotalLootTime / Bot.Stats.LootTimeCount) / 1000)
			end

			if self.LootingState == 4 then -- 4 = loot the item
				print("[" .. os.date(Bot.UsedTimezone) .. "] Looted: " .. lootItemName .. " [" .. lootItemType .. "] (" .. lootItemQuality .. ")")
				Looting.Take(i)
			end

			if self.LootingState == 5 then -- 5 = don't loot the item
				print("[" .. os.date(Bot.UsedTimezone) .. "] Not looted: " .. lootItemName .. " [" .. lootItemType .. "] (" .. lootItemQuality .. ")")
			end
		end
	--end
	Looting.Close()
end

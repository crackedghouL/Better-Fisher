StartFishingState = { }
StartFishingState.__index = StartFishingState
StartFishingState.Name = "Start fishing"

setmetatable(StartFishingState, {
  __call = function (cls, ...)
	return cls.new(...)
  end,
})

function StartFishingState.new()
	local self = setmetatable({}, StartFishingState)
	self.Settings = { MaxEnergyCheat = false }
	self.LastStartFishTickcount = 0
	self.EquippedState = 0
	return self
end

function StartFishingState:Reset()
	self.LastStartFishTickcount = 0
	self.EquippedState = 0
end

function StartFishingState:NeedToRun()
	local selfPlayer = GetSelfPlayer()
	self.EquippedState = 0

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

	if not equippedItem then
		return false
	else
		self.EquippedState = 1
	end

	if self.EquippedState == 1 then -- 1 = normal rod
		if not equippedItem.ItemEnchantStaticStatus.IsFishingRod then
			self.EquippedState = 2
		end
	end

	if self.EquippedState == 2 then -- 2 = search for 'Fishing Rod' string
		if not string.find(equippedItem.ItemEnchantStaticStatus.Name, "Fishing Rod") then
			self.EquippedState = 3
		end
	end

	if self.EquippedState == 3 then -- 3 fallback to know rods using ids
		if	not equippedItem.ItemEnchantStaticStatus.ItemId == 16151 or  -- Steel Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16152 or  -- Gold Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16153 or  -- Triple Float Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16162 or  -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16163 or  -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16164 or  -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16165 or  -- Mediah Rod

									-- Rod +1
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81698 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81699 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81700 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81701 or -- Mediah Rod

									-- Rod +2
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147234 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147235 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147236 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147237 or -- Mediah Rod

									-- Rod +3
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212770 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212771 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212772 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212773 or -- Mediah Rod

									-- Rod +4
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278306 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278307 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278308 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278309 or -- Mediah Rod

									-- Rod +5
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343842 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343843 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343844 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343845 or -- Mediah Rod

									-- Rod +6
			not equippedItem.ItemEnchantStaticStatus.ItemId == 409378 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 409379 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 409380 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 409381 or -- Mediah Rod

									-- Rod +7
																		 -- Balenos Rod
																		 -- Epheria Rod
																		 -- Calpheon Rod
																		 -- Mediah Rod

									-- Rod +8
			not equippedItem.ItemEnchantStaticStatus.ItemId == 540450 or -- Balenos Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 540451 or -- Epheria Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 540452 or -- Calpheon Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 540453	 -- Mediah Rod
		then
			self.EquippedState = 4
		else
			self.EquippedState = 5
		end
	end

	if self.EquippedState == 4 then
		return false
	end

	if self.EquippedState == 5 then
		return true
	end

	if Pyx.System.TickCount - self.LastStartFishTickcount < 4000 then
		return false
	end

	if ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe > 100 then
		return false
	end

	if Bot.Settings.OnBoat == true and selfPlayer.Inventory.FreeSlots == 0 then
		Bot.Stop()
	end

	return selfPlayer.CurrentActionName == "WAIT" and not Looting.IsLooting
end

function StartFishingState:Run()
	Bot.Stats.LastLootTick = Pyx.System.TickCount
	local selfPlayer = GetSelfPlayer()

	if Bot.Settings.OnBoat and selfPlayer.Inventory.FreeSlots == 0 then
		if Bot.Running then
			Bot.Stop()
		end
	else
		print("[" .. os.date(Bot.UsedTimezone) .. "] Fishing...")
		selfPlayer:SetRotation(ProfileEditor.CurrentProfile:GetFishSpotRotation())
		selfPlayer:DoAction("FISHING_START")
		selfPlayer:DoAction("FISHING_ING_START")
		if self.MaxEnergyCheat then
			selfPlayer:DoAction("FISHING_START_END_Lv10")
		else
			selfPlayer:DoAction("FISHING_START_END_Lv0")
		end
		self.LastStartFishTickcount = Pyx.System.TickCount
	end
end
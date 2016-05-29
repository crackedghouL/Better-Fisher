StartFishingState = {}
StartFishingState.__index = StartFishingState
StartFishingState.Name = "Start fishing"

StartFishingState.SETTINGS_ON_NORMAL_FISHING = 0
StartFishingState.SETTINGS_ON_BOAT_FISHING = 1

StartFishingState.GoodPosition = false

setmetatable(StartFishingState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function StartFishingState.new()
	local self = setmetatable({}, StartFishingState)
	self.Settings = {
		UseMaxEnergy = false,
		FishingMethod = StartFishingState.SETTINGS_ON_NORMAL_FISHING
	}
	self.SleepTimer = nil
	self.LastStartFishTickcount = 0
	self.LastActionTime = 0
	self.PlayersNearby = 0
	self.GoodPosition = nil
	self.EquippedState = 0
	self.state = 0
	return self
end

function StartFishingState:Reset()
	self.SleepTimer = nil
	self.LastStartFishTickcount = 0
	self.LastActionTime = 0
	self.PlayersNearby = 0
	self.GoodPosition = nil
	self.EquippedState = 0
	self.state = 0
end

function StartFishingState:NeedToRun()
	local selfPlayer = GetSelfPlayer()
	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	if Bot.LastPauseTick ~= nil and Bot.Paused then
		return false
	end

	if Bot.Paused and Bot.PausedManual and Bot.LoopCounter > 0 then
		return false
	end

	if Pyx.Win32.GetTickCount() - self.LastStartFishTickcount < 4000 then
		return false
	end

	if ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe > 100 then
		return false
	end

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
		if not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Fishing Rod") then
			self.EquippedState = 3
		end
	end

	if self.EquippedState == 3 then -- 3 fallback to know rods using ids
		if	not equippedItem.ItemEnchantStaticStatus.ItemId == 16147 or  -- Thick Rod
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16151 or  -- Steel Rod
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
			return false
		else
			return true
		end
	end

	return selfPlayer.CurrentActionName == "WAIT" and not Looting.IsLooting
end

function StartFishingState:Run()
	local selfPlayer = GetSelfPlayer()

	Bot.Stats.LastLootTick = Pyx.Win32.GetTickCount()
	Bot.SilverStats(false)

	if selfPlayer.HealthPercent <= Bot.Settings.HealthPercent and Bot.Settings.AutoEscape and Bot.Counter == 0 then
		local players = GetCharacters()

		for k,v in pairs(players) do
			if v.IsPlayer and v.Name ~= selfPlayer.Name then -- not string.match(me.Key, v.Key)
				self.PlayersNearby = self.PlayersNearby + 1
			end
		end

		if self.PlayersNearby <= Bot.Settings.MinPeopleBeforeAutoEscape or Bot.Settings.MinPeopleBeforeAutoEscape == 0 then
			local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

			if equippedItem.ItemEnchantStaticStatus.IsFishingRod then
				selfPlayer:UnequipItem(INVENTORY_SLOT_RIGHT_HAND)
			end

			Navigator.Stop()
			BDOLua.Execute("callRescue()")
			Bot.Counter = 10000
		end
	end

	if Bot.Settings.InvFullStop and selfPlayer.Inventory.FreeSlots == 0 then
		if Bot.Running then
			Bot.Stop()
		end
	else
		if self.state == 0 and not Bot.Paused then
			selfPlayer:SetRotation(ProfileEditor.CurrentProfile:GetFishSpotRotation())
			if StartFishingState.GoodPosition then -- thanks to DogGoneFish and Parog
				-- selfPlayer:SetActionState(ACTION_FLAG_MOVE_FORWARD, 100)
				StartFishingState.GoodPosition = false
			end
			self.state = 2
			self.LastActionTime = Pyx.Win32.GetTickCount()
		elseif self.state == 2 and Pyx.Win32.GetTickCount() - self.LastActionTime > 1000 then
			if Bot.EnableDebug and Bot.EnableDebugStartFishingState then
				print("Fishing...")
			end

			selfPlayer:DoAction("FISHING_START")
			selfPlayer:DoAction("FISHING_ING_START")

			if self.Settings.UseMaxEnergy then
				selfPlayer:DoAction("FISHING_START_END_Lv10")
			else
				selfPlayer:DoAction("FISHING_START_END_Lv0")
			end

			self.state = 0
			self.LastStartFishTickcount = Pyx.Win32.GetTickCount()
		end
	end
end
StartFishingState = {}
StartFishingState.__index = StartFishingState
StartFishingState.Name = "Start fishing"

StartFishingState.SETTINGS_ON_NORMAL_FISHING = 0
StartFishingState.SETTINGS_ON_BOAT_FISHING = 1

StartFishingState.GoodPosition = false

setmetatable(StartFishingState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function StartFishingState.new()
	local self = setmetatable({}, StartFishingState)
	self.Settings = {
		RandomDelayMinSeconds = 1,
		RandomDelayMaxSeconds = 3,
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
	if Bot.CheckIfLoggedIn() then
		local selfPlayer = GetSelfPlayer()
		local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

		if not Bot.CheckIfLoggedIn() or not selfPlayer.IsAlive then
			return false
		end

		if Bot.LastPauseTick ~= nil and (Bot.Paused or Bot.PausedManual) then
			return false
		end

		if (Bot.Paused or Bot.PausedManual) and Bot.LoopCounter > 0 then
			return false
		end

		if Pyx.Win32.GetTickCount() - self.LastStartFishTickcount < Bot.WaitTimeForStates then
			return false
		end

		if ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe > Bot.Settings.FishingSpotRadius then
			return false
		end

		return selfPlayer.CurrentActionName == "WAIT" and not Looting.IsLooting
	else
		return false
	end
end

function StartFishingState:Run()
	local selfPlayer = GetSelfPlayer()
	local MinSeconds = self.Settings.RandomDelayMinSeconds * 1000
	local MaxSeconds = self.Settings.RandomDelayMaxSeconds * 1000

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
		if self.state == 0 and (not Bot.Paused or not Bot.PausedManual) then
			selfPlayer:SetRotation(ProfileEditor.CurrentProfile:GetFishSpotRotation())
			if StartFishingState.GoodPosition then
				StartFishingState.GoodPosition = false
			end
			self.state = 2
			self.LastActionTime = Pyx.Win32.GetTickCount()
		end

		if self.state == 2 and Pyx.Win32.GetTickCount() - self.LastActionTime > math.random(MinSeconds, MaxSeconds) then
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
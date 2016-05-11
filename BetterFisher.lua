Bot = { }
Bot.Settings = Settings()

Bot.Running = false
Bot.PrintConsoleState = false
Bot.EnableDebug = false
Bot.EnableDebugMainWindow = false
Bot.EnableDebugInventory = false
Bot.EnableDebugRadar = false

Bot.Counter = 0

Bot.Fsm = FSM()
Bot.DeathState = DeathState()
Bot.BuildNavigationState = BuildNavigationState()
Bot.MoveToFishingSpotState = MoveToFishingSpotState()
Bot.EquipFishingRodState = EquipFishingRodState()
Bot.EquipFloatState = EquipFloatState()
Bot.StartFishingState = StartFishingState()
Bot.HookFishHandleGameState = HookFishHandleGameState()
Bot.HookFishState = HookFishState()
Bot.LootState = LootState()
Bot.InventoryDeleteState = InventoryDeleteState()
Bot.ConsumablesState = ConsumablesState()
Bot.TradeManagerState = TradeManagerState()
Bot.RepairState = RepairState()
Bot.VendorState = VendorState()
Bot.WarehouseState = WarehouseState()
Bot.UnequipFishingRodState = UnequipFishingRodState()
Bot.UnequipFloatState = UnequipFloatState()

-- more info at http://www.lua.org/pil/22.1.html
if Bot.EnableDebug then
	Bot.UsedTimezone = "%c" -- "%H:%M:%S %z"
else
	Bot.UsedTimezone = "%X"
end

function Bot.ResetStats()
	Bot.Stats = {
		Loots = 0,
		AverageLootTime = 0,
		LootQuality = {},
		Fishes = 0,
		Shards = 0,
		Keys = 0,
		Trashes = 0,
		LootTimeCount = 0,
		LastLootTick = 0,
		TotalLootTime = 0,
		SessionStart = 0,
		TotalSession = 0,
	}
end

Bot.ResetStats()

function Bot.Start()
	if not Bot.Running then
		Bot.Stats.SessionStart = Pyx.System.TickCount
		-- Bot.ResetStats() --Only manual reset for long time stats with player interactions ?
		Bot.SaveSettings()

		Bot.RepairState.Forced = false
		Bot.WarehouseState.Forced = false
		Bot.VendorState.Forced = false
		Bot.TradeManagerForced = false

		local currentProfile = ProfileEditor.CurrentProfile

		Bot.WarehouseState.Settings.NpcName = currentProfile.WarehouseNpcName
		Bot.WarehouseState.Settings.NpcPosition = currentProfile.WarehouseNpcPosition
		Bot.WarehouseState.CallWhenCompleted = Bot.StateComplete
		Bot.WarehouseState.CallWhileMoving = Bot.StateMoving
		Bot.WarehouseState.ItemCheckFunction = Bot.CustomWarehouseCheck

		Bot.VendorState.Settings.NpcName = currentProfile.VendorNpcName
		Bot.VendorState.Settings.NpcPosition = currentProfile.VendorNpcPosition
		Bot.VendorState.CallWhenCompleted = Bot.StateComplete
		Bot.VendorState.CallWhileMoving = Bot.StateMoving

		Bot.TradeManagerState.Settings.NpcName = currentProfile.TradeManagerNpcName
		Bot.TradeManagerState.Settings.NpcPosition = currentProfile.TradeManagerNpcPosition
		Bot.TradeManagerState.CallWhenCompleted = Bot.StateComplete
		Bot.TradeManagerState.CallWhileMoving = Bot.StateMoving

		Bot.DeathState.CallWhenCompleted = Bot.Death

		Bot.InventoryDeleteState.ItemCheckFunction = Bot.DeleteItemCheck

		Bot.ConsumablesState.CustomCondition = Bot.ConsumablesCustomRunCheck
		-- Bot.ConsumablesState:ClearTimers() -- In case timer is set at more than 30min, the bot will use an other food while the buff is still active.
		Bot.ConsumablesState.Settings.PreConsumeWait = 2
		Bot.ConsumablesState.Settings.ConsumeWait = 8
		Bot.ConsumablesState.ValidActions = { "WAIT" }

		Bot.RepairState.ItemCheckFunction = Bot.RepairCheck
		Bot.RepairState.Settings.NpcName = currentProfile.RepairNpcName
		Bot.RepairState.Settings.NpcPosition = currentProfile.RepairNpcPosition

		Bot.StartFishingState.PlayerNearby = Bot.PlayerNearby

		if Bot.MeshDisabled ~= true then
			ProfileEditor.Visible = false
			Navigation.MesherEnabled = false
		end

		if not currentProfile then
			print("[" .. os.date(Bot.UsedTimezone) .. "] No profile loaded !")
			return
		end

		if not currentProfile:HasFishSpot() then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Profile require a fish spot!")
			return
		end

		-- Bot.Fsm = FSM()
		if Bot.Settings.PrintConsoleState then
			Bot.Fsm.ShowOutput = true
		end

		if Bot.Settings.OnBoat then
			Bot.Fsm:AddState(Bot.DeathState)
			Bot.Fsm:AddState(Bot.LootState)
			Bot.Fsm:AddState(Bot.InventoryDeleteState)
			Bot.Fsm:AddState(Bot.HookFishHandleGameState)
			Bot.Fsm:AddState(Bot.HookFishState)
			Bot.Fsm:AddState(Bot.UnequipFishingRodState)
			Bot.Fsm:AddState(Bot.UnequipFloatState)
			Bot.Fsm:AddState(Bot.EquipFishingRodState)
			Bot.Fsm:AddState(Bot.EquipFloatState)
			Bot.Fsm:AddState(Bot.ConsumablesState)
			Bot.Fsm:AddState(LibConsumables.ConsumablesState)
			Bot.Fsm:AddState(Bot.StartFishingState)
			Bot.Fsm:AddState(Bot.MoveToFishingSpotState)
		else
			Bot.Fsm:AddState(Bot.BuildNavigationState)
			Bot.Fsm:AddState(Bot.DeathState)
			Bot.Fsm:AddState(Bot.LootState)
			Bot.Fsm:AddState(Bot.InventoryDeleteState)
			Bot.Fsm:AddState(Bot.HookFishHandleGameState)
			Bot.Fsm:AddState(Bot.HookFishState)
			Bot.Fsm:AddState(Bot.UnequipFishingRodState)
			Bot.Fsm:AddState(Bot.UnequipFloatState)
			Bot.Fsm:AddState(Bot.TradeManagerState)
			Bot.Fsm:AddState(Bot.RepairState)
			Bot.Fsm:AddState(Bot.VendorState)
			Bot.Fsm:AddState(Bot.WarehouseState)
			Bot.Fsm:AddState(Bot.EquipFishingRodState)
			Bot.Fsm:AddState(Bot.EquipFloatState)
			Bot.Fsm:AddState(Bot.ConsumablesState)
			Bot.Fsm:AddState(LibConsumables.ConsumablesState)
			Bot.Fsm:AddState(Bot.StartFishingState)
			Bot.Fsm:AddState(Bot.MoveToFishingSpotState)
		end
		Bot.Fsm:AddState(IdleState())
		Bot.Running = true
	end
end

function Bot.Stop()
	Navigator.Stop()
	Bot.Running = false
	Bot.Fsm:Reset()
	Bot.WarehouseState:Reset()
	Bot.VendorState:Reset()
	Bot.TradeManagerState:Reset()
	Bot.DeathState:Reset()
	Bot.Stats.TotalSession = Bot.Stats.TotalSession + (Pyx.System.TickCount - Bot.Stats.SessionStart)
end

function Bot.OnPulse()
	if Pyx.Input.IsGameForeground() then -- pause to start or stop bot
		if Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('S')) then
			if Bot._startHotKeyPressed ~= true then
				Bot._startHotKeyPressed = true
				if Bot.Running then
					print("[" .. os.date(Bot.UsedTimezone) .. "] Stopping Bot from hotkey")
					Bot.Stop()
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Starting bot from hotkey")
					Bot.Start()
				end
			end
		else
			Bot._startHotKeyPressed = false
		end
	end

	if Bot.Counter > 0 then
		Bot.Counter = Bot.Counter-1
	end

	if Bot.Running then
		Bot.Fsm:Pulse()
	end
end

function Bot.SaveSettings()
	local json = JSON:new()
	Pyx.FileSystem.WriteFile("settings.json", json:encode_pretty(Bot.Settings))
end

function Bot.LoadSettings()
	local json = JSON:new()

	Bot.Settings = Settings()
	Bot.Settings.DeathSettings = Bot.DeathState.Settings
	Bot.Settings.LootSettings = Bot.LootState.Settings
	Bot.Settings.RepairSettings = Bot.RepairState.Settings
	Bot.Settings.WarehouseSettings = Bot.WarehouseState.Settings
	Bot.Settings.VendorSettings = Bot.VendorState.Settings
	Bot.Settings.TradeManagerSettings = Bot.TradeManagerState.Settings
	Bot.Settings.InventoryDeleteSettings = Bot.InventoryDeleteState.Settings
	Bot.Settings.ConsumablesSettings = Bot.ConsumablesState.Settings
	Bot.Settings.LibConsumablesSettings = LibConsumables.Settings
	Bot.Settings.HookFishHandleGameSettings = Bot.HookFishHandleGameState.Settings
	Bot.Settings.StartFishingSettigs = Bot.StartFishingState.Settings

	table.merge(Bot.Settings, json:decode(Pyx.FileSystem.ReadFile("settings.json")))
	if string.len(Bot.Settings.LastProfileName) > 0 then
		ProfileEditor.LoadProfile(Bot.Settings.LastProfileName)
	end

	if Bot.Settings.ConsumablesSettings.Consumables[1] == nil then
		Bot.Settings.ConsumablesSettings.Consumables[1] = { Name = "None", ConditionValue = 3, ConditionName = "Time" }
	end
end

function Bot.StateMoving(state)
	local selfPlayer = GetSelfPlayer()
	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

	if equippedItem ~= nil then
		if equippedItem.ItemEnchantStaticStatus.IsFishingRod then
			selfPlayer:UnequipItem(INVENTORY_SLOT_RIGHT_HAND)
		end
	end
end

function Bot.PlayerNearby()
	local me = GetSelfPlayer()
	local players = GetCharacters()
	local count = 0
	for k,v in pairs(players) do
		if v.IsPlayer and not string.match(me.Key, v.Key) then
			count = count + 1
		end
	end
	return (count > 0)
end

function Bot.Death(state)
	if Bot.DeathState.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED then
		Bot.Stop()
	else
		if Bot.Settings.OnBoat == false then
			Bot.TradeManagerState:Reset()
			Bot.WarehouseState:Reset()
			Bot.VendorState:Reset()
			Bot.RepairState:Reset()
		end
	end
end

function Bot.StateComplete(state)
	if state == Bot.TradeManagerState then
		if Bot.Settings.WarehouseSettings.DepositMethod == WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_TRADER then
			Bot.WarehouseState.Forced = true
		end
	elseif state == Bot.VendorState then
		if Bot.Settings.WarehouseSettings.DepositMethod == WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_VENDOR then
			Bot.WarehouseState.Forced = true
		end
	elseif state == Bot.RepairState then
		if Bot.Settings.WarehouseSettings.DepositMethod == WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_REPAIR then
			Bot.WarehouseState.Forced = true
		end
	elseif state == Bot.WarehouseState then
		if Bot.Settings.RepairSettings.Settings.RepairMethod == RepairState.SETTINGS_ON_REPAIR_AFTER_WAREHOUSE then
			Bot.RepairState.Forced = true
		end
	elseif state == Bot.WarehouseState then
		if Bot.Settings.RepairSettings.Settings.RepairMethod == RepairState.SETTINGS_ON_REPAIR_AFTER_TRADER then
			Bot.RepairState.Forced = true
		end
	end

	if Bot.EnableDebug then
		print("[" .. os.date(Bot.UsedTimezone) .. "] " .. tostring(state) .. " Complete!")
	end
end

function Bot.DeleteItemCheck(item)
	if table.find(Bot.InventoryDeleteState.Settings.DeleteItems, item.ItemEnchantStaticStatus.Name) then
		return true
	elseif Bot.Settings.DeleteUsedRods and item.HasEndurance and item.Endurance == 0 and
		   (item.ItemEnchantStaticStatus.ItemId == 16141 or item.ItemEnchantStaticStatus.ItemId == 16151)
	then
		return true
	end
end

function Bot.ConsumablesCustomRunCheck()
	local selfPlayer = GetSelfPlayer()
	if selfPlayer.CurrentActionName == "WAIT" then
		local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

		if equippedItem ~= nil and equippedItem.ItemEnchantStaticStatus.IsFishingRod then
			return true
		end
	end
	return false
end

function Bot.CustomWarehouseCheck(item)
	if not table.find(Bot.WarehouseState.Settings.IgnoreItemsNamed, item.ItemEnchantStaticStatus.Name) and item.Type ~= 8 then
		return true
	end
	return false
end

function Bot.RepairCheck()
	local selfPlayer = GetSelfPlayer()

	for k,v in pairs(selfPlayer.EquippedItems) do
		if Bot.EnableDebug then
			print ("[" .. os.date(Bot.UsedTimezone) .. "] Equipped: " .. tostring(v.HasEndurance) .. " " .. tostring(v.EndurancePercent) .. " " .. tostring(v.ItemEnchantStaticStatus.IsFishingRod))
		end
		if v.HasEndurance and v.EndurancePercent <= 0 and v.ItemEnchantStaticStatus.IsFishingRod == true then
			if Bot.EnableDebug then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Need to repair equipped items")
			end
			return true
		end
	end

	--for k,v in pairs(selfPlayer.Inventory.Items) do
		--if Bot.EnableDebug then
			--print ("[" .. os.date(Bot.UsedTimezone) .. "] Inv: " .. tostring(v.HasEndurance) .. " " .. tostring(v.EndurancePercent) .. " " .. tostring(v.ItemEnchantStaticStatus.IsFishingRod))
		--end
		--if v.HasEndurance and v.EndurancePercent <= 0 and v.ItemEnchantStaticStatus.IsFishingRod == true then
			--if Bot.EnableDebug then
				--print("[" .. os.date(Bot.UsedTimezone) .. "] Need to repair items on inventory")
			--end
			--return true
		--end
	--end

	return false
end
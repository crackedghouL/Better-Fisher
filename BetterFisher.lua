Bot = { }
Bot.Settings = Settings()

Bot.Version = "Better Fisher v0.9c BETA"

Bot.Running = false
Bot.PrintConsoleState = false
Bot.EnableDebug = false
Bot.EnableDebugMainWindow = false
Bot.EnableDebugProfileEditor = false
Bot.EnableDebugInventory = false
Bot.EnableDebugDeathState = false
Bot.EnableDebugEquipFishignRodState = false
Bot.EnableDebugEquipFloatState = false
Bot.EnableDebugHookFishState = false
Bot.EnableDebugHookHandleGameState = false
Bot.EnableDebugInventoryDeleteState = false
Bot.EnableDebugLootState = false
Bot.EnableDebugRepairState = false
Bot.EnableDebugStartFishingState = false
Bot.EnableDebugTradeManagerState = false
Bot.EnableDebugVendorState = false
Bot.EnableDebugWarehouseState = false

Bot.FishingLevel = 0

Bot.WasRunning = false

Bot.Time = nil
Bot.Hours = nil
Bot.Minutes = nil
Bot.Seconds = nil

Bot.Counter = 0

Bot.FSM = FSM()
Bot.IdleState = IdleState()
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
Bot.WarehouseState = WarehouseState()
Bot.VendorState = VendorState()
Bot.RepairState = RepairState()
Bot.UnequipFishingRodState = UnequipFishingRodState()
Bot.UnequipFloatState = UnequipFloatState()

if Bot.EnableDebug then -- more info at http://www.lua.org/pil/22.1.html
	Bot.UsedTimezone = "%c"
else
	Bot.UsedTimezone = "%X"
end

function Bot.FormatMoney(amount)
	while true do
		amount, k = string.gsub(amount, "^(-?%d+)(%d%d%d)", '%1.%2')
		if k == 0 then
			break
		end
	end

	return amount
end

function Bot.ResetStats()
	Bot.Stats = {
		SilverInitial = GetSelfPlayer().Inventory.Money,
		SilverGained = 0,
		Loots = 0,
		AverageLootTime = 0,
		LootQuality = {},
		Fishes = 0,
		Shards = 0,
		Keys = 0,
		Eggs = 0,
		Trashes = 0,
		LootTimeCount = 0,
		LastLootTick = 0,
		TotalLootTime = 0,
		SessionStart = Pyx.Win32.GetTickCount(),
		TotalSession = 0,
	}
end

function Bot.SilverStats(deposit)
	if not deposit then
		Bot.Stats.SilverGained = Bot.Stats.SilverGained + (GetSelfPlayer().Inventory.Money - Bot.Stats.SilverInitial)
	end	
	Bot.Stats.SilverInitial = GetSelfPlayer().Inventory.Money
end

Bot.ResetStats()

function Bot.Start()
	if not Bot.Running then
		local currentProfile = ProfileEditor.CurrentProfile

		Bot.Stats.SessionStart = Pyx.Win32.GetTickCount()
		Bot.SaveSettings()

		Bot.TradeManagerState.Forced = false
		Bot.TradeManagerState.ManualForced = false
		Bot.VendorState.Forced = false
		Bot.VendorState.ManualForced = false
		Bot.WarehouseState.Forced = false
		Bot.WarehouseState.ManualForced = false
		Bot.RepairState.Forced = false
		Bot.RepairState.ManualForced = false

		Navigator.MeshConnects = ProfileEditor.CurrentProfile.MeshConnects
		Navigator.ApproachDistance = 80

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

		Bot.DeathState.CallWhenCompleted = Bot.StateComplete

		Bot.InventoryDeleteState.ItemCheckFunction = Bot.DeleteItemCheck

		Bot.ConsumablesState.CustomCondition = Bot.ConsumablesCustomRunCheck
		-- Bot.ConsumablesState:ClearTimers() -- In case timer is set at more than 30min, the bot will use an other food while the buff is still active
		Bot.ConsumablesState.Settings.PreConsumeWait = 2
		Bot.ConsumablesState.Settings.ConsumeWait = 8
		Bot.ConsumablesState.ValidActions = { "WAIT" }

		Bot.RepairState.ItemCheckFunction = Bot.RepairCheck
		Bot.RepairState.Settings.NpcName = currentProfile.RepairNpcName
		Bot.RepairState.Settings.NpcPosition = currentProfile.RepairNpcPosition

		if Bot.MeshDisabled ~= true then
			ProfileEditor.Visible = false
			Navigation.MesherEnabled = false
			ProfileEditor.MeshConnectEnabled = false
		end

		if not currentProfile then
			print("[" .. os.date(Bot.UsedTimezone) .. "] No profile loaded!")
			return
		end

		if not currentProfile:HasFishSpot() then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Profile require a fish spot!")
			return
		end

		if Bot.Settings.PrintConsoleState then
			Bot.FSM.ShowOutput = true
		end

		if Bot.Settings.OnBoat then
			Bot.FSM:AddState(Bot.DeathState)
			Bot.FSM:AddState(Bot.LootState)
			Bot.FSM:AddState(Bot.InventoryDeleteState)
			Bot.FSM:AddState(Bot.HookFishHandleGameState)
			Bot.FSM:AddState(Bot.HookFishState)
			Bot.FSM:AddState(Bot.UnequipFishingRodState)
			Bot.FSM:AddState(Bot.UnequipFloatState)
			Bot.FSM:AddState(Bot.EquipFishingRodState)
			Bot.FSM:AddState(Bot.EquipFloatState)
			Bot.FSM:AddState(Bot.ConsumablesState)
			Bot.FSM:AddState(LibConsumables.ConsumablesState)
			Bot.FSM:AddState(Bot.StartFishingState)
			Bot.FSM:AddState(Bot.MoveToFishingSpotState)
		else
			Bot.FSM:AddState(Bot.BuildNavigationState)
			Bot.FSM:AddState(Bot.DeathState)
			Bot.FSM:AddState(Bot.LootState)
			Bot.FSM:AddState(Bot.InventoryDeleteState)
			Bot.FSM:AddState(Bot.HookFishHandleGameState)
			Bot.FSM:AddState(Bot.HookFishState)
			Bot.FSM:AddState(Bot.UnequipFishingRodState)
			Bot.FSM:AddState(Bot.UnequipFloatState)
			Bot.FSM:AddState(Bot.TradeManagerState)
			Bot.FSM:AddState(Bot.RepairState)
			Bot.FSM:AddState(Bot.VendorState)
			Bot.FSM:AddState(Bot.WarehouseState)
			Bot.FSM:AddState(Bot.EquipFishingRodState)
			Bot.FSM:AddState(Bot.EquipFloatState)
			Bot.FSM:AddState(Bot.ConsumablesState)
			Bot.FSM:AddState(LibConsumables.ConsumablesState)
			Bot.FSM:AddState(Bot.StartFishingState)
			Bot.FSM:AddState(Bot.MoveToFishingSpotState)
		end
		Bot.FSM:AddState(Bot.IdleState)
		Bot.Running = true
	end
end

function Bot.Stop()
	Navigation.MesherEnabled = false
	Bot.Running = false
	Bot.FSM:Reset()
	Bot.WarehouseState:Reset()
	Bot.VendorState:Reset()
	Bot.TradeManagerState:Reset()
	Bot.DeathState:Reset()
	Navigator.Stop()
	Bot.Stats.TotalSession = Bot.Stats.TotalSession + (Pyx.Win32.GetTickCount() - Bot.Stats.SessionStart)
end

function Bot.OnPulse()
	local selfPlayer = GetSelfPlayer()

	if Pyx.Input.IsGameForeground() then
		if Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('S')) then
			if Bot._startHotKeyPressed ~= true then
				Bot._startHotKeyPressed = true
				if Bot.Running then
					print("[" .. os.date(Bot.UsedTimezone) .. "] Stopping bot from hotkey")
					Bot.Stop()
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Starting bot from hotkey")
					Bot.Start()
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('P')) then
			if Bot._profileHotKeyPressed ~= true then
				Bot._profileHotKeyPressed = true
				if not ProfileEditor.Visible then
					ProfileEditor.Visible = true
				elseif ProfileEditor.Visible then
					ProfileEditor.Visible = false
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('O')) then
			if Bot._settingsHotKeyPressed ~= true then
				Bot._settingsHotKeyPressed = true
				if not BotSettings.Visible then
					BotSettings.Visible = true
				elseif BotSettings.Visible then
					BotSettings.Visible = false
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('B')) then
			if Bot._inventoryHotKeyPressed ~= true then
				Bot._inventoryHotKeyPressed = true
				if not InventoryList.Visible then
					InventoryList.Visible = true
				elseif InventoryList.Visible then
					InventoryList.Visible = false
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('C')) then
			if Bot._consumableHotKeyPressed ~= true then
				Bot._consumableHotKeyPressed = true
				if not LibConsumableWindow.Visible then
					LibConsumableWindow.Visible = true
				elseif LibConsumableWindow.Visible then
					LibConsumableWindow.Visible = false
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('L')) then
			if Bot._statsHotKeyPressed ~= true then
				Bot._statsHotKeyPressed = true
				if not Stats.Visible then
					Stats.Visible = true
				elseif Stats.Visible then
					Stats.Visible = false
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('W')) then
			if Bot._warehouseHotKeyPressed ~= true then
				Bot._warehouseHotKeyPressed = true
				if Bot.Running then
					Bot.WarehouseState.ManualForced = true
					if Bot.EnableDebug then
						print("[" .. os.date(Bot.UsedTimezone) .. "] Go to Warehouse")
					end
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Start the bot first!")
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('T')) then
			if Bot._traderHotKeyPressed ~= true then
				Bot._traderHotKeyPressed = true
				if Bot.Running then
					Bot.TradeManagerState.ManualForced = true
					if Bot.EnableDebug then
						print("[" .. os.date(Bot.UsedTimezone) .. "] Go to Trader")
					end
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Start the bot first!")
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('V')) then
			if Bot._vendorHotKeyPressed ~= true then
				Bot._vendorHotKeyPressed = true
				if Bot.Running then
					Bot.VendorState.ManualForced = true
					if Bot.EnableDebug then
						print("[" .. os.date(Bot.UsedTimezone) .. "] Go to Vendor")
					end
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Start the bot first!")
				end
			end
		elseif Pyx.Input.IsKeyDown(0x12) and Pyx.Input.IsKeyDown(string.byte('G')) then
			if Bot._repairHotKeyPressed ~= true then
				Bot._repairHotKeyPressed = true
				if Bot.Running then
					Bot.RepairState.ManualForced = true
					if Bot.EnableDebug then
						print("[" .. os.date(Bot.UsedTimezone) .. "] Go Repair")
					end
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Start the bot first!")
				end
			end
		else
			Bot._startHotKeyPressed = false
			Bot._profileHotKeyPressed = false
			Bot._settingsHotKeyPressed = false
			Bot._inventoryHotKeyPressed = false
			Bot._consumableHotKeyPressed = false
			Bot._statsHotKeyPressed = false
			Bot._warehouseHotKeyPressed = false
			Bot._traderHotKeyPressed = false
			Bot._vendorHotKeyPressed = false
			Bot._repairHotKeyPressed = false
		end
	end

	if Bot.Counter > 0 then
		Bot.Counter = Bot.Counter - 1
	end

	if selfPlayer then
		local rawLevel = tonumber(BDOLua.Execute([[return getSelfPlayer():get():getLifeExperienceLevel(1)]]))

		if rawLevel <= 10 then -- 1 to 10 = Beginner
			if rawLevel == 1 then
				Bot.FishingLevel = "Beginner 1"
			elseif rawLevel == 2 then
				Bot.FishingLevel = "Beginner 2"
			elseif rawLevel == 3 then
				Bot.FishingLevel = "Beginner 3"
			elseif rawLevel == 4 then
				Bot.FishingLevel = "Beginner 4"
			elseif rawLevel == 5 then
				Bot.FishingLevel = "Beginner 5"
			elseif rawLevel == 6 then
				Bot.FishingLevel = "Beginner 6"
			elseif rawLevel == 7 then
				Bot.FishingLevel = "Beginner 7"
			elseif rawLevel == 8 then
				Bot.FishingLevel = "Beginner 8"
			elseif rawLevel == 9 then
				Bot.FishingLevel = "Beginner 9"
			elseif rawLevel == 10 then
				Bot.FishingLevel = "Beginner 10"
			else
				Bot.FishingLevel = "Beginner ???"
			end
		elseif rawLevel >= 11 and rawLevel <= 20 then -- 11 to 20 = Apprentice
			if rawLevel == 11 then
				Bot.FishingLevel = "Apprentice 1"
			elseif rawLevel == 12 then
				Bot.FishingLevel = "Apprentice 2"
			elseif rawLevel == 13 then
				Bot.FishingLevel = "Apprentice 3"
			elseif rawLevel == 14 then
				Bot.FishingLevel = "Apprentice 4"
			elseif rawLevel == 15 then
				Bot.FishingLevel = "Apprentice 5"
			elseif rawLevel == 16 then
				Bot.FishingLevel = "Apprentice 6"
			elseif rawLevel == 17 then
				Bot.FishingLevel = "Apprentice 7"
			elseif rawLevel == 18 then
				Bot.FishingLevel = "Apprentice 8"
			elseif rawLevel == 19 then
				Bot.FishingLevel = "Apprentice 9"
			elseif rawLevel == 20 then
				Bot.FishingLevel = "Apprentice 10"
			else
				Bot.FishingLevel = "Apprentice ???"
			end
		elseif rawLevel >= 21 and rawLevel <= 30 then -- 21 to 30 = Skilled
			if rawLevel == 21 then
				Bot.FishingLevel = "Skilled 1"
			elseif rawLevel == 22 then
				Bot.FishingLevel = "Skilled 2"
			elseif rawLevel == 23 then
				Bot.FishingLevel = "Skilled 3"
			elseif rawLevel == 24 then
				Bot.FishingLevel = "Skilled 4"
			elseif rawLevel == 25 then
				Bot.FishingLevel = "Skilled 5"
			elseif rawLevel == 26 then
				Bot.FishingLevel = "Skilled 6"
			elseif rawLevel == 27 then
				Bot.FishingLevel = "Skilled 7"
			elseif rawLevel == 28 then
				Bot.FishingLevel = "Skilled 8"
			elseif rawLevel == 29 then
				Bot.FishingLevel = "Skilled 9"
			elseif rawLevel == 30 then
				Bot.FishingLevel = "Skilled 10"
			else
				Bot.FishingLevel = "Skilled ???"
			end
		elseif rawLevel >= 31 and rawLevel <= 40 then -- 31 to 40 = Professional
			if rawLevel == 31 then
				Bot.FishingLevel = "Professional 1"
			elseif rawLevel == 32 then
				Bot.FishingLevel = "Professional 2"
			elseif rawLevel == 33 then
				Bot.FishingLevel = "Professional 3"
			elseif rawLevel == 34 then
				Bot.FishingLevel = "Professional 4"
			elseif rawLevel == 35 then
				Bot.FishingLevel = "Professional 5"
			elseif rawLevel == 36 then
				Bot.FishingLevel = "Professional 6"
			elseif rawLevel == 37 then
				Bot.FishingLevel = "Professional 7"
			elseif rawLevel == 38 then
				Bot.FishingLevel = "Professional 8"
			elseif rawLevel == 39 then
				Bot.FishingLevel = "Professional 9"
			elseif rawLevel == 40 then
				Bot.FishingLevel = "Professional 10"
			else
				Bot.FishingLevel = "Professional ???"
			end
		elseif rawLevel >= 41 and rawLevel <= 50 then -- 41 to 50 = Artisan
			if rawLevel == 41 then
				Bot.FishingLevel = "Artisan 1"
			elseif rawLevel == 42 then
				Bot.FishingLevel = "Artisan 2"
			elseif rawLevel == 43 then
				Bot.FishingLevel = "Artisan 3"
			elseif rawLevel == 44 then
				Bot.FishingLevel = "Artisan 4"
			elseif rawLevel == 45 then
				Bot.FishingLevel = "Artisan 5"
			elseif rawLevel == 46 then
				Bot.FishingLevel = "Artisan 6"
			elseif rawLevel == 47 then
				Bot.FishingLevel = "Artisan 7"
			elseif rawLevel == 48 then
				Bot.FishingLevel = "Artisan 8"
			elseif rawLevel == 49 then
				Bot.FishingLevel = "Artisan 9"
			elseif rawLevel == 50 then
				Bot.FishingLevel = "Artisan 10"
			else
				Bot.FishingLevel = "Artisan ???"
			end
		elseif rawLevel >= 51 then -- 51 to 80 = Master
			if rawLevel == 51 then
				Bot.FishingLevel = "Master 1"
			elseif rawLevel == 52 then
				Bot.FishingLevel = "Master 2"
			elseif rawLevel == 53 then
				Bot.FishingLevel = "Master 3"
			elseif rawLevel == 54 then
				Bot.FishingLevel = "Master 4"
			elseif rawLevel == 55 then
				Bot.FishingLevel = "Master 5"
			elseif rawLevel == 56 then
				Bot.FishingLevel = "Master 6"
			elseif rawLevel == 57 then
				Bot.FishingLevel = "Master 7"
			elseif rawLevel == 58 then
				Bot.FishingLevel = "Master 8"
			elseif rawLevel == 59 then
				Bot.FishingLevel = "Master 9"
			elseif rawLevel == 60 then
				Bot.FishingLevel = "Master 10"
			elseif rawLevel == 61 then
				Bot.FishingLevel = "Master 11"
			elseif rawLevel == 62 then
				Bot.FishingLevel = "Master 12"
			elseif rawLevel == 63 then
				Bot.FishingLevel = "Master 13"
			elseif rawLevel == 64 then
				Bot.FishingLevel = "Master 14"
			elseif rawLevel == 65 then
				Bot.FishingLevel = "Master 15"
			elseif rawLevel == 66 then
				Bot.FishingLevel = "Master 16"
			elseif rawLevel == 67 then
				Bot.FishingLevel = "Master 17"
			elseif rawLevel == 68 then
				Bot.FishingLevel = "Master 18"
			elseif rawLevel == 69 then
				Bot.FishingLevel = "Master 19"
			elseif rawLevel == 70 then
				Bot.FishingLevel = "Master 20"
			elseif rawLevel == 71 then
				Bot.FishingLevel = "Master 21"
			elseif rawLevel == 72 then
				Bot.FishingLevel = "Master 22"
			elseif rawLevel == 73 then
				Bot.FishingLevel = "Master 23"
			elseif rawLevel == 74 then
				Bot.FishingLevel = "Master 24"
			elseif rawLevel == 75 then
				Bot.FishingLevel = "Master 25"
			elseif rawLevel == 76 then
				Bot.FishingLevel = "Master 26"
			elseif rawLevel == 77 then
				Bot.FishingLevel = "Master 27"
			elseif rawLevel == 78 then
				Bot.FishingLevel = "Master 28"
			elseif rawLevel == 79 then
				Bot.FishingLevel = "Master 29"
			elseif rawLevel == 80 then
				Bot.FishingLevel = "Master 30"
			else
				Bot.FishingLevel = "Master ???"
			end
		else
			Bot.FishingLevel = "???"
		end
	else
		Bot.FishingLevel = "N/A"
	end

	if Bot.Running or Bot.WasRunning then
		if Bot.Running then
			Bot.FSM:Pulse()

			Bot.Time = math.ceil((Bot.Stats.TotalSession + Pyx.Win32.GetTickCount() - Bot.Stats.SessionStart) / 1000)
			Bot.Seconds = Bot.Time % 60
			Bot.Minutes = math.floor(Bot.Time / 60) % 60
			Bot.Hours = math.floor(Bot.Time / (60 * 60))

			if ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe < 500 then
				if selfPlayer.IsSwimming then
					selfPlayer:DoAction("JUMP_F_A")
				end
			end
		end

		if Bot.Settings.StopWhenPeopleNearby and (Bot.FSM.CurrentState.Name == Bot.StartFishingState.Name or Bot.WasRunning) then
			local me = selfPlayer
			local players = GetCharacters()
			local count = 0
			local SafeDistance = Bot.Settings.StopWhenPeopleNearbyDistance

			for k,v in pairs(players, function(t,a,b) return t[a].Position.Distance3DFromMe < t[b].Position.Distance3DFromMe end) do
				if (v.IsPlayer and v.Name ~= me.Name) and math.floor(v.Position.Distance3DFromMe) <= SafeDistance then -- not string.match(me.Key, v.Key)
					count = count + 1
				end
			end

			if count > 0 then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Someone is near you, the bot is stopped for security.")
				if Bot.Running then
					Bot.Stop()
					Bot.WasRunning = true
				end
			else
				if not Bot.Running then
					Bot.Start()
					Bot.WasRunning = false
				end
			end

			return count
		end
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
	Bot.Settings.TradeManagerSettings = Bot.TradeManagerState.Settings
	Bot.Settings.WarehouseSettings = Bot.WarehouseState.Settings
	Bot.Settings.VendorSettings = Bot.VendorState.Settings
	Bot.Settings.RepairSettings = Bot.RepairState.Settings
	Bot.Settings.ConsumablesSettings = Bot.ConsumablesState.Settings
	Bot.Settings.LibConsumablesSettings = LibConsumables.Settings
	Bot.Settings.InventoryDeleteSettings = Bot.InventoryDeleteState.Settings
	Bot.Settings.StartFishingSettings = Bot.StartFishingState.Settings
	Bot.Settings.HookFishHandleGameSettings = Bot.HookFishHandleGameState.Settings
	Bot.Settings.LootSettings = Bot.LootState.Settings

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

function Bot.StateComplete(state)
	if state == Bot.TradeManagerState then
		if Bot.Settings.WarehouseSettings.Enabled and Bot.Settings.WarehouseSettings.DepositMethod == Bot.WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_TRADER then -- DepositMethod = 1
			Bot.WarehouseState.Forced = true
		end
	elseif state == Bot.VendorState then
		if Bot.Settings.WarehouseSettings.Enabled and Bot.Settings.WarehouseSettings.DepositMethod == Bot.WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_VENDOR then -- DepositMethod = 0
			Bot.WarehouseState.Forced = true
		end
	elseif state == Bot.RepairState then
		if Bot.Settings.WarehouseSettings.Enabled and Bot.Settings.WarehouseSettings.DepositMethod == Bot.WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_REPAIR then -- DepositMethod = 2
			Bot.WarehouseState.Forced = true
		end
	elseif state == Bot.WarehouseState then
		if Bot.Settings.RepairSettings.Enabled and Bot.Settings.RepairSettings.RepairMethod == Bot.RepairState.SETTINGS_ON_REPAIR_AFTER_WAREHOUSE then -- RepairMethod = 0
			Bot.RepairState.Forced = true
		end
	elseif state == Bot.WarehouseState then
		if Bot.Settings.RepairSettings.Enabled and Bot.Settings.RepairSettings.RepairMethod == Bot.RepairState.SETTINGS_ON_REPAIR_AFTER_TRADER then -- RepairMethod = 1
			Bot.RepairState.Forced = true
		end
	elseif state == Bot.DeathState then
		if 	Bot.Settings.DeathSettings.ReviveMethod == Bot.DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED or
			Bot.Settings.DeathSettings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_NODE or
			Bot.Settings.DeathSettings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE
		then
			Bot.DeathState.Forced = true
		else
			if not Bot.Settings.InvFullStop then
				Bot.TradeManagerState:Reset()
				Bot.WarehouseState:Reset()
				Bot.VendorState:Reset()
				Bot.RepairState:Reset()
			end
		end
	end

	if Bot.EnableDebug then
		print("[" .. os.date(Bot.UsedTimezone) .. "] " .. tostring(state) .. " Complete!")
	end
end

function Bot.DeleteItemCheck(item)
	if table.find(Bot.Settings.InventoryDeleteSettings.DeleteItems, item.ItemEnchantStaticStatus.Name) then
		return true
	elseif Bot.Settings.DeleteUsedRods and item.HasEndurance and item.Endurance == 0 and
		   (item.ItemEnchantStaticStatus.ItemId == 16141 or item.ItemEnchantStaticStatus.ItemId == 16147 or item.ItemEnchantStaticStatus.ItemId == 16151)
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
	if not table.find(Bot.Settings.WarehouseSettings.IgnoreItemsNamed, item.ItemEnchantStaticStatus.Name) and item.Type ~= 8 then
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

		if v.HasEndurance and v.EndurancePercent <= 0 and v.ItemEnchantStaticStatus.IsFishingRod then
			if Bot.EnableDebug then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Need to repair equipped items")
			end

			return true
		end
	end

	for k,v in pairs(selfPlayer.Inventory.Items) do
		if Bot.EnableDebug then
			print ("[" .. os.date(Bot.UsedTimezone) .. "] Inv: " .. tostring(v.HasEndurance) .. " " .. tostring(v.EndurancePercent) .. " " .. tostring(v.ItemEnchantStaticStatus.IsFishingRod))
		end
		if v.HasEndurance and v.EndurancePercent <= 0 and v.ItemEnchantStaticStatus.IsFishingRod then
			if Bot.EnableDebug then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Need to repair items on inventory")
			end
			return true
		end
	end

	return false
end
TradeManagerState = {}
TradeManagerState.__index = TradeManagerState
TradeManagerState.Name = "TradeManager"

setmetatable(TradeManagerState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function TradeManagerState.new()
	local self = setmetatable( { }, TradeManagerState)
	self.Settings = {
		Enabled = true,
		NpcName = "",
		NpcPosition = { X = 0, Y = 0, Z = 0 },
		NpcSize = 0,
		SellAll = true,
		DoBargainGame = true,
		IgnoreItemsNamed = { },
		SecondsBetweenTries = 300
	}
	self.LastTradeUseTimer = nil
	self.SleepTimer = nil
	self.CurrentSellList = {}
	self.ItemCheckFunction = nil
	self.CallWhenCompleted = nil
	self.CallWhileMoving = nil
	self.BargainState = 0
	self.BargainDice = 0 -- Last dice, 0=high 1=low
	self.ManualForced = false
	self.state = 0
	return self
end

function TradeManagerState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		local selfPlayer = GetSelfPlayer()

		if not selfPlayer.IsAlive then
			return false
		end

		if not self:HasNpc() or (not self:HasNpc() and Bot.Settings.InvFullStop) then
			return false
		end

		if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
			return false
		end

		if self.ManualForced and (Navigator.CanMoveTo(self:GetPosition()) or Bot.Settings.UseAutorun) then
			return true
		end

		if self.Settings.Enabled then
			if selfPlayer.Inventory.FreeSlots <= 3 and table.length(self:GetItems(false)) > 0 and not Looting.IsLooting then
				if Navigator.CanMoveTo(self:GetPosition()) or Bot.Settings.UseAutorun then
					return true
				end
			end
		end

		return false
	else
		return false
	end
end

function TradeManagerState:Reset()
	self.LastTradeUseTimer = nil
	self.SleepTimer = nil
	self.ManualForced = false
	self.state = 0
end

function TradeManagerState:Exit()
	if TradeMarket.IsTrading then
		TradeMarket.Close()
	end

	if Dialog.IsTalking then
		Dialog.ClickExit()
	end

	if self.state > 1 then
		self.LastTradeUseTimer = PyxTimer:New(self.Settings.SecondsBetweenTries)
		self.LastTradeUseTimer:Start()
		self.SleepTimer = nil
		self.ManualForced = false
		self.state = 0
	end
end

function TradeManagerState:Run()
	local npcs = GetNpcs()
	local selfPlayer = GetSelfPlayer()
	local vendorPosition = self:GetPosition()

	if Bot.CheckIfRodIsEquipped() then
		selfPlayer:UnequipItem(INVENTORY_SLOT_RIGHT_HAND)
	end

	if vendorPosition.Distance3DFromMe > (200 + self.Settings.NpcSize) then
		if self.CallWhileMoving then
			self.CallWhileMoving(self)
		end
		Navigator.MoveTo(vendorPosition, nil, Bot.Settings.PlayerRun)
		if self.state > 1 then
			self:Exit()
			return
		end
		self.state = 1
		return
	end

	Navigator.Stop()

	if self.SleepTimer ~= nil and self.SleepTimer:IsRunning() and not self.SleepTimer:Expired() then
		return
	end

	if table.length(npcs) < 1 then
		print("Could not find any Trade Manager NPC's")
		self:Exit()
		return
	end

	table.sort(npcs, function(a,b) return a.Position:GetDistance3D(vendorPosition) < b.Position:GetDistance3D(vendorPosition) end)
	local npc = npcs[1]

	if self.state == 1 then -- 1 = open npc dialog
		npc:InteractNpc()
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.state = 2
		return
	end

	if self.state == 2 then -- 2 = create sell list
		if not Dialog.IsTalking then
			print(self.Settings.NpcName .. " dialog didn't open")
			self:Exit()
			return
		end
		BDOLua.Execute("npcShop_requestList()")
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.CurrentSellList = self:GetItems()
		self.state = 3
		return
	end

	if self.state == 3 then -- 3 = play bargain minigame
		if self.Settings.DoBargainGame then
			if self.BargainState == 0 then
				local energy = tonumber(BDOLua.Execute("return getSelfPlayer():getWp()"))
				if energy >= 5 then
					BDOLua.Execute("click_TradeGameStart()")
					BDOLua.Execute("messageBox_YesButtonUp()")
					if math.random(2) == 2 then
						self.BargainDice = 0
					else
						self.BargainDice = 1
					end
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainState = 1
				else
					if Bot.EnableDebug and Bot.EnableDebugTradeManagerState then
						print("Not enought energy. Skipping bargain minigame")
					end
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainState = 0
					self.state = 4
				end
			elseif self.BargainState == 1 then
				if BDOLua.Execute("return isTradeGameSuccess()") == true then
					if Bot.EnableDebug and Bot.EnableDebugTradeManagerState then
						print("Bargain succes!")
					end
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					BDOLua.Execute("Fglobal_TradeGame_Close()")
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainState = 0
					self.state = 4
					self.CurrentSellList = self:GetItems()
				elseif tonumber(string.match (BDOLua.Execute("return UI.getChildControl(Panel_TradeGame, \"StaticText_RemainCount\"):GetText()"),"%d+")) <= 0 then
					if Bot.EnableDebug and Bot.EnableDebugTradeManagerState then
						print("Bargain fail")
					end
					BDOLua.Execute("Fglobal_TradeGame_Close()")
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainState = 0
				else
					if self.BargainDice == 0 then
						if Bot.EnableDebug and Bot.EnableDebugTradeManagerState then
							print("Low dice")
						end
						BDOLua.Execute("tradeGame_LowDice()")
						self.BargainDice = 1
					else
						if Bot.EnableDebug and Bot.EnableDebugTradeManagerState then
							print("High dice")
						end
						BDOLua.Execute("tradeGame_HighDice()")
						self.BargainDice = 0
					end
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
				end
			end
		else
			self.state = 4
		end
		return
	end

	if self.state == 4 then -- 4 = sell all
		if table.length(self.CurrentSellList) < 1 then
			if Bot.EnableDebug then
				print("Sell list created")
			end
			self:Exit()
			return
		end
		TradeMarket.SellAll() -- Currently only Sell All is supported
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.state = 5
		return
	end

	if self.state == 5 then -- 5 = close correctly the npc window
		if TradeMarket.IsTrading then
			TradeMarket.Close()
		end
		Bot.SilverStats(false)
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		if Bot.Settings.RepairSettings.Enabled and Bot.Settings.RepairSettings.RepairMethod == Bot.RepairState.SETTINGS_ON_REPAIR_AFTER_TRADER then
			Bot.RepairState.ManualForced = true
			print("Forcing repair after trader...")
		elseif Bot.Settings.WarehouseSettings.Enabled and Bot.Settings.WarehouseSettings.DepositMethod == Bot.WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_TRADER then
			Bot.WarehouseState.ManualForced = true
			print("Forcing deposit after trader...")
		end
		self.state = 6
		return
	end

	if self.state == 6 then -- 6 = state complete
		if self.CallWhenCompleted then
			self.CallWhenCompleted(self)
		end
	end

	self:Exit()
	return false
end

function TradeManagerState:GetItems()
	local items = { }
	local selfPlayer = GetSelfPlayer()

	if selfPlayer then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if v.ItemEnchantStaticStatus.IsTradeAble then
				if self.ItemCheckFunction then
					if self.ItemCheckFunction(v) then
						table.insert(items, {slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
					end
				else
					if not table.find(self.Settings.IgnoreItemsNamed, v.ItemEnchantStaticStatus.Name) then
						table.insert(items, {slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
					end
				end
			end
		end
	end

	return items
end

function TradeManagerState:HasNpc()
	return string.len(self.Settings.NpcName) > 0
end

function TradeManagerState:GetPosition()
	return Vector3(self.Settings.NpcPosition.X, self.Settings.NpcPosition.Y, self.Settings.NpcPosition.Z)
end
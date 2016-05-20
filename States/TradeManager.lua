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
		SellAll = true,
		TradeManagerOnInventoryFull = true,
		DoBargainGame = true,
		IgnoreItemsNamed = { },
		SecondsBetweenTries = 300
	}

	self.state = 0
	self.Forced = false
	self.ManualForced = false

	self.LastTradeUseTimer = nil
	self.SleepTimer = nil

	self.CurrentSellList = { }

	self.ItemCheckFunction = nil

	self.CallWhenCompleted = nil
	self.CallWhileMoving = nil

	self.BargainState = 0
	self.BargainCount = 0
	self.BargainDice = 0 -- Last dice, 0=high 1=low

	return self
end

function TradeManagerState:NeedToRun()
	local selfPlayer = GetSelfPlayer()

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	if not self:HasNpc() then
		self.Forced = false
		return false
	end

	if not Bot.Settings.EnableTrader then
		self.Forced = false
		return false
	end

	if not self:HasNpc() and Bot.Settings.InvFullStop then
		self.Forced = false
		return false
	end

	if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
		return false
	end

	if Looting.IsLooting and selfPlayer.CurrentActionName == "WAIT" then
		return false
	end

	if self.Settings.TradeManagerOnInventoryFull and selfPlayer.Inventory.FreeSlots <= 3 and table.length(self:GetItems()) > 0 and Navigator.CanMoveTo(self:GetPosition()) and not Looting.IsLooting then
		self.Forced = true
		return true
	end

	if self.Forced and not Navigator.CanMoveTo(self:GetPosition()) then
		self.Forced = false
		return false
	elseif self.Forced == true then
		return true
	end

	if self.ManualForced and not Navigator.CanMoveTo(self:GetPosition()) then
		self.ManualForced = false
		self.Forced = false
		return false
	elseif self.ManualForced == true then
		return true
	end

	return false
end

function TradeManagerState:Reset()
	self.LastTradeUseTimer = nil
	self.SleepTimer = nil
	self.Forced = false
	self.ManualForced = false
	self.state = 0
end

function TradeManagerState:Exit()
	if self.state > 1 then
		if TradeMarket.IsTrading then
			TradeMarket.Close()
		end

		if Dialog.IsTalking then
			Dialog.ClickExit()
		end

		self.state = 0
		self.LastTradeUseTimer = PyxTimer:New(self.Settings.SecondsBetweenTries)
		self.LastTradeUseTimer:Start()
		self.SleepTimer = nil
		self.Forced = false
		self.ManualForced = false
	end
end

function TradeManagerState:Run()
	local selfPlayer = GetSelfPlayer()
	local vendorPosition = self:GetPosition()
	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

	if equippedItem then
		selfPlayer:UnequipItem(INVENTORY_SLOT_RIGHT_HAND)
	end

	if vendorPosition.Distance3DFromMe > 300 then
		if self.CallWhileMoving then
			self.CallWhileMoving(self)
		end

		Navigator.MoveTo(vendorPosition,false,Bot.Settings.PlayerRun)
		if self.state > 1 then
			self:Exit()
			return
		end

		valueChanged = true
		self.state = 1
		return
	end

	Navigator.Stop()

	if self.SleepTimer ~= nil and self.SleepTimer:IsRunning() and not self.SleepTimer:Expired() then
		return
	end

	local npcs = GetNpcs()

	if table.length(npcs) < 1 then
		print("[" .. os.date(Bot.UsedTimezone) .. "] Could not find any Trade Manager NPC's")
		self:Exit()
		return
	end

	table.sort(npcs, function(a,b) return a.Position:GetDistance3D(vendorPosition) < b.Position:GetDistance3D(vendorPosition) end)
	local npc = npcs[1]
	if self.state == 1 then -- 1 = open npc dialog
		npc:InteractNpc()
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.state = 2
		return
	end

	if self.state == 2 then -- 2 = create sell list
		if not Dialog.IsTalking then
			print("[" .. os.date(Bot.UsedTimezone) .. "] "  .. self.Settings.NpcName .. " dialog didn't open")
			self:Exit()
			return
		end

		BDOLua.Execute("npcShop_requestList()")
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.state = 3
		self.CurrentSellList = self:GetItems()
		return
	end

	if self.state == 3 then -- 3 = play bargain minigame
		if self.Settings.DoBargainGame then
			if self.BargainState == 0 then
				local energy = tonumber(BDOLua.Execute("return getSelfPlayer():getWp()"))
				if energy >= 5 then
					BDOLua.Execute("click_TradeGameStart()")
					BDOLua.Execute("messageBox_YesButtonUp()")
					self.BargainCount = 0

					if math.random(2) == 2 then
						self.BargainDice = 0
					else
						self.BargainDice = 1
					end

					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainState = 1
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Not enought energy. Skipping bargain minigame")
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainState = 0
					self.state = 4
				end
			elseif self.BargainState == 1 then
				if BDOLua.Execute("return isTradeGameSuccess()") == true then
					print("[" .. os.date(Bot.UsedTimezone) .. "] Bargain succes!")
					self.SleepTimer = PyxTimer:New(1)
					self.SleepTimer:Start()

					BDOLua.Execute("Fglobal_TradeGame_Close()")
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainState = 0
					self.state = 4
					self.CurrentSellList = self:GetItems()
				elseif self.BargainCount >= 3 then
					print("[" .. os.date(Bot.UsedTimezone) .. "] Bargain fail")
					BDOLua.Execute("Fglobal_TradeGame_Close()")
					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainState = 0
				else
					if self.BargainDice == 0 then
						if Bot.EnableDebug then
							print("[" .. os.date(Bot.UsedTimezone) .. "] Low dice")
						end
						BDOLua.Execute("tradeGame_LowDice()")
						self.BargainDice = 1
					else
						if Bot.EnableDebug then
							print("[" .. os.date(Bot.UsedTimezone) .. "] High dice")
						end
						BDOLua.Execute("tradeGame_HighDice()")
						self.BargainDice = 0
					end

					self.SleepTimer = PyxTimer:New(2)
					self.SleepTimer:Start()
					self.BargainCount = self.BargainCount + 1
				end
			end
		else
			self.state = 4
		end
		return
	end

	if self.state == 4 then -- 4 = sell all
		if table.length(self.CurrentSellList) < 1 then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Sell list created")
			self:Exit()
			return
		end

		TradeMarket.SellAll() -- Currently only Sell All is supported
		self.SleepTimer = PyxTimer:New(5)
		self.SleepTimer:Start()
		self.state = 5
		return
	end

	if self.state == 5 then -- 5 = close correctly the npc window
		if TradeMarket.IsTrading then
			TradeMarket.Close()
		end

		Bot.SilverStats()
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
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
TradeManagerState = { }
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
		IgnoreItemsNamed = { },
		SecondsBetweenTries = 300
	}

	self.State = 0
	self.Forced = false
	self.ManualForced = false

	self.LastTradeUseTimer = nil
	self.SleepTimer = nil

	self.CurrentSellList = { }

	self.ItemCheckFunction = nil

	self.CallWhenCompleted = nil
	self.CallWhileMoving = nil

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

	if Bot.Settings.EnableTrader == false then
		self.Forced = false
		return false
	end

	if not self:HasNpc() and Bot.Settings.OnBoat == true then
		self.Forced = false
		return false
	end

	if self.Forced == true and not Navigator.CanMoveTo(self:GetPosition()) then
		self.Forced = false
		return false
	elseif self.Forced == true then
		return true
	end

	if self.ManualForced == true and not Navigator.CanMoveTo(self:GetPosition()) then
		self.ManualForced = false
		self.Forced = false
		return false
	elseif self.ManualForced == true then
		return true
	end

	if self.LastTradeUseTimer ~= nil and not self.LastTradeUseTimer:Expired() then
		return false
	end

	if 	self.Settings.TradeManagerOnInventoryFull and selfPlayer.Inventory.FreeSlots <= 3 and
		table.length(self:GetItems()) > 0 and Navigator.CanMoveTo(self:GetPosition()) and not Looting.IsLooting
	then
		self.Forced = true
		return true
	end

	return false
end

function TradeManagerState:Reset()
	self.State = 0
	self.Forced = false
	self.ManualForced = false
	self.LastTradeUseTimer = nil
	self.SleepTimer = nil
end

function TradeManagerState:Exit()
	if self.State > 1 then
		if TradeMarket.IsTrading then
			TradeMarket.Close()
		end

		if Dialog.IsTalking then
			Dialog.ClickExit()
		end

		self.State = 0
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
		if self.State > 1 then
			self:Exit()
			return
		end

		valueChanged = true
		self.State = 1
		return
	end

	Navigator.Stop()

	if self.SleepTimer ~= nil and self.SleepTimer:IsRunning() and self.SleepTimer:Expired() == false then
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
	if self.State == 1 then
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.State = 2
	end

	if self.State == 2 then
		npc:InteractNpc()
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.State = 3
		return
	end

	if self.State == 3 then
		if not Dialog.IsTalking then
			print("[" .. os.date(Bot.UsedTimezone) .. "] "  .. self.Settings.NpcName .. " dialog didn't open")
			self:Exit()
			return
		end

		BDOLua.Execute("npcShop_requestList()")
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.State = 4
		self.CurrentSellList = self:GetItems()
		return
	end

	if self.State == 4 then
		if table.length(self.CurrentSellList) < 1 then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Sell list created")
			self:Exit()
			return
		end

		TradeMarket.SellAll() -- Currently only Sell All is supported
		self.SleepTimer = PyxTimer:New(5)
		self.SleepTimer:Start()
		self.State = 5
		return
	end

	if self.State == 5 then
		if TradeMarket.IsTrading then
			TradeMarket.Close()
		end

		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.State = 6
		return
	end

	if self.State == 6 then
		if self.CallWhenCompleted then
			self.CallWhenCompleted(self)
		end

		Bot.SilverStats()
		self:Exit()
		return
	end

	self:Exit()
end

function TradeManagerState:GetItems()
	local items = { }
	local selfPlayer = GetSelfPlayer()
	if selfPlayer then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if v.ItemEnchantStaticStatus.IsTradeAble == true then
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

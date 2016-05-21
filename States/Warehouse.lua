WarehouseState = {}
WarehouseState.__index = WarehouseState
WarehouseState.Name = "Warehouse"

WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_VENDOR = 0
WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_TRADER = 1
WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_REPAIR = 2

setmetatable(WarehouseState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function WarehouseState.new()
	local self = setmetatable({}, WarehouseState)

	self.Settings = {
		Enabled = true,
		NpcName = "",
		NpcPosition = { X = 0, Y = 0, Z = 0 },
		DepositMethod = WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_VENDOR,
		DepositMoney = false,
		MoneyToKeep = 10000,
		IgnoreItemsNamed = {},
		SecondsBetweenTries = 300
	}

	self.state = 0
	self.Forced = false
	self.ManualForced = false

	self.LastUseTimer = nil
	self.SleepTimer = nil

	self.DepositList = nil
	self.CurrentDepositList = {}
	self.DepositedMoney = false
	self.DepositItems = false

	self.ItemCheckFunction = nil

	self.CallWhenCompleted = nil
	self.CallWhileMoving = nil

	return self
end

function WarehouseState:NeedToRun()
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

	if not self:HasNpc() and Bot.Settings.InvFullStop then
		self.Forced = false
		return false
	end

	if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
		self.Forced = false
		return false
	end

	if self.ManualForced and not Navigator.CanMoveTo(self:GetPosition()) then
		self.ManualForced = false
		return false
	elseif self.ManualForced then
		return true
	end

	if not Bot.Settings.EnableWarehouse then
		self.Forced = false
		return false
	end

	if self.Forced and not Navigator.CanMoveTo(self:GetPosition()) then
		self.Forced = false
		return false
	elseif self.Forced == true then
		return true
	end

	if self.Forced and selfPlayer.WeightPercent >= 95 then
		if Navigator.CanMoveTo(self:GetPosition())	then
			self.Forced = true
			return true
		else
			print("[" .. os.date(Bot.UsedTimezone) .. "] Need to Deposit money! Can not find path to NPC: " .. self.Settings.NpcName)
			return false
		end
	end

	if self.Forced and table.length(self:GetItems()) > 0 and (selfPlayer.Inventory.FreeSlots <= 3 or selfPlayer.WeightPercent >= 95) then
		if Navigator.CanMoveTo(self:GetPosition()) then
			self.Forced = true
			return true
		else
			print("[" .. os.date(Bot.UsedTimezone) .. "] Need to Deposit items! Can not find path to NPC: " .. self.Settings.NpcName)
			return false
		end
	end

	return false
end

function WarehouseState:Reset()
	self.LastUseTimer = nil
	self.SleepTimer = nil
	self.Forced = false
	self.ManualForced = false
	self.DepositedMoney = false
	self.DepositItems = false
	self.state = 0
end

function WarehouseState:Exit()
	if self.state > 1 then
		if Dialog.IsTalking then
			Dialog.ClickExit()
		end

		self.state = 0
		self.LastUseTimer = PyxTimer:New(self.Settings.SecondsBetweenTries)
		self.LastUseTimer:Start()
		self.SleepTimer = nil
		self.Forced = false
		self.ManualForced = false
		self.DepositedMoney = false
		self.DepositItems = false
	end
end

function WarehouseState:Run()
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

	local npcs = GetNpcs()
	if table.length(npcs) < 1 then
		print("[" .. os.date(Bot.UsedTimezone) .. "] Could not find any Warehouse NPC's")
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

	if self.state == 2 then -- 2 = create deposit list
		if not Dialog.IsTalking then
			print("[" .. os.date(Bot.UsedTimezone) .. "] " .. self.Settings.NpcName " dialog didn't open")
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
			return
		end

		BDOLua.Execute("Warehouse_OpenPanelFromDialog()")
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()

		if self.Settings.DepositItems or (not self.Settings.DepositItems and self.ManualForced) then
			if Bot.EnableDebug then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Deposit list done")
			end
			self.CurrentDepositList = self:GetItems()
		end

		self.state = 3
		return
	end

	if self.state == 3 then -- 3 = deposit money
		if not self.DepositedMoney and (self.Settings.DepositMoney or self.ManualForced) then
			local toDeposit = selfPlayer.Inventory.Money - self.Settings.MoneyToKeep
			if toDeposit > 0 then
				selfPlayer:WarehousePushMoney(npc, toDeposit)
				self.DepositedMoney = true
				self.SleepTimer = PyxTimer:New(3)
				self.SleepTimer:Start()
			end

			self.DepositedMoney = true
			self.state = 4
			return
		end
	end

	if self.state == 4 then -- 4 = deposit items
		if table.length(self.CurrentDepositList) < 1 then
			Bot.Stats.SilverGained = Bot.Stats.SilverGained + 1
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
			self.DepositItems = true
			self.state = 5
			return
		end

		local item = self.CurrentDepositList[1]
		local itemPtr = selfPlayer.Inventory:GetItemByName(item.name)
		if itemPtr ~= nil then
			if Bot.EnableDebug then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Deposited: " .. itemPtr.ItemEnchantStaticStatus.Name)
			end

			itemPtr:PushToWarehouse(npc)
			self.SleepTimer = PyxTimer:New(2)
			self.SleepTimer:Start()
		end

		table.remove(self.CurrentDepositList, 1)
		return
	end

	if self.state == 5 then -- 5 = state complete
		if self.CallWhenCompleted then
			self.CallWhenCompleted(self)
		end
	end

	self:Exit()
	return false
end

function WarehouseState:GetItems()
	local items = {}
	local selfPlayer = GetSelfPlayer()

	if selfPlayer then
		for k,v in pairs(selfPlayer.Inventory.Items) do
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
	return items
end

function WarehouseState:HasNpc()
	return string.len(self.Settings.NpcName) > 0
end

function WarehouseState:GetPosition()
	return Vector3(self.Settings.NpcPosition.X, self.Settings.NpcPosition.Y, self.Settings.NpcPosition.Z)
end
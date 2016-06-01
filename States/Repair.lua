RepairState = {}
RepairState.__index = RepairState
RepairState.Name = "Repair"

RepairState.SETTINGS_ON_REPAIR_AFTER_WAREHOUSE = 0
RepairState.SETTINGS_ON_REPAIR_AFTER_TRADER = 1

setmetatable(RepairState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function RepairState.new()
	local self = setmetatable({}, RepairState)
	self.Settings = {
		Enabled = true,
		NpcName = nil,
		NpcPosition = { X = 0, Y = 0, Z = 0 },
		RepairMethod = RepairState.SETTINGS_ON_REPAIR_AFTER_WAREHOUSE,
		SecondsBetweenTries = 300
	}

	self.LastUseTimer = nil
	self.SleepTimer = nil

	self.CallWhenCompleted = nil
	self.CallWhileMoving = nil

	self.RepairList = {}
	self.ItemCheckFunction = nil

    self.RepairEquipped = true
    self.RepairInventory = true

	self.Forced = false
	self.ManualForced = false
	self.state = 0

	return self
end

function RepairState:NeedToRun()
	local selfPlayer = GetSelfPlayer()

	if not selfPlayer then
		self.Forced = false
	end

	if not selfPlayer.IsAlive then
		self.Forced = false
	end

	if not self:HasNpc() or (not self:HasNpc() and Bot.Settings.InvFullStop) then
		self.Forced = false
	end

	if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
		self.Forced = false
	end

	if not self.Settings.Enabled then
		self.Forced = false
	end

	if not Navigator.CanMoveTo(self:GetPosition()) then
		self.Forced = false
	end

	if not selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND) then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if 	v.HasEndurance and v.EndurancePercent <= 0 and
				(v.ItemEnchantStaticStatus.IsFishingRod and
				(v.ItemEnchantStaticStatus.ItemId ~= 16141 and v.ItemEnchantStaticStatus.ItemId ~= 16147 and v.ItemEnchantStaticStatus.ItemId ~= 16151))
			then
				if self:HasNpc() and Navigator.CanMoveTo(self:GetPosition()) then
					self.Forced = true
				else
					self.Forced = false
				end
			end
		end
	else
		for k,v in pairs(selfPlayer.EquippedItems) do
			if 	v.HasEndurance and v.EndurancePercent <= 0 and
				(v.ItemEnchantStaticStatus.IsFishingRod and
				(v.ItemEnchantStaticStatus.ItemId ~= 16141 and v.ItemEnchantStaticStatus.ItemId ~= 16147 and v.ItemEnchantStaticStatus.ItemId ~= 16151))
			then
				if self:HasNpc() and Navigator.CanMoveTo(self:GetPosition()) then
					self.Forced = true
				else
					self.Forced = false
				end
			end
		end
	end

	if self.Forced or self.ManualForced then
		return true
	else
		return false
	end

	return false
end

function RepairState:HasNpc()
	return string.len(self.Settings.NpcName) > 0
end

function RepairState:GetPosition()
	return Vector3(self.Settings.NpcPosition.X, self.Settings.NpcPosition.Y, self.Settings.NpcPosition.Z)
end

function RepairState:Reset()
	self.LastUseTimer = nil
	self.SleepTimer = nil
	self.RepairList = {}
	self.Forced = false
	self.ManualForced = false
	self.state = 0
end

function RepairState:Exit()
	if Dialog.IsTalking then
		Dialog.ClickExit()
	end

	if self.state > 1 then
		self.LastUseTimer = PyxTimer:New(self.Settings.SecondsBetweenTries)
		self.LastUseTimer:Start()
		self.SleepTimer = nil
		self.RepairList = {}
		self.Forced = false
		self.ManualForced = false
		self.state = 0
	end
end

function RepairState:Run()
	local npcs = GetNpcs()
	local selfPlayer = GetSelfPlayer()
	local vendorPosition = self:GetPosition()

	if Bot.CheckIfRodIsEquipped() then
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

	if table.length(npcs) < 1 then
		print("Could not find any Repair NPC's")
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

	if self.state == 2 then -- 2 = open repair panel
		self.state = 3
		BDOLua.Execute("Repair_OpenPanel(true)")
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		return
	end

	if self.state == 3 then -- 3 = just a little dealy
		if not Dialog.IsTalking then
			print("Repair dialog didn't open")
			self:Exit()
			return
		end
		self.state = 4
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		return
	end

	if self.state == 4 then -- 4 = repair all equipped items
		self.state = 5
		if self.RepairEquipped then
			selfPlayer:RepairAllEquippedItems(npc)
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
		end
		return
	end

	if self.state == 5 then -- 6 = repair all items in the inventory
		self.state = 6
		if self.RepairInventory then
			selfPlayer:RepairAllInventoryItems(npc)
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
		end
		return
	end

	if self.state == 6 then -- 6 = close repair panel
		if Bot.EnableDebug and Bot.EnableDebugRepairState then
			print("Repair done")
		end
		BDOLua.Execute("Repair_OpenPanel(false)\r\nFixEquip_Close()")
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.state = 7
		return
	end

	if self.state == 7 then -- 7 = state complete
		if Bot.Settings.WarehouseSettings.Enabled == true and Bot.Settings.WarehouseSettings.DepositMethod == WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_REPAIR then
			Bot.WarehouseState.ManualForced = true
			print("Forcing deposit after repair...")
		end
		if self.CallWhenCompleted then
			self.CallWhenCompleted(self)
		end
	end

	self:Exit()
	return false
end

function RepairState:GetItems()
    local items = {}
    local selfPlayer = GetSelfPlayer()

    if selfPlayer then
        for k,v in pairs(selfPlayer.EquippedItems) do
            if self.ItemCheckFunction then
                if self.ItemCheckFunction(v) then
                    table.insert(items, {item = v, slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
                end
            else
                if v.HasEndurance and v.EndurancePercent < 100 then
                    table.insert(items, {item = v, slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
                end
            end
        end

        for k,v in pairs(selfPlayer.Inventory.Items) do
            if self.ItemCheckFunction then
                if self.ItemCheckFunction(v) then
                    table.insert(items, {item = v, slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
                end
            else
                if v.HasEndurance and v.EndurancePercent < 100 then
                    table.insert(items, {item = v, slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
                end
            end
        end
    end

    return items
end
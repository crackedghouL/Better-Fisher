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
		NpcName = "",
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
	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

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

	if not equippedItem then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if 	v.HasEndurance and v.EndurancePercent <= 0 and
				(v.ItemEnchantStaticStatus.IsFishingRod and
				(v.ItemEnchantStaticStatus.ItemId ~= 16141 and v.ItemEnchantStaticStatus.ItemId ~= 16147 and v.ItemEnchantStaticStatus.ItemId ~= 16151))
			then
				if Navigator.CanMoveTo(self:GetPosition()) then
					self.Forced = true
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Need to Repair! Can not find path to NPC: " .. self.Settings.NpcName)
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
				if Navigator.CanMoveTo(self:GetPosition()) then
					self.Forced = true
				else
					print("[" .. os.date(Bot.UsedTimezone) .. "] Need to Repair! Can not find path to NPC: " .. self.Settings.NpcName)
					self.Forced = false
				end
			end
		end
	end

	if self.Forced or self.ManualForced then
		return false
	elseif not self.Forced or not self.ManualForced then
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
	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

	if equippedItem then
		selfPlayer:UnequipItem(INVENTORY_SLOT_RIGHT_HAND)
	end

	if vendorPosition.Distance3DFromMe > 300 then
		if self.CallWhileMoving then
			self.CallWhileMoving(self)
		end

		Navigator.MoveTo(vendorPosition,nil,Bot.Settings.PlayerRun)
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
		print("[" .. os.date(Bot.UsedTimezone) .. "] Repair could not find any NPC's")
		self:Exit()
		return
	end

	table.sort(npcs, function(a,b) return a.Position:GetDistance3D(vendorPosition) < b.Position:GetDistance3D(vendorPosition) end)
	local npc = npcs[1]

	if self.state == 1 then
		npc:InteractNpc()
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.state = 2
		return true
	end

	if self.state == 2 then
		self.state = 3
		BDOLua.Execute("Repair_OpenPanel(true)")
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		return
	end

	if self.state == 3 then
		if not Dialog.IsTalking then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Repair dialog didn't open")
			self:Exit()
			return
		end

		self.state = 4
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		return
	end

	if self.state == 4 then
		self.state = 5
		if self.RepairEquipped then
			selfPlayer:RepairAllEquippedItems(npc)
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
		end
		return
	end

	if self.state == 5 then
		self.state = 6
		if self.RepairInventory then
			selfPlayer:RepairAllInventoryItems(npc)
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
		end
		return
	end

	if self.state == 6 then
		if Bot.EnableDebug and Bot.EnableDebugRepairState then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Repair done")
		end
		BDOLua.Execute("Repair_OpenPanel(false)\r\nFixEquip_Close()")
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
	end

	self:Exit()
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
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
		NpcSize = 0,
		RepairMethod = RepairState.SETTINGS_ON_REPAIR_AFTER_WAREHOUSE,
		UseWarehouseMoney = false,
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
	self.ManualForced = false
	self.state = 0
	return self
end

function RepairState:NeedToRun()
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
			if not selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND) then
				for k,v in pairs(selfPlayer.Inventory.Items) do
					if 	v.HasEndurance and v.EndurancePercent <= 0 and
						(v.ItemEnchantStaticStatus.IsFishingRod and
						(v.ItemEnchantStaticStatus.ItemId ~= 16141 and v.ItemEnchantStaticStatus.ItemId ~= 16147 and v.ItemEnchantStaticStatus.ItemId ~= 16151))
					then
						if Navigator.CanMoveTo(self:GetPosition()) or Bot.Settings.UseAutorun then
							return true
						end
					end
				end
			else
				for k,v in pairs(selfPlayer.EquippedItems) do
					if 	v.HasEndurance and v.EndurancePercent <= 0 and
						(v.ItemEnchantStaticStatus.IsFishingRod and
						(v.ItemEnchantStaticStatus.ItemId ~= 16141 and v.ItemEnchantStaticStatus.ItemId ~= 16147 and v.ItemEnchantStaticStatus.ItemId ~= 16151))
					then
						if Navigator.CanMoveTo(self:GetPosition()) or Bot.Settings.UseAutorun then
							return true
						end
					end
				end
			end
		end

		return false
	else
		return false
	end
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
	self.CallWhenCompleted = nil
	self.CallWhileMoving = nil
	self.RepairList = {}
	self.ItemCheckFunction = nil
	self.RepairEquipped = true
	self.RepairInventory = true
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
		self.ManualForced = false
		self.state = 0
	end
end

function RepairState:Run()
	local npcs = GetNpcs()
	local selfPlayer = GetSelfPlayer()
	local vendorPosition = self:GetPosition()
	local flushdialog = [[ MessageBox.keyProcessEscape() ]]
	local confirm = [[ MessageBox.keyProcessEnter() ]]
	local equippedwarehouse = [[
	UI.getChildControl( Panel_Equipment, "RadioButton_Icon_Money2"):SetCheck(true)
	UI.getChildControl(Panel_Equipment,"RadioButton_Icon_Money"):SetCheck(false)
	RepairAllEquippedItemBtn_LUp()
	]]
	local invenwarehouse = [[
	UI.getChildControl( Panel_Equipment, "RadioButton_Icon_Money2"):SetCheck(true)
	UI.getChildControl(Panel_Equipment,"RadioButton_Icon_Money"):SetCheck(false)
	RepairAllInvenItemBtn_LUp()
	]]

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
		print("Could not find any Repair NPC's")
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

	if self.state == 2 then -- 2 = open repair panel
		BDOLua.Execute(flushdialog)
		BDOLua.Execute("HandleClickedFuncButton(getDialogButtonIndexByType(CppEnums.ContentsType.Contents_Repair))")
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.state = 3
		return
	end

	if self.state == 3 then -- 3 = just a little dealy
		if not Dialog.IsTalking then
			print("Repair dialog didn't open")
			self:Exit()
			return
		end
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.state = 4
		return
	end

	if self.state == 4 then -- 4 = repair all equipped items
		if self.RepairEquipped then
			if self.Settings.UseWarehouseMoney and tonumber(BDOLua.Execute("return Int64toInt32(warehouse_moneyFromNpcShop_s64())")) > 100 then
				BDOLua.Execute(equippedwarehouse)
			else
				selfPlayer:RepairAllEquippedItems(npc)
			end
			self.SleepTimer = PyxTimer:New(2)
			self.SleepTimer:Start()
			self.state = 4.5
		end
		return
	end

	if self.state == 4.5 then
		BDOLua.Execute(confirm)
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.state = 4.9
		return
	end

	if self.state == 4.9 then
		BDOLua.Execute(flushdialog)
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.state = 5
		return
	end

	if self.state == 5 then -- 5 = repair all items in the inventory
		if self.RepairInventory then
			if self.Settings.UseWarehouseMoney and tonumber(BDOLua.Execute("return Int64toInt32(warehouse_moneyFromNpcShop_s64())")) > 100 then
				BDOLua.Execute(invenwarehouse)
				BDOLua.Execute(flushdialog)
			else
				selfPlayer:RepairAllInventoryItems(npc)
			end
			selfPlayer:RepairAllInventoryItems(npc)
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
			self.state = 5.5
			return
		end
	end

	if self.state == 5.5 then
		BDOLua.Execute(confirm)
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.state = 5.9
		return
	end

	if self.state == 5.9 then
		BDOLua.Execute(flushdialog)
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		self.state = 6
		return
	end

	if self.state == 6 then -- 6 = close repair panel
		if Bot.EnableDebug and Bot.EnableDebugRepairState then
			print("Repair done")
		end
		BDOLua.Execute("Repair_OpenPanel(false)\r\nFixEquip_Close()")
		self.SleepTimer = PyxTimer:New(2)
		self.SleepTimer:Start()
		if Bot.Settings.WarehouseSettings.Enabled and Bot.Settings.WarehouseSettings.DepositMethod == Bot.WarehouseState.SETTINGS_ON_DEPOSIT_AFTER_REPAIR then
			Bot.WarehouseState.ManualForced = true
			print("Forcing deposit after repair...")
		end
		self.state = 7
		return
	end

	if self.state == 7 then -- 7 = state complete
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

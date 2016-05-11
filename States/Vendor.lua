VendorState = { }
VendorState.__index = VendorState
VendorState.Name = "Vendor"

setmetatable(VendorState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function VendorState.new()
	local self = setmetatable( { }, VendorState)
	self.Settings = {
		Enabled = true,
		NpcName = "",
		NpcPosition = { X = 0, Y = 0, Z = 0 },
		VendorOnInventoryFull = false,
		VendorOnWeight = false,
		VendorWhite = false,
		VendorGreen = false,
		VendorBlue = false,
		VendorGold = false,
		SellEnabled = true,
		BuyEnabled = true,
		IgnoreItemsNamed = { },
		BuyItems = { },
		SecondsBetweenTries = 300
	}
	-- Buy Items Format {Name, BuyAt, BuyMax} BuyAt level we should buyat or below, BuyMax Max to have in Inventory so if is 100 and we have 20 bot will buy 80

	self.State = 0
	self.Forced = false
	self.ManualForced = false

	self.LastUseTimer = nil
	self.SleepTimer = nil

	self.DepositList = nil
	self.CurrentSellList = { }
	self.CurrentBuyList = { }

	self.ItemCheckFunction = nil

	self.CallWhenCompleted = nil
	self.CallWhileMoving = nil

	return self
end

function VendorState:NeedToRun()
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

	if not self:HasNpc() and Bot.Settings.InvFullStop == true then
		self.Forced = false
		return false
	end

	if self.Settings.SellEnabled == false and self.Settings.BuyEnabled == false then
		return false
	end

	if self.Forced and not Navigator.CanMoveTo(self:GetPosition()) then
		self.Forced = false
		return false
	elseif self.Forced == true then
		return true
	end

	if self.ManualForced and not Navigator.CanMoveTo(self:GetPosition()) then
		self.ManualForced = false
		return false
	elseif self.ManualForced == true then
		return true
	end

	if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
		return false
	end

	if self.Settings.SellEnabled == true then
		if self.Settings.VendorOnInventoryFull and selfPlayer.Inventory.FreeSlots <= 3 and table.length(self:GetSellItems()) > 0 and Navigator.CanMoveTo(self:GetPosition()) then
			self.Forced = true
			return true
		elseif self.Settings.VendorOnWeight and selfPlayer.WeightPercent >= 95 and table.length(self:GetSellItems()) > 0 and Navigator.CanMoveTo(self:GetPosition()) then
			self.Forced = true
			return true
		end
	end

	if  self.Settings.BuyItems == true and
		table.length(self:GetBuyItems(false)) > 0 and
		Navigator.CanMoveTo(self:GetPosition()) then
		self.Forced = true
		return true
	end

	return false
end

function VendorState:HasNpc()
	return string.len(self.Settings.NpcName) > 0
end

function VendorState:GetPosition()
	return Vector3(self.Settings.NpcPosition.X, self.Settings.NpcPosition.Y, self.Settings.NpcPosition.Z)
end

function VendorState:Reset()
	self.State = 0
	self.Forced = false
	self.ManualForced = false
	self.LastUseTimer = nil
	self.SleepTimer = nil
end

function VendorState:Exit()
	if self.State > 1 then
		if Dialog.IsTalking then
			Dialog.ClickExit()
		end

		self.State = 0
		self.Forced = false
		self.ManualForced = false
		self.LastUseTimer = PyxTimer:New(self.Settings.SecondsBetweenTries)
		self.LastUseTimer:Start()
		self.SleepTimer = nil
	end
end

function VendorState:Run()
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
		if self.State > 1 then
			self:Exit()
			return
		end

		self.State = 1
		return
	end

	Navigator.Stop()

	if self.SleepTimer ~= nil and self.SleepTimer:IsRunning() and not self.SleepTimer:Expired() then
		return
	end

	local npcs = GetNpcs()
	if table.length(npcs) < 1 then
		print("[" .. os.date(Bot.UsedTimezone) .. "] Could not find any Vendor NPC's")
		self:Exit()
		return
	end

	table.sort(npcs, function(a,b) return a.Position:GetDistance3D(vendorPosition) < b.Position:GetDistance3D(vendorPosition) end)
	local npc = npcs[1]

	if self.State == 1 then -- 1 = open npc dialog
		npc:InteractNpc()
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.State = 2
		return
	end

	if self.State == 2 then -- 2 = call for lists
		if not Dialog.IsTalking then
			print("[" .. os.date(Bot.UsedTimezone) .. "] " .. self.Settings.NpcName " dialog didn't open")
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
			return
		end

		BDOLua.Execute("npcShop_requestList()")

		if self.Settings.SellEnabled == true then self.CurrentSellList = self:GetSellItems() end
		if self.Settings.BuyEnabled == true then self.CurrentBuyList = self:GetBuyItems(self.Settings.BuyEnabled) end
		if Bot.EnableDebug then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Sell/Buy list done")
		end

		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self.State = 3
		return
	end

	if self.State == 3 then -- 3 = check for all items in list, create sell list and sell
		if table.length(self.CurrentSellList) < 1 then --and self.Settings.SellEnabled == true then
			if Bot.EnableDebug then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Sell from " .. self.Settings.NpcName .. " done")
			end

			self.SleepTimer = PyxTimer:New(1.5)
			self.SleepTimer:Start()
			self.State = 4
			return
		end

		local item = self.CurrentSellList[1]
		local itemPtr = selfPlayer.Inventory:GetItemByName(item.name)
		if itemPtr ~= nil then
			print(itemPtr.InventoryIndex .. " [" .. os.date(Bot.UsedTimezone) .. "] Item sold: " .. itemPtr.ItemEnchantStaticStatus.Name)
			itemPtr:RequestSellItem(npc)
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
		end

		table.remove(self.CurrentSellList, 1)
		return
	end

	if self.State == 4 then -- 4 = check for all items in buy list, create buy list and buy
		if (table.length(self.CurrentBuyList) < 1 and selfPlayer.Inventory.FreeSlots >= 1) then
			if Bot.EnableDebug then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Buy from " .. self.Settings.NpcName .. " done")
			end

			self.SleepTimer = PyxTimer:New(1.5)
			self.SleepTimer:Start()
			self.State = 5
			return
		elseif selfPlayer.Inventory.FreeSlots <= 0 then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Inventory is full")
			Bot.Stop()
			return
		end

		local item = self.CurrentBuyList[1]
		local itemPtr = self:GetBuyItemByName(item.name)
		if itemPtr ~= nil then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Buying " .. item.name .. " Quantity: " .. item.countNeeded)
			for cnt = 1, item.countNeeded do
				itemPtr:Buy(1)
			end
			self.SleepTimer = PyxTimer:New(3)
			self.SleepTimer:Start()
		else
			print("[" .. os.date(Bot.UsedTimezone) .. "] Need to buy " .. item.name .. " Quantity: " .. item.countNeeded .. " but  ".. self.Settings.NpcName .. " don't have it!")
		end

		table.remove(self.CurrentBuyList, 1)
		return
	end

	if self.State == 5 then -- 5 = run away
		if self.CallWhenCompleted then
			self.CallWhenCompleted(self)
		end

		Bot.SilverStats()
		self.SleepTimer = PyxTimer:New(3)
		self.SleepTimer:Start()
		self:Exit()
		return
	end

	self:Exit()
end

function VendorState:CanSellGrade(item)
	if self.Settings.VendorWhite and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_WHITE then
		return true
	end

	if self.Settings.VendorGreen and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GREEN then
		return true
	end

	if self.Settings.VendorBlue and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_BLUE then
		return true
	end

	if self.Settings.VendorGold and item.ItemEnchantStaticStatus.Grade == ITEM_GRADE_GOLD then
		return true
	end

	return false
end

function VendorState:GetSellItems()
	local items = { }
	local selfPlayer = GetSelfPlayer()
	if selfPlayer then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if not v.ItemEnchantStaticStatus.IsFishingRod then
				if self.ItemCheckFunction then
					if self.ItemCheckFunction(v) then
						table.insert(items, { slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count })
					end
				else
					if not table.find(self.Settings.IgnoreItemsNamed, v.ItemEnchantStaticStatus.Name) and self:CanSellGrade(v) == true then
						table.insert(items, { slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count })
					end
				end
			end
		end
	end
	return items
end

function VendorState:NeedToBuy(itemName, count)
	for k,v in pairs(self.Settings.BuyItems) do
		if v.Name == itemName then
			if (count - v.BuyAt) <= 0 then
				-- print(v.Name.." "..count.." "..v.BuyAt.." "..v.BuyMax - count)
				return v.BuyMax - count
			end
			return 0
		end
	end
	return 0
end

function VendorState:StockUpToBuy(itemName, count)
	for k,v in pairs(self.Settings.BuyItems) do
		if v.Name == itemName then
			return v.BuyMax - count
		end
	end
	return 0
end

function VendorState:GetBuyItems(stockUp)
	local items = { }
	local selfPlayer = GetSelfPlayer()
	if selfPlayer then
		local tmpInventory = { }
		local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND) -- Check equipped and add to total (for fishing Rods)

		if equippedItem ~= nil then
			tmpInventory[equippedItem.ItemEnchantStaticStatus.Name] = 1
		end

		for k,v in pairs(selfPlayer.Inventory.Items) do -- get totals from inventory
			if tmpInventory[v.ItemEnchantStaticStatus.Name] == nil then
				tmpInventory[v.ItemEnchantStaticStatus.Name] = v.Count
			else
				tmpInventory[v.ItemEnchantStaticStatus.Name] = tmpInventory[v.ItemEnchantStaticStatus.Name] + v.Count
			end
		end

		for k,v in pairs(tmpInventory) do -- check if we have enough on us
			local countNeeded = self:NeedToBuy(k, v)
			if countNeeded > 0 then
				table.insert(items, {name = k, currentCount = v, countNeeded = countNeeded})
			elseif stockUp == true and self:StockUpToBuy(k, v) > 0 then
				table.insert(items, {name = k, currentCount = v, countNeeded = self:StockUpToBuy(k, v)})
			end
		end

		for k,v in pairs(self.Settings.BuyItems) do -- check for items we don't have in inventory
			if tmpInventory[v.Name] == nil then
				table.insert(items, {name = v.Name, currentCount = 0, countNeeded = v.BuyMax})
			end
		end
	end
	return items
end

function VendorState:GetBuyItemByName(itemName)
	for i = 0, NpcShop.BuyItemCount - 1 do
		local item = NpcShop.GetBuyItemByIndex(i)

		if Bot.EnableDebug then
			print(item.ItemEnchantStaticStatus.Name)
			print(itemName)
		end

		if item.ItemEnchantStaticStatus.Name == itemName then
			return item
		end
	end
	return nil
end
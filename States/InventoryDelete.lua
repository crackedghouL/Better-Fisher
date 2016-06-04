InventoryDeleteState = {}
InventoryDeleteState.__index = InventoryDeleteState
InventoryDeleteState.Name = "Inventory Delete"

setmetatable(InventoryDeleteState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function InventoryDeleteState.new()
	local self = setmetatable({}, InventoryDeleteState)
	self.state = 0
	self.Settings = {
		DeleteItems = {},
		DeleteDepletedItems = {},
		SecondsBetweenTries = 60
	}
	self.SleepTimer = nil
	self.CallWhenCompleted = nil
	self.ItemCheckFunction = nil
	return self
end

function InventoryDeleteState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		if not GetSelfPlayer().IsAlive then
			return false
		end

		if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
			return false
		end

		if table.length(self:GetItems()) > 0 then
			return true
		end

		return false
	else
		return false
	end
end

function InventoryDeleteState:Reset()
	self.LastUseTimer = nil
	self.CallWhenCompleted = nil
	self.ItemCheckFunction = nil
end

function InventoryDeleteState:Run()
	local selfPlayer = GetSelfPlayer()

	self.LastUseTimer = PyxTimer:New(self.Settings.SecondsBetweenTries)
	self.LastUseTimer:Start()

	for k,v in pairs(self:GetItems()) do
		if Bot.EnableDebug and Bot.EnableDebugInventoryDeleteState then
			print("Deleting: "..v.item.ItemEnchantStaticStatus.Name)
		end
		selfPlayer.Inventory:DeleteItem(v.slot)
	end
end

function InventoryDeleteState:GetItems()
	local items = {}
	local selfPlayer = GetSelfPlayer()

	if selfPlayer then
		for k,v in pairs(selfPlayer.Inventory.Items) do
			if self.ItemCheckFunction then
				if self.ItemCheckFunction(v) then
					table.insert(items, {item = v, slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
				end
			else
				if table.find(self.Settings.DeleteItems, v.ItemEnchantStaticStatus.Name) then
					table.insert(items, {item = v, slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
				elseif v.HasEndurance and v.EndurancePercent < 1 and table.find(self.Settings.DeleteItems, v.ItemEnchantStaticStatus.Name) then
					table.insert(items, {item = v, slot = v.InventoryIndex, name = v.ItemEnchantStaticStatus.Name, count = v.Count})
				end
			end
		end
	end

	return items
end
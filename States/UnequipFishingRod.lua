UnequipFishingRodState = {}
UnequipFishingRodState.__index = UnequipFishingRodState
UnequipFishingRodState.Name = "Unequip fishing rod"

setmetatable(UnequipFishingRodState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function UnequipFishingRodState.new()
	local self = setmetatable({}, UnequipFishingRodState)
	self.LastUnequipTickcount = 0
	self.state = 0
	return self
end

function UnequipFishingRodState:Reset()
	self.LastUnequipTickcount = 0
	self.state = 0
end

function UnequipFishingRodState:Exit()
	if self.state > 1 then
		self.state = 0
	end
end

function UnequipFishingRodState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		local selfPlayer = GetSelfPlayer()
		local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

		if not selfPlayer.IsAlive then
			return false
		end

		if Pyx.Win32.GetTickCount() - self.LastUnequipTickcount < Bot.WaitTimeForStates then
			return false
		end

		if not equippedItem then
			return false
		else
			self.state = 1
		end

		if self.state == 1 then -- 1 = know rod
			if not equippedItem.ItemEnchantStaticStatus.IsFishingRod then
				self.state = 2
			end
		end

		if self.state == 2 then -- 2 = this is for unknow rod
			if	not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Fishing Rod") or   -- english client
				not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Canne à pêche") or -- french client
				not string.find(tostring(equippedItem.ItemEnchantStaticStatus.Name), "Angelrute")		  -- deutsch client
			then
				return false
			end
		end

		self:Exit()
		return equippedItem.Endurance == 0
	else
		return false
	end
end

function UnequipFishingRodState:Run()
	local selfPlayer = GetSelfPlayer()
	selfPlayer:UnequipItem(INVENTORY_SLOT_RIGHT_HAND)
	self.LastUnequipTickcount = Pyx.Win32.GetTickCount()
end
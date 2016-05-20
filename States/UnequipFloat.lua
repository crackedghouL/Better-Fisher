UnequipFloatState = {} 
UnequipFloatState.__index = UnequipFloatState
UnequipFloatState.Name = "Unequip float"

setmetatable(UnequipFloatState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function UnequipFloatState.new()
	local self = setmetatable({}, UnequipFloatState)
	self.LastUnequipTickcount = 0
	self.state = 0
	return self
end

function UnequipFloatState:Reset()
	self.LastUnequipTickcount = 0
	self.state = 0
end

function UnequipFloatState:NeedToRun()
	local selfPlayer = GetSelfPlayer()
	local equippedItem = selfPlayer:GetEquippedItem(INVENTORY_SLOT_LEFT_HAND)
	self.state = 0 -- 0 = nothing

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	if Pyx.System.TickCount - self.LastUnequipTickcount < 4000 then
		return false
	end

	if not equippedItem then
		return false
	else
		self.state = 1
	end

	if self.state == 1 then -- 2 = search for 'float' string
		if not string.find(equippedItem.ItemEnchantStaticStatus.Name, "Float") then
			self.state = 2
		end
	end

	if self.state == 2 then -- 3 fallback to know float using ids
		if 	not equippedItem.ItemEnchantStaticStatus.ItemId == 16167 or	 -- Ash Tree Float
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81703 or	 -- Ash Tree Float +1
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147239 or -- Ash Tree Float +2
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212775 or -- Ash Tree Float +3
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278311 or -- Ash Tree Float +4
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343847 or -- Ash Tree Float +5
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16168 or	 -- Maple Float
			not equippedItem.ItemEnchantStaticStatus.ItemId == 81704 or	 -- Maple Float +1
			not equippedItem.ItemEnchantStaticStatus.ItemId == 147240 or -- Maple Float +2
			not equippedItem.ItemEnchantStaticStatus.ItemId == 212776 or -- Maple Float +3
			not equippedItem.ItemEnchantStaticStatus.ItemId == 278312 or -- Maple Float +4
			not equippedItem.ItemEnchantStaticStatus.ItemId == 343848 or -- Maple Float +5
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16169 or	 -- Cedar Float
																		 -- Cedar Float +1
																		 -- Cedar Float +2
																		 -- Cedar Float +3
																		 -- Cedar Float +4
																		 -- Cedar Float +5
			not equippedItem.ItemEnchantStaticStatus.ItemId == 16170	 -- Palm Tree Float
																		 -- Palm Tree Float +1
																		 -- Palm Tree Float +2
																		 -- Palm Tree Float +3
																		 -- Palm Tree Float +4
																		 -- Palm Tree Float +5
		then
			return true
		else
			return false
		end
	end

	return equippedItem.Endurance == 0
end

function UnequipFloatState:Run()
	local selfPlayer = GetSelfPlayer()
	selfPlayer:UnequipItem(INVENTORY_SLOT_LEFT_HAND)
	self.LastUnequipTickcount = Pyx.System.TickCount
end
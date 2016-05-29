MoveToFishingSpotState = {}
MoveToFishingSpotState.__index = MoveToFishingSpotState
MoveToFishingSpotState.Name = "Move to fish spot"

setmetatable(MoveToFishingSpotState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function MoveToFishingSpotState.new()
	local self = setmetatable({}, MoveToFishingSpotState)
	self.LastStartFishTickcount = 0
	return self
end

function MoveToFishingSpotState:Reset()
	self.LastStartFishTickcount = 0
end

function MoveToFishingSpotState:NeedToRun()
	local selfPlayer = GetSelfPlayer()

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	if not Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetFishSpotPosition()) and not Bot.Settings.UseAutorun then
		return false
	end

	return ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe >= 100
end

function MoveToFishingSpotState:Run()
	local equippedItem = GetSelfPlayer():GetEquippedItem(INVENTORY_SLOT_RIGHT_HAND)

	if equippedItem and equippedItem.ItemEnchantStaticStatus.IsFishingRod then
		GetSelfPlayer():UnequipItem(INVENTORY_SLOT_RIGHT_HAND)
	end

	Navigator.MoveTo(ProfileEditor.CurrentProfile:GetFishSpotPosition(), nil, Bot.Settings.PlayerRun)
	StartFishingState.GoodPosition = true
end
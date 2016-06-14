MoveToFishingSpotState = {}
MoveToFishingSpotState.__index = MoveToFishingSpotState
MoveToFishingSpotState.Name = "Move to fish spot"

setmetatable(MoveToFishingSpotState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function MoveToFishingSpotState.new()
	local self = setmetatable({}, MoveToFishingSpotState)
	return self
end

function MoveToFishingSpotState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		if not Bot.CheckIfLoggedIn() or not Bot.CheckIfPlayerIsAlive() then
			return false
		end

		if not Navigator.CanMoveTo(ProfileEditor.CurrentProfile:GetFishSpotPosition()) then
			return false
		end

		return ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe >= Bot.Settings.FishingSpotRadius
	else
		return false
	end
end

function MoveToFishingSpotState:Run()
	if Bot.CheckIfRodIsEquipped() and ProfileEditor.CurrentProfile:GetFishSpotPosition().Distance3DFromMe <= 300 then
		GetSelfPlayer():UnequipItem(INVENTORY_SLOT_RIGHT_HAND)
	end

	Navigator.MoveTo(ProfileEditor.CurrentProfile:GetFishSpotPosition(), nil, Bot.Settings.PlayerRun)
	StartFishingState.GoodPosition = true
end
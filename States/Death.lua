DeathState = {}
DeathState.__index = DeathState
DeathState.Name = "Death"

DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED = 0
DeathState.SETTINGS_ON_DEATH_REVIVE_NODE = 1
DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE = 2

setmetatable(DeathState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function DeathState.new()
	local self = setmetatable({}, DeathState)
	self.Settings = { ReviveMethod = DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED }
	self.LastUseTimer = nil
	self.CallWhenCompleted = nil
	self.WasDead = false
	return self
end

function DeathState:NeedToRun()
	local selfPlayer = GetSelfPlayer()

	if self.LastUseTimer ~= nil and not self.LastUseTimer:Expired() then
		return false
	end

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return true
	end

	self.WasDead = false
	return false
end

function DeathState:Run()
	local selfPlayer = GetSelfPlayer()

	self.LastUseTimer = PyxTimer:New(3)
	self.LastUseTimer:Start()

	if not self.WasDead then
		self.WasDead = true
	end

	if self.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_NODE then
		print("[" .. os.date(Bot.UsedTimezone) .. "] Trying to revive at nearest node...");
		selfPlayer:ReviveAtNode()
	elseif self.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE then
		print("[" .. os.date(Bot.UsedTimezone) .. "] Trying to revive at nearest village...");
		selfPlayer:ReviveAtVillage()
	else
		if Bot.EnableDebug and Bot.EnableDebugDeathState then
			print("[" .. os.date(Bot.UsedTimezone) .. "] Death have state: " .. self.Settings.ReviveMethod)
		end
	end

	if self.CallWhenCompleted then
		self.CallWhenCompleted(self)
	end
end

function DeathState:Reset()
	self.LastUseTimer = nil
	self.WasDead = false
end
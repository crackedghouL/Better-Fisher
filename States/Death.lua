DeathState = {}
DeathState.__index = DeathState
DeathState.Name = "Death"

DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED = 0
DeathState.SETTINGS_ON_DEATH_REVIVE_NODE = 1
DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE = 2

setmetatable(DeathState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function DeathState.new()
	local self = setmetatable({}, DeathState)
	self.Settings = {
		EnableDeathDelay = false,
		DelaySeconds = 200,
		ReviveMethod = DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED
	}
	self.SleepTimer = nil
	self.CallWhenCompleted = nil
	self.state = 0
	return self
end

function DeathState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		if not GetSelfPlayer().IsAlive then
			return true
		end

		return false
	else
		return false
	end
end

function DeathState:Run()
	local selfPlayer = GetSelfPlayer()

	if self.Settings.EnableDeathDelay and self.SleepTimer == nil then
		self.state = 0
	else
		self.state = 1
	end

	if self.SleepTimer ~= nil and self.SleepTimer:IsRunning() and not self.SleepTimer:Expired() then
		return
	end

	if self.state == 0 then
		self.SleepTimer = PyxTimer:New(self.Settings.DelaySeconds)
		self.SleepTimer:Start()
		self.state = 1
		return
	end

	if self.state == 1 then
		if Bot.Settings.DeathSettings.ReviveMethod == Bot.DeathState.SETTINGS_ON_DEATH_ONLY_CALL_WHEN_COMPLETED then
			Bot.Stop()
		elseif self.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_NODE then
			print("Trying to revive at nearest node...");
			selfPlayer:ReviveAtNode()
		elseif self.Settings.ReviveMethod == DeathState.SETTINGS_ON_DEATH_REVIVE_VILLAGE then
			print("Trying to revive at nearest village...");
			selfPlayer:ReviveAtVillage()
		end

		self.state = 2
		return
	end

	if self.state == 2 then
		if self.CallWhenCompleted then
			self.CallWhenCompleted(self)
		end
	end

	self:Exit()
	return false
end

function DeathState:Exit()
	if self.state > 1 then
		self.SleepTimer = nil
		self.state = 0
	end
end

function DeathState:Reset()
	self.SleepTimer = nil
	self.state = 0
end
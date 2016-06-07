HookFishState = {}
HookFishState.__index = HookFishState
HookFishState.Name = "Hook fish"

HookFishState.fishBite = true

setmetatable(HookFishState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function HookFishState.new()
	local self = setmetatable({}, HookFishState)
	self.Settings = {
		UseRandomSeconds = false,
		HookMinSeconds = 30,
		HookMaxSeconds = 120
	}
	self.LastHookFishTickCount = 0
	self.LastWaitToHookTick = 0
	self.WaitToHook = 0
	self.LastHookStateTick = 0
	self.RandomWaitTime = 0
	self.state = 0
	return self
end

function HookFishState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		local selfPlayer = GetSelfPlayer()

		if not selfPlayer.IsAlive then
			return false
		end

		if Bot.LastPauseTick ~= nil and (Bot.Paused or Bot.PausedManual) then
			return false
		end

		if (Bot.Paused or Bot.PausedManual) and Bot.LoopCounter > 0 then
			return false
		end

		if Pyx.Win32.GetTickCount() - self.LastHookFishTickCount < Bot.WaitTimeForStates then
			return false
		end

		return selfPlayer.CurrentActionName == "FISHING_HOOK_ING"
	else
		return false
	end
end

function HookFishState:Run()
	local selfPlayer = GetSelfPlayer()

	if self.state == 0 and selfPlayer.CurrentActionName == "FISHING_HOOK_ING" then
		if self.Settings.UseRandomSeconds then
			realMinSeconds = self.Settings.HookMinSeconds * 1000
			realMaxSeconds = self.Settings.HookMaxSeconds * 1000
			self.LastWaitToHookTick = Pyx.Win32.GetTickCount()
			self.WaitToHook = math.random(realMinSeconds, realMaxSeconds)
			self.state = 1
		else
			self.state = 2
		end
	end

	if self.state == 1 and Pyx.Win32.GetTickCount() - self.LastWaitToHookTick > self.WaitToHook then
		if Bot.EnableDebug and Bot.EnableDebugHookFishState then
			print("Got something!")
		end
		self.state = 2
	end

	if self.state == 2 then
		self.LastHookStateTick = Pyx.Win32.GetTickCount()
		self.RandomWaitTime = math.random(500,1000)
		self.state = 3
	end

	if self.state == 3 and Pyx.Win32.GetTickCount() - self.LastHookStateTick > self.RandomWaitTime then
		selfPlayer:DoAction("FISHING_HOOK_DELAY")
		self.LastHookFishTickCount = Pyx.Win32.GetTickCount()
		self.state = 0
	end
end
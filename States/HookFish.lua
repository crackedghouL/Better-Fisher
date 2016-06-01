HookFishState = {}
HookFishState.__index = HookFishState
HookFishState.Name = "Hook fish"

HookFishState.fishBite = true

setmetatable(HookFishState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function HookFishState.new()
	local self = setmetatable({}, HookFishState)
	self.LastHookFishTickCount = 0
	self.LastHookStateTick = 0
	self.RandomWaitTime = 0
	self.state = 0
	return self
end

function HookFishState:Reset()
	self.LastHookFishTickCount = 0
	self.LastHookStateTick = 0
	self.RandomWaitTime = 0
	self.state = 0
end

function HookFishState:NeedToRun()
	local selfPlayer = GetSelfPlayer()

	if not selfPlayer or not selfPlayer.IsAlive then
		return false
	end

	if Bot.LastPauseTick ~= nil and (Bot.Paused or Bot.PausedManual) then
		return false
	end

	if (Bot.Paused or Bot.PausedManual) and Bot.LoopCounter > 0 then
		return false
	end

	if Pyx.Win32.GetTickCount() - self.LastHookFishTickCount < 4000 then
		return false
	end

	return selfPlayer.CurrentActionName == "FISHING_HOOK_ING"
end

function HookFishState:Run()
	local selfPlayer = GetSelfPlayer()
	if self.state == 0 and selfPlayer.CurrentActionName == "FISHING_HOOK_ING" then
		if Bot.EnableDebug and Bot.EnableDebugHookFishState then
			print("Got something!")
		end
		self.LastHookStateTick = Pyx.Win32.GetTickCount()
		self.RandomWaitTime = math.random(500,1000)
		self.state = 1
	elseif self.state == 1 and Pyx.Win32.GetTickCount() - self.LastHookStateTick > self.RandomWaitTime then
		selfPlayer:DoAction("FISHING_HOOK_DELAY")
		self.LastHookStateTick = 0
		self.state = 0
		self.LastHookFishTickCount = Pyx.Win32.GetTickCount()
	end
end
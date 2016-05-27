HookFishHandleGameState = {}
HookFishHandleGameState.__index = HookFishHandleGameState
HookFishHandleGameState.Name = "Hook game"

setmetatable(HookFishHandleGameState, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function HookFishHandleGameState.new()
	local self = setmetatable({}, HookFishHandleGameState)
	self.Settings = {
		NoDelay = false,
		AlwaysPerfect = false
	}
	self.LastGameTick = 0
	self.RandomWaitTime = 0
	self.state = 0
	return self
end

function HookFishHandleGameState:Reset()
	self.LastGameTick = 0
	self.RandomWaitTime = 0
	self.state = 0
end

function HookFishHandleGameState:NeedToRun()
	local selfPlayer = GetSelfPlayer()

	if not selfPlayer then
		return false
	end

	if not selfPlayer.IsAlive then
		return false
	end

	return selfPlayer.CurrentActionName == "FISHING_HOOK_START" or selfPlayer.CurrentActionName == "FISHING_HOOK_ING_HARDER"
end

function HookFishHandleGameState:Run()
	local selfPlayer = GetSelfPlayer()

	if self.state == 0 and selfPlayer.CurrentActionName == "FISHING_HOOK_START" then -- Wait before starting first minigame
		self.LastGameTick = Pyx.Win32.GetTickCount()
		self.RandomWaitTime = math.random(500,1200)
		self.state = 1
	elseif self.state == 1 and Pyx.Win32.GetTickCount() - self.LastGameTick > self.RandomWaitTime then -- Time spacebar minigame
		if self.Settings.NoDelay or self.Settings.AlwaysPerfect or math.random(10) == 10 then -- Make perfects from options or 10% chance
			if Bot.EnableDebug and Bot.EnableDebugHookHandleGameState then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Perfect timing!")
			end
			BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(3)")
			BDOLua.Execute("Panel_Minigame_SinGauge_End()")
			self.state = 0
		else -- Normal timing
			if Bot.EnableDebug and Bot.EnableDebugHookHandleGameState then
				print("[" .. os.date(Bot.UsedTimezone) .. "] Normal timing!")
			end
			BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(11)")
			self.RandomWaitTime = math.random(3500,4500) -- May need some tweaking ?
			self.state = 2
		end
		self.LastGameTick = Pyx.Win32.GetTickCount()
	elseif self.state == 2 and Pyx.Win32.GetTickCount() - self.LastGameTick > self.RandomWaitTime then -- Letters minigame
		BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(2)")
		self.LastGameTick = Pyx.Win32.GetTickCount()
		self.state = 0
	end
end
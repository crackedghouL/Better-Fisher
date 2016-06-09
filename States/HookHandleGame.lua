HookFishHandleGameState = {}
HookFishHandleGameState.__index = HookFishHandleGameState
HookFishHandleGameState.Name = "Hook game"

setmetatable(HookFishHandleGameState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function HookFishHandleGameState.new()
	local self = setmetatable({}, HookFishHandleGameState)
	self.Settings = {
		NoDelay = false,
		AlwaysPerfect = false,
		PerfectPerc = 10
	}
	self.LastGameTick = 0
	self.RandomWaitTime = 0
	self.state = 0
	return self
end

function HookFishHandleGameState:NeedToRun()
	if Bot.CheckIfLoggedIn() then
		local selfPlayer = GetSelfPlayer()

		if not selfPlayer.IsAlive then
			return false
		end

		return selfPlayer.CurrentActionName == "FISHING_HOOK_START" or selfPlayer.CurrentActionName == "FISHING_HOOK_ING_HARDER"
	else
		return false
	end
end

function HookFishHandleGameState:Run()
	local selfPlayer = GetSelfPlayer()

	if self.state == 0 and selfPlayer.CurrentActionName == "FISHING_HOOK_START" then -- Wait before starting first minigame
		self.LastGameTick = Pyx.Win32.GetTickCount()
		self.RandomWaitTime = math.random(500,1000)
		self.state = 1
		return
	end

	if self.state == 1 and Pyx.Win32.GetTickCount() - self.LastGameTick > self.RandomWaitTime then -- Time spacebar minigame
		if self.Settings.NoDelay or self.Settings.AlwaysPerfect or math.random(self.Settings.PerfectPerc) == self.Settings.PerfectPerc then -- Make perfects from options or % chance of your choise
			if (Bot.EnableDebug and Bot.EnableDebugHookHandleGameState) or self.Settings.PerfectPerc ~= 10 then
				print("Perfect timing!")
			end
			BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(3)")
			BDOLua.Execute("Panel_Minigame_SinGauge_End()")
			self.state = 0
		else -- Normal timing
			if Bot.EnableDebug and Bot.EnableDebugHookHandleGameState then
				print("Normal timing!")
			end
			BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(11)")
			self.RandomWaitTime = math.random(3500,4500) -- May need some tweaking ?
			self.state = 2
		end
		self.LastGameTick = Pyx.Win32.GetTickCount()
		return
	end

	if self.state == 2 and Pyx.Win32.GetTickCount() - self.LastGameTick > self.RandomWaitTime then -- Letters minigame
		BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(2)")
		self.LastGameTick = Pyx.Win32.GetTickCount()
		self.state = 0
	end
end
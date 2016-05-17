HookFishHandleGameState = { }
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
		AlwaysPerfect = false,
		UseOldAnimations = false
	}
	self.LastGameTick = 0
	self.RandomWaitTime = 0
	self.GameState = 0
	return self
end

function HookFishHandleGameState:Reset()
	self.LastGameTick = 0
	self.RandomWaitTime = 0
	self.GameState = 0
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

	if self.GameState == 0 and selfPlayer.CurrentActionName == "FISHING_HOOK_START" then -- Wait before starting first minigame
		self.LastGameTick = Pyx.System.TickCount
		self.RandomWaitTime = math.random(500,1200)
		self.GameState = 1
	elseif self.GameState == 1 and Pyx.System.TickCount - self.LastGameTick > self.RandomWaitTime then -- Time spacebar minigame
		if self.Settings.NoDelay == true or self.Settings.AlwaysPerfect == true or math.random(10) == 10 then -- Make perfects from options or 10% chance
			print("[" .. os.date(Bot.UsedTimezone) .. "] Perfect timing !")
			BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(3)")
			BDOLua.Execute("Panel_Minigame_SinGauge_End()")
			-- selfPlayer:DoAction("FISHING_HOOK_SUCCESS") Not needed, let the client handle it
			self.GameState = 0
		else -- Normal timing
			BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(11)")
			-- selfPlayer:DoAction("FISHING_HOOK_GOOD") Not needed, let the client handle it
			self.RandomWaitTime = math.random(3300,4500) -- May need some tweaking ?
			self.GameState = 2
		end
		self.LastGameTick = Pyx.System.TickCount
	elseif self.GameState == 2 and Pyx.System.TickCount - self.LastGameTick > self.RandomWaitTime then -- Letters minigame
		BDOLua.Execute("getSelfPlayer():get():SetMiniGameResult(2)")
		-- selfPlayer:DoAction("FISHING_HOOK_ING_SUCCESS") Not needed, let the client handle it
		self.LastGameTick = Pyx.System.TickCount
		self.GameState = 0
	end
end
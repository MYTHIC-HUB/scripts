local scheduled, yields, touched = {}, 0, 0
local clock = 0
local os = {clock = function() clock += 0.0001; return clock end}
local Optimizer = {touch = function() touched += 1 end}
-- WORKER

local function node(children)
	return {Parent = true, GetChildren = function() return children or {} end}
end
local children = {}
for i = 1, 1200 do children[i] = node() end
local alive = true
local task = {
	defer = function(callback) scheduled[#scheduled + 1] = coroutine.create(callback) end,
	wait = function() yields += 1; coroutine.yield() end,
}
local function makeState()
	return {settings = {noFx = true}, context = {
		workspace = node(children), isAlive = function() return alive end,
		environment = {task = task},
	}}
end
local function step()
	local thread = scheduled[1]
	assert(thread)
	local ok, problem = coroutine.resume(thread)
	assert(ok, problem)
	if coroutine.status(thread) == "dead" then table.remove(scheduled, 1) end
end
local function drain()
	local steps = 0
	while #scheduled > 0 do
		steps += 1
		assert(steps < 10000, "worker did not finish")
		step()
	end
end

local state = makeState()
for i = 1, 20 do Optimizer.sweep(state) end
assert(#scheduled == 1, "toggle burst scheduled duplicate workers")
drain()
assert(touched == 1201, "coalesced scan should visit each instance once")
assert(yields > 0, "large map did not yield")
assert(not state.workerRunning and state.pending == nil)

touched, yields = 0, 0
local streamed = node()
for i = 1, 5000 do Optimizer.enqueue(state, streamed) end
assert(#scheduled == 1, "streaming burst scheduled duplicate workers")
drain()
assert(touched == 1, "duplicate streamed instance was processed repeatedly")

touched = 0
Optimizer.sweep(state)
step()
local beforeStop = touched
assert(beforeStop > 0 and beforeStop < 1201, "time budget did not split work")
state.stopped = true
drain()
assert(touched == beforeStop, "worker changed instances after teardown")
Optimizer.enqueue(state, node())
assert(#scheduled == 0, "stopped optimizer accepted new work")

state, touched = makeState(), 0
state.settings.noFx = false
Optimizer.sweep(state)
Optimizer.enqueue(state, node())
assert(#scheduled == 0, "inactive optimizer scheduled work")

state, touched = makeState(), 0
Optimizer.sweep(state)
step()
local beforeDeath = touched
alive = false
drain()
assert(touched == beforeDeath, "destroyed application continued processing")
alive = true

state, touched = makeState(), 0
Optimizer.sweep(state)
step()
state.settings.noTex = true
for i = 1, 20 do Optimizer.sweep(state) end
assert(#scheduled == 1, "rescan started a concurrent worker")
drain()
assert(touched >= 1201 and touched < 2402, "rescan did not coalesce")
print("PASS: coalesced toggles; bounded slices; streamed-instance deduplication; teardown; inactive state; destroyed application; mid-scan reconfiguration")

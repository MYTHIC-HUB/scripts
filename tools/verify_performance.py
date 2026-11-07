"""Compile Luau and test the loader/optimizer with mocks; never run gameplay code."""
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
HUB = ROOT / "MYTHIC-HUB"
compiler = shutil.which("luau-compile")
runtime = shutil.which("luau")
if not compiler or not runtime:
    raise SystemExit("Install luau and luau-compile, then add both to PATH.")

parts = [(HUB / f"chunks/part-{i:03d}.txt").read_bytes() for i in range(1, 36)]
source = b"".join(parts).decode()
main = (HUB / "main.lua").read_text()
expected = int(re.search(r"EXPECTED_BYTES = 35, (\d+)", main).group(1))
assert sum(map(len, parts)) == expected, "Loader byte count does not match chunks"
part = parts[32].decode()
a = part.index("function Optimizer.active(state)")
b = part.index("\nfunction Optimizer.glare(state)", a)
worker = part[a:b]
worker_test = (ROOT / "tools/tests/optimizer-worker.luau").read_text().replace("-- WORKER", worker)

# The mock HTTP implementation reads embedded fixtures only. Native loadstring
# checks the fully patched source but its returned chunk is never executed.
delimiter = "======="
assert "]" + delimiter + "]" not in source
harness = """
local nativeCompile = loadstring
local host = {}
local _G = host
local getgenv = function() return host end
local warnings = {}
local warn = function(message) warnings[#warnings + 1] = tostring(message) end
local fixture = [""" + delimiter + "[" + source + "]" + delimiter + """]
local lengths = {""" + ",".join(str(len(p)) for p in parts) + """}
local offsets, at = {}, 1
for i, length in ipairs(lengths) do offsets[i] = at; at += length end
local task = {spawn = function(callback) callback() end, wait = function() end}
local requests, compiles = 0, 0
local broken = false
local game = {
    GetService = function() error("mock: UI unavailable") end,
    HttpGet = function(_, url)
        requests += 1
        local index = tonumber(url:match("part%-(%d+)%.txt$"))
        assert(index, "unexpected URL")
        if broken then return "incomplete" end
        return fixture:sub(offsets[index], offsets[index] + lengths[index] - 1)
    end,
}
local loadstring = function(text)
    compiles += 1
    local chunk, problem = nativeCompile(text)
    assert(chunk, problem)
    return function() return "compiled-only" end
end
local function run()
""" + main + """
end
assert(run() == "compiled-only")
assert(requests == 35 and compiles == 1)
assert(host.__mythicLoading == nil, "loading guard leaked")
host.__mythicLoading = true
assert(run() == nil and requests == 35)
host.__mythicLoading = nil
local active = {Destroyed = false}
host.__pulseMM2Nova = active
assert(run() == active and requests == 35, "duplicate active hub downloaded again")
host.__pulseMM2Nova = nil
broken = true
local ok = pcall(run)
assert(not ok and host.__mythicLoading == nil, "failed load cannot be retried")
for _, message in ipairs(warnings) do
    assert(not message:find("ajuste opcional nao aplicado", 1, true), message)
end
print("PASS: chunk byte count; every runtime patch matched; patched-source compilation; duplicate-load guard; error recovery")
"""

with tempfile.TemporaryDirectory(prefix="mythic-verify-") as directory:
    temporary = Path(directory)
    assembled = temporary / "assembled.lua"
    assembled.write_text(source)
    subprocess.run([compiler, "--null", str(assembled), str(HUB / "main.lua"),
                    str(HUB / "MYTHIC_HUB.lua")], check=True)
    for name, contents in (("worker", worker_test), ("loader", harness)):
        test = temporary / f"{name}.luau"
        test.write_text(contents)
        subprocess.run([runtime, str(test)], check=True)

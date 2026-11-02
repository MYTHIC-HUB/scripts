local catalog = require("../src/Catalog")

local expectedPages = {
    murderer = true, sheriff = true, visuals = true, player = true,
    teleport = true, farm = true, animations = true, troll = true,
    music = true, mobile = true, settings = true, server = true,
}
local expectedTabs = {
    visuals = { esp = true, skins = true },
    farm = { coin = true, role = true, boxes = true, webhook = true },
    animations = { bundles = true, emotes = true, skins = true },
    music = { boombox = true, sounds = true },
    settings = { interface = true, performance = true },
}
local photographedHeadings = {
    ["visuals.presets"] = true, ["visuals.text"] = true, ["visuals.chams"] = true,
    ["visuals.lights"] = true, ["visuals.look"] = true,
    ["mobile.bombSection"] = true, ["mobile.noclipSection"] = true,
}
local expectedKeybinds = {
    ["murderer.killAll"] = "B", ["sheriff.shoot"] = "F",
    ["player.noclip"] = "V", ["player.spin"] = "Z",
    ["player.bhop"] = "Q", ["player.invisible"] = "R",
    ["player.wallHop"] = "X",
}
local validTypes = {
    toggle = true, slider = true, select = true, button = true, input = true,
    note = true, players = true, stats = true, catalog = true,
}
local pageIds, sectionIds, controlIds, keybinds = {}, {}, {}, {}
local counts = { pages = 0, tabs = 0, sections = 0, controls = 0, keybinds = 0 }
local typeCounts = {}

local function titleIsBranded(title)
    assert(type(title) == "string" and title ~= "", "Missing title")
    assert(not string.find(string.lower(title), "pulse", 1, true), "Old brand in title: " .. title)
end
local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function checkControl(item)
    assert(type(item.id) == "string" and item.id ~= "", "Control without ID")
    assert(not controlIds[item.id], "Duplicate control ID: " .. item.id)
    assert(validTypes[item.type], "Unknown control type: " .. tostring(item.type))
    assert(type(item.label) == "string" and item.label ~= "", "Control without label: " .. item.id)
    assert(not string.find(string.lower(item.label), "nao aparece nas fotos", 1, true), "Reference placeholder: " .. item.id)
    assert(not string.find(string.lower(item.id), "reference", 1, true), "Reference-only control: " .. item.id)
    controlIds[item.id] = item
    counts.controls += 1
    typeCounts[item.type] = (typeCounts[item.type] or 0) + 1

    if item.type == "slider" then
        assert(finite(item.min) and finite(item.max) and item.min <= item.max, "Invalid range: " .. item.id)
        assert(finite(item.default) and item.default >= item.min and item.default <= item.max, "Default outside range: " .. item.id)
        assert(finite(item.step) and item.step > 0, "Invalid step: " .. item.id)
    elseif item.type == "select" then
        assert(type(item.options) == "table" and #item.options > 0, "Empty options: " .. item.id)
        local found = false
        for _, option in ipairs(item.options) do
            if (type(option) == "table" and option.value or option) == item.default then found = true end
        end
        assert(found, "Default missing from options: " .. item.id)
    elseif item.type == "toggle" then
        assert(type(item.default) == "boolean", "Non-boolean toggle default: " .. item.id)
    end
    if item.keybind then
        assert(expectedKeybinds[item.id] == item.keybind, "Unverified keybind: " .. item.id)
        assert(not keybinds[item.keybind], "Duplicate keybind: " .. item.keybind)
        assert(item.type == "toggle" or item.type == "button", "Non-action keybind: " .. item.id)
        keybinds[item.keybind] = item.id
        counts.keybinds += 1
    end
    if item.type == "catalog" then
        for _, asset in ipairs(item.items or {}) do
            if type(asset) == "table" then
                assert(type(asset.name) == "string" and asset.name ~= "", "Unnamed asset: " .. item.id)
                assert(asset.rarity ~= "PULSE", "Old brand in asset rarity")
            else
                assert(type(asset) == "string" and asset ~= "", "Invalid catalog item: " .. item.id)
            end
        end
    end
end
local function checkSections(sections, context)
    assert(type(sections) == "table" and #sections > 0, "Empty sections: " .. context)
    for _, item in ipairs(sections) do
        assert(type(item.id) == "string" and item.id ~= "", "Section without ID: " .. context)
        assert(not sectionIds[item.id], "Duplicate section ID: " .. item.id)
        sectionIds[item.id] = true
        titleIsBranded(item.title)
        assert(item.column == 1 or item.column == 2, "Invalid column: " .. item.id)
        assert(type(item.controls) == "table", "Missing controls: " .. item.id)
        if #item.controls == 0 then
            assert(photographedHeadings[item.id] and item.collapsed == true,
                "Empty section is not a photographed collapsed heading: " .. item.id)
        end
        counts.sections += 1
        for _, itemControl in ipairs(item.controls) do checkControl(itemControl) end
    end
end

assert(type(catalog) == "table" and #catalog == 12, "Expected 12 pages with photographed contents")
for _, page in ipairs(catalog) do
    assert(expectedPages[page.id], "Unexpected page: " .. tostring(page.id))
    assert(not pageIds[page.id], "Duplicate page ID: " .. page.id)
    pageIds[page.id] = true
    counts.pages += 1
    titleIsBranded(page.title)
    assert(type(page.subtitle) == "string", "Missing subtitle: " .. page.id)
    assert((page.tabs ~= nil) ~= (page.sections ~= nil), "Page needs tabs or sections: " .. page.id)
    if page.tabs then
        assert(#page.tabs > 0, "Page has empty tabs: " .. page.id)
        local tabIds = {}
        for _, tab in ipairs(page.tabs) do
            assert(type(tab.id) == "string" and tab.id ~= "", "Tab without ID: " .. page.id)
            assert(not tabIds[tab.id], "Duplicate tab in page: " .. page.id .. "/" .. tab.id)
            assert(expectedTabs[page.id] and expectedTabs[page.id][tab.id],
                "Tab without photographed contents: " .. page.id .. "/" .. tab.id)
            tabIds[tab.id] = true
            titleIsBranded(tab.title)
            counts.tabs += 1
            checkSections(tab.sections, page.id .. "/" .. tab.id)
        end
        for id in pairs(expectedTabs[page.id]) do
            assert(tabIds[id], "Missing photographed tab: " .. page.id .. "/" .. id)
        end
    else
        checkSections(page.sections, page.id)
    end
end
for id in pairs(expectedPages) do assert(pageIds[id], "Missing page: " .. id) end
for id, key in pairs(expectedKeybinds) do
    assert(controlIds[id] and controlIds[id].keybind == key, "Missing screenshot keybind: " .. id)
end
assert(controlIds["ui.menuKey"].default == "P", "Menu key must remain P")
assert(controlIds["ui.accentColor"].default == "#EF3340", "Nexus default accent must be red")
assert(table.find(controlIds["skins.rarity"].options, "NEXUS"), "Nexus rarity missing")
assert(not table.find(controlIds["skins.rarity"].options, "PULSE"), "Old rarity label remains")
assert(controlIds["player.spinSpeed"].min == 0 and controlIds["player.spinSpeed"].max == 100,
    "Spin must expose the requested 0-100 range")
assert(controlIds["farm.speed"].dynamicMax == "farm.method", "Farm speed must follow selected method")
assert(controlIds["farm.speed"].max == 26, "Teleport speed ceiling must be 26")
assert(table.find(controlIds["farm.method"].options, "Under Map"), "Under Map method missing")
assert(not table.find(controlIds["farm.method"].options, "Under..."), "Truncated method label remains")
assert(controlIds["farm.speed"].labels.Fast == "Fast Speed"
    and controlIds["farm.speed"].labels["Under Map"] == "Farm Speed"
    and controlIds["farm.speed"].labels.Teleport == "Teleport Speed", "Farm method labels must match reference")
assert(#controlIds["music.songs"].items == 1 and controlIds["music.songs"].items[1].id == "craudete",
    "The requested playlist must contain only Craudete")
assert(not controlIds["music.soundcloudTrack"] and not controlIds["music.add"],
    "The single-song playlist must not include other songs or an unconfigured SoundCloud player")

local types = {}
for name, count in pairs(typeCounts) do table.insert(types, name .. "=" .. tostring(count)) end
table.sort(types)
print(string.format("Catalog OK: %d pages, %d tabs, %d sections, %d controls, %d screenshot keybinds",
    counts.pages, counts.tabs, counts.sections, counts.controls, counts.keybinds))
print("Control inventory: " .. table.concat(types, ", "))

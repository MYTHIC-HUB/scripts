-- Labels and controls transcribed from the supplied screenshots.
local function control(id, kind, label, default, extra)
    local result = { id = id, type = kind, label = label, default = default }
    for key, value in pairs(extra or {}) do result[key] = value end
    return result
end
local function toggle(id, label, default, capability, keybind)
    return control(id, "toggle", label, default == true, { capability = capability, keybind = keybind })
end
local function slider(id, label, default, minimum, maximum, step, extra)
    local result = control(id, "slider", label, default, extra)
    result.min, result.max, result.step = minimum, maximum, step or 1
    return result
end
local function selectControl(id, label, default, options, capability)
    return control(id, "select", label, default, { options = options, capability = capability })
end
local function input(id, label, default, capability)
    return control(id, "input", label, default or "", { capability = capability })
end
local function button(id, label, capability, keybind)
    return control(id, "button", label, nil, { capability = capability, keybind = keybind })
end
local function note(id, label)
    return control(id, "note", label)
end
local function section(id, title, column, controls)
    return { id = id, title = title, column = column, controls = controls }
end
local function unknownSection(id, title, column)
    local result = section(id, title, column, {})
    result.collapsed = true
    return result
end

local skinItems = {
    { name = "Bone Reaper", kind = "Gun", rarity = "NEXUS" },
    { name = "Dragon Lore", kind = "Gun", rarity = "NEXUS" },
    { name = "Ejder Vandal", kind = "Gun", rarity = "NEXUS" },
    { name = "Hydra KRNL", kind = "Gun", rarity = "NEXUS" },
    { name = "Kawaii Pop", kind = "Gun", rarity = "NEXUS" },
    { name = "Pink Royale", kind = "Gun", rarity = "NEXUS" },
    { name = "Enma", kind = "Knife", rarity = "NEXUS" },
    { name = "Oni Katana", kind = "Knife", rarity = "NEXUS" },
    { name = "Batwing", kind = "Knife", rarity = "Ancient" },
    { name = "Celestial", kind = "Knife", rarity = "Ancient" },
    { name = "Elderwood Scythe", kind = "Knife", rarity = "Ancient" },
    { name = "Gingerscythe", kind = "Knife", rarity = "Ancient" },
    { name = "Bauble", kind = "Gun", rarity = "Godly" },
    { name = "Blaster", kind = "Gun", rarity = "Godly" },
    { name = "Blizzard", kind = "Gun", rarity = "Godly" },
    { name = "Blossom", kind = "Gun", rarity = "Godly" },
    { name = "Borealis", kind = "Gun", rarity = "Godly" },
    { name = "Constellation", kind = "Gun", rarity = "Godly" },
    { name = "Gingerscope", kind = "Gun", rarity = "Ancient" },
}

local pages = {
    {
        id = "murderer", title = "Murderer", subtitle = "Kill aura, knife throws and targets", icon = "M",
        sections = {
            section("murderer.main", "Murder", 1, {
                toggle("murderer.aura", "Kill Aura", false, "murderer.aura"),
                toggle("murderer.killAll", "Kill All", false, "murderer.killAll", "B"),
                toggle("murderer.killGunPlayers", "Kill Gun Players", false, "murderer.killGunPlayers"),
            }),
            section("murderer.throw", "Knife Throw", 2, {
                toggle("murderer.throwAim", "Knife Throw Aimbot", false, "murderer.throwAim"),
                toggle("murderer.autoThrow", "Auto Throw", false, "murderer.autoThrow"),
                toggle("murderer.knifeTracers", "Knife Tracers", false, "murderer.knifeTracers"),
            }),
            section("murderer.players", "Kill Player", 1, {
                control("murderer.target", "players", "Search player", nil, { capability = "murderer.target" }),
            }),
        },
    },
    {
        id = "sheriff", title = "Sheriff", subtitle = "Silent aim, aimbot and gun tools", icon = "S",
        sections = {
            section("sheriff.main", "Sheriff", 1, {
                toggle("sheriff.autoPickup", "Auto Pickup Gun", false, "sheriff.autoPickup"),
                button("sheriff.pickup", "Pick Up Gun", "sheriff.pickup"),
                toggle("sheriff.silentAim", "Silent Aim", false, "sheriff.silentAim"),
            }),
            section("sheriff.aimbot", "AimBot", 2, {
                toggle("sheriff.resolver", "Resolver", false, "sheriff.resolver"),
                selectControl("sheriff.aimType", "AimBot Type", "Classic", { "Classic" }),
                slider("sheriff.flickSpeed", "Flick Speed", 6, 1, 20, 1),
                toggle("sheriff.flickMouse", "Flick With Mouse", true, "sheriff.flickMouse"),
                slider("sheriff.flickReturn", "Flick Return %", 75, 0, 100, 1),
                slider("sheriff.prediction", "Prediction (ms)", 20, 0, 300, 1),
                button("sheriff.shoot", "Shot Murder", "sheriff.shoot", "F"),
            }),
            section("sheriff.fov", "AimBot FOV", 1, {
                toggle("sheriff.fovCircle", "Show FOV Circle", false),
            }),
            section("tracers.main", "Bullet Tracers", 1, {
                toggle("tracers.enabled", "Bullet Tracers", false, "tracers.enabled"),
                selectControl("tracers.method", "Tracer Method", "Classic", { "Classic" }),
                selectControl("tracers.style", "Tracer Style", "Energy", { "Energy" }),
                input("tracers.color", "Tracer Color", "#6BC4FF"),
                input("tracers.tailColor", "Tail Color", "#FF5AD2"),
                toggle("tracers.rainbow", "Rainbow Tracers", false),
                slider("tracers.width", "Tracer Width", 100, 1, 300, 1),
                slider("tracers.speed", "Tracer Speed", 520, 20, 2000, 10),
                slider("tracers.duration", "Tracer Duration", 1.2, 0.1, 5, 0.1),
                toggle("tracers.impact", "Impact Effect", true),
                toggle("tracers.muzzle", "Muzzle Flash", true),
                toggle("tracers.otherShots", "Show Other Shots", false, "tracers.otherShots"),
                button("tracers.preview", "Preview Tracer", "tracers.preview"),
            }),
        },
    },
    {
        id = "visuals", title = "Visuals", subtitle = "ESP, world lighting and effects", icon = "V",
        tabs = {
            { id = "esp", title = "ESP", sections = {
                section("visuals.esp.main", "ESP", 1, {
                    toggle("visuals.esp", "Enable ESP", false),
                    toggle("esp.murderer", "Murderer", true),
                    toggle("esp.sheriff", "Sheriff", true),
                    toggle("esp.hero", "Hero", true),
                    toggle("esp.innocent", "Innocent", true),
                    toggle("esp.noRole", "No Role", true),
                    slider("visuals.maxDistance", "Max Distance", 2000, 0, 2000, 10),
                    toggle("visuals.visibilityCheck", "Visibility Check", false),
                    toggle("visuals.gunEsp", "Gun ESP", false, "visuals.gunEsp"),
                }),
                unknownSection("visuals.presets", "Presets", 2),
                unknownSection("visuals.text", "Text", 2),
                unknownSection("visuals.chams", "Chams", 2),
                unknownSection("visuals.lights", "Lights", 2),
                unknownSection("visuals.look", "Look", 2),
            } },
            { id = "skins", title = "Skins", sections = {
                section("skins.main", "Weapon Skins", 1, {
                    toggle("skins.enabled", "Weapon Skin Changer", false, "skins.enabled"),
                    toggle("skins.belt", "Knife On Belt", false, "skins.belt"),
                    selectControl("skins.knife", "Knife", "Celestial", {
                        "Celestial", "Enma", "Oni Katana", "Batwing", "Elderwood Scythe", "Gingerscythe",
                    }, "skins.knife"),
                    selectControl("skins.gun", "Gun", "Gingerscope", {
                        "Gingerscope", "Bone Reaper", "Dragon Lore", "Ejder Vandal", "Hydra KRNL", "Kawaii Pop", "Pink Royale",
                        "Bauble", "Blaster", "Blizzard", "Blossom", "Borealis", "Constellation",
                    }, "skins.gun"),
                    button("skins.reset", "Reset To Real", "skins.reset"),
                }),
                section("skins.catalogSection", "Skin Catalog", 1, {
                    selectControl("skins.rarity", "Rarity", "Any", { "Any", "NEXUS", "Ancient", "Godly" }),
                    selectControl("skins.filter", "Type", "All", { "All", "Knife", "Gun" }),
                    control("skins.catalog", "catalog", "Skin Catalog", nil, { items = skinItems, capability = "skins.catalog" }),
                }),
            } },
        },
    },
    {
        id = "player", title = "Player", subtitle = "Movement, speed and protection", icon = "P",
        sections = {
            section("player.movement", "Movement", 1, {
                toggle("player.noclip", "No Clip", false, nil, "V"),
                toggle("player.cameraNoclip", "No Clip Camera", false),
                toggle("player.infiniteJump", "Infinite Jumps", false),
                toggle("player.antiFling", "Anti-Fling", false),
                toggle("player.antiCoin", "Anti Coin", false, "player.antiCoin"),
                toggle("player.bombJump", "Bomb Jump", false, "player.bombJump"),
                toggle("player.fly", "Fly", false),
                toggle("player.spin", "Spin", false, nil, "Z"),
                slider("player.spinSpeed", "Spin Speed", 20, 0, 100, 1),
                toggle("player.bhop", "Bhop", false, nil, "Q"),
                toggle("player.invisible", "Invisible", false, "player.invisible", "R"),
            }),
            section("player.antiAimSection", "Anti-Aim", 2, {
                toggle("player.antiAim", "Anti Aim", false, "player.antiAim"),
                selectControl("player.antiAim.mode", "AA Mode", "Desync", { "Desync" }, "player.antiAim"),
                selectControl("player.antiAim.direction", "Direction", "Random", { "Random" }, "player.antiAim"),
                slider("player.antiAim.strength", "Spoof Strength", 10, 0, 10, 1, { capability = "player.antiAim" }),
                toggle("player.antiAim.smartPause", "Smart Pause", true, "player.antiAim"),
                toggle("player.antiAim.spoofVelocity", "Spoof Velocity", true, "player.antiAim"),
                toggle("player.antiAim.spoofMoveDirection", "Spoof Move Direction", true, "player.antiAim"),
                toggle("player.antiAim.sideProfile", "Side Profile", true, "player.antiAim"),
            }),
            section("player.speedJump", "Speed & Jump", 2, {
                toggle("player.speedEnabled", "Walk Speed", false),
                slider("player.speed", "Walk Speed Value", 24, 0, 100, 1),
                toggle("player.jumpEnabled", "Jump Power", false),
                slider("player.jump", "Jump Power Value", 60, 0, 150, 1),
                toggle("player.speedGlitch", "Speed Glitch", false, "player.speedGlitch"),
                toggle("player.gravityEnabled", "Gravity", false),
                slider("player.gravity", "Gravity Value", 196.2, 0, 300, 0.1),
                toggle("player.hipHeightEnabled", "Hip Height", false),
                slider("player.hipHeight", "Hip Height Value", 2, 0, 20, 0.1),
            }),
            section("player.wallHopSection", "Wall Hop", 2, {
                toggle("player.wallHop", "Wall Hop", false, nil, "X"),
            }),
        },
    },
    {
        id = "teleport", title = "Teleport", subtitle = "Jump to roles and players", icon = "T",
        sections = {
            section("teleport.role", "TP Role", 1, {
                button("teleport.lobby", "Tp Lobby", "teleport.lobby"),
                button("teleport.map", "Tp Map", "teleport.map"),
                button("teleport.murderer", "Tp Murderer", "teleport.murderer"),
                button("teleport.sheriff", "Tp Sheriff", "teleport.sheriff"),
            }),
            section("teleport.players", "TP Player", 2, {
                control("teleport.player", "players", "Search player", nil, { capability = "teleport.player" }),
            }),
        },
    },
    {
        id = "farm", title = "Farm", subtitle = "Auto farm, session stats and trading", icon = "F",
        tabs = {
            { id = "coin", title = "Coin", sections = {
                section("farm.statsSection", "Stats", 1, { control("farm.stats", "stats", "Session / Coins per day / Total / Status") }),
                section("farm.tradeSection", "Trade", 1, {
                    toggle("farm.tradeCounter", "Trade Value Counter", false, "farm.tradeCounter"),
                    toggle("farm.inventoryValues", "Inventory Values", false, "farm.inventoryValues"),
                }),
                section("farm.main", "Farm", 2, {
                    selectControl("farm.method", "Farm Method", "Fast", { "Fast", "Under Map", "Teleport" }),
                    slider("farm.speed", "Fast Speed", 24, 1, 26, 1, {
                        dynamicMax = "farm.method",
                        labels = { Fast = "Fast Speed", ["Under Map"] = "Farm Speed", Teleport = "Teleport Speed" },
                    }),
                    toggle("farm.enabled", "Auto Farm", false, "farm.enabled"),
                    toggle("farm.rejoin", "Auto Rejoin on Kick", false, "farm.rejoin"),
                    toggle("farm.pickup", "Pick Up Gun", false, "farm.pickup"),
                    toggle("farm.shootFull", "Shoot Murderer on full bag", false, "farm.shootFull"),
                    toggle("farm.respawnFull", "Auto-Respawn on full bag", false, "farm.respawnFull"),
                    toggle("farm.avoidMurderer", "Avoid Murderer", false, "farm.avoidMurderer"),
                    toggle("farm.flingAfterRespawn", "Auto-Fling Murder after respawn", false, "farm.flingAfterRespawn"),
                    toggle("farm.killFull", "Kill all on full bag (murder role)", false, "farm.killFull"),
                    toggle("farm.zombieShoot", "Zombies: shoot as Survivor", false, "farm.zombieShoot"),
                    toggle("farm.zombieKill", "Zombies: Kill All as Zombie", false, "farm.zombieKill"),
                    toggle("farm.zombieFling", "Zombies: Fling gun holders after reset", false, "farm.zombieFling"),
                }),
            } },
            { id = "role", title = "Role", sections = {
                section("rolefarm.statsSection", "Stats", 1, { control("rolefarm.stats", "stats", "Role / Status / Wins / Kills / Level / Prestige") }),
                section("rolefarm.main", "Role Farm", 2, {
                    toggle("rolefarm.innocent", "Innocent Win Farm", false, "rolefarm.innocent"),
                    toggle("rolefarm.sheriff", "Sheriff Win Farm", false, "rolefarm.sheriff"),
                    toggle("rolefarm.murderer", "Murderer Kill Farm", false, "rolefarm.murderer"),
                    toggle("rolefarm.exp", "EXP Farm", false, "rolefarm.exp"),
                    toggle("rolefarm.prestige", "Auto Prestige", false, "rolefarm.prestige"),
                }),
            } },
            { id = "boxes", title = "Boxes", sections = {
                section("boxes.statsSection", "Stats", 1, { control("boxes.stats", "stats", "Opened / Status / Balance / Last Drop") }),
                section("boxes.main", "Boxes", 2, {
                    selectControl("boxes.box", "Box", "", { { label = "Select box", value = "" } }, "boxes.box"),
                    selectControl("boxes.currency", "Pay With", "Auto", { "Auto" }, "boxes.currency"),
                    slider("boxes.delay", "Open Delay", 1, 0.1, 10, 0.1),
                    toggle("boxes.animation", "Show Animation", false),
                    toggle("boxes.auto", "Auto Open", false, "boxes.auto"),
                    button("boxes.open", "Open Once", "boxes.open"),
                }),
            } },
            { id = "webhook", title = "Webhook", sections = {
                section("webhook.main", "Webhook", 1, {
                    input("webhook.url", "Webhook URL", "", "webhook.url"),
                    toggle("webhook.enabled", "Send Farm Stats", false, "webhook.enabled"),
                    slider("webhook.interval", "Every (min)", 10, 1, 120, 1),
                    toggle("webhook.disconnect", "Disconnect Alert", false, "webhook.disconnect"),
                    button("webhook.test", "Send Test", "webhook.test"),
                }),
            } },
        },
    },
    {
        id = "animations", title = "Animations", subtitle = "Free bundles, emotes and skins", icon = "A",
        tabs = {
            { id = "bundles", title = "Bundles", sections = {
                section("animations.options", "Animation options", 1, {
                    slider("animations.speed", "Animation Speed", 1.11, 0.1, 3, 0.01),
                    toggle("animations.autoLoad", "Auto-load on respawn", true),
                    button("animations.reset", "Reset to default animations"),
                }),
                section("animations.combo", "Animation combo", 1, {
                    button("animations.clear", "Clear"),
                    control("animations.idle", "catalog", "Idle", "", { compact = true }),
                    control("animations.walk", "catalog", "Walk", "", { compact = true }),
                    control("animations.run", "catalog", "Run", "", { compact = true }),
                    control("animations.jump", "catalog", "Jump", "", { compact = true }),
                    control("animations.fall", "catalog", "Fall", "", { compact = true }),
                    control("animations.climb", "catalog", "Climb", "", { compact = true }),
                    control("animations.swim", "catalog", "Swim", "", { compact = true }),
                }),
            } },
            { id = "emotes", title = "Emotes", sections = {
                section("animations.emoteOptions", "Emote options", 1, {
                    slider("animations.emoteSpeed", "Emote Speed", 1, 0.1, 3, 0.01),
                    toggle("animations.emoteHold", "Hold (don't stop when moving)", false),
                    button("animations.stopEmote", "Stop emote"),
                }),
                section("animations.emoteSection", "Emote catalog", 1, {
                    input("animations.emoteSearch", "Search emotes or paste emote ID", ""),
                    button("animations.searchEmotes", "Search"),
                    control("animations.emoteCatalog", "catalog", "Emote catalog", nil, {
                        items = { "Apontando2", "Fazer o Que", "Ola", "Estadio", "Aura Flutuante", "Macaco" },
                        capability = "animations.emoteCatalog",
                    }),
                }),
            } },
            { id = "skins", title = "Skins", sections = {
                section("animations.skin", "Skin", 1, {
                    input("animations.skinUser", "Username or user ID", ""),
                    button("animations.wearSkin", "Wear"),
                    button("animations.removeSkin", "Remove Skin"),
                }),
                section("animations.presets", "Presets", 1, {
                    control("animations.skinCatalog", "catalog", "Presets", nil, { capability = "animations.skinCatalog" }),
                }),
            } },
        },
    },
    {
        id = "troll", title = "Troll", subtitle = "Pranks, flings, toys and emotes", icon = "T",
        sections = {
            section("troll.emotes", "Emotes", 1, {
                selectControl("troll.emote", "Emote", "zombie", { "zombie" }, "troll.emote"),
                toggle("troll.autoEmote", "Auto Emote", false, "troll.autoEmote"),
            }),
            section("troll.toys", "Equip Toy", 2, {
                selectControl("troll.toy", "Toys", "Broom", { "Broom" }, "troll.toy"),
                toggle("troll.autoToy", "Auto Equip Toy", false, "troll.autoToy"),
            }),
            section("troll.fakeItems", "Fake Items", 1, {
                toggle("troll.fakeKorblox", "Fake Korblox", false),
                toggle("troll.fakeHeadless", "Fake Headless", false),
            }),
            section("troll.main", "Troll", 2, {
                toggle("troll.jerkTool", "Jerk OFF Tool (R15)", false, "troll.jerkTool"),
                toggle("troll.touchFling", "Touch Fling", false, "troll.touchFling"),
                toggle("troll.clickFling", "Click Fling", false, "troll.clickFling"),
                toggle("troll.clickHump", "Click Hump", false, "troll.clickHump"),
                toggle("troll.orbit", "Orbit", false, "troll.orbit"),
                toggle("troll.playerMenu", "Player Menu", false, "troll.playerMenu"),
            }),
            section("troll.flingPlayers", "Fling Players", 1, {
                toggle("troll.flingPanel", "Fling Panel", false, "troll.flingPanel"),
                control("troll.flingTarget", "players", "Search player", nil, { capability = "troll.flingTarget" }),
            }),
        },
    },
    {
        id = "music", title = "Music", subtitle = "Play your songs in the round", icon = "M",
        tabs = {
            { id = "boombox", title = "Boombox", sections = {
                section("music.effects", "Audio Effects", 1, {
                    selectControl("music.effect", "Audio Effects", "Original", {
                        "Original", "Nightcore", "Slowed + Reverb", "Vaporwave", "Bass Boost", "8D", "Concert", "Muffled", "Chipmunk", "Demon",
                    }),
                    slider("music.speed", "Speed", 1, 0.25, 2, 0.01),
                    slider("music.pitch", "Pitch", 0, -12, 12, 1),
                    slider("music.bass", "Bass (dB)", 0, -20, 20, 1),
                }),
            } },
            { id = "sounds", title = "Sounds", sections = {
                section("music.player", "Music Player", 1, {
                    button("music.play", "Play / Pause"),
                    button("music.previous", "Previous"), button("music.next", "Next"),
                    toggle("music.shuffle", "Shuffle", false), toggle("music.repeat", "Repeat", false),
                    slider("music.volume", "Volume (local)", 50, 0, 100, 1),
                    toggle("music.autoPlay", "Auto Play on Round Start", false, "music.autoPlay"),
                    toggle("music.onScreen", "On-screen Player", false),
                }),
                section("music.library", "My Songs", 1, {
                    control("music.songs", "catalog", "Craudete - Brancoala", nil, {
                        items = { { id = "craudete", name = "Craudete", kind = "Brancoala" } },
                    }),
                }),
                section("music.customSounds", "Custom Sounds", 2, {
                    selectControl("music.shotSound", "Shot Sound", "Off", { "Off" }),
                    button("music.previewShot", "Preview Shot"),
                    selectControl("music.killSound", "Kill Sound", "Off", { "Off" }),
                    button("music.previewKill", "Preview Kill"),
                    slider("music.soundVolume", "Sound Volume", 60, 0, 100, 1),
                }),
                section("music.gameSounds", "Game Sounds", 2, {
                    selectControl("music.roleRoll", "Role Roll Sound", "Game", { "Game" }, "music.roleRoll"),
                    selectControl("music.roleReveal", "Role Reveal Sound", "Game", { "Game" }, "music.roleReveal"),
                    selectControl("music.victory", "Victory Music", "Off", { "Off" }, "music.victory"),
                    slider("music.gameVolume", "Game Sounds Volume", 200, 0, 200, 1),
                    button("music.previewRoles", "Preview Roles", "music.previewRoles"),
                    button("music.previewVictory", "Preview Victory", "music.previewVictory"),
                }),
            } },
        },
    },
    {
        id = "mobile", title = "Mobile", subtitle = "On-screen buttons for touch", icon = "M",
        sections = {
            section("mobile.general", "General", 1, { note("mobile.instructions", "On-screen buttons (mobile). Hold & drag a button to move it, tap to use.") }),
            section("mobile.styleSection", "Buttons Style", 2, {
                selectControl("mobile.style", "Button Design", "Glass", { "Glass" }),
            }),
            section("mobile.flySection", "Fly Button", 1, {
                toggle("mobile.fly", "Fly Button", false), slider("mobile.flySize", "Fly Button Size", 100, 50, 200, 1),
            }),
            section("mobile.bhopSection", "Bhop Button", 2, {
                toggle("mobile.bhop", "Bhop Button", false), slider("mobile.bhopSize", "Bhop Button Size", 100, 50, 200, 1),
            }),
            section("mobile.flingSheriffSection", "Fling Sheriff Button", 1, {
                toggle("mobile.flingSheriff", "Fling Sheriff Button", false, "troll.flingTarget"),
                slider("mobile.flingSheriffSize", "Fling Sheriff Button Size", 100, 50, 200, 1),
            }),
            section("mobile.flingMurdererSection", "Fling Murder Button", 2, {
                toggle("mobile.flingMurderer", "Fling Murder Button", false, "troll.flingTarget"),
                slider("mobile.flingMurdererSize", "Fling Murder Button Size", 100, 50, 200, 1),
            }),
            section("mobile.shotSection", "Shot Murder Button", 1, {
                toggle("mobile.shotMurderer", "Shot Murder Button", false, "sheriff.shoot"),
                slider("mobile.shotMurdererSize", "Shot Murder Button Size", 100, 50, 200, 1),
            }),
            section("mobile.killSection", "Kill All Murder Button", 2, {
                toggle("mobile.killAll", "Kill All Murder Button", false, "murderer.killAll"),
                slider("mobile.killAllSize", "Kill All Murder Button Size", 100, 50, 200, 1),
            }),
            section("mobile.invisibleSection", "Invisible Button", 1, {
                toggle("mobile.invisible", "Invisible Button", false, "player.invisible"),
                slider("mobile.invisibleSize", "Invisible Button Size", 100, 50, 200, 1),
            }),
            section("mobile.knifeSection", "Knife Throw Button", 2, {
                toggle("mobile.knifeThrow", "Knife Throw Button", false, "murderer.throwAim"),
                slider("mobile.knifeThrowSize", "Knife Throw Button Size", 100, 50, 200, 1),
            }),
            unknownSection("mobile.bombSection", "Auto Bomb Jump", 1),
            unknownSection("mobile.noclipSection", "No Clip Button", 2),
            section("mobile.speedSection", "Speed Button", 1, {
                toggle("mobile.speed", "Speed Button", false), slider("mobile.speedSize", "Speed Button Size", 100, 50, 200, 1),
            }),
            section("mobile.glitchSection", "Speed Glitch Button", 2, {
                toggle("mobile.speedGlitch", "Speed Glitch Button", false, "player.speedGlitch"),
                slider("mobile.speedGlitchSize", "Speed Glitch Button Size", 100, 50, 200, 1),
                button("mobile.resetPositions", "Reset UIS Position"),
            }),
            section("mobile.lockSection", "Lock", 1, {
                toggle("mobile.doubleTapLock", "Double Tap Lock", false),
                button("mobile.unlock", "Unlock All Buttons"),
            }),
            section("mobile.hud", "HUD", 2, {
                toggle("mobile.showPing", "Show Ping/Fps UI", true),
                toggle("mobile.roundTimer", "Show Round Timer", false, "mobile.roundTimer"),
            }),
        },
    },
    {
        id = "settings", title = "Settings", subtitle = "Menu, configs and performance", icon = "S",
        tabs = {
            { id = "interface", title = "Interface", sections = {
                section("settings.menu", "Menu", 1, {
                    input("ui.menuKey", "Menu key", "P"),
                    toggle("ui.showFps", "Show FPS / Ping", true),
                    selectControl("ui.language", "Language", "English", { "English" }),
                }),
                section("settings.interface", "Interface", 2, {
                    slider("ui.scale", "UI scale", 0.8, 0.5, 1.4, 0.05),
                    toggle("ui.fit", "Fit to screen", true),
                    slider("ui.radius", "Corner radius", 2, 0, 2, 0.1),
                    slider("ui.textScale", "Text size", 1.1, 0.8, 1.4, 0.05),
                    selectControl("ui.font", "Font", "Ubuntu", { "Ubuntu" }),
                    slider("ui.opacity", "Window opacity", 1, 0.2, 1, 0.05),
                    selectControl("ui.sidebarDensity", "Sidebar density", "Comfortable", { "Comfortable" }),
                    toggle("ui.compactSidebar", "Compact sidebar", false),
                    toggle("ui.groupLabels", "Group labels", false),
                }),
                section("settings.theme", "Theme", 1, {
                    toggle("ui.halloween", "Halloween theme", true),
                    input("ui.accentColor", "Custom accent", "#EF3340"),
                    selectControl("ui.baseTheme", "Base theme", "Halloween", { "Halloween" }),
                    input("ui.panelColor", "Panel color", "#151111"),
                    selectControl("ui.cardStyle", "Card style", "Flat", { "Flat" }),
                    selectControl("ui.background", "Background", "Halloween", { "Halloween" }),
                    slider("ui.backgroundIntensity", "Background intensity", 1.5, 0, 1.5, 0.05),
                    toggle("ui.blur", "Blur behind menu", false),
                }),
                section("settings.behavior", "Behavior", 2, {
                    toggle("ui.animations", "Animations", true),
                    toggle("ui.sounds", "Interface sounds", true),
                    slider("ui.soundVolume", "Sound volume", 1, 0, 1, 0.05),
                    toggle("ui.tooltips", "Tooltips", true),
                    toggle("ui.launcher", "Launcher button", true),
                    button("ui.resetAppearance", "Reset appearance"),
                }),
                section("settings.general", "General", 1, {
                    toggle("general.antiAfk", "Anti AFK", false, "general.antiAfk"),
                    slider("general.screenStretch", "Screen Stretch", 30, 0, 100, 1),
                    toggle("general.trollyNpc", "Trolly NPC", false, "general.trollyNpc"),
                    toggle("general.trollyDances", "Trolly Dances", false, "general.trollyDances"),
                    slider("general.trollyVolume", "Trolly Volume", 100, 0, 100, 1),
                    button("general.reset", "Reset All Settings"),
                    button("unload", "Unload hub"),
                }),
            } },
            { id = "performance", title = "Performance", sections = {
                section("perf.optimizer", "Optimizer", 1, {
                    toggle("perf.noShadows", "No Shadows", false),
                    toggle("perf.noLights", "No Map Lights", false),
                    toggle("perf.noPostEffects", "No Post Effects", false),
                    toggle("perf.noParticles", "No Particles", false),
                    toggle("perf.noTextures", "No Textures", false),
                    toggle("perf.plastic", "Plastic Materials", false),
                    toggle("perf.antiGlare", "Anti-Glare", false),
                }),
                section("perf.main", "Performance", 2, {
                    toggle("perf.fpsUnlock", "FPS Unlocker (9999)", false, "perf.fpsUnlock"),
                    toggle("perf.lowGraphics", "Low Graphics", false),
                    toggle("perf.simplePlayers", "Simple Players", false),
                    toggle("perf.stopAnimations", "Stop Animations (others)", false),
                    toggle("perf.backgroundSaver", "Background Saver", false, "perf.backgroundSaver"),
                    toggle("perf.disable3d", "Disable 3D Rendering", false),
                }),
            } },
        },
    },
    {
        id = "server", title = "Server", subtitle = "Rejoin, hop and server info", icon = "S",
        sections = {
            section("server.main", "Server", 1, {
                button("server.rejoin", "Rejoin Server", "server.rejoin"),
                button("server.hop", "Server Hop", "server.hop"),
                button("server.small", "Join Small Server", "server.small"),
            }),
            section("server.jobSection", "Job ID", 2, {
                button("server.copyJob", "Copy Job ID", "server.copyJob"),
                input("server.jobId", "Job ID", ""),
                button("server.joinJob", "Join", "server.joinJob"),
            }),
            section("server.info", "Server Info", 2, { control("server.stats", "stats", "Players / Ping / Job") }),
            section("server.vote", "Map Vote", 1, {
                selectControl("server.map", "Map", "Spaceship", { "Workplace", "Mineshaft", "Spaceship" }, "server.map"),
                slider("server.votes", "Votes to add", 4, 1, 20, 1, { capability = "server.dupeVotes" }),
                button("server.dupeVotes", "Dupe Votes", "server.dupeVotes"),
                button("server.stopVotes", "Stop", "server.stopVotes"),
                toggle("server.votePanel", "Vote Panel", false, "server.votePanel"),
                toggle("server.silentRespawn", "Silent Respawn", false, "server.silentRespawn"),
            }),
            section("server.dupe", "Auto Dupe", 2, {
                toggle("server.autoDupe", "Auto Dupe", false, "server.autoDupe"),
                toggle("server.farmPriority", "Farm Priority", false, "server.farmPriority"),
                toggle("server.exploreMaps", "Explore Maps", false, "server.exploreMaps"),
                selectControl("server.otherMaps", "Other maps", "Dupe...", { "Dupe..." }, "server.otherMaps"),
            }),
            section("server.priority", "Map Priority", 2, {
                control("server.mapPriority", "catalog", "Map Priority", nil, { capability = "server.mapPriority" }),
            }),
        },
    },
}

return pages

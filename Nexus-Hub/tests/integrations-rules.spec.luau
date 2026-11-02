local rules = require("../src/Integrations").rules
local profile = { Coins = 1500, Gems = 200, Materials = { Owned = { Key = 2, Candy2026 = 800 } } }
local entries, indexed = rules.cratesFromShop({ Weapons = {
    MysteryBox1 = { DataType = "MysteryBox", Price = { Coins = 1000, Gems = 100, Key = 1 }, LayoutOrder = 1 },
    Halloween2026 = { DataType = "MysteryBox", Price = { Candy2026 = 600 }, LayoutOrder = 2 },
    Premium = { DataType = "MysteryBox", Price = { Robux = 100 } },
    Fake = { DataType = "Item", Price = { Coins = 1 } },
    Broken = { DataType = "MysteryBox", Price = { Coins = 0 / 0 } },
} }, { MysteryBox1 = { Name = "Mystery Box #1" } })
assert(#entries == 2 and entries[1].name == "Mystery Box #1")
assert(not indexed.Premium and not indexed.Fake and not indexed.Broken)
assert(rules.balance(profile, "Coins") == 1500)
assert(rules.balance(profile, "Key") == 2)
local weaponKeyProfile = { Coins = 0, Gems = 0, Materials = { Owned = {} }, Weapons = { Owned = { Key = 2 } } }
assert(rules.balance(weaponKeyProfile, "Key") == 2, "Keys can be stored in Weapons.Owned")
assert(rules.chooseCurrency(indexed.MysteryBox1, "Auto", weaponKeyProfile) == "Key",
    "Auto must recognize an owned key when coin balances are insufficient")
assert(rules.chooseCurrency(indexed.MysteryBox1, "Key", weaponKeyProfile) == "Key")
assert(rules.chooseCurrency(indexed.MysteryBox1, "Auto", profile) == "Coins")
assert(rules.chooseCurrency(indexed.MysteryBox1, "Gems", profile) == "Gems")
assert(rules.chooseCurrency(indexed.Halloween2026, "Auto", profile) == "Candy2026")
assert(not rules.chooseCurrency(indexed.Halloween2026, "Gems", profile))
assert(not rules.chooseCurrency(indexed.Halloween2026, "Auto", { Coins = 99999 }))
assert(not rules.chooseCurrency(indexed.MysteryBox1, "Auto", { Coins = 0, Gems = 0, Materials = { Owned = {} } }))
assert(rules.rewardId("Known", { Known = { ItemName = "Known weapon" } }) == "Known")
assert(not rules.rewardId(nil, { Known = {} }))
assert(not rules.rewardId("Error message", { Known = {} }))
assert(not rules.rewardId({ Item = "Known" }, { Known = {} }))
assert(rules.bagState("Coin", 50, 50).full)
assert(not rules.bagState("Coin", 49, 50).full)
assert(not rules.bagState("Coin", 51, 50))
assert(not rules.bagState("Coin", 1, 0))
assert(not rules.bagState("Coin", math.huge, math.huge))
print("PASS: native crate schema, currencies, affordability, confirmed rewards and bag state")

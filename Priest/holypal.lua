local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.priest
local lftime = 0

-------------
---Spells---
-------------
SB.GiftOftheNaaru = 59544
SB.MendingBuff = 41635


local function combat()

-------------
--Modifiers--
-------------
    if modifier.alt and castable(SB.MassDispell) then
      return cast(SB.MassDispell, 'ground')
    end

    if modifier.shift and castable(SB.AngelicFeather) and player.buff(SB.AngelicFeather).down then
      return cast(SB.AngelicFeather, 'player')
    end

    if modifier.control and castable(SB.DivineHymn) then
      return cast(SB.DivineHymn)
    end

-------------
---Dispel----
-------------
    if toggle('dispel', false) and castable(SB.Purify) and player.dispellable(SB.Purify) then
        return cast(SB.Purify, 'player')
    end
    local unit = group.dispellable(SB.Purify)
    if unit and unit.distance < 40 then
        return cast(SB.Purify, unit)
    end



end
local function resting()
-------------
----Fetch----
-------------
local lfg = GetLFGProposal();
local hasData = GetLFGQueueStats(LE_LFG_CATEGORY_LFD);
local hasData2 = GetLFGQueueStats(LE_LFG_CATEGORY_LFR);
local hasData3 = GetLFGQueueStats(LE_LFG_CATEGORY_RF);
local hasData4 = GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO);
local hasData5 = GetLFGQueueStats(LE_LFG_CATEGORY_FLEXRAID);
local hasData6 = GetLFGQueueStats(LE_LFG_CATEGORY_WORLDPVP);
local bgstatus = GetBattlefieldStatus(1);
local autojoin = dark_addon.settings.fetch('holypal_utility_autojoin', true)

-------------
--Auto Join--
-------------
if autojoin == true and hasData == true or hasData2 == true or hasData4 == true or hasData5 == true or hasData6 == true or bgstatus == "queued" then
 SetCVar ("Sound_EnableSoundWhenGameIsInBG",1)
elseif autojoin == false and hasdata == nil or hasData2 == nil or hasData3 == nil or hasData4 == nil or hasData5 == nil or hasData6 == nil or bgstatus == "none" then
 SetCVar ("Sound_EnableSoundWhenGameIsInBG",0)
end

if autojoin ==true and lfg == true or bgstatus == "confirm" then
  PlaySound(SOUNDKIT.IG_PLAYER_INVITE, "Dialog", false);
  lftime = lftime + 1
end

if lftime >=math.random(20,35) then
  SetCVar ("Sound_EnableSoundWhenGameIsInBG",0)
  macro('/click LFGDungeonReadyDialogEnterDungeonButton')
  lftime = 0
end    



-------------
--Modifiers--
-------------
    if modifier.alt and castable(SB.MassDispell) then
      return cast(SB.MassDispell, 'ground')
    end

    if modifier.shift and castable(SB.AngelicFeather) and player.buff(SB.AngelicFeather).down then
      return cast(SB.AngelicFeather, 'player')
    end
-------------
----Buff-----
-------------
    local allies_without_my_buff = group.count(function (unit)
        return unit.alive and unit.distance < 40 and unit.buff(SB.PowerWordFortitude).down
    end)
    if allies_without_my_buff > 2 and castable(SB.PowerWordFortitude) then
        return cast(SB.PowerWordFortitude, 'player')
    end

    if player.buff(SB.PowerWordFortitude).down and castable(SB.PowerWordFortitude) then
        return cast(SB.PowerWordFortitude, 'player')
    end

    
end

function interface()
  local settings = {
    key = 'holypal_settings',
    title = 'Holy Pal - Settings',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Holy Pal - Settings', align= 'center' },
      { type = 'rule' },

    }
  }

  configWindowtwo = dark_addon.interface.builder.buildGUI(settings)

  local utility = {
    key = 'holypal_utility',
    title = 'Holy Pal - Utility',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Holy Pal - Utility', align= 'center' },
      { type = 'rule' },
      { type = 'text', text = 'Dungeon Settings' },
      { key = 'autojoin', type = 'checkbox', text = 'Auto Join', desc = 'Automatically accept Dungeon/Battleground Invites', default = true },
      { type = 'rule' },

    }
  }

  configWindow = dark_addon.interface.builder.buildGUI(utility)

  dark_addon.interface.buttons.add_toggle({
    name = 'settings',
    label = 'Rotation Settings',
    font = 'dark_addon_icon',
    on = {
      label = dark_addon.interface.icon('cog'),
      color = dark_addon.interface.color.blue,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.blue, 0.7)
    },
    off = {
      label = dark_addon.interface.icon('cog'),
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    },
    callback = function(self)
      if configWindow.parent:IsShown() then
        configWindow.parent:Hide()
      else
        --logwindows.parent:Show()
        configWindow.parent:Show()
      end
            if configWindowtwo.parent:IsShown() then
        configWindowtwo.parent:Hide()
      else
        --logwindows.parent:Show()
        configWindowtwo.parent:Show()
      end
    end
  })
end
dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.priest.holy,
    name = 'holypal',
    label = 'PAL: Holy Priest',
    combat = combat,
    resting = resting,
    interface = interface
})

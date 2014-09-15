require("rubickbrawl")
require("constants")

shrinkDummies = {}
shrinkDummies.firstLevel = {}

--[[function RubickBrawlGameMode:AbilityUpgradeCost(keys)
  print ( '[RUBICKBRAWL] AbilityUpgradeCost' )
  --PrintTable(keys)
  --print("player:"..keys.player)
  --PrintTable(self.vPlayers)

  local ID = keys.player - 1

  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
      local abilityToUpgrade = keys.abilityname
      local abil = player.hero:FindAbilityByName(abilityToUpgrade)
      -- local currentLevel = player.currentAbilities[abilityToUpgrade].level
      local currentLevel = abil:GetLevel()
      if abilityToUpgrade == 'rubickbrawl_scourge' then return end
      print(currentLevel)
      print("ability to upgrade: ".. abilityToUpgrade)

      -- check the gold costs
     -- abilityCostKey = abilityToUpgrade .. '_cost'
      --abilityCosts = spellCosts[abilityCostKey]
      print('abilityCostKey: ' .. abilityCostKey)
      -- ensure that the current ability is not the max level.
      --if currentLevel-1 <= #abilityCosts then
        --  newLevel = currentLevel + 1
        --costToUpgrade = abilityCosts[currentLevel]
        --if not costToUpgrade then return end
        --print('costToUpgrade: ' .. costToUpgrade)
        -- check if player's current gold is >= costToUpgrade
        --if player.hero:GetGold() >= costToUpgrade then
         -- player.hero:SetGold(player.hero:GetGold() - costToUpgrade, true)
          -- well shit, the player bought something he didn't have the gold for
        else
          player.hero:RemoveAbility(abilityToUpgrade)
          abil = player.hero:FindAbilityByName(abilityToUpgrade)
          player.hero:AddAbility(abilityToUpgrade)
          abil = player.hero:FindAbilityByName(abilityToUpgrade)
          abil:SetLevel(currentLevel-1)
        end
      end
    end
  end)
end]]

function isPlayerInLava(player)

  if player.onLava == true then
    player.hero:ModifyHealth (player.hero:GetHealth()-LAVA_DAMAGE, player.lastHitByPlayer, false, 0)
    -- player.damageTaken = player.damageTaken + LAVA_DAMAGE
    if player.lavaModAdded == false then
      player.hero:AddNewModifier(player.hero, nil, "modifier_jakiro_liquid_fire_burn", nil)
      player.hero:AddNewModifier(player.hero, nil, "modifier_bloodseeker_rupture", nil)

      player.lavaModAdded = true
    end
  end

  if player.onLava == false then
    if player.lavaModAdded == true then
      player.hero:RemoveModifierByName("modifier_jakiro_liquid_fire_burn")
      player.hero:RemoveModifierByName("modifier_bloodseeker_rupture")
      player.lavaModAdded = false
    end
  end

  if player.isBleeding == true and player.hero:HasModifier('modifier_bloodseeker_rupture') then
    if player.hero:GetPhysicsVelocity():Length() <= bleeding_threshold_vel then
      player.hero:RemoveModifierByName("modifier_bloodseeker_rupture")
      player.isBleeding = false
    end
  end

  -- Check if you're in the bounding rect. If you are, do the hard work to see if you're in the lava or not.
  if (player.hero:GetAbsOrigin().y >= -BOUNDING_RECT and player.hero:GetAbsOrigin().x >= -BOUNDING_RECT)
    and (player.hero:GetAbsOrigin().y <= BOUNDING_RECT and player.hero:GetAbsOrigin().x <= BOUNDING_RECT) then
    -- if firstLevelLava timer started, then polygon test is irrelevent.
    if lavaTimersStarted then 
      if math.pow(player.hero:GetAbsOrigin().x,2) + math.pow(player.hero:GetAbsOrigin().y,2) <= math.pow(platformRadius-20,2) then
        player.onLava = false
      else player.onLava = true
      end

      -- if the timer didn't start, then do the polygon test.
    else
      local c = pnpoly(vertx,verty,player.hero:GetAbsOrigin().x,player.hero:GetAbsOrigin().y)
      if c == -1 then
        player.onLava = true
      end
      -- print('c = ' .. c)
      if c == 1 then
        player.onLava = false
      end
    end

    -- You're outside the bounding rect, so in the lava
  else
    player.onLava = true
  end
end

function RubickBrawlGameMode:initLavaTimers()
  --firstLevelLavaTimer()
  --rubickbrawl_lava_circle_19
  lavaTimersStarted = true
  if firstRound then
    lavaTimerEndTimes = {[1] = GameRules:GetGameTime() + PRE_GAME_TIME+PRE_ROUND_TIME+3}
  else 
    lavaTimerEndTimes = {[1] = GameRules:GetGameTime() + PRE_ROUND_TIME+8}
  end

  lavaLevelUpdated = {[1] = false}

  for i=2,12 do
    lavaTimerEndTimes[i] = lavaTimerEndTimes[i-1] + 8.0
    lavaLevelUpdated[i] = false
  end

  for i=1,12 do
    RubickBrawlGameMode:CreateTimer('rubickbrawl_lava_circle_' .. i, {
      useGameTime = true,
      endTime = lavaTimerEndTimes[i],
      callback = function(rubickbrawl, args)
        if i == 2 and self.timers['rubickbrawl_lava_circle_' .. i-1] ~= nil then self:RemoveTimer('rubickbrawl_lava_circle_' .. i-1) end
        local casterDummy = CreateUnitByName("npc_dummy_unit_nofly", Vector(0,0,0), true, nil, nil, DOTA_TEAM_GOODGUYS)
        casterDummy:AddAbility('rubickbrawl_lava_circle_' .. i)
        local lavaCircle = casterDummy:FindAbilityByName('rubickbrawl_lava_circle_' .. i)
        lavaCircle:SetLevel(1)
        casterDummy:CastAbilityImmediately(lavaCircle, 0)
        casterDummy:ForceKill(true)
        if platformRadius > 0 and lavaLevelUpdated[i] == false then
          platformRadius = platformRadius - 145.0
          lavaLevelUpdated[i] = true
          print('plat radius: ' .. platformRadius)
        end
        return GameRules:GetGameTime() + 3.8
      end})
  end
end

function damageTaken(hero)
  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if hero == player.hero then
      return player.damageTaken
    end
  end)
  return 0
end


































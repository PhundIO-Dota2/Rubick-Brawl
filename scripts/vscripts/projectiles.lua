require("rubickbrawl")
require("constants")
require("physics")
require("lava")

function playCollisionEffect(v)
  if v.collidedWithHero == true then
    if v.spell == 'rubickbrawl_fireball' then
      ParticleManager:CreateParticle('clinkz_strafe_flare', PATTACH_ABSORIGIN_FOLLOW, v.unit)
    end
    if v.spell == 'rubickbrawl_lightning' then
      -- play lightning effect
      lightningAbility({caster = v.caster, target = v.target})
    end
  end

  if v.collidedWithSpell == true then
    if v.spell == 'rubickbrawl_lightning' then
      lightningMissed({caster = v.caster, target_points = {[1] = v.unit:GetAbsOrigin()}})
    end
    if v.spell == 'rubickbrawl_fireball' then
      ParticleManager:CreateParticle('clinkz_strafe_flare', PATTACH_ABSORIGIN_FOLLOW, v.unit)
    end
  end

  if v.didNotCollide == true then
    if v.spell == 'rubickbrawl_lightning' then
      lightningMissed({caster = v.caster, target_points = {[1] = v.unit:GetAbsOrigin()}})
    end
  end
end

function getAbilityReady(dummy, abilityName)
  dummy:AddAbility(abilityName)
  local ability = dummy:FindAbilityByName(abilityName)
  ability:SetLevel(1)
  return dummy
end

function removeUnit(v)
  if v.needsToBeRemoved == true then
    playCollisionEffect(v)
    RubickBrawlGameMode:CreateTimer('transportEffect', {
	  useGameTime=true,
      endTime = GameRules:GetGameTime() + 1.0,
      callback = function(rubickbrawl, args)
        FindClearSpaceForUnit(v.unit, Vector(4900,4900,0), true)
      end})
    v.unit:SetPhysicsVelocity(Vector(0,0,0))
    v.unit:ForceKill(true)
    for i, v2 in ipairs(projectilesOnMap) do
      if v.id == v2.id then
        table.remove(projectilesOnMap, i)
      end
    end
    v.unit:OnPhysicsFrame(nil)

  end
end

function checkSpellSpellCollision(v)
  if v.spell == 'rubickbrawl_fireball' then ThisSpellCanCollideWith = SpellsWhichFireballCanCollideWith end
  if v.spell == 'rubickbrawl_lightning' then ThisSpellCanCollideWith = SpellsWhichLightningCanCollideWith end

  for i2,v2 in ipairs(ThisSpellCanCollideWith) do
    for i3, v3 in ipairs(projectilesOnMap) do
      -- make sure we're not talking about the same unit
      if v.unit ~= v3.unit then
        -- if there's a projectile on the map which this spell can collide with
        if v3.spell == v2 then
          -- if they're not on the same team, check for collision.
          if v.team ~= v3.team then
            if circleCircleCollision(v.unit:GetAbsOrigin(), v3.unit:GetAbsOrigin(), v.radius, v3.radius) then
              print('spellspell coll')
              v.collidedWithSpell = true
              v3.collidedWithSpell = true
              v.needsToBeRemoved = true
              v3.needsToBeRemoved = true
            end

            -- fb+light collision
          elseif (v.spell == 'rubickbrawl_fireball' and v3.spell == 'rubickbrawl_lightning') and (v3.caster == v.caster and v.currentDistance < v3.distance) then
            if circleCircleCollision(v.unit:GetAbsOrigin(), v3.unit:GetAbsOrigin(), v.radius, v3.radius) then
              print('fblight coll')
              lightningMissed({caster = v.caster, target_points = {[1] = v.unit:GetAbsOrigin()}})
              v.didNotCollide = false
              v3.didNotCollide = false
              v.fbLightColl = true
              v3.fbLightColl = true
              fbLightCollision(v, v3)
            end
          end
        end
      end
    end
  end
end

function checkSpellHeroCollision(v)
  if v.canCollideWithEnemyHeroes then
    -- check if there's a spell which can collide with an enemy hero
    RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
      -- check if player and spell are on different teams, and the player isn't dead
      if v.team ~= player.hero:GetTeam() and player.hero:IsAlive() then
        if v.needsToBeRemoved == false then
		--print('v.needsToBeRemoved==false')
          if circleCircleCollision(player.hero:GetAbsOrigin(), v.unit:GetAbsOrigin(), player.hero:GetHullRadius(), v.radius) then
            v.collidedWithHero = true
            print('spell-hero coll')
            v.target = player.hero
            local abil = v.caster:FindAbilityByName(v.spell)
            player.hero:ModifyHealth (player.hero:GetHealth()-(spellDamages[v.spell .. '_damage'])[abil:GetLevel()], v.caster, false, 0)
            if v.kbAtAngle == true then
              makeProjectile(v.caster, {[1] = player.hero}, v.caster:FindAbilityByName(v.spell), KnockbackValues[v.spell], v.unit:GetAbsOrigin())
            else
              makeProjectile(v.caster, {[1] = player.hero}, v.caster:FindAbilityByName(v.spell), KnockbackValues[v.spell], v.caster:GetAbsOrigin())
            end

            --  ParticleManager:CreateParticle('clinkz_strafe_fire', PATTACH_ABSORIGIN_FOLLOW, v.unit)
            v.needsToBeRemoved = true
          end
        end
        if v.needsToBeRemoved == true then return end
      end
    end)
  end
end

function checkDistance(v)
  -- check if projectile went over the max distance
  local currentDistance = distance(v.startPos, v.unit:GetAbsOrigin())
  v.currentDistance = currentDistance
  if v.fbLightColl then return end
  if currentDistance >= v.distance then
    v.didNotCollide = true
    v.needsToBeRemoved = true
  end
end

function playFireball(fb)
  checkDistance(fb)
  checkSpellSpellCollision(fb)
  checkSpellHeroCollision(fb)
  if fb.needsToBeRemoved then
    removeUnit(fb)
  end
end

--[[function checkLightningHeroCollision(light)
 RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if (player.hero ~= light.caster) and (light.team ~= player.nTeam) then
	--player to test
	local p1c = light.caster:GetAbsOrigin()
    local p1={c=Vector(p1c.x,p1c.y,0), v = Vector(player.currentVelocity.x,player.currentVelocity.y,0), m=2, r=light.caster:GetHullRadius()}
	--light projectile
	local p2c = light.unit:GetAbsOrigin()
    local p2={c=Vector(p2c.x,p2c.y,0), v = Vector(light.vel.x,light.vel.y,0), m=2, r=LIGHTNING_RADIUS}
    local t = timeToCollision(p1,p2)
	print('t till lightning collide with hero: '.. t)
	if distance(light.unit:GetAbsOrigin()+(t)*light.vel) <= LIGHTNING_RANGE then
		playCollisionEffect(light)
    end
   end
  end)
end]]

function playLightning(light)
  checkDistance(light)
  checkSpellSpellCollision(light)
  checkSpellHeroCollision(light)
  --checkLightningHeroCollision(light)
  if light.needsToBeRemoved then
    removeUnit(light)
  end
end

function spawnFBUnit(keys)
  local fireballUnit = keys.target
  local direction = (fbPoint-fireballUnit:GetAbsOrigin()):Normalized()
  local entindex = keys.entindex
  --[[ add the effect ability
  fireballUnit:AddAbility('rubickbrawl_fireball_4')
  local fbSpawner = fireballUnit:FindAbilityByName('rubickbrawl_fireball_4')
  fbSpawner:SetLevel(1)]]

  local fireball = {spell = 'rubickbrawl_fireball', unit = fireballUnit, radius = FIREBALL_RADIUS, caster = keys.caster, team = keys.caster:GetTeam(), needsToBeRemoved = false, point = fbPoint, 
    vel = FIREBALL_SPEED*direction, startPos = fireballUnit:GetAbsOrigin(), distance = FIREBALL_RANGE, direction = direction, ticks=1, kbAtAngle = true, 
    canCollideWithEnemyHeroes = true, currentDistance = 0, id = entindex}
  ParticleManager:CreateParticle('brewmaster_fire_ambient', PATTACH_ABSORIGIN_FOLLOW, fireballUnit)
  Physics:Unit(fireballUnit)
  fireballUnit:AddPhysicsVelocity(FIREBALL_SPEED*direction)
  fireballUnit:SetPhysicsFriction(0)
  table.insert(projectilesOnMap, fireball)
  fireballUnit:OnPhysicsFrame (function(unit)
    playFireball(fireball)
  end)
  -- print('getdummyfb keys: ') PrintTable(keys)
end

function spawnLightUnit( keys )
  local lightUnit = keys.target
  local entindex = keys.entindex
  local direction = (lightPoint-lightUnit:GetAbsOrigin()):Normalized()
  local lightning = {spell = 'rubickbrawl_lightning', unit = lightUnit, radius = LIGHTNING_RADIUS, caster = keys.caster, team = keys.caster:GetTeam(), needsToBeRemoved = false, point = lightPoint, 
    vel = LIGHTNING_SPEED*direction, startPos = lightUnit:GetAbsOrigin(), distance = LIGHTNING_RANGE, direction = direction, ticks=1, kbAtAngle = false,
    canCollideWithEnemyHeroes = true, currentDistance = 0, id = entindex}
  Physics:Unit(lightUnit)
  lightUnit:AddPhysicsVelocity(LIGHTNING_SPEED*direction)
  lightUnit:SetPhysicsFriction(0)
  table.insert(projectilesOnMap, lightning)
  lightUnit:OnPhysicsFrame (function(unit)
    playLightning(lightning)
	checkLightningHeroCollision(lightning)
  end)
end

function getFBPoint(keys)
  fbPoint = keys.target_points[1]
  print('got fb point')
end

function getLightningPoint( keys )
  lightPoint = keys.target_points[1]
  -- use time prediction collision to see if it'll collide with a hero within 0.4 secs?
  
end

function shield(keys)
  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if plyID == keys.caster:GetPlayerID() then
      player.isUsingShield = true
    end
  end)
end

function testFunc(keys)
  print('i was called')
  PrintTable(keys)
end

function lightningAbility(keys)

  if keys.target ~= keys.caster then
    --  RubickBrawlGameMode.vPlayers[keys.caster:GetPlayerID()].lightningTarget = tru
    local casterDummy = CreateUnitByName("npc_dummy_unit", keys.caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
    --local targetDummy = CreateUnitByName( "npc_dummy_unit", keys.target:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS )
    casterDummy:AddAbility('rubickbrawl_lightning_effect')
    local lightningEffect = casterDummy:FindAbilityByName('rubickbrawl_lightning_effect')
    lightningEffect:SetLevel(1)
    casterDummy:CastAbilityOnTarget(keys.target, lightningEffect, 0)
    casterDummy:ForceKill(true)
  end  
end

function lightningMissed(keys)
  print('lightmissed')
  local casterDummy = CreateUnitByName("npc_dummy_unit", keys.caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
  local targetDummy = CreateUnitByName( "npc_dummy_unit", keys.target_points[1], false, nil, nil, DOTA_TEAM_BADGUYS )
  casterDummy:AddAbility('rubickbrawl_lightning_effect')
  local lightningEffect = casterDummy:FindAbilityByName('rubickbrawl_lightning_effect')
  lightningEffect:SetLevel(1)
  casterDummy:CastAbilityOnTarget(targetDummy, lightningEffect, 0)
  -- ParticleManager:CreateParticle('brewmaster_storm_ambient', PATTACH_ABSORIGIN_FOLLOW, targetDummy)
  casterDummy:ForceKill(true)
  targetDummy:ForceKill(true)

end

function fbLightCollision(v, v3)
  local allInRange = Entities:FindAllByClassnameWithin( 'npc_dota_hero_*', v.unit:GetAbsOrigin(), fblight_radius)
  local targets = {}
  local damage = 0

  -- get the damage to apply
  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if player.hero == v.caster then
      player.fbLight = true
      local abil = player.hero:FindAbilityByName('rubickbrawl_fireball')
      local abil2 = player.hero:FindAbilityByName('rubickbrawl_lightning')
      damage = 3/4 * (spellDamages['rubickbrawl_fireball_damage'][abil:GetLevel()] + spellDamages['rubickbrawl_lightning_damage'][abil2:GetLevel()])
    end
  end)

  -- now get the enemy heroes
  for i, v4 in ipairs(allInRange) do
    if v4:GetTeam() ~= v.team then
      table.insert(targets,v4)
      v4:ModifyHealth (v4:GetHealth()-damage, v.caster, false, 0)
    end
  end

  -- play the effect
  local dummy = CreateUnitByName("npc_dummy_unit", v.unit:GetAbsOrigin(), true, nil, nil, v.team)
  local dummy = getAbilityReady(dummy,'rubickbrawl_fblight')
  dummy:CastAbilityOnPosition(dummy:GetAbsOrigin(), dummy:FindAbilityByName('rubickbrawl_fblight'), 0)
  dummy:ForceKill(true)

  makeProjectile(v.caster, targets, v.caster:FindAbilityByName(v.spell), PROJECTILE_SPEED, v.unit:GetAbsOrigin())

  print('fblight targets:') PrintTable(allTargets)
  v.needsToBeRemoved = true
  v3.needsToBeRemoved = true
end

function checkIfUsedWW(player)
  if player.hero:IsInvisible() then
    if player.usedWW == false then
      player.usedWW = true
      player.hero:SetBaseMoveSpeed(522)
    end
  elseif player.usedWW then
    player.usedWW = false
    player.hero:SetBaseMoveSpeed(300)
  end
end

function scourgeAbility(keys)
  local caster = keys.caster
  --keys.ability:StartCooldown( 6.0 )
  --if (caster:GetHealth() <= 100) then
  --  caster:SetHealth(10)
  caster:SetHealth(caster:GetHealth()+100.0)
  
  local targets = {}
  for i, v in ipairs(keys.target_entities) do
    if v:GetClassname() == 'npc_dota_hero_rubick' then
      table.insert(targets,v)
    end
  end
  if #targets >= 3 then
    local msg = {
      message = "HATTRICK",
      duration = 0.9
    }
    FireGameEvent("show_center_message",msg)
  end
  makeProjectile(caster, targets, keys.ability, PROJECTILE_SPEED, keys.caster:GetAbsOrigin())
end

function endCooldown(keys)
  keys.ability:EndCooldown()
end

function distance(startPos, endPos)
  return (startPos-endPos):Length()
end

function meteor(keys)
  local dummy = CreateUnitByName("npc_dummy_unit", keys.caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
  dummy:AddAbility('rubickbrawl_meteor2')
  local abil = dummy:FindAbilityByName('rubickbrawl_meteor2')
  abil:SetLevel(1)
  dummy:CastAbilityOnPosition(keys.target_points[1], abil, 0)
  dummy:ForceKill(true)
  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if player.hero == keys.caster then
      abil = player.hero:FindAbilityByName('rubickbrawl_meteor')
      local damage = spellDamages['rubickbrawl_meteor_damage'][abil:GetLevel()]

      RubickBrawlGameMode:CreateTimer('meteor' .. plyID, {
		useGameTime = true,
        endTime = GameRules:GetGameTime() + 1.2,
        callback = function(rubickbrawl, args)
          local allInRange = Entities:FindAllByClassnameWithin( 'npc_dota_hero_*', keys.target_points[1], METEOR_RADIUS)
          local targets = {}

          -- now get the enemy heroes
          for i, v in ipairs(allInRange) do
            if v:GetTeam() ~= player.nTeam then
              table.insert(targets,v)
              v:ModifyHealth (v:GetHealth()-damage, player.hero, false, 0)
            end
          end
          makeProjectile(keys.caster, targets, keys.caster:FindAbilityByName('rubickbrawl_meteor'), PROJECTILE_SPEED, keys.target_points[1])
        end})
    end
  end)
end

function thrust(keys)
  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if keys.caster == player.hero then
      player.isUsingThrust = true
      player.thrustDistance = distance(player.hero:GetAbsOrigin(), keys.target_points[1])
      player.thrustStartPos = player.hero:GetAbsOrigin()
      player.thrustDirection = (keys.target_points[1] - player.thrustStartPos):Normalized()
      player.thrustDirection.z = 0
      player.hero:SetForwardVector(player.thrustDirection)
      player.hero:SetPhysicsVelocity(base_vel)
      player.hero:SetPhysicsFriction(0)

      -- if player.thrustDistance > THRUST_RANGE then player.thrustDistance = THRUST_RANGE end


      RubickBrawlGameMode:CreateTimer('thrust' .. plyID, {
		useGameTime = true,
        endTime = GameRules:GetGameTime() + THRUST_DURATION,
        callback = function(rubickbrawl, args)
          if player.isUsingThrust == true then
            player.isUsingThrust = false
            player.hero:SetPhysicsVelocity(base_vel)
            player.hero:SetPhysicsFriction(base_friction)
            -- player.hero:PreventDI (false)
          end
        end})

      makePropeller(player.hero, {[1] = player.hero}, player.hero:FindAbilityByName('rubickbrawl_thrust'), 4000, (keys.target_points[1]-player.hero:GetAbsOrigin()))
    end
  end)
end

function thrustCase(thruster, victim)

  thrusterCenter = thruster.hero:GetAbsOrigin()
  victimCenter = victim.hero:GetAbsOrigin()
  victimToThruster = (thrusterCenter-victimCenter):Normalized()
  thrusterToVictim = (victimCenter-thrusterCenter):Normalized()

  --normalPlayer.hero:AddPhysicsVelocity(direction*KnockbackValues['rubickbrawl_thrust']*2/3 + direction*normalPlayer.damageTaken)

  --[[ BOTH USED THRUST
  if (victim.isUsingThrust and victim.hero:GetTeam() ~= thruster.hero:GetTeam()) then

    if thruster.isUsingWW == false then
      victim.hero:AddPhysicsVelocity(thrusterToVictim*(KnockbackValues[rubickbrawl_thrust] + victim.damageTaken))
    end

    if victim.isUsingWW == false then
      thruster.hero:AddPhysicsVelocity(victimToThruster*(KnockbackValues[rubickbrawl_thrust] + thruster.damageTaken))
    end

    -- thruster hits the victim
    local abil = thruster.hero:FindAbilityByName('rubickbrawl_thrust')
    thruster.hero:SetPhysicsFriction(base_friction)
    victim.lastHitByPlayer = thruster.hero
    playThrustEffect(victim.hero, thruster.hero)
    victim.hero:ModifyHealth (victim.hero:GetHealth()-spellDamages['rubickbrawl_thrust_damage'][abil:GetLevel()], thruster.hero, false, 0)

    --victim hits the thruster
    local abil2 = thruster.hero:FindAbilityByName('rubickbrawl_thrust')
    victim.hero:SetPhysicsFriction(base_friction)
    thruster.lastHitByPlayer = victim.hero
    playThrustEffect(thruster.hero, victim.hero)
    thruster.hero:ModifyHealth (thruster.hero:GetHealth()-spellDamages['rubickbrawl_thrust_damage'][abil2:GetLevel()], thruster.hero, false, 0)

    local msg = {
      message = "WHIRLWIND",
      duration = 0.9
    }
    FireGameEvent("show_center_message",msg)

    victim.isUsingThrust = false
    thruster.isUsingThrust = false
    return
  end]]

  -- ONE USED THRUST
  if (victim.hero:GetTeam() ~= thruster.hero:GetTeam()) then
    local abil = thruster.hero:FindAbilityByName('rubickbrawl_thrust')
    victim.hero:ModifyHealth (victim.hero:GetHealth()-spellDamages['rubickbrawl_thrust_damage'][abil:GetLevel()], thruster.hero, false, 0)
    playThrustEffect(victim.hero, thruster.hero)

    -- make the thruster stop
    thruster.hero:SetPhysicsVelocity(base_vel)

    -- avoid thrust + ww abuse
    if thruster.isUsingWW == false then
      victim.hero:AddPhysicsVelocity(thrusterToVictim*(KnockbackValues['rubickbrawl_thrust'] + victim.damageTaken))
    end

    thruster.hero:SetPhysicsFriction(base_friction)
    victim.lastHitByPlayer = thruster.hero
    thruster.isUsingThrust = false
  end

  --VICTIM IS ALLY
  if thruster.hero:GetTeam() == victim.hero:GetTeam() then
	thruster.hero:AddNewModifier( thruster.hero, nil , "modifier_phased", {})
		RubickBrawlGameMode:CreateTimer('thrustPhased', {
		useGameTime=true,
        endTime = GameRules:GetGameTime() + 1.0,
        callback = function(rubickbrawl, args)
          if thruster.hero:HasModifier("modifier_phased") then
            thruster.hero:RemoveModifierByName("modifier_phased")
          end
        end})
	end
 end

function updateThrust(player)
  if player.isUsingThrust then
    player.hero:SetForwardVector(player.thrustDirection)
    if distance(player.thrustStartPos, player.hero:GetAbsOrigin()) > player.thrustDistance then
      player.hero:SetPhysicsVelocity(base_vel)
      player.hero:SetPhysicsFriction(base_friction)
      player.isUsingThrust = false
    end
  end
end

--function playWWEffect(normalPlayer.hero, WWUser)

--end

function twoDVectorNormal(x,y)
  local magnitude = math.sqrt(x*x + y*y)
  local xi = x/magnitude
  local yi = y/magnitude
  --print('xi: ' .. xi .. 'yi: ' .. yi)
  return xi, yi
end

-- what a bitch
function teleport(keys)
  local abil = keys.caster:FindAbilityByName('rubickbrawl_teleport')
  local dummy = CreateUnitByName("npc_dummy_unit", keys.caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
  dummy:AddAbility('rubickbrawl_teleport_effect')
  local abil = dummy:FindAbilityByName('rubickbrawl_teleport_effect')
  abil:SetLevel(1)
  
    -- give the teleport user phased for a bit so he doesn't get stuck. and give him increased friction for a bit
  keys.caster:AddNewModifier( keys.caster, nil , "modifier_phased", {})
  keys.caster:SetPhysicsFriction(base_friction+.02)
  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if player.hero == keys.caster then
		RubickBrawlGameMode:CreateTimer('teleportPhased' .. plyID, {
		useGameTime=true,
        endTime = GameRules:GetGameTime() + 1.0,
        callback = function(rubickbrawl, args)
          if player.hero:HasModifier("modifier_phased") then
            player.hero:RemoveModifierByName("modifier_phased")
          end
		  keys.caster:SetPhysicsFriction(base_friction)
        end})
	end
  end)
  
  if distance(keys.caster:GetAbsOrigin(), keys.target_points[1]) <= teleport_ranges[abil:GetLevel()] then
    keys.caster:SetAbsOrigin(keys.target_points[1])
    dummy:CastAbilityOnPosition(keys.target_points[1], abil, 0)
    dummy:ForceKill(true)
  else
    --print('target vector: ' .. 'x: ' .. keys.target_points[1].x .. 'y: ' .. keys.target_points[1].y .. 'z: ' .. keys.target_points[1].z)
    local x = keys.target_points[1].x-keys.caster:GetAbsOrigin().x
    local y = keys.target_points[1].y-keys.caster:GetAbsOrigin().y
    local xi,yi = twoDVectorNormal(x,y)
    local newPosX = xi*teleport_ranges[abil:GetLevel()]
    local newPosY = yi*teleport_ranges[abil:GetLevel()]
    local newPos = keys.caster:GetAbsOrigin() + Vector(newPosX, newPosY,0)
    dummy:CastAbilityOnPosition(newPos, abil, 0)
    keys.caster:SetAbsOrigin(newPos)
    keys.caster:SetPhysicsVelocity(keys.caster:GetPhysicsVelocity()*.8)
    dummy:ForceKill(true)
  end

end

function windwalk(keys)
  print('windwalk called')
  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if player.hero == keys.caster then
      player.isUsingWW = true
      --  player.wwStartTime = Time()
      if player.isUsingWW then
        player.hero:AddNewModifier( player.hero, nil , "modifier_invisible", {})
        player.hero:SetBaseMoveSpeed(522)
      end
      RubickBrawlGameMode:CreateTimer('ww' .. plyID, {
		useGameTime=true,
        endTime = GameRules:GetGameTime() + 2.6,
        callback = function(rubickbrawl, args)
          player.isUsingWW = false
          if player.hero:HasModifier("modifier_invisible") then
            player.hero:RemoveModifierByName("modifier_invisible")
          end
          player.hero:SetBaseMoveSpeed(300)
        end})
    end
  end)
end

function WWCase(WWUser, normalPlayer, bothUsingWW, direction)
  print('wwcase called')

  if WWUser.hero:GetTeam() ~= normalPlayer.hero:GetTeam() and (normalPlayer.hero ~= WWUser.hero) then
    local abil = WWUser.hero:FindAbilityByName('rubickbrawl_windwalk')
    normalPlayer.hero:ModifyHealth (normalPlayer.hero:GetHealth()-spellDamages['rubickbrawl_windwalk_damage'][abil:GetLevel()], WWUser.hero, false, 0)
    --playWWEffect(normalPlayer.hero, WWUser.hero)
    normalPlayer.hero:AddPhysicsVelocity(direction*KnockbackValues['rubickbrawl_windwalk'] + direction*normalPlayer.damageTaken)
    normalPlayer.lastHitByPlayer = WWUser.hero
    WWUser.hero:RemoveModifierByName("modifier_invisible")
    WWUser.hero:SetBaseMoveSpeed(300)
    print('im setting it to false')
    WWUser.isUsingWW = false

  end

end

function playThrustEffect(target, caster)
  local casterDummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
  --local targetDummy = CreateUnitByName( "npc_dummy_unit", keys.target:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS )
  casterDummy:AddAbility('rubickbrawl_thrust_effect')
  local thrustEffect = casterDummy:FindAbilityByName('rubickbrawl_thrust_effect')
  thrustEffect:SetLevel(1)
  --casterDummy:CastAbilityOnTarget(target, thrustEffect, 0)
  casterDummy:CastAbilityImmediately(thrustEffect, 0)
  casterDummy:ForceKill(true)
end

function projectileHeroCollision(caster, instance)

  local casterID = -2
  local targetID = -4
  local casterUsingThrust = false

  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if player.hero == caster then casterID = plyID end
    if player.hero == instance.target then targetID = plyID end
    if player.isUsingThrust == true then casterUsingThrust = true end
  end)

  -- sometimes it will treat the caster as a target
  if casterID == targetID and casterUsingThrust == false then return end

  local velocity = instance.velocity

  local finalVelXFromCollision = (MASS_OF_PROJECTILE/(MASS_OF_PROJECTILE + MASS_OF_RUBICKBRAWL))*velocity.x
  local finalVelYFromCollision = (MASS_OF_PROJECTILE/(MASS_OF_PROJECTILE + MASS_OF_RUBICKBRAWL))*velocity.y
  local vKnockback = Vector(finalVelXFromCollision, finalVelYFromCollision, 0)
  local direction = vKnockback:Normalized()

  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if plyID == targetID then
      -- don't let thrust propell you more if you have more damage taken.
      if instance.abilityName == 'rubickbrawl_thrust' then
        player.hero:AddPhysicsVelocity(vKnockback)
      else
        player.hero:AddPhysicsVelocity(vKnockback + direction*player.damageTaken*1.5)
        -- player.hero:AddPhysicsVelocity(vKnockback)
      end
    end
  end)

end

function makeProjectile(caster, targets, ability, moveSpeed, hitPoint)
  local instances = {}

  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if plyID == caster:GetPlayerID() then
      player.projectiles[ability:GetAbilityName()] = instances
    end
  end)

  local points = {}
  local diffs = {}
  local vVelocities = {}
  local pos = hitPoint
  for i, v in ipairs(targets) do
    instances[i] = {}
    instances[i].target = v
    RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
      if v == player.hero then
        player.lastHitByPlayer = caster
        player.lastHitByAbility = ability
      end
    end)
    instances[i].targetLocation = v:GetAbsOrigin()
    diffs[i] = instances[i].targetLocation - pos
    vVelocities[i] = diffs[i]:Normalized() * moveSpeed
    instances[i].velocity = Vector(vVelocities[i].x, vVelocities[i].y, 0)
    -- PrintTable(instances[i])
    projectileHeroCollision(caster, instances[i])
  end
end

function makePropeller(caster, targets, ability, moveSpeed, hitVect)
  local instances = {}

  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if plyID == caster:GetPlayerID() then
      player.projectiles[ability:GetAbilityName()] = instances
    end
  end)

  local points = {}
  local diffs = {}
  local vVelocities = {}
  -- if ability:GetAbilityName() == 'rubickbrawl_fireball' then pos = fbPoint end
  -- print('targets from makeProjectile:') PrintTable(targets)

  -- i refers to the plyID of a target
  for i, v in ipairs(targets) do
    instances[i] = {}
    instances[i].target = v
    instances[i].abilityName = ability:GetAbilityName()
    --[[RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if v == player.hero then
    player.lastHitByPlayer = caster
    player.lastHitByAbility = ability
    end
    end)]]
    vVelocities[i] = hitVect:Normalized() * moveSpeed
    instances[i].velocity = Vector(vVelocities[i].x, vVelocities[i].y, 0)
    -- PrintTable(instances[i])
    projectileHeroCollision(caster, instances[i])
  end
end

function checkBaseVelocity(player)
  local baseX = player.hero:GetForwardVector().x*player.moveSpeed
  local baseY = player.hero:GetForwardVector().y*player.moveSpeed
  -- if the player isn't sending move commands, and you've added the base velocity to it, then subtract the base velocity.
  if player.hero:IsIdle() and player.baseVelocitySet then
    player.currentVelocity = player.currentVelocity - Vector(baseX, baseY, 0)
    -- player.hero:SetPhysicsVelocity (player.hero:GetPhysicsVelocity() - Vector(baseX, baseY, 0))
    player.baseVelocitySet = false
  end

  -- if the player is sending move commands, add its base velocity if u haven't already.
  if player.hero:IsIdle() == false and player.baseVelocitySet == false then
    player.currentVelocity = player.currentVelocity + Vector(baseX, baseY, 0)
    -- player.hero:SetPhysicsVelocity (player.hero:GetPhysicsVelocity() + Vector(baseX, baseY, 0))
    player.baseVelocitySet = true
  end
end

--p1={c=player.hero:GetAbsOrigin(), v = player.hero:GetPhysicsVelocity(), m=2, r=player.hero:GetHullRadius()}
--p2={c=player2.hero:GetAbsOrigin(), v = player2.hero:GetPhysicsVelocity(), m=2, r=player2.hero:GetHullRadius()}

function DotProduct(v1,v2)
  return (v1.x*v2.x)+(v1.y*v2.y)
end

function timeToCollision(p1,p2)
  local W = p2.v-p1.v
  local D = p2.c-p1.c
  local A = DotProduct(W,W)
  local B = 2*DotProduct(D,W)
  local C = DotProduct(D,D)-(p1.r+p2.r)*(p1.r+p2.r)
  local d = B*B-(4*A*C)
  if d>=0 then
    local t1=(-B-math.sqrt(d))/(2*A)
    if t1<0 then t1=2 end
    local t2=(-B+math.sqrt(d))/(2*A)
    if t2<0 then t2=2 end
    local m = math.min(t1,t2)
    --if ((-0.02<=m) and (m<=1.02)) then
    return m
      --end
  end
  return 2
end

function interfere(p1,p2)
  if ((p1Origin.x - p2Origin.x)*(p1Origin.x - p2Origin.x) + (p1Origin.y - p2Origin.y)*(p1Origin.y - p2Origin.y)) <= (p1Radius+p2Radius)*(p1Radius+p2Radius) then
    return true
  else
    return false
  end
end

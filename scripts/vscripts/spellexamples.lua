--Spell Examples in Dota 2 RubickBrawls:

--[[ Fireball example:
The parameter for this function is based on the "rubickbrawl_fireball" ability in scripts\npc\npc_abilities_custom.txt
This function's main purpose is to communicate with the key values in npc_abilities_custom.txt]]
function spawnFBUnit(keys)
  local fireballUnit = keys.target
  local direction = (fbPoint-fireballUnit:GetAbsOrigin()):Normalized()
  local entindex = keys.entindex

  -- Every spell should have this completely filled out. Add more info if you need it.
  local fireball = {spell = 'rubickbrawl_fireball', unit = fireballUnit, radius = FIREBALL_RADIUS, caster = keys.caster, team = keys.caster:GetTeam(), needsToBeRemoved = false, point = fbPoint, 
    vel = FIREBALL_SPEED*direction, startPos = fireballUnit:GetAbsOrigin(), distance = FIREBALL_RANGE, direction = direction, ticks=1, kbAtAngle = true, 
    canCollideWithEnemyHeroes = true, currentDistance = 0, id = entindex}
    
  ParticleManager:CreateParticle('brewmaster_fire_ambient', PATTACH_ABSORIGIN_FOLLOW, fireballUnit)
  -- Physics functions. See this API: https://github.com/bmddota/barebones/blob/master/PhysicsReadme.txt
  Physics:Unit(fireballUnit)
  fireballUnit:AddPhysicsVelocity(FIREBALL_SPEED*direction)
  fireballUnit:SetPhysicsFriction(0)
  
  -- projectilesOnMap is a table which holds all the unit-projectiles which haven't died.
  table.insert(projectilesOnMap, fireball)
  
  -- This is the spell's think function basically.
  fireballUnit:OnPhysicsFrame (function(unit)
    playFireball(fireball)
  end)
end

function playFireball(fb)
  -- What do you want to happen if this spell goes over its maximum distance?
  checkDistance(fb)
  -- What do you want to happen if this spell collides with another spell?
  checkSpellSpellCollision(fb)
  -- What do you want to happen if this spell collides with a hero?
  checkSpellHeroCollision(fb)
  
  if fb.needsToBeRemoved then
    removeUnit(fb)
  end
end

-- When you write the functions checkSpellSpellCollision(spell), checkSpellHeroCollision(spell), etc it's fine if you just use psuedocode















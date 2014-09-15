-- constants file

-- gold costs for spells
spellCosts = {
  ['rubickbrawl_fireball_cost'] = {[2]=3, [3]=4, [4]=5, [5]=6, [6]=7, [7]=8, [8]=9, [9]=10, [10]=11},
  SCOURGE = {[2]=0, [3]=0, [4]=0, [5]=0, [6]=0},
  ['rubickbrawl_lightning_cost'] = {[1]=7, [2]=8, [3]=9, [4]=10, [5]=11, [6]=12},
  ['rubickbrawl_boomerang_cost'] = {[1]=6, [2]=7, [3]=8, [4]=9, [5]=10, [6]=11, [7]=12},
  ['rubickbrawl_homing_cost'] = {[2]=8, [3]=9, [4]=10, [5]=11, [6]=12},
  PHANTASM = {[2]=7, [3]=8, [4]=9, [5]=10, [6]=11, [7]=12},
  ['rubickbrawl_teleport_cost'] = {[1]=5, [2]=6, [3]=7, [4]=8, [5]=9, [6]=10, [7]=11},
  ['rubickbrawl_thrust_cost'] = {[1]=5, [2]=6, [3]=7, [4]=8, [5]=9, [6]=10, [7]=11},
  SWAP = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  DRAIN = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  WEAKEN = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  FIRESPRAY = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  CLUSTER = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  BOUNCER = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  RECHARGE = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  ['rubickbrawl_meteor_cost'] = {[1]=5, [2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  ['rubickbrawl_magma_cost'] = {[1]=5, [2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  ['rubickbrawl_windwalk_cost'] = {[1]=5, [2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  INVISIBILITY = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  SPLITTERTARGET = {[2]=7, [3]=8, [4]=9, [5]=10, [6]=11},
  SPLITTERAREA = {[2]=7, [3]=8, [4]=9, [5]=10, [6]=11},
  RUSH = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  SHIELD = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  TIMESHIFT = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  MIRROR = {[2]=4, [3]=5, [4]=6, [5]=7, [6]=8},
  LINK = {[2]=4, [3]=5, [4]=6, [5]=7, [6]=8},
  ENTANGLE = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  SILENCE = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  FORCEFIELD = {[2]=7, [3]=8, [4]=9, [5]=10},
}

spellDamages = {
  --//70/75/80/85/90/95/100/105/110
  ['rubickbrawl_fireball_damage'] = {[1]=70, [2]=75, [3]=80, [4]=85, [5]=90, [6]=95, [7]=100, [8]=105, [9]=110, [10]=115},
  --SCOURGE = {[2]=0, [3]=0, [4]=0, [5]=0, [6]=0},
  ['rubickbrawl_lightning_damage'] = {[1]=70, [2]=78, [3]=86, [4]=94, [5]=102, [6]=110},
  ['rubickbrawl_boomerang_damage'] = {[2]=7, [3]=8, [4]=9, [5]=10, [6]=11, [7]=12},
  ['rubickbrawl_homing_damage'] = {[2]=8, [3]=9, [4]=10, [5]=11, [6]=12},
  PHANTASM = {[2]=7, [3]=8, [4]=9, [5]=10, [6]=11, [7]=12},
  --	['rubickbrawl_teleport_damage'] = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10, [7]=11},
  ['rubickbrawl_thrust_damage'] = {[1]=54, [2]=58, [3]=62, [4]=66, [5]=70, [6]=74, [7]=78},
  SWAP = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  DRAIN = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  WEAKEN = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  FIRESPRAY = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  CLUSTER = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  BOUNCER = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  RECHARGE = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  ['rubickbrawl_meteor_damage'] = {[1]= 70,[2]=90, [3]=110, [4]=130, [5]=150, [6]=170},
  --110 50-120 60-130 70-140 80-150 90-160
  --225 240 255 269 282 294
  ['rubickbrawl_magma_damage'] = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  ['rubickbrawl_windwalk_damage'] = {[1]=54,[2]=60, [3]=66, [4]=72, [5]=78, [6]=84},
  INVISIBILITY = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  SPLITTERTARGET = {[2]=7, [3]=8, [4]=9, [5]=10, [6]=11},
  SPLITTERAREA = {[2]=7, [3]=8, [4]=9, [5]=10, [6]=11},
  RUSH = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  SHIELD = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  TIMESHIFT = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  MIRROR = {[2]=4, [3]=5, [4]=6, [5]=7, [6]=8},
  LINK = {[2]=4, [3]=5, [4]=6, [5]=7, [6]=8},
  ENTANGLE = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  SILENCE = {[2]=6, [3]=7, [4]=8, [5]=9, [6]=10},
  FORCEFIELD = {[2]=7, [3]=8, [4]=9, [5]=10},
}


-- velocity
PROJECTILE_SPEED = 2600.0
bleeding_threshold_vel = 1000
base_vel = Vector(10,11,0)
base_friction = .05
low_vel_cap=50
min_v=300

SpellsWhichCanCollideWithEnemyHeroes = {[1] = 'rubickbrawl_fireball', [2] = 'rubickbrawl_lightning'}

KnockbackValues = {
  ['rubickbrawl_fireball'] = PROJECTILE_SPEED,
  ['rubickbrawl_lightning'] = PROJECTILE_SPEED+100.0,
  ['rubickbrawl_thrust'] = PROJECTILE_SPEED*1/2,
  ['rubickbrawl_windwalk'] = PROJECTILE_SPEED*1/2,
}

--fireball
FIREBALL_RANGE = 1300
FIREBALL_RADIUS = 70
FIREBALL_SPEED = 1400
SpellsWhichFireballCanCollideWith = {[1] = 'rubickbrawl_fireball', [2] = 'rubickbrawl_lightning'}

--lightning
LIGHTNING_RANGE = 670
LIGHTNING_RADIUS = 70
LIGHTNING_SPEED = 4000
SpellsWhichLightningCanCollideWith = {[1] = 'rubickbrawl_fireball'}
fblight_radius = 410

METEOR_RADIUS=320

THRUST_RANGE = 1200
EXTRA_THRUST_RADIUS=15
THRUST_DURATION=0.5
-- increased by 200 for each, and increased the difference to 110
teleport_ranges = {[1]=970, [2]=1080, [3]=1190, [4]=1300, [5]=1410, [6]=1520, [7]=1630}





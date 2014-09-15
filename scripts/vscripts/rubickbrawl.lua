print ('[RUBICKBRAWL] rubickbrawl.lua' )

USE_LOBBY=false
DEBUG=false

RUBICKBRAWL_VERSION = "1.2"

ROUNDS_TO_WIN = 6
ROUND_TIME = 3000 
PRE_GAME_TIME = 7
PRE_ROUND_TIME = 8
POST_ROUND_TIME = 2
POST_GAME_TIME = 5

STARTING_GOLD = 0
GOLD_PER_ROUND_LOSER = 10
GOLD_PER_ROUND_WINNER = 10
GOLD_PER_KILL = 0
GOLD_PER_MVP = 0
GOLD_PER_SURVIVE = 0
GOLD_TIME_BONUS_1 = 0
GOLD_TIME_BONUS_2 = 0
GOLD_TIME_BONUS_3 = 0

LEVELS_PER_ROUND_LOSER = 2
LEVELS_PER_ROUND_WINNER = 1
MAX_LEVEL = 50

originalPlatformRadius = 1850
platformRadius = originalPlatformRadius
ORIGINAL_PLATFORM_BOUNDS = 1280
BOUNDING_RECT = 1818
IN_BOUNDS = 6144
Z_VALUE = 7
TIME_WHEN_STUFF_WORKS = 14

GRAVITY = 9.81
MASS_OF_RUBICKBRAWL = 2.0
MASS_OF_PROJECTILE = 2.0
LAVA_DAMAGE = 3.9
THINK_TIME = 0.03

projectilesOnMap = {}
SPELLS = {FIREBALL, SCOURGE, TELEPORT, METEOR, LIGHTNING, BOOMERANG, HOMING, PHANTASM, TELEPORT, THRUST, SWAP, FIRESPRAY, CLUSTER, DRAIN, WEAKEN, BOUNCER, 
  RECHARGE, METEOR, MAGMA, WINDWALK, INVISIBILITY, SPLITTERTARGET, SPLITTERAREA, RUSH, SHIELD, TIMESHIFT, MIRROR, LINK, ENTANGLE, SILENCE, FORCEFIELD}

--nvert = 56

-- stuff to check if person is inside a polygon, see this algorithm: http://stackoverflow.com/questions/217578/point-in-polygon-aka-hit-test
vertx = {[1] = 154, [2] = 219, [3] = 474, [4] = 538, [5] = 666, [6] = 793, [7] = 921, [8] = 1562, [9] = 1562, [10] = 1690, 
  [11] = 1690, [12] = 1754, [13] = 1754, [14] = 1818, [15] = 1818, [16] = 1754, [17] = 1753, [18] = 1690, [19] = 1690, [20] = 1562, [21] = 1562, [22] = 922, 
  [23] = 794, [24] = 666, [25] = 538, [26] = 474, [27] = 218, [28] = 153, [29] = -153, [30] = -218, [31] = -474, [32] = -538, [33] = -666, [34] = -794, 
  [35] = -922, [36] = -1562, [37] = -1562, [38] = -1689, [39] = -1690, [40] = -1754, [41] = -1754, [42] = -1818, [43] = -1818, [44] = -1754, [45] = -1754, [46] = -1690, 
  [47] = -1690, [48] = -1562, [49] = -1562, [50] = -922, [51] = -794, [52] = -666, [53] = -537, [54] = -474, [55] = -218, [56] = -153, [57] = 153}

verty = {[1] = -1817, [2] = -1755, [3] = -1754, [4] = -1690, [5] = -1689, [6] = -1562, [7] = -1561, [8] = -922, [9] = -794, [10] = -666, 
  [11] = -538, [12] = -474, [13] = -218, [14] = -153, [15] = 153, [16] = 218, [17] = 474, [18] = 537, [19] = 666, [20] = 794, [21] = 922, [22] = 1561, 
  [23] = 1562, [24] = 1690, [25] = 1690, [26] = 1754, [27] = 1754, [28] = 1818, [29] = 1818, [30] = 1754, [31] = 1754, [32] = 1689, [33] = 1690, [34] = 1562, 
  [35] = 1561, [36] = 922, [37] = 794, [38] = 666, [39] = 538, [40] = 474, [41] = 217, [42] = 153, [43] = -154, [44] = -218, [45] = -474, [46] = -538, [47] = -666, [48] = -794, 
  [49] = -922, [50] = -1562, [51] = -1562, [52] = -1689, [53] = -1690, [54] = -1754, [55] = -1754, [56] = -1817, [57] = -1817}

bInPreRound = true
firstRound = true
firstLevelLava = false
secondLevelLava = false
thirdLevelLava = false

XP_PER_LEVEL_TABLE = {}

for i=1,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = i * 1000
end

if RubickBrawlGameMode == nil then
  print ( '[RUBICKBRAWL] creating rubickbrawl game mode' )
  RubickBrawlGameMode = {}
  RubickBrawlGameMode.szEntityClassName = "rubickbrawl"
  RubickBrawlGameMode.szNativeClassName = "dota_base_game_mode"
  RubickBrawlGameMode.__index = RubickBrawlGameMode
end

function RubickBrawlGameMode:new( o )
  print ( '[RUBICKBRAWL] RubickBrawlGameMode:new' )
  o = o or {}
  setmetatable( o, RubickBrawlGameMode )
  return o
end

function RubickBrawlGameMode:InitGameMode()
  print('[RUBICKBRAWL] Starting to load RubickBrawl gamemode...')

  -- Setup rules
  GameRules:SetHeroRespawnEnabled( false )
  GameRules:SetUseUniversalShopMode( true )
  --GameRules:SetSameHeroSelectionEnabled( true )
  GameRules:SetHeroSelectionTime( 5.0 )
  GameRules:SetPreGameTime( PRE_ROUND_TIME + PRE_GAME_TIME)
  GameRules:SetPostGameTime( 60.0 )
  GameRules:SetUseBaseGoldBountyOnHeroes(true)
  GameRules:SetGoldPerTick(0)
  print('[RUBICKBRAWL] Rules set')

  InitLogFile( "log/rubickbrawl.txt","")

  -- Hooks
  ListenToGameEvent('entity_killed', Dynamic_Wrap(RubickBrawlGameMode, 'OnEntityKilled'), self)
  print('[RUBICKBRAWL] entity_killed event set')
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(RubickBrawlGameMode, 'AutoAssignPlayer'), self)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(RubickBrawlGameMode, 'CleanupPlayer'), self)
  --ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(RubickBrawlGameMode, 'ShopReplacement'), self)
 -- ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(RubickBrawlGameMode, 'AbilityUpgradeCost'), self)
  ListenToGameEvent('player_say', Dynamic_Wrap(RubickBrawlGameMode, 'PlayerSay'), self)
  -- ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(RubickBrawlGameMode, 'AbilityUsed'), self)

  local function _boundWatConsoleCommand(...)
    return self:_WatConsoleCommand(...)
  end
  Convars:RegisterCommand( "rubickbrawl_wat", _boundWatConsoleCommand, "Report the status of RubickBrawl", 0 )
  print('[RUBICKBRAWL] rubickbrawl_wat set')

  local function _boundSetAbilityConsoleCommand(...)
    return self:_SetAbilityConsoleCommand(...)
  end
  Convars:RegisterCommand( "rubickbrawl_set_ability", _boundSetAbilityConsoleCommand, "Set a hero ability", 0 )
  print('[RUBICKBRAWL] rubickbrawl_set_ability set')

  Convars:RegisterCommand('rubickbrawl_reset_all', function()
    if not Convars:GetCommandClient() or DEBUG then
      self:LoopOverPlayers(function(player, plyID)
        print ( '[RUBICKBRAWL] Resetting player ' .. plyID)
        --PlayerResource:SetGold(plyID, 30000, true)
        player.hero:SetGold(30000, true)
        player.hero:AddExperience(1000, true)


        if player.hero:HasModifier("modifier_stunned") then
          player.hero:RemoveModifierByName("modifier_stunned")
        end

        if player.hero:HasModifier("modifier_invulnerable") then
          player.hero:RemoveModifierByName("modifier_invulnerable")
        end

        for i=0,11 do
          local item = player.hero:GetItemInSlot( i )
          if item ~= nil then
            local name = item:GetAbilityName()
            if string.find(name, "item_rubickbrawl_dash") == nil and string.find(name, "item_simple_shooter") == nil then
              item:Remove()
            end
            --item:SetCurrentCharges(item:GetInitialCharges())
          end
        end
      end)
    end
  end, 'Resets all players.', 0)

  -- Fill server with fake clients
  Convars:RegisterCommand('fake', function()
    -- Check if the server ran it
    if not Convars:GetCommandClient() or DEBUG then
      -- Create fake Players
      SendToServerConsole('dota_create_fake_clients')

      self:CreateTimer('assign_fakes', {
        endTime = Time(),
        callback = function(rubickbrawl, args)
          for i=0, 9 do
            -- Check if this player is a fake one
            if PlayerResource:IsFakeClient(i) then
              -- Grab player instance
              local ply = PlayerResource:GetPlayer(i)
              -- Make sure we actually found a player instance
              if ply then
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
              end
            end
          end
        end})
    end
  end, 'Connects and assigns fake Players.', 0)

  Convars:RegisterCommand('rubickbrawl_test_death', function()
    local cmdPlayer = Convars:GetCommandClient()
    if DEBUG and cmdPlayer ~= nil then
      local playerID = cmdPlayer:GetPlayerID()
      local player = self.vPlayers[playerID]
      for onDeath,scale in pairs(ABILITY_ON_DEATH) do
        local ability = player.hero:FindAbilityByName(onDeath)
        --print('     ' .. onDeath .. ' -- ' .. tostring(ability or 'NOPE'))
        if ability ~= nil and ability:GetLevel() ~= 0 then
          callModApplier(player.hero, onDeath, ability:GetLevel())
          print(tostring(1 + ((scale - 1) * (ability:GetLevel() / 4))))
          print(tostring(ability:GetSpecialValueFor("duration")) + (ability:GetLevel() - 1))
          player.hero:SetModelScale(1 + ((scale - 1) * (ability:GetLevel() / 4)), 1)
          self:CreateTimer('resetScale' .. playerID,{
            endTime = GameRules:GetGameTime() + ability:GetSpecialValueFor("duration") + (ability:GetLevel() - 1),
            useGameTime = true,
            callback = function() 
              player.hero:SetModelScale(1, 1)
            end})
        end
      end
    end
  end, 'Tests the death function', 0)

  Convars:RegisterCommand('rubickbrawl_test_round_complete', function()
    local cmdPlayer = Convars:GetCommandClient()
    if DEBUG then
      self:RoundComplete(true)
    end
  end, 'Tests the death function', 0)


  -- Change random seed
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  self.nRadiantScore = 0
  self.nDireScore = 0
  self.nConnected = 0

  -- Round stuff
  self.nCurrentRound = 1
  self.nRadiantDead = 0
  self.nDireDead = 0
  self.nLastKill = nil
  self.fRoundStartTime = 0

  -- Timers
  self.timers = {}

  -- userID map
  self.vUserIds = {}
  self.vSteamIds = {}

  self.vPlayers = {}
  self.vRadiant = {}
  self.vDire = {}

  -- Active Hero Map
  self.vPlayerHeroData = {}
  self.bPlayersInit = false
  print('[RUBICKBRAWL] values set')

  print('[RUBICKBRAWL] Precaching stuff...')
  PrecacheUnitByName('npc_precache_everything')
  print('[RUBICKBRAWL] Done precaching!') 

  self.thinkState = Dynamic_Wrap( RubickBrawlGameMode, '_thinkState_Prep' )

  print('[RUBICKBRAWL] Done loading RubickBrawl gamemode!\n\n')
end

GameMode = nil

function RubickBrawlGameMode:CaptureGameMode()
  if GameMode == nil then
    print('[RUBICKBRAWL] Capturing game mode...')
    GameMode = GameRules:GetGameModeEntity()		
    GameMode:SetRecommendedItemsDisabled( true )
    GameMode:SetCameraDistanceOverride( 1504.0 )
    GameMode:SetCustomBuybackCostEnabled( true )
    GameMode:SetCustomBuybackCooldownEnabled( true )
    GameMode:SetFogOfWarDisabled( true )
    GameMode:SetBuybackEnabled( false )
    GameMode:SetUseCustomHeroLevels ( true )
     GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
    -- GameMode:SetCustomHeroMaxLevel ( 25 )
    --GameMode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    GameMode:SetTopBarTeamValuesOverride ( true )

    GameRules:SetHeroMinimapIconSize( 360 )


    --[[ self:CreateTimer('PermaNightTime', {
    useGameTime = true,
    endTime = GameRules:GetGameTime(),
    callback = function(rubickbrawl, args)
    GameRules:SetTimeOfDay(19.0)
    return GameRules:GetGameTime() + 120
    end})]]

  --[[ self:CreateTimer('AddTheBots', {
      useGameTime = true,
      endTime = GameRules:GetGameTime() + TIME_WHEN_STUFF_WORKS,
      callback = function(rubickbrawl, args)
        for i=1,9 do
          local heroEntity = PlayerResource:GetPlayer(i):GetAssignedHero()
          Physics:Unit(heroEntity)
          heroEntity:SetNavCollisionType (PHYSICS_NAV_BOUNCE)
          heroEntity:Hibernate(false)
          -- hero:LockToGround (false)
          -- hero:FollowNavMesh (false)
          heroEntity:SetPhysicsVelocity(Vector(10,11,0))
          RubickBrawlGameMode.vPlayers[i] = {
            hero = heroEntity,
            isInEquilibrium = true,
            isUsingThrust = false,
            distanceTraveled = 0.0,
            lightningTarget = false,
            lastHitByPlayer = nil,
            baseVelocity = Vector(heroEntity:GetForwardVector().x*300, heroEntity:GetForwardVector().y*300, 0),
            baseVelocitySet = false,
            moveSpeed = 300,
            lastHitByAbility = nil,
            onLava = false,
            damageTaken = 0,
            lastHealth = 1000,
            accumulatedCollisions = 0,
            timer=0,
            alreadyStoppedThrust = false,
            isUnderLowFriction=false,
            alreadyStoppedTele = false,
            abilCount = 3,
            isUsingShield = false,
            justUsedThrust=false,
            isUsingWW = false,
            lavaModAdded = false,
            projectiles = {},
          --  currentVelocity = Vector(0,0,0),
            nKillsThisRound = 0,
            bDead = false,
            nUnspentGold = STARTING_GOLD,
            fLevel = 1.0,
            nTeam = heroEntity:GetTeam(),
            bRoundInit = false,
            nUnspentAbilityPoints = 1,          
            bConnected = true
          }
        end
      end}) ]]

    print( '[RUBICKBRAWL] Beginning Think' ) 
    GameMode:SetContextThink("RubickBrawlThink", Dynamic_Wrap( RubickBrawlGameMode, 'Think' ), THINK_TIME )
  end
end

--[[function RubickBrawlGameMode:AbilityUsed(keys)
print('[RUBICKBRAWL] AbilityUsed')
PrintTable(keys)
PrintTable(getmetatable(keys))

local ent = Entities:First()
repeat
print('\t[RUBICKBRAWL] ENTName: ' .. tostring(ent:GetName()) .. " -- ClassName: " .. tostring(ent:GetClassname()) .. " -- entindex: " .. tostring(ent:entindex()))
PrintTable(ent)
PrintTable(getmetatable(ent))
ent = Entities:Next(ent)
until ent == nil
end]]

-- Cleanup a player when they leave
function RubickBrawlGameMode:CleanupPlayer(keys)
  print('[RUBICKBRAWL] Player Disconnected ' .. tostring(keys.userid))
  self.nConnected = self.nConnected - 1
end

function RubickBrawlGameMode:CloseServer()
  -- Just exit
  SendToServerConsole('exit')
end

function RubickBrawlGameMode:AutoAssignPlayer(keys)
  print ('[RUBICKBRAWL] AutoAssignPlayer')
  self:CaptureGameMode()
  print ('[RUBICKBRAWL] getting index')
  --print(keys.index)
  local entIndex = keys.index+1
  local ply = EntIndexToHScript(entIndex)
  local playerID = ply:GetPlayerID()

  self.nConnected = self.nConnected + 1
  self:RemoveTimer('all_disconnect')

  if PlayerResource:IsBroadcaster(playerID) then
    return
  end

  playerID = ply:GetPlayerID()
  if self.vPlayers[playerID] ~= nil then
    self.vUserIds[playerID] = nil
    self.vUserIds[keys.userid] = ply
    return
  end
--comment out for d2moddin
  if not USE_LOBBY and playerID == -1 then
    print ('[RUBICKBRAWL] team sizes ' ..  #self.vRadiant .. "  --  " .. #self.vDire)
    if #self.vRadiant > #self.vDire then
      print ('[RUBICKBRAWL] setting to bad guys')
      ply:SetTeam(DOTA_TEAM_BADGUYS)
      ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_BADGUYS)
      table.insert (self.vDire, ply)
    else
      print ('[RUBICKBRAWL] setting to good guys')
      ply:SetTeam(DOTA_TEAM_GOODGUYS)
      ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_GOODGUYS)
      table.insert (self.vRadiant, ply)
    end
    playerID = ply:GetPlayerID()
  end

  print ('[RUBICKBRAWL] playerID: ' .. playerID)

  --PrintTable(PlayerResource)
  --PrintTable(getmetatable(PlayerResource))

  print('[RUBICKBRAWL] SteamID: ' .. PlayerResource:GetSteamAccountID(playerID))
  self.vUserIds[keys.userid] = ply
  self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply
  
  if IsValidEntity(ply) then
	if ply:GetAssignedHero() == nil then
		CreateHeroForPlayer('npc_dota_hero_rubick', ply)
	else
		return
	end
  end

  --Autoassign player
  self:CreateTimer('assign_player_'..entIndex, {
    endTime = Time(),
    callback = function(rubickbrawl, args)
      if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME and IsValidEntity(ply) then
        print ('[RUBICKBRAWL] in pregame')
        -- Assign a hero to a fake client
        local heroEntity = ply:GetAssignedHero()
        if PlayerResource:IsFakeClient(playerID) then
          if heroEntity == nil then
            CreateHeroForPlayer('npc_dota_hero_axe', ply)
          else
            PlayerResource:ReplaceHeroWith(playerID, 'npc_dota_hero_axe', 0, 0)
          end
        end
        heroEntity = ply:GetAssignedHero()
        Physics:Unit(heroEntity)
        heroEntity:SetNavCollisionType (PHYSICS_NAV_BOUNCE)
        heroEntity:Hibernate(false)
        -- heroEntity:LockToGround (false)
        -- heroEntity:FollowNavMesh (false)
        print ('[RUBICKBRAWL] got assigned hero')
        -- Check if we have a reference for this player's hero
        if heroEntity ~= nil and IsValidEntity(heroEntity) then
          print ('[RUBICKBRAWL] setting hero assignment')
          local heroTable = {
            hero = heroEntity,
            isInEquilibrium = true,
			firstRound=true,
            isUsingThrust = false,
            distanceTraveled = 0.0,
            lightningTarget = false,
            lastHitByPlayer = nil,
            baseVelocity = Vector(heroEntity:GetForwardVector().x*300, heroEntity:GetForwardVector().y*300, 0),
            baseVelocitySet = false,
            moveSpeed = 300,
            lastHitByAbility = nil,
            onLava = false,
            damageTaken = 0,
            accumulatedCollisions=0,
            timer=0,
            lastHealth = 1000,
            isUnderLowFriction=false,
            alreadyStoppedThrust = false,
            alreadyStoppedTele = false,
            abilCount=3,
            justUsedThrust=false,
            isUsingShield = false,
            isUsingWW = false,
            lavaModAdded = false,
            projectiles = {},
          --  currentVelocity = Vector(0,0,0),
            nKillsThisRound = 0,
            bDead = false,
            nUnspentGold = STARTING_GOLD,
            fLevel = 1.0,
            nTeam = ply:GetTeam(),
            bRoundInit = false,
            nUnspentAbilityPoints = 1,          
            bConnected = true
          }
          Z_VALUE = heroEntity:GetAbsOrigin().z
          heroEntity:AddExperience(5000,false)
		  
		  for i=1,49 do
            heroEntity:HeroLevelUp(false)
		  end
		  
		  heroEntity:SetAbilityPoints(0)
		  heroTable.hero:SetGold(0, true)
		  
          for i=1,49 do
            heroTable.hero:HeroLevelUp(false)
          end
		  
          heroEntity:AddPhysicsVelocity(Vector(10,11,0))
          -- heroEntity:SetHullRadius(heroEntity:GetHullRadius() + 10.0)
          print ('[RUBICKBRAWL] playerID: ' .. playerID)
          self.vPlayers[playerID] = heroTable

          print ( "[RUBICKBRAWL] setting stuff for player"  .. playerID)
          --heroEntity:__KeyValueFromInt('StatusManaRegen', 100)
          heroEntity:SetMaximumGoldBounty(0)
          heroEntity:SetMinimumGoldBounty(0)
		  
          local fireball = heroEntity:FindAbilityByName('rubickbrawl_fireball')
          heroEntity:UpgradeAbility(fireball)
		  
		  local scourge = heroEntity:FindAbilityByName('rubickbrawl_scourge')
          heroEntity:UpgradeAbility(scourge)
		  
		  local lightning = heroEntity:FindAbilityByName('rubickbrawl_lightning')
          heroEntity:UpgradeAbility(lightning)
		  
		  local teleport = heroEntity:FindAbilityByName('rubickbrawl_teleport')
          heroEntity:UpgradeAbility(teleport)
		  
		  local thrust = heroEntity:FindAbilityByName('rubickbrawl_thrust')
          heroEntity:UpgradeAbility(thrust)
		  
		  local meteor = heroEntity:FindAbilityByName('rubickbrawl_meteor')
          heroEntity:UpgradeAbility(meteor)
		  
          heroEntity:SetCustomDeathXP(0)
          heroEntity:SetGold(0, false)
          heroEntity:SetGold(STARTING_GOLD, true)
          --PlayerResource:SetGold( playerID, 0, false )
          --PlayerResource:SetGold( playerID, STARTING_GOLD, true )
          print ( "[RUBICKBRAWL] GOLD SET FOR PLAYER "  .. playerID)
          PlayerResource:SetBuybackCooldownTime( playerID, 0 )
          PlayerResource:SetBuybackGoldLimitTime( playerID, 0 )
          PlayerResource:ResetBuybackCostTime( playerID )

          if GameRules:State_Get() > DOTA_GAMERULES_STATE_PRE_GAME then

            if heroTable.bRoundInit == false then
              print ( '[RUBICKBRAWL] Initializing player ' .. playerID)
              heroTable.bRoundInit = true
              heroTable.hero:RespawnHero(false, false, false)
              --player.hero:RespawnUnit()
              heroTable.nKillsThisRound = 0
              heroTable.bDead = false

              --PlayerResource:SetGold(playerID, 0, true)
              heroTable.hero:SetGold(0, true)
              heroTable.nUnspentAbilityPoints = heroTable.hero:GetAbilityPoints()
              heroTable.hero:SetAbilityPoints(0)

              --if has modifier remove it
              if heroTable.hero:HasModifier("modifier_stunned") then
                heroTable.hero:RemoveModifierByName("modifier_stunned")
              end

            end
          end

          return
        end
      end

      return Time() + 1.0
    end
  --persist = true
  })
end

function RubickBrawlGameMode:LoopOverPlayers(callback)
  for k, v in pairs(self.vPlayers) do
    -- Validate the player
    if IsValidEntity(v.hero) then
      -- Run the callback
      if callback(v, v.hero:GetPlayerID()) then
        break
      end
    end
  end
end

--[[function RubickBrawlGameMode:ShopReplacement( keys )
  local ID = keys.PlayerID
  if not ID then return end

  local item = keys.itemname
  if not item then return end

  RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
    if plyID == ID then
      local originalGold = player.hero:GetGold()
      player.usedShop=true
      --item_ability_rubickbrawl_lightning
      local abilName = string.sub(item, 14)
      print('abilcount: ' .. player.abilCount)
      if player.hero:HasAbility(abilName) or player.abilCount > 6 then
        local item2 = player.hero:GetItemInSlot(0)
        player.hero:RemoveItem(item2)
        --local diff = originalGold-spellCosts[abilName .. '_cost'][1]
        --print('diff: ' .. diff)
        player.hero:SetGold(player.hero:GetGold()+spellCosts[abilName .. '_cost'][1], true)
        player.usedShop=false
        return
      else
        if abilName == "rubickbrawl_lightning" then
          player.hero:RemoveAbility('rubickbrawl_empty4')
        end
        if abilName == "rubickbrawl_thrust" then
          -- if hero doesn't have this, then tele or thrust was already bought.
          if player.hero:HasAbility('rubickbrawl_empty3') then
            player.hero:RemoveAbility('rubickbrawl_empty3')
          else 
            local item2 = player.hero:GetItemInSlot(0)
            player.hero:RemoveItem(item2)
            player.hero:SetGold(player.hero:GetGold()+spellCosts[abilName .. '_cost'][1], true)
            player.usedShop=false
            return
          end
        end
        if abilName == "rubickbrawl_teleport" then
          player.hero:RemoveAbility('rubickbrawl_empty5')
        end
        if abilName == "rubickbrawl_meteor" then
          player.hero:RemoveAbility('rubickbrawl_empty6')
        end
        player.hero:AddAbility(abilName)
        player.abilCount=player.abilCount+1
        local abil = player.hero:FindAbilityByName(abilName)
        abil:SetLevel(1)
      end
      local item2 = player.hero:GetItemInSlot(0)
      player.hero:RemoveItem(item2)
      player.usedShop=false
    end
  end)
end]]

function RubickBrawlGameMode:_thinkState_Prep( dt )
  --print ( '[RUBICKBRAWL] _thinkState_Prep' )
  if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_PRE_GAME then
    -- Waiting on the game to start..
    return
  end

  self.thinkState = Dynamic_Wrap( RubickBrawlGameMode, '_thinkState_None' )
  self:InitializeRound()


end

function RubickBrawlGameMode:_thinkState_None( dt )
  return
end

function RubickBrawlGameMode:InitializeRound()
  print ( '[RUBICKBRAWL] InitializeRound called' )
  bInPreRound = true
  --local distance = (PLATFORM_BOUNDS-firstLevelCast)+50
  GameRules:SetFirstBloodActive(true)

   self:initLavaTimers()

  if firstRound then
    self:CreateTimer('rubickbrawlInfo', {
      endTime = GameRules:GetGameTime() + 3,
      useGameTime = true,
      callback = function(rubickbrawl, args)
        local msg = {
          message = "RUBICK BRAWL",
          duration = 7.0
        }
        FireGameEvent("show_center_message",msg)
       -- GameRules:SendCustomMessage("Welcome to Rubick Brawl!", 0, 0)
        GameRules:SendCustomMessage("Developer: Myll", 0, 0)
        GameRules:SendCustomMessage("Mapper: Azarak", 0, 0)
        GameRules:SendCustomMessage("Special Thanks: BMD, Smed", 0, 0)
		GameRules:SendCustomMessage("Inspired by WC3 Warlocks", 0, 0)
        GameRules:SendCustomMessage("http://steamcommunity.com/groups/rubickbrawl", 0, 0)
		--GameRules:SendCustomMessage("After each round, you gain 5 skillpoints in which you can upgrade your spells!", 0, 0)
      end
    })
  end
  
  --cancelTimer = false
  --Init Round (give level ups/points/gold back)
  self:RemoveTimer('playerInit')
  self:CreateTimer('playerInit', {
    endTime = Time(),
    callback = function(rubickbrawl, args)
      if not bInPreRound then
        return Time() + 0.5
      end
      self:LoopOverPlayers(function(player, plyID)
        if player.bRoundInit == false then
          print ( '[RUBICKBRAWL] Initializing player ' .. plyID)
          player.bRoundInit = true
          player.hero:RespawnHero(false, false, false)
          --player.hero:RespawnUnit()
          player.nKillsThisRound = 0
          player.hero:SetMana(0)
          player.damageTaken = 0
          player.lastHealth = 1000
		  
		  if player.firstRound == false then player.hero:SetAbilityPoints(3) end
		  if player.firstRound then player.firstRound = false end
		  
          player.hero:SetPhysicsVelocity(Vector(10,11,0))
          player.bDead = false
          --PlayerResource:SetGold(plyID, player.nUnspentGold, true)
          player.hero:SetGold(player.nUnspentGold, true)
          --  player.hero:AddNewModifier( player.hero, nil , "modifier_phased", {})

          -- player.hero:SetAbilityPoints(player.nUnspentAbilityPoints)

		  local fireball = player.hero:FindAbilityByName('rubickbrawl_fireball')
          fireball:EndCooldown()
		  
		  local scourge = player.hero:FindAbilityByName('rubickbrawl_scourge')
          scourge:EndCooldown()
		  
		  local lightning = player.hero:FindAbilityByName('rubickbrawl_lightning')
          lightning:EndCooldown()
		  
		  local teleport = player.hero:FindAbilityByName('rubickbrawl_teleport')
          teleport:EndCooldown()
		  
		  local thrust = player.hero:FindAbilityByName('rubickbrawl_thrust')
          thrust:EndCooldown()
		  
		  local meteor = player.hero:FindAbilityByName('rubickbrawl_meteor')
          meteor:EndCooldown()
		  
          --[[ check for player-player collisions
          player.hero:OnPhysicsFrame (function(unit)
          RubickBrawlGameMode:checkPlayerPlayerCollision(player)
          end)]]

          if not player.hero:HasModifier("modifier_stunned") then
            player.hero:AddNewModifier( player.hero, nil , "modifier_stunned", {})
          end

          if not player.hero:HasModifier("modifier_invulnerable") then
            player.hero:AddNewModifier(player.hero, nil , "modifier_invulnerable", {})
          end
        end
      end)
	  
	  firstRound = false

      --[[if count == #self.vRadiant + #self.vDire then
      print ( '[RUBICKBRAWL] All Initialized' )
      return
      end
      return Time() + 0.5]]
      --if cancelTimer then
      --	return
      --end
      return Time() + 0.5
    end})

  local roundTime = PRE_ROUND_TIME + PRE_GAME_TIME
  PRE_GAME_TIME = 0

  Say(nil, string.format("Round %d starts in %d seconds!", self.nCurrentRound, roundTime), false)
  local startCount = 7
  --Set Timers for round start announcements
  self:CreateTimer('round_start_timer', {
    endTime = GameRules:GetGameTime() + roundTime - 10,
    useGameTime = true,
    callback = function(rubickbrawl, args)
      startCount = startCount - 1
      if startCount == 0 then
        self.fRoundStartTime = GameRules:GetGameTime()
        self:LoopOverPlayers(function(player, plyID)

          player.nUnspentGold = PlayerResource:GetGold(plyID)
          --PlayerResource:SetGold(plyID, 0, true)
          player.hero:SetGold(0, true)

          --if has modifier remove it
          if player.hero:HasModifier("modifier_stunned") then
            player.hero:RemoveModifierByName("modifier_stunned")
          end

          if player.hero:HasModifier("modifier_invulnerable") then
            player.hero:RemoveModifierByName("modifier_invulnerable")
          end

          local timeoutCount = 14
          self:CreateTimer('round_time_out',{
            endTime = GameRules:GetGameTime() + ROUND_TIME - 120,
            useGameTime = true,
            callback = function(rubickbrawl, args)
              timeoutCount = timeoutCount - 1
              if timeoutCount == 0 then 
                -- TIME OUT
                self:LoopOverPlayers(function(player, plyID)
                  player.hero:AddNewModifier( player.hero, nil , "modifier_stunned", {})
                  player.hero:AddNewModifier( player.hero, nil , "modifier_invulnerable", {})
                end)
                self:CreateTimer('victory', {
                  endTime = Time() + POST_ROUND_TIME,
                  callback = function(rubickbrawl, args)
                    RubickBrawlGameMode:RoundComplete(true)
                  end})

                return
              elseif timeoutCount == 13 then
                Say(nil, "2 minutes remaining!", false)
                return GameRules:GetGameTime() + 60
              elseif timeoutCount == 12 then
                Say(nil, "1 minute remaining!", false)
                return GameRules:GetGameTime() + 30
              elseif timeoutCount == 11 then
                Say(nil, "30 seconds remaining!", false)
                return GameRules:GetGameTime() + 20
              else 
                local msg = {
                  message = tostring(timeoutCount),
                  duration = 0.9
                }
                FireGameEvent("show_center_message",msg)
                return GameRules:GetGameTime() + 1
              end
            end})
        end)

        bInPreRound = false;
        local msg = {
          message = "FIGHT!",
          duration = 0.9
        }
        FireGameEvent("show_center_message",msg)
        return
      elseif startCount == 6 then
        Say(nil, "10 seconds remaining!", false)
        return GameRules:GetGameTime() + 5
      else
        local msg = {
          message = tostring(startCount),
          duration = 0.9
        }
        FireGameEvent("show_center_message",msg)
        return GameRules:GetGameTime() + 1
      end
    end})

end

function RubickBrawlGameMode:RoundComplete(timedOut)
  print ('[RUBICKBRAWL] Round Complete')

  self:RemoveTimer('round_start_timer')
  self:RemoveTimer('round_time_out')
  self:RemoveTimer('victory')

  PLATFORM_BOUNDS = ORIGINAL_PLATFORM_BOUNDS
  lavaTimersStarted = false
  platformRadius = originalPlatformRadius

  local elapsedTime = GameRules:GetGameTime() - self.fRoundStartTime - POST_ROUND_TIME

  -- Determine Victor and boost Dire/Radiant score
  local victor = DOTA_TEAM_GOODGUYS
  local s = "Radiant"
  if timedOut then
    --If noteam score any kill, the team on inferior position win this round to prevent from negative attitude
    if self.nLastKill == nil then 
      if self.nRadiantScore > self.nDireScore then
        victor = DOTA_TEAM_BADGUYS
        s = "Dire"
      end
      -- Victor is whoever has least dead
    elseif self.nDireDead < self.nRadiantDead then
      victor = DOTA_TEAM_BADGUYS
      s = "Dire"
      -- If both have same number of dead go by last team that got a kill
    elseif self.nDireDead == self.nRadiantDead and self.nLastKill == DOTA_TEAM_BADGUYS then
      victor = DOTA_TEAM_BADGUYS
      s = "Dire"
    end
  else
    -- Find someone alive and declare that team the winner (since all other team is dead)
    self:LoopOverPlayers(function(player, plyID)
      if player.bDead == false then
        victor = player.nTeam
        if victor == DOTA_TEAM_BADGUYS then
          s = "Dire"
        end
      end
    end)
  end

  local timeBonus = 0
  if elapsedTime < ROUND_TIME / 8 then
    timeBonus = GOLD_TIME_BONUS_1
  elseif elapsedTime < ROUND_TIME / 4 then
    timeBonus = GOLD_TIME_BONUS_2
  elseif elapsedTime < ROUND_TIME / 2 then
    timeBonus = GOLD_TIME_BONUS_3
  end

  if victor == DOTA_TEAM_GOODGUYS then
    self.nRadiantScore = self.nRadiantScore + 1
  else
    self.nDireScore = self.nDireScore + 1
  end

  GameMode:SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireScore )
  GameMode:SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantScore )

  Say(nil, s .. " WINS the round!", false)
  --Say(nil, "Overall Score:  " .. self.nRadiantScore .. " - " .. self.nDireScore, false)

  -- Check if at max round
  -- Complete game entirely and declare an overall victor
  if self.nRadiantScore == ROUNDS_TO_WIN then
    Say(nil, "RADIANT WINS!!  Well Played!", false)
    GameRules:SetSafeToLeave( true )
    GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
    self:CreateTimer('endGame', {
      endTime = Time() + POST_GAME_TIME,
      callback = function(rubickbrawl, args)
        RubickBrawlGameMode:CloseServer()
      end})
    return
  elseif self.nDireScore == ROUNDS_TO_WIN then
    Say(nil, "DIRE WINS!!  Well Played!", false)
    GameRules:SetSafeToLeave( true )
    GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
    self:CreateTimer('endGame', {
      endTime = Time() + POST_GAME_TIME,
      callback = function(rubickbrawl, args)
        RubickBrawlGameMode:CloseServer()
      end})
    return
  end

  -- Figure out how much gold per team
  -- Figure out how many levels per team
  -- Grant gold and levels
  -- Go through players and flag for re-init
  -- Maybe halt playerInit functionality until done?

  local baseGoldRadiant = 0
  local baseGoldDire = 0
  local baseLevelsRadiant = 0
  local baselevelsDire = 0

  -- TODO
  -- MVP Tracking?

  self:LoopOverPlayers(function(player, plyID)
    local gold = 0
    local levels = 0
    player.hero:SetPhysicsVelocity(Vector(10,11,0))
    if player.nTeam == victor then
      gold = GOLD_PER_ROUND_WINNER + timeBonus
      levels = LEVELS_PER_ROUND_WINNER
    else
      gold = GOLD_PER_ROUND_LOSER
      levels = LEVELS_PER_ROUND_LOSER
    end

    -- Player survived
    if player.nTeam ~= victor and player.bDead == false then
      gold = gold + GOLD_PER_SURVIVE
    end

    gold = gold + GOLD_PER_KILL * player.nKillsThisRound

    player.nUnspentGold = player.nUnspentGold + gold
    player.fLevel = player.fLevel + levels
    player.bRoundInit = false
  end)


  self.nCurrentRound = self.nCurrentRound + 1
  self.nRadiantDead = 0
  self.nDireDead = 0
  self.nLastKill = nil

  self:InitializeRound()
end

function RubickBrawlGameMode:PlayerSay(keys)
  print ('[RUBICKBRAWL] PlayerSay')
  PrintTable(keys)

  -- Get the player entity for the user speaking
  local ply = self.vUserIds[keys.userid]
  if ply == nil then
    return
  end

  -- Get the player ID for the user speaking
  local plyID = ply:GetPlayerID()
  if not PlayerResource:IsValidPlayer(plyID) then
    return
  end

  -- Should have a valid, in-game player saying something at this point
  -- The text the person said
  local text = keys.text
  if text == 'proj' then PrintTable(projectilesOnMap) end
  local hero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
  -- if shrinkDummy:IsIdle() then updateLava() end
  -- local dummy = CreateUnitByName("npc_dummy_unit", hero:GetAbsOrigin() + Vector(0,0,30), true, nil, nil, DOTA_TEAM_BADGUYS)
  --ParticleManager:CreateParticle('clinkz_searing_arrow', PATTACH_ABSORIGIN_FOLLOW, dummy)
  --dummy:AddNewModifier(dummy, nil, "modifier_jakiro_liquid_fire_burn", nil)
  -- Match the text against something
  local matchA, matchB = string.match(text, "^-swap%s+(%d)%s+(%d)")
  if matchA ~= nil and matchB ~= nil then
  -- Act on the match
  end

end

function RubickBrawlGameMode:Think()
  --print ( '[RUBICKBRAWL] Thinking' )
  -- If the game's over, it's over.
  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    -- self._scriptBind:EndThink( "GameThink" )
    --RubickBrawlGameMode:EndThink( "GameThink" )
    return
  end

  if GameRules:GetGameTime() > TIME_WHEN_STUFF_WORKS then
    RubickBrawlGameMode:LoopOverPlayers(function(player, plyID)
      --print('plyID: ' .. plyID .. ' x: ' .. vx .. ' y: ' .. vy .. 'hullr: ' .. player.hero:GetHullRadius())
      --print('r: ' .. player.hero:GetHullRadius())

      if player.lastHealth ~= player.hero:GetHealth() then
        -- print('last health ~= gethealth')
        if player.hero:GetHealth() < player.lastHealth then
          local difference = player.lastHealth-player.hero:GetHealth()
          player.damageTaken = player.damageTaken + difference
          --  print('dmg taken: ' .. player.damageTaken)
          player.hero:SetMana(player.hero:GetMana() + difference)
        end
      end

      player.lastHealth = player.hero:GetHealth()

      RubickBrawlGameMode:checkPlayerPlayerCollision(player)
      RubickBrawlGameMode:checkPlayerPillarCollision(player)
	  
	  --make game not pauseable
	 --[[ PauseGame( false )
		if firstTime ~= nil then
			if GameRules:GetGameTime() == firstTime then
				gamePaused = true
				--print('game is paused')
			else
				gamePaused = false
			end
		end
		firstTime = GameRules:GetGameTime()]]
	  
      --updateProjectiles(projectilesOnMap)
      --  print(player.hero:GetPhysicsVelocity():Length())

      --[[ if player.isUsingWW then
      if Time()-player.wwStartTime > 2.6 then
      player.isUsingWW = false
      if player.hero:HasModifier("modifier_invisible") then
      player.hero:RemoveModifierByName("modifier_invisible")
      end
      player.hero:SetBaseMoveSpeed(300)
      end
      end]]

      if player.hero:GetHealth() <= 1.0 then
        player.hero:Kill(player.lastHitByAbility, player.lastHitByPlayer)
      end

      --  print('forward vector: ' .. 'x: ' .. player.hero:GetForwardVector().x .. 'y: ' .. player.hero:GetForwardVector().y .. 'z: ' .. player.hero:GetForwardVector().z)
      --  print('player location: ' .. 'x: ' .. player.hero:GetAbsOrigin().x .. 'y: ' .. player.hero:GetAbsOrigin().y .. 'z: ' .. player.hero:GetAbsOrigin().z)

      isPlayerInLava(player)

      -- stop the hero from moving after some spells are complete.
      if player.hero:HasAbility('rubickbrawl_teleport') then
        local tele = player.hero:FindAbilityByName('rubickbrawl_teleport')
        if tele:GetCooldownTimeRemaining() > 0 and player.alreadyStoppedTele == false then
          player.hero:Stop()
          player.alreadyStoppedTele = true
        end
        if tele:GetCooldownTimeRemaining() == 0 and player.alreadyStoppedTele == true then
          player.alreadyStoppedTele = false
        end
      end

      if player.hero:HasAbility('rubickbrawl_thrust') then
        local thrust = player.hero:FindAbilityByName('rubickbrawl_thrust')
        if thrust:GetCooldownTimeRemaining() > 0 and player.alreadyStoppedThrust == false then
          player.hero:Stop()
          -- player.hero:SetPhysicsVelocity(base_vel)
          player.alreadyStoppedThrust = true
        end
        if thrust:GetCooldownTimeRemaining() == 0 and player.alreadyStoppedThrust == true then
          player.alreadyStoppedThrust = false
        end
      end

      if player.isUnderLowFriction and player.hero:GetPhysicsVelocity():Length() > low_vel_cap then
        player.hero:SetPhysicsFriction(base_friction)
        player.isUnderLowFriction = false
      end

      if player.isUsingThrust then 
        updateThrust(player)
        --player.hero:SetForwardVector(player.thrustDirection)
      end
    end)
  end

  -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
  local now = GameRules:GetGameTime()
  if RubickBrawlGameMode.t0 == nil then
    RubickBrawlGameMode.t0 = now
  end
  local dt = now - RubickBrawlGameMode.t0
  RubickBrawlGameMode.t0 = now

  RubickBrawlGameMode:thinkState( dt )

  -- Process timers
  for k,v in pairs(RubickBrawlGameMode.timers) do
    local bUseGameTime = false
    if v.useGameTime and v.useGameTime == true then
      bUseGameTime = true;
    end
    -- Check if the timer has finished
    if (bUseGameTime and GameRules:GetGameTime() > v.endTime) or (not bUseGameTime and Time() > v.endTime) then
      -- Remove from timers list
      RubickBrawlGameMode.timers[k] = nil

      --print ( '[RUBICKBRAWL] Running timer: ' .. k)

      -- Run the callback
      local status, nextCall = pcall(v.callback, RubickBrawlGameMode, v)

      -- Make sure it worked
      if status then
        -- Check if it needs to loop
        if nextCall then
          -- Change it's end time
          v.endTime = nextCall
          RubickBrawlGameMode.timers[k] = v
        end

        -- Update timer data
        --self:UpdateTimerData()
      else
        -- Nope, handle the error
        RubickBrawlGameMode:HandleEventError('Timer', k, nextCall)
      end
    end
  end

  return THINK_TIME
end

function updateLava(v)
  --[[ v.angle = v.angle - math.pi/30
  local x = math.sin(v.angle)*1600
  local y = math.cos(v.angle)*1600
  v.unit:SetAbsOrigin(Vector(x,y,Z_VALUE))]]
  --if v.orientation == 'top' then print('v.angle for top is ' .. v.angle) end
  if  v.unit:IsIdle() then
    v.angle = v.angle - math.pi/30
    local x = math.sin(v.angle)*platformRadius
    local y = math.cos(v.angle)*platformRadius
    v.unit:MoveToPosition(Vector(x,y,Z_VALUE))
  end
end

function circleCircleCollision(p1Origin, p2Origin, p1Radius, p2Radius)
  if ((p1Origin.x - p2Origin.x)*(p1Origin.x - p2Origin.x) + (p1Origin.y - p2Origin.y)*(p1Origin.y - p2Origin.y)) <= (p1Radius+p2Radius)*(p1Radius+p2Radius) then
    return true
  else
    return false
  end
end

--(x2-x1)^2 + (y1-y2)^2 <= (r1+r2)^2

function getIntersectionDepth(p1,p2)

  local direction = p2.hero:GetAbsOrigin() - p1.hero:GetAbsOrigin()
  local distance = direction:Length()
  direction = direction:Normalized()
  local depth = (p1.hero:GetHullRadius()+p2.hero:GetHullRadius())-distance
  return depth
end

function RubickBrawlGameMode:checkPlayerPlayerCollision(player)
  self:LoopOverPlayers(function(player2, plyID)
    if player.hero ~= player2.hero then
      local pr = player2.hero:GetHullRadius() + 25.0
      if player.isUsingThrust then
        pr=pr+EXTRA_THRUST_RADIUS
      end
      -- print('velocity vector: ' .. 'x: ' .. player2.hero:GetPhysicsVelocity().x .. 'y: ' .. player2.hero:GetPhysicsVelocity().y .. 'z: ' .. player2.hero:GetPhysicsVelocity().z)
      local p1Vi = player.hero:GetPhysicsVelocity()
      local p2Vi = player2.hero:GetPhysicsVelocity()
      local p1Direction = p1Vi:Normalized()
      local p2Direction = p2Vi:Normalized()
      -- the physics isn't updating because of low velocity. so we have to get the velocity manually.
      --print('checkPlayerPlayerCollision')
      local p1c = player.hero:GetAbsOrigin()
      local p2c = player2.hero:GetAbsOrigin()

      -- the next 4 ifs just detect if the player is walking or standing still. if both players are in one of these states,
      -- then we use the time prediction collision algorithm. Otherwise, use circleCircleCollision.
      if p1Vi:Length() < min_v+2 and player.hero:IsIdle() == false then
        p1Direction = (p2c-p1c):Normalized()
        p1Vi=min_v*p1Direction
		player.currentVelocity=p1Vi
        player.isStill=false
        player.useTimePrediction=true
      end

      if player.hero:IsIdle() and p1Vi:Length() < min_v+2 then
        p1Vi = Vector(0,0,0)
		player.currentVelocity=p1Vi
        player.isStill=true
        player.useTimePrediction=true
      end

      if p2Vi:Length() < min_v+2 and player2.hero:IsIdle() == false then
        p2Direction = (p1c-p2c):Normalized()
        p2Vi=min_v*p2Direction
		player2.currentVelocity=p2Vi
        player2.isStill=false
        player2.useTimePrediction=true
      end
      if player2.hero:IsIdle() and p2Vi:Length() < min_v+2 then 
        p2Vi = Vector(0,0,0)
		player2.currentVelocity=p2Vi
        player2.isStill=true
        player2.useTimePrediction=true
      end
		
	  --get the velocity for lightningcoll
	  if player.useTimePrediction==false then player.currentVelocity=player.hero:GetPhysicsVelocity() end
	  if player2.useTimePrediction==false then player2.currentVelocity=player.hero:GetPhysicsVelocity() end
	  
      -- time predication case or thrust case or WW case
      if (player.useTimePrediction and player2.useTimePrediction) or (player.isUsingThrust or player2.isUsingThrust) then
        local p1={c=Vector(p1c.x,p1c.y,0), v = Vector(p1Vi.x,p1Vi.y,0), m=2, r=pr}
        local p2={c=Vector(p2c.x,p2c.y,0), v = Vector(p2Vi.x,p2Vi.y,0), m=2, r=pr}

        local t = timeToCollision(p1,p2)
		
        if t <= THINK_TIME then
          --advance players to point of collision
          --player.hero:SetAbsOrigin(p1c+t*p1Vi)
          --player2.hero:SetAbsOrigin(p2c+t*p2Vi)

          --final velocities
          local p1Vf = (MASS_OF_RUBICKBRAWL/(MASS_OF_RUBICKBRAWL + MASS_OF_RUBICKBRAWL))*p2Vi
          local p2Vf = (MASS_OF_RUBICKBRAWL/(MASS_OF_RUBICKBRAWL + MASS_OF_RUBICKBRAWL))*p1Vi

		  if player2.isUsingThrust then
            thrustCase(player2, player)
            return
          end
          if player.isUsingThrust then
            thrustCase(player,player2)
            return
          end
		  
          -- advance players to end of current frame.
          player.hero:SetAbsOrigin(player.hero:GetAbsOrigin()+(THINK_TIME-t+.01)*p1Vf)
          player2.hero:SetAbsOrigin(player2.hero:GetAbsOrigin()+(THINK_TIME-t+.01)*p2Vf)

          if player.isStill then
            player.hero:AddPhysicsVelocity(p1Vf*1/4)
          else
            player.hero:AddPhysicsVelocity(p1Vf)
          end

          if player2.isStill then
            player2.hero:AddPhysicsVelocity(p2Vf*1/4)
          else
            player2.hero:AddPhysicsVelocity(p2Vf)
          end
        end


      elseif circleCircleCollision(p1c, p2c, pr, pr) then
        print('circleCircleCollision')
		
		local depth = getIntersectionDepth(player,player2)
		--print('')
		if depth < 0 then
			depth=-depth
		end
		print('depth: ' .. depth)
		--p2 to p1
		p1Direction = (p1c-p2c):Normalized()
		--p1 to p2
		p2Direction = (p2c-p1c):Normalized()
		-- player is completely on top of player2
		if depth <= 0 then
			print('depth is '.. depth)
			player.hero:SetAbsOrigin(p1c + Vector(pr,pr,0))
		else
			player.hero:SetAbsOrigin(p1c+p1Direction*(depth)*1/2)
			player2.hero:SetAbsOrigin(p2c+p2Direction*(depth)*1/2)
		end
        local p1Vf = (MASS_OF_RUBICKBRAWL/(MASS_OF_RUBICKBRAWL + MASS_OF_RUBICKBRAWL))*p1Direction*p2Vi:Length()
        local p2Vf = (MASS_OF_RUBICKBRAWL/(MASS_OF_RUBICKBRAWL + MASS_OF_RUBICKBRAWL))*p2Direction*p1Vi:Length()
		
        player.hero:AddPhysicsVelocity(p1Vf)
        player2.hero:AddPhysicsVelocity(p2Vf)
      end

	 --[[ if player2.hero:GetPhysicsVelocity():Length() > bleeding_threshold_vel and player2.onLava == false then
		player2.hero:AddNewModifier(player2.hero, nil, "modifier_bloodseeker_rupture", nil)
		player2.isBleeding = true
	  end

	  if player.hero:GetPhysicsVelocity():Length() > bleeding_threshold_vel and player.onLava == false then
		player.hero:AddNewModifier(player2.hero, nil, "modifier_bloodseeker_rupture", nil)
		player.isBleeding = true
	  end]]
	  
      player.useTimePrediction=false
      player2.useTimePrediction=false
    end
  end)
end

function RubickBrawlGameMode:checkPlayerPillarCollision(playerToCheck)
  local pc = playerToCheck.hero:GetAbsOrigin()
end

function pnpoly( vertx, verty, testx, testy )
  local nvert = table.getn(vertx);
  local c = -1;
  local j = nvert - 1;
  for i = 1, nvert do
    if ( ((verty[i] > testy) ~= (verty[j] > testy)) and (testx < (vertx[j] - vertx[i]) * (testy - verty[i]) / (verty[j] - verty[i]) + vertx[i]) ) then
      c = c * -1;
    end
    j = i;
  end
  return c;
end

function RubickBrawlGameMode:HandleEventError(name, event, err)
  -- This gets fired when an event throws an error

  -- Log to console
  print(err)

  -- Ensure we have data
  name = tostring(name or 'unknown')
  event = tostring(event or 'unknown')
  err = tostring(err or 'unknown')

  -- Tell everyone there was an error
  Say(nil, name .. ' threw an error on event '..event, false)
  Say(nil, err, false)

  -- Prevent loop arounds
  if not self.errorHandled then
    -- Store that we handled an error
    self.errorHandled = true

    -- End the gamemode
    --self:EndGamemode()
  end
end

function RubickBrawlGameMode:CreateTimer(name, args)
  --[[
  args: {
  endTime = Time you want this timer to end: Time() + 30 (for 30 seconds from now),
  useGameTime = use Game Time instead of Time()
  callback = function(frota, args) to run when this timer expires,
  text = text to display to clients,
  send = set this to true if you want clients to get this,
  persist = bool: Should we keep this timer even if the match ends?
  }

  If you want your timer to loop, simply return the time of the next callback inside of your callback, for example:

  callback = function()
  return Time() + 30 -- Will fire again in 30 seconds
  end
  ]]

  if not args.endTime or not args.callback then
    print("Invalid timer created: "..name)
    return
  end

  -- Store the timer
  self.timers[name] = args

  -- Update the timer
  --self:UpdateTimerData()
end

function RubickBrawlGameMode:RemoveTimer(name)
  -- Remove this timer
  self.timers[name] = nil

  -- Update the timers
  --self:UpdateTimerData()
end

function RubickBrawlGameMode:RemoveTimers(killAll)
  local timers = {}

  -- If we shouldn't kill all timers
  if not killAll then
    -- Loop over all timers
    for k,v in pairs(self.timers) do
      -- Check if it is persistant
      if v.persist then
        -- Add it to our new timer list
        timers[k] = v
      end
    end
  end

  -- Store the new batch of timers
  self.timers = timers
end

function RubickBrawlGameMode:_SetAbilityConsoleCommand( ... )
--[[local nArgs = select( '#', ... )
if nArgs < 3 then
print ('rubickbrawl_set_ability <ability_slot_number> <ability_name>')
return
end
local nSlot = tonumber (select ( 1, ... ))
local sAbName = select ( 2, ... ))
print ( 'Set Ability called %d %s', nSlot, sAbName )]]
end

function RubickBrawlGameMode:_WatConsoleCommand()
  print( '******* RubickBrawl Game Status ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      print ( string.format ( 'PlayerdID: %d called wat', playerID ) )
    end
  end

  PrintTable(self.vPlayers)
  print( '*********************************************' )
end

function RubickBrawlGameMode:OnEntityKilled( keys )
  -- print( '[RUBICKBRAWL] OnEntityKilled Called' )
  -- PrintTable( keys )
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- print ('classname:' .. killedUnit:GetClassname())
  if killedUnit:GetClassname() == 'npc_dota_creep_neutral' then
    return
  end
  -- print( '[RUBICKBRAWL] Got KilledUnit' )
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  -- print( '[RUBICKBRAWL] Got KillerEntity if exists' )

  -- Clean up units remaining...
  local enemyData = nil
  if killedUnit then
    --  print( '[RUBICKBRAWL] KilledUnit exists' )
    if killerEntity then
      local killerID = killerEntity:GetPlayerOwnerID()
      if self.vPlayers[killerID] ~= nil then
        self.vPlayers[killerID].nKillsThisRound = self.vPlayers[killerID].nKillsThisRound + 1
        --  print( string.format( '%s killed %s', killerEntity:GetPlayerOwnerID(), killedUnit:GetPlayerOwnerID()) )
      end
    end

    local killedID = killedUnit:GetPlayerOwnerID()
    if self.vPlayers[killedID] ~= nil then
      self.vPlayers[killedID].bDead = true
      if killedUnit:GetUnitName() then
      --  print( string.format( '[RUBICKBRAWL] %s died', killedUnit:GetUnitName() ) )
      else
      --  print ( "[RUBICKBRAWL] couldn't get unit name")
      end
    end

    -- Fix Gold
    self:LoopOverPlayers(function(player, plyID)
      player.hero:SetGold(0, true)
      player.hero:SetGold(0, false)
      --PlayerResource:SetGold(plyID, 0, true)
      --PlayerResource:SetGold(plyID, 0, false)
    end)

    if killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
      self.nRadiantDead = self.nRadiantDead + 1
      self.nLastKill = DOTA_TEAM_GOODGUYS
    else
      self.nDireDead = self.nDireDead + 1
      self.nLastKill = DOTA_TEAM_BADGUYS
    end


    -- Victory Check
    local nRadiantAlive = 0
    local nDireAlive = 0
    self:LoopOverPlayers(function(player, plyID)
      if player.bDead == false then
        if player.nTeam == DOTA_TEAM_GOODGUYS then
          nRadiantAlive = nRadiantAlive + 1
        else
          nDireAlive = nDireAlive + 1
        end
      end
    end)

    print ('RAlive: ' .. tostring(nRadiantAlive) .. ' -- DAlive: ' .. tostring(nDireAlive))

    if nRadiantAlive == 0 or nDireAlive == 0 then
      self:LoopOverPlayers(function(player, plyID)
        if player.bDead == false then
          player.hero:AddNewModifier( player.hero, nil , "modifier_invulnerable", {})
        end
      end)  
      self:CreateTimer('victory', {
        endTime = Time() + POST_ROUND_TIME,
        callback = function(rubickbrawl, args)
          RubickBrawlGameMode:RoundComplete(false)
        end})
      return
    end
  end
end

function RubickBrawlGameMode:FindAndRemove(hero, abilityName)
  if hero == nil or abilityName == nil then
    return
  end

  local ability = hero:FindAbilityByName(abilityName)
  if ability == nil then
    return
  end

  hero:RemoveAbility(abilityName)
end

function RubickBrawlGameMode:FindAndRemoveMod(hero, modName)
  if hero:HasModifier(modName) then
    hero:RemoveModifierByName(modName)
  end
end

function callModApplier( caster, modName, abilityLevel)
  if abilityLevel == nil then
    abilityLevel = ""
  else
    abilityLevel = "_" .. abilityLevel
  end
  local applier = modName .. abilityLevel .. "_applier"
  local ab = caster:FindAbilityByName(applier)
  if ab == nil then
    caster:AddAbility(applier)
    ab = caster:FindAbilityByName( applier )
  end
  caster:CastAbilityNoTarget(ab, -1)
  caster:RemoveAbility(applier)
end

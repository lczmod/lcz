/**
 * CTF base game settings, applied automatically at the game start after core settings.
 *
 * Changelog:
 * - Version 1.0
 *   Initial release
 * 
 * This file is part of LCZ Mod.
 * 
 * LCZ Mod is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * LCZ Mod is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with LCZ Mod.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * This is a required field in config file.
 * Variable values are set in the exact same order as they are listed in the table.
 */
baseGameSettings <-
{
	/**
	 * mp_randomspawn:
	 * 0: Both teams use default team-based spawn points
	 * 1: Both teams use random info_deathmatch_spawn points
	 * 2: Only Ts use random info_deathmatch_spawn points
	 * 3: Only CTs use random info_deathmatch_spawn points
	 */
	mp_randomspawn =			0,
	mp_teammates_are_enemies =	0,
	mp_solid_teammates =		0,
	// Remove // before mp_maxrounds on the next line if you want to use your own, CTF-specific value.
	//mp_maxrounds =			30
};

// Gamemode-specific settings

// Round will be ended when either team caps this number of flags.
// Set to 0 for no limit.
flagCapLimitT <-		3;
flagCapLimitCT <-		3;
// Extra time, in seconds, available to teams after either wins the round.
postWinTime <-			10;
// Number of points awarded to player for capping flag (shows up as "Kills" in CS:GO).
playerCapReward <-		3;
// Number of points awarded to player's team.
teamCapReward <-		1;
// Try not to set values less than one second here;
// Some order-dependent operations take place with small delays after flag state changes.
// These work under assumption that player won't interact with the flag for at least 1 second.
flagDropTimeout <-		30;
flagReactivateTime <-	1;
flagGlowWhenDropped <-	true;
flagGlowWhenCarried <-	true;
// Whether players are allowed to return dropped flags of their own team by touching them.
canReturnOwnFlag <-		true;
playerReturnReward <-	3;
teamReturnReward <-		0;
// Whether players can capture enemy flags while any of their own flags is missing.
canCapWithoutOwnFlag <-	false;

// Gamemode-specific internal vars

// Number of missing flags on either team.
missingFlagsT <-		0;
missingFlagsCT <-		0;
// Number of flags capped so far.
cappedFlagsT <-			0;
cappedFlagsCT <-		0;

/**
 * Drops the flag from the player with specified id.
 *
 * @param	playerId		id of player to drop the flag from.
 * @param	returnToSpawn	if @code true, returns flag to spawn immediately.
 * @param	alert			if @code true, shows HUD alert about flag drop.
 */
function dropPlayerFlag(playerId, returnToSpawn, alert)
{
	local player = lcz.players[playerId];
	if(!player)
	{
		if(lcz.debug) printl("LCZ E: lczCTFDropFlag(): Player with id " + playerId + " not found, exiting.");
		return;
	}
	
	if(lcz.hasPlayerKV(playerId, "CTFFlagCarried"))
	{
		local flagScope = lcz.getPlayerKV(playerId, "CTFFlagCarried");
		
		if(!flagScope)
		{
			if(lcz.debug) printl("LCZ E: lczCTFDropFlag(): No flag script scope for flag on carrier with id " + playerId + ", exiting.");
			return;
		}
		
		if(!flagScope.initialized)
		{
			if(lcz.debug) printl("LCZ E: lczCTFDropFlag(): Flag script hasn't been initialized for flag on carrier with id " + playerId + ", exiting.");
			return;
		}
		
		// Respawn is required when call comes from player disconnect event
		if(flagScope.isRespawnNeeded())
		{
			if(lcz.debug) printl("LCZ I: lczCTFDropFlag(): Flag ents respawn required before dropping flag, calling & exiting.");
			if(returnToSpawn)
				flagScope.flagEntsRespawnedCB.push(function() { dropFlag(flagStartPos); });
			else
				flagScope.flagEntsRespawnedCB.push(function() { dropFlag(self.GetOrigin()); });
			flagScope.respawnFlag(true);
			return;
		}
		else if(alert)
			lcz.alertMessage((flagScope.flagTeam == 2 ? "Terrorist" : "Counter-Terrorist") + " flag dropped!");
		
		if(returnToSpawn)
			flagScope.dropFlag(flagScope.flagStartPos);
		else
			flagScope.dropFlag(flagScope.self.GetOrigin());
	}
}

/**
 * Called from lcz Precache() -> applyGamemodeConfig().
 *
 * This is not a required field in config file.
 * Call is performed after applying the base game settings.
 * Additional gamemode-related initialization can be performed here.
 */
function lczOnGamemodeLoad()
{
	lcz.announcements.push("[LCZ] Gamemode: CTF / Capture The Flag. 2 teams.");
	
	lcz.eventPlayerDeathCB.push
	(
		function(playerId)
		{
			lcz.gamemode.scope.dropPlayerFlag(playerId, false, true);
		}
	);
	
	lcz.eventPlayerDisconnectCB.push
	(
		function(playerId)
		{
			// When player disconnects, his entity with all the movement children are killed.
			// This event fires too late to try and unparent those,
			// so flag ents are respawned instead.
			lcz.gamemode.scope.dropPlayerFlag(playerId, false, true);
		}
	);
	
	lcz.eventCsPreRestartCB.push
	(
		function()
		{
			foreach(id, player in players)
			{
				if(alivePlayers[id])
					lcz.gamemode.scope.dropPlayerFlag(id, true, false);
			}
		}
	);
}
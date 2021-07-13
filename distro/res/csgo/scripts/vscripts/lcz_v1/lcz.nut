/**
 * LCZ core library, version 1.0
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

// Other LCZ modules should access core functions through this globally exposed main scope.
::lcz <- self.GetScriptScope();

// Basic LCZ info & settings
version <-			1;
minorVersion <-		1;
initialized <-		false;
debug <-			false;
coreGamemodeName <-	"lcz";
bspFileName <-		GetMapName().tolower();
mapName <-			null;
scriptExtension <-	"nut";
scriptBasePath <-	"lcz_v1/";
gamemodeBaseName <-	"lcz_gamemode_";
/**
 * Any plugins, scripts or other entities modifying gravity must modify this value as well.
 * Default g = 800 u/s^2 = 20.32 m/s^2. Volvo, wtf? This isn't Jupiter.
 */
gravity <-			800;
baseSpeedMul <-		1.5;
// Possible gamemodes
gamemodes <-
[
	// Core LCZ mode is not an actual gamemode but basis for all other gamemodes.
	{
		name =		coreGamemodeName,
		// Gamemode scope can contain necessary variables & code
		scope =		{}
	},
	{
		name =		"dm",
		scope =		{},
	},
	{
		name =		"tdm",
		scope =		{},
	},
	{
		name =		"ctf",
		scope =		{},
	}
];
// Current gamemode data
gamemode <-			null;
/// Absolute Source limit. CS:GO maxplayers is set in gamemodes_server.txt or with -maxplayers_override.
maxPlayers <-		255;
plrEntIdOffset <-	1;
players <-			[];
alivePlayers <-		[];
playerKV <-			[];
plrEffects <-		[];
/// Sequential token based on number of respawns by players in this slot, can be used in delayed calls.
plrLifeTokens <-	[];
delayedCallCode <-	{};

// Event callback arrays should be filled with push(function(...))

/**
 * Parameters passed to callback function:
 *
 * - playerId
 */
eventPlayerSpawnCB <- [];

/**
 * Parameters passed to callback function:
 *
 * - playerId
 */
eventPlayerDeathCB <- [];

/**
 * Parameters passed to callback function:
 *
 * - playerId
 */
eventPlayerDisconnectCB <- [];

/**
 * No parameters are passed to callback function.
 */
eventCsPreRestartCB <- [];

/**
 * No parameters are passed to callback function.
 */
eventRoundStartCB <- [];

/**
 * Announcements to be displayed in chat at regular intervals.
 * Keep this minimal.
 */
announcements <-		[];
// Delay in seconds
announcementDelay <-	120.0;
lastAnnouncementTime <-	null;

// EntityGroup ents.
speedMod <-				null;
defaultDamageFilter <-	null;
gameScore <-			null;
sc <-					null;
gameRoundEnd <-			null;

function Precache()
{
	// BSP file name must be in the following format:
	// lcz_<dm/tdm/ctf>_<map name>
	//
	// ...or have a EBNF if you prefer a more specific approach:
	// separator = "_" ;
	// letter =
	//	"A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" |
	//	"N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z" |
	//	"a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" |
	//	"n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;
	// digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
	// character = letter | digit | "$" ;
	// gamemode = "dm" | "tdm" | "ctf" ;
	// map name = character, { character } ;
	// bsp name = "lcz", separator, gamemode, separator, map_name ;
	
	local pathSepIdx = null;
	while(pathSepIdx = bspFileName.find("/"))
		if(pathSepIdx == bspFileName.len() - 1)
		{
			printl("LCZ E: lcz Precache(): No BSP file name found in path string (" + bspFileName + "), exiting.");
			return;
		}
		else
			bspFileName = bspFileName.slice(pathSepIdx + 1);
	
	if(bspFileName.len() < 4 || bspFileName.slice(0, 4) != "lcz_")
	{
		printl("LCZ E: lcz Precache(): BSP file name must begin with \"lcz_\".");
		return;
	}
	
	local gamemodeEndPos = bspFileName.find("_", 4);
	if(!gamemodeEndPos || gamemodeEndPos == bspFileName.len() - 1)
	{
		printl("LCZ E: lcz Precache(): Couldn't find map name in BSP file name.");
		return;
	}
	
	local gamemodeName = bspFileName.slice(4, gamemodeEndPos);
	if(!gamemodeName || gamemodeName.len() == 0)
	{
		printl("LCZ E: lcz Precache(): No gamemode name found in BSP file name.");
		return;
	}
	
	local validGamemode = gamemodeName.tolower() != coreGamemodeName.tolower();
	if(validGamemode)
	{
		foreach(id, gamemode in gamemodes)
		{
			// Base settings, skip this
			if(id == 0)
				continue;
			
			if(gamemode.name == gamemodeName)
			{
				validGamemode = true;
				break;
			}
		}
	}
	if(!validGamemode)
	{
		printl("LCZ E: lcz Precache(): Invalid gamemode name (" + gamemodeName + ") found in BSP file name.");
		return;
	}
	
	mapName = bspFileName.slice(gamemodeEndPos + 1);
	
	if(!EntityGroup)
	{
		printl("LCZ E: lcz Precache(): EntityGroup == null");
		return;
	}
	
	if(!EntityGroup[0])
	{
		printl("LCZ E: lcz Precache(): player_speedmod entity not found.");
		return;
	}
	
	if(!EntityGroup[2])
	{
		printl("LCZ E: lcz Precache(): score manager entity not found.");
		return;
	}
	
	if(!EntityGroup[3])
	{
		printl("LCZ E: lcz Precache(): point_servercommand entity not found.");
		return;
	}
	
	if(!EntityGroup[4])
	{
		printl("LCZ E: lcz Precache(): game_round_end entity not found.");
		return;
	}
	
	speedMod =				EntityGroup[0];
	// Can be null if no default damage filter is required in the level.
	defaultDamageFilter =	EntityGroup[1];
	gameScore =				EntityGroup[2];	
	sc =					EntityGroup[3];
	gameRoundEnd =			EntityGroup[4];
	
	if
	(
		!loadGamemode("lcz") ||
		!loadGamemode(gamemodeName)
	)
		return;
	
	self.PrecacheModel("models/player/custom_player/lcz_v1/plr_invis.mdl");
	self.PrecacheModel("models/player/custom_player/lcz_v1/plr_godmode_ct.mdl");
	self.PrecacheModel("models/player/custom_player/lcz_v1/plr_godmode_t.mdl");
	
	// Array size is increased by first player id offset to make it simpler to use
	players.resize(maxPlayers + plrEntIdOffset, null);
	alivePlayers.resize(maxPlayers + plrEntIdOffset, null);
	playerKV.resize(maxPlayers + plrEntIdOffset, null);
	for(local i = plrEntIdOffset; i < maxPlayers + plrEntIdOffset; i++)
		playerKV[i] = {};
	plrEffects.resize(maxPlayers + plrEntIdOffset, 0);
	plrLifeTokens.resize(maxPlayers + plrEntIdOffset, 0);
	
	eventPlayerSpawnCB.push
	(
		function(playerId)
		{
			if(debug) printl("LCZ I: Player respawn cb: " + playerId);
			// Ensure that no delayed calls will make it to the next life.
			plrLifeTokens[playerId]++;
			// Speed mods are not allowed to transfer to next life
			resetPlayerSpeedMod(playerId);
			// Visual effects are not allowed to transfer to next life
			resetPlayerEffects(playerId);
			// Set default gamemode damage filter
			resetPlayerDamageFilter(playerId);
			// Model itself is automatically reset by the engine to base game default
			if(lcz.hasPlayerKV(playerId, "CustomModel"))
				lcz.removePlayerKV(playerId, "CustomModel");
			// Change player's gravity modifier based on base speed multiplier
			// so that jump duration remains the same as without one.
			// This will result in increased jump height.
			// Speed pickup does not further change this modifier; Neither should anything else.
			// The gravity modifier must stay constant for every player for their entire life duration;
			// otherwise jumppads will miss their targets if gravity mod changes mid-flight.
			alivePlayers[playerId].__KeyValueFromFloat("gravity", 1 / baseSpeedMul);
		}
	);
	
	eventPlayerDeathCB.push
	(
		function(playerId)
		{
			if(debug) printl("LCZ I: Player death cb: " + playerId);
			// Ensure that no delayed calls will make it to the next life.
			plrLifeTokens[playerId]++;
		}
	);
	
	eventCsPreRestartCB.push
	(
		function()
		{
			if(debug) printl("LCZ I: Round pre-restart cb");
			// Reset various states on round restart.
			foreach(id, player in players)
			{
				if(player && player.IsValid())
				{
					local playerId = player.entindex();
					// Ensure that no delayed calls will make it to the next round.
					plrLifeTokens[playerId]++;
					// Speed mods are not allowed to transfer to next round
					resetPlayerSpeedMod(playerId);
					// Visual effects are not allowed to transfer to next round
					resetPlayerEffects(playerId);
					// Set default gamemode damage filter
					resetPlayerDamageFilter(playerId);
				}
			}
		}
	);
	
	initialized = true;
}

/**
 * Loads and applies gamemode-specific settings & logic from provided script.
 *
 * @param	gamemodeName	name of gamemode script file, used to construct the full path.
 *
 * @return	@code true if start-up code and settings were executed successfully, @code false otherwise.
 */
function loadGamemode(gamemodeName)
{
	if(!gamemodeName || gamemodeName.len() == 0)
	{
		if(debug) printl("LCZ E: loadGamemode(): No path supplied, exiting.");
		return false;
	}
	
	local configPath =	scriptBasePath + gamemodeBaseName + gamemodeName + "." + scriptExtension;
	foreach(id, listGamemode in gamemodes)
		if(listGamemode.name == gamemodeName)
		{
			gamemode = listGamemode;
			break;
		}
	
	if(!gamemode.scope)
	{
		if(debug) printl("LCZ E: lcz loadGamemode(): Could not find scope variable for gamemode " + gamemodeName);
		return false;
	}
	
	if(!DoIncludeScript(configPath, gamemode.scope))
	{
		if(debug) printl("LCZ E: lcz loadGamemode(): Could not load config [" + gamemodeName + ", full path: [" + configPath + "]");
		return false;
	}
	if(!gamemode.scope.baseGameSettings)
	{
		if(debug) printl("LCZ E: lcz loadGamemode(): Config file [" + gamemodeName + "], full path: [" + configPath + "] does not contain baseGameSettings table.");
		return false;
	}
	
	foreach(conVarName, conVarValue in gamemode.scope.baseGameSettings)
	{
		if(debug) printl("LCZ I: conVarName: " + conVarName + ", conVarValue: " + conVarValue);
		EntFireByHandle(sc, "Command", conVarName + " " + conVarValue, 0, null, null);
	}
	
	if(gamemode.scope.lczOnGamemodeLoad)
		gamemode.scope.lczOnGamemodeLoad();
	
	return true;
}

function think()
{
	if(!initialized)
		return;
	
	if(announcements.len() != 0 && (!lastAnnouncementTime || Time() - lastAnnouncementTime >= announcementDelay))
	{
		foreach(id, announcement in announcements)
			ScriptPrintMessageChatAll(announcement);
		lastAnnouncementTime = Time();
	}
}

/**
 * Called from the level when game_playerspawn entity is activated.
 */
function lczPlayerSpawn()
{
	if(!initialized)
		return;
	
	if(debug) printl("LCZ I: Event: player_spawn");
	
	// Register any new alive players
	local tempPlayer =	Entities.First();
	local currPlayers =	[];
	// Entities.FindByClassname with "player" class will ONLY return human players, not bots.
	// Unless those bots have a "targetname" field - which neither players nor bots have by default.
	// Good job, Volvo. I bet your programmers' office has Voodoo People playing 24/7.
	while(tempPlayer = Entities.Next(tempPlayer))
		if(tempPlayer.GetClassname() == "player")
			currPlayers.push(tempPlayer);
	
	if(debug) printl("LCZ I: Going through currPlayers (length " + currPlayers.len() + ")")
	foreach(id, player in currPlayers)
	{
		local plrId = player.entindex();
		if(debug) printl("currPlayers -> player " + plrId + ", name: " + player.GetName());
		if(debug) printl("Health: " + player.GetHealth() + ", alive: " + alivePlayers[plrId] + ", team: " + player.GetTeam());
		if(player.GetHealth() > 0 && !alivePlayers[plrId])
		{
			if(!players[plrId])
				players[plrId] = player;
			alivePlayers[plrId] = player;
			// Alert any potential spawn event listeners
			foreach(id, func in eventPlayerSpawnCB)
				func(plrId);
		}
	}
	if(debug) printl("LCZ I: Current players loop: Done");
}

/**
 * Called from the level when game_playerdie entity is activated.
 */
function lczPlayerDeath()
{
	if(!initialized)
		return;
	
	if(debug) printl("LCZ I: game_playerdie");
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczPlayerDeath(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczPlayerDeath(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	if(players[plrId] && alivePlayers[plrId])
	{
		if(lcz.debug) printl("LCZ I: Dead player: " + plrId + ", name: " + players[plrId].GetName());
		// Alert any potential death event listeners
		foreach(id, func in eventPlayerDeathCB)
			func(plrId);
		alivePlayers[plrId] = null;
	}
}

/**
 * Called from the level when player_disconnect event fires.
 */
function lczEventPlayerDisconnect()
{
	if(!initialized)
		return;
	
	if(debug) printl("LCZ I: Event: player_disconnect");
	
	for(local plrId = plrEntIdOffset; plrId < maxPlayers + plrEntIdOffset; plrId++)
		if(players[plrId] && !players[plrId].IsValid())
		{
			// Alert any potential disconnect event listeners
			foreach(id, func in eventPlayerDisconnectCB)
				func(plrId);
			clearPlayerKV(plrId);
			resetPlayerEffects(plrId);
			players[plrId] = null;
			alivePlayers[plrId] = null;
		}
}


/**
 * Called from the level when cs_pre_restart event fires.
 */
function lczEventCsPreRestart()
{
	if(!initialized)
		return;
	
	if(debug) printl("LCZ I: Event: cs_pre_restart");
	
	// Alert any potential restart event listeners
	foreach(id, func in eventCsPreRestartCB)
		func();
	
	// Players must be refilled from player_spawn events in new round
	players.resize(maxPlayers + plrEntIdOffset, null);
	alivePlayers.resize(maxPlayers + plrEntIdOffset, null);
	playerKV.resize(maxPlayers + plrEntIdOffset, null);
	for(local i = plrEntIdOffset; i < maxPlayers + plrEntIdOffset; i++)
		playerKV[i] = {};
	plrEffects.resize(maxPlayers + plrEntIdOffset, 0);
}

/**
 * Called from the level when round_start event fires.
 */
function lczEventRoundStart()
{
	if(!initialized)
		return;
	
	if(debug) printl("LCZ I: Event: round_start");
	
	// Alert any potential round start event listeners
	foreach(id, func in eventRoundStartCB)
		func();
}

/**
 * Adds specified number of points to the player score.
 * Adds to kill count in CS:GO.
 * Accepts negative values.
 *
 * @param	playerId	id of player to add or subtract points from.
 * @param	points		points to add or subtract.
 */
function addScore(playerId, points)
{
	if(!initialized)
		return;
	
	if(!points || points == 0)
	{
		if(debug) printl("LCZ E: lczAddScore(): Points to add not specified or 0, exiting.");
		return;
	}
	
	if(!playerId || playerId < lcz.plrEntIdOffset || playerId > lcz.maxPlayers || !players[playerId])
	{
		if(debug) printl("LCZ E: lczAddScore(): Invalid player id " + playerId + ", exiting.");
		return;
	}
	
	local player = players[playerId];
	
	EntFireByHandle(gameScore, "AddOutput", "points " + points, 0, null, null);
	EntFireByHandle(gameScore, "ApplyScore", "", 0, player, null);
}

/**
 * Prints alert message on HUD and in chat for all players.
 *
 * @param	message	message to print.
 */
function alertMessage(message)
{
	teamAlertMessage(message, 0);
}

/**
 * Adds specified number of points to the team.
 * Accepts negative values.
 *
 * @param	team	id of team to add or subtract points from, 2 = T, 3 = CT.
 * @param	points	points to add or subtract.
 */
function addTeamScore(team, points)
{
	if(!initialized)
		return;
	
	if(!points || points == 0)
	{
		if(debug) printl("LCZ E: lczAddTeamScore(): Points to add not specified or 0, exiting.");
		return;
	}
	
	if(!team || team < 2 || team > 3)
	{
		if(debug) printl("LCZ E: lczAddTeamScore(): Invalid team id " + team + ", exiting.");
		return;
	}
	
	EntFireByHandle(gameScore, "AddOutput", "points " + points, 0, null, null);
	if(team == 2)
		EntFireByHandle(gameScore, "AddScoreTerrorist", "", 0, null, null);
	else
		EntFireByHandle(gameScore, "AddScoreCT", "", 0, null, null);
}

/**
 * Prints alert message on HUD and in chat for all players in team.
 *
 * @param	message	message to print.
 * @param	team	id of team to print message for, 2 = T, 3 = CT. If neither, message is printed for both teams.
 */
function teamAlertMessage(message, team)
{
	if(team != 2 && team != 3)
	{
		ScriptPrintMessageCenterAll(message);
		ScriptPrintMessageChatAll(message);
	}
	else
	{
		ScriptPrintMessageCenterTeam(team, message);
		ScriptPrintMessageChatTeam(team, message);
	}
}

/**
 * Ends the round in a draw.
 *
 * @param	postEndDelay	extra time after round ends.
 */
function roundEndDraw(postEndDelay)
{
	EntFireByHandle(gameRoundEnd, "EndRound_Draw", postEndDelay.tostring(), 0, null, null);
}

/**
 * Ends the round with T victory.
 *
 * @param	postEndDelay	extra time after round ends.
 */
function roundEndTWin(postEndDelay)
{
	EntFireByHandle(gameRoundEnd, "EndRound_TerroristsWin", postEndDelay.tostring(), 0, null, null);
	EntFire("@lcz_t_win", "Trigger", "", 0, null);
}

/**
 * Ends the round with CT victory.
 *
 * @param	postEndDelay	extra time after round ends.
 */
function roundEndCTWin(postEndDelay)
{
	EntFireByHandle(gameRoundEnd, "EndRound_CounterTerroristsWin", postEndDelay.tostring(), 0, null, null);
	EntFire("@lcz_ct_win", "Trigger", "", 0, null);
}

/**
 * Starts a delayed call that can only execute within current life of specified player.
 *
 * After specified delay, a provided callback function will be called optional array of arguments.
 * If argument array is provided, its first member must be reference to calling script scope (this).
 * Delayed execution relies on Source I/O system. 
 *
 * @param	delay				delay after which callback function will be called.
 * @param	playerId			id of player associated with the call.
 * @param	callbackFunction	reference to function to be called after the delay.
 * @param	callbackArgs		optional arguments for callback, must contain 'this' as first element.
 */
function currentLifeDelayedCall(delay, playerId, callbackFunction, callbackArgs)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCall(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!players[playerId] || !players[playerId].IsValid())
	{
		if(debug) printl("LCZ E: currentLifeDelayedCall(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	if(!delay || delay <= 0)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCall(): invalid delay " + delay + ", exiting.");
		return;
	}
	
	if(!callbackFunction)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCall(): No callback function provided, exiting.");
		return;
	}
	
	// Reference to callback function & args will be stored in a table.
	// This is to prevent accidental garbage collection if no other references to this function will remain.
	local cbId = UniqueString();
	delayedCallCode.rawset(cbId, {fn = callbackFunction, args = callbackArgs});
	
	EntFireByHandle
	(
		self,
		"RunScriptCode",
		"_currentLifeDelayedCallFinish(" + playerId + ", " + plrLifeTokens[playerId] + ", \"" + cbId + "\");",
		delay,
		null,
		null
	);
}

/**
 * Internal function, should not be called directly: Finisher for delayed call.
 *
 * @param	playerId		id of player associated with the call.
 * @param	playerLifeToken	life token of the player at the moment when the call was started.
 * @param	callbackId		string identifier of the callback function.
 */
function _currentLifeDelayedCallFinish(playerId, playerLifeToken, callbackId)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!players[playerId] || !players[playerId].IsValid())
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	if(playerLifeToken < 1)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): player life token must be equal or greater than 1, got " + playerLifeToken + ", exiting.");
		return;
	}
	else if(playerLifeToken != plrLifeTokens[playerId])
	{
		if(debug) printl("LCZ I: currentLifeDelayedCallFinish(): call was made with another life token (current: " + plrLifeTokens[playerId] + ", got: " + playerLifeToken + ", ignoring.");
		return;
	}
	
	if(!callbackId || callbackId.len() == 0)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): invalid callback string id, exiting.");
		return;
	}
	
	local callbackFunction = delayedCallCode[callbackId].fn;
	if(!callbackFunction)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): couldn't find callback function, exiting.");
		return;
	}
	local callbackArgs = delayedCallCode[callbackId].args;
	
	if(!callbackArgs)
		callbackFunction();
	else
		callbackFunction.pacall(callbackArgs);
	
	delete delayedCallCode[callbackId];
}

/**
 * Returns lesser of two values.
 *
 * @param	a	first value
 * @param	b	second value
 *
 * @return	lesser value
 */
function min(a, b)
{
	return a < b ? a : b;
}

/**
 * Returns bigger of two values.
 *
 * @param	a	first value
 * @param	b	second value
 *
 * @return	lesser value
 */
function max(a, b)
{
	return a > b ? a : b;
}

/**
 * Compares two vectors on per-component basis.
 *
 * @param	v1	First vector.
 * @param	v2	Second vector.
 *
 * @return	@code true if vectors are equal, @code false otherwise.
 */
function areVectorsEqual(v1, v2)
{
	return v1.x == v2.x && v1.y == v2.y && v1.z == v2.z;
}

// WHAT SHIT I HAVE TO COME UP WITH BECAUSE I CAN'T READ KEYVALUES

/**
 * Adds player keyvalue.
 *
 * Keyvalues are arbitrary key/value pairs stored in a table.
 * Each player has their own keyvalue table.
 * Presence or absence of certain keys, as well their exact values can be used by gamemode logic.
 * @code null values are not allowed.
 *
 * @param	playerId	player entity id
 * @param	newKey		key to add
 * @param	newValue	key value to add
 */
function addPlayerKV(playerId, newKey, newValue)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!newValue)
	{
		if(debug) printl("LCZ E: addPlayerKV(): Cannot add empty value (player: " + playerId + ", key: " + newKey + "), exiting");
		return;
	}
	
	foreach(key, value in playerKV[playerId])
		if(key == newKey)
		{
			if(debug) printl("LCZ W: addPlayerKV(): Keyvalue [" + newKey + "] already exists on player " + playerId + ", ignoring.");
			return;
		}
	
	playerKV[playerId][newKey] <- newValue;
}

/**
 * Sets new value for existing key.
 *
 * @param	playerId	player entity id
 * @param	setKey		key to add
 * @param	setValue	key value to add
 */
function setPlayerKV(playerId, setKey, setValue)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!setValue)
	{
		if(debug) printl("LCZ E: addPlayerKV(): Cannot set empty value (player: " + playerId + ", key: " + setKey + "), exiting");
		return;
	}
	
	foreach(key, value in playerKV[playerId])
		if(key == setKey)
		{
			playerKV[playerId][setKey] <- setValue;
			return;
		}
	
	if(debug) printl("LCZ W: addPlayerKV(): Key [" + setKey + "] not found on player " + playerId);
}

/**
 * Removes player keyvalue.
 *
 * @param	playerId	player entity id
 * @param	removeKV	name of key to remove
 */
function removePlayerKV(playerId, removeKey)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	foreach(key, value in playerKV[playerId])
		if(key == removeKey)
		{
			delete playerKV[playerId][removeKey];
			return;
		}
	
	if(debug) printl("LCZ W: removePlayerKV(): Keyvalue [" + removeKey + "] not found on player " + playerId + ".");
}

/**
 * Removes all player keyvalues.
 *
 * @param	playerId	player entity id
 */
function clearPlayerKV(playerId)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	playerKV[playerId].clear();
}

/**
 * Checks whether player has specified keyvalue.
 *
 * @param	playerId	player entity id
 * @param	checkKV		keyvalue to check
 *
 * @return	@code true if player has the keyvalue, @code false otherwise.
 */
function hasPlayerKV(playerId, checkKey)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): Script has not been successfully initialized, exiting.");
		return false;
	}
	
	foreach(key, value in playerKV[playerId])
		if(key == checkKey)
			return true;
	
	return false;
}

/**
 * Retrieves player keyvalue.
 *
 * @param	playerId	player entity id
 * @param	getKey		key to get value of
 *
 * @return	value if key was found, @code null otherwise.
 */
function getPlayerKV(playerId, getKey)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: currentLifeDelayedCallFinish(): Script has not been successfully initialized, exiting.");
		return null;
	}
	
	foreach(key, value in playerKV[playerId])
		if(key == getKey)
			return value;
	
	if(debug) printl("LCZ W: getPlayerKV(): Key " + getKey + " not found for player " + playerId + ", returning null");
	
	return null;
}

/**
 * Retrieves prefix from a full name using base name.
 * Useful in instanced entities if they need to know their instance prefix.
 *
 * @param	name		Full name.
 * @param	baseName	Base name.
 *
 * @return	Extracted prefix or @code null if input was null or name does not contain baseName.
 */
function getPrefix(name, baseName)
{
	if(!name || !baseName)
		return null;
	
	local namePrefixEnd = name.find(baseName);
	if(!namePrefixEnd)
		return null;
	
	return name.slice(0, namePrefixEnd);
}

/**
 * Retrieves postfix from a full name using base name.
 * Useful in instanced entities if they need to know their instance postfix.
 *
 * @param	name		Full name.
 * @param	baseName	Base name.
 *
 * @return	Extracted postfix or @code null if input was null or
 *			name does not contain baseName.
 */
function getPostfix(name, baseName)
{
	if(!name || !baseName)
		return null;
	
	local namePostfixStart = name.find(baseName);
	if(!namePostfixStart)
		return null;
	
	namePostfixStart += baseName.len();
	
	return name.slice(namePostfixStart);
}

/**
 * Given a full name & base name of one entity inside instance, finds all entities in this instance.
 * 
 * @param	entFullName	Full entity name.
 * @param	entBase		Base entity name, as it appears inside instance VMF file.
 * 
 * @return	Array of entities in this instance or @code null if input was null or
 *			entFullName does not contain entBaseName.
 */
function findInstanceEnts(entFullName, entBaseName)
{
	if(!entFullName || !entBaseName)
		return null;
	
	local namePrefix = getPrefix(entFullName, entBaseName);
	local namePostfix = getPostfix(entFullName, entBaseName);
	local currEnt = null;
	while((currEnt = Entities.Next(currEnt)))
	{
		if(namePrefix && !currEnt.GetName().find(namePrefix))
			continue;
		if(namePostfix && !currEnt.GetName().find(namePostfix))
			continue;
		instanceEnts.push(currEnt);
	}
}

/**
 * Convenience function to kill several entities.
 *
 * @param	ents	Array of entities to kill.
 */
function killEnts(ents)
{
	if(!ents)
	{
		if(debug) printl("LCZ E: killEnts(): ents == null, exiting.");
		return null;
	}
	
	foreach(id, ent in ents)
	{
		EntFireByHandle(ent, "Kill", "", 0, null, null);
	}
}

/**
 * Adds effect to "effects" field containing bit flags for various visual entity effects.
 * Known effects working in CS:GO are:
 * 4: Flashlight (emitted from player feet in thirdperson).
 * 32: Disable draw. As of latest tests affects player weapons, too. Can be used for invisibility.
 * Does not affect your own model in thirdperson, only those of other players.
 *
 * Directly reading entity keyvalues is not possible (nice scripting support volvo),
 * so I have to use backing buffers.
 *
 * @param	playerId	player entity id
 * @param	effectId	one or more bitwise effect IDs
 */
function addPlayerEffect(playerId, effectId)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: addPlayerEffect(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!players[playerId] || !players[playerId].IsValid())
	{
		if(debug) printl("LCZ E: addPlayerEffect(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	if(!alivePlayers[playerId])
	{
		if(debug) printl("LCZ W: addPlayerEffect(): player with id \"" + playerId + "\" is dead, exiting.");
		return;
	}
	
	plrEffects[playerId] = plrEffects[playerId] | effectId;
	players[playerId].__KeyValueFromInt("effects", plrEffects[playerId]);
}

/**
 * Removes one or more player visual effects.
 *
 * @param	playerId		player entity id
 * @param	effectId		one or more bitwise effect IDs
 */
function removePlayerEffect(playerId, effectId)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: removePlayerEffect(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!players[playerId] || !players[playerId].IsValid())
	{
		if(debug) printl("LCZ E: removePlayerEffect(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	if(effectId == 0)
	{
		if(debug) printl("LCZ E: removePlayerEffect(): no effect code (effectId == 0), exiting.");
		return;
	}
	
	plrEffects[playerId] = plrEffects[playerId] & ~effectId;
	players[playerId].__KeyValueFromInt("effects", plrEffects[playerId]);
}

/**
 * Removes all player visual effects.
 *
 * @param	playerId		player entity id
 */
function resetPlayerEffects(playerId)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: resetPlayerEffects(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	// No player validity check, reset effects can be called from death or disconnect event handlers.
	if(!players[playerId])
	{
		if(debug) printl("LCZ E: resetPlayerEffects(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	plrEffects[playerId] = 0;
	if(players[playerId].IsValid())
		players[playerId].__KeyValueFromInt("effects", plrEffects[playerId]);
}

/**
 * Sets player speed multiplier value.
 *
 * Speed multiplier is applied for set duration and reverted to gamemode default afterwards.
 * Additionally, sets player's gravity to be proportionally lower in such a manner that
 * jumps still take the same time. This results in higher overall jump height, though.
 *
 * TODO: Review logic?
 *
 * @param	playerId	player entity id
 * @param	multiplier	speed multiplier, where 0 is full stop and 1 is normal speed
 */
function setPlayerSpeedMod(playerId, multiplier)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: setPlayerSpeedMod(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!players[playerId] || !players[playerId].IsValid())
	{
		if(debug) printl("LCZ E: setPlayerSpeedMod(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	if(!alivePlayers[playerId])
	{
		if(debug) printl("LCZ W: setPlayerSpeedMod(): player with id \"" + playerId + "\" is dead, exiting.");
		return;
	}
	
	if(multiplier != baseSpeedMul)
		addPlayerKV(playerId, "CustomSpeedMod", multiplier);
	
	local plr = players[playerId];
	
	EntFireByHandle(speedMod, "ModifySpeed", multiplier.tostring(), 0, plr, plr);
	// Player gravity could be modified so that overall length of jump remains the same.
	// However, this causes problems with jumppads, as they take player gravity mod into account:
	// If this modifier expires mid-flight, player will not land at intended destination point.
	//plr.__KeyValueFromFloat("gravity", 1 / multiplier);
}

/**
 * Reverts player speed multiplier to gamemode default.
 *
 * @param	playerId		player entity id
 */
function resetPlayerSpeedMod(playerId)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: resetPlayerSpeedMod(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!players[playerId] || !players[playerId].IsValid())
	{
		if(debug) printl("LCZ E: resetPlayerSpeedMod(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	local plr = players[playerId];
	
	EntFireByHandle(speedMod, "ModifySpeed", baseSpeedMul.tostring(), 0, plr, plr);
	plr.__KeyValueFromFloat("gravity", 1 / baseSpeedMul);
	
	removePlayerKV(playerId, "CustomSpeedMod");
}

/**
 * Sets player damage filter.
 *
 * Damage filter is applied for set duration and reverted to gamemode default afterwards.
 *
 * @param	playerId		player entity id
 * @param	damageFilter	damage filter entity
 */
function setPlayerDamageFilter(playerId, damageFilter)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: setPlayerDamageFilter(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!players[playerId] || !players[playerId].IsValid())
	{
		if(debug) printl("LCZ E: setPlayerDamageFilter(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	if(!alivePlayers[playerId])
	{
		if(debug) printl("LCZ W: setPlayerDamageFilter(): player with id \"" + playerId + "\" is dead, exiting.");
		return;
	}
	
	if(!damageFilter)
	{
		if(debug) printl("LCZ E: setPlayerDamageFilter(): no damage filter entity passed, exiting.");
		return;
	}
	
	addPlayerKV(playerId, "CustomDamageFilter", damageFilter);
	
	EntFireByHandle
	(
		players[playerId],
		"SetDamageFilter",
		damageFilter.GetName(),
		0,
		null,
		null
	);
}

/**
 * Resets player damage filter to gamemode default one.
 *
 * @param	playerId	player entity id
 */
function resetPlayerDamageFilter(playerId)
{
	if(!initialized)
	{
		if(debug) printl("LCZ E: lczGodmodeReset(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!players[playerId] || !players[playerId].IsValid())
	{
		if(debug) printl("LCZ E: lczGodmodeReset(): player with id \"" + playerId + "\" not found, exiting.");
		return;
	}
	
	EntFireByHandle
	(
		players[playerId],
		"SetDamageFilter",
		defaultDamageFilter ? defaultDamageFilter.GetName() : "",
		0,
		null,
		null
	);
	
	removePlayerKV(playerId, "CustomDamageFilter");
}
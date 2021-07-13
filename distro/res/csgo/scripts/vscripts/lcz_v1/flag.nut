/**
 * CTF flag library.
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

initialized <-	false;

flagModel <-		null;
flagAnchor <-		null;
flagTrigger <-		null;
flagUpright <-		null;
flagTemplate <-		null;
flagMeasure <-		null;
flagSound <-		null;
flagRetSound <-		null;
flagDropSound <-	null;

entPrefix <-	"";
entPostfix <-	"";
selfFullName <-	null;
flagEntNames <-
[
	"flag_script",
	"flag_model",
	"flag_anchor",
	"flag_trigger",
	"flag_upright",
	"flag_parent"
];

// Functions called when all the flag entites have been respawned and re-initialized
flagEntsRespawnedCB <-	[];

// At which points in remaining time of flag lying on the ground to show chat alerts.
// Time marks must not be closer than 0.5s to each other.
flagReturnTimeMarks <-
[
	// Remaining time / Alerted status
	{
		time =		120,
		alerted =	false
	},
	{
		time =		60,
		alerted =	false
	},
	{
		time =		30,
		alerted =	false
	},
	{
		time =		15,
		alerted =	false
	},
	{
		time =		5,
		alerted =	false
	},
];

lastThinkTime <-	null;
thinkDelta <-		null;
flagTeam <-			null;
flagStartPos <-		null;
flagCarried <-		false;
flagInSpawn <-		false;
flagDroppedTime <-	0;
lastCarrierId <-	0;

/**
 * Returns full entity name (with prefix & postfix) based on base name.
 *
 * @param	name	Base entity name.
 *
 * @return	Full entity name.
 */
function getEntFullName(name)
{
	return entPrefix + name + entPostfix;
}

/**
 * Called when player touches the flag trigger.
 *
 * @param	flagOwnerTeam	Number of team that this flag belongs to, 2 = T, 3 = CT;
 */
function lczFlagTouch(flagOwnerTeam)
{
	if(lcz.debug) printl("Flag touch");
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczFlagTouch(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!lcz.gamemode || lcz.gamemode.name != "ctf")
	{
		if(lcz.debug) printl("LCZ E: lczCZTouch(): Expected ctf gamemode, current gamemode is \"" +
			lcz.gamemode ? lcz.gamemode.name : "null" + "\", exiting.");
		return;
	}
	
	if(flagCarried)
	{
		if(lcz.debug) printl("LCZ E: lczFlagTouch(): Flag is already being carried, ignoring.");
		return;
	}
	
	// There really isn't a team with id higher than 3 at the moment.
	// But who knows what Volvo might come up with in the future?
	if(flagOwnerTeam < 2 || flagOwnerTeam > 3)
	{
		 if(lcz.debug) printl("LCZ E: lczFlagTouch(): Flag must belong to T or CT, got team number " + flagOwnerTeam + ", exiting.");
		 return;
	}
	flagTeam = flagOwnerTeam;
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczFlagTouch(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczFlagTouch(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	local playerTeam = activator.GetTeam();
	if(playerTeam < 2 || playerTeam > 3)
	{
		if(lcz.debug) printl("LCZ I: lczFlagTouch(): Player " + plrId + " has wrong team id (" + playerTeam + ") to pick up the flag, ignoring.");
		return;
	}
	
	if(playerTeam == flagOwnerTeam)
	{
		if(lcz.gamemode.scope.canReturnOwnFlag && !flagInSpawn && !flagCarried)
		{
			lcz.alertMessage((flagOwnerTeam == 2 ? "Terrorist" : "Counter-Terrorist") + "s returned their flag!");
			
			lcz.addScore(plrId, lcz.gamemode.scope.playerReturnReward);
			lcz.addTeamScore(playerTeam, lcz.gamemode.scope.teamReturnReward);
			
			returnFlagToSpawn(false);
		}
		else
			if(lcz.debug) printl("LCZ I: lczFlagTouch(): Player " + plrId + " has wrong team id (" + playerTeam + ") to return the flag, ignoring.");
		
		return;
	}
	
	if(lcz.hasPlayerKV(plrId, "CTFFlagCarried"))
	{
		if(lcz.debug) printl("LCZ I: lczFlagTouch(): Player " + plrId + " is already carrying a flag, ignoring.");
		return;
	}
	
	EntFireByHandle(flagTrigger, "Disable", "", 0, null, null);
	lcz.addPlayerKV(plrId, "CTFFlagCarried", self.GetScriptScope());
	
	// Parenting through player name is not perfectly reliable; Other code or entites can change it.
	// However, there's no way to pass new parent by handle.
	//
	// T
	//  H
	//    A
	//       N
	//           K
	//                S
	//
	//                V
	//               O
	//             L
	//          V
	//      O
	// <3
	//
	local playerName =		activator.GetName();
	local playerPrevName =	playerName;
	activator.__KeyValueFromString("targetname", (playerName = UniqueString()))
	
	EntFireByHandle(flagModel, "SetParent", playerName, 0, null, null);
	EntFireByHandle(flagMeasure, "SetMeasureTarget", playerName, 0, null, null);
	
	EntFireByHandle(activator, "AddOutput", "targetname " + playerPrevName, 0, null, null);
	EntFireByHandle(flagModel, "SetParentAttachment", "grenade0", 0, null, null);
	
	EntFireByHandle(flagModel, "SetBodyGroup", "0", 0, null, null);
	
	EntFireByHandle(flagMeasure, "Enable", "", 0, null, null);
	
	EntFireByHandle(flagSound, "PlaySound", "", 0, null, null);
	
	moveAnchorOutside();
	
	resetFlagGlow(true);
	
	lcz.alertMessage((flagOwnerTeam == 2 ? "Terrorist" : "Counter-Terrorist") + " flag taken!");
	
	if(flagInSpawn)
	{
		if(flagOwnerTeam == 2)
			lcz.gamemode.scope.missingFlagsT++;
		else
			lcz.gamemode.scope.missingFlagsCT++;
	}
	
	lastCarrierId =		plrId;
	flagDroppedTime =	0;
	flagInSpawn =		false;
	flagCarried =		true;
}

/**
 * Drops flag from the player
 *
 * @param	dropPos	Vector position at which to drop flag.
 */
function dropFlag(dropPos)
{
	if(lcz.debug) printl("Dropping flag");
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: dropFlag(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!flagCarried)
	{
		if(lcz.debug) printl("LCZ E: dropFlag(): Flag is not being carried, exiting.");
		return;
	}
	
	EntFireByHandle(flagMeasure, "Disable", "", 0, null, null);
	
	EntFireByHandle(flagModel, "ClearParent", "", 0, null, null);
	EntFireByHandle(flagModel, "SetBodyGroup", "1", 0, null, null);
	
	local returnToSpawn = lcz.areVectorsEqual(dropPos, flagStartPos);
	if(!returnToSpawn)
	{
		EntFireByHandle(flagDropSound, "PlaySound", "", 0, null, null);
		// Move physics anchor to the player position via teleport
		EntFireByHandle(flagAnchor, "RunScriptCode", "self.SetAngles(0, 0, 0);", 0, null, null);
		EntFireByHandle
		(
			flagAnchor,
			"RunScriptCode",
			"self.SetOrigin(Vector(" +
			dropPos.x + ", " +
			dropPos.y + ", " +
			dropPos.z + "))",
			0, null, null
		);
		EntFireByHandle(flagAnchor, "Wake", "", 0, null, null);
		EntFireByHandle(flagUpright, "TurnOn", "", 0, null, null);
		// Move flag model with children to the player position
		EntFireByHandle(flagModel, "RunScriptCode", "self.SetAngles(0, 0, 0);", 0, null, null);
		EntFireByHandle
		(
			flagModel,
			"AddOutput",
			"origin " +
			dropPos.x + " " +
			dropPos.y + " " +
			dropPos.z,
			0, null, null
		);
		// Attach model to physics anchor
		// Delay is required because newly awakened prop_physics(_multiplayer)
		// will briefly teleport to its position previous to hibernating, then snap back
		// into new position. Quality coding, Vo-- ugh, I'm repeating myself way too much.
		// This delay will probably need to be raised for < 64 tickrate servers with alternate ticks
		// (who'd run such a server?):
		// 1 frame at 32 ticks = 0.03125s
		EntFireByHandle(flagModel, "SetParent", flagAnchor.GetName(), 0.04, null, null);
	}
	else
		returnFlagToSpawn(false);
	
	resetFlagGlow(false);
	
	EntFireByHandle(flagTrigger, "Enable", "", lcz.gamemode.scope.flagReactivateTime, null, null);
	
	if(lastCarrierId > 0)
		lcz.removePlayerKV(lastCarrierId, "CTFFlagCarried");
	
	foreach(id, timeMark in flagReturnTimeMarks)
		timeMark.alerted = false;
	
	lastCarrierId =	0;
	flagCarried =	false;
}

/**
 * Teleports dropped flag back to spawn.
 */
function returnFlagToSpawn(notify)
{
	if(lcz.debug) printl("Returning flag to spawn");
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: returnFlagToSpawn(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(flagInSpawn)
	{
		if(lcz.debug) printl("LCZ E: returnFlagToSpawn(): Flag is already in spawn, exiting.");
		return;
	}
	
	foreach(id, timeMark in flagReturnTimeMarks)
		timeMark.alerted = false;
	
	EntFireByHandle(flagMeasure, "Disable", "", 0, null, null);
	
	if(flagModel.GetMoveParent())
		EntFireByHandle(flagModel, "ClearParent", "", 0, null, null);
	
	EntFireByHandle(flagModel, "SetBodyGroup", "1", 0, null, null);
	
	EntFireByHandle(flagModel, "AddOutput", "angles 0 0 0", 0, null, null);
	EntFireByHandle
	(
		flagModel,
		"AddOutput",
		"origin " +
		flagStartPos.x + " " +
		flagStartPos.y + " " +
		flagStartPos.z,
		0, null, null
	);
	
	if(!flagCarried)
	{
		EntFireByHandle(flagUpright, "TurnOff", "", 0, null, null);
		// AddOutput origin x y z & angles x y z won't work on prop_physics:
		// On the next frame position & angles will be reset to whatever they were before.
		// SetOrigin and SetAngles seem to work, though.
		EntFireByHandle(flagAnchor, "RunScriptCode", "self.SetAngles(0, 0, 0)", 0, null, null);
		moveAnchorOutside();
	}
	
	resetFlagGlow(false);
	
	if(notify)
	{
		EntFireByHandle(flagRetSound, "PlaySound", "", 0, null, null);
		lcz.alertMessage((flagTeam == 2 ? "Terrorist" : "Counter-Terrorist") + " flag returned!");
	}
	
	if(lastCarrierId > 0)
		lcz.removePlayerKV(lastCarrierId, "CTFFlagCarried");
	
	lastCarrierId =	0;
	flagCarried =	false;
	flagInSpawn =	true;
	
	if(flagTeam == 2)
		lcz.gamemode.scope.missingFlagsT--;
	else
		lcz.gamemode.scope.missingFlagsCT--;
}

/**
 * Moves the flag anchor physics object outside the level.
 */
function moveAnchorOutside()
{
	EntFireByHandle
	(
		flagAnchor,
		"RunScriptCode",
		"self.SetOrigin(Vector(0, 0, 16383))",
		0, null, null
	);
	EntFireByHandle(flagAnchor, "Wake", "", 0, null, null);
	EntFireByHandle(flagAnchor, "Sleep", "", 0.1, null, null);
}

/**
 * Reactivates flag model glow.
 * The need for this action arises from retarded handling
 * of prop_dynamic_glow in CS:GO code:
 * When prop with active glow is moved outside of player's PVS,
 * the glowing outline stays in the old position (the model itself isn't shown).
 * Re-enabling the glow resets it to the actual prop position.
 * 
 * Oh, and if prop isn't in PVS, its glow won't be shown, too.
 * Apparently all this crap was only ever tested with unmoving props.
 * 
 * G
 * G
 * V O L V O
 *
 * @param	flagCarried	if true, resets flag glow to carried glow state, otherwise resets to dropped.
 */
function resetFlagGlow(flagCarried)
{
	EntFireByHandle(flagModel, "SetGlowDisabled", "", 0, null, null);
	// If enable output is fired without delay, glow will reappear only after
	// prop exits and re-enters PVS.
	// volvo WHAT THE FUCK
	if
	(
		flagCarried && lcz.gamemode.scope.flagGlowWhenCarried ||
		!flagCarried && lcz.gamemode.scope.flagGlowWhenDropped
	)
		EntFireByHandle(flagModel, "SetGlowEnabled", "", 0.05, null, null);
}

/**
 * Sets dropped flag glowing state to
 * whatever it's configured to be in CTF mode settings.
 * 
 * @param	delay	Delay after which to disable or enable glow.
 */
function setFlagGlowDropped(delay)
{
	EntFireByHandle
	(
		flagModel,
		lcz.gamemode.scope.flagGlowWhenDropped ?
			"SetGlowEnabled" :
			"SetGlowDisabled",
		"",
		delay,
		null,
		null
	);
}

/**
 * Sets picked up flag glowing state to
 * whatever it's configured to be in CTF mode settings.
 * 
 * @param	delay	Delay after which to disable or enable glow.
 */
function setFlagGlowCarried()
{
	EntFireByHandle
	(
		flagModel,
		lcz.gamemode.scope.flagGlowWhenCarried ?
			"SetGlowEnabled" :
			"SetGlowDisabled",
		"",
		delay,
		null,
		null
	);
}

/**
 * Called every ~0.1 seconds by VM.
 * Exact time elapsed between invocations will depend on server tickrate & load.
 */
function think()
{
	if(!initialized || !flagModel.IsValid())
		return;
	
	thinkDelta = Time() - lastThinkTime;
	
	if(!flagCarried && !flagInSpawn)
	{
		flagDroppedTime += thinkDelta;
		local remainingTime = lcz.gamemode.scope.flagDropTimeout - flagDroppedTime;
		foreach(id, timeMark in flagReturnTimeMarks)
			// A little bit crude... message might be skipped in case of some extreme lag.
			if
			(
				!timeMark.alerted &&
				remainingTime - 0.25 <= timeMark.time &&
				remainingTime + 0.25 >= timeMark.time
			)
			{
				timeMark.alerted = true;
				lcz.alertMessage((flagTeam == 2 ? "Terrorist" : "Counter-Terrorist") + " flag returns in " + timeMark.time + "s!");
				break;
			}
		if(remainingTime <= 0)
		{
			if(lcz.debug) printl("LCZ I: Need to return flag");
			
			returnFlagToSpawn(true);
		}
	}
	
	lastThinkTime = Time();
}

/**
 * Checks whether any flag ents need a respawn,
 * either after carrier player disconnect or a direct removal.
 *
 * @return	@code true if respawn is needed, @false otherwise.
 */
function isRespawnNeeded()
{
	if
	(
		flagModel && flagModel.IsValid() &&
		flagAnchor && flagAnchor.IsValid() &&
		flagTrigger && flagTrigger.IsValid() &&
		flagUpright && flagUpright.IsValid()
	)
		return false;
	
	return true;
}

/**
 * Starts the flag entities respawn & re-initialization process.
 */
function respawnFlag(notify)
{
	initialized = false;
	
	if(flagModel && flagModel.IsValid())
		EntFireByHandle(flagModel, "Kill", "", 0, null, null);
	flagModel = null;
	
	if(flagAnchor && flagAnchor.IsValid())
		EntFireByHandle(flagAnchor, "Kill", "", 0, null, null);
	flagAnchor = null;
	
	if(flagTrigger && flagTrigger.IsValid())
		EntFireByHandle(flagTrigger, "Kill", "", 0, null, null);
	flagTrigger = null;
	
	if(flagUpright && flagUpright.IsValid())
		EntFireByHandle(flagUpright, "Kill", "", 0, null, null);
	flagUpright = null;
	
	if(notify)
	{
		EntFireByHandle(flagRetSound, "PlaySound", "", 0, null, null);
		lcz.alertMessage((flagTeam == 2 ? "Terrorist" : "Counter-Terrorist") + " flag respawned!");
	}
	
	EntFireByHandle(flagTemplate, "ForceSpawn", "", 0, null, null);
}

/**
 * Called by point_template when flag entities have been respawned.
 */
function flagEntsRespawned()
{
	if(!selfFullName)
	{
		if(lcz.debug) printl("LCZ E: flagEntsRespawned(): Couldn't find name of logic_script entity, exiting.");
		return;
	}
	
	flagModel <-	Entities.FindByName(null, getEntFullName(flagEntNames[1]));
	flagAnchor <-	Entities.FindByName(null, getEntFullName(flagEntNames[2]));
	flagTrigger <-	Entities.FindByName(null, getEntFullName(flagEntNames[3]));
	flagUpright <-	Entities.FindByName(null, getEntFullName(flagEntNames[4]));
	
	if
	(
		!flagModel ||
		!flagAnchor ||
		!flagTrigger ||
		!flagUpright
	)
	{
		if(lcz.debug) printl("LCZ E: flagEntsRespawned(): Not all flag entities were found, exiting.");
		return;
	}
	
	EntFireByHandle(flagAnchor, "SetBodyGroup", "1", 0, null, null);
	
	EntFireByHandle
	(
		flagAnchor,
		"AddOutput",
		"OnUser4 " + selfFullName + ":RunScriptCode:returnFlagToSpawn(true):0.5:-1",
		0, null, null
	);
	
	EntFireByHandle(flagTrigger, "SetParent", flagModel.GetName(), 0, null, null);
	
	setFlagGlowDropped(0);
	
	initialized = true;
	
	foreach(id, func in flagEntsRespawnedCB)
		func();
}

function Precache()
{
	if(!EntityGroup)
	{
		printl("LCZ E: flag Precache(): EntityGroup == null");
		return;
	}
	
	selfFullName = self.GetName();
	// Find base script entity name
	local selfBaseNamePos =	selfFullName.find(flagEntNames[0]);
	
	local selfFullNameLen =	selfFullName.len();
	local selfBaseNameLen =	flagEntNames[0].len();
	local entPrefixLen =	0;
	
	if(selfBaseNamePos > 0)
	{
		entPrefix =		selfFullName.slice(0, selfBaseNamePos);
		entPrefixLen =	entPrefix.len();
	}
	
	local entPostfixStart = entPrefixLen + selfBaseNameLen;
	if(entPostfixStart < selfFullNameLen)
		entPostfix = selfFullName.slice(entPostfixStart);
	
	flagTemplate =	EntityGroup[0];
	flagMeasure =	EntityGroup[3];
	flagSound =		EntityGroup[4];
	flagRetSound =	EntityGroup[5];
	flagDropSound =	EntityGroup[6];
	
	if(!flagTemplate || !flagMeasure || !flagSound || !flagRetSound || !flagDropSound)
	{
		printl("LCZ E: flag Precache(): Not all entities have been found, exiting.");
		return;
	}
	
	EntFireByHandle(flagMeasure, "Disable", "", 0, null, null);
	
	flagStartPos =	self.GetOrigin();
	flagInSpawn =	true;
	
	lastThinkTime =	Time();
	
	// Sets initialized to true
	respawnFlag(false);
}
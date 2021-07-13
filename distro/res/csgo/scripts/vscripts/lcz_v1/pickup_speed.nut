/**
 * Speed pickup library.
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

initialized <- false;

speedTrigger <-		null;
speedModel <-		null;
speedSpawnEffect <-	null;
speedSpawnSound <-	null;
speedPickupSound <-	null;

speedRespawnTime <-	30;
speedDuration <-	10;
speedMultiplier <-	2.5;

/**
 * Activates speed pickup modifier for player for certain duration.
 *
 * Since there's no way to read arbitrary entity values (I won't ever tire of thanking you, Volvo),
 * this code is not compatible with anything else that modifies player speed multiplier or gravity.
 */
function lczSpeedPickup()
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczSpeedPickup(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczSpeedPickup(): activator == null");
		return;
	}
	
	local plrId = activator.entindex();
	if(plrId < 1 || plrId > lcz.maxPlayers)
	{
		if(lcz.debug) printl("LCZ E: lczSpeedPickup(): Expected player activator, got entity id [" + plrId + "].");
		return;
	}
	
	if(lcz.hasPlayerKV(plrId, "CustomSpeedMod"))
	{
		if(lcz.debug) printl("LCZ I: lczSpeedPickup(): Speed mod already active on player " + plrId + ", ignoring.");
		return;
	}
	
	lcz.setPlayerSpeedMod(plrId, speedMultiplier);
	lcz.currentLifeDelayedCall
	(
		speedDuration,
		plrId,
		// Callback function
		function(playerId)
		{
			lcz.resetPlayerSpeedMod(playerId);
		},
		// Array of callback arguments
		// Must include 'this' as first argument
		[this, plrId]
	);
	
	EntFireByHandle(speedTrigger, "Disable", "", 0, null, null);
	EntFireByHandle(speedModel, "TurnOff", "", 0, null, null);
	EntFireByHandle(speedSpawnEffect, "Stop", "", 0, null, null);
	EntFireByHandle(speedPickupSound, "PlaySound", "", 0, null, null);
	
	EntFireByHandle(speedTrigger, "Enable", "", speedRespawnTime, null, null);
	EntFireByHandle(speedModel, "TurnOn", "", speedRespawnTime, null, null);
	EntFireByHandle(speedSpawnEffect, "Start", "", speedRespawnTime, null, null);
	EntFireByHandle(speedSpawnSound, "PlaySound", "", speedRespawnTime, null, null);
}

function Precache()
{
	if(!EntityGroup)
	{
		printl("LCZ E: pickup_speed Precache(): EntityGroup == null");
		return;
	}
	
	for(local i = 0; i <= 4; i++)
		if(!EntityGroup[i])
		{
			printl("LCZ E: pickup_speed Precache(): EntityGroup[" + i + "] == null");
			return;
		}
	
	speedTrigger =		EntityGroup[0];
	speedModel =		EntityGroup[1];
	speedSpawnEffect =	EntityGroup[2];
	speedSpawnSound =	EntityGroup[3];
	speedPickupSound =	EntityGroup[4];
	
	initialized = true;
}
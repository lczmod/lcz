/**
 * Weapon pickup library.
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

weaponEquip <-			null;
weaponModel <-			null;
weaponTrigger <-		null;
weaponSpinModel <-		null;
weaponSpawnEffect <-	null;
weaponSpawnSound <-		null;
weaponPickupSound <-	null;

weaponRespawnTime <-	10;

/**
 * Provides activator player with certain weapon (set in game_player_equip entity).
 */
function lczWeaponPickup(weaponTeam)
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczWeaponPickup(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczWeaponPickup(): activator == null");
		return;
	}
	
	local playerTeam = activator.GetTeam();
	
	// Player has to be in the team associated with weapon for skins to work
	if(weaponTeam != -1 && playerTeam != weaponTeam)
		EntFireByHandle(activator, "AddOutput", "teamnumber " + weaponTeam, 0, activator, null);
	
	EntFireByHandle(weaponEquip, "Use", "", 0, activator, null);
	EntFireByHandle(weaponModel, "TurnOff", "", 0, null, null);
	EntFireByHandle(weaponTrigger, "Disable", "", 0, null, null);
	EntFireByHandle(weaponSpawnEffect, "Stop", "", 0, null, null);
	EntFireByHandle(weaponPickupSound, "PlaySound", "", 0, null, null);
	
	if(weaponTeam != -1 && playerTeam != weaponTeam)
		EntFireByHandle(activator, "AddOutput", "teamnumber " + playerTeam, 0, null, null);
	
	EntFireByHandle(weaponTrigger, "Enable", "", weaponRespawnTime, null, null);
	EntFireByHandle(weaponModel, "TurnOn", "", weaponRespawnTime, null, null);
	EntFireByHandle(weaponSpawnEffect, "Start", "", weaponRespawnTime, null, null);
	EntFireByHandle(weaponSpawnSound, "PlaySound", "", weaponRespawnTime, null, null);
}

function Precache()
{
	if(!EntityGroup)
	{
		printl("LCZ E: pickup_weapon Precache(): EntityGroup == null");
		return;
	}
	
	for(local i = 0; i <= 6; i++)
		if(!EntityGroup[i])
		{
			printl("LCZ E: pickup_weapon Precache(): EntityGroup[" + i + "] == null");
			return;
		}
	
	weaponEquip =		EntityGroup[0];
	weaponModel =		EntityGroup[1];
	weaponTrigger =		EntityGroup[2];
	weaponSpinModel =	EntityGroup[3];
	weaponSpawnEffect =	EntityGroup[4];
	weaponSpawnSound =	EntityGroup[5];
	weaponPickupSound =	EntityGroup[6];
	
	EntFireByHandle(weaponSpinModel, "SetBodyGroup", "1", 0, null, null);
	EntFireByHandle(weaponModel, "SetParent", weaponSpinModel.GetName(), 0, null, null);
	// Slight delay is required, otherwise - for whatever reason - the model gets rotated for 90 degrees CW along the X axis of attachment.
	EntFireByHandle(weaponModel, "SetParentAttachmentMaintainOffset", "itempos", 0.1, null, null);
	
	initialized = true;
}
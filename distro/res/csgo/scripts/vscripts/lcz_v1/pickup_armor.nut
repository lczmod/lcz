/**
 * Armor pickup library.
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

armorEquip <-		null;
armorModel <-		null;
armorTrigger <-		null;
armorSpawnEffect <-	null;
armorSpawnSound <-	null;
armorPickupSound <-	null;

armorRespawnTime <-	30;

/**
 * Provides activator player with item_assaultsuit (set in game_player_equip entity).
 */
function lczArmorPickup()
{
	if(!initialized)
	{
		if(lcz.debug) printl("LCZ E: lczArmorPickup(): Script has not been successfully initialized, exiting.");
		return;
	}
	
	if(!activator)
	{
		if(lcz.debug) printl("LCZ E: lczArmorPickup(): activator == null");
		return;
	}
	
	EntFireByHandle(armorEquip, "Use", "", 0, activator, null);
	EntFireByHandle(armorModel, "TurnOff", "", 0, null, null);
	EntFireByHandle(armorTrigger, "Disable", "", 0, null, null);
	EntFireByHandle(armorSpawnEffect, "Stop", "", 0, null, null);
	EntFireByHandle(armorPickupSound, "PlaySound", "", 0, null, null);
	
	EntFireByHandle(armorTrigger, "Enable", "", armorRespawnTime, null, null);
	EntFireByHandle(armorModel, "TurnOn", "", armorRespawnTime, null, null);
	EntFireByHandle(armorSpawnEffect, "Start", "", armorRespawnTime, null, null);
	EntFireByHandle(armorSpawnSound, "PlaySound", "", armorRespawnTime, null, null);
}

function Precache()
{
	if(!EntityGroup)
	{
		printl("LCZ E: pickup_armor Precache(): EntityGroup == null");
		return;
	}
	
	for(local i = 0; i <= 5; i++)
		if(!EntityGroup[i])
		{
			printl("LCZ E: pickup_armor Precache(): EntityGroup[" + i + "] == null");
			return;
		}
	
	armorEquip =		EntityGroup[0];
	armorModel =		EntityGroup[1];
	armorTrigger =		EntityGroup[2];
	armorSpawnEffect =	EntityGroup[3];
	armorSpawnSound =	EntityGroup[4];
	armorPickupSound =	EntityGroup[5];
	
	initialized = true;
}
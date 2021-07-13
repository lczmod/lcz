/**
 * DM base game settings, applied automatically at the game start after core settings.
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
	mp_randomspawn =			1,
	mp_teammates_are_enemies =	1,
	mp_solid_teammates =		1,
};

/**
 * Called from lcz Precache() -> applyGamemodeConfig().
 *
 * This is not a required field in config file.
 * Call is performed after applying the base game settings.
 * Additional gamemode-related initialization can be performed here.
 */
function lczOnGamemodeLoad()
{
	lcz.announcements.push("[LCZ] Gamemode: Deathmatch. All players are enemies.");
}
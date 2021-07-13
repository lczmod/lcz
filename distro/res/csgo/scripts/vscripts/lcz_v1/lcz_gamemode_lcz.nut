/**
 * Core base game settings, applied automatically at the game start before any gamemode settings.
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

// Displays LCZ info in chat on round start
showLCZinfo <- true;

/**
 * This is a required field in config file.
 * Variable values are set in the exact same order as they are listed in the table.
 */
baseGameSettings <-
{
	// Roundtime doesn't accept values higher than 60
	// Long round times are not recommended for maps containing func_rotating entities;
	// Source does not reset func_rotating angles after 360+ rotation and eventually
	// runs into internal limit for entity angles (36000 degrees upon last check).
	// After that, these entities stop rotating and console is filled with error messages.
	// V O L V O
	// P L S
	mp_roundtime =					10,
	mp_roundtime_defuse =			10,
	mp_roundtime_hostage =			10,
	mp_maxrounds =					32767,
	mp_timelimit =					32767,
	/**
	 * mp_randomspawn:
	 * 0: Both teams use default team-based spawn points
	 * 1: Both teams use random info_deathmatch_spawn points
	 * 2: Only Ts use random info_deathmatch_spawn points
	 * 3: Only CTs use random info_deathmatch_spawn points
	 */
	mp_randomspawn =				1,
	mp_respawn_on_death_ct =		1,
	mp_respawn_on_death_t =			1,
	mp_teammates_are_enemies =		1,
	// You're better off using some SourceMod plugins for TK punishment and such.
	// mp_autokick will hop at first opportunity to kick players for "suiciding" by falling into void.
	mp_autokick =					0,
	mp_solid_teammates =			1,
	mp_death_drop_grenade =			0,
	mp_death_drop_gun =				0,
	mp_buytime =					0,
	mp_buy_anywhere =				0,
	mp_buy_during_immunity =		0,
	/**
	 * mp_defuser_allocation:
	 * 0: Do not give defusers to CTs
	 * 1: Give to two random CTs
	 * 2: Give to every CT
	 */
	mp_defuser_allocation =			0,
	mp_dm_bonus_length_min =		0,
	mp_dm_bonus_length_max =		0,
	mp_dm_time_between_bonus_min =	99999,
	mp_dm_time_between_bonus_max =	99999,
	// On-ground acceleration factor, default = 5.5
	sv_accelerate =					20,
	sv_maxspeed =					32767,
	sv_maxvelocity =				32767,
	/**
	 * Stamina system in CS:GO adds a hidden stamina value to a player.
	 * This value is regenerated over time and is expended on jumping and landing.
	 * When there isn't enough stamina, gaining and keeping up the speed is impossible.
	 */
	sv_staminajumpcost =			0,
	sv_staminalandcost =			0,
	sv_staminarecoveryrate =		9999,
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
	// Core game settings are always at index 0
	if(lcz.gamemodes[0].scope.showLCZinfo)
    {
		lcz.announcements.push("This level is running LCZ Mod v" + lcz.version + "." + lcz.minorVersion);
        lcz.announcements.push("Visit https://github.com/lczmod/lcz for more information.");
    }
}
/**
* team switcher for jagd by Root
*
* Description:
*   Plugin switch teams at round start on dod_jagd (for balanced gameplay). Plugin switching teams in the same way as done on gravelpit in TF2
*
* Version 1.0
* Changelog & more info at http://goo.gl/4nKhJ
*/

#pragma semicolon 1 // Force strict semicolon mode.

// ====[ INCLUDES ]====================================================
#include <sourcemod>

// ====[ CONSTANTS ]===================================================
#define PLUGIN_NAME			"Jagd balancer"
#define PLUGIN_VERSION		"1.0"

enum
{
	Team_Spectator = 1,
	Team_Allies,
	Team_Axis,
};

// ====[ PLUGIN ]======================================================
public Plugin:myinfo =
{
	name			= PLUGIN_NAME,
	author			= "Root",
	description		= "Swap teams at round start on jagd",
	version			= PLUGIN_VERSION,
	url				= "http://dodsplugins.com/"
};

/* OnPluginStart()
 *
 * When the plugin starts up.
 * --------------------------------------------------------------------- */
public OnPluginStart()
{
	// Create convars
	CreateConVar("jagdswitcher_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED);

	// Hook events
	HookEvent("dod_round_start", Event_round_start, EventHookMode_Pre);
}

/* Event_round_starts()
 *
 * Called when a round starts.
 * --------------------------------------------------------------------- */
public Event_round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Check if current map is jagd
	decl String:curmap[64];
	GetCurrentMap(curmap, sizeof(curmap));
	if (StrEqual(curmap, "dod_jagd") || StrEqual(curmap, "dod_strand"))
	{
		// Yep, its jagd. Let's call switch event when round starts and event when player changes team
		HookEvent("player_team", Event_changeteam, EventHookMode_Pre);
		SwitchTeams();
	}
}

/* Event_changeteam()
 *
 * Called when a player changes team.
 * --------------------------------------------------------------------- */
public Action:Event_changeteam(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Lets hide message '*Player joined Wermacht/U.S'
	if (!dontBroadcast && !GetEventBool(event, "silent"))
	{
		SetEventBroadcast(event, true);
	}
	return Plugin_Continue;
}

/* SwitchTeams()
 *
 * Check current player's team and switch to other.
 * --------------------------------------------------------------------- */
public Action:SwitchTeams()
{
	// Switch function written by <eVa>Dog
	for (new client = 1; client <= MaxClients; client++)
	{
		// Checking clients
		if (IsClientInGame(client) && (GetClientTeam(client) == Team_Allies)) // is player on US?
		{
			// Yep, get the other team
			ChangeClientTeam(client, Team_Spectator);
			ChangeClientTeam(client, Team_Axis);
			ShowVGUIPanel(client, "class_ger", INVALID_HANDLE, false);
		}
		else if (IsClientInGame(client) && (GetClientTeam(client) == Team_Axis)) // Nope, he is GER
		{
			// You probably want ask - why players moving to spectators? Its needed for switching teams without deaths (old DoD:S bug: you dont die when you joined spectators)
			ChangeClientTeam(client, Team_Spectator);
			ChangeClientTeam(client, Team_Allies);
			ShowVGUIPanel(client, "class_us", INVALID_HANDLE, false);
		}
	}
	UnhookEvent("player_team", Event_changeteam, EventHookMode_Pre);
	return Plugin_Handled;
}
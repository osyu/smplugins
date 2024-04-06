#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.2"

public Plugin myinfo =
{
  name = "[TF2] Bot Quota Alternate Behavior",
  author = "ugng",
  description = "Prevents bot quota from spawning bots before a human joins a team",
  version = PLUGIN_VERSION,
  url = "https://osyu.sh"
}

Handle g_hBqaQuota;
Handle g_hBqaLeaveOnSpec;
Handle g_hBotQuota;
bool g_bHumanHasBeenOnTeam;
int g_iCurrHumanOnSpec = -1;

public void OnPluginStart()
{
  g_hBqaQuota = CreateConVar("sm_bqa_quota", "0", "Bot quota to be used for alternate behavior");
  g_hBqaLeaveOnSpec = CreateConVar("sm_bqa_leave_on_spec", "1", "Whether bots should leave when all humans are spectators", _, true, 0.0, true, 1.0);

  g_hBotQuota = FindConVar("tf_bot_quota");

  HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
  HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
  HookConVarChange(g_hBqaQuota, OnConVarChanged);
  HookConVarChange(g_hBqaLeaveOnSpec, OnConVarChanged);
  HookConVarChange(g_hBotQuota, OnConVarChanged);

  CheckStatus();
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));
  if (!IsFakeClient(client) && !GetEventBool(event, "disconnect") && GetEventInt(event, "team") <= 1)
  {
    g_iCurrHumanOnSpec = client;
    CheckStatus();
    g_iCurrHumanOnSpec = -1;
  }
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));
  if (!IsFakeClient(client))
  {
    CheckStatus();
  }
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
  CheckStatus();
}

public void OnClientDisconnect_Post(int client)
{
  CheckStatus();
}

void CheckStatus()
{
  if (CheckHumanOnTeam())
  {
    SetConVarInt(g_hBotQuota, GetConVarInt(g_hBqaQuota));
    g_bHumanHasBeenOnTeam = true;
  }
  else
  {
    SetConVarInt(g_hBotQuota, 0);
    g_bHumanHasBeenOnTeam = false;
  }
}

bool CheckHumanOnTeam()
{
  bool bAllowSpec = !GetConVarBool(g_hBqaLeaveOnSpec) && g_bHumanHasBeenOnTeam;

  for (int i = 1; i <= MaxClients; i++)
  {
    if (IsClientInGame(i) && !IsFakeClient(i))
    {
      char sName[MAX_NAME_LENGTH];
      GetClientName(i, sName, sizeof(sName));
      if (bAllowSpec || !(GetClientTeam(i) <= 1 || g_iCurrHumanOnSpec == i))
      {
        return true;
      }
    }
  }

  return false;
}

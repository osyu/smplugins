#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
  name = "Hide Bot Connect Messages",
  author = "ugng",
  description = "Hide bot connect/disconnect messages",
  version = PLUGIN_VERSION,
  url = "https://osyu.sh",
};

public void OnPluginStart()
{
  HookEvent("player_connect_client", Event_PlayerGeneric, EventHookMode_Pre);
  HookEvent("player_disconnect", Event_PlayerGeneric, EventHookMode_Pre);
}

public Action Event_PlayerGeneric(Event event, const char[] name, bool dontBroadcast)
{
  if (GetEventBool(event, "bot"))
  {
    event.BroadcastDisabled = true;
  }
  
  return Plugin_Continue;
}

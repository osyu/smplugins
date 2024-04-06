#include <sourcemod>
#include <geoip>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.3"

public Plugin myinfo = 
{
  name = "Better Connect Messages",
  author = "ugng",
  description = "Nicer looking (dis)connect messages",
  version = PLUGIN_VERSION,
  url = "https://osyu.sh/",
};

public void OnPluginStart()
{
  HookEvent("player_connect_client", Event_ConnectClient, EventHookMode_Pre);
  HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
  HookEvent("player_changename", Event_ChangeName, EventHookMode_Pre);
  HookUserMessage(GetUserMessageId("SayText2"), OnSayText2, true);
}

public void OnClientPutInServer(int iClient)
{
  if (!IsFakeClient(iClient))
  {
    char sName[MAX_NAME_LENGTH];
    char sIP[16];
    char sCountry[32];
    GetClientName(iClient, sName, sizeof(sName));
    GetClientIP(iClient, sIP, sizeof(sIP));
    bool bCountry = GeoipCountry(sIP, sCountry, sizeof(sCountry));
    int iSteamID = GetSteamAccountID(iClient, false);

    if (!bCountry)
    {
      strcopy(sCountry, sizeof(sCountry), "Unknown");
    }

    CPrintToChatAll(/*"{green}＋ */"{khaki}%s {default}joined from {khaki}%s {%s}[U:1:%d]", sName, sCountry, IsClientAuthorized(iClient) ? "normal" : "darksalmon", iSteamID);
  }
}

void Event_ConnectClient(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
  SetEventBroadcast(hEvent, true);

  if (!GetEventBool(hEvent, "bot"))
  {
    char sName[MAX_NAME_LENGTH];
    GetEventString(hEvent, "name", sName, sizeof(sName));

    CPrintToChatAll(/*"{orange}～ */"{khaki}%s {default}connecting", sName);
  }
}

void Event_Disconnect(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
  SetEventBroadcast(hEvent, true);

  int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

  if (iClient)
  {
    if (!GetEventBool(hEvent, "bot"))
    {
      char sName[MAX_NAME_LENGTH];
      char sReason[PLATFORM_MAX_PATH];
      GetEventString(hEvent, "name", sName, sizeof(sName));
      GetEventString(hEvent, "reason", sReason, sizeof(sReason));
      int iSteamID = GetSteamAccountID(iClient, false);

      CPrintToChatAll(/*"{red}－ */"{khaki}%s {default}%s {%s}[U:1:%d]", sName, sReason, IsClientAuthorized(iClient) ? "normal" : "darksalmon", iSteamID);
    }
  }
}

void Event_ChangeName(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
  SetEventBroadcast(hEvent, true);

  char sOldName[MAX_NAME_LENGTH];
  char sName[MAX_NAME_LENGTH];
  GetEventString(hEvent, "oldname", sOldName, sizeof(sOldName));
  GetEventString(hEvent, "newname", sName, sizeof(sName));

  CPrintToChatAll(/*"{orange}＊ */"{khaki}%s {default}changed name to {khaki}%s", sOldName, sName);
}

Action OnSayText2(UserMsg iMsgId, Handle hMsg, const int[] iPlayers, int iNumPlayers, bool bReliable, bool bInit)
{
  if (!bReliable)
  {
    return Plugin_Continue;
  }

  BfReadShort(hMsg); // Team color

  char sMessage[PLATFORM_MAX_PATH];
  BfReadString(hMsg, sMessage, sizeof(sMessage));

  if (StrEqual(sMessage, "#TF_Name_Change"))
  {
    return Plugin_Handled;
  }

  return Plugin_Continue;
}

#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
  name = "[TF2] Disable Holiday Lights",
  author = "ugng",
  description = "Disable holiday light rendering for clients",
  version = PLUGIN_VERSION,
  url = "https://osyu.sh/"
}

public void OnMapStart()
{
  GameRules_SetProp("m_bRopesHolidayLightsAllowed", 0);
}

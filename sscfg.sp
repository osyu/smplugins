#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0"

public Plugin myinfo = 
{
  name = "[TF2] Scoring Style Configs",
  author = "ugng",
  description = "Execute configs based on map scoring style (per-cap/round)",
  version = VERSION,
  url = "https://osyu.sh/"
};

public void OnConfigsExecuted()
{
  int bScorePerCapture = 0;

  int iEnt = FindEntityByClassname(-1, "team_control_point_master");
  if (iEnt != -1)
  {
    int offset = FindDataMapInfo(iEnt, "m_bScorePerCapture");
    bScorePerCapture = GetEntData(iEnt, offset, 1);
  }

  ServerCommand("exec \"%s\"", bScorePerCapture ? "ss_capture" : "ss_round");
}

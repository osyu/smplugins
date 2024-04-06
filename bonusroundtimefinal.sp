#include <sourcemod>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo =
{
  name = "[TF2] Bonus Round Time Final",
  author = "ugng",
  description = "Set a different bonus round time for the final round",
  version = PLUGIN_VERSION,
  url = "https://osyu.sh/"
}

Handle g_hBonusRoundTimeFinal;
Handle g_hGetBonusRoundTimePre;

public void OnPluginStart()
{
  g_hBonusRoundTimeFinal = CreateConVar("sm_bonusroundtimefinal", "25", "Bonus round time for final round");

  Handle hGameConf = LoadGameConfigFile("bonusroundtimefinal");
  int offset = GameConfGetOffset(hGameConf, "CTeamplayRoundBasedRules::GetBonusRoundTime");
  hGameConf.Close();

  g_hGetBonusRoundTimePre = DHookCreate(offset, HookType_GameRules, ReturnType_Int, ThisPointer_Ignore, GetBonusRoundTimePre);
  DHookAddParam(g_hGetBonusRoundTimePre, HookParamType_Bool);
}

public void OnMapStart()
{
  DHookGamerules(g_hGetBonusRoundTimePre, false);
}

public MRESReturn GetBonusRoundTimePre(Handle hReturn, Handle hParams)
{
  if (DHookGetParam(hParams, 1))
  {
    DHookSetReturn(hReturn, GetConVarInt(g_hBonusRoundTimeFinal));
    return MRES_Supercede;
  }
  
  return MRES_Handled;
}

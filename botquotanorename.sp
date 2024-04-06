#include <sourcemod>
#include <sdktools>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
  name = "[TF2] Bot Quota No Rename",
  author = "ugng",
  description = "Prevent redundant bot renames when added by bot quota",
  version = PLUGIN_VERSION,
  url = "https://osyu.sh",
};

public void OnPluginStart()
{
  StartPrepSDKCall(SDKCall_Static);
  PrepSDKCall_SetSignature(SDKLibrary_Engine, "@CreateInterface", 0);
  PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

  Handle hCreateInterface = EndPrepSDKCall();
  Address pVEngineServer = SDKCall(hCreateInterface, "VEngineServer023", 0);
  hCreateInterface.Close();

  Handle hGameConf = LoadGameConfigFile("botquotanorename");
  int offset = GameConfGetOffset(hGameConf, "CVEngineServer::SetFakeClientConVarValue");
  hGameConf.Close();

  Handle hSetFakeClientConVarValuePre = DHookCreate(offset, HookType_Raw, ReturnType_Void, ThisPointer_Ignore, SetFakeClientConVarValuePre);
  DHookAddParam(hSetFakeClientConVarValuePre, HookParamType_Edict);
  DHookAddParam(hSetFakeClientConVarValuePre, HookParamType_CharPtr);
  DHookAddParam(hSetFakeClientConVarValuePre, HookParamType_CharPtr);
  DHookRaw(hSetFakeClientConVarValuePre, false, pVEngineServer);
}

public MRESReturn SetFakeClientConVarValuePre(Handle hParams)
{
  char sCvar[5];
  DHookGetParamString(hParams, 2, sCvar, sizeof(sCvar));

  if (StrEqual(sCvar, "name"))
  {
    return MRES_Supercede;
  }

  return MRES_Handled;
}

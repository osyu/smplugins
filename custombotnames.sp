/* Uses functions from botnames.sp by Aaron Griffith
 * https://github.com/agrif/botnames */

#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <dhooks>

#define PLUGIN_VERSION "1.0"
#define BOT_NAME_FILE "configs/botnames.txt"

public Plugin myinfo =
{
  name = "Custom Bot Names",
  author = "ugng",
  description = "Replace the random bot name list with your own",
  version = PLUGIN_VERSION,
  url = "https://osyu.sh/"
}

Handle g_arrsBotNames;
Handle g_arriNameRedirects;
int g_iNextIndex;

public void OnPluginStart()
{
  Handle hCfgFile = LoadGameConfigFile("custombotnames");
  Handle hDetourGetRandomBotName = DHookCreateFromConf(hCfgFile, "GetRandomBotName");
  hCfgFile.Close();
  DHookEnableDetour(hDetourGetRandomBotName, false, GetRandomBotNamePre);

  ReloadNames();
  GenerateRedirects();
}

void ReloadNames()
{
  g_iNextIndex = 0;

  if (g_arrsBotNames != INVALID_HANDLE)
  {
    ClearArray(g_arrsBotNames);
  }
  else
  {
    g_arrsBotNames = CreateArray(MAX_NAME_LENGTH);
  }

  char path[PLATFORM_MAX_PATH];
  BuildPath(Path_SM, path, sizeof(path), BOT_NAME_FILE);
  
  Handle file = OpenFile(path, "r");
  if (file == INVALID_HANDLE)
  {
    LogError("Could not open file \"%s\"", path);
    return;
  }

  char newname[MAX_NAME_LENGTH*3];
  char formedname[MAX_NAME_LENGTH];
  char prefix[MAX_NAME_LENGTH] = "";

  while (IsEndOfFile(file) == false)
  {
    if (ReadFileLine(file, newname, sizeof(newname)) == false)
    {
      break;
    }
    
    // trim off comments starting with // or #
    int commentstart;
    commentstart = StrContains(newname, "//");
    if (commentstart != -1)
    {
      newname[commentstart] = 0;
    }
    commentstart = StrContains(newname, "#");
    if (commentstart != -1)
    {
      newname[commentstart] = 0;
    }
    
    int length = strlen(newname);
    if (length < 2)
    {
      // we loaded a bum name
      // (that is, blank line or 1 char == bad)
      continue;
    }

    // get rid of pesky whitespace
    TrimString(newname);
    
    Format(formedname, sizeof(formedname), "%s%s", prefix, newname);
    PushArrayString(g_arrsBotNames, formedname);
  }
  
  CloseHandle(file);
}

void GenerateRedirects()
{
  int iNumNames = GetArraySize(g_arrsBotNames);

  if (g_arriNameRedirects != INVALID_HANDLE)
  {
    ResizeArray(g_arriNameRedirects, iNumNames);
  }
  else
  {
    g_arriNameRedirects = CreateArray(1, iNumNames);
  }

  for (int i = 0; i < iNumNames; i++)
  {
    SetArrayCell(g_arriNameRedirects, i, i);

    if (i == 0)
    {
      continue;
    }

    SwapArrayItems(g_arriNameRedirects, GetRandomInt(0, i - 1), i);
  }
}

void LoadNextName(char[] name, int maxlen)
{
  int iNumNames = GetArraySize(g_arrsBotNames);

  GetArrayString(g_arrsBotNames, GetArrayCell(g_arriNameRedirects, g_iNextIndex), name, maxlen);

  g_iNextIndex++;
  if (g_iNextIndex > iNumNames - 1)
  {
    g_iNextIndex = 0;
  }
}

public MRESReturn GetRandomBotNamePre(DHookReturn hReturn)
{
  char sName[MAX_NAME_LENGTH];
  LoadNextName(sName, sizeof(sName));

  DHookSetReturnString(hReturn, sName);
  return MRES_Supercede;
}

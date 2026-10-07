class MutHexedVOTE extends HxMutator
    config(HexedMutators);

var config string VoteListCustomBG;
var config string MapListCustomBG;
var config string PreviewCustomBG;
var config string ChatBoxCustomBG;
var config array<string> MapPreviewLoaders;

function bool MutatorIsAllowed()
{
    return Super.MutatorIsAllowed() && Level.NetMode != NM_Standalone;
}

function array<string> GetArrayProperty(int Index)
{
    if (Properties[Index].Name == "MapPreviewLoaders")
    {
        return MapPreviewLoaders;
    }
    return Super.GetArrayProperty(Index);
}

defaultproperties
{
    FriendlyName="HexedVOTE %TAG%"
    Description="Provides an enhanced map vote menu on top of xVoting."
    bAddToServerPackages=true
    QualifiedName="HexedVOTE"
    ClientReplicationInfoClass=class'HxVTClient'
    Properties(0)=(Name="VoteListCustomBG",Type=HX_PROPERTY_String,UpperLimit="100")
    Properties(1)=(Name="MapListCustomBG",Type=HX_PROPERTY_String,UpperLimit="100")
    Properties(2)=(Name="PreviewCustomBG",Type=HX_PROPERTY_String,UpperLimit="100")
    Properties(3)=(Name="ChatBoxCustomBG",Type=HX_PROPERTY_String,UpperLimit="100")
    Properties(4)=(Name="MapPreviewLoaders",Type=HX_PROPERTY_Array)
    DisplayInfo(0)=(Section="Map Vote Menu",Caption="Vote List Custom BG",Hint="Texture name to set as custom background of the vote list.",bAdvanced=true,Verbosity=HX_VERB_High)
    DisplayInfo(1)=(Section="Map Vote Menu",Caption="Map List Custom BG",Hint="Texture name to set as custom background of the map list.",bAdvanced=true,Verbosity=HX_VERB_High)
    DisplayInfo(2)=(Section="Map Vote Menu",Caption="Preview Custom BG",Hint="Texture name to set as custom background of the map preview banner.",bAdvanced=true,Verbosity=HX_VERB_High)
    DisplayInfo(3)=(Section="Map Vote Menu",Caption="Chat Box Custom BG",Hint="Texture name to set as custom background of the chat box.",bAdvanced=true,Verbosity=HX_VERB_High)
    DisplayInfo(4)=(Section="Map Vote Menu",Caption="Map Preview Loaders",Hint="Auxiliary loader classes providing custom map previews.",bAdvanced=true,Verbosity=HX_VERB_High)
    ConfigClasses(0)=class'HxVTMenuConfig'
    Priority=232
    bDisableTick=true
}

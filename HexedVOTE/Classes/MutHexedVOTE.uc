class MutHexedVOTE extends HxMutator;

var config string VoteListCustomBG;
var config string MapListCustomBG;
var config string PreviewCustomBG;
var config string ChatBoxCustomBG;

function bool MutatorIsAllowed()
{
    return Super.MutatorIsAllowed() && Level.NetMode != NM_Standalone;
}

defaultproperties
{
    FriendlyName="HexedVOTE v7"
    Description="Provides an enhanced map vote menu on top of xVoting."
    bAddToServerPackages=true
    CRIClass=class'HxVTClient'
    Properties(0)=(Name="VoteListCustomBG",Type=HX_PROPERTY_String,UpperLimit="100")
    Properties(1)=(Name="MapListCustomBG",Type=HX_PROPERTY_String,UpperLimit="100")
    Properties(2)=(Name="PreviewCustomBG",Type=HX_PROPERTY_String,UpperLimit="100")
    Properties(3)=(Name="ChatBoxCustomBG",Type=HX_PROPERTY_String,UpperLimit="100")
    DisplayInfo(0)=(Section="Map Vote Menu",Caption="Vote list Custom BG",Hint="Texture name to set as custom background of the vote list.",bAdvanced=true)
    DisplayInfo(1)=(Section="Map Vote Menu",Caption="Map list Custom BG",Hint="Texture name to set as custom background of the map list.",bAdvanced=true)
    DisplayInfo(2)=(Section="Map Vote Menu",Caption="Preview Custom BG",Hint="Texture name to set as custom background of the map preview banner.",bAdvanced=true)
    DisplayInfo(3)=(Section="Map Vote Menu",Caption="Chat box Custom BG",Hint="Texture name to set as custom background of the chat box.",bAdvanced=true)
    bDisableTick=true
}

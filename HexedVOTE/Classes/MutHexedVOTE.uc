class MutHexedVOTE extends HxMutator;

var config string VoteListCustomBG;
var config string MapListCustomBG;
var config string PreviewCustomBG;
var config string ChatBoxCustomBG;

defaultproperties
{
    FriendlyName="HexedVOTE v6dev"
    Description="Provides an enhanced map vote menu on top of xVoting."
    bAddToServerPackages=true
    MutatorGroup="HexedVOTE"
    CRIClass=class'HxVTClient'
    Properties(0)=(Name="VoteListCustomBG",Section="Map Vote Menu",Caption="Vote list Custom BG",Hint="Texture name to set as custom background of the vote list.",Type="Text",Data="1024",bAdvanced=true)
    Properties(1)=(Name="MapListCustomBG",Section="Map Vote Menu",Caption="Map list Custom BG",Hint="Texture name to set as custom background of the map list.",Type="Text",Data="1024",bAdvanced=true)
    Properties(2)=(Name="PreviewCustomBG",Section="Map Vote Menu",Caption="Preview Custom BG",Hint="Texture name to set as custom background of the map preview banner.",Type="Text",Data="1024",bAdvanced=true)
    Properties(3)=(Name="ChatBoxCustomBG",Section="Map Vote Menu",Caption="Chat box Custom BG",Hint="Texture name to set as custom background of the chat box.",Type="Text",Data="1024",bAdvanced=true)
}

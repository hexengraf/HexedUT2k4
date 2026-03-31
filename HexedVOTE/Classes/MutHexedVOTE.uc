class MutHexedVOTE extends HxMutator;

var config string VoteListBG;
var config string MapListBG;
var config string PreviewBG;
var config string ChatBoxBG;

defaultproperties
{
    FriendlyName="HexedVOTE v6dev"
    Description="Provides an enhanced map vote menu."
    bAddToServerPackages=true
    MutatorGroup="HexedVOTE"
    CRIClass=class'HxVTClient'
    Properties(0)=(Name="VoteListBG",Section="Map Vote Menu",Caption="Vote list BG",Hint="Texture name to set as custom background of the vote list.",Type="Text",Data="1024",bAdvanced=true)
    Properties(1)=(Name="MapListBG",Section="Map Vote Menu",Caption="Map list BG",Hint="Texture name to set as custom background of the map list.",Type="Text",Data="1024",bAdvanced=true)
    Properties(2)=(Name="PreviewBG",Section="Map Vote Menu",Caption="Preview BG",Hint="Texture name to set as custom background of the map preview banner.",Type="Text",Data="1024",bAdvanced=true)
    Properties(3)=(Name="ChatBoxBG",Section="Map Vote Menu",Caption="Chat box BG",Hint="Texture name to set as custom background of the chat box.",Type="Text",Data="1024",bAdvanced=true)
}

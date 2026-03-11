class HxSTYEditBox extends GUI2Styles;

event Initialize()
{
    local int i;

    Super.Initialize();
    for (i = 0; i < 5; ++i)
    {
        if (Fonts[i] == None)
        {
            FontNames[i] = "UT2SmallFont";
            Fonts[i] = Controller.GetMenuFont(FontNames[i]);
        }
    }
}

defaultproperties
{
    KeyName="HxEditBox"

    FontNames(0)="HxSmallerFont"
    FontNames(1)="HxSmallerFont"
    FontNames(2)="HxSmallerFont"
    FontNames(3)="HxSmallerFont"
    FontNames(4)="HxSmallerFont"

    Images(0)=Material'engine.WhiteSquareTexture'
    Images(1)=Material'engine.WhiteSquareTexture'
    Images(2)=Material'engine.WhiteSquareTexture'
    Images(3)=Material'engine.WhiteSquareTexture'
    Images(4)=Material'engine.WhiteSquareTexture'

    ImgColors(0)=(R=35,G=71,B=140,A=255)
    ImgColors(1)=(R=43,G=110,B=195,A=255)
    ImgColors(2)=(R=41,G=136,B=255,A=255)
    ImgColors(3)=(R=41,G=136,B=255,A=255)
    ImgColors(4)=(R=32,G=50,B=75,A=255)

    FontColors(0)=(R=255,G=255,B=255,A=255)
    FontColors(1)=(R=255,G=255,B=255,A=255)
    FontColors(2)=(R=255,G=255,B=255,A=255)
    FontColors(3)=(R=255,G=255,B=255,A=255)

    BorderOffsets(0)=5
}

class HxSTYOptionList extends HxGUIStyles;

function bool InternalOnDraw(Canvas C,
                             eMenuState MenuState,
                             float Left,
                             float Top,
                             float Width,
                             float Height)
{
    BorderOffsets[0] = Round(C.ClipY * 0.015);
    BorderOffsets[2] = BorderOffsets[0];
    return false;
}

defaultproperties
{
    KeyName="HxOptionList"

    Images(0)=Material'engine.WhiteSquareTexture'
    Images(1)=Material'engine.WhiteSquareTexture'
    Images(2)=Material'engine.WhiteSquareTexture'
    Images(3)=Material'engine.WhiteSquareTexture'
    Images(4)=Material'engine.WhiteSquareTexture'

    ImgColors(0)=(R=28,G=47,B=96,A=32)
    ImgColors(1)=(R=28,G=47,B=96,A=32)
    ImgColors(2)=(R=28,G=47,B=96,A=32)
    ImgColors(3)=(R=28,G=47,B=96,A=32)
    ImgColors(4)=(R=28,G=47,B=96,A=32)

    Frames(0)=(Material=Material'engine.WhiteSquareTexture',Color=(R=113,G=159,B=205,A=255),Thickness=0.001)
}

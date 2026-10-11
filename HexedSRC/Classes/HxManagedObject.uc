class HxManagedObject extends HxTypes
    abstract;

var protected LevelInfo Level;
var protected HxClientManager ClientManager;

function Setup(LevelInfo Level, HxClientManager Manager)
{
    Self.Level = Level;
    ClientManager = Manager;
}

function Destroy()
{
    Level = None;
    ClientManager = None;
}

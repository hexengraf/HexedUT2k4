class HxConfig extends Object;

simulated function bool CopyPropertyFrom(Object OldObject,
                                         string PropertyName,
                                         optional string OldPropertyName)
{
    return CopyProperty(Self, OldObject, PropertyName, OldPropertyName);
}

static function Object FindOldVersionObject(coerce string FullName,
                                            optional int MinVersion,
                                            optional out int Version)
{
    local class<Object> OldClass;
    local Object OldObject;
    local string PackageName;
    local string ClassName;
    local string VersionName;

    if (ExtractVersion(FullName, VersionName, PackageName, ClassName))
    {
        Version = int(VersionName);
        while (Version > MinVersion)
        {
            --Version;
            OldClass = class<Object>(DynamicLoadObject(
                PackageName$"v"$string(Version)$"."$ClassName, class'Class', true));
            if (OldClass != None)
            {
                OldObject = new() OldClass;
                if (OldObject != None)
                {
                    return OldObject;
                }
            }
        }
    }
    return None;
}

static function Actor FindOldVersionActor(Actor Owner,
                                          coerce string FullName,
                                          optional int MinVersion,
                                          optional out int Version)
{
    local class<Actor> OldClass;
    local Actor OldActor;
    local string PackageName;
    local string ClassName;
    local string VersionName;

    if (ExtractVersion(FullName, VersionName, PackageName, ClassName))
    {
        Version = int(VersionName);
        while (Version > MinVersion)
        {
            --Version;
            OldClass = class<Actor>(DynamicLoadObject(
                PackageName$"v"$string(Version)$"."$ClassName, class'Class', true));
            if (OldClass != None)
            {
                OldActor = Owner.Spawn(OldClass, Owner);
                if (OldActor != None)
                {
                    OldActor.Disable('Tick');
                    return OldActor;
                }
            }
        }
    }
    return None;
}

static function bool CopyProperty(Object NewObject,
                                  Object OldObject,
                                  string PropertyName,
                                  optional string OldPropertyName)
{
    local string Value;

    Value = OldObject.GetPropertyText(PropertyName);
    if (Value != "")
    {
        return NewObject.SetPropertyText(PropertyName, Value);
    }
    else if (OldPropertyName != "")
    {
        Value = OldObject.GetPropertyText(OldPropertyName);
        if (Value != "")
        {
            return NewObject.SetPropertyText(PropertyName, Value);
        }
    }
    return false;
}

static function bool ExtractVersion(coerce string FullName,
                                    out string Version,
                                    optional out string PackageName,
                                    optional out string ClassName)
{
    return Divide(FullName, ".", PackageName, ClassName)
        && Divide(PackageName, "v", PackageName, Version);
}

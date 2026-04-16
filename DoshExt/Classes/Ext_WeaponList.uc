class Ext_WeaponList extends Object
    config(DoshExtWeapons);

var config array<string> WeapDef;
var array< class<KFWeaponDefinition> > WeapDefs;
var array< class<KFWeapon> > WeapClasses;

function LoadWeapons()
{
    local string WPDStr;
    local class<KFWeaponDefinition> WPD;
    local class<KFWeapon> WPC;

    foreach default.WeapDef(WPDStr)
    {
        WPD = class<KFWeaponDefinition>(DynamicLoadObject(WPDStr, class'Class'));
        if (WPD == none)
        {
            `log("Failed to load weapon definition: " $ WPDStr);
            continue;
        }

        WPC = class<KFWeapon>(DynamicLoadObject(WPD.Default.WeaponClassPath, class'Class'));
        if (WPC == none)
        {
            `log("Failed to load weapon class: " $ WPDStr);
            continue;
        }

        WeapDefs.AddItem(WPD);
        WeapClasses.AddItem(WPC);
    }
}

function class<KFWeaponDefinition> GetWeaponDef(class<KFWeapon> WPC)
{
    local int i;
    for (i = 0; i < WeapClasses.Length; i++)
    {
        if (WeapClasses[i] == WPC)
            return WeapDefs[i];
    }
    return None;
}

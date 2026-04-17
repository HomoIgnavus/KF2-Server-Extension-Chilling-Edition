class Ext_WeaponProp_GrenadeLauncher extends Ext_WeaponProperties;

var float BaseAoE;

public function DefInit(class<KFWeaponDefinition> WeaponDefParam)
{
    super.DefInit(WeaponDefParam);

    BaseAoE = class<KFProjectile>(WeaponClass.default.WeaponProjectiles[0]).default.ExplosionTemplate.DamageRadius;
    bCanUpgradeAoE = true;

    `log("Ext_WeaponProp_GrenadeLauncher: MaxDmgLv=" @ MaxDmgLv);
}

public function ApplyModifiers()
{
    local float before;
    local float after;
    super.ApplyModifiers();
    
    // apply AoE
    // test
    class<KFProjectile>(WeaponClass.default.WeaponProjectiles[0]).default.ExplosionTemplate.DamageRadius = BaseAoE * (1.0 + default.AoEPerLv * AoELv);
}

public function Bool CanAddPenetration()
{
    return false;
}

public function Bool CanAddFireRate()
{
    return false;
}

public function string GetAoEInfo()
{
    if (AoELv == 0) return "(Lv 0)";
    return "(Lv" $ AoELv @ "+" $ Round(AoEPerLv * AoELv * 100) $ "%)"; 
}

defaultproperties
{
    bCanUpgradeAoE = true
}
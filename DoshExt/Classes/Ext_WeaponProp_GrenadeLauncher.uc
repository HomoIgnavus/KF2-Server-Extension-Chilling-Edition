class Ext_WeaponProp_GrenadeLauncher extends Ext_WeaponProperties;

var class<KFProjectile> Projectile;
var float BaseAoE;
var float BaseProjDmg;

public function DefInit(class<KFWeaponDefinition> WeaponDefParam)
{
    super.DefInit(WeaponDefParam);

    Projectile = class<KFProjectile>(WeaponClass.default.WeaponProjectiles[0]);
    BaseAoE = Projectile.default.ExplosionTemplate.DamageRadius;
    BaseProjDmg = Projectile.default.ExplosionTemplate.Damage;
    bCanUpgradeAoE = true;

    `log("Ext_WeaponProp_GrenadeLauncher: MaxDmgLv=" @ MaxDmgLv);
}

public function ApplyModifiers()
{
    local int Idx;
    local float DmgMod;
    local float MagMod;

    if (WeaponInstance == none) 
    {
        `log("ApplyModifiers: WeaponInstance is none");
        return;
    }

    if (DamageLv > 0)
    {
        DmgMod = 1.0 + default.DmgPerLv * DamageLv;
        Projectile.default.ExplosionTemplate.Damage = Round(BaseProjDmg * DmgMod);
    }

    if (PenetrationLv > 0)
    {
        for (Idx = 0; Idx < WeaponInstance.PenetrationPower.Length; Idx++)
        {
            WeaponInstance.PenetrationPower[Idx] = BasePenetration[idx] * (1.0 + default.PenetrationPerLv * PenetrationLv);
        }
    }

    if (MagazineLv > 0)
    {
        MagMod = 1.0 + default.MagazinePerLv * MagazineLv;
        WeaponInstance.MagazineCapacity[0] = Round(float(BaseMagazine[0]) * MagMod);
        WeaponInstance.MagazineCapacity[1] = Round(float(BaseMagazine[1]) * MagMod);
        // `log("ApplyModifiers: MagazinePerLv=" @ MagazinePerLv @ " MagazineLv=" @ MagazineLv @ ", MagMod=" @ MagMod @ ", magazine upgrade to: " @ WeaponInstance.MagazineCapacity[0] @ ", " @ WeaponInstance.MagazineCapacity[1]);
    }

    if (MaxAmmoLv > 0)
    {
        WeaponInstance.SpareAmmoCapacity[0] = Round(BaseMaxAmmo[0] * (1.0 + default.SparePerLv * MaxAmmoLv));
        WeaponInstance.SpareAmmoCapacity[1] = Round(BaseMaxAmmo[1] * (1.0 + default.SparePerLv * MaxAmmoLv));
    }

    // apply AoE
    Projectile.default.ExplosionTemplate.DamageRadius = BaseAoE * (1.0 + default.AoEPerLv * AoELv);
    
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
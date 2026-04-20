class Ext_WeaponProp_Melee extends Ext_WeaponProperties;

var float BaseRange;
var array<KFMeleeHelperBase.MeleeHitBoxInfo> BaseHitBoxChain;


public function DefInit(class<KFWeaponDefinition> WeaponDefParam)
{
    super.DefInit(WeaponDefParam);
    bCanUpgradeAoE = false;
    bCanUpgradeFireRate = true;

    `log("Ext_WeaponProp_HuskCannon: MaxDmgLv=" @ MaxDmgLv);
}

public function Bool CanAddPenetration()
{
    return false;
}

defaultproperties
{
    bCanUpgradeAoE = false
}
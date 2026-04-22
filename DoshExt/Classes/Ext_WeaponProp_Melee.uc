class Ext_WeaponProp_Melee extends Ext_WeaponProperties;

var float BaseRange;
var array<KFMeleeHelperBase.MeleeHitBoxInfo> BaseHitBoxChain;
// Store the applied fire rate level for melee weapons to reference
var int AppliedFireRateLv;


public function DefInit(class<KFWeaponDefinition> WeaponDefParam)
{
    super.DefInit(WeaponDefParam);
    bCanUpgradeAoE = false;
    bCanUpgradeFireRate = false;

    `log("Ext_WeaponProp_Melee: MaxDmgLv=" @ MaxDmgLv);
}

public function Bool CanAddPenetration()
{
    return false;
}

defaultproperties
{
    bCanUpgradeAoE = false
}
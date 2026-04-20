class Ext_MeleeHelper extends KFMeleeHelperWeapon within KFWeapon;

var float MeleeRange;

simulated function float GetMeleeRange()
{
    `log("Ext_MeleeHelper.GetMeleeRange: " @ MeleeRange);
	return MeleeRange;
}

defaultproperties
{
    MaxHitRange = 2000;
}
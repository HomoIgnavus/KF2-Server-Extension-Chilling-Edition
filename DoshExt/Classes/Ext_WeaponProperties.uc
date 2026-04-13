class Ext_WeaponProperties extends Object
    config(DoshExtWeapons);


var ExtPlayerReplicationInfo ExtPRI;

var public class<KFWeaponDefinition> WeaponDef;
var public class<KFWeapon> WeaponClass;
var public int DamageLv;
var private array<float> BaseDamage;
var public int AoELv;
var private float BaseAoE;
var private int DoTLv;
var private float BaseDoT;
var public int FireRateLv;
var private array<float> BaseFireInterval;
var public int PenetrationLv;
var private array<float> BasePenetration;
var public int MagazineLv;
var private int BaseMagazine[2];
var public int MaxAmmoLv;
var private int BaseMaxAmmo[2];
var public int ListedPrice;
var private bool bCanUpgradeMagazine;
var private bool bCanUpgradeAoE;
var private bool bCanUpgradeDoT;

var config int MaxDmgLv;
var config int MaxAoELv;
var config int MaxDoTLv;
var config int MaxFireRateLv;
var config int MaxPenetrationLv;
var config int MaxMagazineLv;
var config int MaxSpareLv;

var config float DmgPerLv;
var config float DmgCost;
var config float AoEPerLv;
var config float AoECost;
var config float DoTPerLv;
var config float DoTCost;
var config float FireRatePerLv;
var config float FireRateCost;
var config float PenetrationPerLv;
var config float PenetrationCost;
var config float MagazinePerLv;
var config float MagazineCost;
var config float SparePerLv;
var config float SpareCost;

var private int BasePrice;
var private int NextDmgCost;
var private int NextAoECost;
var private int NextDoTCost;
var private int NextFireRateCost;
var private int NextPenetrationCost;
var private int NextMagazineCost;
var private int NextSpareCost;

public function Init(class<KFWeaponDefinition> WeaponDefParam, KFPlayerController KFPC)
{
    ExtPRI = ExtPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
    if (ExtPRI == none)
    {
        `log("Failed to initialize Ext_WeaponProperties for " @ WeaponDefParam);
        return;
    }

    WeaponDef = WeaponDefParam;
    WeaponClass = class<KFWeapon>(DynamicLoadObject(WeaponDefParam.Default.WeaponClassPath, class'Class'));
    if (WeaponClass == None)
    {
        `log("Failed to load weapon instance: " @ WeaponDefParam.Default.WeaponClassPath);
        return;
    }
    
    DamageLv=0;
    BaseDamage=WeaponClass.default.InstantHitDamage;
    FireRateLv=0;
    BaseFireInterval=WeaponClass.default.FireInterval;
    PenetrationLv=0;
    BasePenetration=WeaponClass.default.PenetrationPower;
    MagazineLv=0;
    BaseMagazine[0] = WeaponClass.default.MagazineCapacity[0];
    BaseMagazine[1] = WeaponClass.default.MagazineCapacity[1];
    MaxAmmoLv=0;
    BaseMaxAmmo[0] = WeaponClass.default.SpareAmmoCapacity[0];
    BaseMaxAmmo[1] = WeaponClass.default.SpareAmmoCapacity[1];
    // SetMaxLvs();

    ListedPrice=WeaponDefParam.Default.BuyPrice;

    if (WeaponClass.default.MagazineCapacity[0] > 1)
        bCanUpgradeMagazine = true;
    else
        bCanUpgradeMagazine = false;

    if (ClassIsChildOf(WeaponClass, class'KFWeap_GrenadeLauncher_Base'))
        bCanUpgradeAoE = true;
    else
        bCanUpgradeAoE = false;

    if (ClassIsChildOf(WeaponClass, class'KFWeap_FlameBase'))
        bCanUpgradeDot = true;
    else
        bCanUpgradeDot = false;

    BasePrice = WeaponDef.Default.BuyPrice;
    NextDmgCost = DmgCost * BasePrice;
    NextAoECost = AoECost * BasePrice;
    NextFireRateCost = FireRateCost * BasePrice;
    NextPenetrationCost = PenetrationCost * BasePrice;
    NextMagazineCost = MagazineCost * BasePrice;
    NextSpareCost = SpareCost * BasePrice;
}

public static function InitClass(PlayerReplicationInfo PRIParam)
{
    local ExtPlayerReplicationInfo ExtPRI;
    local Ext_PerkBase CurrentPerk;
    local int Prestige;

    ExtPRI = ExtPlayerReplicationInfo(PRIParam);
    if (ExtPRI == none) return;

    CurrentPerk = ExtPRI.FCurrentPerk;
    if (CurrentPerk == None) return;

    Prestige = CurrentPerk.CurrentPrestige;

    default.MaxDmgLv = default.DmgPerLv * Prestige;
    default.MaxAoELv = default.AoEPerLv * Prestige;
    default.MaxDotLv = default.DoTPerLv * Prestige;
    default.MaxFireRateLv = default.FireRatePerLv * Prestige;
    default.MaxPenetrationLv = default.PenetrationPerLv * Prestige;
    default.MaxMagazineLv = default.MagazinePerLv * Prestige;
    default.MaxSpareLv = default.SparePerLv * Prestige;

    `log("Ext_WeaponProperties.SetMaxLvs: MaxDmgLv=" @ default.MaxDmgLv @ " MaxAoELv=" @ default.MaxAoELv @ " MaxDotLv=" @ default.MaxDotLv @ " MaxFireRateLv=" @ default.MaxFireRateLv @ " MaxPenetrationLv=" @ default.MaxPenetrationLv @ " MaxMagazineLv=" @ default.MaxMagazineLv @ " MaxSpareLv=" @ default.MaxSpareLv);
}

public function ApplyModifiers(KFWeapon KFW)
{
    local int Idx;
    local float DmgMod;
    local float MagMod;

    if (KFW == none) return;

    if (DamageLv > 0)
    {
        DmgMod = 1.0 + default.DmgPerLv * DamageLv;
        for (Idx = 0; Idx < KFW.InstantHitDamage.Length; Idx++)
        {
            KFW.InstantHitDamage[Idx] = Round(BaseDamage[Idx] * DmgMod);
        }
    }

    if (FireRateLv > 0)
    {
        for (Idx = 0; Idx < KFW.FireInterval.Length; Idx++)
        {
            KFW.FireInterval[Idx] *= (1.0 - default.FireRatePerLv * FireRateLv);
        }
    }

    if (PenetrationLv > 0)
    {
        for (Idx = 0; Idx < KFW.PenetrationPower.Length; Idx++)
        {
            KFW.PenetrationPower[Idx] *= (1.0 + default.PenetrationPerLv * PenetrationLv);
        }
    }

    if (MagazineLv > 0)
    {
        MagMod = 1.0 + default.MagazinePerLv * MagazineLv;
        KFW.MagazineCapacity[0] = Round(float(KFW.MagazineCapacity[0]) * MagMod);
        KFW.MagazineCapacity[1] = Round(float(KFW.MagazineCapacity[1]) * MagMod);
        // `log("ApplyModifiers: MagazinePerLv=" @ MagazinePerLv @ " MagazineLv=" @ MagazineLv @ ", MagMod=" @ MagMod @ ", magazine upgrade to: " @ KFW.MagazineCapacity[0] @ ", " @ KFW.MagazineCapacity[1]);
    }

    if (MaxAmmoLv > 0)
    {
        KFW.SpareAmmoCapacity[0] *= (1.0 + default.SparePerLv * MaxAmmoLv);
        KFW.SpareAmmoCapacity[1] *= (1.0 + default.SparePerLv * MaxAmmoLv);
    }

    `log("ApplyModifiers: modded stats: Dmg=" @ KFW.InstantHitDamage[0] @ " FireRate=" @ KFW.FireInterval[0] @ " Penetration=" @ KFW.PenetrationPower[0] @ " Magazine=" @ KFW.MagazineCapacity[0] @ " MaxAmmo=" @ KFW.SpareAmmoCapacity[0]);
}

public function Bool CanAddDamage()
{
    return ExtPRI != None && DamageLv < default.MaxDmgLv && ExtPRI.Score > NextDmgCost;
}

public function Bool CanAddAoE()
{
    return ExtPRI != None && bCanUpgradeAoE && AoELv < default.MaxAoELv && ExtPRI.Score > NextAoECost;
}

public function Bool CanAddDot()
{
    return ExtPRI != None && bCanUpgradeDot && DotLv < default.MaxDotLv && ExtPRI.Score > NextDotCost;
}

public function Bool CanAddPenetration()
{
    return ExtPRI != None && PenetrationLv < default.MaxPenetrationLv && ExtPRI.Score > NextPenetrationCost;
}

public function Bool CanAddFireRate()
{
    return ExtPRI != None && FireRateLv < default.MaxFireRateLv && ExtPRI.Score > NextFireRateCost;
}

public function Bool CanAddMagazine()
{
    return ExtPRI != None && bCanUpgradeMagazine && MagazineLv < default.MaxMagazineLv && ExtPRI.Score > NextMagazineCost;
}

public function Bool CanAddAmmo()
{
    return ExtPRI != None && MaxAmmoLv < default.MaxSpareLv && ExtPRI.Score > NextSpareCost;
}

public function AddDamage()
{

    if (!CanAddDamage())
        return;

    DamageLv++;
    ExtPRI.AddDosh(-NextDmgCost);
    if (DamageLv < default.MaxDmgLv)
        NextDmgCost = Round(BasePrice * DmgCost * (1 + DamageLv));
    else
        NextDmgCost = 0;
}

public function AddFireRate()
{
    if (!CanAddFireRate())
        return;

    FireRateLv++;
    ExtPRI.AddDosh(-NextFireRateCost);
    if (FireRateLv < default.MaxFireRateLv)
        NextFireRateCost = Round(BasePrice * FireRateCost * (1 + FireRateLv));
    else
        NextFireRateCost = 0;
}

public function AddPenetration()
{
    if (!CanAddPenetration())
        return;

    PenetrationLv++;
    ExtPRI.AddDosh(-NextPenetrationCost);

    if (PenetrationLv < default.MaxPenetrationLv)
        NextPenetrationCost = Round(BasePrice *  PenetrationCost * (1 + PenetrationLv));
    else
        NextPenetrationCost = 0;
}

public function AddMagazine()
{

    if (!CanAddMagazine())
        return;

    MagazineLv++;
    ExtPRI.AddDosh(-NextMagazineCost);

    if (MagazineLv < default.MaxMagazineLv)
        NextMagazineCost = Round(BasePrice * MagazineCost * (1 + MagazineLv));
    else
        NextMagazineCost = 0;
}

public function AddAmmo()
{
    if (!CanAddAmmo())
        return;

    MaxAmmoLv++;
    ExtPRI.AddDosh(-NextSpareCost);

    if (MaxAmmoLv < default.MaxSpareLv)
        NextSpareCost = Round(BasePrice * SpareCost * (1 + MaxAmmoLv));
    else
        NextSpareCost = 0;
}

public function AddAoE()
{
    if (!CanAddAoE())
        return;

    AoELv += 1.0;
    ExtPRI.AddDosh(-NextAoECost);

    if (AoELv < MaxAoELv)
        NextAoECost = Round(BasePrice * AoECost * (1 + AoELv));
    else
        NextAoECost = 0;
}

public function string GetItemName()
{
    return WeaponDef.static.GetItemName();
}

public function int GetSellPrice()
{
    return ListedPrice * 0.75;
}

public function int GetCostDmg()
{
    return NextDmgCost;
}

public function int GetCostAoE()
{
    return NextAoECost;
}

public function int GetCostFireRate()
{
    return NextFireRateCost;
}

public function int GetCostPenetration()
{
    return NextPenetrationCost;
}

public function int GetCostMagazine()
{
    return NextMagazineCost;
}

public function int GetCostAmmo()
{
    return NextSpareCost;
}

public function string GetDamageInfo()
{
    local float Modified;
    if (BaseDamage.Length == 0) return "0 (Lv 0)";
    Modified = BaseDamage[0] * (1.0 + DmgPerLv * DamageLv);
    if (DamageLv == 0) return Round(Modified) @ "(Lv 0)";
    return Round(Modified) @ "(Lv" $ DamageLv @ "+" $ Round(DmgPerLv * DamageLv * 100) $ "%)";
}

public function string GetAoEInfo()
{
    if (AoELv == 0) return "(Lv 0)";
    return "(Lv" $ AoELv @ "+" $ Round(AoEPerLv * AoELv * 100) $ "%)"; 
}

public function string GetFireRateInfo()
{
    local float interval, Modified;
    if (BaseFireInterval.Length == 0) return "0/s (Lv 0)";
    interval = BaseFireInterval[0] > 0 ? BaseFireInterval[0] : 1.0;
    Modified = interval * (1.0 - FireRatePerLv * FireRateLv);
    if (FireRateLv == 0) return Round(1.0/interval) $ "/s (Lv 0)";
    return Round(1.0/Modified) $ "/s (Lv" $ FireRateLv @ "+" $ Round(FireRatePerLv * FireRateLv * 100) $ "%)";
}

public function string GetPenetrationInfo()
{
    local float Modified;
    if (BasePenetration.Length == 0) return "0 (Lv 0)";
    Modified = BasePenetration[0] * (1.0 + PenetrationPerLv * PenetrationLv);
    if (PenetrationLv == 0) return Round(Modified) @ "(Lv 0)";
    return Round(Modified) @ "(Lv" $ PenetrationLv @ "+" $ Round(PenetrationPerLv * PenetrationLv * 100) $ "%)";
}

public function string GetMagazineInfo()
{
    local float Modified;
    Modified = BaseMagazine[0] * (1.0 + MagazinePerLv * MagazineLv);
    if (MagazineLv == 0) return Round(Modified) @ "(Lv 0)";
    return Round(Modified) @ "(Lv" $ MagazineLv @ "+" $ Round(MagazinePerLv * MagazineLv * 100) $ "%)";
}

public function string GetAmmoInfo()
{
    local float Modified;
    Modified = BaseMaxAmmo[0] * (1.0 + SparePerLv * MaxAmmoLv);
    if (MaxAmmoLv == 0) return Round(Modified) @ "(Lv 0)";
    return Round(Modified) @ "(Lv" $ MaxAmmoLv @ "+" $ Round(SparePerLv * MaxAmmoLv * 100) $ "%)";
}
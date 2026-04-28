class Ext_WeaponProperties extends Object
    config(DoshExtWeapons);

enum UpgradeTypes
{
    DamageUp,
    PenetrationUp,
    AoEUp,
    DoTUp,
};

var ExtPlayerReplicationInfo ExtPRI;

var public class<KFWeaponDefinition> WeaponDef;
var public class<KFWeapon> WeaponClass;
var public KFWeapon WeaponInstance;
var public int DamageLv;
var public array<float> BaseDamage;
var public int AoELv;
var public float BaseAoE;
var public int DoTLv;
var public float BaseDoT;
var public int PenetrationLv;
var public array<float> BasePenetration;
var public int ListedPrice;

var public bool bCanUpgradeDamage;
var public bool bCanUpgradeAoE;
var public bool bCanUpgradeDoT;
var public bool bCanUpgradePenetration;

var config int MaxDmgLv;
var config int MaxAoELv;
var config int MaxDoTLv;
var config int MaxPenetrationLv;

var config float DmgPerLv;
var config float DmgCost;
var config float AoEPerLv;
var config float AoECost;
var config float DoTPerLv;
var config float DoTCost;
var config float PenetrationPerLv;
var config float PenetrationCost;

var public int BasePrice;
var public int NextDmgCost;
var public int NextAoECost;
var public int NextDoTCost;
var public int NextPenetrationCost;
var public int TotalValue;

// called when the weapon is added to the player's inventory
public function PCInit(ExtPlayerController PCParam, KFWeapon WeaponParam)
{
    ExtPRI = ExtPlayerReplicationInfo(PCParam.PlayerReplicationInfo);
    if (ExtPRI == none)
    {
        `log("Failed to initialize Ext_WeaponProperties for " @ WeaponParam);
        return;
    }

    WeaponInstance = WeaponParam;

    if (PCParam.WeaponList == None)
    {
        PCParam.WeaponList = new class'Ext_WeaponList';
        PCParam.WeaponList.LoadWeapons();
    }

    if (PCParam.WeaponList != None)
    {
        WeaponDef = PCParam.WeaponList.GetWeaponDef(WeaponParam.Class);
    }

    if (WeaponDef == None && PCParam.WeaponPage != None)
    {
        WeaponDef = PCParam.WeaponPage.GetWeaponProperties(WeaponParam.Class).WeaponDef;
    }

    if (WeaponDef == None)
    {
        `log("Failed to resolve weapon definition for " @ WeaponParam.Class);
        return;
    }

    DefInit(WeaponDef);
    ApplyModifiers();
}

public function DefInit(class<KFWeaponDefinition> WeaponDefParam)
{
    // if (ExtPRI == none)
    // {
    //     `log("Failed to initialize Ext_WeaponProperties for " @ WeaponDefParam);
    //     return;
    // }
    WeaponDef = WeaponDefParam;

    if (WeaponDefParam == None)
    {
        `log("Failed to initialize Ext_WeaponProperties: WeaponDefParam is none");
        return;
    }

    WeaponClass = class<KFWeapon>(DynamicLoadObject(WeaponDefParam.Default.WeaponClassPath, class'Class'));
    if (WeaponClass == None)
    {
        `log("Failed to load weapon instance: " @ WeaponDefParam.Default.WeaponClassPath);
        return;
    }
    
    DamageLv=0;
    BaseDamage=WeaponClass.default.InstantHitDamage;
    PenetrationLv=0;
    BasePenetration=WeaponClass.default.PenetrationPower;
    // SetMaxLvs();

    ListedPrice=WeaponDefParam.Default.BuyPrice;

    if (WeaponClass.default.InstantHitDamage[0] > 0)
        bCanUpgradeDamage = true;
    else
        bCanUpgradeDamage = false;

    if (WeaponClass.default.PenetrationPower[0] > 0)
        bCanUpgradePenetration = true;
    else
        bCanUpgradePenetration = false;

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
    NextPenetrationCost = PenetrationCost * BasePrice;
    TotalValue = WeaponDef.Default.BuyPrice;
}

public static function SetMaxLvs(PlayerReplicationInfo PRIParam)
{
    local ExtPlayerReplicationInfo LocalPRI;
    local Ext_PerkBase CurrentPerk;
    local int Prestige;

    LocalPRI = ExtPlayerReplicationInfo(PRIParam);
    if (LocalPRI == none)
    {
        `log("Ext_WeaponProperties.SetMaxLvs: LocalPRI is None");
        return;
    }

    // Try to get prestige from replicated ECurrentPerkPrestige first
    if (LocalPRI.ECurrentPerkPrestige > 0)
    {
        Prestige = LocalPRI.ECurrentPerkPrestige;
        `log("Ext_WeaponProperties.SetMaxLvs: Using replicated ECurrentPerkPrestige=" @ Prestige);
    }
    else
    {
        // Fallback to FCurrentPerk if available
        CurrentPerk = LocalPRI.FCurrentPerk;
        if (CurrentPerk == None)
        {
            `log("Ext_WeaponProperties.SetMaxLvs: FCurrentPerk is None and ECurrentPerkPrestige=0, using default max level 10");
            Prestige = 10;
        }
        else
        {
            Prestige = CurrentPerk.CurrentPrestige;
            `log("Ext_WeaponProperties.SetMaxLvs: Using FCurrentPerk.CurrentPrestige=" @ Prestige);
        }
    }

    default.MaxDmgLv = Prestige;
    default.MaxAoELv = Prestige;
    default.MaxDotLv = Prestige;
    default.MaxPenetrationLv = Prestige;

    `log("Ext_WeaponProperties.SetMaxLvs: MaxDmgLv=" @ default.MaxDmgLv @ " MaxAoELv=" @ default.MaxAoELv @ " MaxDotLv=" @ default.MaxDotLv @ " MaxPenetrationLv=" @ default.MaxPenetrationLv);
}

public function ApplyModifiers()
{
    local int Idx;
    local float DmgMod;

    if (WeaponInstance == none) 
    {
        `log("ApplyModifiers: WeaponInstance is none");
        return;
    }

    if (DamageLv > 0)
    {
        DmgMod = 1.0 + default.DmgPerLv * DamageLv;
        for (Idx = 0; Idx < WeaponInstance.InstantHitDamage.Length; Idx++)
        {
            WeaponInstance.InstantHitDamage[Idx] = Round(BaseDamage[Idx] * DmgMod);
        }
    }



    if (PenetrationLv > 0)
    {
        for (Idx = 0; Idx < WeaponInstance.PenetrationPower.Length; Idx++)
        {
            WeaponInstance.PenetrationPower[Idx] = BasePenetration[idx] * (1.0 + default.PenetrationPerLv * PenetrationLv);
        }
    }



    `log("ApplyModifiers: modded stats: Dmg=" @ WeaponInstance.InstantHitDamage[0] @ " Penetration=" @ WeaponInstance.PenetrationPower[0]);
}

public function Bool CanAddDamage()
{
    local bool bResult;
    local int ScoreValue;

    if (ExtPRI != None)
        ScoreValue = ExtPRI.Score;
    else
        ScoreValue = -1;

    bResult = ExtPRI != None && DamageLv < default.MaxDmgLv && ExtPRI.Score > NextDmgCost;
    `log("Ext_WeaponProperties.CanAddDamage: ExtPRI=" @ ExtPRI @ " DamageLv=" @ DamageLv @ " MaxDmgLv=" @ default.MaxDmgLv @ " Score=" @ ScoreValue @ " NextDmgCost=" @ NextDmgCost @ " Result=" @ bResult);
    return bResult;
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


public function AddDamage()
{

    if (!CanAddDamage())
        return;

    DamageLv++;
    ExtPRI.AddDosh(-NextDmgCost);
    TotalValue += NextDmgCost;

    if (DamageLv < default.MaxDmgLv)
        NextDmgCost = Round(BasePrice * DmgCost * (1 + DamageLv));
    else
        NextDmgCost = 0;
}



public function AddPenetration()
{
    if (!CanAddPenetration())
        return;

    PenetrationLv++;
    ExtPRI.AddDosh(-NextPenetrationCost);
    TotalValue += NextPenetrationCost;

    if (PenetrationLv < default.MaxPenetrationLv)
        NextPenetrationCost = Round(BasePrice *  PenetrationCost * (1 + PenetrationLv));
    else
        NextPenetrationCost = 0;
}



public function AddAoE()
{
    if (!CanAddAoE())
        return;

    AoELv += 1.0;
    ExtPRI.AddDosh(-NextAoECost);
    TotalValue += NextAoECost;

    if (AoELv < MaxAoELv)
        NextAoECost = Round(BasePrice * AoECost * (1 + AoELv));
    else
        NextAoECost = 0;
}

public function AddDot()
{
    if (!CanAddDot())
        return;

    DoTLv += 1.0;
    ExtPRI.AddDosh(-NextDoTCost);
    TotalValue += NextDoTCost;

    if (DoTLv < MaxDoTLv)
        NextDoTCost = Round(BasePrice * DoTCost * (1 + DoTLv));
    else
        NextDoTCost = 0;
}

public function string GetItemName()
{
    return WeaponDef.static.GetItemName();
}

public function int GetSellPrice()
{
    return TotalValue * 0.75;
}

public function int GetCostDmg()
{
    return NextDmgCost;
}

public function int GetCostAoE()
{
    return NextAoECost;
}



public function int GetCostPenetration()
{
    return NextPenetrationCost;
}

public function Array<UpgradeTypes> GetUpgradables()
{
    local Array<UpgradeTypes> upgradables;

    if (bCanUpgradeDamage)
        upgradables.AddItem(UpgradeTypes.DamageUp);
    if (bCanUpgradeDoT)
        upgradables.AddItem(UpgradeTypes.DoTUp);
    if (bCanUpgradeAoE)
        upgradables.AddItem(UpgradeTypes.AoEUp);
    if (bCanUpgradePenetration)
        upgradables.AddItem(UpgradeTypes.PenetrationUp);

    return upgradables;
}


public function string GetUpgradeInfo(UpgradeTypes Type)
{
    local float Modified;
    
    switch (Type)
    {
        case DamageUp:
            if (BaseDamage.Length == 0) return "0 (Lv 0)";
            Modified = BaseDamage[0] * (1.0 + DmgPerLv * DamageLv);
            if (DamageLv == 0) return Round(Modified) @ "(Lv 0)";
            return Round(Modified) @ "(Lv" $ DamageLv @ "+" $ Round(DmgPerLv * DamageLv * 100) $ "%)";
            break;
            
        case AoEUp:
            if (AoELv == 0) return "(Lv 0)";
            return "(Lv" $ AoELv @ "+" $ Round(AoEPerLv * AoELv * 100) $ "%)";
            break;
            
        case DoTUp:
            if (DoTLv == 0) return "(Lv 0)";
            return "(Lv" $ DoTLv @ "+" $ Round(DoTPerLv * DoTLv * 100) $ "%)";
            break;
            
        case PenetrationUp:
            if (BasePenetration.Length == 0) return "0 (Lv 0)";
            Modified = BasePenetration[0] * (1.0 + PenetrationPerLv * PenetrationLv);
            if (PenetrationLv == 0) return Round(Modified) @ "(Lv 0)";
            return Round(Modified) @ "(Lv" $ PenetrationLv @ "+" $ Round(PenetrationPerLv * PenetrationLv * 100) $ "%)";
            break;
            
        default:
            return "(Lv 0)";
            break;
    }
}


static final operator(24) bool == ( Ext_WeaponProperties A, Ext_WeaponProperties B )
{
    return A.WeaponClass == B.WeaponClass;
}

static final operator(26) bool != ( Ext_WeaponProperties A, Ext_WeaponProperties B )
{
    return A.WeaponClass != B.WeaponClass;
}
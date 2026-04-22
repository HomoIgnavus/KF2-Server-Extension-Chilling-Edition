class UIP_WeaponPage extends KFGUI_MultiComponent
    config(DoshExtWeapons);

var ExtPlayerController KFPC;
var ExtPlayerReplicationInfo KFPRI;
var KFGUI_ColumnList InventoryList;
var KFGUI_ColumnList SaleList;
var KFGUI_Base WeaponIconDisplay; // For displaying weapon icon
var KFGUI_Button BuyWeaponButton; // Upgrade button below icon
var int WeaponIdx;

var KFGUI_Button DmgUpgradeBtn;
var KFGUI_Button AoEUpgradeBtn;
var KFGUI_Button FireRateUpgradeBtn;
var KFGUI_Button PenetrationUpgradeBtn;
var KFGUI_Button MagazineUpgradeBtn;
var KFGUI_Button AmmoUpgradeBtn;

var KFGUI_TextLable DmgValueLabel;
var KFGUI_TextLable AoEValueLabel;
var KFGUI_TextLable FireRateValueLabel;
var KFGUI_TextLable PenetrationValueLabel;
var KFGUI_TextLable MagazineValueLabel;
var KFGUI_TextLable AmmoValueLabel;

var localized string ColumnWeaponText;
var localized string ColumnPriceText;
var localized string ColumnDamageText;
var localized string ColumnFireRateText;
var localized string ColumnPenetrationText;
var localized string ColumnMagazineText;
var localized string ColumnAmmoText;

var Array<int> SaleListMap; // Maps SaleList row indices to WeaponDefList indices

var config Array<string> WeapDef;

// var array< class<ExtWeapon> > TraderWeapList;
var Array<Ext_WeaponProperties> AvailableWeapons;
var int SelectedInventoryIdx;
var int SelectedTraderIdx;
var Array<Ext_WeaponProperties> OwnedWeapList;
var bool bIsInventorySelected;

var int SelectedPerkIdx;
var KFGUI_ComboBox PerkDropdown;
var array<class<KFPerk> > DropdownPerkList;

function LoadAvailableWeapons()
{
    local int i;
    local class<KFWeaponDefinition> WPD;
    local Ext_WeaponProperties WPP;

    if (KFPC.WeaponList == None)
        return;

    for (i = 0; i < KFPC.WeaponList.WeapDefs.Length; i++)
    {
        WPD = KFPC.WeaponList.WeapDefs[i];
        if (WPD != None)
        {
            WPP = new class'Ext_WeaponProperties';
            WPP.DefInit(WPD);
            AvailableWeapons.AddItem(WPP);
        }
    }
    `log("LoadAvailableWeapons(): Loaded " @ AvailableWeapons.Length @ " available weapons from WeaponList.");
}

function FColumnItem NewFColumnItem(string Text, float Width)
{
    local FColumnItem NewItem;
    NewItem.Text = Text;
    NewItem.Width = Width;
    return NewItem;
}

/** Subobjects from defaultproperties are not duplicated reliably for `new(Self)` pages;
 *  leave Components empty in defaults and build here (see log: None in Components broke CaptureMouse). */
private function EnsureComponentsBuilt()
{
    local KFGUI_Base Icon;
    local KFGUI_GreenButton Btn;
    local KFGUI_ColumnList Inv, SaleComp;

    if (FindComponentID('WeaponUpgradeButton') != None)
        return;

    Components.Length = 0;

    Icon = new (Self) class'KFGUI_MultiComponent';
    Icon.ID = 'WeaponIconDisplay';
    Icon.XPosition = 0.01;
    Icon.YPosition = 0.02;
    Icon.XSize = 0.16;
    Icon.YSize = 0.25;
    Components.AddItem(Icon);
    Icon.Owner = Owner;
    Icon.ParentComponent = Self;

    Btn = new (Self) class'KFGUI_GreenButton';
    Btn.ID = 'WeaponUpgradeButton';
    Btn.XPosition = 0.01;
    Btn.YPosition = 0.28;
    Btn.XSize = 0.16;
    Btn.YSize = 0.05;
    Btn.ButtonText = "Upgrade";
    Components.AddItem(Btn);
    Btn.Owner = Owner;
    Btn.ParentComponent = Self;

    // Damage row with upgrade button
    AddStatRow('DmgLabel', 'DmgValue', 'DmgUpgradeBtn', 0.00, "Damage:");
    
    // AoE row with upgrade button
    AddStatRow('AoELabel', 'AoEValue', 'AoEUpgradeBtn', 0.05, "AoE:");
    
    // FireRate row with upgrade button
    AddStatRow('FireRateLabel', 'FireRateValue', 'FireRateUpgradeBtn', 0.10, "Fire Rate:");
    
    // Penetration row with upgrade button
    AddStatRow('PenetrationLabel', 'PenetrationValue', 'PenetrationUpgradeBtn', 0.15, "Penetration:");
    
    // Magazine row with upgrade button
    AddStatRow('MagazineLabel', 'MagazineValue', 'MagazineUpgradeBtn', 0.20, "Magazine:");
    
    // Ammo row with upgrade button
    AddStatRow('AmmoLabel', 'AmmoValue', 'AmmoUpgradeBtn', 0.25, "Max Ammo:");

    Inv = new (Self) class'KFGUI_ColumnList';
    Inv.ID = 'Weapons';
    Inv.XPosition = 0.01;
    Inv.YPosition = 0.34;
    Inv.XSize = 0.48;
    Inv.YSize = 0.64;
    Inv.BackgroundColor.R = 4;
    Inv.BackgroundColor.G = 30;
    Inv.BackgroundColor.B = 8;
    Inv.BackgroundColor.A = 255;
    Components.AddItem(Inv);
    Inv.Owner = Owner;
    Inv.ParentComponent = Self;

    SaleComp = new (Self) class'KFGUI_ColumnList';
    SaleComp.ID = 'Sale';
    SaleComp.XPosition = 0.50;
    SaleComp.YPosition = 0.08;
    SaleComp.XSize = 0.48;
    SaleComp.YSize = 0.90;

    PerkDropdown = new (Self) class'KFGUI_ComboBox';
    PerkDropdown.ID = 'PerkDropdown';
    PerkDropdown.XPosition = 0.50;
    PerkDropdown.YPosition = 0.02;
    PerkDropdown.XSize = 0.48;
    PerkDropdown.YSize = 0.05;
    PerkDropdown.ListBackgroundColor = MakeColor(4, 30, 8, 255);
    PerkDropdown.ListBorderColor = MakeColor(8, 60, 16, 255);
    PerkDropdown.ListHoverColor = MakeColor(32, 128, 32, 255);
    PerkDropdown.BoxColor = MakeColor(4, 30, 8, 255);
    PerkDropdown.SelectedTextColor = MakeColor(128, 255, 128, 255);
    Components.AddItem(PerkDropdown);
    PerkDropdown.Owner = Owner;
    PerkDropdown.ParentComponent = Self;
    SaleComp.BackgroundColor.R = 4;
    SaleComp.BackgroundColor.G = 30;
    SaleComp.BackgroundColor.B = 8;
    SaleComp.BackgroundColor.A = 255;
    Components.AddItem(SaleComp);
    SaleComp.Owner = Owner;
    SaleComp.ParentComponent = Self;
}

private function AddStatRow(name LabelID, name ValueID, name ButtonID, float YPos, string LabelText)
{
    local KFGUI_TextLable Label;
    local KFGUI_TextLable Value;
    local KFGUI_Button Btn;

    // Label
    Label = new (Self) class'KFGUI_TextLable';
    Label.ID = LabelID;
    Label.XPosition = 0.18;
    Label.YPosition = 0.02 + YPos;
    Label.XSize = 0.10;
    Label.YSize = 0.04;
    Label.SetText(LabelText);
    Components.AddItem(Label);
    Label.Owner = Owner;
    Label.ParentComponent = Self;

    // Value
    Value = new (Self) class'KFGUI_TextLable';
    Value.ID = ValueID;
    Value.XPosition = 0.28;
    Value.YPosition = 0.02 + YPos;
    Value.XSize = 0.14;
    Value.YSize = 0.04;
    Value.SetText("0 (Lv 0)");
    Components.AddItem(Value);
    Value.Owner = Owner;
    Value.ParentComponent = Self;

    // Upgrade Button
    Btn = new (Self) class'KFGUI_Button';
    Btn.ID = ButtonID;
    Btn.XPosition = 0.43;
    Btn.YPosition = 0.02 + YPos;
    Btn.XSize = 0.04;
    Btn.YSize = 0.04;
    Btn.ButtonText = "+";
    Components.AddItem(Btn);
    Btn.Owner = Owner;
    Btn.ParentComponent = Self;
}

function InitMenu()
{
    KFPC = ExtPlayerController(GetPlayer());
    if (KFPC == None)
    {
        `log("Error: UIP_WeaponPage could not get player controller reference.");
        return;
    }
    KFPC.WeaponPage = Self;
    KFPRI = ExtPlayerReplicationInfo(KFPC.PlayerReplicationInfo);

    EnsureComponentsBuilt();

    LoadAvailableWeapons();

    WeaponIconDisplay = FindComponentID('WeaponIconDisplay');
    BuyWeaponButton = KFGUI_Button(FindComponentID('WeaponUpgradeButton'));

    InventoryList = KFGUI_ColumnList(FindComponentID('Weapons'));
    InventoryList.Columns.AddItem(NewFColumnItem(ColumnWeaponText, 0.32));
    // WeaponList.Columns.AddItem(NewFColumnItem(ColumnPriceText, 0.10));
    InventoryList.Columns.AddItem(NewFColumnItem(ColumnDamageText, 0.10));
    InventoryList.Columns.AddItem(NewFColumnItem(ColumnFireRateText, 0.12));
    InventoryList.Columns.AddItem(NewFColumnItem(ColumnPenetrationText, 0.12));
    InventoryList.Columns.AddItem(NewFColumnItem(ColumnMagazineText, 0.12));
    InventoryList.Columns.AddItem(NewFColumnItem(ColumnAmmoText, 0.22));

    SaleList = KFGUI_ColumnList(FindComponentID('Sale'));
    SaleList.Columns.AddItem(NewFColumnItem(ColumnWeaponText, 0.32));
    SaleList.Columns.AddItem(NewFColumnItem(ColumnPriceText, 0.10));
    SaleList.Columns.AddItem(NewFColumnItem(ColumnDamageText, 0.10));
    SaleList.Columns.AddItem(NewFColumnItem(ColumnFireRateText, 0.12));
    SaleList.Columns.AddItem(NewFColumnItem(ColumnPenetrationText, 0.12));
    SaleList.Columns.AddItem(NewFColumnItem(ColumnMagazineText, 0.12));
    SaleList.Columns.AddItem(NewFColumnItem(ColumnAmmoText, 0.22));

    // InitWeaponProperties();

    Super.InitMenu();

    if (PerkDropdown != None)
    {
        PerkDropdown.OnComboChanged = OnPerkDropdownChanged;
    }

    InventoryList.OnSelectedRow = OnInventorySelected;
    SaleList.OnSelectedRow = OnTraderSelected;

    if (BuyWeaponButton != None)
    {
        BuyWeaponButton.OnClickLeft = OnBuyWeaponClicked;
        BuyWeaponButton.OnClickRight = OnBuyWeaponClicked;
    }

    // Find stat value labels
    DmgValueLabel = KFGUI_TextLable(FindComponentID('DmgValue'));
    AoEValueLabel = KFGUI_TextLable(FindComponentID('AoEValue'));
    FireRateValueLabel = KFGUI_TextLable(FindComponentID('FireRateValue'));
    PenetrationValueLabel = KFGUI_TextLable(FindComponentID('PenetrationValue'));
    MagazineValueLabel = KFGUI_TextLable(FindComponentID('MagazineValue'));
    AmmoValueLabel = KFGUI_TextLable(FindComponentID('AmmoValue'));

    // Find and wire up upgrade buttons
    DmgUpgradeBtn = KFGUI_Button(FindComponentID('DmgUpgradeBtn'));
    if (DmgUpgradeBtn != None)
    {
        DmgUpgradeBtn.OnClickLeft = OnUpgradeDamage;
        DmgUpgradeBtn.OnClickRight = OnUpgradeDamage;
    }

    AoEUpgradeBtn = KFGUI_Button(FindComponentID('AoEUpgradeBtn'));
    if (AoEUpgradeBtn != None)
    {
        AoEUpgradeBtn.OnClickLeft = OnUpgradeAoE;
        AoEUpgradeBtn.OnClickRight = OnUpgradeAoE;
    }

    FireRateUpgradeBtn = KFGUI_Button(FindComponentID('FireRateUpgradeBtn'));
    if (FireRateUpgradeBtn != None)
    {
        FireRateUpgradeBtn.OnClickLeft = OnUpgradeFireRate;
        FireRateUpgradeBtn.OnClickRight = OnUpgradeFireRate;
    }

    PenetrationUpgradeBtn = KFGUI_Button(FindComponentID('PenetrationUpgradeBtn'));
    if (PenetrationUpgradeBtn != None)
    {
        PenetrationUpgradeBtn.OnClickLeft = OnUpgradePenetration;
        PenetrationUpgradeBtn.OnClickRight = OnUpgradePenetration;
    }

    MagazineUpgradeBtn = KFGUI_Button(FindComponentID('MagazineUpgradeBtn'));
    if (MagazineUpgradeBtn != None)
    {
        MagazineUpgradeBtn.OnClickLeft = OnUpgradeMagazine;
        MagazineUpgradeBtn.OnClickRight = OnUpgradeMagazine;
    }

    AmmoUpgradeBtn = KFGUI_Button(FindComponentID('AmmoUpgradeBtn'));
    if (AmmoUpgradeBtn != None)
    {
        AmmoUpgradeBtn.OnClickLeft = OnUpgradeAmmo;
        AmmoUpgradeBtn.OnClickRight = OnUpgradeAmmo;
    }

}

function PopulatePerkDropdown()
{
    local int i;
    local int CurrentPerkIdx;
    local ExtPerkManager CurrentManager;
    local class<KFPerk> BP;

    if (PerkDropdown == None || KFPC == None) return;

    DropdownPerkList.Length = 0;
    PerkDropdown.Values.Length = 0;
    
    DropdownPerkList.AddItem(None);
    PerkDropdown.Values.AddItem("All Perks");

    CurrentPerkIdx = -1;

    CurrentManager = KFPC.ActivePerkManager;
    if (CurrentManager != None)
    {
        for (i = 0; i < CurrentManager.UserPerks.Length; i++)
        {
            if (CurrentManager.UserPerks[i] == None) continue;

            BP = CurrentManager.UserPerks[i].BasePerk;
            DropdownPerkList.AddItem(BP);
            PerkDropdown.Values.AddItem(BP.default.PerkName);
            
            if (KFPRI != None && KFPRI.ECurrentPerk.default.BasePerk == BP)
            {
                SelectedPerkIdx = i + 1;
            }
        }
    }
    
    PerkDropdown.SelectedIndex = SelectedPerkIdx;
}

function OnPerkDropdownChanged(KFGUI_ComboBox Sender)
{
    if (Sender.SelectedIndex >= 0 && Sender.SelectedIndex < DropdownPerkList.Length)
    {
        SelectedPerkIdx = Sender.SelectedIndex;
    }
    else
    {
        SelectedPerkIdx = -1;
    }
    
    Timer();
}

function ShowMenu()
{
    Super.ShowMenu();
    
    PopulatePerkDropdown();
    
    class'Ext_WeaponProperties'.static.SetMaxLvs(KFPRI);
    class'Ext_WeaponProp_GrenadeLauncher'.static.SetMaxLvs(KFPRI);
    class'Ext_WeaponProp_HuskCannon'.static.SetMaxLvs(KFPRI);
    class'Ext_WeaponProp_Melee'.static.SetMaxLvs(KFPRI);

    SetTimer(2.0, true);
    Timer();
}

function CloseMenu()
{
    Super.CloseMenu();
    SetTimer(0, false);
    
    // Clear selection state
    SelectedInventoryIdx = -1;
    SelectedTraderIdx = -1;
}

function int GetFireRate(KFWeapon KFW)
{
    return Round(60 / KFW.FireInterval[0]);
}

function int GetTraderFireRate(int WeaponIdxParam)
{
    local Ext_WeaponProperties WPP;

    WPP = AvailableWeapons[WeaponIdxParam];
    if (WPP == None)
        return 0;

    return WPP.GetBaseFireRate();
}

function bool CanAfford(Ext_WeaponProperties WPP)
{
    if (WPP == None)
        return false;
    return KFPRI.Score >= WPP.BasePrice;
}

function Timer()
{
    local class<KFWeaponDefinition> WPD;
    local class<KFWeapon> WPC;
    local Ext_WeaponProperties WPP;
    local KFWeapon KFW;
    local Pawn P;
    local int FireRate;
    local int AoE;
    local int DoT;
    local int Dmg;
    local int Pnt;
    local int Mag;
    local int Spare;
    local int Price;
    local ExtPlayerController LocalPC;
    local int idx;
    local int PropIdx;
    local bool bHasWeapon;
    local array< class<KFPerk> > WeaponPerks;

    LocalPC = ExtPlayerController(GetPlayer());
    if (LocalPC == none) return;

    // Update max levels if perk info is now available
    if (KFPRI != None && KFPRI.FCurrentPerk != None)
    {
        class'Ext_WeaponProperties'.static.SetMaxLvs(KFPRI);
        class'Ext_WeaponProp_GrenadeLauncher'.static.SetMaxLvs(KFPRI);
        class'Ext_WeaponProp_HuskCannon'.static.SetMaxLvs(KFPRI);
        class'Ext_WeaponProp_Melee'.static.SetMaxLvs(KFPRI);
    }

    P = LocalPC.Pawn;
    if (P == None || P.InvManager == None) return;

    // weapon inventory list
    InventoryList.EmptyList();
    OwnedWeapList = LocalPC.InvProperties;
        
    for (idx = 0; idx < OwnedWeapList.Length; idx++)
    {
        WPP = OwnedWeapList[idx];
        KFW = OwnedWeapList[idx].WeaponInstance;
        if (KFW == None) continue;
        
        // Price = KFW.default.SellPrice;
        Dmg = Round(KFW.InstantHitDamage[0]);
        FireRate = GetFireRate(KFW);
        Pnt = KFW.PenetrationPower[0];
        Mag = KFW.MagazineCapacity[0];
        Spare = KFW.SpareAmmoCapacity[0];
        InventoryList.AddLine(WPP.WeaponDef.static.GetItemName() @ "\n" @ Dmg @ "\n" @ FireRate @ "/s\n" @ Pnt @ "\n" @ Mag @ " \n " @ Spare, idx);
    }

    // trader weapon list
    SaleList.EmptyList();
    SaleListMap.Length = 0;
    for (idx = 0; idx < AvailableWeapons.Length; idx++)
    {
        WPP = AvailableWeapons[idx];
        WPC = WPP.WeaponClass;
        WPD = WPP.WeaponDef;
        if (WPP == None)
        {
            `log("WeaponPage: WPP is None for index " @ idx);
            continue;
        }
        
        // Check if player already has this weapon in inventory
        bHasWeapon = false;
        // Skip if player already owns this weapon
        if (KFPC.FindWeaponProperties(WPC, PropIdx))
        {
            `log("WeaponPage: Player already owns " @ WPD.default.WeaponClassPath);
            continue;
        }
        
        // Add to visible list and map
        SaleListMap.AddItem(idx);
        
        // hide weapons of different perks
        WeaponPerks = WPC.static.GetAssociatedPerkClasses();
        if (SelectedPerkIdx != -1 && WeaponPerks.Find(DropdownPerkList[SelectedPerkIdx]) == INDEX_NONE)
        {
            continue;
        }

        Price = WPP.BasePrice;
        FireRate = GetTraderFireRate(idx);
        Dmg = Round(WPC.static.CalculateTraderWeaponStatDamage());
        Pnt = Round(WPC.default.PenetrationPower[0]);
        SaleList.AddLine(WPD.static.GetItemName() @ "\n" @ Price @ "\n" @ Dmg @ "\n" @ FireRate @ "/s\n" @ Pnt @ "\n" @ WPC.default.MagazineCapacity[0] @ " \n " @ WPC.default.SpareAmmoCapacity[0], SaleListMap.Length - 1);
        `log("WeaponPage: Added " @ WPD.static.GetItemName() @ " to sale list with price " @ Price);
    }

    // SelectedInventoryWeap = KeepInvWeap;

    // Update weapon icon display if a weapon is selected
    UpdateWeaponIconDisplay();
}

function OnInventorySelected(KFGUI_ListItem Item, int Row, bool bRight, bool bDblClick)
{
    if (Item != None && Item.Value >= 0 && Item.Value < OwnedWeapList.Length)
    {
        SelectedInventoryIdx = Item.Value;
        bIsInventorySelected = true;
        BuyWeaponButton.SetDisabled(false);
        UpdateWeaponIconDisplay();
    }
}

function OnTraderSelected(KFGUI_ListItem Item, int Row, bool bRight, bool bDblClick)
{
    if (Item != None && Item.Value >= 0 && Item.Value < SaleListMap.Length)
    {
        SelectedTraderIdx = SaleListMap[Item.Value];
        bIsInventorySelected = false;
        BuyWeaponButton.SetDisabled(false);
        UpdateWeaponIconDisplay();
    }
}

function OnBuyWeaponClicked(KFGUI_Button Sender)
{
    local Ext_WeaponProperties WPP;
    local ExtPlayerController EXTPC;
    local ExtPlayerReplicationInfo ExtPri;
    local ExtHumanPawn EXTP;
    local KFWeapon SpawnedWeapon;

    EXTPC = ExtPlayerController(GetPlayer());
    if (EXTPC == None)
        return;

    ExtPri = ExtPlayerReplicationInfo(EXTPC.PlayerReplicationInfo);
    if (ExtPri == None)
        return;

    EXTP = ExtHumanPawn(EXTPC.Pawn);
    if (EXTP == None)
        return;

    if (bIsInventorySelected)
    {
        // Sell the selected inventory weapon
        if (SelectedInventoryIdx < 0)
            return;
        SellSelectedWeapon(EXTPC, EXTP);
    }
    else
    {
        // Buy the selected trader weapon
        WPP = AvailableWeapons[SelectedTraderIdx];
        
        if (WPP == None || !CanAfford(WPP)) return;

        `log("Purchase weapon: " @ WPP.WeaponClass @ " for " @ WPP.BasePrice);
        
        // Call server function to purchase weapon and deduct dosh atomically
        EXTPC.ServerPurchaseWeapon(WPP.WeaponClass, WPP.BasePrice);

    }
    Timer();
}

private function SellSelectedWeapon(ExtPlayerController EXTPC, ExtHumanPawn EXTP)
{
    local Inventory Inv;

    if (SelectedInventoryIdx < 0)
        return;

    // Call server function to sell weapon and add dosh atomically
    EXTPC.ServerSellWeapon(SelectedInventoryIdx);

    // Clear selection and refresh
    SelectedInventoryIdx = -1;
    bIsInventorySelected = false;
    Timer();
}

function UpdateWeaponIconDisplay()
{
    if (BuyWeaponButton != None)
    {
        if (bIsInventorySelected)
        {
            BuyWeaponButton.ButtonText = "Sell";
        }
        else
        {
            BuyWeaponButton.ButtonText = "Buy";
        }
    }
    UpdateStatsDisplay();
}

function UpdateStatsDisplay()
{
    local int Prestige;
    local int Dosh;
    local Ext_WeaponProperties WPP;
    local ExtPlayerController LocalPC;
    local ExtPlayerReplicationInfo ExtPri;

    LocalPC = ExtPlayerController(GetPlayer());
    if (LocalPC == None || !bIsInventorySelected || SelectedInventoryIdx < 0 || SelectedInventoryIdx >= LocalPC.InvProperties.Length)
    {
        `log("UpdateStatsDisplay: LocalPC is None");
        WPP = None;
        return;
    }

    ExtPRI = ExtPlayerReplicationInfo(LocalPC.PlayerReplicationInfo);
    if (ExtPRI == None)
    {
        `log("UpdateStatsDisplay: ExtPRI is None");
        return;
    }

    Prestige = ExtPRI.FCurrentPerk.CurrentPrestige;
    Dosh = ExtPRI.Score;
    WPP = LocalPC.InvProperties[SelectedInventoryIdx];
    `log("UpdateStatsDisplay: Dosh=" @ Dosh @ " SelectedInventoryIdx=" @ SelectedInventoryIdx @ " WPP=" @ WPP);

    // Toggle upgrade buttons based on selection type
    if (DmgUpgradeBtn != None)
    {
        DmgUpgradeBtn.SetDisabled(!bIsInventorySelected || WPP == None || !WPP.CanAddDamage());
        `log("UpdateStatsDisplay: DmgUpgradeBtn disabled=" @ DmgUpgradeBtn.bDisabled @ " bIsInventorySelected=" @ bIsInventorySelected @ " WPP=" @ WPP @ " CanAddDamage=" @ (WPP != None ? WPP.CanAddDamage() : false));
        DmgUpgradeBtn.bHidden = (WPP == None);
        if (WPP != None) DmgUpgradeBtn.ButtonText = string(WPP.NextDmgCost);
    }
    else
    {
        `log("UpdateStatsDisplay: DmgUpgradeBtn is None");
    }

    if (AoEUpgradeBtn != None)
    {
        AoEUpgradeBtn.SetDisabled(!bIsInventorySelected || WPP == None || !WPP.CanAddAoE());
        AoEUpgradeBtn.bHidden = (WPP == None || !WPP.bCanUpgradeAoE);
        if (WPP != None) AoEUpgradeBtn.ButtonText = string(WPP.NextAoECost);
    }

    if (FireRateUpgradeBtn != None)
    {
        FireRateUpgradeBtn.SetDisabled(!bIsInventorySelected || WPP == None || !WPP.CanAddFireRate());
        FireRateUpgradeBtn.bHidden = (WPP == None || !WPP.bCanUpgradeFireRate);
        if (WPP != None) FireRateUpgradeBtn.ButtonText = string(WPP.NextFireRateCost);
    }

    if (PenetrationUpgradeBtn != None)
    {
        PenetrationUpgradeBtn.SetDisabled(!bIsInventorySelected || WPP == None || !WPP.CanAddPenetration());
        PenetrationUpgradeBtn.bHidden = (WPP == None || !WPP.bCanUpgradePenetration);
        if (WPP != None) PenetrationUpgradeBtn.ButtonText = string(WPP.NextPenetrationCost);
    }

    if (MagazineUpgradeBtn != None)
    {
        MagazineUpgradeBtn.SetDisabled(!bIsInventorySelected || WPP == None || !WPP.CanAddMagazine());
        MagazineUpgradeBtn.bHidden = (WPP == None || !WPP.bCanUpgradeMagazine);
        if (WPP != None) MagazineUpgradeBtn.ButtonText = string(WPP.NextMagazineCost);
    }

    if (AmmoUpgradeBtn != None)
    {
        AmmoUpgradeBtn.SetDisabled(!bIsInventorySelected || WPP == None || !WPP.CanAddAmmo());
        AmmoUpgradeBtn.bHidden = (WPP == None || !WPP.bCanUpgradeSpare);
        if (WPP != None) AmmoUpgradeBtn.ButtonText = string(WPP.NextSpareCost);
    }

    // if (bIsInventorySelected && SelectedInventoryWeap != None)
    // {
    //     WPP = SelectedInventoryWeap;
    // }
    // else
    // {
    //     // For trader weapons, show base stats without level
    //     if (DmgValueLabel != None)
    //         DmgValueLabel.SetText("Base");
    //     if (AoEValueLabel != None)
    //         AoEValueLabel.SetText("Base");
    //     if (FireRateValueLabel != None)
    //         FireRateValueLabel.SetText("Base");
    //     if (PenetrationValueLabel != None)
    //         PenetrationValueLabel.SetText("Base");
    //     if (MagazineValueLabel != None)
    //         MagazineValueLabel.SetText("Base");
    //     if (AmmoValueLabel != None)
    //         AmmoValueLabel.SetText("Base");
    //     return;
    // }

    // Update damage stat
    if (DmgValueLabel != None)
        DmgValueLabel.SetText(WPP.GetDamageInfo());

    // Update AoE stat
    if (AoEValueLabel != None)
        AoEValueLabel.SetText(WPP.GetAoEInfo());

    // Update fire rate stat
    if (FireRateValueLabel != None)
        FireRateValueLabel.SetText(WPP.GetFireRateInfo());

    // Update penetration stat
    if (PenetrationValueLabel != None)
        PenetrationValueLabel.SetText(WPP.GetPenetrationInfo());

    // Update magazine stat
    if (MagazineValueLabel != None)
        MagazineValueLabel.SetText(WPP.GetMagazineInfo());

    // Update ammo stat
    if (AmmoValueLabel != None)
        AmmoValueLabel.SetText(WPP.GetAmmoInfo());
}

simulated function OnUpgradeDamage(KFGUI_Button Sender)
{
    local ExtPlayerController EXTPC;
    local Ext_WeaponProperties WPP;

    // `log("UIP_WeaponPage.OnUpgradeDamage: bIsInventorySelected=" @ bIsInventorySelected @ " SelectedInventoryIdx=" @ SelectedInventoryIdx);

    if (!bIsInventorySelected || SelectedInventoryIdx < 0)
    {
        // `log("UIP_WeaponPage.OnUpgradeDamage: Early return - invalid selection state");
        return;
    }

    EXTPC = ExtPlayerController(GetPlayer());
    `log("UIP_WeaponPage.OnUpgradeDamage: EXTPC=" @ EXTPC);
    if (EXTPC == None)
    {
        // `log("UIP_WeaponPage.OnUpgradeDamage: Early return - EXTPC is None");
        return;
    }
    
    // Verify the weapon property exists before calling server
    if (SelectedInventoryIdx >= EXTPC.InvProperties.Length)
    {
        // `log("UIP_WeaponPage.OnUpgradeDamage: ERROR - SelectedInventoryIdx (" @ SelectedInventoryIdx @ ") >= InvProperties.Length (" @ EXTPC.InvProperties.Length @ ")");
        return;
    }
    
    WPP = EXTPC.InvProperties[SelectedInventoryIdx];
    if (WPP == None)
    {
        // `log("UIP_WeaponPage.OnUpgradeDamage: ERROR - InvProperties[" @ SelectedInventoryIdx @ "] is None");
        return;
    }
    
    // `log("UIP_WeaponPage.OnUpgradeDamage: Valid weapon found - " @ WPP.WeaponDef.default.WeaponClassPath);
    // `log("UIP_WeaponPage.OnUpgradeDamage: Calling ServerUpgradeWeaponDamage(" @ SelectedInventoryIdx @ ")");
    EXTPC.ServerUpgradeWeaponDamage(SelectedInventoryIdx);
}

simulated function OnUpgradeAoE(KFGUI_Button Sender)
{
    local ExtPlayerController EXTPC;
    local Ext_WeaponProperties WPP;

    if (!bIsInventorySelected || SelectedInventoryIdx < 0)
    {
        // `log("UIP_WeaponPage.OnUpgradeAoE: Early return - invalid selection state");
        return;
    }

    EXTPC = ExtPlayerController(GetPlayer());
    if (EXTPC == None)
    {
        // `log("UIP_WeaponPage.OnUpgradeAoE: Early return - EXTPC is None");
        return;
    }
    
    if (SelectedInventoryIdx >= EXTPC.InvProperties.Length)
    {
        // `log("UIP_WeaponPage.OnUpgradeAoE: ERROR - SelectedInventoryIdx (" @ SelectedInventoryIdx @ ") >= InvProperties.Length (" @ EXTPC.InvProperties.Length @ ")");
        return;
    }
    
    WPP = EXTPC.InvProperties[SelectedInventoryIdx];
    if (WPP == None)
    {
        // `log("UIP_WeaponPage.OnUpgradeAoE: ERROR - InvProperties[" @ SelectedInventoryIdx @ "] is None");
        return;
    }
    
    // `log("UIP_WeaponPage.OnUpgradeAoE: Calling ServerUpgradeWeaponAoE(" @ SelectedInventoryIdx @ ")");
    EXTPC.ServerUpgradeWeaponAoE(SelectedInventoryIdx);
}

simulated function OnUpgradeFireRate(KFGUI_Button Sender)
{
    local ExtPlayerController EXTPC;
    local Ext_WeaponProperties WPP;

    if (!bIsInventorySelected || SelectedInventoryIdx < 0)
    {
        // `log("UIP_WeaponPage.OnUpgradeFireRate: Early return - invalid selection state");
        return;
    }

    EXTPC = ExtPlayerController(GetPlayer());
    if (EXTPC == None)
    {
        // `log("UIP_WeaponPage.OnUpgradeFireRate: Early return - EXTPC is None");
        return;
    }
    
    if (SelectedInventoryIdx >= EXTPC.InvProperties.Length)
    {
        // `log("UIP_WeaponPage.OnUpgradeFireRate: ERROR - SelectedInventoryIdx (" @ SelectedInventoryIdx @ ") >= InvProperties.Length (" @ EXTPC.InvProperties.Length @ ")");
        return;
    }
    
    WPP = EXTPC.InvProperties[SelectedInventoryIdx];
    if (WPP == None)
    {
        // `log("UIP_WeaponPage.OnUpgradeFireRate: ERROR - InvProperties[" @ SelectedInventoryIdx @ "] is None");
        return;
    }
    
    // `log("UIP_WeaponPage.OnUpgradeFireRate: Calling ServerUpgradeWeaponFireRate(" @ SelectedInventoryIdx @ ")");
    EXTPC.ServerUpgradeWeaponFireRate(SelectedInventoryIdx);
}

simulated function OnUpgradePenetration(KFGUI_Button Sender)
{
    local ExtPlayerController EXTPC;
    local Ext_WeaponProperties WPP;

    if (!bIsInventorySelected || SelectedInventoryIdx < 0)
    {
        // `log("UIP_WeaponPage.OnUpgradePenetration: Early return - invalid selection state");
        return;
    }

    EXTPC = ExtPlayerController(GetPlayer());
    if (EXTPC == None)
    {
        // `log("UIP_WeaponPage.OnUpgradePenetration: Early return - EXTPC is None");
        return;
    }
    
    if (SelectedInventoryIdx >= EXTPC.InvProperties.Length)
    {
        // `log("UIP_WeaponPage.OnUpgradePenetration: ERROR - SelectedInventoryIdx (" @ SelectedInventoryIdx @ ") >= InvProperties.Length (" @ EXTPC.InvProperties.Length @ ")");
        return;
    }
    
    WPP = EXTPC.InvProperties[SelectedInventoryIdx];
    if (WPP == None)
    {
        // `log("UIP_WeaponPage.OnUpgradePenetration: ERROR - InvProperties[" @ SelectedInventoryIdx @ "] is None");
        return;
    }
    
    // `log("UIP_WeaponPage.OnUpgradePenetration: Calling ServerUpgradeWeaponPenetration(" @ SelectedInventoryIdx @ ")");
    EXTPC.ServerUpgradeWeaponPenetration(SelectedInventoryIdx);
}

simulated function OnUpgradeMagazine(KFGUI_Button Sender)
{
    local ExtPlayerController EXTPC;
    local Ext_WeaponProperties WPP;

    if (!bIsInventorySelected || SelectedInventoryIdx < 0)
    {
        // `log("UIP_WeaponPage.OnUpgradeMagazine: Early return - invalid selection state");
        return;
    }

    EXTPC = ExtPlayerController(GetPlayer());
    if (EXTPC == None)
    {
        // `log("UIP_WeaponPage.OnUpgradeMagazine: Early return - EXTPC is None");
        return;
    }
    
    if (SelectedInventoryIdx >= EXTPC.InvProperties.Length)
    {
        // `log("UIP_WeaponPage.OnUpgradeMagazine: ERROR - SelectedInventoryIdx (" @ SelectedInventoryIdx @ ") >= InvProperties.Length (" @ EXTPC.InvProperties.Length @ ")");
        return;
    }
    
    WPP = EXTPC.InvProperties[SelectedInventoryIdx];
    if (WPP == None)
    {
        // `log("UIP_WeaponPage.OnUpgradeMagazine: ERROR - InvProperties[" @ SelectedInventoryIdx @ "] is None");
        return;
    }
    
    // `log("UIP_WeaponPage.OnUpgradeMagazine: Calling ServerUpgradeWeaponMagazine(" @ SelectedInventoryIdx @ ")");
    EXTPC.ServerUpgradeWeaponMagazine(SelectedInventoryIdx);
}

simulated function OnUpgradeAmmo(KFGUI_Button Sender)
{
    local ExtPlayerController EXTPC;
    local Ext_WeaponProperties WPP;

    if (!bIsInventorySelected || SelectedInventoryIdx < 0)
    {
        `log("UIP_WeaponPage.OnUpgradeAmmo: Early return - invalid selection state");
        return;
    }

    EXTPC = ExtPlayerController(GetPlayer());
    if (EXTPC == None)
    {
        `log("UIP_WeaponPage.OnUpgradeAmmo: Early return - EXTPC is None");
        return;
    }
    
    if (SelectedInventoryIdx >= EXTPC.InvProperties.Length)
    {
        `log("UIP_WeaponPage.OnUpgradeAmmo: ERROR - SelectedInventoryIdx (" @ SelectedInventoryIdx @ ") >= InvProperties.Length (" @ EXTPC.InvProperties.Length @ ")");
        return;
    }
    
    WPP = EXTPC.InvProperties[SelectedInventoryIdx];
    if (WPP == None)
    {
        `log("UIP_WeaponPage.OnUpgradeAmmo: ERROR - InvProperties[" @ SelectedInventoryIdx @ "] is None");
        return;
    }
    
    `log("UIP_WeaponPage.OnUpgradeAmmo: Calling ServerUpgradeWeaponAmmo(" @ SelectedInventoryIdx @ ")");
    EXTPC.ServerUpgradeWeaponAmmo(SelectedInventoryIdx);
}

function DrawWeaponIcon(class<KFWeapon> KFW, Canvas C, float X, float Y, float Width, float Height)
{
    local Texture2D Tex;
    local float DrawW, DrawH;

    if (KFW != None)
    {
        Tex = KFW.default.WeaponSelectTexture;
        if (Tex != None)
        {
            DrawW = Width;
            DrawH = DrawW * (float(Tex.SizeY) / float(Tex.SizeX));
            if (DrawH > Height)
            {
                DrawH = Height;
                DrawW = DrawH * (float(Tex.SizeX) / float(Tex.SizeY));
            }
            X += (Width - DrawW) / 2.0;
            Y += (Height - DrawH) / 2.0;

            C.SetPos(X, Y);
            C.DrawTile(Tex, DrawW, DrawH, 0, 0, Tex.SizeX, Tex.SizeY);
        }
    }
}

// function DrawWeaponClassIcon(class<KFWeapon> WPC, Canvas C, float X, float Y, float Width, float Height)
// {
//     local Texture2D Tex;
//     local float DrawW, DrawH;

//     if (WPC != None)
//     {
//         Tex = WPC.default.WeaponSelectTexture;
//         if (Tex != None)
//         {
//             DrawW = Width;
//             DrawH = DrawW * (float(Tex.SizeY) / float(Tex.SizeX));
//             if (DrawH > Height)
//             {
//                 DrawH = Height;
//                 DrawW = DrawH * (float(Tex.SizeX) / float(Tex.SizeY));
//             }
//             X += (Width - DrawW) / 2.0;
//             Y += (Height - DrawH) / 2.0;

//             C.SetPos(X, Y);
//             C.DrawTile(Tex, DrawW, DrawH, 0, 0, Tex.SizeX, Tex.SizeY);
//         }
//     }
// }

function Ext_WeaponProperties GetWeaponProperties(class<KFWeapon> KFW)
{
    local Ext_WeaponProperties WPP;
    foreach AvailableWeapons(WPP)
    {
        if (WPP.WeaponClass == KFW)
            return WPP;
    }
    return None;
}

function DrawMenu()
{
    local float X, Y, W, H;
    local int idx, i;
    local class<KFWeapon> WP2Draw;
    
    Super.DrawMenu();
    
    if (WeaponIconDisplay != None)
    {
        // Coordinates must be relative to the Component's origin!
        X = WeaponIconDisplay.CompPos[0] - CompPos[0];
        Y = WeaponIconDisplay.CompPos[1] - CompPos[1];
        W = WeaponIconDisplay.CompPos[2];
        H = WeaponIconDisplay.CompPos[3];
        
        Canvas.SetDrawColor(255, 255, 255, 255);
        
        if (bIsInventorySelected)
        {
            if (SelectedInventoryIdx < 0) return;
            WP2Draw = OwnedWeapList[SelectedInventoryIdx].WeaponClass;
        }
        else
        {
            if (SelectedTraderIdx == -1 || SelectedTraderIdx >= AvailableWeapons.Length) return;
            WP2Draw = AvailableWeapons[SelectedTraderIdx].WeaponClass;
        }

        DrawWeaponIcon(WP2Draw, Canvas, X, Y, W, H);
    }
}

defaultproperties
{
}
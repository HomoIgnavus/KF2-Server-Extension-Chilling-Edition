class UIP_WeaponPage extends KFGUI_MultiComponent
    dependson(Ext_WeaponProperties);

var KFPlayerReplicationInfo KFPRI;
var KFGUI_ColumnList InventoryList;
var KFGUI_ColumnList SaleList;
var KFGUI_Base WeaponIconDisplay; // For displaying weapon icon
var KFGUI_Button BuyWeaponButton; // Upgrade button below icon
var int WeaponIdx;

var Ext_WeaponProperties SelectedInventoryWeap;
var class<KFWeaponDefinition> SelectedTraderWeap;
var bool bIsInventorySelected;

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

var config Array<string> WeapDef;
var Array< class<KFWeaponDefinition> > WeaponDefList;
var Array< class<KFWeapon> > WeaponClassList;
var Array<int> SaleListMap; // Maps SaleList row indices to WeaponDefList indices

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
    SaleComp.YPosition = 0.02;
    SaleComp.XSize = 0.48;
    SaleComp.YSize = 0.96;
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
    EnsureComponentsBuilt();

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

    LoadTraderWeapons();
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

    KFPRI = KFPlayerReplicationInfo(GetPlayer().PlayerReplicationInfo);
}

private function InitWeaponProperties()
{
    local class<KFWeaponDefinition> WPD;
    local Ext_WeaponProperties WPP;

    foreach WeaponDefList(WPD)
    {
        WPP = new(Self) class'Ext_WeaponProperties';
        WPP.Init(WPD);
        OwnedWeapProps.AddItem(WPP);
    }
}

private function LoadTraderWeapons()
{
    local string DefStr;
    local class<KFWeaponDefinition> WPD;
    local class<KFWeapon> WPC;

    `log("UIP_WeaponPage: found " @ WeapDef.Length @ " items in config.");

    WeaponDefList.Length = 0;
    WeaponClassList.Length = 0;
    foreach WeapDef(DefStr)
    {
        if (DefStr == "")
            continue;

        `log("UIP_WeaponPage: WeapDef=" @ DefStr);
        WPD = class<KFWeaponDefinition>(DynamicLoadObject(DefStr, class'Class'));
        if (WPD == None)        
        {
            `Log("Failed to load weapon class: " @ DefStr);
            continue;
        }
        WPC = class<KFWeapon>(DynamicLoadObject(WPD.default.WeaponClassPath, class'Class'));

        WeaponDefList.AddItem(WPD);
        WeaponClassList.AddItem(WPC);
    }
    `log("UIP_WeaponPage: Loaded " @ WeaponDefList.Length @ " weapons for trader.");
}

function ShowMenu()
{
    Super.ShowMenu();
    SetTimer(2.0, true);
    Timer();
}

function CloseMenu()
{
    Super.CloseMenu();
    SetTimer(0, false);
    
    // Clear selection state
    SelectedInventoryWeap = None;
    SelectedTraderWeap = None;
}

function int GetFireRate(int WeaponIdxParam)
{
    local float interval;
    local class<KFWeapon> WPC;

    WPC = WeaponClassList[WeaponIdxParam];
    if (WPC == None)
        return 0;

    interval = WPC.default.FireInterval[0] > 0 ? WPC.default.FireInterval[0] : 1.0;

    return Round(1.0 / interval);
}

function bool CanAfford(class<KFWeaponDefinition> WeaponDef)
{
    if (WeaponDef == None)
        return false;
    return KFPRI.Score >= WeaponDef.default.BuyPrice;
}

function Timer()
{
    local Inventory Inv;
    local KFWeapon KFW;
    local class<KFWeaponDefinition> WPD;
    local class<KFWeapon> WPC;
    local Ext_WeaponProperties WPP;
    local Pawn P;
    local string FireRate;
    local string Dmg;
    local string Pnt;
    local string Mag;
    local string Spare;
    local int Price;
    local ExtPlayerController KFPC;
    local int i;
    local bool bHasWeapon;
    local Ext_WeaponProperties KeepInvWeap;
    local class<KFWeaponDefinition> KeepSaleWeap;

    KFPC = ExtPlayerController(GetPlayer());
    if (KFPC == none) return;

    P = KFPC.Pawn;
    if (P == None || P.InvManager == None) return;

    // weapon inventory list
    // AllWeapProps.Length = 0;
    InventoryList.EmptyList();
        
    for (i = 0; i < KFPC.WeaponProperties.Length; i++)
    {
        WPP = KFPC.WeaponProperties[i];
        if (SelectedInventoryWeap == WPP) KeepInvWeap = WPP;
        // Price = KFW.default.SellPrice;
        Dmg = WPP.GetDamageInfo();
        FireRate = WPP.GetFireRateInfo();
        Pnt = WPP.GetPenetrationInfo();
        Mag = WPP.GetMagazineInfo();
        Spare = WPP.GetAmmoInfo();
        InventoryList.AddLine(WPP.GetItemName() @ "\n" @ Dmg @ "\n" @ FireRate @ "/s\n" @ Pnt @ "\n" @ Mag @ " \n " @ Spare, i);
        
        break;
    }

    // trader weapon list
    SaleList.EmptyList();
    SaleListMap.Length = 0;
    for (i = 0; i < WeaponDefList.Length; i++)
    {
        WPD = WeaponDefList[i];
        WPC = WeaponClassList[i];
        if (WPD == None)
            continue;
        
        // Check if player already has this weapon in inventory
        bHasWeapon = false;
        for (Inv = P.InvManager.InventoryChain; Inv != None; Inv = Inv.Inventory)
        {
            KFW = KFWeapon(Inv);
            if (KFW != None && KFW.Class == WPC)
            {
                bHasWeapon = true;
                break;
            }
        }
        
        // Skip if player already owns this weapon
        if (bHasWeapon)
            continue;
        
        // Add to visible list and map
        SaleListMap.AddItem(i);
        if (SelectedTraderWeap == WPD) KeepSaleWeap = WPD;
        
        // hide weapons of different perks
        // if (WPC.default.AssociatedPerkClasses != P.)
        Price = WPD.default.BuyPrice;
        FireRate = GetFireRate(i);
        Dmg = Round(WPC.static.CalculateTraderWeaponStatDamage());
        Pnt = Round(WPC.default.PenetrationPower[0]);
        SaleList.AddLine(WPD.static.GetItemName() @ "\n" @ Price @ "\n" @ Dmg @ "\n" @ FireRate @ "/s\n" @ Pnt @ "\n" @ WPC.default.MagazineCapacity[0] @ " \n " @ WPC.default.SpareAmmoCapacity[0], i);
    }

    SelectedInventoryWeap = KeepInvWeap;
    SelectedTraderWeap = KeepSaleWeap;

    // Update weapon icon display if a weapon is selected
    UpdateWeaponIconDisplay();
}

function OnInventorySelected(KFGUI_ListItem Item, int Row, bool bRight, bool bDblClick)
{
    if (Item != None && Item.Value >= 0 && Item.Value < OwnedWeapProps.Length)
    {
        SelectedInventoryWeap = OwnedWeapProps[Item.Value];
        bIsInventorySelected = true;
        BuyWeaponButton.SetDisabled(false);
        UpdateWeaponIconDisplay();
    }
}

function OnTraderSelected(KFGUI_ListItem Item, int Row, bool bRight, bool bDblClick)
{
    if (Item != None && Item.Value >= 0 && Item.Value < WeaponDefList.Length)
    {
        SelectedTraderWeap = WeaponDefList[Item.Value];
        bIsInventorySelected = false;
        BuyWeaponButton.SetDisabled(false);
        UpdateWeaponIconDisplay();
    }
}

function OnBuyWeaponClicked(KFGUI_Button Sender)
{
    local ExtPlayerController EXTPC;
    local ExtHumanPawn EXTP;
    local class<KFWeapon> WPC;
    local KFWeapon SpawnedWeapon;
    local Ext_WeaponProperties WPP;

    EXTPC = ExtPlayerController(GetPlayer());
    if (EXTPC == None)
        return;

    EXTP = ExtHumanPawn(EXTPC.Pawn);
    if (EXTP == None)
        return;

    if (bIsInventorySelected)
    {
        // Sell the selected inventory weapon
        if (SelectedInventoryWeap != None)
        {
            SellSelectedWeapon(EXTPC, EXTP);
        }
    }
    else
    {
        // Buy the selected trader weapon
        if (SelectedTraderWeap != None && CanAfford(SelectedTraderWeap))
        {
            `log("Purchase weapon: " @ SelectedTraderWeap);
            WPC = class<KFWeapon>(DynamicLoadObject(SelectedTraderWeap.default.WeaponClassPath, class'Class'));
            SpawnedWeapon = KFWeapon(extp.InvManager.CreateInventory(WPC));
            if (SpawnedWeapon == None) return;

            KFPRI.AddDosh(-SelectedTraderWeap.default.BuyPrice);
            WPP = new(self) class'Ext_WeaponProperties'();
            ExtPC.AddWeaponProperties(SelectedTraderWeap);
            OwnedWeapProps.AddItem(WPP);
            Timer();
        }
    }
}

private function SellSelectedWeapon(ExtPlayerController EXTPC, ExtHumanPawn EXTP)
{
    local KFWeapon WeaponToSell;
    local Inventory Inv;
    local int SellPrice;
    local int i;

    if (SelectedInventoryWeap == None || SelectedInventoryWeap.WeaponClass == None)
        return;

    // Find the actual weapon instance in inventory
    WeaponToSell = None;
    for (Inv = EXTP.InvManager.InventoryChain; Inv != None; Inv = Inv.Inventory)
    {
        WeaponToSell = KFWeapon(Inv);
        if (WeaponToSell != None && WeaponToSell.Class == SelectedInventoryWeap.WeaponClass)
        {
            break;
        }
        WeaponToSell = None;
    }

    if (WeaponToSell == None)
        return;

    // Calculate sell price (75% of buy price)
    SellPrice = SelectedInventoryWeap.GetSellPrice();

    // Remove weapon from inventory
    EXTP.InvManager.RemoveFromInventory(WeaponToSell);
    WeaponToSell.Destroy();

    // Refund the player
    KFPRI.AddDosh(SellPrice);

    // Remove from owned properties
    for (i = 0; i < OwnedWeapProps.Length; i++)
    {
        if (OwnedWeapProps[i] == SelectedInventoryWeap)
        {
            OwnedWeapProps.Remove(i, 1);
            break;
        }
    }

    // Clear selection and refresh
    SelectedInventoryWeap = None;
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
    local Ext_WeaponProperties WPP;

    // Toggle upgrade buttons based on selection type
    if (DmgUpgradeBtn != None)
    {
        DmgUpgradeBtn.SetDisabled(!bIsInventorySelected || SelectedInventoryWeap == None || !SelectedInventoryWeap.CanAddDamage());
        DmgUpgradeBtn.ButtonText = string(SelectedInventoryWeap.GetCostDmg());
    }

    if (AoEUpgradeBtn != None)
    {
        AoEUpgradeBtn.SetDisabled(!bIsInventorySelected && SelectedInventoryWeap == None || SelectedInventoryWeap.CanAddAoE());
        AoEUpgradeBtn.ButtonText = string(SelectedInventoryWeap.GetCostAoE());
    }

    if (FireRateUpgradeBtn != None)
    {
        FireRateUpgradeBtn.SetDisabled(!bIsInventorySelected && SelectedInventoryWeap == None || SelectedInventoryWeap.CanAddFireRate());
        FireRateUpgradeBtn.ButtonText = string(SelectedInventoryWeap.GetCostFireRate());
    }

    if (PenetrationUpgradeBtn != None)
    {
        PenetrationUpgradeBtn.SetDisabled(!bIsInventorySelected && SelectedInventoryWeap == None || SelectedInventoryWeap.CanAddPenetration());
        PenetrationUpgradeBtn.ButtonText = string(SelectedInventoryWeap.GetCostPenetration());
    }

    if (MagazineUpgradeBtn != None)
    {
        MagazineUpgradeBtn.SetDisabled(!bIsInventorySelected && SelectedInventoryWeap == None || SelectedInventoryWeap.CanAddMagazine());
        MagazineUpgradeBtn.ButtonText = string(SelectedInventoryWeap.GetCostMagazine());
    }

    if (AmmoUpgradeBtn != None)
    {
        AmmoUpgradeBtn.SetDisabled(!bIsInventorySelected && SelectedInventoryWeap == None || SelectedInventoryWeap.CanAddAmmo());
        AmmoUpgradeBtn.ButtonText = string(SelectedInventoryWeap.GetCostAmmo());
    }

    if (bIsInventorySelected && SelectedInventoryWeap != None)
    {
        WPP = SelectedInventoryWeap;
    }
    else
    {
        // For trader weapons, show base stats without level
        if (DmgValueLabel != None)
            DmgValueLabel.SetText("Base");
        if (AoEValueLabel != None)
            AoEValueLabel.SetText("Base");
        if (FireRateValueLabel != None)
            FireRateValueLabel.SetText("Base");
        if (PenetrationValueLabel != None)
            PenetrationValueLabel.SetText("Base");
        if (MagazineValueLabel != None)
            MagazineValueLabel.SetText("Base");
        if (AmmoValueLabel != None)
            AmmoValueLabel.SetText("Base");
        return;
    }

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

function OnUpgradeDamage(KFGUI_Button Sender)
{
    if (!bIsInventorySelected || SelectedInventoryWeap == None)
        return;
    
    SelectedInventoryWeap.AddDamage();
    UpdateStatsDisplay();
}

function OnUpgradeAoE(KFGUI_Button Sender)
{
    if (!bIsInventorySelected || SelectedInventoryWeap == None)
        return;
    
    SelectedInventoryWeap.AddAoE();
    UpdateStatsDisplay();
}

function OnUpgradeFireRate(KFGUI_Button Sender)
{
    if (!bIsInventorySelected || SelectedInventoryWeap == None)
        return;
    
    SelectedInventoryWeap.AddFireRate();
    UpdateStatsDisplay();
}

function OnUpgradePenetration(KFGUI_Button Sender)
{
    if (!bIsInventorySelected || SelectedInventoryWeap == None)
        return;
    
    SelectedInventoryWeap.AddPenetration();
    UpdateStatsDisplay();
}

function OnUpgradeMagazine(KFGUI_Button Sender)
{
    if (!bIsInventorySelected || SelectedInventoryWeap == None)
        return;
    
    SelectedInventoryWeap.AddMagazine();
    UpdateStatsDisplay();
}

function OnUpgradeAmmo(KFGUI_Button Sender)
{
    if (!bIsInventorySelected || SelectedInventoryWeap == None)
        return;
    
    SelectedInventoryWeap.AddAmmo();
    UpdateStatsDisplay();
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

function DrawWeaponClassIcon(class<KFWeapon> WPC, Canvas C, float X, float Y, float Width, float Height)
{
    local Texture2D Tex;
    local float DrawW, DrawH;

    if (WPC != None)
    {
        Tex = WPC.default.WeaponSelectTexture;
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

function DrawMenu()
{
    local float X, Y, W, H;
    local int idx, i;
    
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
            if (SelectedInventoryWeap != None)
            {
                DrawWeaponIcon(SelectedInventoryWeap.WeaponClass, Canvas, X, Y, W, H);
            }
        }
        else
        {
            if (SelectedTraderWeap != None)
            {
                idx = -1;
                for (i = 0; i < WeaponDefList.Length; ++i)
                {
                    if (WeaponDefList[i] == SelectedTraderWeap)
                    {
                        idx = i;
                        break;
                    }
                }
                
                if (idx != -1 && idx < WeaponClassList.Length)
                {
                    DrawWeaponClassIcon(WeaponClassList[idx], Canvas, X, Y, W, H);
                }
            }
        }
    }
}

defaultproperties
{
}
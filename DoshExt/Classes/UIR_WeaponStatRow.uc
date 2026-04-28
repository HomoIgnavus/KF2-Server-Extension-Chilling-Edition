Class UIR_WeaponStatRow extends KFGUI_MultiComponent;

var KFGUI_TextLable InfoText;
var KFGUI_Button UpgradeButton;

var int StatType; // 0=Damage, 1=AoE, 2=Penetration, 3=DoT
var UIP_WeaponPage ParentPage;

function InitMenu()
{
    InfoText = KFGUI_TextLable(FindComponentID('Info'));
    UpgradeButton = KFGUI_Button(FindComponentID('UpgradeBtn'));

    Super.InitMenu();
}

function SetStatInfo(string Info, int Cost, bool bCanUpgrade)
{
    if (InfoText != None)
        InfoText.SetText(Info);

    if (UpgradeButton != None)
    {
        UpgradeButton.ButtonText = string(Cost);
        UpgradeButton.SetDisabled(!bCanUpgrade);
    }
}

function OnUpgradeClicked(KFGUI_Button Sender)
{
    if (ParentPage == None) return;

    switch (StatType)
    {
    case 0:
        ParentPage.OnUpgradeDamage(Sender);
        break;
    case 1:
        ParentPage.OnUpgradeAoE(Sender);
        break;
    case 2:
        ParentPage.OnUpgradePenetration(Sender);
        break;
    case 3:
        ParentPage.OnUpgradeDoT(Sender);
        break;
    }
}

defaultproperties
{
    Begin Object Class=KFGUI_TextLable Name=StatInfoLabel
        ID="Info"
        XPosition=0
        YPosition=0.2
        XSize=0.70
        YSize=0.7
        AlignX=2
        AlignY=1
        TextFontInfo=(bClipText=true)
    End Object
    Begin Object Class=KFGUI_Button Name=StatUpgradeBtn
        ID="UpgradeBtn"
        XPosition=0.72
        YPosition=0.1
        XSize=0.27
        YSize=0.8
        ButtonText="0"
        OnClickLeft=OnUpgradeClicked
        OnClickRight=OnUpgradeClicked
    End Object

    Components.Add(StatInfoLabel)
    Components.Add(StatUpgradeBtn)
}

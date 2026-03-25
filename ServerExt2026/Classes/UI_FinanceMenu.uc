class UI_FinanceMenu extends UI_MidGameMenu;

function InitMenu()
{
    local int i;
    local KFGUI_Button B;

    PageSwitcher = KFGUI_SwitchMenuBar(FindComponentID('Pager'));
    Super(KFGUI_Page).InitMenu();

    AddMenuButton('Close', CloseButtonText, CloseButtonToolTip);

    for (i=0; i<Pages.Length; ++i)
    {
        PageSwitcher.AddPage(Pages[i],B).InitMenu();
        if (Pages[i]==Class'UIP_AdminMenu')
            AdminButton = B;
    }
}

defaultproperties
{
    WindowTitle="Finance Menu"
    XPosition=0.15
    YPosition=0.1
    XSize=0.7
    YSize=0.8

    Pages.Add(Class'UIP_Banking')
    Pages.Add(Class'UIP_News')
    Pages.Add(Class'UIP_PerkSelection')
    Pages.Add(Class'UIP_Settings')
    Pages.Add(Class'UIP_PlayerSpecs')
    Pages.Add(Class'UIP_About')

    Begin Object Class=KFGUI_SwitchMenuBar Name=MultiPager
        ID="Pager"
        XPosition=0.01
        YPosition=0.08
        XSize=0.98
        YSize=0.82
        BorderWidth=0.04
        ButtonAxisSize=0.08
    End Object

    Components.Add(MultiPager)
}
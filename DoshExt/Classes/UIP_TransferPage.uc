class UIP_TransferPage extends KFGUI_MultiComponent;

var KFGUI_ComponentList PlayersList;
var array<UIR_TransferPlayer> PlayerItems;

var localized string ColumnPlayerText;
var localized string ColumnDoshText;

function InitMenu()
{
    PlayersList = KFGUI_ComponentList(FindComponentID('Players'));
    Super.InitMenu();
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
}

function Timer()
{
    local int i, ItemsCount;
    local KFPlayerReplicationInfo PRI;
    local GameReplicationInfo GRI;

    GRI = GetPlayer().WorldInfo.GRI;
    if (GRI == None)
        return;

    for (i = 0; i < GRI.PRIArray.Length; ++i)
    {
        PRI = KFPlayerReplicationInfo(GRI.PRIArray[i]);
        if (PRI == None || PRI.bOnlySpectator || PRI.bBot)
            continue;

        if (PRI == GetPlayer().PlayerReplicationInfo)
        {
            continue;
        }

        if (ItemsCount >= PlayerItems.Length)
        {
            PlayerItems[PlayerItems.Length] = UIR_TransferPlayer(PlayersList.AddListComponent(class'UIR_TransferPlayer'));
            PlayerItems[PlayerItems.Length-1].InitMenu();
        }

        PlayerItems[ItemsCount].SetTargetPRI(PRI);
        ItemsCount++;
    }

    while (PlayersList.ItemComponents.Length > ItemsCount)
    {
        PlayerItems[PlayerItems.Length-1].CloseMenu();
        PlayerItems.Remove(PlayerItems.Length-1, 1);
        PlayersList.ItemComponents.Length = ItemsCount;
    }
}

defaultproperties
{
    Begin Object Class=KFGUI_ComponentList Name=PlayerList
        ID="Players"
        XPosition=0.02
        YPosition=0.02
        XSize=0.96
        YSize=0.96
        ListItemsPerPage=12
    End Object
    Components.Add(PlayerList)
}
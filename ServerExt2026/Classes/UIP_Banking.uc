// This file is part of Server Extension.
// Server Extension - a mutator for Killing Floor 2.
//
// Copyright (C) 2016-2016-2024 The Server Extension authors and contributors
//
// Server Extension is free software: you can redistribute it
// and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Server Extension is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with Server Extension. If not, see <https://www.gnu.org/licenses/>.

Class UIP_Banking extends KFGUI_MultiComponent;

var KFGUI_ColumnList PlayersList;
var editinline export KFGUI_RightClickMenu PlayerContext;
var int SelectedPlayerID;

// Context menu text
var localized string SelectPlayerText;
var localized string DepositMoney;
var localized string WithdrawMoney;
var localized string TransferMoney;
var localized string ViewBalance;
var localized string ColumnPlayer;
var localized string ColumnBalance;
var localized string ColumnKills;
var localized string ColumnExp;

// Helper function to create row items
function FRowItem newFRowItem(string Text, int Value, bool isSplitter)
{
    local FRowItem newItem;

    newItem.Text = Text;
    newItem.Value = Value;
    newItem.bSplitter = isSplitter;

    return newItem;
}

// Helper function to create column items
function FColumnItem newFColumnItem(string Text, float Width)
{
    local FColumnItem newItem;

    newItem.Text = Text;
    newItem.Width = Width;

    return newItem;
}

function InitMenu()
{
    PlayersList = KFGUI_ColumnList(FindComponentID('Players'));
    
    // Initialize context menu with banking actions
    PlayerContext.ItemRows.AddItem(newFRowItem("", -1, false)); // Will be set to player name
    PlayerContext.ItemRows.AddItem(newFRowItem(ViewBalance, 0, false));
    PlayerContext.ItemRows.AddItem(newFRowItem("", 0, true)); // Splitter
    PlayerContext.ItemRows.AddItem(newFRowItem(DepositMoney, 1, false));
    PlayerContext.ItemRows.AddItem(newFRowItem(WithdrawMoney, 2, false));
    PlayerContext.ItemRows.AddItem(newFRowItem(TransferMoney, 3, false));
    
    // Setup column headers
    PlayersList.Columns.AddItem(newFColumnItem(ColumnPlayer, 0.40));
    PlayersList.Columns.AddItem(newFColumnItem(ColumnBalance, 0.20));
    PlayersList.Columns.AddItem(newFColumnItem(ColumnKills, 0.20));
    PlayersList.Columns.AddItem(newFColumnItem(ColumnExp, 0.20));

    Super.InitMenu();
}

function ShowMenu()
{
    Super.ShowMenu();
    SetTimer(2, true);
    Timer();
}

function CloseMenu()
{
    Super.CloseMenu();
    SetTimer(0, false);
}

// Update player list every 2 seconds
function Timer()
{
    UpdateBankingPlayerList();
}

// Custom player list update for banking
function UpdateBankingPlayerList()
{
    local int i;
    local ExtPlayerReplicationInfo PRI;
    local string S, BalanceStr;
    
    PlayersList.EmptyList();
    if (GetPlayer().WorldInfo.GRI == None)
        return;
        
    for (i = 0; i < GetPlayer().WorldInfo.GRI.PRIArray.Length; ++i)
    {
        PRI = ExtPlayerReplicationInfo(GetPlayer().WorldInfo.GRI.PRIArray[i]);
        if (PRI == None || PRI.bHiddenUser)
            continue;
            
        S = PRI.PlayerName;
        if (PRI.ShowAdminName())
            S $= " (" $ PRI.GetAdminName() $ ")";
        
        // TODO: Get actual balance from your banking system
        BalanceStr = "$" $ string(PRI.Score); // Using Score as placeholder for balance
        
        // Add player line with balance info
        PlayersList.AddLine(
            S $ "\n" $ BalanceStr $ "\n" $ FormatInteger(PRI.RepKills) $ "\n" $ FormatInteger(PRI.RepEXP),
            PRI.PlayerID,
            S $ "\n" $ MakeSortStr(PRI.Score) $ "\n" $ MakeSortStr(PRI.RepKills) $ "\n" $ MakeSortStr(PRI.RepEXP)
        );
    }
}

// Handle right-click on player
function SelectedRow(KFGUI_ListItem Item, int Row, bool bRight, bool bDblClick)
{
    if (bRight || bDblClick)
    {
        // Set the selected player name in context menu
        PlayerContext.ItemRows[0].Text = SelectPlayerText $ " " $ Item.Columns[0];
        SelectedPlayerID = Item.Value;
        PlayerContext.OpenMenu(Self);
    }
}

// Handle context menu item selection
function SelectedRCItem(int Index)
{
    local int ActionID;
    
    if (Index > 0 && !PlayerContext.ItemRows[Index].bSplitter)
    {
        ActionID = PlayerContext.ItemRows[Index].Value;
        
        // Call banking handler based on action
        switch (ActionID)
        {
        case 0: // View Balance
            ViewPlayerBalance(SelectedPlayerID);
            break;
        case 1: // Deposit Money
            OpenDepositWindow(SelectedPlayerID);
            break;
        case 2: // Withdraw Money
            OpenWithdrawWindow(SelectedPlayerID);
            break;
        case 3: // Transfer Money
            OpenTransferWindow(SelectedPlayerID);
            break;
        }
    }
}

// Banking action functions (to be implemented based on your banking system)
function ViewPlayerBalance(int PlayerID)
{
    local ExtPlayerController PC;
    
    PC = ExtPlayerController(GetPlayer());
    if (PC != None)
    {
        // TODO: Implement balance viewing logic
        `log("Viewing balance for player ID: " $ PlayerID);
        PC.ClientMessage("Viewing balance for player ID: " $ PlayerID);
    }
}

function OpenDepositWindow(int PlayerID)
{
    local ExtPlayerController PC;
    
    PC = ExtPlayerController(GetPlayer());
    if (PC != None)
    {
        // TODO: Open deposit input window
        `log("Opening deposit window for player ID: " $ PlayerID);
        PC.ClientMessage("Deposit functionality - to be implemented");
    }
}

function OpenWithdrawWindow(int PlayerID)
{
    local ExtPlayerController PC;
    
    PC = ExtPlayerController(GetPlayer());
    if (PC != None)
    {
        // TODO: Open withdrawal input window
        `log("Opening withdraw window for player ID: " $ PlayerID);
        PC.ClientMessage("Withdraw functionality - to be implemented");
    }
}

function OpenTransferWindow(int PlayerID)
{
    local ExtPlayerController PC;
    
    PC = ExtPlayerController(GetPlayer());
    if (PC != None)
    {
        // TODO: Open transfer input window
        `log("Opening transfer window for player ID: " $ PlayerID);
        PC.ClientMessage("Transfer functionality - to be implemented");
    }
}

// Helper function to format integers with commas
static final function string FormatInteger(int Val)
{
    local string S, O;
    local int StrLen;

    S = string(Val);
    StrLen = Len(S);
    if (StrLen <= 3)
        return S;
        
    while (StrLen > 3)
    {
        if (O == "")
            O = Right(S, 3);
        else 
            O = Right(S, 3) $ "," $ O;
        S = Left(S, StrLen - 3);
        StrLen -= 3;
    }
    if (StrLen > 0)
        O = S $ "," $ O;
    return O;
}

defaultproperties
{
    Begin Object Class=KFGUI_RightClickMenu Name=BankingPlayerContext
        OnSelectedItem=SelectedRCItem
    End Object
    PlayerContext=BankingPlayerContext

    Begin Object Class=KFGUI_ColumnList Name=BankingPlayerList
        ID="Players"
        XPosition=0.05
        YPosition=0.05
        XSize=0.9
        YSize=0.92
        OnSelectedRow=SelectedRow
    End Object
    Components.Add(BankingPlayerList)
}
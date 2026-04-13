// This file is part of Server Extension.
// Server Extension - a mutator for Killing Floor 2.
//
// Copyright (C) 2016-2024 The Server Extension authors and contributors
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

class ExtInventoryManager extends KFInventoryManager;

// Dosh spamming barrier.
var transient float MoneyTossTime;
var transient byte MoneyTossCount;

simulated function ThrowMoney()
{
    local KFPlayerController KFPC;
    local KF2GUIController GUIController;
    local UI_FinanceMenu FinanceMenu;
    
    KFPC = KFPlayerController(Pawn(Owner).Controller);
    if (KFPC != None)
    {
        GUIController = class'KF2GUIController'.Static.GetGUIController(KFPC);
        if (GUIController != None)
        {
            // Open the finance menu using KF2GUIController
            FinanceMenu = UI_FinanceMenu(GUIController.OpenMenu(class'UI_FinanceMenu'));
            
            // Optional: Set focus or perform additional setup
            if (FinanceMenu != None)
            {
                // Menu is now open and active
                `log("Finance menu opened");
            }
        }
    }
}

reliable server function ServerThrowMoney()
{
	// return;
	if (MoneyTossTime>WorldInfo.TimeSeconds)
	{
		if (MoneyTossCount>=10)
			return;
		++MoneyTossCount;
		MoneyTossTime = FMax(MoneyTossTime,WorldInfo.TimeSeconds+0.5);
	}
	else
	{
		MoneyTossCount = 0;
		MoneyTossTime = WorldInfo.TimeSeconds+1;
	}
	Super.ServerThrowMoney();
}

simulated function Inventory CreateInventory(class<Inventory> NewInventoryItemClass, optional bool bDoNotActivate)
{
	local KFWeapon Wep;
	local Inventory SupClass;

	SupClass = Super.CreateInventory(NewInventoryItemClass, bDoNotActivate);
	Wep = KFWeapon(SupClass);

	if (Wep != none)
	{
		if (KFWeap_Pistol_Dual9mm(Wep) != None && ExtWeap_Pistol_Dual9mm(Wep) == None)
		{
			Wep.Destroy();
			return Super.CreateInventory(class'ExtWeap_Pistol_Dual9mm', bDoNotActivate);
		}

		return Wep;
	}

	return SupClass;
}

simulated function CheckForExcessRemoval(KFWeapon NewWeap)
{
	local Inventory RemoveInv, Inv;

	if (KFWeap_Pistol_Dual9mm(NewWeap) != None)
	{
		for (Inv = InventoryChain; Inv != None; Inv = Inv.Inventory)
		{
			if (Inv.Class == class'ExtWeap_Pistol_9mm')
			{
				RemoveInv = Inv;
				Inv = Inv.Inventory;
				RemoveFromInventory(RemoveInv);
			}
		}
	}

	Super.CheckForExcessRemoval(NewWeap);
}
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

// Military Grade Rounds
Class Ext_TraitSA_Base extends Ext_TraitBase;

enum SpecialAbilities
{
	SpAbil_PerkGrenade,
	SpAbil_RocketJump,
	SpAbil_MGRs,
	SpAbil_None,
};

var float DmgRatio[5];
var float PntRatio[5];

static function AddAbility(ExtHumanPawn Player, SpecialAbilities Ability)
{
	local int idx;
	local ExtPlayerController EPC;
	EPC = ExtPlayerController(Player.Controller);
	if (EPC != None)
	{	
		`log("Ext_TraitSA_Base.AddAbility: BEFORE Add - Ability param = " @ Ability @ ", Array length = " @ EPC.SpecialAbil.Length);
		
		EPC.SpecialAbil.AddItem(Ability);
		
		`log("Ext_TraitSA_Base.AddAbility: AFTER Add - Array length = " @ EPC.SpecialAbil.Length);
		for (idx = 0; idx < EPC.SpecialAbil.Length; idx++)
			`log("Ext_TraitSA_Base.AddAbility:   AFTER [" @ idx @ "] = " @ EPC.SpecialAbil[idx]);
	}
	else
	{
		`log("Ext_TraitSA_Base.AddAbility: ERROR - EPC is None!");
	}
}

static function RemoveAbility(ExtHumanPawn Player, SpecialAbilities Ability)
{
	local ExtPlayerController EPC;
	EPC = ExtPlayerController(Player.Controller);
	if (EPC != None)
		EPC.SpecialAbil.RemoveItem(Ability);
}

defaultproperties
{
	TraitGroup=class'Ext_TGroupSpAbility'

	NumLevels=3
	
	DefLevelCosts(0)=100
	DefLevelCosts(1)=200
	DefLevelCosts(2)=400
	
}
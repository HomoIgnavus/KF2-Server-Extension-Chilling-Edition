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
Class Ext_TraitSA_MGRs extends Ext_TraitSA_Base;

var float DmgRatio[5];
var float PntRatio[5];

static function ApplyEffectOn(ExtHumanPawn Player, Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	super.AddAbility(Player, SpAbil_MGRs);
}

static function CancelEffectOn(ExtHumanPawn Player, Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	super.RemoveAbility(Player, SpAbil_MGRs);
}

defaultproperties
{
	SupportedPerk=class'Ext_PerkCommando'
	
	DmgRatio(0)=1.5
	DmgRatio(1)=2.0
	DmgRatio(2)=5.0
	
	PntRatio(0)=2.0
	PntRatio(1)=5.0
	PntRatio(2)=10.0
}
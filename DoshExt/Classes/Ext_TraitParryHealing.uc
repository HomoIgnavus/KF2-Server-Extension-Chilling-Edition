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

Class Ext_TraitParryHealing extends Ext_TraitBase;

var public float HealPercentage[3];
var public float ArmorPercentage[3];

// Only available once Parry Master has been learned.
// static function bool MeetsRequirements(byte Lvl, Ext_PerkBase Perk)
// {
// 	return true;
// }


static function TraitActivate(Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;
	local int Idx;

	ZerkerPerk = Ext_PerkBerserker(Perk);
	if (ZerkerPerk == none) return;

	Idx = Level - 1;

	ZerkerPerk.ApplyTraitParryHealing(Default.HealPercentage[Idx], Default.ArmorPercentage[Idx]);
}

static function TraitDeActivate(Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;

	ZerkerPerk = Ext_PerkBerserker(Perk);
	if (ZerkerPerk == none) return;

	ZerkerPerk.ApplyTraitParryHealing(0.f, 0.f);
}

defaultproperties
{
	TraitGroup=class'Ext_TGroupParry'
	NumLevels=4
	DefLevelCosts(0)=10
	DefLevelCosts(1)=20
	DefLevelCosts(2)=40
	DefLevelCosts(3)=40

	HealPercentage(0)=0.01;
	HealPercentage(1)=0.02;
	HealPercentage(2)=0.05;
	HealPercentage(3)=0.10;

	ArmorPercentage(0)=0.0;
	ArmorPercentage(1)=0.0;
	ArmorPercentage(2)=0.05;
	ArmorPercentage(3)=0.10;
}
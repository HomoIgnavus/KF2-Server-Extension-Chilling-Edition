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

Class Ext_TraitParryProjectile extends Ext_TraitBase;

var public float DamageReduction[2];

// // Only available once Parry Master has been learned.
static function bool MeetsRequirements(byte Lvl, Ext_PerkBase Perk)
{
	local int TraitIdx;

	// First check level.
	if (Perk.CurrentLevel<Default.MinLevel || Perk.CurrentPrestige < 3)
		return false;

	TraitIdx = Perk.PerkTraits.Find('TraitType', class'Ext_TraitParryExplosion');
	if (TraitIdx < 0 || Perk.PerkTraits[TraitIdx].CurrentLevel < 1)
		return false;
	
	return true;
}


static function ApplyEffectOn(ExtHumanPawn Player, Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	Player.bCanParryProj = true;
	Player.bCanReflectProj = (Level >= 1);
}

static function CancelEffectOn(ExtHumanPawn Player, Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	Player.bCanParryProj = false;
	Player.bCanReflectProj = false;
}

defaultproperties
{
	TraitGroup=class'Ext_TGroupParry'
	NumLevels=2
	DefLevelCosts(0)=50
	DefLevelCosts(1)=100

	DamageReduction(0)=0.2f;
	DamageReduction(1)=0.5f;
}
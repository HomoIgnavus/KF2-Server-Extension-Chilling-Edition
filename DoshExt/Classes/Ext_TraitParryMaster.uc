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

Class Ext_TraitParryMaster extends Ext_TraitBase;

var public float DamageReduction[5];
var public float EffectDuration[5];

static function TraitActivate(Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;
	local int Idx;

	ZerkerPerk = Ext_PerkBerserker(Perk);
	if (ZerkerPerk == none) return;

	Idx = Level - 1;

	ZerkerPerk.ApplyTraitParryMaster(Default.DamageReduction[Idx], Default.EffectDuration[Idx]);
}

static function TraitDeActivate(Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;

	ZerkerPerk = Ext_PerkBerserker(Perk);
	if (ZerkerPerk == none) return;

	ZerkerPerk.ApplyTraitParryMaster(0.f, 0.f);
}

defaultproperties
{
	TraitGroup=class'Ext_TGroupParry'
	NumLevels=5
	DefLevelCosts(0)=10
	DefLevelCosts(1)=20
	DefLevelCosts(2)=40
	DefLevelCosts(3)=50
	DefLevelCosts(4)=100

	DamageReduction(0)=0.1f;
	DamageReduction(1)=0.2f;
	DamageReduction(2)=0.3f;
	DamageReduction(3)=0.5f;
	DamageReduction(4)=0.8f;

	EffectDuration(0)=0.5f;
	EffectDuration(1)=1.0f;
	EffectDuration(2)=1.5f;
	EffectDuration(3)=2.0f;
	EffectDuration(4)=3.0f;
}
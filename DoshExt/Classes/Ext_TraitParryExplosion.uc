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

Class Ext_TraitParryExplosion extends Ext_TraitBase;

var public float ExplosionDamage[5];
var public float ExplosionRadius[5];

// // Only available once Parry Master has been learned.
// static function bool MeetsRequirements(byte Lvl, Ext_PerkBase Perk)
// {
// 	if (Perk.bLearnedPerk[class'Ext_TraitParryMaster']) return true;
// 	return false;
// }

static function TraitActivate(Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;
	local int Idx;

	ZerkerPerk = Ext_PerkBerserker(Perk);
	if (ZerkerPerk == none) return;

	Idx = Level - 1;
	ZerkerPerk.ApplyTraitParryExplosion(Default.ExplosionDamage[Idx], Default.ExplosionRadius[Idx]);
}

static function TraitDeActivate(Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;

	ZerkerPerk = Ext_PerkBerserker(Perk);
	if (ZerkerPerk == none) return;

	ZerkerPerk.ApplyTraitParryExplosion(0.0, 0.0);
}

defaultproperties
{
	TraitGroup=class'Ext_TGroupParry'
	NumLevels=5
	DefLevelCosts(0)=10
	DefLevelCosts(1)=20
	DefLevelCosts(2)=40
	DefLevelCosts(3)=80
	DefLevelCosts(4)=160

	ExplosionDamage(0)=20;
	ExplosionDamage(1)=50;
	ExplosionDamage(2)=80;
	ExplosionDamage(3)=120;
	ExplosionDamage(4)=240;

	ExplosionRadius(0)=200;
	ExplosionRadius(1)=300;
	ExplosionRadius(2)=400;
	ExplosionRadius(3)=600;
	ExplosionRadius(4)=1000;
}
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

Class Ext_TraitBombzerker extends Ext_TraitBase;

var float MaxExpDamage[5];
var float MaxExpRadius[5];
var float MaxFallDamage[5];

static function ApplyEffectOn(ExtHumanPawn Player, Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;
	ZerkerPerk = Ext_PerkBerserker(Perk);

	if (ZerkerPerk == none) return;

	ZerkerPerk.ApplyTraitBombzerker(MaxExpDamage[Level-1], MaxExpRadius[Level-1], MaxFallDamage[Level-1], true);
}

static function CancelEffectOn(ExtHumanPawn Player, Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;
	ZerkerPerk = Ext_PerkBerserker(Perk);

	if (ZerkerPerk == none) return;
	
	ZerkerPerk.ApplyTraitBombzerker(0.0, 0.0, 0.0, false);
}

defaultproperties
{
	SupportedPerk=class'Ext_PerkBerserker'
	NumLevels=5
	DefLevelCosts(0)=100
	DefLevelCosts(1)=200
	DefLevelCosts(2)=400
	DefLevelCosts(3)=800
	DefLevelCosts(4)=1600
	
	MaxExpDamage(0)=0.2
	MaxExpDamage(1)=0.5
	MaxExpDamage(2)=1.0
	MaxExpDamage(3)=3.0
	MaxExpDamage(4)=10.0
	
	MaxExpRadius(0)=500
	MaxExpRadius(1)=700
	MaxExpRadius(2)=1000
	MaxExpRadius(3)=1500
	MaxExpRadius(4)=3500
	
	MaxFallDamage(0)=1.0
	MaxFallDamage(1)=2.0
	MaxFallDamage(2)=3.0
	MaxFallDamage(3)=4.0
	MaxFallDamage(4)=10.0
}
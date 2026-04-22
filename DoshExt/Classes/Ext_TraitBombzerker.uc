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

var float ExpDamageRatio[5]; // explosion damage/falldamage ratio
var float ExpRadiusRatio[5]; // explosion radius/falldamage ratio

static function TraitActivate(Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;
	ZerkerPerk = Ext_PerkBerserker(Perk);

	if (ZerkerPerk == none) return;

	ZerkerPerk.ApplyTraitBombzerker(default.ExpDamageRatio[Level-1], default.ExpRadiusRatio[Level-1], true);
}

static function TraitDeActivate(Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	local Ext_PerkBerserker ZerkerPerk;
	ZerkerPerk = Ext_PerkBerserker(Perk);

	if (ZerkerPerk == none) return;

	ZerkerPerk.ApplyTraitBombzerker(0.0, 0.0, false);
}

defaultproperties
{
	SupportedPerk=class'Ext_PerkBerserker'
	TraitGroup=class'Ext_TGroupBombzerker'
	NumLevels=5
	
	DefLevelCosts(0)=100
	DefLevelCosts(1)=200
	DefLevelCosts(2)=400
	DefLevelCosts(3)=800
	DefLevelCosts(4)=1600
	
	ExpDamageRatio(0)=1.0
	ExpDamageRatio(1)=2.0
	ExpDamageRatio(2)=10.0
	ExpDamageRatio(3)=40.0
	ExpDamageRatio(4)=150.0
	
	ExpRadiusRatio(0)=0.5
	ExpRadiusRatio(1)=1.0
	ExpRadiusRatio(2)=1.5
	ExpRadiusRatio(3)=2.0
	ExpRadiusRatio(4)=3.0
}
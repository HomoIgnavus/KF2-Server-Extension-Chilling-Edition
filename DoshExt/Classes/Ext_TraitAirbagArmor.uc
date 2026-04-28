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

// Armor now consumes falling damage
Class Ext_TraitAirbagArmor extends Ext_TraitBase;

var float AbsorbRate[5]; // explosion damage/falldamage ratio

static function ApplyEffectOn(ExtHumanPawn Player, Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)

{
	Player.AirBagRate = default.AbsorbRate[Level-1];
}

static function CancelEffectOn(ExtHumanPawn Player, Ext_PerkBase Perk, byte Level, optional Ext_TraitDataStore Data)
{
	Player.AirBagRate = 0.0;
}

defaultproperties
{
	NumLevels=3
	
	DefLevelCosts(0)=100
	DefLevelCosts(1)=200
	DefLevelCosts(2)=400
	
	AbsorbRate(0)=0.2
	AbsorbRate(1)=0.5
	AbsorbRate(2)=1.0
}
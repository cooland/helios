﻿//  Copyright 2014 Craig Courtney
//    
//  Helios is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Helios is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

namespace GadrocsWorkshop.Helios.Units
{
    public abstract class MassUnit : BindingValueUnit
    {
        public override BindingValueUnitType Type
        {
            get { return BindingValueUnitType.Mass; }
        }

        /// <summary>
        /// Returns the factor which represents the number of pounds in one of this unit.
        /// Ex: Kilogram = 2.20462262 pounds so ConverstionFactor is 2.20462262.
        /// </summary>
        public abstract double ConversionFactor { get; }
    }
}

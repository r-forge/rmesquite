/* Mesquite.R source code.  Copyright 2010 W. Maddison, H. Lapp & D. Maddison. 
December 2009.

Mesquite.R is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.

This source code and its compiled class files are free and modifiable under the terms of 
GNU General Public License v. 2.  (http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
 */
package mesquite.R.common;

import mesquite.lib.MesquiteDouble;
import mesquite.lib.MesquiteInteger;

import mesquite.lib.Taxa;
import mesquite.lib.characters.CharacterData;
import mesquite.categ.lib.DNAData;
import mesquite.categ.lib.DNAState;
import mesquite.categ.lib.CategoricalData;
import mesquite.categ.lib.CategoricalState;
import mesquite.cont.lib.ContinuousData;
import mesquite.meristic.lib.MeristicData;


public class RCharacterData {

	private CharacterData charData;

	public RCharacterData(CharacterData data) {
		this.charData = data;
	}

	public String[] asStringMatrix() {
		if (!(charData instanceof CategoricalData)) {
			throw new IllegalArgumentException(
					"data is continuous, use asDoubleMatrix instead");
		}
		StateAsString stateConv = null;
		if (charData instanceof DNAData) {
			stateConv = new StateAsString() {
				public String asString(long state) {
					return DNAState.toString(state, false);
				}
			};
		} else {
			stateConv = new StateAsString() {
				public String asString(long state) {
					return CategoricalState.toString(state, false);
				}
			};
		}
		int numChars = charData.getNumChars();
		int numTaxa = charData.getNumTaxa();
		String[] matrix = new String[numTaxa * numChars];
		CategoricalData data = (CategoricalData) charData;
		for (int it = 0; it < numTaxa; it++) {
			for (int ic = 0; ic < numChars; ic++) {
				long state = data.getState(ic, it);
				matrix[it * numChars + ic] = stateConv.asString(state);
			}
		}
		return matrix;
	}

	public double[] asDoubleMatrix() {
		if (charData instanceof ContinuousData){
			ContinuousData data = (ContinuousData) charData;
			int numChars = data.getNumChars();
			int numTaxa = data.getNumTaxa();
			double[] matrix = new double[numTaxa * numChars];
			for (int it = 0; it < numTaxa; it++) {
				for (int ic = 0; ic < numChars; ic++) {
					double state = data.getState(ic, it, 0);
					if (!MesquiteDouble.isCombinable(state))
						state = Double.NaN;
					matrix[it * numChars + ic] = state;
				}
			}
			return matrix;
		}
		else if (charData instanceof MeristicData){
			MeristicData data = (MeristicData) charData;
			int numChars = data.getNumChars();
			int numTaxa = data.getNumTaxa();
			double[] matrix = new double[numTaxa * numChars];
			for (int it = 0; it < numTaxa; it++) {
				for (int ic = 0; ic < numChars; ic++) {
					int state = data.getState(ic, it, 0);
					if (!MesquiteInteger.isCombinable(state))
						matrix[it * numChars + ic] = Double.NaN;
					else
						matrix[it * numChars + ic] = state;
				}
			}
			return matrix;
		}
		return null;
	}

	public String[] getColumnNames() {
		int numChars = charData.getNumChars();
		String[] names = new String[numChars];
		for (int ic = 0; ic < numChars; ic++) {
			names[ic] = charData.getCharacterName(ic);
		}
		return names;
	}

	public String[] getRowNames() {
		Taxa taxa = charData.getTaxa();
		int numTaxa = taxa.getNumTaxa();
		String[] names = new String[numTaxa];
		for (int ic = 0; ic < numTaxa; ic++) {
			names[ic] = taxa.getTaxonName(ic);
		}
		return names;
	}

	public interface StateAsString {
		public String asString(long state);
	}
}
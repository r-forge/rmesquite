/* Mesquite.R source code.  Copyright 2010 W. Maddison, H. Lapp & D. Maddison. 
December 2009.

Mesquite.R is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.

This source code and its compiled class files are free and modifiable under the terms of 
GNU General Public License v. 2.  (http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
*/
package mesquite.R.common;
/*~~  */
import mesquite.lib.MesquiteNumber;

/* ======================================================================== */
public class RNumericMatrix  {
	public String[] columnNames;
	public String[] rowNames;
	public MesquiteNumber[][] values;
	public RNumericMatrix(){
		this(new MesquiteNumber());
	}
	public RNumericMatrix(int columns, int rows){
		columnNames = new String[columns];
		rowNames = new String[rows];
		values = new MesquiteNumber[columns][rows];
		for (int i = 0; i< columns; i++)
			for (int k =0; k< rows; k++)
				values[i][k] = new MesquiteNumber();
	}
	public RNumericMatrix(MesquiteNumber n){
		MesquiteNumber[]  aux = n.getAuxiliaries();
		if (aux == null || aux.length == 0){
			columnNames = new String[1];
			rowNames = new String[1];
			values = new MesquiteNumber[1][1];
			rowNames[0] = n.getName();
			columnNames[0] = n.getName();
			values[0][0] = new MesquiteNumber(n);
		}
		else {
			int columns = aux.length+1;
			columnNames = new String[columns];
			rowNames = new String[1];
			rowNames[0] = n.getName();
			
			values = new MesquiteNumber[columns][1];
			columnNames[0] = n.getName();
			values[0][0] = new MesquiteNumber(n);
			for (int i=1; i<columns; i++){
				values[i][0] = new MesquiteNumber(aux[i-1]);
				columnNames[i] = aux[i-1].getName();
			}
		}
		
	}
	public String[] getColumnNames(){
		return columnNames;
	}
	public String[] getRowNames(){
		return rowNames;
	}
	public MesquiteNumber[][] getValues(){
		return values;
	}
}

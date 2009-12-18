/* Mesquite.R source code.  Copyright 2009 W. Maddison, H. Lapp & D. Maddison. 
December 2009.

Mesquite.R is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.

This source code and its compiled class files are free and modifiable under the terms of 
GNU General Public License v. 2.  (http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
 */
package mesquite.R.RCallsMesquite.lib;
/* ~~ */
import java.io.File;
import java.util.*;
import mesquite.lib.*;
import mesquite.lib.duties.*;
import mesquite.lib.characters.*;

import mesquite.R.common.APETree;
import mesquite.R.common.RNumericMatrix;
import mesquite.categ.lib.*;
import mesquite.cont.lib.*;
import mesquite.*;


/* ======================================================================== */
public class MesquiteRunner {
	Mesquite mesquite;

	MesquiteProject project;

	FileCoordinator coord;

	boolean ready = false;

	public MesquiteRunner() {
		MesquiteTrunk.startedAsLibrary = true;
		MesquiteThread.suppressInteractionAsLibrary = true;
		ConsoleWindow.suppressConsoleInput = true;
		MesquiteTrunk.consoleListenSuppressed = true;
		setInteractive(true);
		//	MesquiteTrunk.suppressSystemOutPrintln = true;
	}

	public synchronized Mesquite startMesquite(String args[]) {
		System.err.println("System.errTesting");
		System.out.println("System.outTesting");
		if (mesquite != null) return mesquite;
		setInteractive(false);
		mesquite = new Mesquite(args);
		
		//here load all modules needed
		loadModuleClass(mesquite.R.RCallsMesquite.DoneEditAssistant.DoneEditAssistant.class);
		ready = true;
		System.err.println("Starting Mesquite");
		setInteractive(true);
		return mesquite;
	}

	public synchronized Mesquite startMesquite(boolean showWindows) {
		if (showWindows)
			return startMesquite(null);
		else
			return startMesquite(new String[]{"-w"});
	}
	public synchronized void stopMesquite() {
		if (mesquite == null) return;
		setInteractive(false);
		mesquite.exit(true, 0);
		mesquite = null;
		project = null;
		coord = null;
	}

	public Mesquite mesquite() {
		if (mesquite == null) startMesquite(true);
		return mesquite;
	}
	public void setInteractive(boolean interactive) {
		MesquiteThread.suppressInteractionAsLibrary = !interactive;
		MesquiteThread.unknownThreadIsScripting = !interactive;
	}

	public Thread[] getJavaThreads() {
		Thread[] threads = new Thread[Thread.currentThread().activeCount()];
		Thread.enumerate(threads);
		return threads;
	}

	public void loadModuleClass(Class c){
		String pathSlash = "R_HOME" + MesquiteFile.fileSeparator;
		CommandChecker moduleChecker = new CommandChecker();
		MesquiteModule mb = mesquite.instantiateModule(c);
		if (mb!=null && mb instanceof MesquiteModule) {
			if (mb.isPrerelease() && mb.isSubstantive()){
				MesquiteModule.mesquiteTrunk.substantivePrereleasesFound();
			}
			if (mb.compatibleWithSystem()) {
				MesquiteModuleInfo mBI = new MesquiteModuleInfo(c, mb, moduleChecker, pathSlash);
				if (!mb.getName().equals("Mesquite") && mesquite.mesquiteModulesInfoVector.nameAlreadyInList(mb.getName()))
					MesquiteTrunk.mesquiteTrunk.alert("Two modules have the same name (" + mb.getName() + ").  This may make one of the modules unavailable for use. (Module class: " + mb.getClass().getName() +
					").\n\nThis problem can arise if a module has been moved, and you update your copy of Mesquite on a Windows machine by replacing folders without deleting the previous folder, or if you are programming and you haven't updated all projects.");
				mesquite.mesquiteModulesInfoVector.addElement(mBI, false);
				mesquite.mesquiteModulesInfoVector.recordDuty(mb);
				mBI.setAsDefault(mesquite.mesquiteModulesInfoVector.isDefault(mb));
			}
			mb = null;
		}

	}
	public synchronized MesquiteModule startModule(String name, String script) {
		setInteractive(false);
		MesquiteModule module = coord.hireNamedEmployee(MesquiteModule.class, name);
		if (module == null) {
			System.err.println("Module " + name + " was not started");
			setInteractive(true);
			return null;
		}
		if (script != null) {
			Puppeteer p = new Puppeteer(module);
			MesquiteInteger pos = new MesquiteInteger(0);
			p.execute(module, script, pos, "", false);
		}
		setInteractive(true);
		return module;
	}
	public synchronized MesquiteModule startModuleOfDutyClass(String dutyClass, Object constraint) {
		Class c = findClass(dutyClass);
		if (c == null) {
			MesquiteMessage.println("Class " + dutyClass + " was not found");
			return null;
		}
		if (constraint instanceof CharacterData)
			constraint = ((CharacterData)constraint).getStateClass();
		MesquiteModule module = null;
		try {
			module = coord.hireCompatibleEmployee(c, constraint, "Choose module");
		}
		catch(Exception e){
			MesquiteFile.throwableToLog(this, e);
			return null;
		}
		if (module == null) {
			MesquiteMessage.println("Module of type " + dutyClass + " was not started");
			return null;
		}
		return module;
	}

	public synchronized void stopModule(MesquiteModule m) {
		setInteractive(false);
		coord.fireEmployee(m);
		setInteractive(true);
	}
	public String[] commandsOfModule(String name){
		MesquiteModuleInfo mod = MesquiteTrunk.mesquiteModulesInfoVector.findModule(MesquiteModule.class, name);
		if (mod != null){
			java.util.Vector v = mod.getCommands();
			java.util.Vector vE = mod.getExplanations();
			if (v == null || vE == null)
				return null;
			String[] commands = new String[v.size()];
			for (int i=0; i<v.size() && i<vE.size(); i++){
				commands[i] = (String)v.elementAt(i) + " -- " + (String)vE.elementAt(i);
			}
			return commands;
		}
		return null;
	}
	private Class findClass(String duty) {
		Class c = null;
		try {
			c = Class.forName(duty);
		} catch (ClassNotFoundException e) {
		}
		return c;
	}

	public String[] modulesWithDuty(String duty) {
		Class c = null;
		if (c == null)
			c = findClass(duty);
		if (c == null)
			c = findClass("mesquite.lib.duties." + duty);
		if (c == null)
			c = findClass("mesquite.tree.lib." + duty);
		if (c == null)
			c = findClass("mesquite.characters.lib." + duty);
		if (c == null)
			c = findClass("mesquite.cont.lib." + duty);
		if (c == null)
			c = findClass("mesquite.categ.lib." + duty);
		if (c == null)
			c = findClass("mesquite.characters.lib." + duty);
		if (c == null)
			c = findClass("mesquite.diverse.lib." + duty);
		if (c == null)
			c = findClass("mesquite.correl.lib." + duty);

		if (c != null) {
			Listable[] modules = MesquiteTrunk.mesquiteModulesInfoVector.getModulesOfDuty(c, null, coord);
			String[] s = new String[modules.length];
			for (int i = 0; i < modules.length; i++)
				s[i] = modules[i].getName() + " (Class: " + ((MesquiteModuleInfo) modules[i]).getClassName() + ")";
			return s;
		}

		return null;
	}

	public String[] dutyClasses() {
		java.util.Vector v = MesquiteTrunk.mesquiteModulesInfoVector.getDutyList();
		String[] s = new String[v.size()];
		for (int i = 0; i < v.size(); i++)
			s[i] = (String) v.elementAt(i);
		return s;
	}

	public String getName(Listable mod) {
		return mod.getName();
	}

	public String getClassName(Listable mod) {
		if (mod instanceof MesquiteModuleInfo) {
			return ((MesquiteModuleInfo) mod).getShortClassName();
		}
		return null;
	}

	public String getExplanation(Listable mod) {
		if (mod instanceof Explainable) {
			return ((Explainable) mod).getExplanation();
		}
		return null;
	}

	public void sendScriptToModule(MesquiteModule module, String script) {
		if (script != null) {
			if (module != null) {
				Puppeteer p = new Puppeteer(module);
				MesquiteInteger pos = new MesquiteInteger(0);
				p.execute(module, script, pos, "", false);
			}
		}
	}

	/* ========================================== */
	public MesquiteProject readFile(String path, String format) {
		MesquiteProject proj = mesquite().newProject(path, 1, true, "'" + path + "' @interpreter = " + format + " suppressImportFileSave");
		if (proj == null) {
			System.err.println("File Reading Failed (path " + path + ")");
			return null;
		}
		return proj;
	}

	public String[] projectContents(MesquiteProject proj) {
		java.util.Vector v = new java.util.Vector();
		if (proj.getHomeFileName() == null)
			v.addElement("Project (without home file)");
		else
			v.addElement("Project with home file " + proj.getHomeFileName());
		if (proj.getHomeDirectoryName() != null)
			v.addElement("Location: in directory " + proj.getHomeDirectoryName());
		if (proj.getFiles().size() > 1) {

			v.addElement("Linked files");
			for (int i = 0; i < proj.getFiles().size(); i++) {
				MesquiteFile file = (MesquiteFile) proj.getFiles().elementAt(i);
				if (file != proj.getHomeFile())
					v.addElement("   " + file.getName() + " at " + file.getDirectoryName());
			}
		}
		if (proj.getTaxas().size() > 0) {
			for (int i = 0; i < proj.getTaxas().size(); i++) {
				Taxa t = (Taxa) proj.getTaxas().elementAt(i);
				v.addElement("Taxa block: " + t.getName() + " (with " + t.getNumTaxa() + " taxa)");
				if (proj.getNumberCharMatricesVisible(t) > 0) {
					for (int k = 0; k < proj.getNumberCharMatricesVisible(t); k++) {
						CharacterData data = proj.getCharacterMatrixVisible(t, k);
						v.addElement("     Character matrix: " + data.getName() + " (of type " + data.getTypeName() + ")");
					}
				}
				if (proj.getNumberOfFileElements(TreeVector.class) > 0) {
					for (int k = 0; k < proj.getNumberOfFileElements(TreeVector.class); k++) {
						TreeVector trees = (TreeVector) proj.getFileElement(TreeVector.class, k);
						if (trees.getTaxa() == t)
							v.addElement("     Tree block: " + trees.getName() + " (with " + trees.size() + " trees)");
					}
				}

			}
		}
		ListableVector other = new ListableVector(); //proj.getOtherElements();
		boolean first = true;
		for (int i = 0; i < other.size(); i++) {
			Object o = other.elementAt(i);
			if (!(o instanceof TreeVector) && o instanceof FileElement && !(o instanceof SpecsSet)) {
				if (!StringUtil.blank(((FileElement) o).getName()))
					first = false;
			}
		}
		if (!first){
			first = true;
			for (int i = 0; i < other.size(); i++) {
				if (first)
					v.addElement("Other elements: ");
				first = false;
				Object o = other.elementAt(i);
				if (!(o instanceof TreeVector) && o instanceof FileElement && !(o instanceof SpecsSet)) {
					if (!StringUtil.blank(((FileElement) o).getName()))
						v.addElement("    " + ((FileElement) o).getName() + " (" + ((FileElement)o).getTypeName() + ")");
				}
			}
		}
		/* NOT READY YET
		ModelVector mv = proj.getCharacterModels();
		first = true;
		for (int i = 0; i < mv.size(); i++) {
			if (first)
				v.addElement("Character models: ");
			first = false;
			Object o = mv.elementAt(i);
			if (o instanceof CharacterModel) {
				v.addElement("    " + ((CharacterModel) o).getName() + " (" + ((CharacterModel) o).getModelTypeName() + ")");
			}
		}
		 */
		String[] s = new String[v.size()];
		for (int i = 0; i < v.size(); i++)
			s[i] = (String) v.elementAt(i);
		return s;
	}

	public Taxa[] getTaxaBlocks(MesquiteProject proj) {
		int numTaxaBlocks = proj.getNumberTaxas();
		Taxa[] result = new Taxa[numTaxaBlocks];
		for (int i = 0; i < numTaxaBlocks; i++)
			result[i] = proj.getTaxa(i);
		return result;
	}

	private Taxa findTaxaBlock(int taxaBlockID) {
		Projects p = MesquiteTrunk.getProjectList();
		for (int i = 0; i < p.getNumProjects(); i++) {
			MesquiteProject proj = p.getProject(i);
			Taxa t = proj.getTaxaByID(taxaBlockID);
			if (t != null)
				return t;
		}
		return null;
	}

	private Taxa findTaxaBlock(String name) {
		Projects p = MesquiteTrunk.getProjectList();
		for (int i = 0; i < p.getNumProjects(); i++) {
			MesquiteProject proj = p.getProject(i);
			Taxa t = proj.getTaxa(name);
			if (t != null)
				return t;
		}

		return null;
	}

	public ContinuousData[] getContinuousMatrices(Taxa taxa) {
		if (taxa == null)
			return new ContinuousData[] {};
		MesquiteProject proj = taxa.getProject();
		int numMatrices = proj.getNumberCharMatricesVisible(taxa, ContinuousState.class);
		ContinuousData[] result = new ContinuousData[numMatrices];
		for (int i = 0; i < numMatrices; i++)
			result[i] = (ContinuousData) proj.getCharacterMatrixVisible(taxa, i, ContinuousState.class);
		return result;
	}

	public CategoricalData[] getCategoricalMatrices(Taxa taxa) {
		if (taxa == null)
			return new CategoricalData[] {};
		MesquiteProject proj = taxa.getProject();
		// unfortunately Mesquite's CategoricalData is a superclass of MolecularData
		int numMatrices = proj.getNumberCharMatricesVisible(taxa, CategoricalState.class);
		int count = 0;
		for (int i = 0; i < numMatrices; i++) {
			if (!(proj.getCharacterMatrixVisible(taxa, i, CategoricalState.class) instanceof MolecularData))
				count++;
		}

		CategoricalData[] result = new CategoricalData[count];
		count = 0;
		for (int i = 0; i < numMatrices; i++) {
			if (!(proj.getCharacterMatrixVisible(taxa, i, CategoricalState.class) instanceof MolecularData))
				result[count++] = (CategoricalData) proj.getCharacterMatrixVisible(taxa, i, CategoricalState.class);
		}
		return result;
	}

	public DNAData[] getDNAMatrices(Taxa taxa) {
		if (taxa == null)
			return new DNAData[] {};
		MesquiteProject proj = taxa.getProject();
		int numMatrices = proj.getNumberCharMatricesVisible(taxa, DNAState.class);
		DNAData[] result = new DNAData[numMatrices];
		for (int i = 0; i < numMatrices; i++)
			result[i] = (DNAData) proj.getCharacterMatrixVisible(taxa, i, DNAState.class);
		return result;
	}

	public String[] getRowNames(Taxa taxa) {
		String[] names = new String[taxa.getNumTaxa()];
		for (int ic = 0; ic < taxa.getNumTaxa(); ic++) {
			names[ic] = taxa.getTaxonName(ic);
		}
		return names;
	}

	public TreeVector[] getTreeVectors(Taxa taxa) {
		System.err.println(" taxa " + taxa);
		if (taxa == null)
			return new TreeVector[] {};

		FileCoordinator useCoord = coord;
		if (useCoord == null) {
			MesquiteProject project = taxa.getProject();
			useCoord = project.getCoordinatorModule();
		}
		TreesManager manager = (TreesManager) useCoord.findElementManager(TreeVector.class);
		if (manager != null) {
			int numLists = manager.getNumberTreeBlocks(taxa);
			System.err.println(" numLists " + numLists);
			TreeVector[] result = new TreeVector[numLists];
			for (int i = 0; i < numLists; i++)
				result[i] = manager.getTreeBlock(taxa, i);
			return result;
		}
		return null;
	}
	/**/
	public String getTree(TreeVector v, int index) {
		if (v == null)
			return "";
		index--;
		if (index < v.size() && index >= 0) {
			APETree phylo = new APETree(v.getTree(index));
			return phylo.toRCommand();
		}
		return "";
	}

	// Wayne: getMesquiteTree and convertMesquiteToPHYLO
	/* ========================================== */
	public Taxa loadTaxaBlock(String name) {
		return loadTaxaBlock(name, null);
	}
	private Taxa matchInProject(MesquiteProject project, Taxa taxa){
		Projects p = MesquiteTrunk.getProjectList();
		for (int i = 0; i < project.getNumberTaxas(); i++) {
			Taxa candidate = project.getTaxa(i);
			if (candidate.equals(taxa, true, true))
				return candidate;
		}
		return null;
	}
	public Taxa loadTaxaBlock(String name, String[] names) {
		setInteractive(false);
		if (project == null) {
			project = mesquite().newProject("", 0, true);
			coord = project.getCoordinatorModule();
		}
		FileCoordinator coord = project.getCoordinatorModule();
		TaxaManager man = (TaxaManager) coord.findElementManager(Taxa.class);
		Taxa taxa = null;
		if (names == null) {
			taxa = findTaxaBlock(name);
			setInteractive(true);
			if (taxa != null) {
				return taxa;
			}
		}
		taxa = man.makeNewTaxa(name, names.length, false);
		for (int i = 0; i < names.length; i++)
			taxa.setTaxonName(i, names[i]);
		Taxa candidate = matchInProject(project, taxa);
		if (candidate != null){
			taxa.dispose();
			setInteractive(true);
			return candidate;
		}
		taxa.addToFile(project.getHomeFile(), project, man);
		setInteractive(true);
		return taxa;
	}

	public CategoricalData loadCategoricalMatrix(Taxa taxa, String name, int numChars, int[] matrix) {
		if (project == null) {
			System.err.println("Taxa block must be loaded before matrix");
			return null;
		}
		setInteractive(false);
		CharactersManager man = (CharactersManager) coord.findElementManager(CharacterData.class);
		CategoricalData data = (CategoricalData) man.newCharacterData(taxa, numChars, "Standard Categorical Data");
		data.addToFile(project.getHomeFile(), project, man);

		int count = 0;
		for (int ic = 0; ic < numChars; ic++) {
			for (int it = 0; it < taxa.getNumTaxa(); it++) {
				if (matrix[count] >= 0) {
					int state = matrix[count];
					data.setState(ic, it, CategoricalState.makeSet(state));
				}
				count++;
			}
		}
		setInteractive(true);
		return data;
	}

	public MesquiteTree loadTree(Taxa taxa, String name, String newick) {
		if (project == null) {
			System.err.println("Taxa block must be loaded before tree");
			return null;
		}
		setInteractive(false);
		TreesManager man = (TreesManager) coord.findElementManager(TreeVector.class);
		TreeVector trees = man.getTreeBlock(taxa, 0);
		if (trees == null) {
			trees = man.makeNewTreeBlock(taxa, "RunnerTrees for " + taxa.getName(), project.getHomeFile());
			trees.addToFile(project.getHomeFile(), project, man);
		}
		MesquiteTree tree = new MesquiteTree(taxa, newick);
		if (name != null)
			tree.setName(name);
		trees.addElement(tree, true);
		setInteractive(true);
		return tree;
	}

	/* ========================================== */

	public RNumericMatrix numberForTreeAndMatrix(int moduleID, MesquiteTree tree, CharacterData matrix) {
		MesquiteModule m = mesquite().findEmployeeWithIDNumber(moduleID);
		if (m instanceof NumberForMatrixAndTree && tree instanceof Tree && matrix instanceof CharacterData) {
			NumberForMatrixAndTree calc = (NumberForMatrixAndTree) m;
			MesquiteNumber n = new MesquiteNumber();
			MesquiteString s = new MesquiteString();
			calc.calculateNumber((Tree) tree, ((CharacterData) matrix).getMCharactersDistribution(), n, s);
			if (n.isCombinable()) {
				return new RNumericMatrix(n);
			}
		}
		return new RNumericMatrix();
	}

	public RNumericMatrix numberForTreeAndCharacter(MesquiteModule m, MesquiteTree tree, CharacterData matrix, int index) {
		index--;  //change character to zero based
		if (tree == null || matrix == null)
			return new RNumericMatrix();

		if (m == null){
			m = coord.hireCompatibleEmployee(NumberForCharAndTree.class, matrix.getStateClass(), "Value to calculate for tree and character");

		}
		if (m instanceof NumberForCharAndTree && tree instanceof Tree && matrix instanceof CharacterData) {
			NumberForCharAndTree calc = (NumberForCharAndTree) m;
			MesquiteNumber n = new MesquiteNumber();
			MesquiteString s = new MesquiteString();
			calc.calculateNumber((Tree) tree, ((CharacterData) matrix).getCharacterDistribution(index), n, s);
			System.err.println("Result: " + s);
			if (n.isCombinable()) {
				return new RNumericMatrix(n);
			}
		}
		return new RNumericMatrix();
	}
	/* ========================================== */
	/* ========================================== */
	/* ========================================== */
	/* ========================================== */
	Vector treeWindowsForEditing = new Vector();
	mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker findTWModuleForTree(MesquiteTree tree){
		for (int i = 0; i< treeWindowsForEditing.size(); i++){
			mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker twm = (mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker)treeWindowsForEditing.elementAt(i);
			if (twm.getTree().getTaxa() == tree.getTaxa()){
				if (twm.isDoomed()){
					treeWindowsForEditing.removeElement(twm);
					return null;
				}
				return twm;
			}
		}
		return null;
	}
	public MesquiteTree editTree(MesquiteTree tree) {
		setInteractive(false);
		mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord man = (mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord) coord.findEmployeeWithDuty(mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord.class);
		Taxa taxa = tree.getTaxa();
		System.err.println("Editing tree: " + tree.writeTree());

		mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker twm = (mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker)man.showTreeWindow(taxa);
		String script = "getTreeDrawCoordinator; tell It; suppress; setTreeDrawer  #mesquite.trees.SquareTree.SquareTree; tell It; setNodeLocs #mesquite.trees.NodeLocsStandard.NodeLocsStandard; tell It; branchLengthsToggle on; endTell; orientRight; endTell; desuppress; endTell;";
		sendScriptToModule(twm, script);

		setInteractive(true);
		twm.showTree(tree);
		mesquite.R.RCallsMesquite.DoneEditAssistant.DoneEditAssistant dea = (mesquite.R.RCallsMesquite.DoneEditAssistant.DoneEditAssistant)twm.doCommand("newAssistant", "#DoneEditAssistant", CommandChecker.defaultChecker);

		MesquiteWindow w = twm.getModuleWindow();
		w.setWindowSize(1200, 700);
		w.show();
		try {
			while (!dea.isDone()){
				Thread.sleep(50);
			}
		}
		catch (InterruptedException e){
		}
		MesquiteTree t = (MesquiteTree)twm.getTree();
		MesquiteTree q = t.cloneTree();
		twm.fireEmployee(dea);
		man.fireEmployee(twm);
		return q;
	}
	public void showTree(MesquiteTree tree) {
		setInteractive(false);
		mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker twm = findTWModuleForTree(tree);

		if (twm == null) {
			mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord man = (mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord) coord.findEmployeeWithDuty(mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord.class);
			Taxa taxa = tree.getTaxa();
			System.err.println("Showing tree: " + tree.writeTree());

			twm = (mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker)man.showTreeWindow(taxa);
			String script = "getTreeDrawCoordinator; tell It; suppress; setTreeDrawer  #mesquite.trees.SquareTree.SquareTree; tell It; setNodeLocs #mesquite.trees.NodeLocsStandard.NodeLocsStandard; tell It; branchLengthsToggle on; endTell; orientRight; endTell; desuppress; endTell;";
			sendScriptToModule(twm, script);
			treeWindowsForEditing.addElement(twm);
		}
		setInteractive(true);
		twm.showTree(tree);
		MesquiteWindow w = twm.getModuleWindow();
		w.setWindowSize(1200, 700);
		w.show();
	}

	mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker findFrontmostTreeWindow(FileCoordinator coord){

		mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord man = (mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord) coord.findEmployeeWithDuty(mesquite.trees.BasicTreeWindowCoord.BasicTreeWindowCoord.class);
		ListableVector v = man.getEmployeeVector();
		//look first for a front window
		for (int i = 0; i< v.size(); i++){
			Object obj = v.elementAt(i);
			if (obj instanceof mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker){
				mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker twm = (mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker)obj;
				if (!twm.isDoomed()  & twm.getModuleWindow() != null && twm.getModuleWindow().isFrontMostInLocation()){
					return twm;
				}
			}
		}
		//now choose any tree window
		for (int i = 0; i< v.size(); i++){
			Object obj = v.elementAt(i);
			if (obj instanceof mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker){
				mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker twm = (mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker)obj;
				if (!twm.isDoomed()  & twm.getModuleWindow() != null){
					return twm;
				}
			}
		}
		return null;
	}
	public MesquiteTree getTreeInWindow() {
		mesquite.trees.BasicTreeWindowMaker.BasicTreeWindowMaker twm = null;
		if (coord != null) 
			twm = findFrontmostTreeWindow(coord);
		else {
			Projects projects = MesquiteTrunk.getProjectList();
			int i = 0;
			while (twm == null && i<projects.getNumProjects()){
				MesquiteProject proj = projects.getProject(i);
				FileCoordinator c = proj.getCoordinatorModule();
				twm = findFrontmostTreeWindow(c);
				if (twm != null)
					coord = c;
				i++;
			}
		}
		//MesquiteThread.actingAsLibrary = false;
		if (twm != null) 	{	
			MesquiteTree t = (MesquiteTree)twm.getTree();
			return t.cloneTree();
		}
		return null;

	}
	mesquite.charMatrices.BasicDataWindowMaker.BasicDataWindowMaker findFrontmostMatrixWindow(FileCoordinator coord){
		mesquite.charMatrices.BasicDataWindowCoord.BasicDataWindowCoord man = (mesquite.charMatrices.BasicDataWindowCoord.BasicDataWindowCoord) coord.findEmployeeWithDuty(mesquite.charMatrices.BasicDataWindowCoord.BasicDataWindowCoord.class);
		ListableVector v = man.getEmployeeVector();
		for (int i = 0; i< v.size(); i++){
			Object obj = v.elementAt(i);
			if (obj instanceof mesquite.charMatrices.BasicDataWindowMaker.BasicDataWindowMaker){
				mesquite.charMatrices.BasicDataWindowMaker.BasicDataWindowMaker twm = (mesquite.charMatrices.BasicDataWindowMaker.BasicDataWindowMaker)obj;
				if (!twm.isDoomed()  & twm.getModuleWindow() != null && twm.getModuleWindow().isFrontMostInLocation()){
					return twm;
				}
			}
		}
		for (int i = 0; i< v.size(); i++){
			Object obj = v.elementAt(i);
			if (obj instanceof mesquite.charMatrices.BasicDataWindowMaker.BasicDataWindowMaker){
				mesquite.charMatrices.BasicDataWindowMaker.BasicDataWindowMaker twm = (mesquite.charMatrices.BasicDataWindowMaker.BasicDataWindowMaker)obj;
				if (!twm.isDoomed()  & twm.getModuleWindow() != null){
					return twm;
				}
			}
		}
		return null;
	}
	public CharacterData getMatrixInWindow() {
		mesquite.charMatrices.BasicDataWindowMaker.BasicDataWindowMaker twm = null;
		if (coord != null)
			twm = findFrontmostMatrixWindow(coord);
		else {
			Projects projects = MesquiteTrunk.getProjectList();
			int i = 0;
			while (twm == null && i<projects.getNumProjects()){
				MesquiteProject proj = projects.getProject(i);
				FileCoordinator c = proj.getCoordinatorModule();
				twm = findFrontmostMatrixWindow(c);
				if (twm != null)
					coord = c;
				i++;
			}
		}
		//MesquiteThread.actingAsLibrary = false;
		if (twm != null) 	{	
			CharacterData t = (CharacterData)twm.getCharacterData();
			if (t instanceof ContinuousData){
				ContinuousData data = (ContinuousData) t;
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
			}
			CharacterData clone =  t.cloneData();
			if (clone instanceof ContinuousData){
				ContinuousData data = (ContinuousData) clone;
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
			}
			return clone;
		}
		return null;

	}
	/* ========================================== */
	/* ========================================== */
	/* ========================================== */

	void packFreqs(Tree tree, int node, MesquiteNumber[][] freqs, CategoricalHistory hist, MesquiteInteger pos) {
		pos.increment();
		if (hist.frequenciesExist()) {
			double[] freq = hist.getFrequencies(node);
			if (freq != null) {
				for (int i = 0; i < freq.length; i++) {
					freqs[i][pos.getValue()].setValue(freq[i]);
				}
			}
		}
		for (int d = tree.firstDaughterOfNode(node); tree.nodeExists(d); d = tree.nextSisterOfNode(d)) {
			packFreqs(tree, d, freqs, hist, pos);
		}
	}

	int maxStateInTree(Tree tree, int node, CategoricalHistory hist) {
		int max = 0;
		if (hist.frequenciesExist()) {
			double[] freq = hist.getFrequencies(node);
			if (freq != null || freq.length > 1) {
				int maxHere = 0;
				for (int i = 0; i < freq.length; i++) {
					if (freq[i] > 0.0)
						maxHere = i;
				}
				if (maxHere > max)
					max = maxHere;
			}
		}
		for (int d = tree.firstDaughterOfNode(node); tree.nodeExists(d); d = tree.nextSisterOfNode(d)) {
			int maxD = maxStateInTree(tree, d, hist);
			if (maxD > max)
				max = maxD;
		}
		return max;
	}

	public RNumericMatrix ancestralStatesCategorical(MesquiteModule m, MesquiteTree tree, CategoricalData matrix, int index) {
		index--;

		//showTree(tree);
		if (m instanceof CharStatesForNodes && tree instanceof Tree && matrix instanceof CharacterData) {
			CharStatesForNodes calc = (CharStatesForNodes) m;
			MesquiteNumber n = new MesquiteNumber();
			MesquiteString s = new MesquiteString();
			CategoricalDistribution oneObserved = (CategoricalDistribution) ((CharacterData) matrix).getCharacterDistribution(index);
			CategoricalHistory oneReconstructed = (CategoricalHistory) oneObserved.adjustHistorySize(tree, null);
			calc.calculateStates((Tree) tree, oneObserved, oneReconstructed, s);
			System.err.println("Ancestral states reconstructed: " + s);

			int maxStates = maxStateInTree(tree, tree.getRoot(), oneReconstructed) + 1;
			RNumericMatrix results = new RNumericMatrix(maxStates, tree.numberOfNodesInClade(tree.getRoot()));
			for (int i = 0; i < maxStates; i++)
				results.columnNames[i] = Integer.toString(i);
			packFreqs(tree, tree.getRoot(), results.values, oneReconstructed, new MesquiteInteger(-1));
			return results;
		}
		return null;
	}

	/* ========================================== */

	public static void main(String[] args) {
		MesquiteRunner mr = new MesquiteRunner();
		mr.startMesquite(args);
		Taxa t = mr.loadTaxaBlock("Test", new String[] { "a1", "a2", "a3", "a4" });
		System.out.println("taxa test " + t);
		int[] matrix = new int[12];
		matrix[0] = 0;
		matrix[1] = 1;
		matrix[2] = 1;
		matrix[3] = 0;
		CategoricalData cat = (CategoricalData) mr.loadCategoricalMatrix(t, "Matrix", 2, matrix);
		System.out.println("data " + cat);
		MesquiteTree tree = mr.loadTree(t, "treee", "(((a1:1.2,a3:3.4):1.5,a4:2.8):4.2,a2):0.6;");
		System.out.println("tree " + tree.writeTree());
		/*
		 * int modID = mr.startModule("#TreelengthForMatrix"); System.out.println("modID " + modID); double num = mr.numberForTreeAndMatrix(modID, tree, cat); System.out.println("result " + num);
		 * 
		 * 
		 * int modID2 = mr.startModule("#BiSSELikelihood"); System.out.println("modID " + modID2); double num2 = mr.numberForTreeAndCharacter(modID2, tree, cat, 0); System.out.println("result " + num2);
		 * 
		 */
	}

}

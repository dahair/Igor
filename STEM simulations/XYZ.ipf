#pragma rtGlobals=1		// Use modern global access method.

// Functions to read, write, and manipulate XYZ coordinate files for Earl
// Kirkland's EM simulation package
//
// added RDF, pmv 06-30-06
// added PartialRDF, split RDF and RDFWork, pmv 06-07-06
// added SaveCIF, ZtoSymbol, pmv 01-14-10

function SetCell(xyz, ax, by, cz)
	wave xyz
	variable ax, by, cz
	
	SetAX(xyz, ax)
	SetBY(xyz, by)
	SetCZ(xyz, cz)
end

function SetAX(xyz, ax)
	wave xyz
	variable ax
	
	string n = note(xyz)
	n = ReplaceNumberByKey("ax", n, ax)
	
	Note/K xyz
	Note xyz, n	
end

function SetBY(xyz, by)
	wave xyz
	variable by
	
	string n = note(xyz)
	n = ReplaceNumberByKey("by", n, by)
	
	Note/K xyz
	Note xyz, n	
end

function SetCZ(xyz, cz)
	wave xyz
	variable cz
	
	string n = note(xyz)
	n = ReplaceNumberByKey("cz", n, cz)
	
	Note/K xyz
	Note xyz, n	
end

function GetAX(xyz)
	wave xyz
	
	string n = note(xyz)
	variable ax = NumberByKey("ax", n)
	return ax
end

function GetBY(xyz)
	wave xyz
	
	string n = note(xyz)
	variable by = NumberByKey("by", n)
	return by
end

function GetCZ(xyz)
	wave xyz
	
	string n = note(xyz)
	variable cz = NumberByKey("cz", n)
	return cz
end

function SaveXYZ(name, xyz)
	string name
	wave xyz
	
	variable npts = DimSize(xyz, 0)
	Make/O/N=(npts) zn, xa, ya, za, occ, deb
	zn = xyz[p][0]
	xa = xyz[p][1]
	ya = xyz[p][2]
	za = xyz[p][3]
	occ = xyz[p][4]
	deb = xyz[p][5]
	
	if(DimSize(xyz, 1) != 6)
		printf "The XYZ wave must have six columns.\r"
		return 0
	endif

	variable f
	Open/T=".xyz" f
	if(!strlen(S_filename))
		printf "Error opening file.\r"
		return 0
	endif
	
	Sort za, zn, xa, ya, za, occ, deb

	fprintf f, "%s\n", name
	fprintf f, "\t%f\t%f\t%f\n", GetAX(xyz), GetBY(xyz), GetCZ(xyz)
	wfprintf f, "%d\t %g\t %g\t %g\t %g\t %g\n" zn, xa, ya, za, occ, deb
	
	fprintf f, "-1\n"
	
	close f
	
	KillWaves zn, xa, ya, za, occ, deb
end

function SaveCIF(name, xyz)
	string name
	wave xyz
	
	if(DimSize(xyz, 1) != 6)
		printf "The XYZ wave must have six columns.\r"
		return 0
	endif

	variable f
	Open/T=".cif" f
	if(!strlen(S_filename))
		printf "Error opening file.\r"
		return 0
	endif
	
	variable ax, by, cz
	ax = GetAX(xyz)
	by = GetBY(xyz)
	cz = GetCZ(xyz)
	
	variable npts = DimSize(xyz, 0)
	Make/O/N=(npts) zn, xa, ya, za, occ
	Make/O/T/N=(npts) site_label, site_type_symbol
	zn = xyz[p][0]
	xa = xyz[p][1] / ax
	ya = xyz[p][2] / by
	za = xyz[p][3] / cz
	occ = xyz[p][4]
	Sort zn, zn, xa, ya, za, occ
	site_label = ZtoSymbol(zn[p])
	
	variable i, count = 0
	string type_temp
	sprintf type_temp, "%s%d", site_label[0], count
	site_type_symbol[0] = type_temp
	for(i=1; i<npts; i+=1)
		if (!cmpstr(site_label[i], site_label[i-1]))
			count += 1
		else
			count = 0
		endif

		sprintf type_temp, "%s%d", site_label[i], count
		site_type_symbol[i] = type_temp
		
	endfor

	fprintf f, "#This .cif file generated by Igor SaveCIF by PMV.\r"
	fprintf f, "#Original description: %s\r\r", name

	fprintf f, "data_%s\r\r", name

	fprintf f, "_cell_length_a     %g\r", GetAX(xyz)
	fprintf f, "_cell_length_b     %g\r",   GetBY(xyz)
	fprintf f, "_cell_length_c     %g\r", GetCZ(xyz)
	fprintf f, "_cell_angle_alpha    90\r"
	fprintf f, "_cell_angle_beta    90\r"
	fprintf f, "_cell_angle_gamma    90\r\r"

	fprintf f, "_symmetry_cell_setting    triclinic\r"
	fprintf f, "_symmetry_space_group_name_H-M    'P 1'\r\r"

	fprintf f, "loop_\r"
	fprintf f, "_atom_site_label\r"
	fprintf f, "_atom_site_type_symbol\r"
	fprintf f, "_atom_site_fract_x\r"
	fprintf f, "_atom_site_fract_y\r"
	fprintf f, "_atom_site_fract_z\r"
	fprintf f, "_atom_site_occupancy\r"

	wfprintf f, "%s\t %s\t %g\t %g\t %g\t %g\n" site_label, site_type_symbol, xa, ya, za, occ
		
	close f
	
	KillWaves site_label, site_type_symbol, zn, xa, ya, za, occ
end

function/S ZtoSymbol(znum)
	variable znum
	
	make/o/n=(110)/t ZtoSymbol_work
	ZtoSymbol_work[0,18] = {"no", "H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne", "Na", "Mg", "Al", "Si", "P", "S", "Cl", "Ar"}
	ZtoSymbol_work[19, 37] = {"K", "Ca", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn", "Ga", "Ge", "As", "Se", "Br", "Kr", "Rb"}
	ZtoSymbol_work[38, 57] = {"Sr", "Y", "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd", "In", "Sn", "Sb", "Te", "I", "Xe", "Cs", "Ba", "La"}
	ZtoSymbol_work[58, 76] = {"Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu", "Hf", "Ta", "W", "Re", "Os"}
	ZtoSymbol_work[77,96] = {"Ir", "Pt", "Au", "Hg", "Tl", "Pb", "Bi", "Po", "At", "Rn", "Fr", "Ra", "Ac", "Th", "Pa", "U", "Np", "Pu", "Am", "Cm"}
	ZtoSymbol_work[97,109] = {"Bk", "Cf", "Es", "Fm", "Md", "No", "Lr", "Rf", "Db", "Sg", "Bh", "Hs", "Mt"}

	string ret = ZtoSymbol_work[znum]
	
	Killwaves ZtoSymbol_work

	return ret
	
end

function SaveXYZNoSortZ(name, xyz)
	string name
	wave xyz
	
	variable npts = DimSize(xyz, 0)
	Make/O/N=(npts) zn, xa, ya, za, occ, deb
	zn = xyz[p][0]
	xa = xyz[p][1]
	ya = xyz[p][2]
	za = xyz[p][3]
	occ = xyz[p][4]
	deb = xyz[p][5]
	
	if(DimSize(xyz, 1) != 6)
		printf "The XYZ wave must have six columns.\r"
		return 0
	endif

	variable f
	Open/T=".xyz" f
	if(!strlen(S_filename))
		printf "Error opening file.\r"
		return 0
	endif
	
	fprintf f, "%s\n", name
	fprintf f, "\t%f\t%f\t%f\n", GetAX(xyz), GetBY(xyz), GetCZ(xyz)
	wfprintf f, "%d\t %g\t %g\t %g\t %g\t %g\n" zn, xa, ya, za, occ, deb
	
	fprintf f, "-1\n"
	
	close f
	
	KillWaves zn, xa, ya, za, occ, deb
end


function SaveXYZNoDialog(name, path, xyz)
	string name, path
	wave xyz
	
	variable npts = DimSize(xyz, 0)
	Make/O/N=(npts) zn, xa, ya, za, occ, deb
	zn = xyz[p][0]
	xa = xyz[p][1]
	ya = xyz[p][2]
	za = xyz[p][3]
	occ = xyz[p][4]
	deb = xyz[p][5]
	
	if(DimSize(xyz, 1) != 6)
		printf "The XYZ wave must have six columns.\r"
		return 0
	endif

	variable f
	Open/T=".xyz" f as path
	if(!strlen(S_filename))
		printf "Error opening file.\r"
		return 0
	endif
	
	fprintf f, "%s\n", name
	fprintf f, "\t%f\t%f\t%f\n", GetAX(xyz), GetBY(xyz), GetCZ(xyz)
	wfprintf f, "%d\t %g\t %g\t %g\t %g\t %g\n" zn, xa, ya, za, occ, deb
	
	fprintf f, "-1\n"
	
	close f
	
	KillWaves zn, xa, ya, za, occ, deb
end

function LoadXYZ()

	variable xyzf
	Open/R/T=".xyz" xyzf
	
	if(!xyzf)
		return 0
	endif
	
	variable ax, by, cz
	string line
	FReadLine xyzf, line
	FReadLine xyzf, line
	sscanf line, "%g %g %g", ax, by, cz
	
	close xyzf
	
	LoadWave/J/L={0, 2, 0, 0, 0}/M/N=xyz S_filename
	Duplicate/O xyz0, xyz
	Killwaves xyz0
	DeletePoints/M=0 DimSize(xyz, 0)-1, 1, xyz
	
	SetCell(xyz, ax, by, cz)
	
end


function PeriodicContinue(xyz, nx, ny, nz)
	wave xyz
	variable nx, ny, nz
	
	variable ax = GetAX(xyz)
	variable by = GetBY(xyz)
	variable cz = GetCZ(xyz)
	variable natoms = DimSize(xyz, 0)
	
	variable npatoms = natoms*nx*ny*nz
	
	Make/O/N=(npatoms, 6) xyz_cont
	variable ix, iy, iz, ip = 0
	for(ix = 0; ix<nx; ix+=1)
		for(iy=0; iy<ny; iy+=1)
			for(iz=0; iz<nz; iz+=1)
				xyz_cont[ip,ip+natoms][] = xyz[p-ip][q]
				xyz_cont[ip,ip+natoms][1] += ix*ax
				xyz_cont[ip,ip+natoms][2] += iy*by
				xyz_cont[ip,ip+natoms][3] += iz*cz
				ip += natoms
			endfor
		endfor
	endfor
	
	SetCell(xyz_cont, ax*nx, by*ny, cz*nz)				
	
end


// recenter the coordinates of the xyz wave about the
// point (xc, yc, zc) measured in units of the sueprcell
// size.  So Recenter(xyz, 0.5, 0.5, 0.5) puts the coordinates
// in the middle of the supercell that extends from 0 to 1.
function Recenter(xyz, xc, yc, zc)
	wave xyz
	variable xc, yc, zc
	
	variable ax = GetAX(xyz)
	variable by = GetBY(xyz)
	variable cz = GetCZ(xyz)
	
	printf "Model supercell is (%g, %g, %g) A.\r", ax, by, cz
	
	variable sx, sy, sz // shifts
	variable xmin = 2*ax, xmax = -2*ax, ymin = 2*by, ymax = -2*by, zmin = 2*cz, zmax = -2*cz
	variable natoms = DimSize(xyz, 1)

	make/O/N=(DimSize(xyz, 0)) size_t
	size_t = xyz[p][1]
	Wavestats/Q size_t
	xmax = V_max
	xmin = V_min

	size_t = xyz[p][2]
	Wavestats/Q size_t
	ymax = V_max
	ymin = V_min
		
	size_t = xyz[p][3]
	Wavestats/Q size_t
	zmax = V_max
	zmin = V_min
		
	KillWaves size_t	
	
	printf "Model extends from %g to %g in x, %g to %g in y, and %g to %g in z.\r", xmin, xmax, ymin, ymax, zmin, zmax
	
	sx = (xmax + xmin)/2 - xc*ax
	sy = (ymax + ymin)/2 - yc*by
	sz = (zmax + zmin)/2 - zc*cz
	
	printf "Recentering shift is (%g, %g, %g) to every atom.\r", sx, sy, sz
	
	xyz[][1] -= sx
	xyz[][2] -= sy
	xyz[][3] -= sz
	
end
	

function StackXYZ(top, bot)
	wave top, bot
	
	if( (GetAX(top) != GetAX(bot)) || (GetBY(top) != GetBY(bot)) )
		printf "Can only stack models of the same size.  Exiting.\r"
		return 0
	endif
	
	variable topz = GetCZ(top)
	variable topn = DimSize(top, 0), botn = DimSize(bot, 0)
	Redimension/N=((topn+botn), 6) top
	
	top[topn,][] = bot[p-topn][q]
	top[topn, ][3] = bot[p-topn][3] + topz
	
	SetCZ(top, (GetCZ(top)+GetCZ(bot)))
	
end


function Shift(xyz, axis, dist)
	wave xyz
	variable axis, dist
	
	if(dist < 0)
		printf "Sorry.  Only works for positive shifts.\r"
		return 0
	endif
	
	make/n=(DimSize(xyz, 0)) shift_t
	
	variable cell
	switch(axis)
		case 1:
			shift_t = xyz[p][1]
			cell = GetAX(xyz)
			break
		case 2:
			shift_t = xyz[p][2]
			cell = GetBY(xyz)
			break
		case 3:
			shift_t = xyz[p][3]
			cell = GetCZ(xyz)
			break
		default:
			printf "Axis %d not found.  Must be 1, 2, or 3.\r", axis
			Killwaves shift_t
			return 0
	endswitch
	
	shift_t += dist
	shift_t = (shift_t[p] > cell ? shift_t[p] - cell : shift_t[p] )

	switch(axis)
		case 1:
			xyz[][1] = shift_t[p]
			break
		case 2:
			xyz[][2] = shift_t[p]
			break
		case 3:
			xyz[][3] = shift_t[p]
			break
	endswitch
	
	KillWaves shift_t
	
end
	

//ax, by, or cz < 0 means no cut in that direction
function CutXYZ(xyz, ax, by, cz)
	wave xyz
	variable ax, by, cz
	
	variable natoms = DimSize(xyz, 0)
	Make/O/N=(natoms) zn, xa, ya, za, occ, deb
	
	zn = xyz[p][0]
	xa = xyz[p][1]
	ya = xyz[p][2]
	za = xyz[p][3]
	occ = xyz[p][4]
	deb = xyz[p][5]
	
	//cut in X
	if(ax > 0)
		sort xa, zn, xa, ya, za, occ, deb
		FindLevel/P xa, ax
		if(!V_flag)
			DeletePoints V_levelX, (natoms-V_levelX+1), zn, xa, ya, za, occ, deb
		endif
		natoms = numpnts(xa)
	else
		ax = GetAX(xyz)
	endif

	 //cut in Y
	if(by > 0)
		sort ya, zn, xa, ya, za, occ, deb
		FindLevel/P ya, by
		if(!V_flag)
			DeletePoints V_levelX, (natoms-V_levelX+1), zn, xa, ya, za, occ, deb
		endif
		natoms = numpnts(xa)
	else
		by = GetBY(xyz)
	endif

	 //cut in Z
	if(cz > 0)
		sort za, zn, xa, ya, za, occ, deb
		FindLevel/P za, cz
		if(!V_flag)
			DeletePoints V_levelX, (natoms-V_levelX+1), zn, xa, ya, za, occ, deb
		endif
		natoms = numpnts(xa)
	else
		cz = GetCZ(xyz)
	endif 
	
	Make/O/N=((natoms), 6) cut_xyz
	cut_xyz[][0] = zn[p]
	cut_xyz[][1] = xa[p]
	cut_xyz[][2] = ya[p]
	cut_xyz[][3] = za[p]
	cut_xyz[][4] = occ[p]
	cut_xyz[][5] = deb[p]
	SetCell(cut_xyz, ax, by, cz)
	
	KillWaves zn, xa, ya, za, occ, deb
end

function DensityXYZ(xyz)
	wave xyz
	
	return DimSize(xyz, 0) / (GetAX(xyz)*GetBY(xyz)*GetCZ(xyz))
end
	 
function SizeXYZ(xyz)
	wave xyz
	
	make/O/N=(DimSize(xyz, 0)) size_t
	
	size_t = xyz[p][1]
	Wavestats/Q size_t
	if((V_max - V_min) > GetAX(xyz) )
		printf "WARNING: X box size is %g.  X coordinates run from %g to %g, a difference of %g.,\r", GetAX(xyz), V_min, V_max, V_max - V_min
	else
		printf "X box size is %g.  X coordinates run from %g to %g, a difference of %g.,\r", GetAX(xyz), V_min, V_max, V_max - V_min
	endif

	size_t = xyz[p][2]
	Wavestats/Q size_t
	if((V_max - V_min) > GetBY(xyz))
		printf "WARNING: Y box size is %g.  Y coordinates run from %g to %g, a difference of %g.,\r", GetBY(xyz), V_min, V_max, V_max - V_min
	else
		printf "Y box size is %g.  Y coordinates run from %g to %g, a difference of %g.,\r", GetBY(xyz), V_min, V_max, V_max - V_min
	endif
	
	size_t = xyz[p][3]
	Wavestats/Q size_t
	if((V_max - V_min) > GetCZ(xyz) )
		printf "WARNING: Z box size is %g.  Z coordinates run from %g to %g, a difference of %g.,\r", GetCZ(xyz), V_min, V_max, V_max - V_min
	else
		printf "Z box size is %g.  Z coordinates run from %g to %g, a difference of %g.,\r", GetCZ(xyz), V_min, V_max, V_max - V_min
	endif
		
	KillWaves size_t	
end

function MakeSphere(xyz, diameter)
	wave xyz
	variable diameter
	
	
	variable ax, by, cz
	ax = GetAX(xyz)
	by = GetBY(xyz)
	cz = GetCZ(xyz)
	
	variable dupx, dupy, dupz
	dupx = ceil(diameter / ax)+1
	dupy = ceil(diameter / by)+1
	dupz = ceil(diameter / cz)+1
	
	PeriodicContinue(xyz, dupx, dupy, dupz)
	Duplicate/O xyz_cont sphere
	Killwaves xyz_cont
	wave sphere = $"sphere"
	variable xc = GetAX(sphere)/2
	variable yc = GetBY(sphere)/2
	variable zc = GetCZ(sphere)/2
	
	Make/O/N=(DimSize(sphere, 0)) dist, dummy, Znum, xa, ya, za, occ, debye
	Znum = sphere[p][0]
	xa = sphere[p][1]
	ya = sphere[p][2]
	za = sphere[p][3]
	debye = sphere[p][4]
	occ = sphere[p][5]
	dummy = p
	dist = (sphere[p][1] - xc)^2 + (sphere[p][2]-yc)^2 + (sphere[p][3]-zc)^2
	
	Sort dist, dist, dummy, Znum, xa, ya, za, debye, occ
	variable pchop = binarysearch(dist, ((diameter/2)^2))+1
	
	DeletePoints pchop, numpnts(dist), sphere, dummy, Znum, xa, ya, za, debye, occ
	Sort dummy, Znum, xa, ya, za, debye, occ
	sphere[][0] = Znum[p]
	sphere[][1] = xa[p]
	sphere[][2] = ya[p]
	sphere[][3] = za[p]
	sphere[][4] = debye[p]
	sphere[][5] = occ[p]
	
	Killwaves dist, dummy, Znum xa, ya, za, debye, occ
	//variable i=0, dist, r2 = (diameter/2)^2
	//do
	//	dist =  ( (sphere[i][1] - xc)^2 + (sphere[i][2] - yc)^2 + (sphere[i][3]-zc)^2 )
	//	if(dist > r2)
	///		DeletePoints i, 1, sphere
	//		//printf "deleteing point.\r"
	//	else
	//		i+=1
	//	endif
	//	//if(!mod(i, 100))
	//	//	printf "i=%d\r", i
	//	//endif
	//while(i < DimSize(sphere, 0))
	
	SetCell(sphere, diameter+3, diameter+3, diameter+3)
	Recenter(sphere, 0.5, 0.5, 0.5)
	printf "Sphere created with %d atoms.\r", DimSize(sphere, 0)
end


// Calculate radial distribution function of a model, discretized into
// "pts" number of points.  If the function generates an "out of memory"
// or "too many points in the wave" error, reduce the parameter mem.
function RDF(atoms, pts)
	wave atoms
	variable pts
	
	string rdf_name = NameofWave(atoms)+"_rdf"
	RDFWork(atoms, pts)
	Duplicate/O prdf_w $rdf_name

	Killwaves prdf_w
end	

function RDFWork(atoms, pts)
	wave atoms
	variable pts
	
	variable mem = 5e7
	
	variable ax, by, cz, natoms
	ax = GetAX(atoms)
	by = GetBY(atoms)
	cz = GetCZ(atoms)
	natoms = DimSize(atoms, 0)
	
	variable radius = max(ax, max(by, cz)) / 2
	Make/O/N=(pts) prdf_w = 0
	SetScale/I x 0, radius, "", prdf_w
	
	variable qstep,nq = 0
	do
		qstep = min( floor(mem / natoms), (natoms - nq) )
		Make/O/N=(natoms, qstep) pairs
		SetScale/p x, 0, 1, "", pairs
		SetScale/p y nq, 1, "", pairs
		//printf "nq = %d, pairs y scale from %d to %d.\r", nq, DimOffset(pairs, 1), DimOffset(pairs, 1) + Dimdelta(pairs, 1)*DimSize(pairs, 1)
		pairs = ( (atoms(x)[1] - atoms(y)[1])^2 + (atoms(x)[2] - atoms(y)[2])^2 + (atoms(x)[3] - atoms(y)[3])^2 )
		pairs = sqrt(pairs)
		Histogram/B=2/A pairs, prdf_w
		nq += qstep
	while(nq < natoms)
	
	Killwaves pairs
end

// Calculates the radial distribution functions of a model, discretized into
// "pts" number of points.  If the function generates an "out of memory"
// or "too many points in the wave" error, reduce the parameter mem.
function PartialRDF(atoms, pts)
	wave atoms
	variable pts
	
	Duplicate/O atoms atoms_prdf
	SortByAtomicNum(atoms_prdf)
	variable natoms = DimSize(atoms_prdf, 0)
	
	// count the number of different types of atoms in the structure
	make/o/n=1 zlist
	make/o/n=(1, 2) zpos
	zpos[0][0] = 0
	zlist[0] = atoms_prdf[0][0]
	variable i, atom_types = 1
	for(i=1; i<natoms; i+=1)
		if( abs(atoms_prdf[i][0] - atoms_prdf[i-1][0]) > 0.5)
			//printf "%g\r", abs(atoms_prdf[i][0] - atoms_prdf[i-1][0])
			//printf "adding atoms type.  atoms_prdf[%d] = %d.  atoms_prdf[%d] = %d\r", i, atoms_prdf[i][0], i-1, atoms_prdf[i-1][0]
			InsertPoints atom_types, 1, zlist, zpos
			zlist[atom_types] = atoms_prdf[i][0]
			zpos[atom_types-1][1] = i-1
			zpos[atom_types][0] = i
			atom_types+=1
		endif
	endfor
	zpos[atom_types][1] = natoms-1
	
	// generate all the combinations of rdfs
	string prdf_name
	variable j
	for(i=0; i<atom_types; i+=1)
		Make/o/n=( (zpos[i][1] - zpos[i][0] + 1), 6) atoms_a
		atoms_a = atoms_prdf[p+zpos[i][0]][q]
		SetCell(atoms_a, GetAX(atoms), GetBY(atoms), GetCZ(atoms))
		RDFWork(atoms_a, pts)
		sprintf prdf_name, "%s_Z%d_Z%d", NameofWave(atoms), zlist[i], zlist[i]
		Duplicate/O prdf_w $prdf_name

		for(j=i+1; j<atom_types; j+=1)
			Make/o/n=( (zpos[j][1] - zpos[j][0] + 1), 6) atoms_b
			atoms_b = atoms_prdf[p+zpos[j][0]][q]
			SetCell(atoms_b, GetAX(atoms), GetBY(atoms), GetCZ(atoms))
			PartialRDFWork(atoms_a, atoms_b, pts)
			sprintf prdf_name, "%s_Z%d_Z%d", NameofWave(atoms), zlist[i], zlist[j]
			Duplicate/O prdf_w $prdf_name
			
		endfor

	endfor
	
	printf "There are %d atomic species, for %d partial RDFs.\r", atom_types, atom_types*(atom_types-1)/2 + atom_types
	
	Killwaves prdf_w, atoms_a, atoms_b, atoms_prdf, zlist, zpos
end
		
// 		
function PartialRDFWork(atoms_a, atoms_b, pts)
	wave atoms_a, atoms_b
	variable pts
	
	variable mem = 5e7
	
	variable ax, by, cz, natoms_a, natoms_b
	ax = GetAX(atoms_a)
	by = GetBY(atoms_a)
	cz = GetCZ(atoms_a)
	natoms_a = DimSize(atoms_a, 0)
	natoms_b = DimSize(atoms_b, 0)
	
	variable radius = max(ax, max(by, cz)) / 2
	Make/O/N=(pts) prdf_w = 0
	SetScale/I x 0, radius, "", prdf_w
	
	variable qstep,nq = 0
	do
		qstep = min( floor(mem / natoms_b), (natoms_b - nq) )
		Make/O/N=(natoms_a, qstep) pairs
		SetScale/p x, 0, 1, "", pairs
		SetScale/p y nq, 1, "", pairs
		//printf "nq = %d, pairs y scale from %d to %d.\r", nq, DimOffset(pairs, 1), DimOffset(pairs, 1) + Dimdelta(pairs, 1)*DimSize(pairs, 1)
		pairs = ( (atoms_a(x)[1] - atoms_b(y)[1])^2 + (atoms_a(x)[2] - atoms_b(y)[2])^2 + (atoms_a(x)[3] - atoms_b(y)[3])^2 )
		pairs = sqrt(pairs)
		Histogram/B=2/A pairs, prdf_w
		nq += qstep
	while(nq < natoms_b)
	
	prdf_w *= 2
	Killwaves pairs
	
end

function SortByAtomicNum(atoms)
	wave atoms
	
	variable natoms = DimSize(atoms, 0)
	make/o/n=(natoms) zatom, xx, yy, zz, occ, vib
	zatom = atoms[p][0]
	xx = atoms[p][1]
	yy = atoms[p][2]
	zz = atoms[p][3]
	occ = atoms[p][4]
	vib = atoms[p][5]
	
	Sort zatom, zatom, xx, yy, zz, occ, vib
	
	atoms[][0] = zatom[p]
	atoms[][1] = xx[p]
	atoms[][2] = yy[p]
	atoms[][3] = zz[p]
	atoms[][4] = occ[p]
	atoms[][5] = vib[p]
	
	Killwaves zatom, xx, yy, zz, occ, vib
	
end

function Rescale(xyz, frac)
	wave xyz
	variable frac
	
	Duplicate xyz xyz_rs
	Recenter(xyz_rs, 0, 0, 0)
	xyz_rs[][1] = frac*xyz[p][1]
	xyz_rs[][2] = frac*xyz[p][2]
	xyz_rs[][3] =frac*xyz[p][3]
	
	SetCell(xyz_rs, frac*GetAX(xyz), frac*GetBY(xyz), frac*GetCZ(xyz))
	
	Recenter(xyz_rs, 0.5, 0.5, 0.5)
	
	SizeXYZ(xyz_rs)
	
end


function Composition(xyz)
	wave xyz
	
	variable natom = DimSize(xyz, 0)
	make/o/n=(natom) zatom
	zatom = xyz[p][0]
	
	Sort zatom, zatom
	
	make/o/n=(1, 2) comp_count
	comp_count[0][0] = zatom[1]
	comp_count[0][1] = 1
	
	variable i
	for(i=1; i<natom; i+=1)
	
		if(comp_count[0][0] == zatom[i])
			comp_count[0][1] += 1
		else
			InsertPoints/M=0 0, 1, comp_count
			comp_count[0][0] = zatom[i]
			comp_count[0][1] = 1
		endif
		
	endfor
	
	printf "%d total atoms\r", natom
	for(i=0; i<DimSize(comp_count, 0); i+=1)
		printf "Z = %d, %d atoms, %g  %", comp_count[i][0], comp_count[i][1], 100*comp_count[i][1] / natom
		printf " composition.\r"
	endfor
	
	Killwaves zatom, comp_count
	
end
	
	
	
	
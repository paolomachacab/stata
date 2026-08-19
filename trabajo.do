/*
*===============================================================================
	DMCAE - 2026
	Economía Computacional
	Actividad en clase: Gestión de datos y propuesta de investigación empírica
*===============================================================================	
*/
*-------------------------------------------------------------------------------
* Pregunta de investigación: ¿Cómo se relaciona el nivel educativo del jefe o jefa de hogar con el ingreso per cápita del hogar en Bolivia (2023), y cómo difiere esa relación según el área de residencia, el sexo y el grupo de edad del jefe o jefa?


*¿Cómo se relaciona el nivel educativo con el sexo, la edad, la pertenencia a una nación o pueblo indígena y el área de residencia en Bolivia durante 2023?


 * 1. Preparación y exploración de los datos
	
	* Cargar stata
	clear all
	cd "D:\OneDrive\Documentos\Ivan\Cursos\2026\Diplomado en Métodos Cuantitativos\Modulo 1 - Economía Computacional\EH 2023"
	use "EH2023_Persona", clear
	
	*Variable de resultado
	yhogpc //ingreso del hogar percapita
	
	*Variable explicativa
	niv_ed_g // Nivel educativo general
	s01a_02  //sexo
	s01a_03  //edad
	depto	 // departamento	
	area	 // area
	s01a_05	 // realacion o parentesco
	
	
	* Cambiar nombres
	rename niv_ed_g nivel 
	rename s01a_02 sexo
	rename s01a_03 edad
	rename s01a_05 parentesco_jh
	
	
	* Valores faltantes
	codebook yhogpc nivel sexo edad parentesco_jh depto area
	
	keep if !missing(yhogpc)
	keep if !missing(nivel)
	codebook yhogpc nivel
	
	sum yhogpc
	replace yhogpc = . if yhogpc < 100
	
* 2. Construccion de variables
	
	gen jefe_hogar = parentesco_jh==1
	tab jefe_hogar_

	gen mujer = sexo==2
	tab mujer
	
	gen urbano = area==1
	tab urbano

	
	
	
	
	
	
	
	
	
*3. Análisis descriptivo
*4. Automatización y reproducibilidad
*5. Interpretación económica

	
	
* Explorar datos
	
	* Estadística descriptiva
	sum yhog
	sum edad
	tab area
	tab sexo
	tab edu
	
	* Valores faltantes
	misstable sum yhog
	codebook yhog
	misstable sum edad
	
	
	replace yhog = . if yhog < 100
	
		* 2. Construcción de variables
	gen mujer = sexo==2
	tab mujer
	
	gen urbano = area==1
	tab urbano
	
	recode edad (0/17=1) (18/29=2) (30/59=3) (60/99=4), generate(edad_g)
	label variable edad_g "Grupo de edad"
	label define edad_g_L 1 "1. Menor de edad" 2 "2. Joven" 3 "3. Adulto" 4 "4. Viejo"
	label values edad_g edad_g_L
	tab edad_g
	
	
	* 3. Análisis descriptivo
	sum yhog, detail
	histogram yhog, frecuency normal
	
	tabstat yhog, by(area) statistics(mean sd median min max) 
	
	tabstat yhog, by(sexo) statistics(mean sd median min max) 
	
	tabstat yhog, by(edad_g) statistics(mean sd median min max) 
	
	
	*4. Automatización y reproducibilidad
	global var_principales "area"
	
	
	
	
	
	
	
	*5. Interpretación económica.
	
	
	
	
	
	
	
	
	
	gen joven = edad > 12 & edad<18 
	tab joven
	
	
		gen rico = ylab >= 28000		// Tener cuidado con los missings
	tab rico
	tab ylab if rico == 1
	tab ylab if rico == 1, m
	replace rico = . if ylab == . 		// para corregir los missing porque es un numero infinitamente grande
	tab rico
	
	
	
	
	* Tabular variable // sirve ara variables cualitativas, no usar para cuantitativas (usar summarize)
	tab sexo
	tab edad 
	tab edad if edad < 18
	
	tab edad sexo if edad < 18
	tab edad sexo if edad < 18, row
	
	tab1 edad sexo edu // no corre porque no tenemos 3 dimensiones, para ello usamos tab1

* Transformación de datos
	
	* Generar variable 
	gen x_var = 0
	gen ln_ylab=ln(ylab)
	generate id = _n 		// identificador único (por observación), es un conteo desde 1 hasta n  

	* Reemplazar valor
	replace ylab = . if ylab < 50
	
	* Generar con funciones
	egen mean_ylab = mean(ylab) 
	
	gen diff_ylab = ylab - mean_ylab
	browse ylab mean_ylab diff_ylab 

	* Codificar variable
	recode edad (0/17=1) (18/29=2) (30/59=3) (60/99=4), generate(edad_g)
	label variable edad_g "Grupo de edad"
	label define edad_g_L 1 "1. Menor de edad" 2 "2. Joven" 3 "3. Adulto" 4 "4. Viejo"
	label values edad_g edad_g_L
	tab edad_g
	
	* Decodificar variable
	decode edad_g, generate(edad_g_str)  

	* String hacia numérica
	encode edad_g_str, generate(edad_g2) 
	tab1 edad_g edad_g2
	
	* Repetir comando por grupo
	bysort depto: egen mean_ylab_dep = mean(ylab)		//by en muchos de los cassos se necesitará bysort, by general el comando de acuerdo al orden de la variable, entonces necesitamos ordenar por eso usamos bysort.
	replace mean_ylab_dep = . if ylab==.		//donde habia missing mantenemos que sea missing

	bysort folio: egen mean_ylab_hog = mean(ylab)
	replace mean_ylab_hog = . if ylab==.

* Variables dicotómicas
	
	* Crear dicotómica
	gen joven = edad > 12 & edad<18 
	tab joven
	
	gen rico = ylab >= 28000		// Tener cuidado con los missings
	tab rico
	tab ylab if rico == 1
	tab ylab if rico == 1, m
	replace rico = . if ylab == . 		// para corregir los missing porque es un numero infinitamente grande
	tab rico

	tabulate depto, generate(depto_)
	summarize depto_*
	summarize i.depto		// Sin base

* Eliminar información

	* Seleccionar una muestra
	keep if !missing(ylab)		// mantenemos si no es missing el ingreso laboral
	keep if ylab != .
	drop if ylab == .
	drop if edad<18				//estas 4 lineas de codigo hacen completamente lo mismo

	* Borrar variables
	keep folio-edad *y*
	drop yprilab yseclab
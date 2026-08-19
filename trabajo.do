/*
===============================================================================
	DMCAE - 2026
	Economía Computacional
	Actividad en clase: Gestión de datos y propuesta de investigación empírica
===============================================================================	

-------------------------------------------------------------------------------
Pregunta de investigación: 

¿Cómo se relaciona el nivel educativo con el sexo, la edad, la pertenencia a una nación o pueblo indígena y el área de residencia en Bolivia durante 2023?
*/


*ACTIVIDAD

 * 1. Preparación y exploración de los datos
	
	* Cargar stata
	clear all
	cd "D:\OneDrive\Documentos\Ivan\Cursos\2026\Diplomado en Métodos Cuantitativos\Modulo 1 - Economía Computacional\EH 2023"
	
	use "EH2023_Persona", clear
	
	*Variable de resultado
	aestudio  //años de estudio
	
	*Variables explicativas
	s01a_02  // sexo
	s01a_03  // edad
	s01a_09	 // pertenencia a un pueblo indigena
	area	 // area
		
	* Cambiar nombres
	rename s01a_02 sexo
	rename s01a_03 edad
	rename s01a_09 pertenencia
	
	* Valores faltantes
	codebook aestudio sexo edad pertenencia area
	misstable summarize aestudio sexo edad pertenencia area
	
	keep if !missing(aestudio)
	
	
* 2. Construccion de variables
	
	* Creacion de las variables hombre y mujer a partir de la variable sexo

	gen hombre = sexo==1
	tab hombre
	
	gen mujer = sexo==2
	tab mujer

	* Construcción de la vaariable categorica para edad considerando rangos
	recode edad (0/17=1) (18/29=2) (30/59=3) (60/99=4), generate(edad_g)
	label variable edad_g "Grupo de edad"
	label define edad_g_L 1 "1. Menor de edad" 2 "2. Joven" 3 "3. Adulto" 4 "4. Viejo"
	label values edad_g edad_g_L
	tab edad_g
	
	* Creacion de las variables pertenece y no pertenece a partir de la variable pertenencia
	
	gen pertenece = pertenencia==1
	tab pertenece
	
	gen nopertenece = pertenencia==2
	tab nopertenece
	
	* Creacion de las variables urbano y rural a partir de la variable area
	
	gen urbano = area==1
	tab urbano
	
	gen rural = area==2
	tab rural
	
	
*3. Análisis descriptivo

	sum aestudio, detail
	tab sexo
	tab edad_g
	tab pertenencia
	tab area
	
	tab aestudio sexo
	tab aestudio edad_g
	tab aestudio pertenencia
	tab aestudio area
	
	tabstat aestudio, by(sexo) statistics(mean sd median min max)
	tabstat aestudio, by(edad_g) statistics(mean sd median min max)
	tabstat aestudio, by(pertenencia) statistics(mean sd median min max)
	tabstat aestudio, by(area) statistics(mean sd median min max)
	
	
*4. Automatización y reproducibilidad

	foreach var of varlist sexo edad_g pertenencia area {
	    tabstat aestudio, by (`var') statistics (mean sd median min max)
	}

*5. Interpretación económica

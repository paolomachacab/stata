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

	
	

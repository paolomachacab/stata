/*
===============================================================================
	DMCAE - 2026
	Economía Computacional
	Actividad en clase: Gestión de datos y propuesta de investigación empírica
===============================================================================	

-------------------------------------------------------------------------------
Pregunta de investigación: 

¿Existen brechas en los años de estudio de la población boliviana de 25 años
o más según sexo, área de residencia, pertenencia a un pueblo indígena
originario y departamento?
*/


*ACTIVIDAD

 * 1. Preparación y exploración de los datos
	
	* Cargar stata
	clear all
	cd "D:\OneDrive\Documentos\Ivan\Cursos\2026\Diplomado en Métodos Cuantitativos\Modulo 1 - Economía Computacional\EH 2023"
	
	use "EH2023_Persona", clear
    log using "Actividad_EH2023.log", text replace
	
	*Variable de resultado
	*aestudio  //años de estudio
	
	*Variables explicativas
	*s01a_02  // sexo
	*s01a_03  // edad
	*s01a_09  // pertenencia a un pueblo indigena
	*area	  // area
	*depto	  // departamento
		
	* Cambiar nombres
	rename s01a_02 sexo
	rename s01a_03 edad
	rename s01a_09 pertenencia
	
	* Etiquetas
	label variable sexo        "Sexo"
	label variable edad        "Edad"
	label variable area        "Área de residencia"
	label variable pertenencia "Pertenencia indígena"

	label define sexo_L 1 "1. Hombre" 2 "2. Mujer"
	label values sexo sexo_L

	label define area_L 1 "1. Urbana" 2 "2. Rural"
	label values area area_L

	* Formato con dos decimales para que las medias no salgan redondeadas
	format aestudio %9.2f

	* Valores faltantes
	codebook aestudio sexo edad pertenencia area depto
	tab pertenencia, m

	* Observaciones problemáticas
	sum edad if missing(aestudio)		// son niños de 0 a 3 años
	count if aestudio > edad & !missing(aestudio)

	* Muestra de análisis: 25 años o más, sin extranjeros ni educación alternativa
	keep if !missing(aestudio)
	keep if edad >= 25
	drop if pertenencia == 3
	drop if niv_ed_g == 4

	count
	
	
* 2. Construccion de variables
	
	* Variable derivada: 12 años = secundaria completa o más en Bolivia
	gen sec_comp = aestudio >= 12
	label variable sec_comp "Secundaria completa"
	label define sec_L 0 "0. No" 1 "1. Sí"
	label values sec_comp sec_L
	tab sec_comp

	* Validación contra el nivel educativo de la base
	tab niv_ed sec_comp, row

	* Dicotómicas
	gen mujer = sexo == 2
	gen pertenece = pertenencia == 1
	gen rural = area == 2
	tab1 mujer pertenece rural

	* Recodificación de edad en grupos
	recode edad (25/39 = 1) (40/59 = 2) (60/max = 3), generate(edad_g)
	label variable edad_g "Grupo de edad"
	label define edad_g_L 1 "1. 25-39" 2 "2. 40-59" 3 "3. 60 y más"
	label values edad_g edad_g_L
	tab edad_g
	
	
*3. Análisis descriptivo

	sum aestudio, detail

	tab sexo
	tab area
	tab pertenencia
	tab depto

	tab sexo, sum(aestudio)
	tab area, sum(aestudio)
	tab pertenencia, sum(aestudio)
	tab depto, sum(aestudio)

	* Tabulaciones cruzadas
	tab sexo sec_comp, row
	tab area sec_comp, row
	tab pertenencia sec_comp, row
	tab depto sec_comp, row
	
	
*4. Automatización y reproducibilidad

	global grupos sexo area pertenencia depto

	foreach var of varlist $grupos {
		tab `var', sum(aestudio)
		tab `var' sec_comp, row
	}

	* Brecha de género dentro de cada grupo de edad
	forvalues i = 1/3 {
		tab sexo sec_comp if edad_g == `i', row
	}

	* Brecha en años de estudio de cada dicotómica
	foreach d of varlist mujer rural pertenece {
		sum aestudio if `d' == 0
		scalar m0 = r(mean)
		sum aestudio if `d' == 1
		scalar m1 = r(mean)
		display "Brecha `d' = " m0 - m1
	}

	log close


/*
*5. Interpretación económica

	Pregunta: ¿Existen brechas en los años de estudio de la población boliviana
	de 25 años o más según sexo, área de residencia, pertenencia indígena y
	departamento? 

	Se espera menos años de estudio en mujeres, población rural
	e indígena, porque el acceso a la escuela estuvo limitado por la distancia,
	el costo de dejar de trabajar y cuidados.

	Resultados:
	1. Brecha urbano-rural: 11,6 años frente a 6,7 (4,9 años de diferencia).
	2. Brecha de género: 1,1 años. La brecha étnica es 3,2 años.

	Limitación: una dificultad fue decidir a quién excluir. Se elimino a 49
	extranjeros y a 56 casos de educación alternativa porque no encajaban en
	las categorías de la pregunta, pero ese criterio se eligio en base al tamaño
    que represntaban en la muestra
 */

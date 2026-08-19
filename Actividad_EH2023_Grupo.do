/*
*===============================================================================
	DMCAE - 2026
	Economía Computacional
	Actividad en clase: Gestión de datos y propuesta de investigación empírica
	Base: EH2023_Persona (INE Bolivia)
	Grupo: [nombres]
*===============================================================================

	PREGUNTA
	¿Existen brechas en los años de escolaridad de la población boliviana de
	25 años o más según sexo, área de residencia, pertenencia a un pueblo
	indígena originario y departamento?

	Resultado    : aestudio (años de estudio), sec_comp (secundaria completa)
	Explicativas : sexo, area, pertenencia, depto

*===============================================================================
*/

*-------------------------------------------------------------------------------
* 0. CONFIGURACIÓN
*-------------------------------------------------------------------------------

	* Limpia la memoria y borra las macros de corridas anteriores
	clear all
	macro drop _all

	* Cambia el directorio de trabajo
	cd "C:\Users\Paolo\Desktop\EH 2023"

	* Graba toda la salida en un archivo de texto
	log using "Actividad_EH2023_Grupo.log", text replace


*-------------------------------------------------------------------------------
* 1. PREPARACIÓN Y EXPLORACIÓN
*-------------------------------------------------------------------------------

	* Carga la base de personas
	use "EH2023_Persona", clear

	* Variables seleccionadas
	* aestudio  : años de estudio (0 a 23)
	* s01a_02   : sexo
	* s01a_03   : edad
	* s01a_09   : pertenencia a pueblo indígena originario
	* area      : área de residencia
	* depto     : departamento
	* niv_ed    : nivel educativo detallado (se usa para validar sec_comp)
	* niv_ed_g  : nivel educativo general

	* Muestra el tipo y la etiqueta de cada variable
	describe aestudio s01a_02 s01a_03 s01a_09 area depto niv_ed niv_ed_g

	* Muestra las categorías originales de la base. Se revisan antes de crear
	* etiquetas nuevas para no borrar información
	* help label
	label list labels2 labels9 labels1 labels0

	* Cambia los nombres por otros más fáciles de leer
	rename s01a_02 sexo
	rename s01a_03 edad
	rename s01a_09 pertenencia

	* Pone nombre descriptivo a cada variable
	label variable aestudio    "Años de estudio"
	label variable sexo        "Sexo"
	label variable edad        "Edad"
	label variable pertenencia "Pertenencia indígena"
	label variable area        "Área de residencia"

	* Pone nombre a cada categoría de sexo y área
	label define sexo_L 1 "1. Hombre" 2 "2. Mujer"
	label values sexo sexo_L

	label define area_L 1 "1. Urbana" 2 "2. Rural"
	label values area area_L

	* Muestra la distribución de pertenencia incluyendo los missing
	tab pertenencia, m

	* Convierte en missing la categoría 3 ("No soy boliviana o boliviano").
	* La pregunta no aplica a personas extranjeras
	replace pertenencia = . if pertenencia == 3

	label define pert_L 1 "1. Sí pertenece" 2 "2. No pertenece"
	label values pertenencia pert_L

	tab pertenencia, m

	* Resume las variables principales y detalla la de resultado
	codebook aestudio sexo pertenencia area
	sum aestudio, detail

	* Guarda en un global la lista de variables a revisar
	global revisar "aestudio sexo edad pertenencia area depto"

	* Cuenta los valores faltantes de cada variable sin repetir el comando
	* seis veces
	* help foreach
	foreach v of global revisar {
		display "=== Missing en `v' ==="
		count if missing(`v')
	}

	* Revisa quiénes son los casos sin años de estudio. Resultan ser niños de
	* 0 a 3 años, que aún no entran al sistema educativo
	sum edad if missing(aestudio), detail

	* Verifica que nadie tenga más años de estudio que años de edad
	count if aestudio > edad & !missing(aestudio)

	* Define la edad mínima de la muestra
	global edad_min = 25

	* Elimina los casos sin años de estudio
	drop if missing(aestudio)

	* Deja solo a personas de 25 años o más, edad en la que la trayectoria
	* educativa ya terminó
	drop if edad < $edad_min

	* Elimina a las personas extranjeras para que todas las tablas tengan el
	* mismo número de observaciones
	drop if missing(pertenencia)

	* Elimina la categoría "Otros" de nivel educativo (código 4). Son casos de
	* educación alternativa y de adultos que no tienen equivalencia en años
	tab niv_ed_g
	drop if niv_ed_g == 4

	* Cuenta la muestra final y la guarda en un escalar
	* help return
	count
	scalar N_muestra = r(N)
	display "Muestra de análisis = " N_muestra


*-------------------------------------------------------------------------------
* 2. CONSTRUCCIÓN DE VARIABLES
*-------------------------------------------------------------------------------

	* Crea la variable de secundaria completa a partir de años de estudio.
	* En Bolivia 12 años equivalen a primaria y secundaria completas, y es el
	* umbral de referencia en la literatura de economía de la educación
	gen sec_comp = aestudio >= 12
	replace sec_comp = . if aestudio == .
	label variable sec_comp "Secundaria completa o más"

	label define si_no_L 0 "0. No completó secundaria" 1 "1. Completó secundaria"
	label values sec_comp si_no_L

	tab sec_comp, m

	* Verifica que el umbral de 12 años coincida con la frontera entre
	* secundaria y superior que utiliza el INE
	tab niv_ed sec_comp, row

	* Crea las variables dicotómicas. El replace es necesario porque una
	* expresión lógica pone 0 donde hay missing
	label define dummy_L 0 "0. No" 1 "1. Sí"

	gen mujer = sexo == 2
	replace mujer = . if sexo == .
	label variable mujer "Mujer"
	label values mujer dummy_L

	gen pertenece = pertenencia == 1
	replace pertenece = . if pertenencia == .
	label variable pertenece "Pertenece a pueblo indígena"
	label values pertenece dummy_L

	gen rural = area == 2
	replace rural = . if area == .
	label variable rural "Área rural"
	label values rural dummy_L

	* Muestra las tres dicotómicas en una sola instrucción
	tab1 mujer pertenece rural, m

	* Agrupa la edad en tres tramos para describir la composición de la muestra
	* help recode
	recode edad (25/39 = 1) (40/59 = 2) (60/max = 3), generate(edad_g)
	label variable edad_g "Grupo de edad"

	label define edad_g_L 1 "1. 25-39" 2 "2. 40-59" 3 "3. 60 y más"
	label values edad_g edad_g_L

	tab edad_g

	* Calcula el promedio de años de estudio de cada departamento y lo asigna
	* a cada persona
	* help egen
	bysort depto: egen edu_dep = mean(aestudio)
	label variable edu_dep "Años de estudio promedio del departamento"

	* Mide cuánto se aleja cada persona del promedio de su departamento
	gen edu_rel = aestudio - edu_dep
	label variable edu_rel "Desvío respecto al promedio departamental"


*-------------------------------------------------------------------------------
* 3. ANÁLISIS DESCRIPTIVO
*-------------------------------------------------------------------------------

	* Describe la variable de resultado
	sum aestudio, detail

	* Guarda media, mediana y rango en escalares
	scalar edu_media = r(mean)
	scalar edu_p50   = r(p50)
	scalar edu_rango = r(max) - r(min)
	display "Media = " edu_media "  Mediana = " edu_p50 "  Rango = " edu_rango

	* Guarda en un global las cuatro variables explicativas
	global grupos "sexo area pertenencia depto"

	* Muestra la frecuencia de los cuatro grupos
	tab1 $grupos

	* Compara los años de estudio dentro de cada grupo. Se usa tab con la
	* opción sum porque muestra el nombre completo de cada categoría
	* help tabulate oneway
	foreach g of global grupos {
		display "=== AÑOS DE ESTUDIO SEGÚN `g' ==="
		tab `g', sum(aestudio)
	}

	* Cruza secundaria completa con cada grupo. Se usa sec_comp y no aestudio
	* porque esta última tiene 24 valores y la tabla sería ilegible.
	* La opción row muestra el porcentaje dentro de cada fila
	foreach g of global grupos {
		display "=== Secundaria completa según `g' (% fila) ==="
		tab `g' sec_comp, row
	}

	* Calcula la brecha de años de estudio de cada dicotómica usando los
	* resultados que sum deja guardados en r()
	foreach d in mujer rural pertenece {
		sum aestudio if `d' == 0
		scalar m0 = r(mean)
		sum aestudio if `d' == 1
		scalar m1 = r(mean)
		scalar brecha = m0 - m1
		display "Brecha `d': " %5.2f m0 " vs " %5.2f m1 " = " %5.2f brecha
	}

	* Repite la tabla de género por separado en área urbana y rural
	* help forvalues
	forvalues i = 1/2 {
		display "=== Área `i' ==="
		tab sexo sec_comp if area == `i', row
	}

	* Muestra el porcentaje con secundaria completa en cada departamento
	tab depto sec_comp, row


*-------------------------------------------------------------------------------
* 4. AUTOMATIZACIÓN Y REPRODUCIBILIDAD
*-------------------------------------------------------------------------------
/*
	global edad_min  : edad mínima de la muestra
	global revisar   : lista de variables para revisar missing
	global grupos    : lista de variables explicativas
	foreach          : missing, comparaciones por grupo, tablas cruzadas y brechas
	forvalues        : recorre las áreas urbana y rural
	scalar y r()     : guardan medias, brechas y porcentajes
	log using        : graba toda la salida
*/


*-------------------------------------------------------------------------------
* 5. INTERPRETACIÓN ECONÓMICA
*-------------------------------------------------------------------------------
/*
	PREGUNTA
	¿Existen brechas en los años de escolaridad de la población boliviana de
	25 años o más según sexo, área de residencia, pertenencia a un pueblo
	indígena originario y departamento?

	RELACIÓN ESPERADA
	Esperamos menos años de estudio en mujeres, población rural y población
	indígena. La educación es una inversión en capital humano cuyo acceso
	estuvo limitado por la distancia a la escuela, el costo de dejar de
	trabajar y normas de género que priorizaron la educación de los varones.

	RESULTADOS DESCRIPTIVOS
	1. La brecha urbano-rural es la mayor de todas: 11,62 años de estudio en
	   el área urbana frente a 6,68 en la rural, casi 5 años de diferencia.
	   En términos de secundaria completa, 65,6% en lo urbano contra 26,1%
	   en lo rural.
	2. La brecha de género es menor (1,14 años) pero se combina con la rural:
	   en el área urbana 61,9% de las mujeres completó secundaria, mientras
	   que en el área rural solo 23,6%.

	NOTA SOBRE LA VARIABLE CONSTRUIDA
	El umbral de 12 años reproduce la clasificación oficial del INE: la
	variable construida coincide con el nivel educativo reportado en 22.674
	de 22.683 casos (99,96%). Las 9 discordancias son personas con educación
	superior y menos de 12 años, que accedieron a institutos técnicos por vías
	alternativas al bachillerato.

	LIMITACIÓN
	Los casos sin años de estudio son niños de 0 a 3 años, por lo que no
	afectan a la población analizada; se excluyó además a 49 personas
	extranjeras y 56 casos de educación alternativa. La limitación principal
	es que la base tiene factor de expansión y diseño muestral complejo: los
	resultados sin ponderar describen la muestra y no a la población nacional.
	El tamaño muestral por departamento es desigual (de 1.021 casos en Pando a
	5.448 en La Paz), por lo que las comparaciones departamentales
	desagregadas por área deben leerse con cautela. Además, el área de
	residencia es endógena porque quienes estudian más tienden a migrar a la
	ciudad.
*/

	log close

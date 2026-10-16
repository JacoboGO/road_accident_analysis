SELECT * FROM road_accident

--Query 01 - Total de víctimas

WITH by_casualties AS (
	SELECT 
		SUM(number_of_casualties) Casualties_total,
		SUM(CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN number_of_casualties ELSE 0 END) PY_Casualties_2021,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
	FROM road_accident
)

SELECT
Casualties_total,
PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021_global,
CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022_global,
CAST(100.0 * (CY_Casualties_2022 - PY_Casualties_2021) / NULLIF(PY_Casualties_2021, 0) AS DECIMAL(5,2)) pct_YoY_Casualties
FROM by_casualties
ORDER BY Casualties_total DESC

--Query 02 - Total de reportes

WITH by_index AS (
	SELECT 
		COUNT(DISTINCT accident_index) Accidents_Total,
		COUNT(DISTINCT CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN accident_index END) PY_Accidents_2021,
		
		COUNT(DISTINCT CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN accident_index END) CY_Accidents_2022
	FROM road_accident
)
SELECT
Accidents_Total,
PY_Accidents_2021,
CY_Accidents_2022,
CAST(100.0 * (CY_Accidents_2022 - PY_Accidents_2021) / NULLIF(PY_Accidents_2021, 0) AS DECIMAL(5,2)) pct_YoY_accidents
FROM by_index
ORDER BY Accidents_Total DESC

--Query 03 - Total de víctimas por severidad del accidente

WITH severity AS (
	SELECT 
		accident_severity,
		SUM(number_of_casualties) Casualties_total,
		SUM(CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN number_of_casualties ELSE 0 END) PY_Casualties_2021,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
	FROM road_accident
	GROUP BY accident_severity
)

SELECT
accident_severity,
casualties_total,
CAST(100.0 * Casualties_total / SUM(Casualties_total) OVER () AS DECIMAL(5,2)) pct_casualties_total,
PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(PY_Casualties_2021) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021_global,
CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(CY_Casualties_2022) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022_global,
CAST(100.0 * (CY_Casualties_2022 - PY_Casualties_2021) / NULLIF(PY_Casualties_2021, 0) AS DECIMAL(5,2)) pct_YoY_Casualties
FROM severity
ORDER BY Casualties_total DESC

--Query 04 - Total de víctimas por tipo de vehículo

WITH vehicle AS (
	SELECT 
		CASE
			WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
			WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Car'
			WHEN vehicle_type IN ('Motorcycle 125cc and under', 'Motorcycle 50cc and under', 'Motorcycle over 125cc and up to 500cc', 'Motorcycle over 500cc', 'Pedal cycle') THEN 'Bike'
			WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 'Minibus (8 - 16 passenger seats)') THEN 'Bus'
			WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over', 'Goods over 3.5t. and under 7.5t','Van / Goods 3.5 tonnes mgw or under') THEN 'Van'
			ELSE 'Other'
		END vehicle_group,
		SUM(number_of_casualties) Casualties_total,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
	FROM road_accident
	GROUP BY
		CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
		WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Car'
		WHEN vehicle_type IN ('Motorcycle 125cc and under', 'Motorcycle 50cc and under', 'Motorcycle over 125cc and up to 500cc', 'Motorcycle over 500cc', 'Pedal cycle') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 'Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods 7.5 tonnes mgw and over', 'Goods over 3.5t. and under 7.5t','Van / Goods 3.5 tonnes mgw or under') THEN 'Van'
		ELSE 'Other'
	END
)
SELECT
vehicle_group,
Casualties_total,
CY_Casualties_2022
FROM vehicle
ORDER BY CY_Casualties_2022 DESC

--Query 05 - Total de accidentes por mes 

WITH by_month AS (
	SELECT 
		MONTH(accident_date) month_num,
		DATENAME(MONTH, accident_date) month_name, 
		SUM(CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN number_of_casualties ELSE 0 END) PY_Casualties_2021,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
		FROM road_accident
		WHERE accident_date >= '20210101'
		AND accident_date < '20230101'
		GROUP BY MONTH(accident_date), DATENAME(MONTH, accident_date)
)

SELECT
month_name,
PY_Casualties_2021,
CY_Casualties_2022,
CAST(100.0 * (CY_Casualties_2022 - PY_Casualties_2021)  / NULLIF(PY_Casualties_2021, 0) AS DECIMAL(5,2)) PCT_YoY_Casualties
FROM by_month
ORDER BY month_num

--Query 06 - Total de víctimas por tipo de camino

WITH by_road AS (
	SELECT 
		road_type,
		SUM(number_of_casualties) Casualties_total,
		SUM(CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN number_of_casualties ELSE 0 END) PY_Casualties_2021,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
	FROM road_accident
	GROUP BY road_type
)

SELECT
road_type,
Casualties_total,
CAST(100.0 * Casualties_total / SUM(Casualties_total) OVER () AS DECIMAL(5,2)) pct_casualties_total,
PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(PY_Casualties_2021) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021_global,
CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(CY_Casualties_2022) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022_global,
CAST(100.0 * (CY_Casualties_2022 - PY_Casualties_2021) / NULLIF(PY_Casualties_2021, 0) AS DECIMAL(5,2)) pct_YoY_Casualties
FROM by_road
ORDER BY CY_Casualties_2022 DESC

--Query 07 - Total de víctimas por zona

WITH by_zone AS (
	SELECT 
		urban_or_rural_area,
		SUM(number_of_casualties) Casualties_total,
		SUM(CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN number_of_casualties ELSE 0 END) PY_Casualties_2021,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
	FROM road_accident
	GROUP BY urban_or_rural_area
)

SELECT
urban_or_rural_area,
Casualties_total,
CAST(100.0 * Casualties_total / SUM(Casualties_total) OVER () AS DECIMAL(5,2)) pct_casualties_total,
PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(PY_Casualties_2021) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021_global,
CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(CY_Casualties_2022) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022_global,
CAST(100.0 * (CY_Casualties_2022 - PY_Casualties_2021) / NULLIF(PY_Casualties_2021, 0) AS DECIMAL(5,2)) pct_YoY_Casualties
FROM by_zone
ORDER BY pct_CY_Casualties_2022 DESC

--Query 08 - Total de víctimas por condición de luz

WITH by_light_conditions AS (
	SELECT 
		CASE
			WHEN light_conditions IN ('Daylight') THEN 'Day'
			WHEN light_conditions IN ('Darkness - lighting unknown', 'Darkness - lights lit', 'Darkness - lights unlit', 'Darkness - no lighting') THEN 'Night'
			END light_conditions,
		SUM(number_of_casualties) Casualties_total,
		SUM(CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN number_of_casualties ELSE 0 END) PY_Casualties_2021,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
	FROM road_accident
	GROUP BY CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lighting unknown', 'Darkness - lights lit', 'Darkness - lights unlit', 'Darkness - no lighting') THEN 'Night'
		END
)

SELECT
light_conditions,
Casualties_total,
CAST(100.0 * Casualties_total / SUM(Casualties_total) OVER () AS DECIMAL(5,2)) pct_casualties_total,
PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(PY_Casualties_2021) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021_global,
CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(CY_Casualties_2022) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022_global,
CAST(100.0 * (CY_Casualties_2022 - PY_Casualties_2021) / NULLIF(PY_Casualties_2021, 0) AS DECIMAL(5,2)) pct_YoY_Casualties
FROM by_light_conditions
ORDER BY Casualties_total DESC

--Query 09 - Total de víctimas por condición del camino

WITH by_road_surface AS (
	SELECT 
		CASE
			WHEN road_surface_conditions IN ('Dry') THEN 'Dry'
			WHEN road_surface_conditions IN ('Flood over 3cm. deep', 'Wet or damp') THEN 'Wet'
			WHEN road_surface_conditions IN ('Frost or ice', 'Snow') THEN 'Snow/Ice'
			END surface_road,
		SUM(number_of_casualties) Casualties_total,
		SUM(CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN number_of_casualties ELSE 0 END) PY_Casualties_2021,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
	FROM road_accident
	GROUP BY CASE
			WHEN road_surface_conditions IN ('Dry') THEN 'Dry'
			WHEN road_surface_conditions IN ('Flood over 3cm. deep', 'Wet or damp') THEN 'Wet'
			WHEN road_surface_conditions IN ('Frost or ice', 'Snow') THEN 'Snow/Ice'
			END
)

SELECT
surface_road,
casualties_total,
CAST(100.0 * Casualties_total / SUM(Casualties_total) OVER () AS DECIMAL(5,2)) pct_casualties_total,
PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(PY_Casualties_2021) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021_global,
CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(CY_Casualties_2022) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022_global,
CAST(100.0 * (CY_Casualties_2022 - PY_Casualties_2021) / NULLIF(PY_Casualties_2021, 0) AS DECIMAL(5,2)) pct_YoY_Casualties
FROM by_road_surface
ORDER BY Casualties_total DESC

--Query 10 - Top 10 de ciudades con mayor número de victimas

WITH by_local_authority AS (
	SELECT 
		local_authority,
		SUM(number_of_casualties) Casualties_total,
		SUM(CASE WHEN accident_date >= '20210101'
				AND accident_date < '20220101'
				THEN number_of_casualties ELSE 0 END) PY_Casualties_2021,
		SUM(CASE WHEN accident_date >= '20220101'
				AND accident_date < '20230101'
				THEN number_of_casualties ELSE 0 END) CY_Casualties_2022
	FROM road_accident
	GROUP BY local_authority
)

SELECT TOP 10
local_authority,
Casualties_total,
CAST(100.0 * Casualties_total / SUM(Casualties_total) OVER () AS DECIMAL(5,2)) pct_casualties_total,
PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(PY_Casualties_2021) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021,
CAST(100.0 * PY_Casualties_2021 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_PY_Casualties_2021_global,
CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(CY_Casualties_2022) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022,
CAST(100.0 * CY_Casualties_2022 / NULLIF(SUM(Casualties_total) OVER (), 0) AS DECIMAL(5,2)) pct_CY_Casualties_2022_global,
CAST(100.0 * (CY_Casualties_2022 - PY_Casualties_2021) / NULLIF(PY_Casualties_2021, 0) AS DECIMAL(5,2)) pct_YoY_Casualties
FROM by_local_authority
ORDER BY CY_Casualties_2022 DESC
--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------





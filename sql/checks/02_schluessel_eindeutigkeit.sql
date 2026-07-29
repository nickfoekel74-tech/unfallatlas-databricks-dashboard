-- =============================================================
-- CHECK 02 -- Eindeutigkeit des Primaerschluessels
-- Nach 02_silver.sql ausfuehren.
--
-- Der wichtigste Check des Projekts. Er hat zwei Fehler
-- aufgedeckt, die beide ohne Fehlermeldung aufgetreten sind:
--
--   1. OBJECTID beginnt je Jahrgang neu bei 1
--      -> 1.812.256 Zeilen bei nur 269.048 verschiedenen IDs
--
--   2. CONCAT_WS ueberspringt NULL-Argumente stillschweigend.
--      Da 2025 weder OBJECTID noch OID_ fuehrt, erhielten alle
--      273.007 Zeilen dieses Jahrgangs den Schluessel '2025'
--      -> 1.539.250 statt 1.812.256 eindeutige IDs
--
-- Erwartung: beide Werte identisch.
-- =============================================================

SELECT
  COUNT(*)                  AS zeilen,
  COUNT(DISTINCT unfall_id) AS ids
FROM workspace.default.unfaelle_silver;


-- Bei Abweichung: eingrenzen, welcher Jahrgang betroffen ist
SELECT
  jahr,
  COUNT(*)                  AS zeilen,
  COUNT(DISTINCT unfall_id) AS ids
FROM workspace.default.unfaelle_silver
GROUP BY jahr
ORDER BY jahr;

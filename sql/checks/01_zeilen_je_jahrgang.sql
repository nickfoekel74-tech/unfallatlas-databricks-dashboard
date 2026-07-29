-- =============================================================
-- CHECK 01 -- Vollstaendigkeit der Ingestion
-- Nach 01_bronze_load.sql ausfuehren.
--
-- Erwartung: 7 Zeilen (2019-2025), je rund 240.000-275.000.
-- 2020 und 2021 liegen sichtbar niedriger -- das ist der
-- Corona-Effekt, kein Ladefehler.
-- Fehlt ein Jahr, wurde eine Datei nicht ins Volume hochgeladen.
-- Erscheint eine Zeile mit UJAHR = NULL, ist eine Kopfzeile in
-- die Daten geraten.
-- =============================================================

SELECT UJAHR, COUNT(*) AS zeilen
FROM workspace.default.unfaelle_bronze
GROUP BY UJAHR
ORDER BY UJAHR;


-- Schema-Drift sichtbar machen:
-- COUNT(spalte) zaehlt nur Nicht-NULL-Werte. Eine 0 bedeutet,
-- dass die Spalte im jeweiligen Jahrgang nicht existiert.
-- Erwartung: STRZUSTAND nur 2019-2020 gefuellt,
--            IstStrassenzustand ab 2021.
SELECT
  UJAHR,
  COUNT(*)                  AS zeilen,
  COUNT(STRZUSTAND)         AS strzustand,
  COUNT(IstStrassenzustand) AS iststrassenzustand,
  COUNT(OBJECTID)           AS objectid,
  COUNT(OID_)               AS oid_,
  COUNT(_rescued_data)      AS rescued
FROM workspace.default.unfaelle_bronze
GROUP BY UJAHR
ORDER BY UJAHR;
-- rescued muss ueberall 0 sein. Andernfalls gab es Parsing-
-- Probleme und Werte sind in die Auffangspalte gerutscht.

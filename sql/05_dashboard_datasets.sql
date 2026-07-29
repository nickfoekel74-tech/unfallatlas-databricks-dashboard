-- =============================================================
-- 05_dashboard_datasets.sql
-- Vorab aggregierte Views als Grundlage der Dashboard-Datasets
--
-- Im Dashboard werden diese drei Views als Datasets eingebunden.
-- Der Jahres- und Bundesland-Filter wird an das Feld jahr bzw.
-- bundesland ALLER drei Datasets gebunden -- sonst filtert er
-- nur einen Teil der Kacheln.
--
-- Grundregel fuer alle Kennzahlen:
-- Die Datasets liefern ausschliesslich Zaehler und Nenner, nie
-- fertige Quoten. Eine vorberechnete Prozentspalte wuerde beim
-- Aggregieren aufsummiert statt neu berechnet. Quoten entstehen
-- erst auf Kachelebene als Custom Calculation:
--     100.0 * SUM(toedliche) / SUM(unfaelle)
-- =============================================================

---------------------------------------------------------------
-- Dataset 1: Kennzahlen, Zeitverlauf, Heatmap
-- Basis ist Silver, weil hier keine Verkehrsmittel-Dimension
-- vorkommt und eine Zeile genau einem Unfall entspricht.
---------------------------------------------------------------
CREATE OR REPLACE VIEW workspace.default.ds_unfaelle AS
SELECT
  jahr,
  monat,
  wochentag,
  wochentag_nr,
  stunde,
  bundesland,
  COUNT(*)               AS unfaelle,
  COUNT_IF(ist_toedlich) AS toedliche
FROM workspace.default.unfaelle_silver
GROUP BY ALL;

---------------------------------------------------------------
-- Dataset 2: Aufschluesselungen nach Verkehrsmittel
-- Basis ist die Beteiligten-Tabelle. COUNT(*) zaehlt hier
-- Beteiligungen, nicht Unfaelle.
---------------------------------------------------------------
CREATE OR REPLACE VIEW workspace.default.ds_verkehrsmittel AS
SELECT
  jahr,
  bundesland,
  verkehrsmittel,
  unfalltyp,
  COUNT(*)               AS beteiligungen,
  COUNT_IF(ist_toedlich) AS toedliche
FROM workspace.default.unfaelle_beteiligte
GROUP BY ALL;

---------------------------------------------------------------
-- Dataset 3: Karte
-- Rasterung auf eine Nachkommastelle (~11 km) reduziert 1,8 Mio.
-- Punkte auf einige tausend Zellen. Ungerasterte Rohpunkte
-- bringen jede Kartenvisualisierung zum Erliegen.
-- Das WHERE filtert Koordinaten ausserhalb Deutschlands,
-- insbesondere 0/0.
---------------------------------------------------------------
CREATE OR REPLACE VIEW workspace.default.ds_karte AS
SELECT
  jahr,
  bundesland,
  ROUND(lat, 1)          AS lat,
  ROUND(lon, 1)          AS lon,
  COUNT(*)               AS unfaelle,
  COUNT_IF(ist_toedlich) AS toedliche
FROM workspace.default.unfaelle_silver
WHERE lat BETWEEN 47 AND 56
  AND lon BETWEEN  5 AND 16
GROUP BY ALL
HAVING COUNT(*) >= 5;

---------------------------------------------------------------
-- Dataset 4: Bundeslandvergleich, einwohnernormiert
--
-- MAX(einwohner) statt SUM: Die Einwohnerzahl wiederholt sich
-- ueber alle Gruppierungszeilen und wuerde sich sonst
-- vervielfachen.
--
-- Custom Calculation auf Kachelebene:
--   100000.0 * SUM(unfaelle) / MAX(einwohner) / COUNT(DISTINCT jahr)
-- Die Division durch die Jahresanzahl haelt die Kennzahl stabil,
-- wenn der Nutzer den Zeitraum einschraenkt.
---------------------------------------------------------------
CREATE OR REPLACE VIEW workspace.default.ds_bundesland AS
SELECT
  s.jahr,
  s.bundesland,
  e.einwohner,
  COUNT(*)                 AS unfaelle,
  COUNT_IF(s.ist_toedlich) AS toedliche
FROM workspace.default.unfaelle_silver s
JOIN workspace.default.bundesland_einwohner e
  ON s.bundesland = e.bundesland
GROUP BY ALL;

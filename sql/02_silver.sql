-- =============================================================
-- 02_silver.sql
-- Bereinigte Faktentabelle: eine Zeile je Unfall
--
-- Aufgaben dieses Layers:
--   1. Eindeutigen Schluessel bilden
--   2. Numerische Codes in Klartext uebersetzen
--   3. Koordinaten von String (Dezimalkomma) nach DOUBLE
--   4. Abgeleitete Dimensionen ergaenzen (Tageszeit, Wochenende)
--
-- Zur Schluesselbildung:
-- OBJECTID beginnt in jedem Jahrgang erneut bei 1 und ist damit
-- ueber alle Jahrgaenge hinweg nicht eindeutig. Ausserdem heisst
-- die Spalte je nach Jahrgang OBJECTID oder OID_, und im Jahrgang
-- 2025 fehlen beide.
--
-- ACHTUNG CONCAT_WS: Die Funktion ueberspringt NULL-Argumente
-- stillschweigend, statt NULL zurueckzugeben. Ohne den COALESCE-
-- Fallback kollabiert der Jahrgang 2025 auf den einzigen
-- Schluesselwert '2025' -- ohne Fehlermeldung. Der Check in
-- checks/02_schluessel_eindeutigkeit.sql deckt das auf.
--
-- Codebedeutungen laut DSB_Unfallatlas.pdf der Quelle.
-- =============================================================

CREATE OR REPLACE TABLE workspace.default.unfaelle_silver AS
SELECT
  CONCAT_WS('-',
    CAST(UJAHR AS STRING),
    COALESCE(
      CAST(COALESCE(OBJECTID, OID_) AS STRING),
      CONCAT('gen', CAST(monotonically_increasing_id() AS STRING))
    )
  )                                       AS unfall_id,

  ---------------------------------------------------------------
  -- Zeit
  ---------------------------------------------------------------
  UJAHR                                   AS jahr,
  UMONAT                                  AS monat,
  USTUNDE                                 AS stunde,
  CASE UWOCHENTAG
    WHEN 1 THEN 'Sonntag'    WHEN 2 THEN 'Montag'
    WHEN 3 THEN 'Dienstag'   WHEN 4 THEN 'Mittwoch'
    WHEN 5 THEN 'Donnerstag' WHEN 6 THEN 'Freitag'
    WHEN 7 THEN 'Samstag'
  END                                     AS wochentag,
  UWOCHENTAG                              AS wochentag_nr,
  UWOCHENTAG IN (1, 7)                    AS ist_wochenende,
  CASE
    WHEN USTUNDE BETWEEN  6 AND  9 THEN 'Morgen (6-9)'
    WHEN USTUNDE BETWEEN 10 AND 15 THEN 'Tag (10-15)'
    WHEN USTUNDE BETWEEN 16 AND 19 THEN 'Feierabend (16-19)'
    WHEN USTUNDE BETWEEN 20 AND 23 THEN 'Abend (20-23)'
    ELSE 'Nacht (0-5)'
  END                                     AS tageszeit,

  ---------------------------------------------------------------
  -- Ort
  ---------------------------------------------------------------
  CASE ULAND
    WHEN  1 THEN 'Schleswig-Holstein'     WHEN  2 THEN 'Hamburg'
    WHEN  3 THEN 'Niedersachsen'          WHEN  4 THEN 'Bremen'
    WHEN  5 THEN 'Nordrhein-Westfalen'    WHEN  6 THEN 'Hessen'
    WHEN  7 THEN 'Rheinland-Pfalz'        WHEN  8 THEN 'Baden-Württemberg'
    WHEN  9 THEN 'Bayern'                 WHEN 10 THEN 'Saarland'
    WHEN 11 THEN 'Berlin'                 WHEN 12 THEN 'Brandenburg'
    WHEN 13 THEN 'Mecklenburg-Vorpommern' WHEN 14 THEN 'Sachsen'
    WHEN 15 THEN 'Sachsen-Anhalt'         WHEN 16 THEN 'Thüringen'
  END                                     AS bundesland,

  -- Amtlicher Gemeindeschluessel des Kreises. LPAD stellt die
  -- fuehrenden Nullen wieder her, die beim Einlesen als INT
  -- verlorengegangen sind.
  LPAD(ULAND, 2, '0')
    || CAST(UREGBEZ AS STRING)
    || LPAD(UKREIS, 2, '0')               AS kreis_ags,

  -- Dezimalkomma -> Punkt, dann Cast
  CAST(REPLACE(XGCSWGS84, ',', '.') AS DOUBLE) AS lon,
  CAST(REPLACE(YGCSWGS84, ',', '.') AS DOUBLE) AS lat,

  ---------------------------------------------------------------
  -- Schwere
  -- Achtung: Die Kategorie bezeichnet die schwerste Folge des
  -- Unfalls, nicht die Anzahl der Verletzten.
  ---------------------------------------------------------------
  CASE UKATEGORIE
    WHEN 1 THEN 'Getötete'
    WHEN 2 THEN 'Schwerverletzte'
    WHEN 3 THEN 'Leichtverletzte'
  END                                     AS unfallkategorie,
  UKATEGORIE = 1                          AS ist_toedlich,

  ---------------------------------------------------------------
  -- Art und Typ
  ---------------------------------------------------------------
  CASE UTYP1
    WHEN 1 THEN 'Fahrunfall'        WHEN 2 THEN 'Abbiegeunfall'
    WHEN 3 THEN 'Einbiegen/Kreuzen' WHEN 4 THEN 'Überschreiten'
    WHEN 5 THEN 'Ruhender Verkehr'  WHEN 6 THEN 'Längsverkehr'
    WHEN 7 THEN 'Sonstiger Unfall'
  END                                     AS unfalltyp,
  UART                                    AS unfallart_code,

  ---------------------------------------------------------------
  -- Umstaende
  -- STRZUSTAND (2019-2020) und IstStrassenzustand (ab 2021) sind
  -- dieselbe Information unter unterschiedlichem Spaltennamen.
  -- Trotz des Praefix "Ist" ist das kein Boolean, sondern der
  -- Code 0/1/2.
  ---------------------------------------------------------------
  CASE ULICHTVERH
    WHEN 0 THEN 'Tageslicht'
    WHEN 1 THEN 'Dämmerung'
    WHEN 2 THEN 'Dunkelheit'
  END                                     AS lichtverhaeltnisse,
  CASE COALESCE(STRZUSTAND, IstStrassenzustand)
    WHEN 0 THEN 'trocken'
    WHEN 1 THEN 'nass/feucht'
    WHEN 2 THEN 'winterglatt'
  END                                     AS strassenzustand,

  ---------------------------------------------------------------
  -- Beteiligte Verkehrsmittel
  -- Mehrfachnennung moeglich: ein Unfall zwischen PKW und Rad
  -- setzt zwei Flags. Aufloesung in 03_beteiligte.sql.
  ---------------------------------------------------------------
  CAST(IstRad      AS BOOLEAN)            AS ist_rad,
  CAST(IstPKW      AS BOOLEAN)            AS ist_pkw,
  CAST(IstFuss     AS BOOLEAN)            AS ist_fuss,
  CAST(IstKrad     AS BOOLEAN)            AS ist_krad,
  CAST(IstGkfz     AS BOOLEAN)            AS ist_lkw,
  CAST(IstSonstige AS BOOLEAN)            AS ist_sonstige,

  quelldatei
FROM workspace.default.unfaelle_bronze;

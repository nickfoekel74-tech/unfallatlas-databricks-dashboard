-- =============================================================
-- 01_bronze_load.sql
-- Ingestion aller Jahrgaenge in die Bronze-Tabelle
--
-- Voraussetzung: Die entpackten CSV-Dateien (2019-2025) liegen
-- flach in einem Unity Catalog Volume. Nur Datendateien hochladen,
-- keine schema.ini (wuerde sonst als CSV geparst werden).
--
-- Besonderheiten der Quelldaten:
--   sep      ';'           deutsche Behoerden-CSV
--   encoding 'ISO-8859-1'  laut schema.ini der Quelle (ANSI)
--   Dezimaltrennzeichen ist ein Komma -> Koordinaten kommen als
--   String an und werden erst im Silver-Layer gecastet
--
-- mergeSchema bildet die Vereinigungsmenge aller Spalten ueber die
-- Jahrgaenge. Notwendig, weil sich Spaltennamen zwischen den
-- Jahrgaengen unterscheiden (siehe 02_silver.sql).
-- =============================================================

CREATE OR REPLACE TABLE workspace.default.unfaelle_bronze AS
SELECT
  *,
  _metadata.file_name AS quelldatei
FROM read_files(
  '/Volumes/workspace/default/unfalldaten_deutschland/',
  format         => 'csv',
  sep            => ';',
  header         => true,
  encoding       => 'ISO-8859-1',
  mergeSchema    => true,
  pathGlobFilter => '*.csv'
);

-- =============================================================
-- CHECK 03 -- Vollstaendigkeit der Code-Uebersetzung
-- Nach 02_silver.sql ausfuehren.
--
-- Jedes CASE ohne ELSE liefert NULL, wenn ein Code auftritt, den
-- die Uebersetzung nicht abdeckt. Das faellt im Dashboard sonst
-- erst als leere Kategorie auf.
--
-- Erwartung: alle Spalten ausser gesamt sind 0.
-- =============================================================

SELECT
  COUNT(*)                                                 AS gesamt,
  SUM(CASE WHEN unfallkategorie    IS NULL THEN 1 ELSE 0 END) AS null_kategorie,
  SUM(CASE WHEN unfalltyp          IS NULL THEN 1 ELSE 0 END) AS null_typ,
  SUM(CASE WHEN bundesland         IS NULL THEN 1 ELSE 0 END) AS null_land,
  SUM(CASE WHEN wochentag          IS NULL THEN 1 ELSE 0 END) AS null_wochentag,
  SUM(CASE WHEN lichtverhaeltnisse IS NULL THEN 1 ELSE 0 END) AS null_licht,
  SUM(CASE WHEN strassenzustand    IS NULL THEN 1 ELSE 0 END) AS null_strasse,
  SUM(CASE WHEN lat IS NULL OR lon IS NULL THEN 1 ELSE 0 END) AS null_koordinate
FROM workspace.default.unfaelle_silver;


-- Bei Treffern: die nicht abgedeckten Rohcodes ermitteln,
-- Beispiel fuer den Unfalltyp
-- SELECT UTYP1, COUNT(*) FROM workspace.default.unfaelle_bronze
-- GROUP BY UTYP1 ORDER BY UTYP1;

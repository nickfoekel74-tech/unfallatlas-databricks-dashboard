-- =============================================================
-- CHECK 04 -- Konsistenz zwischen Silver und Beteiligten-Tabelle
-- Nach 03_beteiligte.sql ausfuehren.
--
-- explode() in Kombination mit WHERE beteiligt entfernt still-
-- schweigend jeden Unfall, bei dem kein einziges Flag gesetzt
-- ist. Ohne diesen Check faellt das nicht auf.
--
-- Erwartung:
--   ids_beteiligte + ohne_flag = zeilen_silver
--   Im vorliegenden Datensatz ist ohne_flag = 0, jeder Unfall
--   traegt also mindestens ein Verkehrsmittel-Flag.
-- =============================================================

SELECT
  (SELECT COUNT(*)
     FROM workspace.default.unfaelle_silver)                  AS zeilen_silver,
  (SELECT COUNT(*)
     FROM workspace.default.unfaelle_beteiligte)              AS zeilen_beteiligte,
  (SELECT COUNT(DISTINCT unfall_id)
     FROM workspace.default.unfaelle_beteiligte)              AS ids_beteiligte,
  (SELECT COUNT(*)
     FROM workspace.default.unfaelle_silver
    WHERE NOT (ist_rad OR ist_pkw OR ist_fuss
               OR ist_krad OR ist_lkw OR ist_sonstige))       AS ohne_flag;

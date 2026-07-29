-- =============================================================
-- 04_dim_einwohner.sql
-- Dimensionstabelle zur Normierung der Unfallzahlen
--
-- Ohne Normierung bildet ein Bundesland-Ranking im Wesentlichen
-- die Einwohnerzahl ab und sagt fachlich nichts aus.
--
-- ACHTUNG: Die Werte unten sind gerundete Naeherungen und muessen
-- vor Veroeffentlichung durch offizielle Zahlen ersetzt werden.
-- Quelle: Statistisches Bundesamt, GENESIS-Tabelle 12411
-- (Bevoelkerungsstand nach Bundesland).
--
-- Bekannte Vereinfachung: nur ein Stichtag statt jahresgenauer
-- Werte. Sauberer waere eine zusaetzliche Spalte jahr und ein
-- Join ueber (bundesland, jahr).
--
-- Die Schreibweise der Bundeslaender muss exakt der CASE-
-- Uebersetzung in 02_silver.sql entsprechen, sonst greift der
-- Join nicht. Kontrolle: checks/04_join_vollstaendigkeit.sql
-- =============================================================

CREATE OR REPLACE TABLE workspace.default.bundesland_einwohner AS
SELECT * FROM VALUES
  ('Nordrhein-Westfalen',    18100000),
  ('Bayern',                 13400000),
  ('Baden-Württemberg',      11300000),
  ('Niedersachsen',           8100000),
  ('Hessen',                  6400000),
  ('Rheinland-Pfalz',         4200000),
  ('Sachsen',                 4100000),
  ('Berlin',                  3800000),
  ('Schleswig-Holstein',      2950000),
  ('Brandenburg',             2600000),
  ('Sachsen-Anhalt',          2200000),
  ('Thüringen',               2100000),
  ('Hamburg',                 1900000),
  ('Mecklenburg-Vorpommern',  1600000),
  ('Saarland',                1000000),
  ('Bremen',                   700000)
AS t(bundesland, einwohner);

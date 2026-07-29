-- =============================================================
-- 03_beteiligte.sql
-- Lange Form: eine Zeile je Unfall UND beteiligtem Verkehrsmittel
--
-- Warum: Die Ist*-Flags sind kein einzelnes Merkmal, sondern sechs
-- unabhaengige Boolean-Spalten. In der breiten Form laesst sich
-- nicht nach Verkehrsmittel gruppieren -- man muesste sechs
-- Einzelabfragen schreiben und zusammensetzen. explode() klappt
-- die Flags von der Breite in die Laenge und macht daraus eine
-- Dimension.
--
-- Folge fuers Dashboard:
--   COUNT(*)                  -> Beteiligungen (~2,65 Mio.)
--   COUNT(DISTINCT unfall_id) -> Unfaelle      (~1,81 Mio.)
-- Die Kategorien ueberlappen sich: ein Unfall zwischen LKW und
-- Rad erscheint in beiden Verkehrsmittel-Gruppen.
-- =============================================================

CREATE OR REPLACE TABLE workspace.default.unfaelle_beteiligte AS
SELECT
  unfall_id,
  jahr,
  monat,
  stunde,
  wochentag,
  wochentag_nr,
  ist_wochenende,
  tageszeit,
  bundesland,
  kreis_ags,
  lat,
  lon,
  unfallkategorie,
  ist_toedlich,
  unfalltyp,
  lichtverhaeltnisse,
  strassenzustand,
  verkehrsmittel
FROM workspace.default.unfaelle_silver
LATERAL VIEW explode(map(
  'Fahrrad',            ist_rad,
  'PKW',                ist_pkw,
  'Fußgänger',          ist_fuss,
  'Motorrad',           ist_krad,
  'Güterkraftfahrzeug', ist_lkw,
  'Sonstige',           ist_sonstige
)) t AS verkehrsmittel, beteiligt
WHERE beteiligt;

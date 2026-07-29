-- =============================================================
-- CHECK 05 -- Join gegen die Einwohner-Dimension
-- Nach 04_dim_einwohner.sql ausfuehren.
--
-- Ein INNER JOIN verwirft Zeilen ohne Treffer stillschweigend.
-- Eine abweichende Schreibweise eines Bundeslands (Umlaut,
-- Bindestrich) reduziert dann die Gesamtzahl, ohne dass eine
-- Fehlermeldung erscheint.
--
-- Erwartung: 16 Bundeslaender, unfaelle_im_join entspricht der
-- Gesamtzahl aus Silver.
-- =============================================================

SELECT
  COUNT(DISTINCT s.bundesland) AS bundeslaender_im_join,
  COUNT(*)                     AS unfaelle_im_join
FROM workspace.default.unfaelle_silver s
JOIN workspace.default.bundesland_einwohner e
  ON s.bundesland = e.bundesland;


-- Bei Abweichung: nicht zuordenbare Schreibweisen anzeigen
SELECT DISTINCT s.bundesland
FROM workspace.default.unfaelle_silver s
LEFT JOIN workspace.default.bundesland_einwohner e
  ON s.bundesland = e.bundesland
WHERE e.bundesland IS NULL;

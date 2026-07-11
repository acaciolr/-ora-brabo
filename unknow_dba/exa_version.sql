SELECT
cellname cv_cellname
, CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/objective/text()') AS VARCHAR2(20)) objective
, CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/status/text()')    AS VARCHAR2(15)) status
, CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/name/text()')      AS VARCHAR2(30)) interdb_plan
, CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/catPlan/text()')   AS VARCHAR2(30)) cat_plan
, CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/dbPlan/text()')    AS VARCHAR2(30)) db_plan
FROM
v$cell_config 
WHERE
conftype = 'IORM'
ORDER BY
cv_cellname
/
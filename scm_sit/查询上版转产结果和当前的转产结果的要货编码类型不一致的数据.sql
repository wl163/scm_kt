SELECT
t1.proto_code,
t1.proto_code_type AS current_type,
t2.proto_code_type AS previous_type
FROM (
    SELECT
    DISTINCT
    proto_code,
    proto_code_type
    FROM sp_turn_prodt_put
    WHERE ((proto_code_type='套机' AND whole_in_out='整机') OR proto_code_type IN ('单内','单外','配件'))
) AS t1
LEFT JOIN (
    SELECT
    DISTINCT
    proto_code,
    proto_code_type
    FROM sp_turn_prodt_result_last_week_pre
    WHERE ((proto_code_type='套机' AND whole_in_out='整机') OR proto_code_type IN ('单内','单外','配件'))
) AS t2 ON t1.proto_code=t2.proto_code
WHERE t2.proto_code IS NOT NULL AND t1.proto_code_type!=t2.proto_code_type




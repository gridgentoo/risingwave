CREATE TABLE supplier (s_suppkey INT, s_name CHARACTER VARYING, s_address CHARACTER VARYING, s_nationkey INT, s_phone CHARACTER VARYING, s_acctbal NUMERIC, s_comment CHARACTER VARYING, PRIMARY KEY (s_suppkey));
CREATE TABLE part (p_partkey INT, p_name CHARACTER VARYING, p_mfgr CHARACTER VARYING, p_brand CHARACTER VARYING, p_type CHARACTER VARYING, p_size INT, p_container CHARACTER VARYING, p_retailprice NUMERIC, p_comment CHARACTER VARYING, PRIMARY KEY (p_partkey));
CREATE TABLE partsupp (ps_partkey INT, ps_suppkey INT, ps_availqty INT, ps_supplycost NUMERIC, ps_comment CHARACTER VARYING, PRIMARY KEY (ps_partkey, ps_suppkey));
CREATE TABLE customer (c_custkey INT, c_name CHARACTER VARYING, c_address CHARACTER VARYING, c_nationkey INT, c_phone CHARACTER VARYING, c_acctbal NUMERIC, c_mktsegment CHARACTER VARYING, c_comment CHARACTER VARYING, PRIMARY KEY (c_custkey));
CREATE TABLE orders (o_orderkey BIGINT, o_custkey INT, o_orderstatus CHARACTER VARYING, o_totalprice NUMERIC, o_orderdate DATE, o_orderpriority CHARACTER VARYING, o_clerk CHARACTER VARYING, o_shippriority INT, o_comment CHARACTER VARYING, PRIMARY KEY (o_orderkey));
CREATE TABLE lineitem (l_orderkey BIGINT, l_partkey INT, l_suppkey INT, l_linenumber INT, l_quantity NUMERIC, l_extendedprice NUMERIC, l_discount NUMERIC, l_tax NUMERIC, l_returnflag CHARACTER VARYING, l_linestatus CHARACTER VARYING, l_shipdate DATE, l_commitdate DATE, l_receiptdate DATE, l_shipinstruct CHARACTER VARYING, l_shipmode CHARACTER VARYING, l_comment CHARACTER VARYING, PRIMARY KEY (l_orderkey, l_linenumber));
CREATE TABLE nation (n_nationkey INT, n_name CHARACTER VARYING, n_regionkey INT, n_comment CHARACTER VARYING, PRIMARY KEY (n_nationkey));
CREATE TABLE region (r_regionkey INT, r_name CHARACTER VARYING, r_comment CHARACTER VARYING, PRIMARY KEY (r_regionkey));
CREATE TABLE person (id BIGINT, name CHARACTER VARYING, email_address CHARACTER VARYING, credit_card CHARACTER VARYING, city CHARACTER VARYING, state CHARACTER VARYING, date_time TIMESTAMP, extra CHARACTER VARYING, PRIMARY KEY (id));
CREATE TABLE auction (id BIGINT, item_name CHARACTER VARYING, description CHARACTER VARYING, initial_bid BIGINT, reserve BIGINT, date_time TIMESTAMP, expires TIMESTAMP, seller BIGINT, category BIGINT, extra CHARACTER VARYING, PRIMARY KEY (id));
CREATE TABLE bid (auction BIGINT, bidder BIGINT, price BIGINT, channel CHARACTER VARYING, url CHARACTER VARYING, date_time TIMESTAMP, extra CHARACTER VARYING);
CREATE TABLE alltypes1 (c1 BOOLEAN, c2 SMALLINT, c3 INT, c4 BIGINT, c5 REAL, c6 DOUBLE, c7 NUMERIC, c8 DATE, c9 CHARACTER VARYING, c10 TIME, c11 TIMESTAMP, c13 INTERVAL, c14 STRUCT<a INT>, c15 INT[], c16 CHARACTER VARYING[]);
CREATE TABLE alltypes2 (c1 BOOLEAN, c2 SMALLINT, c3 INT, c4 BIGINT, c5 REAL, c6 DOUBLE, c7 NUMERIC, c8 DATE, c9 CHARACTER VARYING, c10 TIME, c11 TIMESTAMP, c13 INTERVAL, c14 STRUCT<a INT>, c15 INT[], c16 CHARACTER VARYING[]);
CREATE MATERIALIZED VIEW m0 AS SELECT t_1.extra AS col_0, max((OVERLAY((TRIM(TRAILING t_0.o_clerk FROM t_0.o_orderstatus)) PLACING ('Tc5Athm7dN') FROM (INT '40')))) AS col_1 FROM orders AS t_0 JOIN person AS t_1 ON t_0.o_clerk = t_1.extra GROUP BY t_0.o_orderkey, t_1.state, t_0.o_shippriority, t_1.credit_card, t_1.extra HAVING false;
CREATE MATERIALIZED VIEW m1 AS SELECT t_1.c15 AS col_0, t_1.c14 AS col_1 FROM nation AS t_0 FULL JOIN alltypes2 AS t_1 ON t_0.n_comment = t_1.c9 WHERE t_1.c1 GROUP BY t_1.c14, t_1.c15, t_0.n_regionkey;
CREATE MATERIALIZED VIEW m2 AS WITH with_0 AS (WITH with_1 AS (SELECT t_2.r_name AS col_0 FROM region AS t_2 WHERE (coalesce(NULL, NULL, NULL, NULL, false, NULL, NULL, NULL, NULL, NULL)) GROUP BY t_2.r_name) SELECT (709) AS col_0 FROM with_1 WHERE true) SELECT (SMALLINT '32767') AS col_0, (233) AS col_1, ((SMALLINT '74') * (INTERVAL '305491')) AS col_2 FROM with_0 WHERE true;
CREATE MATERIALIZED VIEW m3 AS SELECT tumble_0.c8 AS col_0, tumble_0.c16 AS col_1, tumble_0.c11 AS col_2 FROM tumble(alltypes1, alltypes1.c11, INTERVAL '16') AS tumble_0 WHERE CAST(tumble_0.c3 AS BOOLEAN) GROUP BY tumble_0.c13, tumble_0.c9, tumble_0.c16, tumble_0.c3, tumble_0.c5, tumble_0.c11, tumble_0.c8;
CREATE MATERIALIZED VIEW m4 AS SELECT (INTERVAL '0') AS col_0, (INT '1') AS col_1, 'ixYmlf8dhh' AS col_2, (CASE WHEN (true) THEN t_1.seller WHEN true THEN t_1.seller ELSE t_1.seller END) AS col_3 FROM alltypes1 AS t_0 LEFT JOIN auction AS t_1 ON t_0.c11 = t_1.expires AND t_0.c1 WHERE (t_0.c10 = (INTERVAL '822701')) GROUP BY t_0.c6, t_0.c8, t_0.c13, t_1.seller, t_0.c3, t_1.description, t_1.extra, t_0.c10, t_1.item_name, t_0.c15 HAVING true;
CREATE MATERIALIZED VIEW m5 AS SELECT (380) AS col_0, TIME '05:38:26' AS col_1 FROM region AS t_0 LEFT JOIN supplier AS t_1 ON t_0.r_comment = t_1.s_name GROUP BY t_1.s_acctbal, t_1.s_name, t_0.r_regionkey, t_1.s_suppkey HAVING true;
CREATE MATERIALIZED VIEW m6 AS WITH with_0 AS (SELECT (INT '-250511417') AS col_0, (concat_ws(t_1.p_container, 'Wwx39crvxu', 'USIeQWyf0c', t_1.p_container)) AS col_1, 'stOcyalwdo' AS col_2, t_1.p_partkey AS col_3 FROM part AS t_1 WHERE true GROUP BY t_1.p_container, t_1.p_partkey, t_1.p_type HAVING false) SELECT (227) AS col_0, (INT '-2121625792') AS col_1 FROM with_0;
CREATE MATERIALIZED VIEW m7 AS SELECT tumble_0.c16 AS col_0 FROM tumble(alltypes1, alltypes1.c11, INTERVAL '62') AS tumble_0 GROUP BY tumble_0.c15, tumble_0.c16, tumble_0.c1, tumble_0.c9, tumble_0.c3;
CREATE MATERIALIZED VIEW m8 AS SELECT CAST(true AS INT) AS col_0 FROM orders AS t_0 RIGHT JOIN customer AS t_1 ON t_0.o_orderpriority = t_1.c_address GROUP BY t_1.c_name, t_0.o_shippriority, t_0.o_clerk;
CREATE MATERIALIZED VIEW m9 AS WITH with_0 AS (SELECT (INTERVAL '1') AS col_0 FROM m4 AS t_3 WHERE (coalesce(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, NULL)) GROUP BY t_3.col_1, t_3.col_0) SELECT ARRAY[TIMESTAMP '2022-04-05 05:39:28', TIMESTAMP '2022-04-05 05:39:28', TIMESTAMP '2022-03-29 05:20:34', TIMESTAMP '2022-04-05 04:39:28'] AS col_0, (BIGINT '542') AS col_1 FROM with_0 WHERE ('Py3ohnAkD9' > 'Ekf6Co8NUP');
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
CREATE MATERIALIZED VIEW m0 AS WITH with_0 AS (WITH with_1 AS (SELECT sq_3.col_0 AS col_0, (INTERVAL '-60') AS col_1, (REAL '-546183167') AS col_2, (TRIM(BOTH '3V6RYnGjM9' FROM sq_3.col_0)) AS col_3 FROM (SELECT 'mPuLpnJegN' AS col_0 FROM region AS t_2 WHERE ((18) <= (REAL '311')) GROUP BY t_2.r_regionkey, t_2.r_comment HAVING max(((coalesce(NULL, NULL, NULL, NULL, NULL, DATE '2021-12-23', NULL, NULL, NULL, NULL)) < TIMESTAMP '2021-12-28 06:11:32'))) AS sq_3 WHERE false GROUP BY sq_3.col_0 HAVING true) SELECT (886) AS col_0 FROM with_1) SELECT (BIGINT '813') AS col_0 FROM with_0 WHERE (((INT '173') * (coalesce(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, (length('AilS6NWO72'))))) > (INT '790'));
CREATE MATERIALIZED VIEW m2 AS SELECT t_1.auction AS col_0 FROM person AS t_0 JOIN bid AS t_1 ON t_0.credit_card = t_1.channel GROUP BY t_0.id, t_1.date_time, t_1.auction HAVING (true);
CREATE MATERIALIZED VIEW m3 AS WITH with_0 AS (SELECT t_2.c6 AS col_0, t_1.url AS col_1 FROM bid AS t_1 FULL JOIN alltypes2 AS t_2 ON t_1.price = t_2.c4 WHERE t_2.c1 GROUP BY t_1.url, t_2.c16, t_1.date_time, t_2.c6, t_2.c15) SELECT (SMALLINT '474') AS col_0, (BIGINT '366') AS col_1, (BIGINT '565') AS col_2, (FLOAT '-1410477295') AS col_3 FROM with_0 WHERE true;
CREATE MATERIALIZED VIEW m4 AS SELECT sq_2.col_0 AS col_0 FROM (SELECT 'i06ifKXGVK' AS col_0, t_1.category AS col_1 FROM nation AS t_0 RIGHT JOIN auction AS t_1 ON t_0.n_comment = t_1.item_name AND true GROUP BY t_1.reserve, t_1.extra, t_1.initial_bid, t_1.category, t_1.id, t_1.seller) AS sq_2 WHERE true GROUP BY sq_2.col_0 HAVING ((REAL '1079667743') = (766));
CREATE MATERIALIZED VIEW m5 AS SELECT t_0.expires AS col_0 FROM auction AS t_0 RIGHT JOIN region AS t_1 ON t_0.extra = t_1.r_comment WHERE false GROUP BY t_0.expires HAVING (coalesce(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, NULL));
CREATE MATERIALIZED VIEW m7 AS WITH with_0 AS (WITH with_1 AS (WITH with_2 AS (SELECT sq_4.col_0 AS col_0, (to_char(DATE '2021-12-28', (TRIM(sq_4.col_0)))) AS col_1, 'zNpm5OIRNC' AS col_2, sq_4.col_0 AS col_3 FROM (SELECT t_3.s_phone AS col_0, t_3.s_phone AS col_1, t_3.s_phone AS col_2, (0) AS col_3 FROM supplier AS t_3 WHERE CAST(t_3.s_nationkey AS BOOLEAN) GROUP BY t_3.s_phone) AS sq_4 WHERE (TIMESTAMP '2021-12-29 05:11:35' <= TIMESTAMP '2021-12-29 06:11:34') GROUP BY sq_4.col_0) SELECT TIME '05:11:35' AS col_0, (SMALLINT '183') AS col_1 FROM with_2) SELECT TIME '06:11:34' AS col_0, TIMESTAMP '2021-12-29 06:11:35' AS col_1, false AS col_2 FROM with_1) SELECT (SMALLINT '760') AS col_0, DATE '2021-12-22' AS col_1 FROM with_0;
CREATE MATERIALIZED VIEW m8 AS SELECT (((((SMALLINT '479') | (SMALLINT '652')) + (((SMALLINT '63') # (SMALLINT '1')) >> (t_0.n_nationkey % (SMALLINT '624')))) * (SMALLINT '964')) * t_1.p_partkey) AS col_0 FROM nation AS t_0 RIGHT JOIN part AS t_1 ON t_0.n_comment = t_1.p_brand WHERE false GROUP BY t_1.p_size, t_0.n_nationkey, t_1.p_type, t_1.p_brand, t_1.p_partkey;
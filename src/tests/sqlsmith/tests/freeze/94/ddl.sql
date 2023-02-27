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
CREATE MATERIALIZED VIEW m0 AS WITH with_0 AS (SELECT t_1.c3 AS col_0, CAST(t_2.c1 AS INT) AS col_1 FROM alltypes2 AS t_1 FULL JOIN alltypes1 AS t_2 ON t_1.c13 = t_2.c13 AND t_2.c1 WHERE t_1.c1 GROUP BY t_1.c3, t_2.c6, t_2.c5, t_2.c2, t_2.c3, t_1.c5, t_2.c9, t_2.c11, t_2.c1, t_1.c11, t_1.c2, t_1.c7, t_2.c10, t_2.c13, t_1.c4) SELECT (DATE '2022-07-10' - (INTERVAL '-722661')) AS col_0, (936) AS col_1, DATE '2022-07-10' AS col_2 FROM with_0;
CREATE MATERIALIZED VIEW m2 AS SELECT t_0.price AS col_0, (OVERLAY(t_0.channel PLACING (md5(string_agg(t_0.extra, (concat_ws(t_0.url, t_0.channel, t_0.url, (upper('Ka0nr1uSci'))))) FILTER(WHERE ((324) < (BIGINT '-4173394539989201154'))))) FROM (INT '216') FOR (INT '551'))) AS col_1, (BIGINT '299') AS col_2, ('qKBVWQSyOh') AS col_3 FROM bid AS t_0 GROUP BY t_0.price, t_0.date_time, t_0.channel, t_0.extra;
CREATE MATERIALIZED VIEW m3 AS SELECT t_0.c6 AS col_0 FROM alltypes2 AS t_0 JOIN person AS t_1 ON t_0.c9 = t_1.name AND (t_0.c6 = (t_0.c3 | t_0.c4)) WHERE false GROUP BY t_0.c8, t_0.c6, t_0.c3, t_0.c13, t_0.c5, t_0.c10, t_1.id HAVING false;
CREATE MATERIALIZED VIEW m4 AS WITH with_0 AS (SELECT t_1.p_size AS col_0, ((SMALLINT '668') # t_1.p_size) AS col_1, t_1.p_partkey AS col_2, (FLOAT '289') AS col_3 FROM part AS t_1 GROUP BY t_1.p_size, t_1.p_name, t_1.p_partkey, t_1.p_mfgr, t_1.p_type HAVING ((SMALLINT '846') < (BIGINT '839'))) SELECT false AS col_0, TIME '06:12:21' AS col_1 FROM with_0 WHERE false;
CREATE MATERIALIZED VIEW m5 AS SELECT (TIMESTAMP '2022-07-03 06:12:23') AS col_0, tumble_0.col_1 AS col_1 FROM tumble(m0, m0.col_0, INTERVAL '45') AS tumble_0 WHERE true GROUP BY tumble_0.col_1, tumble_0.col_0;
CREATE MATERIALIZED VIEW m6 AS SELECT DATE '2022-07-03' AS col_0, (SMALLINT '1') AS col_1 FROM alltypes1 AS t_0 GROUP BY t_0.c6, t_0.c8, t_0.c1, t_0.c2, t_0.c15;
CREATE MATERIALIZED VIEW m7 AS WITH with_0 AS (SELECT (FLOAT '64') AS col_0, tumble_1.col_0 AS col_1, (concat_ws('42v3ClcaIQ', 'ksQGwBxe4S', '2Z7iIMLnnQ', 'ehGeOqlJOd')) AS col_2 FROM tumble(m5, m5.col_0, INTERVAL '39') AS tumble_1 GROUP BY tumble_1.col_0) SELECT CAST(NULL AS STRUCT<a INT, b INTERVAL, c TIME>) AS col_0, (split_part('XGe6N6Bf4Q', 'mrrcMJD97G', (INT '268'))) AS col_1, 'ZR1c2Yue7v' AS col_2 FROM with_0 WHERE (DATE '2022-07-10' <> (DATE '2022-07-09' - (INT '1')));
CREATE MATERIALIZED VIEW m9 AS SELECT hop_0.auction AS col_0 FROM hop(bid, bid.date_time, INTERVAL '3600', INTERVAL '334800') AS hop_0 WHERE false GROUP BY hop_0.bidder, hop_0.price, hop_0.date_time, hop_0.auction;
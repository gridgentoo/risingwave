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
CREATE MATERIALIZED VIEW m0 AS WITH with_0 AS (SELECT (BIGINT '-1023023015045217323') AS col_0, t_2.l_quantity AS col_1, t_1.extra AS col_2 FROM auction AS t_1 LEFT JOIN lineitem AS t_2 ON t_1.seller = t_2.l_orderkey AND true GROUP BY t_2.l_linestatus, t_2.l_returnflag, t_2.l_orderkey, t_2.l_shipinstruct, t_1.extra, t_2.l_quantity, t_1.initial_bid, t_1.description) SELECT (69) AS col_0, (coalesce(NULL, NULL, NULL, TIMESTAMP '2022-06-16 07:18:38', NULL, NULL, NULL, NULL, NULL, NULL)) AS col_1 FROM with_0 WHERE true;
CREATE MATERIALIZED VIEW m1 AS WITH with_0 AS (SELECT ((SMALLINT '0') | (BIGINT '825')) AS col_0 FROM hop(auction, auction.expires, INTERVAL '538666', INTERVAL '22085306') AS hop_1 WHERE ((((FLOAT '553') - ((REAL '921') + (REAL '604'))) * (FLOAT '252')) <= (FLOAT '547')) GROUP BY hop_1.initial_bid, hop_1.seller) SELECT (INT '352') AS col_0, ((SMALLINT '477') % (BIGINT '902')) AS col_1, CAST((INT '66') AS BOOLEAN) AS col_2, (approx_count_distinct((FLOAT '996')) FILTER(WHERE true) - (INT '711')) AS col_3 FROM with_0 WHERE false;
CREATE MATERIALIZED VIEW m2 AS SELECT (SMALLINT '-11551') AS col_0, t_0.initial_bid AS col_1, t_0.initial_bid AS col_2 FROM auction AS t_0 RIGHT JOIN region AS t_1 ON t_0.extra = t_1.r_comment AND true GROUP BY t_0.initial_bid;
CREATE MATERIALIZED VIEW m3 AS WITH with_0 AS (SELECT (REAL '808') AS col_0, t_1.c5 AS col_1 FROM alltypes2 AS t_1 LEFT JOIN partsupp AS t_2 ON t_1.c3 = t_2.ps_partkey AND t_1.c1 GROUP BY t_1.c5 HAVING true) SELECT (INT '240') AS col_0, true AS col_1, true AS col_2 FROM with_0 WHERE ((FLOAT '930') < (FLOAT '23'));
CREATE MATERIALIZED VIEW m4 AS SELECT tumble_0.date_time AS col_0, (BIGINT '530') AS col_1, TIME '07:18:39' AS col_2 FROM tumble(auction, auction.date_time, INTERVAL '78') AS tumble_0 WHERE ((SMALLINT '0') = (FLOAT '412')) GROUP BY tumble_0.date_time, tumble_0.initial_bid, tumble_0.id, tumble_0.expires HAVING true;
CREATE MATERIALIZED VIEW m5 AS SELECT DATE '2022-06-17' AS col_0, hop_0.c1 AS col_1, true AS col_2, ((REAL '292') < (REAL '882')) AS col_3 FROM hop(alltypes2, alltypes2.c11, INTERVAL '1', INTERVAL '83') AS hop_0 WHERE true GROUP BY hop_0.c6, hop_0.c1, hop_0.c14;
CREATE MATERIALIZED VIEW m6 AS SELECT (substr(t_1.c_address, t_0.ps_availqty)) AS col_0 FROM partsupp AS t_0 LEFT JOIN customer AS t_1 ON t_0.ps_availqty = t_1.c_custkey AND true WHERE (true) GROUP BY t_1.c_address, t_1.c_acctbal, t_0.ps_availqty, t_0.ps_supplycost;
CREATE MATERIALIZED VIEW m8 AS SELECT 'UOjuyOp4HS' AS col_0 FROM hop(person, person.date_time, INTERVAL '604800', INTERVAL '52617600') AS hop_0 WHERE true GROUP BY hop_0.id, hop_0.email_address, hop_0.city;
// Copyright 2023 RisingWave Labs
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.risingwave.sourcenode;

import com.risingwave.proto.ConnectorServiceProto;
import com.risingwave.proto.Data;
import com.risingwave.sourcenode.common.DbzConnectorConfig;
import com.risingwave.sourcenode.common.PostgresValidator;
import com.risingwave.sourcenode.common.ValidatorUtils;
import io.grpc.StatusRuntimeException;
import io.grpc.stub.StreamObserver;
import java.io.IOException;
import java.sql.DriverManager;
import java.util.*;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SourceValidateHandler {
    static final Logger LOG = LoggerFactory.getLogger(SourceValidateHandler.class);
    private final StreamObserver<ConnectorServiceProto.ValidateSourceResponse> responseObserver;

    public SourceValidateHandler(
            StreamObserver<ConnectorServiceProto.ValidateSourceResponse> responseObserver) {
        this.responseObserver = responseObserver;
    }

    public void handle(ConnectorServiceProto.ValidateSourceRequest request) {
        try {
            validateDbProperties(request, this.responseObserver);
            // validate pass
            responseObserver.onNext(
                    ConnectorServiceProto.ValidateSourceResponse.newBuilder().build());
            responseObserver.onCompleted();

        } catch (StatusRuntimeException e) {
            LOG.warn("Source validation failed", e);
            responseObserver.onNext(validateResponse(e.getMessage()));
            responseObserver.onCompleted();

        } catch (Exception e) {
            LOG.error("Internal error on source validation", e);
            responseObserver.onNext(validateResponse("Internal error: " + e.getMessage()));
            responseObserver.onCompleted();
        }
    }

    private ConnectorServiceProto.ValidateSourceResponse validateResponse(String message) {
        return ConnectorServiceProto.ValidateSourceResponse.newBuilder()
                .setError(
                        ConnectorServiceProto.ValidationError.newBuilder()
                                .setErrorMessage(message)
                                .build())
                .build();
    }

    private void ensurePropNotNull(Map<String, String> props, String name) {
        if (!props.containsKey(name)) {
            throw ValidatorUtils.invalidArgument(
                    String.format("'%s' not found, please check the WITH properties", name));
        }
    }

    private String getJdbcPrefix(ConnectorServiceProto.SourceType sourceType) {
        switch (sourceType) {
            case MYSQL:
                return "jdbc:mysql";
            case POSTGRES:
            case CITUS:
                return "jdbc:postgresql";
            default:
                throw ValidatorUtils.invalidArgument("Unknown source type: " + sourceType);
        }
    }

    private void validateDbProperties(
            ConnectorServiceProto.ValidateSourceRequest request,
            StreamObserver<ConnectorServiceProto.ValidateSourceResponse> responseObserver)
            throws Exception {
        var props = request.getPropertiesMap();

        ensurePropNotNull(props, DbzConnectorConfig.HOST);
        ensurePropNotNull(props, DbzConnectorConfig.PORT);
        ensurePropNotNull(props, DbzConnectorConfig.DB_NAME);
        ensurePropNotNull(props, DbzConnectorConfig.TABLE_NAME);
        String jdbcUrl =
                getJdbcPrefix(request.getSourceType())
                        + "://"
                        + props.get(DbzConnectorConfig.HOST)
                        + ":"
                        + props.get(DbzConnectorConfig.PORT)
                        + "/"
                        + props.get(DbzConnectorConfig.DB_NAME);
        LOG.debug("validate jdbc url: {}", jdbcUrl);

        var sqlStmts = new Properties();
        try (var input =
                getClass().getClassLoader().getResourceAsStream("validate_sql.properties")) {
            sqlStmts.load(input);
        } catch (IOException e) {
            LOG.error("failed to load sql statements", e);
            throw ValidatorUtils.internalError(e.getMessage());
        }

        ensurePropNotNull(props, DbzConnectorConfig.USER);
        ensurePropNotNull(props, DbzConnectorConfig.PASSWORD);
        String dbUser = props.get(DbzConnectorConfig.USER);
        String dbPassword = props.get(DbzConnectorConfig.PASSWORD);
        switch (request.getSourceType()) {
            case POSTGRES:
                ensurePropNotNull(props, DbzConnectorConfig.PG_SCHEMA_NAME);
                try (var validator =
                        new PostgresValidator(
                                jdbcUrl,
                                dbUser,
                                dbPassword,
                                props,
                                sqlStmts,
                                request.getTableSchema())) {
                    validator.validateAll();
                }
                break;

            case CITUS:
                ensurePropNotNull(props, DbzConnectorConfig.PG_SCHEMA_NAME);
                try (var coordinatorValidator =
                        new PostgresValidator(
                                jdbcUrl,
                                dbUser,
                                dbPassword,
                                props,
                                sqlStmts,
                                request.getTableSchema())) {
                    coordinatorValidator.validateDistributedTable();
                    coordinatorValidator.validateTableSchema();
                }

                ensurePropNotNull(props, DbzConnectorConfig.DB_SERVERS);
                var servers = props.get(DbzConnectorConfig.DB_SERVERS);
                var workerAddrs = StringUtils.split(servers, ',');
                var jdbcPrefix = getJdbcPrefix(request.getSourceType());
                for (String workerAddr : workerAddrs) {
                    String workerJdbcUrl =
                            jdbcPrefix
                                    + "://"
                                    + workerAddr
                                    + "/"
                                    + props.get(DbzConnectorConfig.DB_NAME);

                    LOG.info("workerJdbcUrl {}", workerJdbcUrl);
                    try (var workerValidator =
                            new PostgresValidator(
                                    workerJdbcUrl,
                                    dbUser,
                                    dbPassword,
                                    props,
                                    sqlStmts,
                                    request.getTableSchema())) {
                        workerValidator.validateLogConfig();
                        workerValidator.validatePrivileges();
                    }
                }

                break;
            case MYSQL:
                try (var conn =
                        DriverManager.getConnection(
                                jdbcUrl,
                                props.get(DbzConnectorConfig.USER),
                                props.get(DbzConnectorConfig.PASSWORD))) {
                    // usernamed and password are correct
                    var dbMeta = conn.getMetaData();

                    LOG.debug("source schema: {}", request.getTableSchema().getColumnsList());
                    LOG.debug("source pk: {}", request.getTableSchema().getPkIndicesList());

                    // check whether source db has enabled binlog
                    try (var stmt = conn.createStatement()) {
                        var res = stmt.executeQuery(sqlStmts.getProperty("mysql.bin_log"));
                        while (res.next()) {
                            if (!res.getString(2).equalsIgnoreCase("ON")) {
                                throw ValidatorUtils.internalError(
                                        "MySQL doesn't enable binlog.\nPlease set the value of log_bin to 'ON' and restart your MySQL server.");
                            }
                        }
                    }
                    // check binlog format
                    try (var stmt = conn.createStatement()) {
                        var res = stmt.executeQuery(sqlStmts.getProperty("mysql.bin_format"));
                        while (res.next()) {
                            if (!res.getString(2).equalsIgnoreCase("ROW")) {
                                throw ValidatorUtils.internalError(
                                        "MySQL binlog_format should be 'ROW'.\nPlease modify the config and restart your MySQL server.");
                            }
                        }
                    }
                    try (var stmt = conn.createStatement()) {
                        var res = stmt.executeQuery(sqlStmts.getProperty("mysql.bin_row_image"));
                        while (res.next()) {
                            if (!res.getString(2).equalsIgnoreCase("FULL")) {
                                throw ValidatorUtils.internalError(
                                        "MySQL binlog_row_image should be 'FULL'.\\nPlease modify the config and restart your MySQL server.");
                            }
                        }
                    }
                    // check whether table exist
                    try (var stmt = conn.prepareStatement(sqlStmts.getProperty("mysql.table"))) {
                        stmt.setString(1, props.get(DbzConnectorConfig.DB_NAME));
                        stmt.setString(2, props.get(DbzConnectorConfig.TABLE_NAME));
                        var res = stmt.executeQuery();
                        while (res.next()) {
                            var ret = res.getInt(1);
                            if (ret == 0) {
                                throw ValidatorUtils.invalidArgument("MySQL table doesn't exist");
                            }
                        }
                    }
                    // check whether PK constraint match source table definition
                    try (var stmt =
                            conn.prepareStatement(sqlStmts.getProperty("mysql.table_schema"))) {
                        var sourceSchema = request.getTableSchema();
                        stmt.setString(1, props.get(DbzConnectorConfig.DB_NAME));
                        stmt.setString(2, props.get(DbzConnectorConfig.TABLE_NAME));
                        var res = stmt.executeQuery();
                        var pkFields = new HashSet<String>();
                        int index = 0;
                        while (res.next()) {
                            var field = res.getString(1);
                            var dataType = res.getString(2);
                            var key = res.getString(3);

                            if (index >= sourceSchema.getColumnsCount()) {
                                throw ValidatorUtils.invalidArgument(
                                        "The number of columns mismatch");
                            }

                            var srcCol = sourceSchema.getColumns(index++);
                            if (!srcCol.getName().equals(field)) {
                                throw ValidatorUtils.invalidArgument(
                                        String.format(
                                                "column name mismatch: %s, [%s]",
                                                field, srcCol.getName()));
                            }

                            if (!isMySQLDataTypeCompatible(dataType, srcCol.getDataType())) {
                                throw ValidatorUtils.invalidArgument(
                                        String.format(
                                                "incompatible data type of column %s",
                                                srcCol.getName()));
                            }
                            if (key.equalsIgnoreCase("PRI")) {
                                pkFields.add(field);
                            }
                        }

                        if (!isPkMatch(sourceSchema, pkFields)) {
                            throw ValidatorUtils.invalidArgument("Primary key mismatch");
                        }
                    }
                }
                break;
            default:
                LOG.warn("Unknown source type");
                throw ValidatorUtils.invalidArgument("Unknown source type");
        }
    }

    private boolean isPkMatch(
            ConnectorServiceProto.TableSchema sourceSchema, Set<String> pkFields) {
        if (sourceSchema.getPkIndicesCount() != pkFields.size()) {
            return false;
        }
        for (var index : sourceSchema.getPkIndicesList()) {
            if (!pkFields.contains(sourceSchema.getColumns(index).getName())) {
                return false;
            }
        }
        return true;
    }

    private boolean isMySQLDataTypeCompatible(
            String mysqlDataType, Data.DataType.TypeName typeName) {
        int val = typeName.getNumber();
        switch (mysqlDataType) {
            case "tinyint": // boolean
                return (val == Data.DataType.TypeName.BOOLEAN_VALUE)
                        || (Data.DataType.TypeName.INT16_VALUE <= val
                                && val <= Data.DataType.TypeName.INT64_VALUE);
            case "smallint":
                return Data.DataType.TypeName.INT16_VALUE <= val
                        && val <= Data.DataType.TypeName.INT64_VALUE;
            case "mediumint":
            case "int":
                return Data.DataType.TypeName.INT32_VALUE <= val
                        && val <= Data.DataType.TypeName.INT64_VALUE;
            case "bigint":
                return val == Data.DataType.TypeName.INT64_VALUE;

            case "float":
            case "real":
                return val == Data.DataType.TypeName.FLOAT_VALUE
                        || val == Data.DataType.TypeName.DOUBLE_VALUE;
            case "double":
                return val == Data.DataType.TypeName.DOUBLE_VALUE;
            case "decimal":
                return val == Data.DataType.TypeName.DECIMAL_VALUE;
            case "varchar":
                return val == Data.DataType.TypeName.VARCHAR_VALUE;
            default:
                return true; // true for other uncovered types
        }
    }

    private boolean isPostgresDataTypeCompatible(
            String pgDataType, Data.DataType.TypeName typeName) {
        int val = typeName.getNumber();
        switch (pgDataType) {
            case "smallint":
                return Data.DataType.TypeName.INT16_VALUE <= val
                        && val <= Data.DataType.TypeName.INT64_VALUE;
            case "integer":
                return Data.DataType.TypeName.INT32_VALUE <= val
                        && val <= Data.DataType.TypeName.INT64_VALUE;
            case "bigint":
                return val == Data.DataType.TypeName.INT64_VALUE;
            case "float":
            case "real":
                return val == Data.DataType.TypeName.FLOAT_VALUE
                        || val == Data.DataType.TypeName.DOUBLE_VALUE;
            case "boolean":
                return val == Data.DataType.TypeName.BOOLEAN_VALUE;
            case "double":
            case "double precision":
                return val == Data.DataType.TypeName.DOUBLE_VALUE;
            case "decimal":
            case "numeric":
                return val == Data.DataType.TypeName.DECIMAL_VALUE;
            case "varchar":
            case "character varying":
                return val == Data.DataType.TypeName.VARCHAR_VALUE;
            default:
                return true; // true for other uncovered types
        }
    }
}

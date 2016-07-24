package de.biggis.tools

import org.apache.flink.api.java.ExecutionEnvironment
import org.apache.flink.api.java.io.jdbc.JDBCInputFormat
import org.apache.flink.api.java.tuple.Tuple2
import org.apache.flink.api.java.typeutils.TupleTypeInfo

import static org.apache.flink.api.common.typeinfo.BasicTypeInfo.*

class FlinkListTiles {
    def static void main(String[] args) {
    	val env = ExecutionEnvironment.executionEnvironment
        val inputFormat = (JDBCInputFormat.buildJDBCInputFormat => [
            drivername = "com.mysql.jdbc.Driver"
            DBUrl = "jdbc:mysql://localhost:3306/tiledb"
            query = "select tileid, uri from tiles"
        ]).finish
    	val src = env.createInput(inputFormat, new TupleTypeInfo(Tuple2, LONG_TYPE_INFO, STRING_TYPE_INFO))
    	src.print
    }
}

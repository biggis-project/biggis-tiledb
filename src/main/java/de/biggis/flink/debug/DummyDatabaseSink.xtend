package de.biggis.flink.debug

import org.apache.flink.api.java.io.jdbc.JDBCOutputFormat
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment
import org.apache.flink.streaming.api.functions.sink.OutputFormatSinkFunction
import org.apache.flink.api.java.tuple.Tuple1

@Deprecated
class DummyDatabaseSink {

    def static void main(String[] args) {

        val outFormat = JDBCOutputFormat.buildJDBCOutputFormat
          .setDrivername("com.mysql.jdbc.Driver")
          .setDBUrl("jdbc:mysql://localhost:3306/tiledb")
          .setQuery("insert into pokus (num) values (?)")
          .finish

        val env = StreamExecutionEnvironment.getExecutionEnvironment
        //env.fromCollection((1 .. 10).toList).addSink(new MySQLDatabaseSink)
        env.fromCollection((1 .. 10).map[new Tuple1(it)].toList).addSink(new OutputFormatSinkFunction(outFormat))
        env.execute
        
          
       
        
        
    }
}


package de.biggis.flink

import java.sql.Connection
import java.sql.DriverManager
import java.sql.Statement
import org.apache.flink.configuration.Configuration
import org.apache.flink.streaming.api.functions.sink.RichSinkFunction

@Deprecated
class MySQLDatabaseSink<T> extends RichSinkFunction<T> {
    
    transient Connection conn
    transient Statement stmt
    
    override open(Configuration parameters) throws Exception {
        super.open(parameters)
        
        // JDBC initialization
        println("Connecting to database...")
        class.classLoader.loadClass("com.mysql.jdbc.Driver")
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/tiledb", "root", "test")
        stmt = conn.createStatement
    }
    
    override close() throws Exception {
        super.close()
        stmt.close
        conn.close
    }

    override invoke(T value) throws Exception {
        val sql = '''insert into pokus (num) values («value»)'''
        stmt.executeUpdate(sql)
        println(sql)
    }
}

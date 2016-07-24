package de.biggis.flink

import com.google.gson.Gson
import de.biggis.flink.messages.BiggisMessage
import java.sql.Connection
import java.sql.DriverManager
import java.util.Properties
import org.apache.flink.api.common.functions.MapFunction
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer09
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaProducer09
import org.apache.flink.streaming.util.serialization.SimpleStringSchema
import java.lang.reflect.Type

/**
 * Replaces JDBC SinkFunction because we want to perform additiona function when
 * inserting a record do to the database table.
 */
class BiggisTransformation {
    
    /** Lazy initialization */
    private transient Connection _conn

    /** Lazy initialization */
    private def getConn() {
        _conn ?: {
            println("Connecting to database...")
            
            // uses the same class loader as the class, which is safer,
            // especially when using frameworks such as OSGi
            class.classLoader.loadClass("com.mysql.jdbc.Driver")
            
            // this will also set the transient private variable
            _conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/tiledb", "root", "test")
            
            _conn.autoCommit = false
            _conn // returns the connection
        }
    }
    
//    transient int transformId
    transient val flinkExecEnv = StreamExecutionEnvironment.getExecutionEnvironment
    transient val kafkaSchema = new SimpleStringSchema
    transient Properties kafkaProps
    
    new() {
        kafkaProps = new Properties => [
            put("bootstrap.servers", "localhost:9092")
            put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
            put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")
            put("max.block.ms", "10000")
        ]
//        transformId = registerBiggisTransformation(args)
//        kafkaProps = ParameterTool.fromArgs(args).properties
    }
    
    def void destroy() {
//        unregisterBiggisTransformation(transformId)
    }
    
    def <IN extends BiggisMessage, OUT extends BiggisMessage> addTransform(
        Class<IN> input, Class<OUT> output, MapFunction<IN, OUT> func ) {

        flinkExecEnv
            .addSource(new FlinkKafkaConsumer09(input.name, kafkaSchema, kafkaProps))
            .map[ jsonmsg | new Gson().fromJson(jsonmsg, input) ]
            .returns(input) // type hint for flink
            .map(func)
            .map[ msg | new Gson().toJson(msg) ]
            .addSink(new FlinkKafkaProducer09(output.name, kafkaSchema, kafkaProps))
    }
    
    def <OUT extends BiggisMessage> addProducer(Class<OUT> output, MapFunction<Integer, OUT> func) {
        flinkExecEnv
        .setParallelism(1) // no parallelism
        .fromCollection((1000 .. 1).toList) // 1000 iterations
        .map(func) // produce one item in every iteratio
        .map[msg|new Gson().toJson(msg)] // serialize to JSON
        .addSink(new FlinkKafkaProducer09(output.name, kafkaSchema, kafkaProps))
    }
    
    def execute() {
        flinkExecEnv.execute
    }
    
//    private def registerBiggisTransformation(String[] args) {
//        val st = conn.prepareStatement("insert into transforms (params) values (?)")
//        
//        val serializedObj = new Gson().toJson(args)
//        st.setString(1, serializedObj)
//        st.executeUpdate
//            
//        val rs = st.generatedKeys
//        rs.next
//        val transformId = rs.getInt(1) // column #1 should be "tileid"
//        rs.close
//
//        st.close
//        conn.commit
//        
//        return transformId
//    }
//    
//    private def unregisterBiggisTransformation(int transformId) {
//        val st = conn.createStatement
//        st.executeUpdate('''DELETE FROM transforms WHERE transid = «transformId»''')
//        st.close
//        conn.commit
//    }
    
   
//    def SinkFunction<String> addOutputPort(String portName) {
//        
//        new FlinkKafkaProducer09(portName, kafkaSchema, kafkaProps)
//    }
//    
//    def DataStreamSource<String> addInputPort(String portName) {
//        env.addSource(new FlinkKafkaConsumer09(portName, kafkaSchema, kafkaProps))
//    }
    
//    def static void main(String[] args) {
//        val db = new LazyMySQL
//        val id = db.registerBiggisTransformation("testik")
//        println('''transformid: «id»''')
//        db.unregisterBiggisTransformation(id)
//    }
}


//        val mysqlOut = (JDBCOutputFormat.buildJDBCOutputFormat => [
//            drivername = "com.mysql.jdbc.Driver"
//            DBUrl = "jdbc:mysql://localhost:3306/tiledb"
//            batchInterval = 1 // after how many records we should insert the data into db table
//            query = '''
//                INSERT INTO tiles (fname, extent, update_area, ts, ts_idx)
//                VALUES (?,?,?,?,?)
//                ON DUPLICATE KEY UPDATE
//                    collisions = collisions + 1,
//                    fname = VALUES(fname),
//                    extent = VALUES(extent),
//                    update_area = VALUES(update_area),
//                    ts = VALUES(ts),
//                    ts_idx = VALUES(ts_idx)
//            '''
//        ]).finish

//       val tuples = tileStream.map[
//           new Tuple5(filename, polygon, polygon, timestamp, timestamp)
//       ].returns(TupleTypeInfo.getBasicTupleTypeInfo(String, String, String, String, String))
//       
//       tuples.addSink(new OutputFormatSinkFunction(mysqlOut))
//       tuples.print

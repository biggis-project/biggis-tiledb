package de.biggis.flink

import java.io.Serializable
import java.lang.reflect.Modifier
import java.sql.Connection
import java.sql.DriverManager
import java.sql.Statement
import java.sql.Timestamp
import java.util.Calendar

class TileDb implements Serializable {
    
    /** Lazy initialization */
    transient Connection _conn

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
    
    def getTileById(long tileid) {
        var Tile tile // tile of null will be returned
        
        val stmt = conn.createStatement
        stmt.execute('''SELECT * FROM tiles where tileid = «tileid»''')
        val rs = stmt.resultSet
        
        if (rs.next) {
            tile = new Tile
            for(i : 1..rs.metaData.columnCount) {
                val fieldName = rs.metaData.getColumnName(i)
                val fieldValue = rs.getObject(i)
                tile.setFieldByName(fieldName, fieldValue)
            }
            rs.close
        }
        
        stmt.close
        return tile
    }
    
    static dispatch def toValueTemplate(Geometry value) '''ST_GeometryFromText(?)'''
    static dispatch def toValueTemplate(Object value) '''?'''
    static dispatch def toValueTemplate(Void value) '''?''' // if value is null
    
    static dispatch def fixSqlValue(Geometry x) {return x.toString}
    static dispatch def fixSqlValue(Object x) {x}
    static dispatch def fixSqlValue(Void x) {x}

    def updateTile(Tile tile) {
        
        // we store only non-transient fields
        val nonTransientFields = Tile.declaredFields.filter[!Modifier.isTransient(modifiers)]
        nonTransientFields.forEach[accessible = true]
        
        val stmt = conn.prepareStatement('''
        REPLACE INTO tiles («nonTransientFields.map[name].join(", ")»)
        VALUES («nonTransientFields.map[get(tile).toValueTemplate].join(", ")»)
        ''', Statement.RETURN_GENERATED_KEYS)

        nonTransientFields.forEach[field, paramIndex |
            stmt.setObject(paramIndex + 1, field.get(tile).fixSqlValue)
        ]
        stmt.execute
        
        // keys are generated e.g. when adding new Tile to database
        val rs = stmt.generatedKeys
        rs.next
        val tileidGen = rs.getLong(1)
        
        conn.commit
        
        return tileidGen
    }
    
    def Tile createNewTile(String newUri) {
        val NOW = new Timestamp(Calendar.getInstance.time.time)
        return new Tile => [
            uri = newUri
            update_past = NOW
            ts = NOW
            ts_idx = NOW
            transid = 1 // TODO: transid should be registered and deregistered properly
            
            // insert into db and generate ID
            tileid = updateTile(it)
        ]
    }
}

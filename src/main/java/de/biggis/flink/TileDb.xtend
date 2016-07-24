package de.biggis.flink

import java.io.Serializable
import java.sql.Connection
import java.sql.DriverManager
import java.sql.Statement
import java.sql.Timestamp
import java.util.Calendar
import org.junit.Assert
import org.junit.Test
import java.math.BigInteger
import java.lang.reflect.Modifier

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
    
    def Tile getTileById(long tileid) {
        val stmt = conn.createStatement
        stmt.execute('''SELECT * FROM tiles where tileid = «tileid»''')
        
        val rs = stmt.resultSet
        if (rs.next) {
            new Tile => [
                for(field : Tile.declaredFields) {
                    field.accessible = true
                    field.set(it, rs.getObject(field.name).mapSqlType) //TODO: String probably comes from DB, it should be converted here to Polygon
                }
            ]
        }
    }
    
    static dispatch def mapSqlType(BigInteger value) {value.longValue}
    static dispatch def mapSqlType(Object value) {value}
    static dispatch def mapSqlType(Void value) {value}
    
    static dispatch def toValEntry(Polygon value) '''ST_GeometryFromText(?)'''
    static dispatch def toValEntry(Object value) '''?'''
    static dispatch def toValEntry(Void value) '''?''' // if value is null
    
    static dispatch def toSerializedValue(Polygon x) {return x.toString}
    static dispatch def toSerializedValue(Object x) {x}
    static dispatch def toSerializedValue(Void x) {x}

    def updateTile(Tile tile) {
        
        // we store only non-transient fields
        val nonTransientFields = Tile.declaredFields.filter[!Modifier.isTransient(modifiers)]
        nonTransientFields.forEach[accessible = true]
        
        val stmt = conn.prepareStatement('''
        REPLACE INTO tiles («nonTransientFields.map[name].join(", ")»)
        VALUES («nonTransientFields.map[get(tile).toValEntry].join(", ")»)
        ''', Statement.RETURN_GENERATED_KEYS)

        nonTransientFields.forEach[field, paramIndex |
            stmt.setObject(paramIndex + 1, field.get(tile).toSerializedValue)
        ]
        stmt.execute
        
        // keys are generated e.g. when adding new Tile to database
        val rs = stmt.generatedKeys
        rs.next
        val tileidGen = rs.getLong(1)
        
        conn.commit
        
        return tileidGen
    }
    
//    def Tile prepareEmptyTile(String newUri) {
//        new Tile => [
//            tileid = 0
//            uri = newUri
//            transid = 1 // TODO: transformation id should be registered and deregistered properly
//            ts_idx = new Timestamp(Calendar.getInstance.time.time) // NOW
//            ts = ts_idx
//            update_past = ts_idx
//        ]
//    }
    
    def Tile createNewTile(String newUri) {
        new Tile => [
            tileid = 0
            uri = newUri
            transid = 1 // TODO: transformation id should be registered and deregistered properly
            ts_idx = new Timestamp(Calendar.getInstance.time.time) // NOW
            ts = ts_idx
            update_past = ts_idx
            
            tileid = updateTile(it)
        ]
    }
    
    
    @Test
    def void testTileUpdate() {
        
        val db = new TileDb
        val tile1 = db.getTileById(1)
        
        Assert.assertNotNull(tile1)
        Assert.assertTrue(tile1 instanceof Tile)
        
        tile1.pixel_mean = tile1.pixel_mean + 1
        
        db.updateTile(tile1)
        
        val tile2 = db.getTileById(1)
        Assert.assertEquals(tile1, tile2)
    }
    
//    @Test
//    def void testPrepareEmptyTile() {
//        val db = new TileDb
//        val tile = db.prepareEmptyTile("dummy")
//        Assert.assertEquals(0, tile.tileid)
//        
//        tile.tileid = db.updateTile(tile)
//        Assert.assertTrue(tile.tileid > 0)
//        
//        println(tile)
//    }

    @Test
    def void testCreateNewTile() {
        val db = new TileDb
        val tile = db.createNewTile("dummy")
        Assert.assertTrue(tile.tileid > 0)
        println(tile)
    }

}

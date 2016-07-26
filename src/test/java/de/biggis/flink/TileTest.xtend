package de.biggis.flink

import java.math.BigInteger
import java.sql.Timestamp
import java.util.Calendar
import org.junit.Assert
import org.junit.Test

class GeometryTest {
    @Test def void testGeometryEquals() {
        val g1 = new Geometry
        val g2 = new Geometry
        Assert.assertNotSame(g1, g2)
        Assert.assertEquals(g1, g2)

        val g3 = new Geometry("dummy")
        val g4 = new Geometry("dummy2")
        Assert.assertNotSame(g3, g4)
        Assert.assertFalse(g3.equals(g4))
    }
}

class TileTest {
    
    val NOW = new Timestamp(Calendar.getInstance.time.time)
    
    @Test def void testSetFieldByName() {
        val tile = new Tile
        Assert.assertNull(tile.uri)
        
        tile.setFieldByName("uri", "some uri")
        Assert.assertEquals(tile.uri, "some uri")
        
        tile.setFieldByName("uri", null)
        Assert.assertNull(tile.uri)
        
        // integer value
        tile.setFieldByName("tileid", 15)
        Assert.assertEquals(tile.tileid, 15)
        
        // big value (converted inside Tile to long)
        tile.setFieldByName("tileid", BigInteger.valueOf(18))
        Assert.assertEquals(tile.tileid, 18)        

        // timestamp
        Assert.assertNull(tile.ts)
        tile.setFieldByName("ts", NOW)
        Assert.assertEquals(tile.ts, NOW)
        
        // geometry
        val polygonStr = "polygon((0 0, 1 0, 1 1, 0 0))"
        val polygonGeom = new Geometry(polygonStr)
        
        // geometry (extent)
        Assert.assertNull(tile.extent)
        tile.setFieldByName("extent", polygonStr)
        Assert.assertEquals(tile.extent, polygonGeom)
        tile.setFieldByName("extent", polygonGeom)
        Assert.assertEquals(tile.extent, polygonGeom)

        // geometry (update_area)
        Assert.assertNull(tile.update_area)
        tile.setFieldByName("update_area", polygonStr)
        Assert.assertEquals(tile.update_area, polygonGeom)
        tile.setFieldByName("update_area", polygonGeom)
        Assert.assertEquals(tile.update_area, polygonGeom)
    }
}

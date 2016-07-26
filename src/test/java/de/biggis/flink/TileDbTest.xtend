package de.biggis.flink

import org.junit.Assert
import org.junit.Before
import org.junit.Test

class TileDbTest {
    
    val db = new TileDb
    
    @Before def void init() {
        val tile1 = new Tile
        
        tile1.tileid = 1
        tile1.transid = 1 // TODO: dummy transid
        tile1.uri = "db record for testing"
        
        db.updateTile(tile1)
    }
    
    @Test
    def void testCreateNewTile() {
        val tile = db.createNewTile("dummy")
        Assert.assertTrue(tile.tileid > 0)
        // println(tile)
    }

    @Test
    def void testTileUpdate() {
        val tile1 = db.getTileById(1)
        Assert.assertNotNull(tile1)
        
        tile1.pixel_mean = tile1.pixel_mean + 1
        println(tile1)
        db.updateTile(tile1)
        
        val tile2 = db.getTileById(1)
        Assert.assertEquals(tile1, tile2)
    }
}
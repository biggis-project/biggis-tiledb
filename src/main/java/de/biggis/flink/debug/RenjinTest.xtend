package de.biggis.flink.debug

import javax.script.ScriptEngineManager

@Deprecated
class RenjinTest {
    def static void main(String[] args) {
        val manager = new ScriptEngineManager
        val engine = manager.getEngineByName("Renjin")
        if (engine == null) {
            throw new RuntimeException("Renjin Script Engine not found on the classpath.")
        }
        
        // TODO: raster package currently does not work in renjin
        engine.eval("library(raster)")
        engine.eval("r <- raster('/home/vlx/Work/biggis/biggis-tiledb/data/tiles/evening_EPSG_31467_tile_4_6.tif')")
        engine.eval("print(r)")
    }
}

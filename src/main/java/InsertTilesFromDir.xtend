import java.io.File
import java.sql.DriverManager
import org.apache.commons.io.FileUtils
import org.gdal.gdal.gdal

class InsertTilesFromDir {
	def static void main(String[] args) {

		InsertSampleData.classLoader.loadClass("com.mysql.jdbc.Driver")
		
		// STEP 3: Open a connection
		println("Connecting to database...")
		val conn = DriverManager.getConnection("jdbc:mysql://localhost:32770/tiledb", "root", "test")

		// STEP 4: Execute a query
		println("Creating statement...")
		val stmt = conn.createStatement

		// deleting all tiles
		stmt.executeUpdate("delete from tiles")
		
		gdal.AllRegister
		println(gdal.VersionInfo)
		//osr
		
		// inserting tiles from directory
		// assuming they are already from the grid
		FileUtils
			.listFiles( new File("data/tiles"), #["tif"], false)
			.forEach[ file, tileid |
				
				val tile = gdal.Open(file.toString)

				// closure for computing X-coordinate of a pixel
				val transx = [int x|
					val gt = tile.GetGeoTransform
					val ulx = gt.get(0)
					val xres = gt.get(1)
					ulx + x * xres
				]
				
				// closure for computing Y-coordinate of a pixel
				val transy = [int y|
					val gt = tile.GetGeoTransform
					val uly = gt.get(3)
					val yres = gt.get(5)
					uly + y * yres
				]
				
				val sx = tile.rasterXSize
				val sy = tile.rasterYSize
				
				val topleft = '''«transx.apply(0)» «transy.apply(0)»'''
				val topright = '''«transx.apply(sx)» «transy.apply(0)»'''
				val bottomright = '''«transx.apply(sx)» «transy.apply(sy)»'''
				val bottomleft = '''«transx.apply(0)» «transy.apply(sy)»'''
					
				println('''
				File: «file.toString»
				Driver: «tile.GetDriver.GetDescription»
				X-size: «tile.rasterXSize»
				Y-size: «tile.rasterYSize»
				Metadata:
				  «FOR m:tile.GetMetadata_Dict.keySet»
				  «m» = "«tile.GetMetadataItem(m.toString)»"
				  «ENDFOR»
				''')
				
				val sql = '''
					insert into tiles (tileid, fname, extent, update_area, ts, ts_idx) values
					(«tileid», "«file.toString»",
					ST_PolygonFromText('polygon(( «topleft», «topright», «bottomright», «bottomleft», «topleft» ))'),
					ST_PolygonFromText('polygon(( «topleft», «topright», «bottomright», «bottomleft», «topleft» ))'),
					"«tile.GetMetadataItem("TIFFTAG_DATETIME")»",
					"«tile.GetMetadataItem("TIFFTAG_DATETIME")»")
				'''
				
				println(sql)
				stmt.executeUpdate(sql)
			]

		// cleanup
		stmt.close
		conn.close
		
	}
}

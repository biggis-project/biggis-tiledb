package de.biggis.tools

import java.sql.DriverManager

class CreateTileDB {
    def static void main(String[] args) {

        // Register JDBC driver (safer way than Class.forName)
        CreateTileDB.classLoader.loadClass("com.mysql.jdbc.Driver")

        // Open a connection
        println("Connecting to database...")
        val conn = DriverManager.getConnection("jdbc:mysql://localhost:3306", "root", "test")

        // Execute a query
        println("Creating statement...")
        val stmt = conn.createStatement

        // Deleting all tiles from database
        stmt.executeUpdate("DROP DATABASE IF EXISTS tiledb;")
        stmt.executeUpdate("create database tiledb;")

        stmt.executeUpdate('''
            CREATE TABLE tiledb.transforms (
              transid SERIAL PRIMARY KEY,
              params BLOB DEFAULT NULL COMMENT "serialized parameters"
            );
        ''')

        stmt.executeUpdate('''
            CREATE TABLE tiledb.tiles (
              tileid SERIAL PRIMARY KEY, -- COMMENT "generated and relevant only for internal db purposes", 
              
             -- to use larger indexes, run the following sql: SET @@global.innodb_large_prefix = 1;
              uri VARCHAR(200) UNIQUE NOT NULL COMMENT "assuming URI = URL = filename",
              extent GEOMETRY COMMENT "the map extent of this tile",
            
              -- the tile has to be regenerated if something within update_area
              -- and in a time frame between now and update_past
              update_area GEOMETRY COMMENT "geometry  used for update detection",
              update_past TIMESTAMP COMMENT "timespan used for update detection",
            
              ts TIMESTAMP COMMENT "time dimension of the tile",
              ts_idx TIMESTAMP COMMENT "when the tile was indexed",
            
              transid BIGINT UNSIGNED NOT NULL
              COMMENT "reference to the transformation that produced this tile",
              FOREIGN KEY (transid) REFERENCES tiledb.transforms(transid) ON DELETE CASCADE,
              
              pixel_mean double not null default 0 COMMENT "mean value computed from all pixels in the tile",
              pixel_stdev double not null default 0 COMMENT "standard deviation computed from all pixels in the tile"
            );
        ''')

        // cleanup
        stmt.close
        conn.close

        println("done")
    }
}

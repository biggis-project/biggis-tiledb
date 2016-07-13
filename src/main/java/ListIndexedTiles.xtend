import java.sql.DriverManager

class ListIndexedTiles {
    def static void main(String[] args) {
        
        // Register JDBC driver (safer way than Class.forName)
        ListIndexedTiles.classLoader.loadClass("com.mysql.jdbc.Driver")

        // Open a connection (expecting a dockerized MySQL instance that is available on port 32770)
        println("Connecting to database...")
        val conn = DriverManager.getConnection("jdbc:mysql://localhost:32770/tiledb", "root", "test")

        // Execute a query
        println("Creating statement...")
        val stmt = conn.createStatement

        val rs = stmt.executeQuery("select tileid, astext(extent) as extent, fname from tiles")

        while (rs.next) {
            println('''
                ID: «rs.getInt("tileid")»
                  - «rs.getString("extent")»
                  - «rs.getString("fname")»
            ''')
        }

        // Cleanup
        rs.close
        stmt.close
        conn.close
    }
}

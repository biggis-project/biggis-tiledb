import java.sql.DriverManager

class ListIndexedTiles {
    def static void main(String[] args) {
        // STEP 2: Register JDBC driver
        Class.forName("com.mysql.jdbc.Driver");

        // STEP 3: Open a connection
        println("Connecting to database...")
        val conn = DriverManager.getConnection("jdbc:mysql://localhost:32770/tiledb", "root", "test")

        // STEP 4: Execute a query
        println("Creating statement...")
        val stmt = conn.createStatement

        val rs = stmt.executeQuery("select tileid, astext(extent) as extent, fname from tiles")

        while (rs.next) {
            println("ID: " + rs.getInt("tileid"))
            println(" - " + rs.getString("extent"))
            println(" - " + rs.getString("fname"))
        }

        // cleanup
        rs.close
        stmt.close
        conn.close
    }
}

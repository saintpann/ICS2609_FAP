package tools;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.servlet.ServletContext;

public class DatabaseManager {

    public static Connection getConnection(ServletContext context, String dbName) throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
            
            // Fetch parameters dynamically based on the dbName passed in
            String url = context.getInitParameter(dbName + "_URL");
            String user = context.getInitParameter(dbName + "_USER");
            String pass = context.getInitParameter(dbName + "_PASS");
            
            return DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException e) {
            throw new SQLException("PostgreSQL Driver not found.", e);
        }
    }
}
package tools;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class DataSeeder {

    private static Connection getConnection() throws SQLException, NamingException {
        Context initContext = new InitialContext();
        Context envContext = (Context) initContext.lookup("java:comp/env");
        DataSource ds = (DataSource) envContext.lookup("jdbc/UserDB");
        return ds.getConnection();
    }

    // New helper method to ensure the table physically exists in the GlassFish database
    private static void createTableIfNotExists(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            DatabaseMetaData dbm = conn.getMetaData();
            // Derby stores table names in UPPERCASE
            try (ResultSet tables = dbm.getTables(null, null, "USERS", null)) {
                if (!tables.next()) {
                    System.out.println("USERS table not found. Creating it dynamically...");
                    String createSQL = "CREATE TABLE USERS ("
                            + "uname VARCHAR(50) NOT NULL, "
                            + "pass VARCHAR(255) NOT NULL, "
                            + "role VARCHAR(20) NOT NULL, "
                            + "PRIMARY KEY (uname))";
                    stmt.executeUpdate(createSQL);
                    System.out.println("USERS table created successfully.");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error verifying/creating USERS table:");
            e.printStackTrace();
        }
    }

    public static String seedDatabase(String secretKey, String algo, String mode, String padding) {
        
        String insertQuery = "INSERT INTO USERS(uname, pass, role) VALUES (?, ?, ?)";
        
        try (Connection conn = getConnection()) {
            
            // 1. Force table creation before trying to insert data
            createTableIfNotExists(conn);
            
            try (PreparedStatement pstmt = conn.prepareStatement(insertQuery)) {
                Cryptograph crypt = new Cryptograph(secretKey, algo, mode, padding);
                
                String defaultPassword = "password123";
                String encryptedDefaultPassword = crypt.encrypt(defaultPassword);

                int count = 0;

                for (int i = 1; i <= 3; i++) {
                    pstmt.setString(1, "admin" + i);
                    pstmt.setString(2, encryptedDefaultPassword); 
                    pstmt.setString(3, "Admin");
                    pstmt.addBatch();
                    count++;
                }

                for (int i = 1; i <= 50; i++) {
                    pstmt.setString(1, "student" + i);
                    pstmt.setString(2, encryptedDefaultPassword); 
                    pstmt.setString(3, "Student");
                    pstmt.addBatch();
                    count++;
                }

                int[] results = pstmt.executeBatch();
                return "SUCCESS: Seeded " + results.length + " users into Derby. Default password is 'password123'.";
            }
            
        } catch (SQLException | NamingException e) {
            e.printStackTrace();
            return "ERROR: Database connection or execution failed. Check server logs.";
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR: Cryptography initialization failed.";
        }
    }
}
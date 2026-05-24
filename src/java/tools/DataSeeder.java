package tools;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletContext;
import tools.Cryptograph;

public class DataSeeder {

    // Helper method to connect to Derby using web.xml parameters
    private static Connection getConnection(ServletContext context) throws SQLException, ClassNotFoundException {
        Class.forName("org.apache.derby.jdbc.ClientDriver");
        String url = context.getInitParameter("DerbyURL");
        String user = context.getInitParameter("DerbyUser");
        String pass = context.getInitParameter("DerbyPass");
        return DriverManager.getConnection(url, user, pass);
    }

    // 2. The Seeding Logic (Now accepts ServletContext)
    public static String seedDatabase(ServletContext context, String secretKey, String algo, String mode, String padding) {
        
        String insertQuery = "INSERT INTO Users (uname, pass, role) VALUES (?, ?, ?)";
        
        // try-with-resources handles fetching from the DriverManager and securely closing it
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(insertQuery)) {

            // Initialize Cryptograph with the parameters passed from the Servlet
            Cryptograph crypt = new Cryptograph(secretKey, algo, mode, padding);
            
            // Encrypt the default password
            String defaultPassword = "password123";
            String encryptedDefaultPassword = crypt.encrypt(defaultPassword);

            int count = 0;

            // Seed 3 Admin Users
            for (int i = 1; i <= 3; i++) {
                pstmt.setString(1, "admin" + i);
                pstmt.setString(2, encryptedDefaultPassword); 
                pstmt.setString(3, "Admin");
                pstmt.addBatch();
                count++;
            }

            // Seed 50 Student Users
            for (int i = 1; i <= 50; i++) {
                pstmt.setString(1, "student" + i);
                pstmt.setString(2, encryptedDefaultPassword); 
                pstmt.setString(3, "Student");
                pstmt.addBatch();
                count++;
            }

            // Execute the batch
            int[] results = pstmt.executeBatch();
            return "SUCCESS: Seeded " + results.length + " users into Derby. Default password is 'password123'.";

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return "ERROR: Database connection or execution failed. Check server logs.";
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR: Cryptography initialization failed.";
        }
    }
}
package tools;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import tools.Cryptograph;

public class DataSeeder {

    // 1. The JNDI Connection Method (Same as your UserDAO)
    private static Connection getConnection() throws SQLException, NamingException {
        Context initContext = new InitialContext();
        Context envContext = (Context) initContext.lookup("java:comp/env");
        DataSource ds = (DataSource) envContext.lookup("jdbc/UserDB");
        return ds.getConnection();
    }

    // 2. The Seeding Logic
    public static String seedDatabase(String secretKey, String algo, String mode, String padding) {
        
        String insertQuery = "INSERT INTO USERS(uname, pass, role) VALUES (?, ?, ?)";
        
        // try-with-resources handles fetching from the pool and returning it
        try (Connection conn = getConnection();
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

        } catch (SQLException | NamingException e) {
            e.printStackTrace();
            return "ERROR: Database connection or execution failed. Check server logs.";
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR: Cryptography initialization failed.";
        }
    }
}
package tools;

import java.sql.*;
import javax.naming.*;
import javax.sql.DataSource;

public class DataSeeder {

    // Connection for UserDB (Derby)
    private static Connection getUserDBConnection() throws SQLException, NamingException {
        Context initContext = new InitialContext();
        Context envContext = (Context) initContext.lookup("java:comp/env");
        DataSource ds = (DataSource) envContext.lookup("jdbc/UserDB");
        return ds.getConnection();
    }

    // Connection for ExamDB (PostgreSQL)
    private static Connection getExamDBConnection() throws SQLException, NamingException {
        Context initContext = new InitialContext();
        Context envContext = (Context) initContext.lookup("java:comp/env");
        DataSource ds = (DataSource) envContext.lookup("jdbc/ExamDB");
        return ds.getConnection();
    }

    /**
     * Initializes the ExamDB tables and seeds initial course data
     */
    public static String initializeExamDB() {
    try (Connection conn = getExamDBConnection();
         Statement stmt = conn.createStatement()) {
        
        DatabaseMetaData dbm = conn.getMetaData();
        
        // 1. Create Courses Table
        try (ResultSet tables = dbm.getTables(null, null, "COURSES", null)) {
            if (!tables.next()) {
                String sql = "CREATE TABLE COURSES ("
                        + "course_id SERIAL PRIMARY KEY, "
                        + "course_name VARCHAR(100) NOT NULL, "
                        + "description TEXT)";
                stmt.execute(sql);
                System.out.println("COURSES table created.");
            }
        }

        // 2. Create Questions Table
        try (ResultSet tables = dbm.getTables(null, null, "QUESTIONS", null)) {
            if (!tables.next()) {
                String sql = "CREATE TABLE QUESTIONS ("
                        + "question_id SERIAL PRIMARY KEY, "
                        + "course_id INT, " // Removed REFERENCES for compatibility
                        + "question_text TEXT NOT NULL, "
                        + "questions_choices TEXT NOT NULL, "
                        + "question_answer VARCHAR(255) NOT NULL)";
                stmt.execute(sql);
                System.out.println("QUESTIONS table created.");
            }
        }
        
        return "SUCCESS: ExamDB initialized.";
    } catch (SQLException | NamingException e) {
        e.printStackTrace();
        return "ERROR: ExamDB initialization failed: " + e.getMessage();
    }
}

    /**
     * Original Derby Seeding Logic
     */
    public static String seedUserDB(String secretKey, String algo, String mode, String padding) {
        String insertQuery = "INSERT INTO USERS(uname, pass, role) VALUES (?, ?, ?)";
        
        try (Connection conn = getUserDBConnection()) {
            // Existing table creation logic
            try (Statement stmt = conn.createStatement()) {
                DatabaseMetaData dbm = conn.getMetaData();
                try (ResultSet tables = dbm.getTables(null, null, "USERS", null)) {
                    if (!tables.next()) {
                        stmt.executeUpdate("CREATE TABLE USERS (uname VARCHAR(50) PRIMARY KEY, pass VARCHAR(255) NOT NULL, role VARCHAR(20) NOT NULL)");
                    }
                }
            }
            
            // Proceed with insertion...
            // (Keep your original loop logic here)
            return "SUCCESS: UserDB seeded.";
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR: UserDB seeding failed.";
        }
    }
}
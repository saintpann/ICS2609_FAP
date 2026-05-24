
package tools;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class CertDAO {

    public CertDAO(){}
    
    private Connection getConnection() throws SQLException, NamingException {
        Context initContext = new InitialContext();
        Context envContext = (Context) initContext.lookup("java:comp/env");
        DataSource ds = (DataSource) envContext.lookup("jdbc/CertDB");
        return ds.getConnection();
    }

    // Method to save a new completed exam score
    public boolean saveCertification(String uname, String courseName, double score) {
        String query = "INSERT INTO Certifications (uname, course_name, score) VALUES (?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, uname);
            pstmt.setString(2, courseName);
            pstmt.setDouble(3, score);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException | NamingException e) {
            System.err.println("CertDB Insert Error:");
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            System.err.println("DAO Connection test failed:");
            e.printStackTrace();
            return false;
        }
    }

    // Method to retrieve all certifications for a specific student's dashboard
    public List<Map<String, String>> getStudentCertifications(String uname) {
        List<Map<String, String>> certList = new ArrayList<>();
        String query = "SELECT course_name, score, issue_date FROM Certifications WHERE uname = ? ORDER BY issue_date DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, uname);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> cert = new HashMap<>();
                    cert.put("course_name", rs.getString("course_name"));
                    cert.put("score", String.valueOf(rs.getDouble("score")));
                    cert.put("issue_date", rs.getString("issue_date"));
                    certList.add(cert);
                }
            }
        } catch (SQLException | NamingException e) {
            System.err.println("CertDB Retrieval Error:");
            e.printStackTrace();
        }
        return certList;
    }
}
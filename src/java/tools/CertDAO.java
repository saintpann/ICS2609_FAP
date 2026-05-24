
package tools;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.sql.DataSource;

public class CertDAO {

    public CertDAO(){}
    
    private Connection getConnection(ServletContext context) throws SQLException, ClassNotFoundException {
    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = context.getInitParameter("CertDBURL");
    String user = context.getInitParameter("CertDBUser");
    String pass = context.getInitParameter("CertDBPass");
    return DriverManager.getConnection(url, user, pass);
    }

    // Method to save a new completed exam score
    public boolean saveCertification(ServletContext context,String uname, String courseName, double score) {
        String query = "INSERT INTO Certifications (uname, course_name, score) VALUES (?, ?, ?)";
        
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, uname);
            pstmt.setString(2, courseName);
            pstmt.setDouble(3, score);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("CertDB Insert Error:");
            e.printStackTrace();
            return false;
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(CertDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
        
    }
    
    public boolean testConnection(ServletContext context) {
        try (Connection conn = getConnection(context)) {
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            System.err.println("DAO Connection test failed:");
            e.printStackTrace();
            return false;
        }
    }

    // Method to retrieve all certifications for a specific student's dashboard
    public List<Map<String, String>> getStudentCertifications(ServletContext context, String uname) {
        List<Map<String, String>> certList = new ArrayList<>();
        String query = "SELECT course_name, score, issue_date FROM Certifications WHERE uname = ? ORDER BY issue_date DESC";
        
        try (Connection conn = getConnection(context);
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
        } catch (SQLException e) {
            System.err.println("CertDB Retrieval Error:");
            e.printStackTrace();
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(CertDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return certList;
    }
    // Method to fetch all certifications within a specific date range for the Admin Report
    public List<Map<String, String>> getCertificationsByDate(javax.servlet.ServletContext context, String startDate, String endDate) {
        List<Map<String, String>> certList = new ArrayList<>();
        // Query filters by issue_date
        String query = "SELECT uname, course_code, score, issue_date FROM Certifications WHERE issue_date >= ? AND issue_date <= ? ORDER BY issue_date DESC";
        
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            // Append times to make the search inclusive for the entire start and end days
            pstmt.setString(1, startDate + " 00:00:00");
            pstmt.setString(2, endDate + " 23:59:59");
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> cert = new HashMap<>();
                    cert.put("uname", rs.getString("uname"));
                    cert.put("course_code", rs.getString("course_code"));
                    cert.put("score", String.valueOf(rs.getDouble("score")));
                    cert.put("issue_date", rs.getString("issue_date"));
                    certList.add(cert);
                }
            }
        } catch (Exception e) {
            System.err.println("CertDB Date Retrieval Error:");
            e.printStackTrace();
        }
        return certList;
    }
}
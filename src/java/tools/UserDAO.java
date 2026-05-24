package tools;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList; // Added import
import java.util.List;      // Added import
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.sql.DataSource;

public class UserDAO {

    private Connection getConnection(ServletContext context) throws SQLException, ClassNotFoundException {
    Class.forName("org.apache.derby.jdbc.ClientDriver");
    String url = context.getInitParameter("DerbyURL");
    String user = context.getInitParameter("DerbyUser");
    String pass = context.getInitParameter("DerbyPass");
    return DriverManager.getConnection(url, user, pass);
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

    public User authenticateUser(ServletContext context, String username, String password) {
        String query = "SELECT role FROM Users WHERE uname = ? AND pass = ?";
        
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    // Construct and return the User object
                    return new User(username, role); 
                }
            }
        } catch (Exception e) {
            System.err.println("UserDB Authentication Error:");
            e.printStackTrace();
        }
        
        // Return null if authentication fails
        return null; 
    }

    // fetches users for Report
    public java.util.List<User> getAllUsers(javax.servlet.ServletContext context) {
        java.util.List<User> users = new java.util.ArrayList<>();
        String query = "SELECT uname, role FROM Users ORDER BY role ASC, uname ASC";
        
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                User u = new User();
                u.setUsername(rs.getString("uname"));
                u.setRole(rs.getString("role"));
                users.add(u);
            }
        } catch (Exception e) {
            System.err.println("UserDB Directory Retrieval Error:");
            e.printStackTrace();
        }
        return users;
    }
    
}
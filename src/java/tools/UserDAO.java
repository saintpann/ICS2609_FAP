package tools;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletContext;

public class UserDAO {

    // Helper method for Derby Connection
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

    // =====================================================================
    // MODULE 1: AUTHENTICATION & ONBOARDING
    // =====================================================================

    public User authenticateUser(ServletContext context, String username, String password) {
        String query = "SELECT role FROM Users WHERE uname = ? AND pass = ?";
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    User u = new User(username, role); 
                    u.setPassword(password); // Required for Self-Report PDF
                    return u; 
                }
            }
        } catch (Exception e) {
            System.err.println("UserDB Authentication Error:");
            e.printStackTrace();
        }
        return null; 
    }

    // Check if a user already exists to prevent duplicate registrations
    public boolean userExists(ServletContext context, String username) {
        String query = "SELECT uname FROM Users WHERE uname = ?";
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            System.err.println("UserDB Check Error:");
            e.printStackTrace();
            return true; 
        }
    }

    // Insert a brand new user (Used by Sign-Up & Admin CRUD)
    public boolean registerUser(ServletContext context, String username, String encryptedPassword, String role) {
        String query = "INSERT INTO Users (uname, pass, role) VALUES (?, ?, ?)";
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, username);
            pstmt.setString(2, encryptedPassword);
            pstmt.setString(3, role);
            
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("UserDB Registration Error:");
            e.printStackTrace();
            return false;
        }
    }

    // =====================================================================
    // MODULE 2 & 3: DIRECTORY & ADMIN CRUD
    // =====================================================================

    // Fetches all users for the Directory and Master PDF Report
    public List<User> getAllUsers(ServletContext context) {
        List<User> users = new ArrayList<>();
        String query = "SELECT uname, pass, role FROM Users ORDER BY role ASC, uname ASC";
        
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                User u = new User();
                u.setUsername(rs.getString("uname"));
                u.setPassword(rs.getString("pass")); 
                u.setRole(rs.getString("role"));
                users.add(u);
            }
        } catch (Exception e) {
            System.err.println("UserDB Directory Retrieval Error:");
            e.printStackTrace();
        }
        return users;
    }

    // Updates a user's password (Used by Settings & Admin Reset)
    public boolean updatePassword(ServletContext context, String username, String newEncryptedPassword) {
        String query = "UPDATE Users SET pass = ? WHERE uname = ?";
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, newEncryptedPassword);
            pstmt.setString(2, username);
            
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("UserDB Update Password Error:");
            e.printStackTrace();
            return false;
        }
    }

    // Completely removes a user identity from Derby
    public boolean deleteUser(ServletContext context, String username) {
        String query = "DELETE FROM Users WHERE uname = ?";
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, username);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("UserDB Delete Error:");
            e.printStackTrace();
            return false;
        }
    }

    // Updates a user's system role (Admin to Student, etc.)
    public boolean updateUserRole(ServletContext context, String username, String newRole) {
        String query = "UPDATE Users SET role = ? WHERE uname = ?";
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, newRole);
            pstmt.setString(2, username);
            
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("UserDB Update Role Error:");
            e.printStackTrace();
            return false;
        }
    }
}
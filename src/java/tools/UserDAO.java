package tools;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList; // Added import
import java.util.List;      // Added import
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class UserDAO {

    private Connection getConnection() throws SQLException, NamingException {
        Context initContext = new InitialContext();
        Context envContext = (Context) initContext.lookup("java:comp/env");
        DataSource ds = (DataSource) envContext.lookup("jdbc/UserDB");
        return ds.getConnection();
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

    public String authenticateAndGetRole(String inputUname, String encryptedAttempt) {
        String query = "SELECT pass, role FROM Users WHERE uname = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, inputUname);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String encryptedDbPass = rs.getString("pass");
                    
                    if (encryptedDbPass.equals(encryptedAttempt)) {
                        return rs.getString("role");
                    }
                }
            }
        } catch (SQLException | NamingException e) {
            System.err.println("UserDB Authentication Error:");
            e.printStackTrace();
        }
        return null; 
    }

    // fetches users for Report
    public List<String[]> getAllUsers() {
        List<String[]> userList = new ArrayList<>();
        String query = "SELECT id, uname, role FROM Users";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                String[] user = new String[3];
                
                try {
                    user[0] = rs.getString("id"); 
                } catch (SQLException e) {
                    user[0] = "N/A"; // if no id column exists
                }
                
                user[1] = rs.getString("uname");
                user[2] = rs.getString("role");
                
                userList.add(user);
            }
            
        } catch (SQLException | NamingException e) {
            System.err.println("UserDB Retrieval Error (getAllUsers):");
            e.printStackTrace();
        }
        
        return userList;
    }
}
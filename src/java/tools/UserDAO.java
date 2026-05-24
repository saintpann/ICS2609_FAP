
package tools;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
}
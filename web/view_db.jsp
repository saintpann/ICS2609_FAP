<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, javax.naming.*, javax.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>Database Viewer</title></head>
<body style="font-family: monospace; padding: 20px;">
    <h2>Live UserDB Data</h2>
    <table border="1" cellpadding="5">
        <tr><th>Username</th><th>Role</th><th>Encrypted Password</th></tr>
        <%
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            try {
                Context initContext = new InitialContext();
                Context envContext = (Context) initContext.lookup("java:comp/env");
                DataSource ds = (DataSource) envContext.lookup("jdbc/UserDB");
                
                conn = ds.getConnection();
                stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT * FROM USERS");
                     
                while(rs.next()) {
        %>
                    <tr>
                        <td><%= rs.getString("uname") %></td>
                        <td><%= rs.getString("role") %></td>
                        <td><%= rs.getString("pass") %></td>
                    </tr>
        <%      }
            } catch(Exception e) {
                out.println("<tr><td colspan='3'>Error: " + e.getMessage() + "</td></tr>");
            } finally {
                // Classic Java 1.5 resource closing
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (stmt != null) try { stmt.close(); } catch(SQLException e) {}
                if (conn != null) try { conn.close(); } catch(SQLException e) {}
            }
        %>
    </table>
</body>
</html>
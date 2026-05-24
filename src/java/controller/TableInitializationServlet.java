package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.SQLException;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class TableInitializationServlet extends HttpServlet {

    private Connection getDerbyConnection(ServletContext context) throws Exception {
        Class.forName("org.apache.derby.jdbc.ClientDriver");
        return DriverManager.getConnection(
            context.getInitParameter("DerbyURL"),
            context.getInitParameter("DerbyUser"),
            context.getInitParameter("DerbyPass")
        );
    }

    private Connection getPostgresConnection(ServletContext context) throws Exception {
        Class.forName("org.postgresql.Driver");
        return DriverManager.getConnection(
            context.getInitParameter("ExamDBURL"),
            context.getInitParameter("ExamDBUser"),
            context.getInitParameter("ExamDBPass")
        );
    }

    private Connection getMysqlConnection(ServletContext context) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(
            context.getInitParameter("CertDBURL"),
            context.getInitParameter("CertDBUser"),
            context.getInitParameter("CertDBPass")
        );
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        ServletContext context = getServletContext();
        
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html><head><title>Database Initialization</title>");
            out.println("<style>");
            out.println("body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f9; }");
            out.println(".status-box { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 750px; }");
            out.println(".success { color: #155724; background-color: #d4edda; border: 1px solid #c3e6cb; padding: 12px; border-radius: 4px; margin-bottom: 10px; }");
            out.println(".error { color: #721c24; background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 12px; border-radius: 4px; margin-bottom: 10px; }");
            out.println("</style></head><body>");
            out.println("<div class='status-box'><h2>Database Table Provisioning Engine</h2><hr>");

            // 1. Initialize Apache Derby (UserDB) using revised Identity Columns Layout
            try (Connection conn = getDerbyConnection(context);
                 Statement stmt = conn.createStatement()) {
                
                String derbySQL = "CREATE TABLE Users ("
                                + "id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, "
                                + "uname VARCHAR(50) UNIQUE NOT NULL, "
                                + "pass VARCHAR(255) NOT NULL, "
                                + "role VARCHAR(20) NOT NULL"
                                + ")";
                stmt.executeUpdate(derbySQL);
                out.println("<div class='success'>✅ <strong>Derby (UserDB):</strong> Connected! Identity table 'Users' generated successfully.</div>");
                
            } catch (SQLException e) {
                // 'X0Y32' is the specific SQL State error code for "Table Already Exists" in Apache Derby
                if ("X0Y32".equals(e.getSQLState())) {
                    out.println("<div class='success'>ℹ️ <strong>Derby (UserDB):</strong> Connected! Table 'Users' already exists.</div>");
                } else {
                    out.println("<div class='error'>❌ <strong>Derby Error:</strong> " + e.getMessage() + " (State: " + e.getSQLState() + ")</div>");
                }
            } catch (Exception e) {
                out.println("<div class='error'>❌ <strong>Derby Connection Failure:</strong> " + e.getMessage() + "</div>");
            }

            // 2. Initialize PostgreSQL (ExamDB)
            try (Connection conn = getPostgresConnection(context);
                 Statement stmt = conn.createStatement()) {
                
                String pgCoursesSQL = "CREATE TABLE IF NOT EXISTS Courses ("
                                    + "course_id SERIAL PRIMARY KEY, "
                                    + "course_code VARCHAR(50) UNIQUE NOT NULL, "
                                    + "course_title VARCHAR(100) NOT NULL, "
                                    + "description TEXT"
                                    + ")";
                stmt.executeUpdate(pgCoursesSQL);
                
                String pgQuestionsSQL = "CREATE TABLE IF NOT EXISTS Questions ("
                                      + "question_id SERIAL PRIMARY KEY, "
                                      + "course_id INT NOT NULL, "
                                      + "question_text TEXT NOT NULL, "
                                      + "correct_answer VARCHAR(255) NOT NULL, "
                                      + "CONSTRAINT fk_course FOREIGN KEY(course_id) REFERENCES Courses(course_id) ON DELETE CASCADE"
                                      + ")";
                stmt.executeUpdate(pgQuestionsSQL);
                
                out.println("<div class='success'>✅ <strong>PostgreSQL (ExamDB):</strong> Connected! Relational tables 'Courses' and 'Questions' are initialized.</div>");
                
            } catch (Exception e) {
                out.println("<div class='error'>❌ <strong>PostgreSQL Error:</strong> " + e.getMessage() + "</div>");
            }

            // 3. Initialize MySQL (CertDB)
            try (Connection conn = getMysqlConnection(context);
                 Statement stmt = conn.createStatement()) {
                
                String mysqlSQL = "CREATE TABLE IF NOT EXISTS Certifications ("
                                + "cert_id INT AUTO_INCREMENT PRIMARY KEY, "
                                + "uname VARCHAR(50) NOT NULL, "
                                + "course_code VARCHAR(50) NOT NULL, "
                                + "score DECIMAL(5,2) NOT NULL, "
                                + "issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                                + "INDEX idx_student (uname)"
                                + ")";
                stmt.executeUpdate(mysqlSQL);
                out.println("<div class='success'>✅ <strong>MySQL (CertDB):</strong> Connected! Table 'Certifications' optimized with indices successfully.</div>");
                
            } catch (Exception e) {
                out.println("<div class='error'>❌ <strong>MySQL Error:</strong> " + e.getMessage() + "</div>");
            }

            out.println("<br><p>Tables verified. You can now execute the database content hydration routine via <a href='seed'><strong>/seed</strong></a>.</p>");
            out.println("</div></body></html>");
        }
    }
}
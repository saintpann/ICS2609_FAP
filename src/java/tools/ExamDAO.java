
package tools;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.sql.DataSource;

public class ExamDAO {

    private Connection getConnection(ServletContext context) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        String url = context.getInitParameter("ExamDBURL");
        String user = context.getInitParameter("ExamDBUser");
        String pass = context.getInitParameter("ExamDBPass");
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

    public List<String[]> getExamQuestions(ServletContext context, String courseName) {
        List<String[]> examData = new ArrayList<>();
        String query = "SELECT q.question_text, q.correct_answer " +
               "FROM Questions q " +
               "JOIN Courses c ON q.course_id = c.course_id " +
               "WHERE c.course_code = ?";
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
             
            pstmt.setString(1, courseName);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String[] qAndA = new String[2];
                    qAndA[0] = rs.getString("question_text");
                    qAndA[1] = rs.getString("correct_answer");
                    examData.add(qAndA);
                }
            }
            
        } catch (Exception e) {
            System.err.println("ExamDB Retrieval Error:");
            e.printStackTrace();
        }
        
        return examData;
    }
}
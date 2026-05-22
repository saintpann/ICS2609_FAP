
package tools;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class ExamDAO {

    private Connection getConnection() throws SQLException, NamingException {
        Context initContext = new InitialContext();
        Context envContext = (Context) initContext.lookup("java:comp/env");
        DataSource ds = (DataSource) envContext.lookup("jdbc/ExamDB");
        return ds.getConnection();
    }

    // Returns a List of String Arrays: Index 0 = Question, Index 1 = Correct Answer
    public List<String[]> getExamQuestions(String courseName) {
        List<String[]> examData = new ArrayList<>();
        String query = "SELECT question_text, correct_answer FROM Exam_Bank WHERE course_name = ?";

        try (Connection conn = getConnection();
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
            
        } catch (SQLException | NamingException e) {
            System.err.println("ExamDB Retrieval Error:");
            e.printStackTrace();
        }
        
        return examData;
    }
}
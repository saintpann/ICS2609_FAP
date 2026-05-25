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
import javax.servlet.ServletContext;

public class ExamDAO {

    private Connection getConnection(ServletContext context) throws SQLException, ClassNotFoundException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("\n[CRITICAL] PostgreSQL JDBC Driver (postgresql-42.x.jar) not found in WEB-INF/lib!\n");
            throw e;
        }
        
        // --- UPDATED TO TARGET YOUR EXAMDB PARAMETERS ---
        String url = context.getInitParameter("ExamDBURL");
        String user = context.getInitParameter("ExamDBUser");
        String pass = context.getInitParameter("ExamDBPass");
        
        return DriverManager.getConnection(url, user, pass);
    }

    public List<Map<String, String>> getAllCourses(ServletContext context) {
        List<Map<String, String>> courses = new ArrayList<>();
        String query = "SELECT course_id, course_code, course_title, description FROM Courses ORDER BY course_id ASC";
        
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, String> course = new HashMap<>();
                course.put("course_id", String.valueOf(rs.getInt("course_id")));
                course.put("course_code", rs.getString("course_code"));
                course.put("course_title", rs.getString("course_title"));
                course.put("description", rs.getString("description"));
                courses.add(course);
            }
        } catch (Exception e) {
            throw new RuntimeException("SQL ERROR in getAllCourses: " + e.getMessage(), e);
        }
        return courses;
    }

    public List<Map<String, String>> getQuestionsForCourse(ServletContext context, int courseId) {
        List<Map<String, String>> questions = new ArrayList<>();
        String query = "SELECT question_id, question_text FROM Questions WHERE course_id = ? ORDER BY question_id ASC";
        
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setInt(1, courseId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> q = new HashMap<>();
                    q.put("question_id", String.valueOf(rs.getInt("question_id")));
                    q.put("question_text", rs.getString("question_text"));
                    questions.add(q);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("SQL ERROR in getQuestionsForCourse: " + e.getMessage(), e);
        }
        return questions;
    }

    public double gradeExam(ServletContext context, int courseId, Map<Integer, String> userAnswers) {
        String query = "SELECT question_id, correct_answer FROM Questions WHERE course_id = ?";
        int totalQuestions = 0;
        int correctAnswers = 0;
        
        try (Connection conn = getConnection(context);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setInt(1, courseId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    totalQuestions++;
                    int qId = rs.getInt("question_id");
                    String dbAnswer = rs.getString("correct_answer");
                    
                    if (userAnswers.containsKey(qId)) {
                        String studentAnswer = userAnswers.get(qId);
                        // Case-insensitive check and removes accidental trailing spaces
                        if (studentAnswer != null && studentAnswer.trim().equalsIgnoreCase(dbAnswer.trim())) {
                            correctAnswers++;
                        }
                    }
                }
            }
            if (totalQuestions == 0) return 0.0;
            return ((double) correctAnswers / totalQuestions) * 100.0;
            
        } catch (Exception e) {
            throw new RuntimeException("SQL ERROR in gradeExam: " + e.getMessage(), e);
        }
    }
}
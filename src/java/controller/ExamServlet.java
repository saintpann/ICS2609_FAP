package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// Using the exact packages Member 2 created
import tools.ExamDAO;
import tools.CertDAO;

@WebServlet(name = "ExamServlet", urlPatterns = {"/takeExam"})
public class ExamServlet extends HttpServlet {

    // PHASE 1: THE EXAM CONTROLLER (Loading the Exam)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String courseId = request.getParameter("courseId");
        if (courseId == null) {
            courseId = "Java101"; 
        }

        try {
            // 1. Call Member 2's ExamDAO
            ExamDAO examDAO = new ExamDAO();
            
            // Member 2 returns a List of String arrays [Question, Answer]
            List<String[]> examData = examDAO.getExamQuestions(courseId);
            
            // 2. Pass the data to the UI
            // NOTE TO MEMBER 4: In your JSP loop, use ${item[0]} to print the question text!
            request.setAttribute("examQuestions", examData);
            request.setAttribute("courseId", courseId);

            // 3. Forward to the UI
            RequestDispatcher dispatcher = request.getRequestDispatcher("/take_exam.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database Error: Unable to load the exam.");
            request.getRequestDispatcher("/general_error.jsp").forward(request, response);
        }
    }

    // PHASE 2: GRADING LOGIC
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("uname") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String username = (String) session.getAttribute("uname");
        String courseId = request.getParameter("courseId");

        try {
            // 2. Re-fetch the Answer Key from Member 2's DAO to grade the test
            ExamDAO examDAO = new ExamDAO();
            List<String[]> answerKey = examDAO.getExamQuestions(courseId);
            
            int score = 0;
            int totalQuestions = answerKey.size();
            
            // 3. Loop through the key and compare it to the student's submitted answers
            for (int i = 0; i < totalQuestions; i++) {
                // Member 4 must name their HTML radio buttons "answer_0", "answer_1", etc.
                String submittedAnswer = request.getParameter("answer_" + i);
                
                // Index 1 holds the correct answer in Member 2's array
                String correctAnswer = answerKey.get(i)[1]; 
                
                // Prevent NullPointerExceptions if the student skipped a question
                if (submittedAnswer != null && submittedAnswer.equalsIgnoreCase(correctAnswer)) {
                    score++;
                }
            }
            
            // Calculate final percentage
            double percentage = 0;
            if (totalQuestions > 0) {
                percentage = ((double) score / totalQuestions) * 100;
            }

            // 4. Save Final Score using Member 2's CertDAO
            CertDAO certDAO = new CertDAO();
            boolean isSaved = certDAO.saveCertification(username, courseId, percentage);

            // 5. Send results back to the UI
            if (isSaved) {
                request.setAttribute("finalScore", percentage);
                request.setAttribute("successMessage", "Exam submitted! You scored: " + String.format("%.2f", percentage) + "%");
                request.getRequestDispatcher("/student_dashboard.jsp").forward(request, response);
            } else {
                throw new Exception("Failed to save certification to MySQL.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error calculating and saving exam score.");
            request.getRequestDispatcher("/general_error.jsp").forward(request, response);
        }
    }
}
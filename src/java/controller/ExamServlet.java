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
import tools.ExamDAO;
import tools.CertDAO;
import tools.User; // Import the User object we created

public class ExamServlet extends HttpServlet {

    // --- Task 4: Load Exam ---
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String courseId = request.getParameter("courseId");
        if (courseId == null) {
            courseId = "Java101"; 
        }

        try {
            ExamDAO examDAO = new ExamDAO();
            
            // Pass getServletContext() to read credentials from web.xml
            List<String[]> examData = examDAO.getExamQuestions(getServletContext(), courseId);
            
            request.setAttribute("examQuestions", examData);
            request.setAttribute("courseId", courseId);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/take-exam.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database Error: Unable to load the exam.");
            request.getRequestDispatcher("/general_error.jsp").forward(request, response);
        }
    }

    // --- Task 5: Submit & Grade Exam ---
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Use the new "currentUser" attribute we setup in HomeServlet
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login");
            return;
        }
        
        // Extract the username from the User object
        User loggedInUser = (User) session.getAttribute("currentUser");
        String username = loggedInUser.getUsername();
        
        String courseId = request.getParameter("courseId");

        try {
            ExamDAO examDAO = new ExamDAO();
            // Pass getServletContext()
            List<String[]> answerKey = examDAO.getExamQuestions(getServletContext(), courseId);
            
            int score = 0;
            int totalQuestions = answerKey.size();
            
            for (int i = 0; i < totalQuestions; i++) {
                String submittedAnswer = request.getParameter("answer_" + i);
                String correctAnswer = answerKey.get(i)[1]; 
                
                if (submittedAnswer != null && submittedAnswer.equalsIgnoreCase(correctAnswer)) {
                    score++;
                }
            }
            
            double percentage = 0;
            if (totalQuestions > 0) {
                percentage = ((double) score / totalQuestions) * 100;
            }

            CertDAO certDAO = new CertDAO();
            // Pass getServletContext() and save the score to MySQL
            boolean isSaved = certDAO.saveCertification(getServletContext(), username, courseId, percentage);

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
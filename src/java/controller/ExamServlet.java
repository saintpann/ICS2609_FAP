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

@WebServlet(name = "ExamServlet", urlPatterns = {"/takeExam"})
public class ExamServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String courseId = request.getParameter("courseId");
        if (courseId == null) {
            courseId = "Java101"; 
        }

        try {
            ExamDAO examDAO = new ExamDAO();
            List<String[]> examData = examDAO.getExamQuestions(courseId);
            
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("uname") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String username = (String) session.getAttribute("uname");
        String courseId = request.getParameter("courseId");

        try {
            ExamDAO examDAO = new ExamDAO();
            List<String[]> answerKey = examDAO.getExamQuestions(courseId);
            
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
            boolean isSaved = certDAO.saveCertification(username, courseId, percentage);

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
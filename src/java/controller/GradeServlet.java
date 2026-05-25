package controller;

import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import tools.CertDAO;
import tools.ExamDAO;
import tools.User;

@WebServlet(name = "GradeServlet", urlPatterns = {"/gradeExam"})
public class GradeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        ExamDAO examDAO = new ExamDAO();
        String courseIdStr = request.getParameter("courseId");
        String courseCode = request.getParameter("courseCode");
        
        if (courseIdStr == null || courseCode == null) {
            response.sendRedirect(request.getContextPath() + "/takeExam");
            return;
        }

        int courseId = Integer.parseInt(courseIdStr);
        Map<Integer, String> userAnswers = new HashMap<>();
        Enumeration<String> parameterNames = request.getParameterNames();
        
        // Extract dynamically generated text inputs (name="q_1", etc.)
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            if (paramName.startsWith("q_")) {
                int questionId = Integer.parseInt(paramName.substring(2));
                String answer = request.getParameter(paramName);
                userAnswers.put(questionId, answer);
            }
        }

        // 1. Grade the Exam
        double finalScore = examDAO.gradeExam(getServletContext(), courseId, userAnswers);
        boolean passed = finalScore >= 75.0;

        // 2. Save Certificate if Passed
        if (passed) {
            CertDAO certDAO = new CertDAO();
            certDAO.saveCertification(getServletContext(), currentUser.getUsername(), courseCode, finalScore);
        }

        // 3. Forward to Results UI
        request.setAttribute("courseCode", courseCode);
        request.setAttribute("finalScore", String.format("%.2f", finalScore));
        request.setAttribute("passed", passed);
        request.getRequestDispatcher("/app/result.jsp").forward(request, response);
    }
}
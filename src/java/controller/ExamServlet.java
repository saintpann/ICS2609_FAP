package controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import tools.ExamDAO;
import tools.User;

@WebServlet(name = "ExamServlet", urlPatterns = {"/takeExam"})
public class ExamServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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

        if (courseIdStr == null || courseIdStr.trim().isEmpty()) {
            // Load the list of available courses
            List<Map<String, String>> courses = examDAO.getAllCourses(getServletContext());
            request.setAttribute("courses", courses);
            request.getRequestDispatcher("/app/exam_list.jsp").forward(request, response);
        } else {
            // Load the specific exam form
            try {
                int courseId = Integer.parseInt(courseIdStr);
                List<Map<String, String>> questions = examDAO.getQuestionsForCourse(getServletContext(), courseId);
                
                request.setAttribute("courseId", courseId);
                request.setAttribute("courseCode", courseCode);
                request.setAttribute("questions", questions);
                request.getRequestDispatcher("/app/exam_form.jsp").forward(request, response);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/takeExam");
            }
        }
    }
}
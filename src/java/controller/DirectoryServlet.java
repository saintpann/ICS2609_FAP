package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import tools.User;
import tools.UserDAO;

public class DirectoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Security Check
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole().trim())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        // Fetch Users
        UserDAO userDAO = new UserDAO();
        List<User> allUsers = userDAO.getAllUsers(getServletContext());
        
        // Attach to request and forward
        request.setAttribute("userList", allUsers);
        request.getRequestDispatcher("/directory.jsp").forward(request, response);
    }
}
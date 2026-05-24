package controller;

import java.io.IOException;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import tools.Cryptograph;
import tools.UserDAO;
import tools.User; // Import your new Model

public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Look for the "currentUser" object instead of the loose strings
        if (session != null && session.getAttribute("currentUser") != null) {
            
            // Cast the session attribute back to a User object
            User currentUser = (User) session.getAttribute("currentUser");
            
            if ("Admin".equalsIgnoreCase(currentUser.getRole())) {
                request.getRequestDispatcher("/app/admin_dashboard.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/app/student_dashboard.jsp").forward(request, response);
            }
        } else {
            // Noted: login.jsp is in the root directory now
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String inputUname = request.getParameter("username").trim();
        String inputPass = request.getParameter("password").trim();

        if (inputUname != null && inputPass != null) {
            try {
                ServletContext context = getServletContext();
                String secretKey = context.getInitParameter("secretKey");
                String algo = context.getInitParameter("cipherAlgorithm");
                String mode = context.getInitParameter("cipherMode");
                String padding = context.getInitParameter("cipherPadding");

                Cryptograph crypt = new Cryptograph(secretKey, algo, mode, padding);
                String encryptedAttempt = crypt.encrypt(inputPass);

                UserDAO userDao = new UserDAO();
                
                // Fetch the populated User object from the DAO
                User currentUser = userDao.authenticateUser(getServletContext(),inputUname, encryptedAttempt);

                if (currentUser != null) {
                    HttpSession session = request.getSession(true);
                    
                    // Attach the entire User object to the session
                    session.setAttribute("currentUser", currentUser);
                    
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
            } catch (Exception e) {
                System.err.println("Login Processing Error:");
                e.printStackTrace();
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=invalid");
    }
}
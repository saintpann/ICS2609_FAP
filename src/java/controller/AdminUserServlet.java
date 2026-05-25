package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import tools.CertDAO;
import tools.Cryptograph;
import tools.User;
import tools.UserDAO;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/adminAction"})
public class AdminUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Strict Admin Security Check
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole().trim())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        String action = request.getParameter("action");
        String targetUser = request.getParameter("targetUser");
        UserDAO userDAO = new UserDAO();
        CertDAO certDAO = new CertDAO();

        // Prevent admin from deleting or demoting themselves
        if (targetUser != null && targetUser.equalsIgnoreCase(currentUser.getUsername()) && ("delete".equals(action) || "editRole".equals(action))) {
            response.sendRedirect(request.getContextPath() + "/directory?error=You cannot alter or delete your own active session.");
            return;
        }

        try {
            // Cryptograph Init
            String secretKey = getServletContext().getInitParameter("secretKey");
            String algo = getServletContext().getInitParameter("cipherAlgorithm");
            String mode = getServletContext().getInitParameter("cipherMode");
            String padding = getServletContext().getInitParameter("cipherPadding");
            Cryptograph crypt = new Cryptograph(secretKey, algo, mode, padding);

            if ("add".equals(action)) {
                String rawPass = request.getParameter("password");
                String role = request.getParameter("role");
                
                if (userDAO.userExists(getServletContext(), targetUser)) {
                    response.sendRedirect(request.getContextPath() + "/directory?error=Username already exists.");
                    return;
                }
                
                String encryptedPass = crypt.encrypt(rawPass);
                userDAO.registerUser(getServletContext(), targetUser, encryptedPass, role);
                response.sendRedirect(request.getContextPath() + "/directory?success=New user added successfully.");

            } else if ("delete".equals(action)) {
                // Delete certs first, then identity
                certDAO.deleteStudentCertifications(getServletContext(), targetUser);
                userDAO.deleteUser(getServletContext(), targetUser);
                response.sendRedirect(request.getContextPath() + "/directory?success=User " + targetUser + " has been deleted.");

            } else if ("editRole".equals(action)) {
                String newRole = request.getParameter("role");
                userDAO.updateUserRole(getServletContext(), targetUser, newRole);
                response.sendRedirect(request.getContextPath() + "/directory?success=Role updated for " + targetUser + ".");

            } else if ("resetPassword".equals(action)) {
                String newPass = request.getParameter("newPassword");
                String encryptedPass = crypt.encrypt(newPass);
                userDAO.updatePassword(getServletContext(), targetUser, encryptedPass);
                response.sendRedirect(request.getContextPath() + "/directory?success=Password reset for " + targetUser + ".");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/directory?error=A system error occurred.");
        }
    }
}
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

@WebServlet(name = "UserSettingsServlet", urlPatterns = {"/userSettings"})
public class UserSettingsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        String action = request.getParameter("action");
        UserDAO userDAO = new UserDAO();

        try {
            if ("changePassword".equals(action)) {
                String newPass = request.getParameter("newPass");
                String confirmPass = request.getParameter("confirmPass");

                if (!newPass.equals(confirmPass)) {
                    response.sendRedirect(request.getContextPath() + "/settings.jsp?error=Passwords do not match.");
                    return;
                }

                // Encrypt the new password
                String secretKey = getServletContext().getInitParameter("secretKey");
                String algo = getServletContext().getInitParameter("cipherAlgorithm");
                String mode = getServletContext().getInitParameter("cipherMode");
                String padding = getServletContext().getInitParameter("cipherPadding");
                
                Cryptograph crypt = new Cryptograph(secretKey, algo, mode, padding);
                String encryptedPass = crypt.encrypt(newPass);

                boolean success = userDAO.updatePassword(getServletContext(), currentUser.getUsername(), encryptedPass);
                
                if (success) {
                    // Update session object so Self-Report PDF immediately sees the new password
                    currentUser.setPassword(encryptedPass);
                    response.sendRedirect(request.getContextPath() + "/settings.jsp?success=Password updated successfully.");
                } else {
                    response.sendRedirect(request.getContextPath() + "/settings.jsp?error=Failed to update password.");
                }

            } else if ("deleteAccount".equals(action)) {
                // 1. Purge MySQL Certificates
                CertDAO certDAO = new CertDAO();
                certDAO.deleteStudentCertifications(getServletContext(), currentUser.getUsername());
                
                // 2. Delete Derby Identity
                userDAO.deleteUser(getServletContext(), currentUser.getUsername());
                
                // 3. Destroy Session & Redirect
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/index.jsp?success=Your account has been permanently deleted.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/settings.jsp?error=An unexpected system error occurred.");
        }
    }
}